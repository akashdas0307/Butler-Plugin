#!/bin/bash
# conversation-logger.sh — Appends every Master message and Butler reply to CONVERSATION.md.
# Fires on: UserPromptSubmit (Master turn), Stop (Butler turn).
# Self-locates from script path — no hardcoded paths, no env var dependency.

# ── SELF-LOCATE ─────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_PLUGIN_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CLAUDE_PROJECT_DIR="$(cd "$CLAUDE_PLUGIN_ROOT/.." && pwd)"
export CLAUDE_PLUGIN_ROOT CLAUDE_PROJECT_DIR
# ─────────────────────────────────────────────────────────────────────────────

DATE=$(date '+%Y-%m-%d %H:%M:%S')
LOG_FILE="$CLAUDE_PROJECT_DIR/CONVERSATION.md"
INPUT=$(cat)
EVENT=$(echo "$INPUT" | jq -r '.event // empty' 2>/dev/null)

# Guard — ensure log file exists
touch "$LOG_FILE"

# Route by event type
if [ "$EVENT" = "UserPromptSubmit" ]; then
  MSG=$(echo "$INPUT" | jq -r '.prompt // empty' 2>/dev/null)
  echo -e "\n**Master [$DATE]:** $MSG" >> "$LOG_FILE"

elif [ "$EVENT" = "Stop" ]; then
  MSG=$(echo "$INPUT" | jq -r '.message // .text // "[Response]"' 2>/dev/null)
  echo -e "**Butler [$DATE]:** $MSG" >> "$LOG_FILE"
  echo "---" >> "$LOG_FILE"
fi

exit 0