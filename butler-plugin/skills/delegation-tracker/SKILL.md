---
name: delegation-tracker
description: Use when the Master delegates a task to someone else or mentions waiting on a dependency.
---
# Delegation SOP
1. When Master delegates a task, update `TASKS.md` under `## Waiting On`.
2. Format: `- [ ] **[Task Name]** - Waiting on [Person] since [Date]`.
3. Automatically calculate a follow-up date (default: +3 days).
4. If the Master asks to "check delegations", review the `Waiting On` list. For any task past its follow-up date, automatically use `gmail_create_draft` to draft a gentle ping to that person, and notify the Master.