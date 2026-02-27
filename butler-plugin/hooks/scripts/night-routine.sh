#!/bin/bash
# night-routine.sh
# Role: File system cleanup only. Notion sync + reflection handled by /night-routine agent command.
# Called by: scheduler or /night-routine command as a pre-step.

set -e

DATE=$(date "+%Y-%m-%d %H:%M:%S")
TODAY=$(date "+%Y-%m-%d")
PROJECT_DIR="${CLAUDE_PROJECT_DIR}"
CONV_FILE="${PROJECT_DIR}/CONVERSATION.md"
ARCHIVE_DIR="${PROJECT_DIR}/archive/${TODAY}"
WORK_DIR="${PROJECT_DIR}/work"
SIGNOFF_FILE="${PROJECT_DIR}/SIGNOFF.md"

# --- Step 1: Validate environment ---
if [ -z "$PROJECT_DIR" ]; then
  echo "ERROR: CLAUDE_PROJECT_DIR is not set. Aborting." >&2
  exit 1
fi

# --- Step 2: Create today's archive directory ---
mkdir -p "$ARCHIVE_DIR"

# --- Step 3: Archive today's CONVERSATION.md ---
if [ -f "$CONV_FILE" ] && [ -s "$CONV_FILE" ]; then
  cp "$CONV_FILE" "${ARCHIVE_DIR}/CONVERSATION_${TODAY}.md"
  # Clear for tomorrow — do not delete, just empty
  > "$CONV_FILE"
  echo "[night-routine] CONVERSATION.md archived to ${ARCHIVE_DIR}"
else
  echo "[night-routine] CONVERSATION.md empty or missing — skipping archive"
fi

# --- Step 4: Archive completed work files ---
if [ -d "$WORK_DIR" ] && [ "$(ls -A $WORK_DIR 2>/dev/null)" ]; then
  mv "${WORK_DIR}"/* "$ARCHIVE_DIR"/ 2>/dev/null || true
  echo "[night-routine] work/ files moved to archive/${TODAY}/"
else
  echo "[night-routine] No work files to archive"
fi

# --- Step 5: Clear stale daily files (they regenerate each morning) ---
for stale_file in NOTIFICATIONS.md SCHEDULE.md; do
  if [ -f "${PROJECT_DIR}/${stale_file}" ]; then
    > "${PROJECT_DIR}/${stale_file}"
    echo "[night-routine] Cleared ${stale_file}"
  fi
done

# --- Step 6: Write signoff timestamp ---
echo "## Night Routine — ${DATE}" >> "$SIGNOFF_FILE"
echo "- CONVERSATION.md archived: ${TODAY}" >> "$SIGNOFF_FILE"
echo "- Stale files cleared: NOTIFICATIONS.md, SCHEDULE.md" >> "$SIGNOFF_FILE"
echo "- work/ archived to: archive/${TODAY}/" >> "$SIGNOFF_FILE"
echo "" >> "$SIGNOFF_FILE"

echo "[night-routine] Complete: ${DATE}"
exit 0
