#!/usr/bin/env bash
# Schließt die Sicherheitslücke: Ports 8080/8765 nur noch lokal, nicht öffentlich.
# Auf dem Hetzner-Server als root ausführen: sudo bash secure-firewall.sh

set -euo pipefail

if [[ "${EUID:-}" -ne 0 ]]; then
  echo "Bitte mit sudo ausführen."
  exit 1
fi

if command -v ufw >/dev/null 2>&1; then
  ufw deny 8080/tcp comment "Tom App nur via app.mapaluto.de HTTPS" || true
  ufw deny 8765/tcp comment "Festung nur via app.mapaluto.de HTTPS" || true
  ufw status numbered | head -30
  echo "OK: ufw-Regeln gesetzt (8080/8765 blockiert von außen)."
else
  echo "ufw nicht installiert — iptables manuell prüfen."
fi

echo "Test lokal (soll 200/302 sein):"
curl -s -o /dev/null -w "8080: %{http_code}\n" http://127.0.0.1:8080/ || echo "8080: DOWN"
curl -s -o /dev/null -w "8765: %{http_code}\n" http://127.0.0.1:8765/ || echo "8765: DOWN"
curl -s -o /dev/null -w "nginx 8081 /: %{http_code}\n" http://127.0.0.1:8081/ || echo "8081: DOWN"
