# Gmail Connector - Quick Reference Cheat Sheet

## ⚡ TLDR: Gmail Capabilities

```
6 OPERATIONS AVAILABLE:
├─ gmail_search_messages → Find & filter emails
├─ gmail_read_message → Get full email content
├─ gmail_read_thread → Get entire conversation
├─ gmail_get_profile → Account info
├─ gmail_list_drafts → List unsent drafts
└─ gmail_create_draft → Create unsent email

FETCH LIMITS:
├─ Per call: 1-500 messages (default 20)
├─ Pagination: YES (nextPageToken)
├─ Total: Unlimited (via pagination)
└─ Rate limit: 10,000 operations/day
```

---

## 📋 Operations Summary

### Search Messages
```
gmail_search_messages({
  q: "search query",        // Required: Gmail search syntax
  maxResults: 50,           // Optional: 1-500 (default 20)
  pageToken: "..."          // Optional: For pagination
})

Returns:
├─ messages[] array
├─ Snippet (first 100 chars)
├─ Message ID & Thread ID
└─ nextPageToken (if more results)
```

### Read Single Message
```
gmail_read_message({
  messageId: "msg-id"
})

Returns:
├─ Full body content
├─ All headers (From, To, Subject, etc.)
├─ Attachment metadata
└─ Thread ID (for context)
```

### Read Entire Conversation
```
gmail_read_thread({
  threadId: "thread-id"
})

Returns:
├─ All messages in order
├─ Complete details for each
├─ Full conversation context
└─ One threadId for all messages
```

### Get Account Info
```
gmail_get_profile()

Returns:
├─ Email address
├─ Total message count
├─ Total thread count
└─ History ID
```

### List Drafts
```
gmail_list_drafts({
  maxResults: 20,           // 1-500
  pageToken: "..."          // For pagination
})

Returns:
├─ All unsent drafts
├─ Preview of each
└─ draftId for reference
```

### Create Draft
```
gmail_create_draft({
  to: "recipient@example.com",     // Required
  subject: "Subject",              // Required
  body: "Email content",           // Required
  cc: "optional@example.com",      // Optional
  bcc: "optional@example.com",     // Optional
  contentType: "text/plain"        // or "text/html"
})

Returns:
├─ draftId
├─ messageId
└─ Status: UNSENT
```

---

## 🔍 SEARCH QUERY EXAMPLES

### Unread Emails
```
is:unread
```

### Last 24 Hours
```
newer_than:1d
```

### Unread Last 24 Hours (MOST COMMON)
```
is:unread newer_than:1d
```

### From Specific Person
```
from:boss@company.com
```

### From Person Last 7 Days
```
from:boss@company.com newer_than:7d
```

### With Attachments
```
has:attachment
```

### Unread with Attachments Last 3 Days
```
is:unread has:attachment newer_than:3d
```

### Invoices
```
subject:invoice
```

### Unread Invoices Last 30 Days
```
is:unread subject:invoice newer_than:30d
```

### PDF Attachments
```
filename:pdf
```

### Starred Messages
```
is:starred
```

### Multiple Senders (OR)
```
from:alice@x.com OR from:bob@x.com
```

### Exclude Spam
```
is:unread -is:spam
```

### Specific Label
```
label:work
```

### Custom Label
```
label:urgent_projects
```

### Exact Phrase Match
```
"budget approval"
```

### Date Range
```
after:2024/2/1 before:2024/2/28
```

### Larger than 1MB
```
size>1000000
```

### Combination Example
```
is:unread from:boss@company.com newer_than:1d -is:spam
```

---

## ✅ SEARCH FILTER MATRIX

| Filter | Syntax | Example |
|--------|--------|---------|
| **Unread** | `is:unread` | `is:unread` |
| **Starred** | `is:starred` | `is:starred` |
| **Spam** | `is:spam` | `is:spam` |
| **Trash** | `is:trash` | `is:trash` |
| **From** | `from:` | `from:alice@x.com` |
| **To** | `to:` | `to:you@x.com` |
| **Subject** | `subject:` | `subject:meeting` |
| **Label** | `label:` | `label:work` |
| **Has Attachment** | `has:attachment` | `has:attachment` |
| **File Type** | `filename:` | `filename:pdf` |
| **Size** | `size:` or `size>` | `size>1M` |
| **Exact Phrase** | `"phrase"` | `"exact match"` |
| **Last 24h** | `newer_than:1d` | `newer_than:1d` |
| **Last N Days** | `newer_than:Nd` | `newer_than:7d` |
| **Older than N Days** | `older_than:Nd` | `older_than:30d` |
| **After Date** | `after:YYYY/M/D` | `after:2024/2/20` |
| **Before Date** | `before:YYYY/M/D` | `before:2024/2/28` |
| **OR Logic** | ` OR ` | `from:a@x OR from:b@x` |
| **NOT/Exclude** | `-` | `-from:spam@x` |

---

## 📊 FETCH LIMITS BREAKDOWN

| Scenario | Limit | Pagination |
|----------|-------|-----------|
| **Single Search** | 500 max per call | YES (nextPageToken) |
| **Default Search** | 20 per call | YES |
| **Single Message** | 1 message | N/A |
| **Full Thread** | All messages | N/A |
| **Drafts List** | Configurable | YES |
| **Daily Quota** | 10,000 ops/day | Per account |
| **Per Minute** | ~100 reasonable | Soft limit |

---

## 🔄 PAGINATION PATTERN

```javascript
// First request
let results = [];
let pageToken = null;

do {
  const response = gmail_search_messages({
    q: "is:unread newer_than:1d",
    maxResults: 100,
    pageToken: pageToken
  });
  
  results = [...results, ...response.messages];
  pageToken = response.nextPageToken;
  
} while (pageToken);

// Now results has ALL unread emails from last 24h
```

---

## 💡 COMMON USE CASES FOR CHIEF OF STAFF

### Daily Briefing
```
gmail_search_messages({
  q: "is:unread newer_than:1d",
  maxResults: 50
})

→ Get all unread from last 24 hours
→ Summarize key points
→ Extract action items
→ Sync to Notion tasks
```

### Email Triage
```
gmail_search_messages({
  q: "is:unread label:work newer_than:3d",
  maxResults: 100
})

→ Find all unread work emails (3 days)
→ Categorize by priority
→ Create follow-up tasks
```

### Invoice Processing
```
gmail_search_messages({
  q: "subject:invoice has:attachment newer_than:30d",
  maxResults: 50
})

→ Find all invoices with attachments
→ Extract due dates
→ Create payment reminders
```

### Boss Communication
```
gmail_search_messages({
  q: "from:boss@company.com newer_than:7d",
  maxResults: 50
})

→ Read all boss emails (past week)
→ Extract decisions/instructions
→ Prioritize action items
```

### Full Thread Analysis
```
const msg = gmail_read_message({ messageId: "..." });
const thread = gmail_read_thread({ threadId: msg.threadId });

→ Get complete conversation history
→ Understand full context
→ Draft informed response
```

### Draft Response
```
gmail_create_draft({
  to: "person@company.com",
  subject: "Re: Original Subject",
  body: "AI-composed response...",
  cc: "manager@company.com"
})

→ AI composes thoughtful response
→ User reviews before sending
→ Safe automation (no auto-send)
```

---

## 🚀 WORKFLOW EXAMPLES

### Example 1: Daily Unread Summary

```
Step 1: Search
  → gmail_search_messages({ q: "is:unread newer_than:1d", maxResults: 50 })
  → Get up to 50 unread from past 24 hours

Step 2: Read Full Content
  → For each message, gmail_read_message(messageId)
  → Get complete body, headers, attachments

Step 3: Summarize
  → Extract key points
  → Identify action items
  → Categorize by priority

Step 4: Store
  → Save summary in Obsidian
  → Create Notion tasks for follow-ups
  → Archive messageId for reference
```

### Example 2: Conversation Context

```
Step 1: Find Message
  → gmail_search_messages({ q: "from:boss@company.com newer_than:1d" })
  → Get recent from boss

Step 2: Get Context
  → gmail_read_thread(threadId from result)
  → Get entire conversation history

Step 3: Analyze
  → Understand full context
  → Identify decisions/changes
  → Extract requirements

Step 4: Respond
  → gmail_create_draft()
  → Compose informed response
  → Send for approval
```

### Example 3: Scheduled Daily Briefing

```
Trigger: Every morning at 8 AM

Step 1: Get Profile
  → gmail_get_profile()
  → Verify connection

Step 2: Search Recent
  → gmail_search_messages({ 
      q: "is:unread newer_than:1d -is:spam",
      maxResults: 100 
    })
  → Find important unread

Step 3: Process
  → Read critical messages
  → Extract action items
  → Identify deadlines

Step 4: Create Brief
  → Summarize in Obsidian
  → Create Notion tasks
  → Attach context links

Step 5: Optional Drafts
  → gmail_create_draft for key responses
  → Store draftId for followup
```

---

## ⚠️ KEY LIMITATIONS

### ❌ Can't Do

```
- Send emails directly (only drafts)
- Download attachment file data
- Edit existing drafts
- Delete messages
- Modify labels/categories
- Access other user's mailbox
- Create email filters/rules
```

### ✅ Can Do

```
- Search with complex filters
- Read full message content
- Read entire conversation history
- Create unsent drafts
- List all drafts
- Get account info
- Combine multiple filters
- Use pagination for large sets
```

---

## 🔑 ID TYPES IN GMAIL

```
messageId:
├─ Unique per message
├─ Permanent (never changes)
├─ Used to read that specific message
└─ Format: alphanumeric string

threadId:
├─ Shared by all messages in conversation
├─ Permanent (never changes)
├─ Used to read entire conversation
└─ All messages in thread have same ID

draftId:
├─ Unique per draft
├─ Permanent while draft exists
├─ Used to reference draft
└─ Changes to messageId if sent

What's Permanent:
├─ messageId: YES
├─ threadId: YES
├─ draftId: YES (until sent)
└─ After sending: messageId (not draftId)
```

---

## 📈 RATE LIMIT MANAGEMENT

```
Daily Quota: 10,000 operations
├─ Search: 1 operation
├─ Read Message: 1 operation
├─ Read Thread: 1 operation
├─ Create Draft: 1 operation
└─ Get Profile: 1 operation

Example Daily Budget:
├─ 500 searches (500 operations)
├─ 2000 message reads (2000 operations)
├─ 1000 thread reads (1000 operations)
├─ 500 draft creates (500 operations)
└─ Still 5500 left for others

Recommendation:
├─ Batch operations efficiently
├─ Use maxResults wisely
├─ Store results for reuse
└─ Check quota usage regularly
```

---

## 🎯 BEFORE YOU START

```
✅ Verify authentication
   └─ gmail_get_profile() should work

✅ Test simple search
   └─ gmail_search_messages({ q: "is:unread" })

✅ Read a message
   └─ gmail_read_message(messageId from search)

✅ Create a draft
   └─ gmail_create_draft() with test content

✅ Understand pagination
   └─ Use nextPageToken for large datasets

✅ Plan your workflow
   └─ Which searches will run daily?
   └─ Which threads need full read?
   └─ When to create drafts?

✅ Track quota
   └─ Monitor operations count
   └─ Plan around 10,000/day limit
```

---

## 🔗 GMAIL vs NOTION vs CALENDAR

| Feature | Gmail | Notion | Calendar |
|---------|-------|--------|----------|
| **Search** | Advanced | Semantic | Event-based |
| **Fetch** | Pagination | Single | Single |
| **Create** | Draft only | Pages/DBs | Events |
| **Update** | Draft only | Pages/Schema | Events |
| **Read** | Full msg | Full page | Events |
| **Pagination** | YES | NO | NO |
| **Max/call** | 500 | 1 (per fetch) | N/A |
| **Rate limit** | 10k/day | Per-call | Per-call |

---

## ✨ SUMMARY

```
GMAIL STRENGTHS:
✓ Powerful search/filter syntax
✓ Large pagination support (500/call)
✓ Complete message content access
✓ Full conversation context
✓ Safe draft creation (no auto-send)
✓ Unread filter (great for briefings)
✓ Date range filtering
✓ Attachment detection

GMAIL CONSTRAINTS:
✗ No direct email sending
✗ No attachment file downloads
✗ No label modification
✗ No message deletion via MCP
✗ 10,000 operations/day quota
✗ No existing draft editing

PERFECT FOR:
→ Daily email briefings
→ Action item extraction
→ Conversation analysis
→ Automated draft composition
→ Email triage workflows
```

---

## 🚀 GET STARTED

1. **Authenticate**: Automatic via Claude.ai OAuth
2. **Check Access**: `gmail_get_profile()`
3. **Search Unread**: `gmail_search_messages({ q: "is:unread" })`
4. **Read Message**: `gmail_read_message({ messageId: "..." })`
5. **Read Thread**: `gmail_read_thread({ threadId: "..." })`
6. **Create Draft**: `gmail_create_draft({ to, subject, body })`
7. **Use Pagination**: Leverage `nextPageToken` for large datasets
8. **Combine Filters**: `is:unread newer_than:1d from:boss@company.com`

You're ready! 🎉
