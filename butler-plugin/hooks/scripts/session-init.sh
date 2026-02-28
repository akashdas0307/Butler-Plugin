#!/bin/bash
# session-init.sh — Hot-load check. Fires at SessionStart.
# Reads today's CONTEXT_DUMP.md and prints it into context if fresh.

# ── SELF-LOCATE ─────────────────────────────────────────────────────────────
# Finds the latest cached plugin version and the workspace root independently.
BUTLER=$(find /sessions -path "*/.local-plugins/cache/butler-plugin/butler-plugin/*/scripts/cold-boot.sh" -type f 2>/dev/null | sort -V | tail -1 | xargs dirname | xargs dirname)

if [ -z "$BUTLER" ]; then
  echo "ERROR: Cannot locate butler-plugin"
  exit 1
fi

CLAUDE_PLUGIN_ROOT="$BUTLER"
CLAUDE_PROJECT_DIR="$(find /sessions/*/mnt -maxdepth 1 -type d ! -name "mnt" ! -name ".*" 2>/dev/null | head -1)"
export CLAUDE_PLUGIN_ROOT CLAUDE_PROJECT_DIR
# ─────────────────────────────────────────────────────────────────────────────

TODAY=$(date '+%Y-%m-%d')
DUMP_FILE="$CLAUDE_PROJECT_DIR/CONTEXT_DUMP.md"
CORE_FILES=(CLAUDE.md USER.md SOUL.md SCRATCHPAD.md MEMORYLOG.md TASK.md)
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
