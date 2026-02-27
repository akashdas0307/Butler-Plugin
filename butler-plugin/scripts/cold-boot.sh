#!/bin/bash
DUMP_FILE="${CLAUDE_PROJECT_DIR}/CONTEXT_DUMP.md"
TODAY=$(date '+%Y-%m-%d')
DATE=$(date '+%Y-%m-%d %H:%M:%S')
REFS="${CLAUDE_PLUGIN_ROOT}/core-modules-references.json"
CORE_FILES=(CLAUDE.md USER.md SOUL.md SCRATCHPAD.md MEMORYLOG.md TASK.md)
MISSING_FILES=()

# Validate references JSON first
if [ ! -f "$REFS" ]; then
  echo "COLD_BOOT_STATUS=REFS_MISSING"
  exit 1
fi

# Validate it has all required keys
for key in CLAUDE.md USER.md SOUL.md SCRATCHPAD.md MEMORYLOG.md TASK.md; do
  if ! jq -e ".[\"$key\"].notion_page_id" "$REFS" > /dev/null 2>&1; then
    echo "COLD_BOOT_STATUS=REFS_INVALID"
    echo "MISSING_KEY=$key"
    exit 1
  fi
done

# Check which core files exist locally
for f in "${CORE_FILES[@]}"; do
  if [ ! -f "${CLAUDE_PROJECT_DIR}/$f" ]; then
    MISSING_FILES+=("$f")
  fi
done

# LOCAL COMPLETE PATH — zero Notion API cost
if [ ${#MISSING_FILES[@]} -eq 0 ]; then
  {
    echo "# BUTLER CONTEXT DUMP"
    echo "**Generated:** $DATE"
    echo "**Source:** LOCAL (no Notion fetch required)"
    echo ""
    for f in "${CORE_FILES[@]}"; do
      echo -e "\n---\n## $f"
      cat "${CLAUDE_PROJECT_DIR}/$f"
    done
  } > "$DUMP_FILE"
  echo "COLD_BOOT_STATUS=LOCAL_COMPLETE"
else
  # Signal morning.md which files need Notion fetch
  echo "COLD_BOOT_STATUS=NOTION_FETCH_REQUIRED"
  echo "MISSING_FILES=${MISSING_FILES[*]}"
fi

exit 0
