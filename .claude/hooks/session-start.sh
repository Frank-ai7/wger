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
