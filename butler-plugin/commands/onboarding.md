---
description: Initialize the Butler system, check health, and establish boundaries.
---

# Onboarding Command

Execute the following steps sequentially and strictly.

## 1. Health Check
Check if `jq` is installed by running: !`command -v jq || echo "MISSING"`
If it returns "MISSING", halt and use `AskUserQuestion` to ask the Master to install `jq` (e.g., `brew install jq` or `winget install jq`). Wait for confirmation before proceeding.

Check connection to the `notion`, `gmail`, and `google-calendar` MCP servers. If any are missing, advise the Master how to connect them and halt.

## 2. Notion Initialization
Using the `notion` MCP (`notion-create-page`):
1. Create a root page/database for the Butler.
2. Inside it, create 6 separate pages: `CLAUDE`, `USER`, `SOUL`, `SCRATCHPAD`, `TASK`, and `MEMORYLOG`.

## 2.3 — UUID Capture (After Each Notion Page Created)
For each core file created in Notion:
- Extract the `page_id` from the Notion API response
- Append to core-modules-references.json:
  { "filename": { "notion_page_id": "<extracted_id>", "created": "<today>", "label": "<label>" } }
- Do NOT proceed to next page creation until this write is confirmed.

## 2.5 — Local Directory & File Initialization

Run sequentially. Do not proceed if any command fails.

!`mkdir -p ${CLAUDE_PROJECT_DIR}/{work,archive,memory}`
!`touch ${CLAUDE_PROJECT_DIR}/CONVERSATION.md`
!`cp ${CLAUDE_PLUGIN_ROOT}/dashboard/butler-dashboard.html ${CLAUDE_PROJECT_DIR}/`
!`cp ${CLAUDE_PLUGIN_ROOT}/core-modules-references.json ${CLAUDE_PROJECT_DIR}/ 2>/dev/null || echo "{}" > ${CLAUDE_PROJECT_DIR}/core-modules-references.json`

Confirm all directories exist:
!`ls -la ${CLAUDE_PROJECT_DIR}/`

If any of the above fail, surface the specific error to Master and halt. Do not proceed to Step 3 with a broken directory state.

## 3. Local Registration
(Handled in 2.3) Ensure `core-modules-references.json` in the local working directory is valid JSON mapping file names to their Notion UUIDs and metadata.

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
- Populate SOUL.template.md with answers from Q10, Q11, Q12
- Populate USER.template.md with answers from Q1–Q9, Q13–Q15
- Write both to Notion (capture UUIDs → write to core-modules-references.json)
- Write local copies to ${CLAUDE_PROJECT_DIR}/

## 5. Scheduling Instruction
Instruct the Master: "Initialization complete. Please type `/schedule` to create a daily recurring task at 11:00 PM that runs the command `/night-routine`."
