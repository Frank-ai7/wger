#!/bin/bash
# Pyragogy Behörden-Assistent — Setup Script
# Auf dem Hetzner-Server ausführen nach SSH-Login
# Voraussetzung: n8n läuft als Docker-Container mit PostgreSQL

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JSON_FILE="$SCRIPT_DIR/pyragogy_behoerde.json"

echo "================================================"
echo " Pyragogy Behörden-Assistent — Setup"
echo "================================================"

# ── Schritt 1: Docker-Container finden ──────────────
echo ""
echo "[1/4] Suche n8n Docker-Container..."
N8N_CONTAINER=$(docker ps --format '{{.Names}}' | grep -i n8n | head -1)

if [ -z "$N8N_CONTAINER" ]; then
    echo "FEHLER: Kein laufender n8n-Container gefunden."
    echo "Laufende Container:"
    docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}'
    echo ""
    echo "Bitte Container-Namen manuell angeben:"
    read -rp "Container-Name: " N8N_CONTAINER
fi

echo "  Container gefunden: $N8N_CONTAINER"

# ── Schritt 2: JSON in Container kopieren ───────────
echo ""
echo "[2/4] Kopiere Workflow-JSON in Container..."
docker cp "$JSON_FILE" "$N8N_CONTAINER:/tmp/pyragogy_behoerde.json"
echo "  Datei kopiert nach /tmp/pyragogy_behoerde.json"

# ── Schritt 3: Import ────────────────────────────────
echo ""
echo "[3/4] Importiere Workflow in n8n..."
docker exec "$N8N_CONTAINER" n8n import:workflow --input=/tmp/pyragogy_behoerde.json
echo "  Import abgeschlossen"

# ── Schritt 4: Anleitung ausgeben ───────────────────
echo ""
echo "[4/4] Naechste Schritte in n8n (Browser):"
echo ""
echo "  1. Öffne: https://DEINE-N8N-DOMAIN"
echo "  2. Gehe zu: Workflows → 'Pyragogy Behörden-Assistent'"
echo "  3. Credentials verknüpfen (oben rechts → 'Credentials'):"
echo ""
echo "     Pyragogy Supabase DB  → PostgreSQL"
echo "       Host:     db.[REF].supabase.co"
echo "       Port:     5432"
echo "       Database: postgres"
echo "       User:     postgres"
echo "       Password: [DB-Passwort aus Supabase Settings]"
echo "       SSL:      EIN"
echo ""
echo "     Pyragogy Anthropic    → Anthropic"
echo "       API Key: sk-ant-..."
echo ""
echo "     Pyragogy Email SMTP   → SMTP"
echo "       Host:     smtp.gmail.com"
echo "       Port:     587"
echo "       User:     deine@gmail.com"
echo "       Password: [Gmail App-Passwort]"
echo ""
echo "  4. In Node 'Review Email senden':"
echo "     [DEINE_EMAIL@DOMAIN.DE] → deine echte E-Mail ersetzen"
echo ""
echo "  5. Workflow aktivieren (Toggle oben rechts)"
echo ""
echo "  6. Test-Aufruf:"
N8N_URL="${N8N_URL:-https://DEINE-N8N-DOMAIN}"
echo "     curl -X POST $N8N_URL/webhook/pyragogy/behoerde \\"
echo "       -H 'Content-Type: application/json' \\"
echo "       -d '{\"title\":\"GdB-Widerspruch Test\",\"initial_text\":\"Test\",\"tags\":\"gdb\"}'"
echo ""
echo "================================================"
echo " Setup abgeschlossen!"
echo "================================================"
