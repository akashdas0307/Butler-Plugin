#!/bin/bash
# conversation-logger.sh — Appends every Master message and Butler reply to CONVERSATION.md.
# Fires on: UserPromptSubmit (Master turn), Stop (Butler turn).
#
# Fix v1.2.8:
#   - Self-locate via find instead of SCRIPT_DIR (hooks run from plugin cache, not workspace)
#   - Event detection checks .event AND .hook_event_name (Claude Code native format)
#   - Fallback Stop detection via presence of .message/.text (if event field missing)

# ── SELF-LOCATE ─────────────────────────────────────────────────────────────
# Hook scripts live inside the read-only plugin cache (.local-plugins).
# Must find the user's actual butler project folder in the workspace.
BUTLER=$(find /sessions -maxdepth 10 -name "butler" -type d \
  -not -path "*/.local-plugins/*" \
  -not -path "*/.skills/*" \
  2>/dev/null | head -1)

if [ -z "$BUTLER" ]; then
  # Fallback: resolve from script path (works if plugin installed in workspace)
  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
  BUTLER="$(cd "$SCRIPT_DIR/../.." && pwd)"
fi

CLAUDE_PLUGIN_ROOT="$BUTLER"
CLAUDE_PROJECT_DIR="$BUTLER"
export CLAUDE_PLUGIN_ROOT CLAUDE_PROJECT_DIR
# ─────────────────────────────────────────────────────────────────────────────

DATE=$(date '+%Y-%m-%d %H:%M:%S')
LOG_FILE="$CLAUDE_PROJECT_DIR/CONVERSATION.md"
INPUT=$(cat)

# Guard — ensure log file exists
touch "$LOG_FILE"

# Detect event: check .event first, then .hook_event_name (Claude Code native format)
EVENT=$(echo "$INPUT" | jq -r '.event // .hook_event_name // empty' 2>/dev/null)

# Fallback: if no event field but message/text fields exist, it's a Stop (Butler response)
if [ -z "$EVENT" ]; then
  HAS_MSG=$(echo "$INPUT" | jq -r '.message // .text // empty' 2>/dev/null)
  if [ -n "$HAS_MSG" ]; then
    EVENT="Stop"
  fi
fi

# Route by event type
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