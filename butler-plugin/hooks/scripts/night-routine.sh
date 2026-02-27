#!/bin/bash
# night-routine.sh — Fires at ~23:00 (time is pattern-adaptive, not hardcoded)

DATE=$(date '+%Y-%m-%d %H:%M:%S')
TODAY=$(date '+%Y-%m-%d')

# 1. Reflection — Offload to Haiku subagent
# Pass CONVERSATION.md content. Ask subagent to:
# - Identify patterns in master's requests today
# - Note what Butler did well vs poorly
# - Draft 1-3 improvement hypotheses
# Output written to SIGNOFF.md

# 2. Core File Updates
# Read local: CLAUDE.md, USER.md, SOUL.md, SCRATCHPAD.md, MEMORYLOG.md, TASK.md
# Push each to Notion via notion-update-page using core-modules-references.json page_ids

# 3. Scratchpad Review
# Promote validated hypotheses from SCRATCHPAD.md → MEMORYLOG.md
# Clear confirmed/invalidated items from SCRATCHPAD.md

# 4. Archive
# Move completed work files from ${CLAUDE_PROJECT_DIR}/work/ → ${CLAUDE_PROJECT_DIR}/archive/${TODAY}/
# Clear NOTIFICATIONS.md and SCHEDULE.md (they refresh each morning)

# 5. Signoff
echo "Night routine complete: $DATE" >> "${CLAUDE_PROJECT_DIR}/SIGNOFF.md"
