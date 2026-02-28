#!/bin/bash
# night-routine.sh — End-of-day reflection, Notion sync, archive, signoff.
# Trigger time: ~23:00 IST (scheduled via butler:night-routine command).
#
# Fix v1.2.8:
#   - Self-locate via find (same as conversation-logger.sh) — old SCRIPT_DIR
#     approach resolved into the read-only plugin cache, not the butler workspace.
#   - Archive now truncates files instead of rm (avoids permission errors).

# ── SELF-LOCATE ─────────────────────────────────────────────────────────────
BUTLER=$(find /sessions -maxdepth 10 -name "butler" -type d \
  -not -path "*/.local-plugins/*" \
  -not -path "*/.skills/*" \
  2>/dev/null | head -1)

if [ -z "$BUTLER" ]; then
  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
  BUTLER="$(cd "$SCRIPT_DIR/../.." && pwd)"
fi

CLAUDE_PLUGIN_ROOT="$BUTLER"
CLAUDE_PROJECT_DIR="$BUTLER"
export CLAUDE_PLUGIN_ROOT CLAUDE_PROJECT_DIR
# ─────────────────────────────────────────────────────────────────────────────

DATE=$(date '+%Y-%m-%d %H:%M:%S')
TODAY=$(date '+%Y-%m-%d')
REFS="$CLAUDE_PLUGIN_ROOT/core-modules-references.json"
CONV="$CLAUDE_PROJECT_DIR/CONVERSATION.md"

echo "[$DATE] Night routine starting..."

# ── 1. REFLECTION (offload to Haiku subagent) ───────────────────────────────
# Pass CONVERSATION.md to subagent (model: claude-haiku).
# Subagent task:
#   - Identify patterns in master's requests today
#   - Note what Butler did well vs poorly
#   - Draft 1-3 improvement hypotheses
#   - Write output to $CLAUDE_PROJECT_DIR/SIGNOFF.md
if [ -f "$CONV" ]; then
  echo "REFLECTION_INPUT=$CONV"
  echo "REFLECTION_STATUS=PENDING_SUBAGENT"
else
  echo "WARN: CONVERSATION.md not found — skipping reflection."
fi

# ── 2. NOTION SYNC ──────────────────────────────────────────────────────────
# Validate refs file exists before attempting sync
if [ ! -f "$REFS" ]; then
  echo "ERROR: core-modules-references.json missing. Skipping Notion sync."
else
  CORE_FILES=(CLAUDE.md USER.md SOUL.md SCRATCHPAD.md MEMORYLOG.md TASK.md)
  for f in "${CORE_FILES[@]}"; do
    LOCAL_FILE="$CLAUDE_PROJECT_DIR/$f"
    if [ -f "$LOCAL_FILE" ]; then
      PAGE_ID=$(jq -r ".[\"$f\"].notion_page_id // empty" "$REFS" 2>/dev/null)
      if [ -n "$PAGE_ID" ]; then
        echo "NOTION_SYNC: $f → $PAGE_ID"
        # Agent will execute: notion-update-page $PAGE_ID with content of $LOCAL_FILE
      else
        echo "WARN: No Notion page_id for $f in refs. Skipping."
      fi
    fi
  done
fi

# ── 3. SCRATCHPAD REVIEW ────────────────────────────────────────────────────
# Agent promotes validated hypotheses SCRATCHPAD.md → MEMORYLOG.md
# Clears confirmed/invalidated items from SCRATCHPAD.md
echo "SCRATCHPAD_REVIEW=PENDING_AGENT"

# ── 4. ARCHIVE ──────────────────────────────────────────────────────────────
ARCHIVE_DIR="$CLAUDE_PROJECT_DIR/archive/$TODAY"
mkdir -p "$ARCHIVE_DIR"

if [ -f "$CONV" ]; then
  cp "$CONV" "$ARCHIVE_DIR/CONVERSATION_${TODAY}.md"
  echo "ARCHIVED: CONVERSATION.md → archive/$TODAY/"
  # Truncate (not rm) — workspace may restrict deletion
  > "$CONV"
  echo "Cleared: CONVERSATION.md"
fi

# Clear daily refresh files (truncate, not rm)
[ -f "$CLAUDE_PROJECT_DIR/NOTIFICATIONS.md" ] && > "$CLAUDE_PROJECT_DIR/NOTIFICATIONS.md" && echo "Cleared: NOTIFICATIONS.md"
[ -f "$CLAUDE_PROJECT_DIR/SCHEDULE.md" ]      && > "$CLAUDE_PROJECT_DIR/SCHEDULE.md"      && echo "Cleared: SCHEDULE.md"

# ── 5. SIGNOFF ──────────────────────────────────────────────────────────────
echo "Night routine complete: $DATE" >> "$CLAUDE_PROJECT_DIR/SIGNOFF.md"
echo "[$DATE] Night routine complete."

exit 0