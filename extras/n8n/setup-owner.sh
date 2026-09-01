#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/credentials.env"
N8N_URL="${N8N_URL:-http://localhost:5678}"

if [[ ! -f "${ENV_FILE}" ]]; then
  cp "${SCRIPT_DIR}/credentials.env.example" "${ENV_FILE}"
fi

set -a
# shellcheck disable=SC1090
source "${ENV_FILE}"
set +a

response="$(curl -sf "${N8N_URL}/rest/settings")"
if echo "${response}" | python3 -c "import sys,json; d=json.load(sys.stdin)['data']; sys.exit(0 if d['userManagement']['showSetupOnFirstLoad'] else 1)"; then
  curl -sf -X POST "${N8N_URL}/rest/owner/setup" \
    -H 'Content-Type: application/json' \
    -d "{\"email\":\"${N8N_OWNER_EMAIL}\",\"firstName\":\"${N8N_OWNER_FIRST_NAME}\",\"lastName\":\"${N8N_OWNER_LAST_NAME}\",\"password\":\"${N8N_OWNER_PASSWORD}\"}" >/dev/null
  echo "Owner account created: ${N8N_OWNER_EMAIL}"
else
  echo "Owner account already configured."
fi
