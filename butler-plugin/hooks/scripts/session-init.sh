#!/bin/bash
# session-init.sh — Hot-load check. Fires at SessionStart.
# Reads today's CONTEXT_DUMP.md and prints it into context if fresh.

# ── SELF-LOCATE ─────────────────────────────────────────────────────────────
# The hook scripts live inside the read-only plugin cache (.local-plugins).
# We must find the user's actual "butler" project folder in the workspace.
BUTLER=$(find /sessions -maxdepth 10 -name "butler" -type d \
  -not -path "*/.local-plugins/*" \
  -not -path "*/.skills/*" \
  2>/dev/null | head -1)

if [ -z "$BUTLER" ]; then
  # Fallback: resolve from script path (works if plugin is installed in workspace)
  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
  BUTLER="$(cd "$SCRIPT_DIR/../.." && pwd)"
fi

CLAUDE_PLUGIN_ROOT="$BUTLER"
CLAUDE_PROJECT_DIR="$BUTLER"
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
