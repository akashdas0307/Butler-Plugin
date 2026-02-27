#!/bin/bash
# session-init.sh — Hot-load check. Fires at session start (PreToolUse or SessionStart).
# Self-locates from script path — no hardcoded paths, no env var dependency.

# ── SELF-LOCATE ─────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_PLUGIN_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CLAUDE_PROJECT_DIR="$(cd "$CLAUDE_PLUGIN_ROOT/.." && pwd)"
export CLAUDE_PLUGIN_ROOT CLAUDE_PROJECT_DIR
# ─────────────────────────────────────────────────────────────────────────────

TODAY=$(date '+%Y-%m-%d')
DUMP_FILE="$CLAUDE_PROJECT_DIR/CONTEXT_DUMP.md"
CORE_FILES=(CLAUDE.md USER.md SOUL.md SCRATCHPAD.md MEMORYLOG.md)
ALL_PRESENT=true

# Check if today's context dump exists
if [ -f "$DUMP_FILE" ]; then
  FILE_DATE=$(grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' "$DUMP_FILE" | head -1)

  if [ "$FILE_DATE" = "$TODAY" ]; then
    # Verify each core file exists locally
    for f in "${CORE_FILES[@]}"; do
      if [ ! -f "$CLAUDE_PROJECT_DIR/$f" ]; then
        ALL_PRESENT=false
        echo "WARN: Missing local file: $f"
      fi
    done

    if [ "$ALL_PRESENT" = true ]; then
      echo "HOT_LOAD_STATUS=COMPLETE"
      echo "SOURCE=$DUMP_FILE"
      cat "$DUMP_FILE"
      exit 0
    else
      echo "HOT_LOAD_STATUS=INCOMPLETE"
      echo "ACTION: Some core files missing. Run /morning to restore full context."
      exit 1
    fi
  fi
fi

echo "HOT_LOAD_STATUS=STALE_OR_MISSING"
echo "ACTION: No valid context for today. Run /morning."
exit 0