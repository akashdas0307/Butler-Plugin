---
description: Start the day — cold boot, context load, dashboard, triage.
---

# Morning Command

Execute steps sequentially.

---

## 0. Resolve Workspace Paths

!`BUTLER=$(find /sessions -maxdepth 5 -name "butler-plugin" -type d -not -path "*/.*" 2>/dev/null | head -1) && echo "PLUGIN=$BUTLER" && echo "PROJECT=$(dirname "$BUTLER")" && echo "OK"`

If `BUTLER` is empty → halt. Tell Master: "Cannot locate butler-plugin. Ensure workspace folder is mounted."

---

## 1. Cold Boot (Context Assembly)

!`BUTLER=$(find /sessions -maxdepth 5 -name "butler-plugin" -type d -not -path "*/.*" 2>/dev/null | head -1) && bash "$BUTLER/hooks/scripts/cold-boot.sh"`

Parse the output signal:

- If `COLD_BOOT_STATUS=LOCAL_COMPLETE` → read `CONTEXT_DUMP.md` into context. Proceed to Step 2.

- If `COLD_BOOT_STATUS=NOTION_FETCH_REQUIRED`:
  - Read `core-modules-references.json`
  - For each file in `MISSING_FILES`: fetch from Notion via `notion-retrieve-page` using its `page_id`
  - Save each fetched file to the project dir
  - Re-run cold-boot.sh
  - Read assembled `CONTEXT_DUMP.md` into context

- If `COLD_BOOT_STATUS=REFS_MISSING` → halt. Tell Master: "core-modules-references.json missing. Run /onboarding first."

---

## 2. Email & Calendar Triage

Spawn subagent [model: haiku] → Task: "Search Gmail with `is:unread newer_than:1d`, max 20 results. Categorize each as [Important], [Financial], [General], or [Other] based on USER.md triage rules. Output structured list only. Write to NOTIFICATIONS.md in the project dir."

Spawn subagent [model: haiku] → Task: "List all Google Calendar events for today. Output: time, title, location. Write to SCHEDULE.md in the project dir."

---

## 3. Dashboard Prep

!`BUTLER=$(find /sessions -maxdepth 5 -name "butler-plugin" -type d -not -path "*/.*" 2>/dev/null | head -1) && PROJ="$(dirname "$BUTLER")" && DASH="$PROJ/butler-dashboard.html" && if [ ! -f "$DASH" ]; then cp "$BUTLER/dashboard/butler-dashboard.html" "$DASH" && echo "dashboard: copied" || echo "WARN: dashboard source not found"; else echo "dashboard: already exists"; fi`

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