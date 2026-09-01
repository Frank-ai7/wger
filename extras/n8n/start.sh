#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

if [[ ! -d node_modules ]]; then
  echo "Installing n8n dependencies..."
  npm install
fi

if [[ -f .env ]]; then
  set -a
  # shellcheck disable=SC1091
  source .env
  set +a
fi

if [[ -z "${N8N_ENCRYPTION_KEY:-}" && -f "${N8N_USER_FOLDER:-$HOME/.n8n}/config" ]]; then
  export N8N_ENCRYPTION_KEY
  N8N_ENCRYPTION_KEY="$(python3 -c "import json; print(json.load(open('${N8N_USER_FOLDER:-$HOME/.n8n}/config'))['encryptionKey'])")"
fi

if [[ -z "${N8N_ENCRYPTION_KEY:-}" ]]; then
  export N8N_ENCRYPTION_KEY
  N8N_ENCRYPTION_KEY="$(openssl rand -hex 32)"
  echo "Generated N8N_ENCRYPTION_KEY (save this): ${N8N_ENCRYPTION_KEY}"
fi

export WEBHOOK_URL="${WEBHOOK_URL:-http://localhost:5678/}"
export GENERIC_TIMEZONE="${GENERIC_TIMEZONE:-Europe/Berlin}"
export N8N_HOST="${N8N_HOST:-localhost}"
export N8N_PROTOCOL="${N8N_PROTOCOL:-http}"

exec npm start
