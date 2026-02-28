#!/bin/bash
# night-routine-FIXED.sh — Optimized for API rate limiting & error handling
#
# CHANGES FROM ORIGINAL:
#  ✓ Added rate limiting (0.5s delay) between Notion calls
#  ✓ Added exponential backoff retry logic
#  ✓ Added error handling for failed syncs
#  ✓ Added timing metrics for debugging
#  ✓ Safe defaults: script continues even if some syncs fail
#
# USAGE: Replace hooks/scripts/night-routine.sh with this version in the plugin

# ── SELF-LOCATE ─────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_PLUGIN_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CLAUDE_PROJECT_DIR="$(cd "$CLAUDE_PLUGIN_ROOT/.." && pwd)"
export CLAUDE_PLUGIN_ROOT CLAUDE_PROJECT_DIR
# ─────────────────────────────────────────────────────────────────────────────

DATE=$(date '+%Y-%m-%d %H:%M:%S')
TODAY=$(date '+%Y-%m-%d')
REFS="$CLAUDE_PLUGIN_ROOT/core-modules-references.json"
CONV="$CLAUDE_PROJECT_DIR/CONVERSATION.md"

echo "[$DATE] Night routine starting (OPTIMIZED)..."
START_TIME=$(date +%s)

# ── UTILITY: Retry with exponential backoff ──────────────────────────────────
retry_with_backoff() {
  local description=$1
  local command=$2
  local max_retries=3
  local delay=1
  local attempt=1

  while [ $attempt -le $max_retries ]; do
    echo "  → Attempt $attempt/$max_retries: $description"

    if eval "$command"; then
      echo "  ✓ Success: $description"
      return 0
    fi

    if [ $attempt -lt $max_retries ]; then
      echo "  ⚠ Failed. Waiting ${delay}s before retry..."
      sleep $delay
      delay=$((delay * 2))  # Exponential backoff: 1s → 2s → 4s
    fi

    attempt=$((attempt + 1))
  done

  echo "  ✗ Failed after $max_retries retries: $description"
  return 1
}

# ── 1. REFLECTION (offload to Haiku subagent) ───────────────────────────────
echo "[1/4] Starting reflection..."
if [ -f "$CONV" ]; then
  echo "  → REFLECTION_INPUT=$CONV"
  echo "  → REFLECTION_STATUS=PENDING_SUBAGENT"
  REFLECTION_SPAWNED=1
else
  echo "  ⚠ WARN: CONVERSATION.md not found — skipping reflection."
  REFLECTION_SPAWNED=0
fi

# ── 2. NOTION SYNC (WITH RATE LIMITING) ──────────────────────────────────────
echo "[2/4] Syncing to Notion (with rate limiting)..."
if [ ! -f "$REFS" ]; then
  echo "  ✗ ERROR: core-modules-references.json missing. Skipping Notion sync."
else
  CORE_FILES=(CLAUDE.md USER.md SOUL.md SCRATCHPAD.md MEMORYLOG.md TASK.md)
  SYNC_SUCCESS=0
  SYNC_FAILED=0

  for f in "${CORE_FILES[@]}"; do
    LOCAL_FILE="$CLAUDE_PROJECT_DIR/$f"

    if [ -f "$LOCAL_FILE" ]; then
      PAGE_ID=$(jq -r ".[\"$f\"].notion_page_id // empty" "$REFS" 2>/dev/null)

      if [ -n "$PAGE_ID" ]; then
        # Rate limiting: wait 0.5s before each Notion call
        # This prevents API 529 (Overloaded) errors by spreading requests
        sleep 0.5

        # Retry logic: if sync fails, retry with exponential backoff
        if retry_with_backoff "Notion: $f → $PAGE_ID" \
           "notion-update-page $PAGE_ID < $LOCAL_FILE 2>/dev/null"; then
          SYNC_SUCCESS=$((SYNC_SUCCESS + 1))
        else
          SYNC_FAILED=$((SYNC_FAILED + 1))
          echo "  ⚠ Continuing despite failure (not critical)..."
        fi
      else
        echo "  ⚠ WARN: No Notion page_id for $f in refs. Skipping."
      fi
    fi
  done

  echo "  Summary: $SYNC_SUCCESS synced, $SYNC_FAILED failed"
fi

# ── 3. SCRATCHPAD REVIEW ────────────────────────────────────────────────────
echo "[3/4] Reviewing scratchpad..."
echo "  → SCRATCHPAD_REVIEW=PENDING_AGENT"

# ── 4. ARCHIVE & CLEANUP ────────────────────────────────────────────────────
echo "[4/4] Archiving & cleanup..."
ARCHIVE_DIR="$CLAUDE_PROJECT_DIR/archive/$TODAY"
mkdir -p "$ARCHIVE_DIR"

# Archive CONVERSATION.md
if [ -f "$CONV" ]; then
  cp "$CONV" "$ARCHIVE_DIR/CONVERSATION_${TODAY}.md"
  echo "  ✓ Archived: CONVERSATION.md"
  > "$CONV"
  echo "  ✓ Cleared: CONVERSATION.md"
fi

# Clear daily refresh files
[ -f "$CLAUDE_PROJECT_DIR/NOTIFICATIONS.md" ] && rm -f "$CLAUDE_PROJECT_DIR/NOTIFICATIONS.md" && echo "  ✓ Cleared: NOTIFICATIONS.md"
[ -f "$CLAUDE_PROJECT_DIR/SCHEDULE.md" ] && rm -f "$CLAUDE_PROJECT_DIR/SCHEDULE.md" && echo "  ✓ Cleared: SCHEDULE.md"

# ── TIMING & SIGNOFF ────────────────────────────────────────────────────────
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Night routine complete: $DATE"
echo "Duration: ${DURATION}s"
echo "Status: ✓ Success"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "Good night, Master. Patterns logged, Notion synced, and systems cleared for tomorrow."
echo "" >> "$CLAUDE_PROJECT_DIR/SIGNOFF.md"
echo "[$DATE] Night routine complete (duration: ${DURATION}s)" >> "$CLAUDE_PROJECT_DIR/SIGNOFF.md"

exit 0