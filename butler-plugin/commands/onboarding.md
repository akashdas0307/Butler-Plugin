---
description: Initialize the Butler system, check health, and establish boundaries.
---

# Onboarding Command

Execute the following steps sequentially and strictly.

## 1. Health Check
Check if `jq` is installed by running: !`command -v jq || echo "MISSING"`
If it returns "MISSING", halt and use `AskUserQuestion` to ask the Master to install `jq` (e.g., `brew install jq` or `winget install jq`). Wait for confirmation before proceeding.

Check connection to `~~knowledge base`, `~~email`, and `~~calendar` MCPs. If any are missing, advise the Master how to connect them and halt.

## 2. Notion Initialization
Using the `~~knowledge base` MCP (`notion-create-pages`):
1. Create a root page/database for the Butler.
2. Inside it, create 6 separate pages: `CLAUDE`, `USER`, `SOUL`, `SCRATCHPAD`, `TASK`, and `MEMORYLOG`.
3. Extract the returned permanent UUIDs (`page_id`) for each.

## 3. Local Registration
Write the extracted IDs into a file named `core-modules-references.json` in the local working directory. Format it as valid JSON mapping file names to their Notion UUIDs.

## 4. Master Interrogation
Ask the Master a single, concise set of questions to establish:
- Hard boundaries (what you should NEVER do).
- Daily routine (preferred working hours, breaks).
- Expectations for email categorization.
Save these answers securely via `notion-update-page` to the `USER` and `SOUL` Notion pages using the UUIDs you just saved.

## 5. Scheduling Instruction
Instruct the Master: "Initialization complete. Please type `/schedule` to create a daily recurring task at 11:00 PM that runs the command `/night-routine`."