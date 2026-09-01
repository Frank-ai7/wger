#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKFLOW_FILE="${SCRIPT_DIR}/workflow.json"
CONFIG_FILE="${N8N_USER_FOLDER:-$HOME/.n8n}/config"

if [[ -z "${N8N_ENCRYPTION_KEY:-}" && -f "${CONFIG_FILE}" ]]; then
  N8N_ENCRYPTION_KEY="$(python3 -c "import json; print(json.load(open('${CONFIG_FILE}'))['encryptionKey'])" 2>/dev/null || true)"
  export N8N_ENCRYPTION_KEY
fi

if [[ ! -f "${WORKFLOW_FILE}" ]]; then
  echo "Workflow file not found: ${WORKFLOW_FILE}" >&2
  exit 1
fi

if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
  echo "Importing workflow into running n8n container..."
  docker compose -f "${SCRIPT_DIR}/docker-compose.yml" exec -T n8n \
    n8n import:workflow --input=/import/workflow.json
  echo "Done. Open http://localhost:5678 and connect credentials."
  exit 0
fi

if [[ -x "${SCRIPT_DIR}/node_modules/.bin/n8n" ]]; then
  echo "Importing workflow with local n8n CLI..."
  (cd "${SCRIPT_DIR}" && ./node_modules/.bin/n8n import:workflow --input=workflow.json)
  echo "Done. Open http://localhost:5678 and connect credentials."
  exit 0
fi

if command -v n8n >/dev/null 2>&1; then
  echo "Importing workflow with global n8n CLI..."
  n8n import:workflow --input="${WORKFLOW_FILE}"
  echo "Done. Open http://localhost:5678 and connect credentials."
  exit 0
fi

echo "Neither docker compose nor n8n CLI found." >&2
echo "Start n8n first, then import manually via UI: Workflows → Import from File → workflow.json" >&2
exit 1
