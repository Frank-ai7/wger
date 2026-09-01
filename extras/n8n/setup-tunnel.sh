#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/.env"
LOG_FILE="/tmp/cloudflared-n8n.log"
CLOUDFLARED="${CLOUDFLARED:-/tmp/cloudflared}"

if [[ ! -x "${CLOUDFLARED}" ]]; then
  curl -sL https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o "${CLOUDFLARED}"
  chmod +x "${CLOUDFLARED}"
fi

SESSION_NAME="cloudflared-tunnel"
if ! tmux -f /exec-daemon/tmux.portal.conf has-session -t "=${SESSION_NAME}" 2>/dev/null; then
  tmux -f /exec-daemon/tmux.portal.conf new-session -d -s "${SESSION_NAME}" -c "${SCRIPT_DIR}" -- "${SHELL:-zsh}" -l
fi

tmux -f /exec-daemon/tmux.portal.conf send-keys -t "${SESSION_NAME}:0.0" C-c
sleep 1
tmux -f /exec-daemon/tmux.portal.conf send-keys -t "${SESSION_NAME}:0.0" \
  "${CLOUDFLARED} tunnel --url http://localhost:5678 2>&1 | tee ${LOG_FILE}" C-m

TUNNEL_URL=""
for _ in $(seq 1 20); do
  TUNNEL_URL="$(rg -o 'https://[a-z0-9-]+\.trycloudflare\.com' "${LOG_FILE}" | head -1 || true)"
  if [[ -n "${TUNNEL_URL}" ]]; then
    break
  fi
  sleep 1
done

if [[ -z "${TUNNEL_URL}" ]]; then
  echo "Could not detect Cloudflare tunnel URL. Check ${LOG_FILE}." >&2
  exit 1
fi

HOST="${TUNNEL_URL#https://}"

if [[ -f "${ENV_FILE}" ]]; then
  python3 - "${ENV_FILE}" "${TUNNEL_URL}" "${HOST}" <<'PY'
import pathlib
import sys

env_path = pathlib.Path(sys.argv[1])
tunnel_url = sys.argv[2]
host = sys.argv[3]

lines = env_path.read_text().splitlines() if env_path.exists() else []
values = {}
for line in lines:
    if not line.strip() or line.strip().startswith("#") or "=" not in line:
        continue
    key, value = line.split("=", 1)
    values[key.strip()] = value.strip()

values["WEBHOOK_URL"] = f"{tunnel_url}/"
values["N8N_HOST"] = host
values["N8N_PROTOCOL"] = "https"

ordered_keys = ["WEBHOOK_URL", "N8N_HOST", "N8N_PROTOCOL", "GENERIC_TIMEZONE", "N8N_ENCRYPTION_KEY"]
output = []
seen = set()
for key in ordered_keys:
    if key in values:
        output.append(f"{key}={values[key]}")
        seen.add(key)
for key, value in values.items():
    if key not in seen:
        output.append(f"{key}={value}")

env_path.write_text("\n".join(output) + "\n")
PY
else
  cat > "${ENV_FILE}" <<EOF
WEBHOOK_URL=${TUNNEL_URL}/
N8N_HOST=${HOST}
N8N_PROTOCOL=https
GENERIC_TIMEZONE=Europe/Berlin
EOF
fi

echo "Tunnel URL: ${TUNNEL_URL}/"
echo "Updated ${ENV_FILE}. Restart n8n with ./start.sh to apply WEBHOOK_URL."
