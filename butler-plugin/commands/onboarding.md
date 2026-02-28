---
description: Initialize the Butler system, check health, and establish boundaries.
---

# Onboarding Command

Execute the following steps sequentially and strictly.

---

## 0. Resolve Workspace Paths

Run once at the start. All subsequent steps depend on these variables.

!`BUTLER=$(find /sessions -path "*/.local-plugins/cache/butler-plugin/butler-plugin/*/scripts/cold-boot.sh" -type f 2>/dev/null | sort -V | tail -1 | xargs dirname | xargs dirname) && PROJ="$(find /sessions/*/mnt -maxdepth 1 -type d ! -name "mnt" ! -name ".*" 2>/dev/null | head -1)" && echo "CLAUDE_PLUGIN_ROOT=$BUTLER" && echo "CLAUDE_PROJECT_DIR=$PROJ" && echo "OK"`

If the above returns empty or errors → halt and surface to Master: "Cannot locate butler-plugin folder. Ensure the project folder is mounted correctly."

---

## 1. Health Check

!`BUTLER=$(find /sessions -path "*/.local-plugins/cache/butler-plugin/butler-plugin/*/scripts/cold-boot.sh" -type f 2>/dev/null | sort -V | tail -1 | xargs dirname | xargs dirname) && PROJ="$(find /sessions/*/mnt -maxdepth 1 -type d ! -name "mnt" ! -name ".*" 2>/dev/null | head -1)" && command -v jq > /dev/null && echo "jq: OK" || echo "jq: MISSING"`

If `jq: MISSING` → halt. Ask Master to install jq (`brew install jq` / `winget install jq`). Wait for confirmation.

Check connection to `notion`, `gmail`, and `google-calendar` MCP servers. If any are missing, advise Master how to connect them and halt.

---

## 2. Notion Initialization

Using the `notion` MCP (`notion-create-page`):
1. Create a root page/database for the Butler.
2. Inside it, create 6 separate pages: `CLAUDE`, `USER`, `SOUL`, `SCRATCHPAD`, `TASK`, and `MEMORYLOG`.

---

## 2.3 — UUID Capture (After Each Notion Page Created)

For each core file created in Notion:
- Extract the `page_id` from the Notion API response.
- Append to `core-modules-references.json`:
  ```json
  { "filename": { "notion_page_id": "<extracted_id>", "created": "<today>", "label": "<label>" } }
  ```
- Do NOT proceed to next page creation until this write is confirmed.

---

## 2.5 — Local Directory & File Initialization

**Step A — Resolve paths (run first, exports used by all steps below):**

!`BUTLER=$(find /sessions -path "*/.local-plugins/cache/butler-plugin/butler-plugin/*/scripts/cold-boot.sh" -type f 2>/dev/null | sort -V | tail -1 | xargs dirname | xargs dirname) && PROJ="$(find /sessions/*/mnt -maxdepth 1 -type d ! -name "mnt" ! -name ".*" 2>/dev/null | head -1)" && echo "PLUGIN=$BUTLER" && echo "PROJECT=$PROJ"`

If `BUTLER` is empty → halt. The workspace is not mounted or butler-plugin folder is missing.

**Step B — Create directories:**

!`BUTLER=$(find /sessions -path "*/.local-plugins/cache/butler-plugin/butler-plugin/*/scripts/cold-boot.sh" -type f 2>/dev/null | sort -V | tail -1 | xargs dirname | xargs dirname) && PROJ="$(find /sessions/*/mnt -maxdepth 1 -type d ! -name "mnt" ! -name ".*" 2>/dev/null | head -1)" && mkdir -p "$PROJ/work" "$PROJ/archive" "$PROJ/memory" "$PROJ/butler" && echo "Dirs created at: $PROJ"`

**Step C — Initialize core files:**

!`BUTLER=$(find /sessions -path "*/.local-plugins/cache/butler-plugin/butler-plugin/*/scripts/cold-boot.sh" -type f 2>/dev/null | sort -V | tail -1 | xargs dirname | xargs dirname) && PROJ="$(find /sessions/*/mnt -maxdepth 1 -type d ! -name "mnt" ! -name ".*" 2>/dev/null | head -1)" && mkdir -p "$PROJ/butler" && touch "$PROJ/butler/CONVERSATION.md" && echo "CONVERSATION.md: OK"`

!`BUTLER=$(find /sessions -path "*/.local-plugins/cache/butler-plugin/butler-plugin/*/scripts/cold-boot.sh" -type f 2>/dev/null | sort -V | tail -1 | xargs dirname | xargs dirname) && PROJ="$(find /sessions/*/mnt -maxdepth 1 -type d ! -name "mnt" ! -name ".*" 2>/dev/null | head -1)" && cp "$BUTLER/dashboard/butler-dashboard.html" "$PROJ/" 2>/dev/null && echo "dashboard: OK" || echo "WARN: dashboard not found, skipping"`

!`BUTLER=$(find /sessions -path "*/.local-plugins/cache/butler-plugin/butler-plugin/*/scripts/cold-boot.sh" -type f 2>/dev/null | sort -V | tail -1 | xargs dirname | xargs dirname) && PROJ="$(find /sessions/*/mnt -maxdepth 1 -type d ! -name "mnt" ! -name ".*" 2>/dev/null | head -1)" && cp "$BUTLER/core-modules-references.json" "$PROJ/" 2>/dev/null || echo '{}' > "$PROJ/core-modules-references.json" && echo "core-modules-references.json: OK"`

**Step D — Verify:**

!`BUTLER=$(find /sessions -path "*/.local-plugins/cache/butler-plugin/butler-plugin/*/scripts/cold-boot.sh" -type f 2>/dev/null | sort -V | tail -1 | xargs dirname | xargs dirname) && PROJ="$(find /sessions/*/mnt -maxdepth 1 -type d ! -name "mnt" ! -name ".*" 2>/dev/null | head -1)" && ls -la "$PROJ/"`

If any of the above fail → surface the specific error to Master and halt. Do not proceed to Step 3 with a broken directory state.

---

## 3. Local Registration

Ensure `core-modules-references.json` in the local working directory is valid JSON mapping file names to their Notion UUIDs and metadata. (Handled via Step 2.3.)

---

## 4. Master Interrogation

Ask these questions in ONE grouped message using AskUserQuestion:

**IDENTITY & ROLE**
1. What is your full name and professional title?
2. What is your primary role and top 3 responsibilities?
3. Who are your top 5 VIP contacts? (name, role, relationship)

**ROUTINE & SCHEDULE**
4. What time do you start and end work?
5. What are your preferred deep-work hours (no interruptions)?
6. Any recurring weekly commitments? (calls, standups, etc.)

**COMMUNICATION STYLE**
7. Describe your email tone: formal / casual / data-first?
8. Paste 1-2 sample emails you've written.
9. What sign-off do you use? (Best, Thanks, Regards, etc.)

**HARD BOUNDARIES (SOUL)**
10. What must I NEVER do autonomously?
11. What topics are strictly off-limits for me to handle?
12. Any privacy rules? (e.g., never log client names)

**EMAIL TRIAGE RULES**
13. Which senders are always [Important]? (names or domains)
14. Which topics are [Financial]? (invoices, budgets, etc.)
15. Any email threads or senders to permanently ignore?

After receiving answers:
- Populate `SOUL.md` with answers from Q10, Q11, Q12
- Populate `USER.md` with answers from Q1–Q9, Q13–Q15
- Write both to Notion (capture UUIDs → write to `core-modules-references.json`)
- Write local copies to resolved `$PROJ/`

---

## 5. Scheduling Instruction

Inform Master:
- Type `/morning` at the start of each day to begin your session.
- Type `/update` to sync memory and Notion mid-session or before closing.
- Onboarding is now complete.