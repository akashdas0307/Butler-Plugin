---
description: Synchronizes local files (TASK.md, CLAUDE.md) back to their permanent Notion pages mid-day.
---

# Update Command

Execute the synchronization protocol immediately.

## 1. Load References

!`BUTLER=$(find /sessions -maxdepth 10 -name "butler" -type d -not -path "*/.local-plugins/*" -not -path "*/.skills/*" 2>/dev/null | head -1) && PROJ="$(dirname "$BUTLER")" && echo "PLUGIN=$BUTLER" && echo "PROJECT=$PROJ"`

Read `butler/core-modules-references.json` to obtain the Notion `page_id`s for CLAUDE, USER, SOUL, SCRATCHPAD, TASK, and MEMORYLOG.

## 2. Sync to Notion

Core module files live at the **workspace root** (not inside `butler/`): `$PROJ/CLAUDE.md`, `$PROJ/TASK.md`, etc.

For each core file that exists at the workspace root:
1. Read its contents.
2. Wait 0.5 seconds between calls (rate limiting — prevents API 529 errors).
3. Use the `notion` MCP (`notion-update-page`) to overwrite the corresponding Notion page.

## 3. Acknowledge

Output exactly: "Sync complete. All local changes pushed to permanent storage."
