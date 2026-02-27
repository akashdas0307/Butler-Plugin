---
description: Commands the Butler to begin working on the tasks listed under Butler Tasks.
---

# Execute Command

Master has approved the schedule and dashboard. It is time for you to work.

## 1. Read Current State
Read the local files: `TASK.md`, `NOTIFICATIONS.md`, and `SCHEDULE.md`.

## 2. Execute Butler Tasks
Look specifically under `## Butler Tasks` in `TASK.md`.
Prioritize: [URGENT] > [Important] > [General]

For each task assigned to you:
1. **Analyze**: What tools are required?
   - **Token-Heavy Work**: Spawn subagent [model: haiku] with task context.
   - **Email**: Use `gmail_create_draft` (NEVER `gmail_send`).
   - **Calendar**: Use Google Calendar MCP tool.

2. **Execute**: Perform the task autonomously.

3. **Update UI**: Move the completed task from `## Butler Tasks` to `## Done` in `TASK.md`. Ensure you write the file to the local disk immediately so the Master's HTML Dashboard updates in real-time.

## 3. Clear Notifications
If a task involved handling an email from `NOTIFICATIONS.md`, remove that email from the Notifications file and save it, clearing it from the Master's dashboard.

## 4. Report
When all `## Butler Tasks` are complete, output exactly: "Master, my assigned tasks are complete and the Dashboard has been updated. I am standing by."
