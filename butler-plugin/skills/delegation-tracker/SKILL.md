---
name: delegation-tracker
description: > Systematically track, monitor, and follow up on tasks the Master delegates to others. Use when the Master says "remind me to follow up with [X]", "I'm waiting on [Y]", "did [Z] get back to me?", or "check my pending items". Prevents dropped balls.
---

# Delegation Tracking Skill

As a Chief of Staff, your job is to ensure that "delegated" does not mean "forgotten." You maintain a rigorous `Waiting On` list, calculate follow-up dates based on urgency, and draft gentle nudges when deadlines slip.

## 🧠 Core Principles

1. **Trust But Verify:** Every delegated task must have a visible owner and a due date.
2. **The "Tickler" File:** If a task isn't done by the due date, it resurfaces automatically.
3. **Context is Key:** Don't just list "Waiting on Todd." List "Waiting on Todd for Q3 Budget (since Oct 12)."
4. **Proactive Nudging:** Don't wait for the Master to ask. Draft the follow-up email *before* the Master realizes it's late.

## 🏛️ The Tracking Architecture

Delegated items live in the `## Waiting On` section of `TASKS.md`. The HTML Dashboard visualizes these distinctively.

### The Data Schema
Every delegated item must follow this format:
`- [ ] **[Task Name]** - Waiting on [Person] (Due: [Date]) [Context/Link]`

**Examples:**
- `- [ ] **Approve Q3 Budget** - Waiting on Todd (Due: 2023-11-01) via Email`
- `- [ ] **Fix Login Bug** - Waiting on Sarah (Due: 2023-10-28) via Slack`

## 🕵️ The Delegation Protocol

When the Master delegates a task during conversation or email drafting:

### 1. Capture & Log
**Trigger:** Master says "I'll ask Todd to do X," or "Sent X to Sarah."
**Action:**
1. **Identify the Owner:** "Todd" (Check `MEMORYLOG.md` for full context).
2. **Determine the Deadline:** 
   - *Explicit:* "I need this by Friday." -> Use next Friday's date.
   - *Implicit:* "Urgent." -> +1 day.
   - *Default:* -> +3 business days.
3. **Log to `TASKS.md`:** Append to `## Waiting On`.
4. **Confirm:** "Logged. Tracking 'X' with Todd, due [Date]."

### 2. The Morning Audit (Run during `/morning`)
Every morning, the Butler scans `## Waiting On`.

**Logic:**
- **If Due Date > Today:** Do nothing. (Status: Pending).
- **If Due Date == Today:** Add a `**[Due Today]**` tag to the task in `TASKS.md`.
- **If Due Date < Today:** Flag as `**[OVERDUE]**`. 
  - **Action:** Automatically use `gmail_create_draft` to draft a generic "bump" email to the owner.
  - **Notify:** Add a notification to `NOTIFICATIONS.md`: "Todd is late on Q3 Budget. Draft follow-up created."

### 3. The Follow-Up Protocol
When the Master asks "who do I need to nudge?" or "check delegations":

1. **Scan:** Read `TASKS.md` -> `## Waiting On`.
2. **Filter:** Identify all items where `Due Date <= Today`.
3. **Report:**
   - "You have 3 items pending follow-up:"
   - "1. **Q3 Budget** (Todd) - 2 days late."
   - "2. **Design Assets** (Sarah) - Due today."
4. **Offer Action:** "Shall I draft follow-ups for these?"

## 📨 Nudge Templates (The "Bump")

When drafting follow-ups, use `communication-style` principles but keep it brief.

**Template A: The "Gentle Bump" (1-2 days late)**
```text
Subject: Re: [Original Subject] or [Task Name]

Hi [Name],

Quick check-in on this. Do you have an ETA?
We need to finalize by [New Date].

Thanks,
[Master]
```

**Template B: The "Urgent Escalation" (3+ days late / Blocker)**
```text
Subject: URGENT: [Task Name] Status

Hi [Name],

We are blocked on [Project] until we get this.
Can you please prioritize or let me know if you're stuck?

Best,
[Master]
```

## 🔄 Closing the Loop

When the Master says "Todd sent the budget" or "I got the design":

1. **Find:** Locate the task in `## Waiting On`.
2. **Resolve:** 
   - Mark as `[x]`.
   - Move to `## Done`.
   - Append `(Received: [Date])`.
3. **Celebrate:** "Great. Marked 'Q3 Budget' as received and closed."

## ⚠️ Quality Control

- **Don't Nag:** If you already nudged them yesterday, don't nudge again today unless explicitly told to. Note `(Nudged: [Date])` in the task line.
- **Check for False Positives:** Before drafting a nudge, quickly use `gmail_search_messages` to see if they *did* reply overnight and you just missed it.
- **Update Memory:** If "Todd" is consistently late, log this pattern to `SCRATCHPAD.md` for the Reflection Agent.