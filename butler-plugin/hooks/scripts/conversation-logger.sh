#!/bin/bash
# conversation-logger.sh v1.3.0
# Fires on: UserPromptSubmit (Master turn), Stop (Butler turn).
#
# Fixes vs previous versions:
#   1. hooks.json now has top-level "hooks" wrapper — Zod validation passes
#   2. UserPromptSubmit input block now passes {{prompt}}
#   3. Checks .event AND .hook_event_name (Claude Code native format)
#   4. Fallback Stop detection via .message/.text presence
#   5. Self-locates butler dir via find (plugin cache is read-only)

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

DATE=$(date '+%Y-%m-%d %H:%M:%S')
LOG_FILE="$CLAUDE_PROJECT_DIR/CONVERSATION.md"
INPUT=$(cat)

touch "$LOG_FILE"

EVENT=$(echo "$INPUT" | jq -r '.event // .hook_event_name // empty' 2>/dev/null)

if [ -z "$EVENT" ]; then
  HAS_MSG=$(echo "$INPUT" | jq -r '.message // .text // empty' 2>/dev/null)
  if [ -n "$HAS_MSG" ]; then
    EVENT="Stop"
  fi
fi

if [ "$EVENT" = "UserPromptSubmit" ]; then
  MSG=$(echo "$INPUT" | jq -r '.prompt // empty' 2>/dev/null)
  if [ -n "$MSG" ]; then
    echo -e "\n**Master [$DATE]:** $MSG" >> "$LOG_FILE"
  fi
elif [ "$EVENT" = "Stop" ]; then
  MSG=$(echo "$INPUT" | jq -r '.message // .text // "[Response]"' 2>/dev/null)
  echo -e "**Butler [$DATE]:** $MSG" >> "$LOG_FILE"
  echo "---" >> "$LOG_FILE"
fi

exit 0
