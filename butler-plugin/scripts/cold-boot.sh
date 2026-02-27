#!/bin/bash
# cold-boot.sh — Morning context assembly. Run once per day on /morning.
# Self-locates from script path — no hardcoded paths, no env var dependency.

# ── SELF-LOCATE ─────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_PLUGIN_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CLAUDE_PROJECT_DIR="$(cd "$CLAUDE_PLUGIN_ROOT/.." && pwd)"
export CLAUDE_PLUGIN_ROOT CLAUDE_PROJECT_DIR
# ─────────────────────────────────────────────────────────────────────────────

DATE=$(date '+%Y-%m-%d %H:%M:%S')
TODAY=$(date '+%Y-%m-%d')
DUMP_FILE="$CLAUDE_PROJECT_DIR/CONTEXT_DUMP.md"
REFS="$CLAUDE_PLUGIN_ROOT/core-modules-references.json"
CORE_FILES=(CLAUDE.md USER.md SOUL.md SCRATCHPAD.md MEMORYLOG.md TASK.md)
MISSING_FILES=()

# Validate core-modules-references.json
if [ ! -f "$REFS" ]; then
  echo "COLD_BOOT_STATUS=REFS_MISSING"
  echo "ERROR: core-modules-references.json not found at $REFS"
  echo "ACTION: Run /onboarding first."
  exit 1
fi

if ! jq empty "$REFS" 2>/dev/null; then
  echo "COLD_BOOT_STATUS=REFS_INVALID"
  echo "ERROR: core-modules-references.json is malformed JSON."
  exit 1
fi

# Check which core files exist locally
for f in "${CORE_FILES[@]}"; do
  if [ ! -f "$CLAUDE_PROJECT_DIR/$f" ]; then
    MISSING_FILES+=("$f")
  fi
done

# LOCAL COMPLETE — no Notion API cost
if [ ${#MISSING_FILES[@]} -eq 0 ]; then
  {
    echo "# BUTLER CONTEXT DUMP"
    echo "**Generated:** $DATE"
    echo "**Source:** LOCAL"
    echo ""
    for f in "${CORE_FILES[@]}"; do
      echo -e "\n---\n## $f"
      cat "$CLAUDE_PROJECT_DIR/$f"
    done
  } > "$DUMP_FILE"
  echo "COLD_BOOT_STATUS=LOCAL_COMPLETE"
  echo "DUMP=$DUMP_FILE"
else
  # Signal morning.md which files need Notion fetch
  echo "COLD_BOOT_STATUS=NOTION_FETCH_REQUIRED"
  printf "MISSING_FILES=%s\n" "${MISSING_FILES[*]}"
fi

exit 0