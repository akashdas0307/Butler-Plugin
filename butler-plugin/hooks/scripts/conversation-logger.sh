#!/bin/bash
# Isolates conversation logs outside the main context window.
INPUT=$(cat)
EVENT=$(echo "$INPUT" | jq -r '.hook_event_name // empty')
DATE=$(date '+%Y-%m-%d %H:%M:%S')
LOG_FILE="${CLAUDE_PROJECT_DIR}/CONVERSATION.md"

# Guard against missing file
touch "$LOG_FILE"

if [ "$EVENT" = "UserPromptSubmit" ]; then
    MSG=$(echo "$INPUT" | jq -r '.prompt // empty')
    echo -e "\n**Master [${DATE}]:** ${MSG}" >> "$LOG_FILE"
elif [ "$EVENT" = "Stop" ]; then
    MSG=$(echo "$INPUT" | jq -r '.message // .text // "[Response]"')
    echo -e "**Butler [${DATE}]:** ${MSG}" >> "$LOG_FILE"
    echo "---" >> "$LOG_FILE"
fi
