#!/bin/bash
# Cold Boot Script: Prepares the Context Dump.

DUMP_FILE="${CLAUDE_PROJECT_DIR}/CONTEXT_DUMP.md"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

echo "# BUTLER CONTEXT DUMP" > "$DUMP_FILE"
echo "**Generated:** $DATE" >> "$DUMP_FILE"
echo "---" >> "$DUMP_FILE"

echo "*(Waiting for Butler to inject Notion data...)*" >> "$DUMP_FILE"

exit 0