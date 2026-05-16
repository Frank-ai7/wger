#!/bin/bash
set -euo pipefail

# Only run in remote Claude Code on the web sessions
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

cd "$CLAUDE_PROJECT_DIR"

# Install Python dependencies (including dev extras)
uv sync --dev

# Install JS dependencies and copy static assets
# COREPACK_ENABLE_STRICT=0: remote env may have a different Corepack version than
# declared in packageManager; suppressed to avoid version mismatch errors.
COREPACK_ENABLE_STRICT=0 YARN_IGNORE_PATH=1 yarn install

# Create settings file if not present
if [ ! -f settings.py ]; then
  uv run wger create-settings
fi

# Restore custom skills from repo into global Claude skills directory
mkdir -p ~/.claude/skills
for skill_dir in "$CLAUDE_PROJECT_DIR"/.claude/skills/*/; do
  skill_name=$(basename "$skill_dir")
  if [ ! -d ~/.claude/skills/"$skill_name" ]; then
    cp -r "$skill_dir" ~/.claude/skills/"$skill_name"
  fi
done

# Load secrets from .env and export to session environment
if [ -f "$CLAUDE_PROJECT_DIR/.env" ] && [ -n "${CLAUDE_ENV_FILE:-}" ]; then
  grep -v '^\s*#' "$CLAUDE_PROJECT_DIR/.env" | grep -v '^\s*$' | while IFS= read -r line; do
    echo "export $line" >> "$CLAUDE_ENV_FILE"
  done
fi
