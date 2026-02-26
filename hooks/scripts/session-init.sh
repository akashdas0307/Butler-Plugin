#!/bin/bash
# Handles Hot-Loading vs requiring a Cold Boot

DUMP_FILE="${CLAUDE_PROJECT_DIR}/CONTEXT_DUMP.md"
TODAY=$(date '+%Y-%m-%d')

if [ -f "$DUMP_FILE" ]; then
    # Check if the dump file was created today
    FILE_DATE=$(grep -oE '\*\*Generated:\*\* [0-9]{4}-[0-9]{2}-[0-9]{2}' "$DUMP_FILE" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}')
    
    if [ "$FILE_DATE" = "$TODAY" ]; then
        echo "🔄 **Hot Load Complete:** Local context for $TODAY restored. No Notion sync required."
        echo "---"
        # Print the context so Claude reads it immediately into the prompt
        cat "$DUMP_FILE"
        exit 0
    fi
fi

echo "🌅 **New Day Detected or Context Missing.** Master, please run \`/morning\` to initiate Cold Boot from Notion."
exit 0