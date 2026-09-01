#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

echo "==> Installing n8n dependencies (if needed)"
if [[ ! -d node_modules ]]; then
  npm install
fi

echo "==> Creating owner account"
chmod +x setup-owner.sh setup-tunnel.sh import-workflow.sh start.sh
./setup-owner.sh

echo "==> Starting n8n"
SESSION_NAME="n8n-server"
if ! tmux -f /exec-daemon/tmux.portal.conf has-session -t "=${SESSION_NAME}" 2>/dev/null; then
  tmux -f /exec-daemon/tmux.portal.conf new-session -d -s "${SESSION_NAME}" -c "${SCRIPT_DIR}" -- "${SHELL:-zsh}" -l
  tmux -f /exec-daemon/tmux.portal.conf send-keys -t "${SESSION_NAME}:0.0" './start.sh' C-m
else
  echo "n8n tmux session already running."
fi

for _ in $(seq 1 30); do
  if curl -sf http://localhost:5678/healthz >/dev/null 2>&1; then
    break
  fi
  sleep 2
done

echo "==> Importing workflow"
./import-workflow.sh

echo "==> Starting public tunnel for Telegram webhooks"
./setup-tunnel.sh

if [[ -f .env ]]; then
  set -a
  # shellcheck disable=SC1091
  source .env
  set +a
  tmux -f /exec-daemon/tmux.portal.conf send-keys -t "${SESSION_NAME}:0.0" C-c
  sleep 2
  tmux -f /exec-daemon/tmux.portal.conf send-keys -t "${SESSION_NAME}:0.0" './start.sh' C-m
  sleep 6
fi

if [[ -f credentials.env ]] && rg -q 'TELEGRAM_BOT_TOKEN=.+' credentials.env 2>/dev/null; then
  echo "==> Wiring credentials from credentials.env"
  python3 setup-credentials.py
else
  echo "==> Skipping credentials (copy credentials.env.example → credentials.env and add API keys)"
fi

cat <<EOF

Setup complete.

  n8n UI:      http://localhost:5678
  Login:       admin@local.dev / Admin1234!
  Webhook URL: ${WEBHOOK_URL:-see .env}

Next steps:
  1. Fill credentials.env with your API keys
  2. Run: python3 setup-credentials.py
  3. Connect Google OAuth in the n8n UI (Gmail, Calendar, Tasks)
  4. Activate the workflow and message your Telegram bot

EOF
