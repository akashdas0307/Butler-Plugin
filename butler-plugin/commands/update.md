---
description: Synchronizes local files (TASK.md, CLAUDE.md) back to their permanent Notion pages mid-day.
---

# Update Command

Execute the synchronization protocol immediately.

## 1. Load References
Read the `core-modules-references.json` in the local directory to obtain the Notion `page_id`s for `CLAUDE`, `USER`, `SOUL`, `SCRATCHPAD`, `TASK`, and `MEMORYLOG`.

## 2. Sync to Notion
For each file that exists locally in the working directory (e.g., `TASK.md`):
1. Read its contents.
2. Use the `~~knowledge base` MCP (`notion-update-page`) to overwrite the corresponding Notion page with the latest local content using the `page_id` from Step 1.

## 3. Acknowledge
Output exactly: "Sync complete. All local changes pushed to permanent storage."
