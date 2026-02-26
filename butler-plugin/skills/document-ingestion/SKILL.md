---
name: document-ingestion
description: Use when summarizing long documents, articles, or transcripts to save into permanent memory.
---
# Ingestion SOP
1. Read the provided text using the `Read` tool if it is a file.
2. Extract: 
   - 3-bullet Executive Summary.
   - Action Items.
   - Key Entities (People, Projects, Financial numbers).
3. Ask the Master: "Shall I save this summary to the `MEMORYLOG` in Notion?"
4. If yes, use the `notion-update-page` tool using the UUID in `core-modules-references.json`.