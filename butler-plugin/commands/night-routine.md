---
description: The 11 PM Scheduled Task. Triggers reflection, Notion sync, and daily cleanup.
---

# Night Routine Command

Execute the Good Night protocol strictly and sequentially.

## 1. Trigger Reflection
Invoke the `reflection-agent` subagent: "Analyze today's `CONVERSATION.md` and update the `SCRATCHPAD.md` with behavioral hypotheses."
Wait for the subagent to complete and return its findings.

## 2. Push to Permanent Memory
Read the `core-modules-references.json`.
Push the contents of all local core files to their respective Notion `page_id`s via the `notion-update-page` tool. 

## 3. Archive & Cleanup
1. Move today's `CONVERSATION.md` to an `archive/` folder, renaming it to `CONVERSATION_YYYY_MM_DD.md`.
2. Clear the local `CONVERSATION.md` so it is blank for tomorrow.
3. If the reflection agent proposed structural improvements to the plugin itself, append them to a local `Signoff.md` file for the Master to review at the end of the week.

## 4. Signoff
Output exactly: "Good night, Master. Patterns logged, Notion synced, and systems cleared for tomorrow."
Terminate session.