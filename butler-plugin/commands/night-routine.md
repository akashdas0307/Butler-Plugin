---
description: The 11 PM Scheduled Task. Triggers reflection, Notion sync, and daily cleanup.
---

# Night Routine Command

Execute the Good Night protocol strictly and sequentially.

## 0. Resolve Paths

!`BUTLER=$(find /sessions -path "*/.local-plugins/cache/butler-plugin/butler-plugin/*/scripts/cold-boot.sh" -type f 2>/dev/null | sort -V | tail -1 | xargs dirname | xargs dirname) && PROJ="$(find /sessions/*/mnt -maxdepth 1 -type d ! -name "mnt" ! -name ".*" 2>/dev/null | head -1)" && echo "PLUGIN=$BUTLER" && echo "PROJECT=$PROJ"`

- `BUTLER` = plugin directory (plugin infra, scripts, templates)
- `PROJ` = workspace root (CLAUDE.md, USER.md, TASK.md, SOUL.md, SCRATCHPAD.md, MEMORYLOG.md)
- Session folder: `$PROJ/butler/` (CONVERSATION.md, NOTIFICATIONS.md, SCHEDULE.md)

## 1. Trigger Reflection

Invoke the `reflection-agent` subagent: "Analyze today's `butler/CONVERSATION.md` and update the `SCRATCHPAD.md` (at workspace root) with behavioral hypotheses."
Wait for the subagent to complete and return its findings.

## 2. Push to Permanent Memory

Read `butler/core-modules-references.json`.
Push the contents of all core files at the **workspace root** to their respective Notion `page_id`s via `notion-update-page`.

**Rate-limit rule:** Wait 0.5 seconds between each Notion call to prevent API 529 (Overloaded) errors.

Core files to sync (all at workspace root, NOT inside butler/):
- `CLAUDE.md`, `USER.md`, `SOUL.md`, `SCRATCHPAD.md`, `MEMORYLOG.md`, `TASK.md`

## 3. Archive & Cleanup

1. Copy `butler/CONVERSATION.md` to `archive/YYYY-MM-DD/CONVERSATION_YYYY-MM-DD.md` (archive at workspace root).
2. Clear `butler/CONVERSATION.md` (truncate to blank for tomorrow).
3. Clear `butler/NOTIFICATIONS.md` and `butler/SCHEDULE.md`.
4. If the reflection agent proposed structural improvements to the plugin itself, append them to `SIGNOFF.md` at workspace root for the Master to review.

## 4. Signoff

Output exactly: "Good night, Master. Patterns logged, Notion synced, and systems cleared for tomorrow."
Terminate session.
