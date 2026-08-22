#!/usr/bin/env bash
# Reparatur-Skript: OpenClaw Gateway auf Linux-VPS (Port 18789)
# Ausfuehren auf dem Server: bash fix-openclaw-gateway.sh

set -euo pipefail

PORT="${OPENCLAW_GATEWAY_PORT:-18789}"
OC_HOME="${HOME}/.openclaw"
OC_CONFIG="${OC_HOME}/openclaw.json"
OC_ENV="${OC_HOME}/.env"
LOG="/tmp/fix-openclaw-gateway.log"

exec > >(tee -a "$LOG") 2>&1

echo "=== OpenClaw Gateway Reparatur $(date -Is) ==="

if ! command -v openclaw >/dev/null 2>&1; then
  echo "FEHLER: openclaw CLI nicht gefunden."
  echo "Installieren: npm i -g openclaw@latest --allow-scripts=openclaw"
  exit 1
fi

mkdir -p "$OC_HOME"

# gateway.mode=local (haeufiger Startblocker)
if openclaw config get gateway.mode 2>/dev/null | grep -qv local; then
  echo "Setze gateway.mode=local ..."
  openclaw config set gateway.mode local || true
fi

# Agent main sicherstellen (JSON minimal patchen falls jq vorhanden)
if [[ -f "$OC_CONFIG" ]] && command -v jq >/dev/null 2>&1; then
  if ! jq -e '.agents.list[]? | select(.id=="main")' "$OC_CONFIG" >/dev/null 2>&1; then
    echo "Fuege Agent 'main' zu agents.list hinzu ..."
    tmp="$(mktemp)"
    jq '.agents.list = ((.agents.list // []) + [{"id":"main","name":"Main Agent","default":true}] | unique_by(.id))' \
      "$OC_CONFIG" > "$tmp" && mv "$tmp" "$OC_CONFIG"
  fi
fi

# Port-Konflikt beheben
if command -v ss >/dev/null 2>&1; then
  if ss -tlnp 2>/dev/null | grep -q ":${PORT} "; then
    echo "Port ${PORT} belegt – stoppe alte OpenClaw-Prozesse ..."
    openclaw gateway stop 2>/dev/null || true
    pkill -f "openclaw.*gateway" 2>/dev/null || true
    sleep 2
  fi
fi

# systemd user (headless VPS)
if command -v loginctl >/dev/null 2>&1; then
  loginctl enable-linger "$(whoami)" 2>/dev/null || true
fi

export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

# Gateway-Service installieren/starten
if openclaw gateway install 2>/dev/null; then
  echo "Gateway-Service installiert."
fi

if systemctl --user is-system-running >/dev/null 2>&1; then
  systemctl --user daemon-reload 2>/dev/null || true
  systemctl --user enable openclaw-gateway.service 2>/dev/null || true
  systemctl --user restart openclaw-gateway.service 2>/dev/null || true
else
  echo "systemd --user nicht verfuegbar – starte Gateway direkt ..."
  nohup openclaw gateway --port "$PORT" >> /tmp/openclaw-gateway-nohup.log 2>&1 &
  sleep 3
fi

# Fallback-Start
openclaw gateway restart 2>/dev/null || openclaw gateway start 2>/dev/null || true
sleep 2

echo ""
echo "--- Status ---"
openclaw gateway status 2>/dev/null || true
openclaw models status 2>/dev/null || true
openclaw doctor 2>/dev/null || true

echo ""
echo "--- Port ${PORT} ---"
ss -tlnp 2>/dev/null | grep ":${PORT} " || netstat -tlnp 2>/dev/null | grep ":${PORT} " || echo "WARNUNG: Port ${PORT} hoert nicht zu!"

echo ""
echo "=== Fertig. Log: ${LOG} ==="
echo "Auf dem SERVER testen: curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:${PORT}/"
echo "Von Ihrem PC: SSH-Tunnel noetig (127.0.0.1 ist nur localhost des jeweiligen Rechners)."
