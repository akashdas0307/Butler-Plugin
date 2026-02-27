#!/bin/bash
DUMP_FILE="${CLAUDE_PROJECT_DIR}/CONTEXT_DUMP.md"
TODAY=$(date '+%Y-%m-%d')
CORE_FILES=(CLAUDE.md USER.md SOUL.md SCRATCHPAD.md MEMORYLOG.md)
ALL_PRESENT=true

if [ -f "$DUMP_FILE" ]; then
  FILE_DATE=$(grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' "$DUMP_FILE" | head -1)

  if [ "$FILE_DATE" = "$TODAY" ]; then
    # Verify each core file exists locally
    for f in "${CORE_FILES[@]}"; do
      if [ ! -f "${CLAUDE_PROJECT_DIR}/$f" ]; then
        ALL_PRESENT=false
        echo "⚠️ Missing local file: $f"
      fi
    done

    if [ "$ALL_PRESENT" = true ]; then
      echo "🔄 Hot Load Complete: All context for $TODAY restored."
      cat "$DUMP_FILE"
      exit 0
    else
      echo "HOT_LOAD_STATUS=INCOMPLETE"
      echo "ACTION_REQUIRED: Some core files missing locally. Run /morning to restore full context."
      exit 1
    fi
  fi
fi

echo "🌅 No valid context for today. Run /morning to Cold Boot."
exit 0
