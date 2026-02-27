---
description: The daily cold-boot sequence. Fetches context, preps calendar, and loads dashboard.
---

# Morning Command

Execute the morning protocol immediately.

## 1. Cold Boot (Context Assembly)

Run: !`bash ${CLAUDE_PLUGIN_ROOT}/scripts/cold-boot.sh`

Parse output:
- If `COLD_BOOT_STATUS=LOCAL_COMPLETE`:
  → Read CONTEXT_DUMP.md into context. Proceed to Step 2.

- If `COLD_BOOT_STATUS=NOTION_FETCH_REQUIRED`:
  → Read core-modules-references.json
  → For each file in MISSING_FILES: fetch from Notion via notion-retrieve-page using the page_id
  → Save each fetched file to ${CLAUDE_PROJECT_DIR}/
  → Re-run cold-boot.sh
  → Read assembled CONTEXT_DUMP.md into context

- If `COLD_BOOT_STATUS=REFS_MISSING`:
  → Surface to Master: "core-modules-references.json missing. Run /onboarding first."
  → Stop.

## 2. Information Gathering
- **Email**: Use the `gmail` MCP — search for `is:unread newer_than:1d`, limit 20 results. Write output to NOTIFICATIONS.md.
- **Calendar**: Use the `google-calendar` MCP — list all events for today. Write output to SCHEDULE.md.

## 3. Dashboard Prep

# 3a — Ensure dashboard exists (COPY, never regenerate)
!`DASH="${CLAUDE_PROJECT_DIR}/butler-dashboard.html"; if [ ! -f "$DASH" ]; then cp "${CLAUDE_PLUGIN_ROOT}/dashboard/butler-dashboard.html" "$DASH"; fi`

# 3b — Offload triage and calendar to Haiku subagents (token efficiency)
Spawn subagent [model: haiku] → Task: "Read emails from NOTIFICATIONS.md. Categorize each as [Important], [Financial], [General], or [Other] based on USER.md triage rules. Output structured list only."

Spawn subagent [model: haiku] → Task: "Read Google Calendar for today. List all events with time, title, location. Output structured list only."

# 3c — Write subagent outputs to data files
Write email triage output → NOTIFICATIONS.md
Write calendar output → SCHEDULE.md
Update TASK.md: separate Master Tasks vs Butler Tasks

# 3d — Tell Master
"Dashboard ready. Open butler-dashboard.html from your working directory."
"It reads NOTIFICATIONS.md, SCHEDULE.md, and TASK.md automatically."

## 4. Master Presentation
Present the morning summary concisely and request confirmation: "Shall I lock this schedule and begin Butler Tasks, Master? If so, run `/execute`."
