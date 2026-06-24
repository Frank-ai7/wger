#!/usr/bin/env bash
# Deploy app.mapaluto.de nginx + Root-Seite auf Hetzner (behebt 502 auf /)
# Auf dem Server ausführen, aus dem Repo-Ordner:
#   cd /pfad/zum/wger && sudo bash extras/mapaluto/DEPLOY-HETZNER.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WEB_ROOT="/var/www/app.mapaluto.de"
NGINX_SITE="/etc/nginx/sites-available/app.mapaluto.de"
NGINX_ENABLED="/etc/nginx/sites-enabled/app.mapaluto.de"

if [[ "${EUID:-}" -ne 0 ]]; then
  echo "Bitte mit sudo ausführen."
  exit 1
fi

echo "=== 1/5 Statische Startseite ==="
mkdir -p "$WEB_ROOT"
cp "$SCRIPT_DIR/app-root/index.html" "$WEB_ROOT/index.html"
chown -R www-data:www-data "$WEB_ROOT" 2>/dev/null || chown -R nginx:nginx "$WEB_ROOT" 2>/dev/null || true

echo "=== 2/5 nginx Site ==="
cp "$SCRIPT_DIR/nginx-app-proxy.conf" "$NGINX_SITE"
ln -sf "$NGINX_SITE" "$NGINX_ENABLED"

echo "=== 3/5 nginx test ==="
nginx -t

echo "=== 4/5 nginx reload ==="
systemctl reload nginx

echo "=== 5/5 Lokale Tests ==="
curl -sf -o /dev/null -w "Root /: HTTP %{http_code}\n" http://127.0.0.1:8081/ || {
  echo "FEHLER: nginx antwortet nicht auf 127.0.0.1:8081"
  exit 1
}

echo ""
echo "OK. Nächste Schritte:"
echo "  1) Cloudflare Tunnel auf http://127.0.0.1:8081 zeigen (siehe cloudflared-app-ingress.snippet.yml)"
echo "  2) sudo systemctl restart cloudflared"
echo "  3) sudo bash $SCRIPT_DIR/secure-firewall.sh   # Ports 8080/8765 von außen schließen"
echo "  4) Im Browser: https://app.mapaluto.de/ (nach Cloudflare-Login)"
