---
description: Commands the Butler to begin working on the tasks listed under Butler Tasks.
---

# Execute Command

Master has approved the schedule and dashboard. It is time for you to work.

## 1. Read Current State
Read the local files: `TASK.md` (at `$PROJ` workspace root), `NOTIFICATIONS.md`, and `SCHEDULE.md` (both at `$PROJ/butler/`).

## 2. Execute Butler Tasks
Look specifically under `## Butler Tasks` in `TASK.md`.
Prioritize: [URGENT] > [Important] > [General]

For each task assigned to you:
1. **Analyze**: What tools are required?
   - **Token-Heavy Work**: Spawn subagent [model: haiku] with task context.
   - **Email**: Use `gmail_create_draft` (NEVER `gmail_send`).
   - **Calendar**: Use Google Calendar MCP tool.

2. **Execute**: Perform the task autonomously.

3. **Update Local Files (MANDATORY — do this immediately after each task, before moving to the next):**
   - **Calendar action** → Append the new event as a row to the `## Today's Events` table in `$PROJ/butler/SCHEDULE.md`. Format: `| HH:MM AM/PM – HH:MM AM/PM | [emoji] Event Title | Brief notes |`. If the table doesn't exist yet, create it with header `| Time | Event | Notes |\n|------|-------|-------|` first. Save the file to disk immediately.
   - **Task completed** → Move it from `## Butler Tasks` to `## Done` in `$PROJ/TASK.md` (workspace root) and save to disk immediately.
   - **Email handled** → Remove that email entry from `$PROJ/butler/NOTIFICATIONS.md` and save to disk immediately.

   > The HTML dashboard polls local files every second. Writing to disk is what makes the dashboard update in real-time.

## 3. Report
When all `## Butler Tasks` are complete, output exactly: "Master, my assigned tasks are complete and the Dashboard has been updated. I am standing by."
