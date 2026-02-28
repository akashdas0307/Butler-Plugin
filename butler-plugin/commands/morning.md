---
description: Start the day — cold boot, context load, dashboard, triage.
---

# Morning Command

Execute steps sequentially.

---

## 0. Resolve Workspace Paths
**Architecture:** `butler/` is plugin infra. Core modules (CLAUDE.md etc.) live at the PARENT (workspace root).

!`BUTLER=$(find /sessions -path "*/.local-plugins/cache/butler-plugin/butler-plugin/*/scripts/cold-boot.sh" -type f 2>/dev/null | sort -V | tail -1 | xargs dirname | xargs dirname) && PROJ="$(find /sessions/*/mnt -maxdepth 1 -type d ! -name "mnt" ! -name ".*" 2>/dev/null | head -1)" && echo "CLAUDE_PLUGIN_ROOT=$BUTLER" && echo "CLAUDE_PROJECT_DIR=$PROJ" && echo "OK"`

If `BUTLER` is empty → halt. Tell Master: "Cannot locate butler folder. Ensure workspace folder is mounted."

---
## 0.5 — Local Directory & File Initialization

**Step A — Resolve paths (run first, used by all steps below):**

!`BUTLER=$(find /sessions -path "*/.local-plugins/cache/butler-plugin/butler-plugin/*/scripts/cold-boot.sh" -type f 2>/dev/null | sort -V | tail -1 | xargs dirname | xargs dirname) && PROJ="$(find /sessions/*/mnt -maxdepth 1 -type d ! -name "mnt" ! -name ".*" 2>/dev/null | head -1)" && echo "PLUGIN=$BUTLER" && echo "PROJECT=$PROJ"`

If `BUTLER` is empty → halt. The workspace is not mounted or butler folder is missing.


## 1. Cold Boot (Context Assembly)

!`BUTLER=$(find /sessions -path "*/.local-plugins/cache/butler-plugin/butler-plugin/*/scripts/cold-boot.sh" -type f 2>/dev/null | sort -V | tail -1 | xargs dirname | xargs dirname) && PROJ="$(find /sessions/*/mnt -maxdepth 1 -type d ! -name "mnt" ! -name ".*" 2>/dev/null | head -1)" && bash "$BUTLER/scripts/cold-boot.sh"`

Parse the output signal:

- If `COLD_BOOT_STATUS=LOCAL_COMPLETE` → read `CONTEXT_DUMP.md` (at workspace root) into context. Proceed to Step 2.

- If `COLD_BOOT_STATUS=NOTION_FETCH_REQUIRED`:
  - Read `core-modules-references.json`
  - For each file in `MISSING_FILES`: fetch from Notion via `notion-retrieve-page` using its `page_id`
  - Save each fetched file to the project dir
  - Re-run cold-boot.sh
  - Read assembled `CONTEXT_DUMP.md` into context

- If `COLD_BOOT_STATUS=REFS_MISSING` → halt. Tell Master: "core-modules-references.json missing. Run /onboarding first."

---

## 2. Email & Calendar Triage

Spawn subagent [model: haiku] → Task: "Search Gmail with `is:unread newer_than:1d`, max 20 results. Categorize each as [Important], [Financial], [General], or [Other] based on USER.md triage rules. Output structured list only. Write to `$PROJ/butler/NOTIFICATIONS.md`."

Spawn subagent [model: haiku] → Task: "List all Google Calendar events for today. Output: time, title, location. Write to `$PROJ/butler/SCHEDULE.md`."

---

## 3. Dashboard Prep

!`BUTLER=$(find /sessions -path "*/.local-plugins/cache/butler-plugin/butler-plugin/*/scripts/cold-boot.sh" -type f 2>/dev/null | sort -V | tail -1 | xargs dirname | xargs dirname) && PROJ="$(find /sessions/*/mnt -maxdepth 1 -type d ! -name "mnt" ! -name ".*" 2>/dev/null | head -1)" && DASH="$PROJ/butler-dashboard.html" && PLUGIN_CACHE=$(find /sessions -path "*/.local-plugins/cache/butler-plugin/butler-plugin/*/dashboard/butler-dashboard.html" 2>/dev/null | sort -V | tail -1) && if [ ! -f "$DASH" ]; then if [ -n "$PLUGIN_CACHE" ]; then cp "$PLUGIN_CACHE" "$DASH" && echo "dashboard: copied from plugin cache"; else echo "WARN: dashboard source not found"; fi; else echo "dashboard: already exists"; fi`

Update `TASK.md`: separate **Master Tasks** (tasks Master will do) from **Butler Tasks** (tasks Butler will execute).

Tell Master:
- "Dashboard ready. Open `butler-dashboard.html` from your workspace folder."
- "It reads NOTIFICATIONS.md, SCHEDULE.md, and TASK.md automatically."

---

## 4. Schedule Confirmation

Present Master with:
1. Email digest from NOTIFICATIONS.md
2. Calendar events from SCHEDULE.md
3. Today's task split: Master Tasks / Butler Tasks

Ask Master to confirm, adjust time slots, or reprioritize. After confirmation:
- Update Google Calendar with today's confirmed schedule and any upcoming deadlines
- Update TASK.md with final priorities
- Update `CONTEXT_DUMP.md` with confirmed day plan

---

## 5. Execute Butler Tasks

For Butler Tasks confirmed by Master → run `/execute`