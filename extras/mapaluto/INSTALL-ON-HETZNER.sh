#!/usr/bin/env bash
# Ein-Klick-Fix für app.mapaluto.de + mapaluto.de/agent auf dem Hetzner
#
# In der Hetzner Web-Konsole (root) EINZELN ausführen:
#   curl -fsSL "https://raw.githubusercontent.com/Frank-ai7/wger/cursor/mapaluto-ubuntu-button-fce1/extras/mapaluto/INSTALL-ON-HETZNER.sh" | sudo bash
#
# Oder nach git clone:
#   sudo bash extras/mapaluto/INSTALL-ON-HETZNER.sh

set -euo pipefail

REPO_BRANCH="cursor/mapaluto-ubuntu-button-fce1"
RAW_BASE="https://raw.githubusercontent.com/Frank-ai7/wger/${REPO_BRANCH}/extras/mapaluto"
WORK="/tmp/mapaluto-deploy-$$"
WEB_APP="/var/www/app.mapaluto.de"
NGINX_APP="/etc/nginx/sites-available/app.mapaluto.de"
NGINX_AGENT="/etc/nginx/sites-available/mapaluto-agent"
OPENCLAW_PORT="${OPENCLAW_PORT:-}"

if [[ "${EUID:-}" -ne 0 ]]; then
  echo "Bitte mit sudo ausführen."
  exit 1
fi

log() { echo "[mapaluto] $*"; }

detect_openclaw_port() {
  local port=""
  # Docker: Container mit claw/agent im Namen
  if command -v docker >/dev/null 2>&1; then
    port=$(docker ps --format '{{.Names}} {{.Ports}}' 2>/dev/null \
      | grep -iE 'claw|openclaw|kiloclaw|agent' \
      | grep -oE '127\.0\.0\.1:([0-9]+)' | head -1 | cut -d: -f2 || true)
    [[ -z "$port" ]] && port=$(docker ps --format '{{.Names}} {{.Ports}}' 2>/dev/null \
      | grep -iE 'claw|openclaw|kiloclaw|agent' \
      | grep -oE '0\.0\.0\.0:([0-9]+)->' | head -1 | grep -oE '[0-9]+' | head -1 || true)
  fi
  # Fallback: typische Ports testen
  if [[ -z "$port" ]]; then
    for p in 18789 3000 8080 7860 5000; do
      if curl -sf -m 2 "http://127.0.0.1:${p}/" >/dev/null 2>&1 || \
         curl -sf -m 2 "http://127.0.0.1:${p}/health" >/dev/null 2>&1; then
        port="$p"
        break
      fi
    done
  fi
  echo "$port"
}

mkdir -p "$WORK/app-root"
log "Lade Deploy-Dateien …"
curl -fsSL "${RAW_BASE}/app-root/index.html" -o "${WORK}/app-root/index.html"
curl -fsSL "${RAW_BASE}/nginx-app-proxy.conf" -o "${WORK}/nginx-app-proxy.conf"
curl -fsSL "${RAW_BASE}/secure-firewall.sh" -o "${WORK}/secure-firewall.sh"

log "=== 1/6 app.mapaluto.de Startseite + Proxy (Port 8081) ==="
mkdir -p "$WEB_APP"
cp "${WORK}/app-root/index.html" "$WEB_APP/index.html"
chown -R www-data:www-data "$WEB_APP" 2>/dev/null || chown -R nginx:nginx "$WEB_APP" 2>/dev/null || true
cp "${WORK}/nginx-app-proxy.conf" "$NGINX_APP"
ln -sf "$NGINX_APP" /etc/nginx/sites-enabled/app.mapaluto.de

log "=== 2/6 mapaluto.de/agent Proxy (Port 8082) ==="
if [[ -z "$OPENCLAW_PORT" ]]; then
  OPENCLAW_PORT=$(detect_openclaw_port)
fi
if [[ -z "$OPENCLAW_PORT" ]]; then
  log "WARNUNG: OpenClaw-Port nicht gefunden. Setze: export OPENCLAW_PORT=DEIN_PORT && sudo bash $0"
  OPENCLAW_PORT=18789
  log "Verwende Platzhalter-Port ${OPENCLAW_PORT} — bitte anpassen falls falsch."
fi

cat > "$NGINX_AGENT" <<NGINX
server {
    listen 127.0.0.1:8082;
    server_name mapaluto.de;

    location = /kiloclaw { return 301 /agent/; }
    location = /agent  { return 301 /agent/; }

    location /agent/ {
        proxy_pass http://127.0.0.1:${OPENCLAW_PORT}/;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_read_timeout 86400;
    }
}
NGINX
ln -sf "$NGINX_AGENT" /etc/nginx/sites-enabled/mapaluto-agent

log "=== 3/6 nginx test + reload ==="
nginx -t
systemctl reload nginx

log "=== 4/6 Firewall (8080/8765 nach außen zu) ==="
bash "${WORK}/secure-firewall.sh" || true

log "=== 5/6 Lokale Tests ==="
curl -s -o /dev/null -w "app.mapaluto.de /  (8081): %{http_code}\n" http://127.0.0.1:8081/ || echo "8081: FAIL"
curl -s -o /dev/null -w "OpenClaw direkt (:${OPENCLAW_PORT}): %{http_code}\n" "http://127.0.0.1:${OPENCLAW_PORT}/" || echo "OpenClaw: DOWN — Container starten!"
curl -s -o /dev/null -w "mapaluto.de /agent (8082): %{http_code}\n" http://127.0.0.1:8082/agent/ || echo "8082/agent: FAIL"

log "=== 6/6 Cloudflare Tunnel ==="
echo ""
echo "Füge in ~/.cloudflared/config.yml (oder /etc/cloudflared/config.yml) ein:"
echo ""
cat <<YAML
ingress:
  - hostname: app.mapaluto.de
    service: http://127.0.0.1:8081
  - hostname: mapaluto.de
    path: /agent*
    service: http://127.0.0.1:8082
  - hostname: mapaluto.de
    path: /kiloclaw*
    service: http://127.0.0.1:8082
  # … deine bestehenden mapaluto.de-Regeln (/, /n8n, …) UNVERÄNDERT darunter …
YAML
echo ""
echo "Danach: sudo systemctl restart cloudflared"
echo ""
echo "Browser testen (nach Cloudflare-Login):"
echo "  https://app.mapaluto.de/"
echo "  https://mapaluto.de/agent"
echo ""
if ! curl -sf -m 2 "http://127.0.0.1:${OPENCLAW_PORT}/" >/dev/null 2>&1; then
  echo ">>> OpenClaw läuft NICHT auf Port ${OPENCLAW_PORT}. Starte den Container/Dienst,"
  echo ">>> dann: export OPENCLAW_PORT=RICHTIGER_PORT && sudo bash extras/mapaluto/INSTALL-ON-HETZNER.sh"
  docker ps 2>/dev/null || true
fi

rm -rf "$WORK"
log "Fertig."
