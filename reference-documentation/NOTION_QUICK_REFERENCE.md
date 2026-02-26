# Notion Connector - Quick Reference Cheat Sheet

## ⚡ TLDR: ID Behavior

```
ALL NOTION IDs ARE PERMANENT & STATIC
├─ page_id: Never changes
├─ database_id: Never changes  
├─ data_source_id: Never changes
├─ user_id: Never changes
└─ discussion_id: Never changes

Even after: updates, moves, renames, content changes → IDs STAY THE SAME
```

---

## 📋 Operations at a Glance

### CREATE Operations → Always Return IDs

```
✅ notion-create-pages
   Input: Parent ID (optional)
   Output: page_id for each page
   
✅ notion-create-database  
   Input: Schema definition
   Output: database_id + data_source_id
   
✅ notion-create-comment
   Input: page_id (required)
   Output: discussion_id
```

### READ Operations → Return IDs for Found Items

```
✅ notion-fetch
   Input: page_id, database_id, or URL
   Output: Full details + all child IDs
   
✅ notion-search
   Input: Query text (no ID needed)
   Output: All matching page/database IDs
   
✅ notion-get-users / notion-get-teams
   Input: (Optional query)
   Output: All user_ids / team_ids
   
✅ notion-get-comments
   Input: page_id (required)
   Output: discussion_id + content for all threads
```

### UPDATE Operations → IDs Unchanged

```
✅ notion-update-page
   Input: page_id (required)
   Output: Same page_id (unchanged)
   What changes: Content, properties, title
   
✅ notion-update-data-source
   Input: data_source_id (required)
   Output: Same data_source_id (unchanged)
   What changes: Schema, column definitions
   
✅ notion-move-pages
   Input: page_id (required)
   Output: Same page_id (unchanged)
   What changes: Parent location
   
✅ notion-duplicate-page
   Input: page_id (required)
   Output: NEW page_id (for cloned copy)
   Old page_id: Unchanged
```

---

## 🆔 ID Required? YES or NO?

| Operation | Requires ID | Which ID |
|-----------|-------------|----------|
| Create pages | NO (optional parent) | N/A |
| Create database | NO (optional parent) | N/A |
| Create comment | **YES** | page_id |
| Fetch | **YES** | page_id OR db_id |
| Search | NO | N/A |
| Get users/teams | NO | N/A |
| Get comments | **YES** | page_id |
| Update page | **YES** | page_id |
| Update schema | **YES** | data_source_id |
| Move pages | **YES** | page_id |
| Duplicate | **YES** | page_id |

---

## 🔑 ID Discovery Flow

### Need an ID? Here's how:

```
1️⃣ FOR KNOWN ITEMS:
   Use: notion-fetch(url_or_id)
   Get: page_id, data_source_id, child IDs
   
2️⃣ FOR SEARCHING ITEMS:
   Use: notion-search(query_text)
   Get: All matching page IDs + database IDs
   
3️⃣ FOR NEWLY CREATED ITEMS:
   Use: notion-create-* operation
   Get: ID immediately in response
   
4️⃣ FOR PEOPLE:
   Use: notion-get-users(query_text)
   Get: All matching user_ids
   
5️⃣ FOR TEAMS:
   Use: notion-get-teams(query_text)
   Get: All matching team_ids
```

---

## 📊 Data Persistence Reference

### What's Static (Never Changes)?
```
✓ page_id
✓ database_id
✓ data_source_id
✓ user_id
✓ discussion_id
✓ URL path structure (after ID assigned)
✓ Backlinks and references
```

### What's Dynamic (Updates Happen)?
```
✗ Page title
✗ Page content
✗ Page properties
✗ Database schema
✗ Database columns
✗ Page parent (location)
✗ Timestamps (created_at, updated_at)
✗ Comment count
```

---

## 🔄 Workflow Examples

### Example 1: Create → Reference Later

```
SESSION 1:
  └─ Create database
  └─ Get: data_source_id = "abc123..."

SESSION 2 (next day):
  └─ Use: data_source_id = "abc123..."
  └─ Create new pages in same database
  └─ Works! ✓ ID is permanent

SESSION 3 (next month):
  └─ Use: data_source_id = "abc123..."
  └─ Update schema with new columns
  └─ Works! ✓ ID is permanent
```

### Example 2: Updating Content

```
page_id = "page-uuid-123" ← STAYS THE SAME

Update 1: Change title
  └─ page_id = "page-uuid-123" ← UNCHANGED

Update 2: Change content
  └─ page_id = "page-uuid-123" ← UNCHANGED

Update 3: Move to different parent
  └─ page_id = "page-uuid-123" ← UNCHANGED

Update 4: Add properties
  └─ page_id = "page-uuid-123" ← UNCHANGED
```

### Example 3: Duplicate Safe

```
Original: page_id = "original-uuid"

Duplicate: 
  └─ Returns: page_id = "new-uuid"
  └─ Original: UNCHANGED

Both exist independently with different IDs
```

---

## 🛠️ Code Generation Questions

| Question | Answer |
|----------|--------|
| Is code static per page? | NO - Code regenerated each session |
| Are Notion references static? | YES - IDs are permanent |
| Does code execution change IDs? | NO - IDs never change |
| Can code reuse past IDs? | YES - They're permanent |
| Do I need to store IDs? | YES - For referencing items |
| Can IDs expire? | NO - They're permanent |
| Can IDs be reused for new items? | NO - Each item gets unique ID |

---

## ✅ Implementation Checklist

```
Before any operation:
☑️ Know which operation you're doing
☑️ Check if ID is required (see table above)
☑️ If required, get ID from:
   - notion-fetch (if known item)
   - notion-search (if finding item)
   - Response from create operation (if new item)
   
For updates:
☑️ Use SAME ID as original item
☑️ Content/properties will update
☑️ ID itself will NOT change
☑️ Old versions preserved in Notion history

For references:
☑️ Save IDs when you create items
☑️ Use same IDs in future sessions
☑️ Don't generate new IDs (retrieve existing ones)
```

---

## 🚀 Common Patterns

### Pattern 1: Reusable Template Database

```javascript
// First time: Create template
const dbId = createDatabase();  // Returns: "db-template-uuid"
// Save this ID!

// Anytime later: Use template
createPages({ 
  parent: { data_source_id: "db-template-uuid" }
})
// Works because UUID is permanent
```

### Pattern 2: Versioned Content

```javascript
// Create document with ID
pageId = createPage();  // Returns: "doc-uuid"

// Version 1
updatePage(pageId, content_v1);
// pageId = "doc-uuid" (unchanged)

// Version 2
updatePage(pageId, content_v2);
// pageId = "doc-uuid" (unchanged)

// Notion tracks all versions, ID stays constant
```

### Pattern 3: Dynamic Schema

```javascript
// Create database
dbId = createDatabase(initial_schema);

// Add columns later (no data loss)
updateDataSource(dbId, ADD COLUMN X);
updateDataSource(dbId, ADD COLUMN Y);

// dbId = "same-uuid" throughout
// All existing records automatically updated
```

### Pattern 4: Safe Archival

```javascript
// Original page
pageId = "current-uuid"

// Duplicate for archive
archivePageId = duplicatePage(pageId);
// archivePageId = new unique ID
// original pageId = unchanged

// Now you have 2 separate pages with different IDs
```

---

## ⚠️ Common Mistakes & Fixes

### ❌ Mistake 1: Generating New IDs
```
WRONG: Every operation, create new database
  └─ Results in duplicate databases

RIGHT: Create once, reuse same data_source_id
  └─ Single database, multiple sessions
```

### ❌ Mistake 2: Not Saving Creation Response
```
WRONG: Create page, don't save the page_id
  └─ Can't reference page later

RIGHT: Save returned page_id immediately
  └─ Use same ID in future operations
```

### ❌ Mistake 3: Assuming ID Changes on Update
```
WRONG: After updating, get new ID for same item
  └─ Creates duplicate entries

RIGHT: Update with same ID
  └─ ID never changes, content does
```

### ❌ Mistake 4: Forgetting data_source_id vs database_id
```
WRONG: Use database_id for schema updates on multi-source DB
  └─ Operation fails

RIGHT: Use data_source_id from fetch <data-source> tag
  └─ Operation succeeds
```

---

## 🔍 Finding IDs

### In Notion URL:
```
https://notion.so/workspace/Page-Title-abc123def456
                                      └─ page_id (last part)

https://notion.so/workspace/Database-Title-abc123def456
                                       └─ database_id
```

### From notion-fetch Response:
```markdown
<page url="https://notion.so/...abc123...">
        └─ Contains page_id

<database url="...">
<data-source url="collection://ds-uuid">
                             └─ data_source_id
```

### From notion-create Response:
```json
{
  "id": "newly-created-uuid",
  "url": "https://notion.so/newly-created-uuid"
}
```

---

## 📞 When to Use Each Tool

```
notion-fetch
├─ Use when: You know page/DB, want full details
├─ Requires: page_id, database_id, or URL
└─ Returns: Everything including child IDs

notion-search  
├─ Use when: You don't know ID, searching for something
├─ Requires: Search query
└─ Returns: All matching IDs

notion-create-pages
├─ Use when: Making new pages
├─ Requires: (Optional parent)
└─ Returns: New page_id

notion-create-database
├─ Use when: Making new database
├─ Requires: Schema definition
└─ Returns: database_id + data_source_id

notion-update-page
├─ Use when: Changing page content/properties
├─ Requires: page_id (SAME page_id)
└─ Returns: Updated page_id (unchanged)

notion-update-data-source
├─ Use when: Adding/removing database columns
├─ Requires: data_source_id (get from fetch)
└─ Returns: data_source_id (unchanged)

notion-move-pages
├─ Use when: Relocating pages to different parent
├─ Requires: page_id, new parent_id
└─ Returns: page_id (unchanged)

notion-duplicate-page
├─ Use when: Cloning a page
├─ Requires: page_id
└─ Returns: NEW page_id for clone

notion-create-comment
├─ Use when: Adding discussion to page
├─ Requires: page_id
└─ Returns: discussion_id

notion-get-comments
├─ Use when: Reading all discussions
├─ Requires: page_id
└─ Returns: All discussion_ids + content

notion-get-users / notion-get-teams
├─ Use when: Finding people or teams
├─ Requires: (Optional query)
└─ Returns: user_id, team_id lists
```

---

## 🎯 TL;DR Summary

| Aspect | Rule |
|--------|------|
| IDs Change? | **NO - Never** |
| Create Returns ID? | **YES - Always** |
| Code is Static? | **NO - Regenerated** |
| References Static? | **YES - Permanent** |
| Need to Save IDs? | **YES - For reuse** |
| Can Reuse IDs? | **YES - They're permanent** |
| ID Required for Update? | **YES - Same ID** |
| Data Loss on Update? | **NO - Safe** |
| Can IDs Expire? | **NO - Permanent** |

---

## 🔗 Working with Your AI Chief of Staff

Since you're building the AI Chief of Staff system:

```
1. Create database structure once → Save data_source_id
2. Create page templates → Save page_id references
3. Build automation around these IDs (they're permanent)
4. IDs work across sessions (perfect for scheduled jobs)
5. Updates don't change IDs (safe for tracking)
6. Schema changes don't lose data (grow fearlessly)
```

Your automation system can reliably reference the same Notion items indefinitely using stored IDs.
