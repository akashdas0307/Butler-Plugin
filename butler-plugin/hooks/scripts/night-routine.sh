#!/bin/bash
# night-routine.sh — End-of-day reflection, Notion sync, archive, signoff.
# Trigger time: ~23:00 (pattern-adaptive, not hardcoded — read from MEMORYLOG.md).
# Self-locates from script path — no hardcoded paths, no env var dependency.

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

if [ -d "$CLAUDE_PROJECT_DIR/work" ]; then
  # Move completed files (non-empty) to archive
  find "$CLAUDE_PROJECT_DIR/work" -maxdepth 1 -type f | while read -r file; do
    mv "$file" "$ARCHIVE_DIR/" && echo "ARCHIVED: $file"
  done
fi

# Clear daily refresh files
rm -f "$CLAUDE_PROJECT_DIR/NOTIFICATIONS.md"
rm -f "$CLAUDE_PROJECT_DIR/SCHEDULE.md"
echo "Cleared: NOTIFICATIONS.md, SCHEDULE.md"

# ── 5. SIGNOFF ──────────────────────────────────────────────────────────────
echo "Night routine complete: $DATE" >> "$CLAUDE_PROJECT_DIR/SIGNOFF.md"
echo "[$DATE] Night routine complete."

exit 0