---
name: document-ingestion
description: > Standard Operating Procedure for processing and saving large documents, PDFs, or long text blocks. Use when the Master says "read this", "summarize this PDF", "ingest this report", "add this to memory", or "what does this document say". Delegates processing to the `ingestion-agent` to preserve context window. | context: fork | agent: ingestion-agent
---

# Document Ingestion Skill

As a Chief of Staff, you must process information faster than the Master. You ingest unstructured data (PDFs, logs, threads), strip away the noise, and file the signal into the permanent Knowledge Base (`MEMORYLOG.md` or `projects/`).

## 🧠 Core Principles

1.  **Signal > Noise:** The Master doesn't need a rewording of the document; they need the *implications* of the document.
2.  **Structured Storage:** Never dump raw text into memory. Always format it (tables, bullets).
3.  **Entity Linkage:** If the document mentions "Todd," link it to the existing "Todd" entry in memory.
4.  **Actionability:** Always extract the "So What?" (Action Items).

## 🏛️ The Ingestion Protocol

When the Master provides a file or text block:

### 1. The Triage Phase (Main Context)
Identify the nature of the input to guide the subagent.
-   **Input Check:** Is it a file path? A URL? Copied text?
-   **Context Setting:** Tell the subagent *why* we are reading this.
    -   *Example:* "Analyze this contract for red flags."
    -   *Example:* "Summarize these meeting notes for action items."

### 2. The Processing Phase (Subagent Fork)
Pass the document to the `ingestion-agent` with a specific directive:

> "Analyze the attached [File/Text].
> **Focus:** [Specific Focus, e.g., Financials, Timeline, Legal Risks]
> **Output:** Use the Standard Ingestion Template.
> **Extraction:** List all dates and dollar amounts explicitly."

### 3. The Integration Phase (Return to Main)
The subagent will return a structured **Ingestion Entry**. Your job is to integrate it into the Master's permanent memory.

1.  **Present:** Show the Executive Summary and Action Items to the Master.
2.  **Ask for Disposition:**
    -   *"Shall I file this under `MEMORYLOG.md` (General Knowledge)?"*
    -   *"Should I add the Action Items to your `TASK.md`?"*
3.  **Execute:**
    -   If **Memory**: Use `notion-update-page` (via `memory-management`) to append the entry.
    -   If **Tasks**: Use the `task-management` skill to append the Action Items to `## Master Tasks` or `## Butler Tasks`.

## 🎭 Scenario-Specific Templates

The subagent will use the general template, but you should prompt it for specifics based on file type:

**1. Legal Contracts / SOWs**
-   **Focus:** Deliverables, Deadlines, Payment Terms, Termination Clauses.
-   **Prompt:** "Highlight any clause that imposes a penalty on us."

**2. Technical Specifications / RFCs**
-   **Focus:** Breaking Changes, API limits, Security requirements.
-   **Prompt:** "List all breaking changes and deprecated features."

**3. Meeting Transcripts**
-   **Focus:** Decisions made, Disagreements, Action Items.
-   **Prompt:** "Ignore the chit-chat. Who promised what?"

## ⚠️ Quality Control

-   **File Size Check:** If the file is huge, ask the subagent to read the first and last 20% first, or use `Grep` to find keywords.
-   **Verification:** If the subagent extracts a dollar amount, verify it matches the context (e.g., is it $10k per month or per year?).
-   **Redaction:** If saving to `MEMORYLOG.md`, redact PII (Personal Identifiable Information) unless strictly necessary.