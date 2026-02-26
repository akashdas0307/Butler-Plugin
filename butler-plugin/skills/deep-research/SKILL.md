---
name: deep-research
description: > Standard Operating Procedure for conducting comprehensive, multi-step research. Use when the Master asks "find out about [X]", "research [Y]", "look into [Z]", "who is [Person]", or "compare A vs B". Delegates execution to the `research-agent` subagent to preserve context window. | context: fork | agent: research-agent
---

# Deep Research Skill

As a Chief of Staff, you do not just "search"—you investigate. This skill defines the protocol for delegating complex research tasks to a specialized subagent, ensuring the output is strategic, cited, and decision-ready.

## 🧠 Core Principles

1.  **Triangulation:** Never accept a single source. The subagent must verify facts across multiple data points.
2.  **Citations are Mandatory:** Every claim must be traceable.
3.  **BLUF (Bottom Line Up Front):** The Master needs the answer first, evidence second.
4.  **Token Hygiene:** Heavy reading and synthesis happen in the subagent's forked context. Only the finalized brief returns to the main thread.

## 🏛️ The Delegation Protocol

When the Master initiates a research request:

### 1. The Triage Phase (Main Context)
Before spawning the subagent, clarify the intent to avoid wasted cycles.
-   **Ambiguity Check:** If the request is "Research AI," ask: *"Are we looking for market trends, technical implementation, or competitive landscape?"*
-   **Constraint Setting:** explicitly tell the subagent the output format (e.g., "Compare pricing models", "Find technical limitations").

### 2. The Execution Phase (Subagent Fork)
Pass a structured prompt to the `research-agent`:

> "You are the Research Specialist. The Master needs a deep dive on [Topic].
> **Focus:** [Specific Aspect, e.g., Pricing, Technical Feasibility]
> **Constraints:**
> 1.  Verify all claims with at least two sources.
> 2.  Cite every fact with a URL or document name.
> 3.  Produce an Executive Brief using the standard template.
> 4.  Do not output raw search results. Synthesize."

### 3. The Synthesis Phase (Return to Main)
The subagent will return a **Research Brief**. Your job is to:
1.  **Review:** Does it answer the Master's core question?
2.  **Format:** Ensure it renders cleanly as Markdown.
3.  **Action:** Present the brief and ask: *"Shall I save this to `MEMORYLOG.md` (Project Context) or `SCRATCHPAD.md` (Temporary)?"*

## 📝 Executive Brief Template (Enforced Output)

The subagent must return data in this exact structure:

```markdown
# 🕵️ Research Brief: [Topic]

## 🚨 Executive Summary (BLUF)
[2-3 sentences answering the core question directly. If "It depends," explain the primary factor.]

## 🔑 Key Findings
1.  **[Insight 1]** - [Detail] ([Source](url))
2.  **[Insight 2]** - [Detail] ([Source](url))
3.  **[Insight 3]** - [Detail] ([Source](url))

## 📊 Comparison / Data
| Feature/Entity | Option A | Option B |
|----------------|----------|----------|
| Price          | $X       | $Y       |
| Key Strength   | Speed    | Stability|

## ⚠️ Risks / Red Flags
-   [e.g., Competitor A has recent security breach news] ([Source](url))
-   [e.g., Technology B is deprecated]

## 🔗 Source List
-   [Title - URL]
-   [Title - URL]
```

## 🎭 Scenario-Specific Methodologies

**1. Competitive Intelligence ("Compare X vs Y")**
-   **Focus:** Differentiators, Pricing, Customer Sentiment (G2/Reddit), not marketing copy.

**2. Entity Vetting ("Who is this person/company?")**
-   **Focus:** Credibility, Past Exits/Roles, Controversies, Lawsuits.

**3. Technical Feasibility ("Can we do X?")**
-   **Focus:** Documentation, API Limits, Libraries, Deprecation Notices.

## ⚠️ Quality Control

-   **Staleness Check:** If a source is >1 year old, flag it as "(202X Data)".
-   **Hallucination Check:** If the subagent cannot find a specific fact (e.g., pricing), it must state "Undisclosed," not guess.
-   **Recursion:** If the research reveals a new, more important question, flag it in the Executive Summary.