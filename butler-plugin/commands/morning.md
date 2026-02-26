---
description: The daily cold-boot sequence. Fetches context, preps calendar, and loads dashboard.
---

# Morning Command

Execute the morning protocol immediately.

## 1. Cold Boot (Context Assembly)
Execute the cold-boot script: !`bash ${CLAUDE_PLUGIN_ROOT}/scripts/cold-boot.sh`
This script reads `core-modules-references.json`, fetches the 6 core files from the `~~knowledge base`, and creates `CONTEXT_DUMP.md` locally. 
Read `CONTEXT_DUMP.md` into your context.
Fetch the latest `TASK.md` content from Notion and save it locally.

## 2. Information Gathering
- **Email**: Use `~~email` to fetch `is:unread newer_than:1d` (Max 20). Spwan `email-triage` subagent to categorize them into: [Important], [General], [Financial].
- **Calendar**: Use `~~calendar` to pull today's schedule and imminent deadlines. Spawn `schedule-optimizer` subagent.

## 3. Dashboard Prep & Strategy
Ensure `butler-dashboard.html` exists locally. Write the subagent findings to `NOTIFICATIONS.md` and `SCHEDULE.md`.
Update `TASKS.md` separating:
- **Master Tasks**: Tasks the Master must do manually.
- **Butler Tasks**: Tasks you will execute automatically (e.g., drafting emails).

## 4. Master Presentation
Present the morning summary concisely and request confirmation: "Shall I lock this schedule and begin Butler Tasks, Master? If so, run `/execute`."