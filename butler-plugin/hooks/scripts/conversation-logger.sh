#!/bin/bash
# Isolates conversation logs outside the main context window.
INPUT=$(cat)
EVENT=$(echo "$INPUT" | jq -r '.hook_event_name // empty')
DATE=$(date '+%Y-%m-%d %H:%M:%S')
LOG_FILE="${CLAUDE_PROJECT_DIR}/CONVERSATION.md"

if[ "$EVENT" = "UserPromptSubmit" ]; then
    MSG=$(echo "$INPUT" | jq -r '.prompt // empty')
    echo "**Master [${DATE}]:** ${MSG}" >> "$LOG_FILE"
elif[ "$EVENT" = "Stop" ]; then
    echo "**Butler [${DATE}]:** [Task Completed / Responded]" >> "$LOG_FILE"
    echo "---" >> "$LOG_FILE"
fi

exit 0