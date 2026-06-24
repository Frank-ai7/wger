#!/usr/bin/env bash
# Auf dem mapaluto-Rechner ausfuehren (WSL, Linux, oder SSH auf 178.105.175.183)
#   bash extras/mapaluto/check-mapaluto.sh

OUT="${HOME}/mapaluto-diagnose.txt"
{
  echo "=== mapaluto Diagnose ==="
  echo "Host: $(hostname)"
  echo "Datum: $(date)"
  echo

  echo "=== docker ps ==="
  docker ps 2>&1 || echo "Docker nicht verfuegbar"
  echo

  echo "=== ss -tlnp | grep LISTEN ==="
  ss -tlnp 2>/dev/null | grep LISTEN || netstat -tlnp 2>/dev/null | grep LISTEN
  echo

  echo "=== systemctl caddy cloudflared ==="
  systemctl status caddy cloudflared --no-pager 2>&1 || true
  echo

  echo "=== curl lokal ==="
  for url in http://127.0.0.1/ http://127.0.0.1:8080/ http://127.0.0.1:8081/ http://127.0.0.1:8765/ http://127.0.0.1:18789/; do
    code=$(curl -s -o /dev/null -w "%{http_code}" -m 2 "$url" 2>/dev/null || echo "000")
    echo "$url -> $code"
  done
} | tee "$OUT"

echo "Gespeichert: $OUT"
