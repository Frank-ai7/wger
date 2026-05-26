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
echo "[1/5] Suche n8n Docker-Container..."
N8N_CONTAINER=$(docker ps --format '{{.Names}}' | grep -i 'n8n' | grep -v postgres | grep -v redis | head -1)

if [ -z "$N8N_CONTAINER" ]; then
    echo "Kein n8n-Container gefunden. Laufende Container:"
    docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}'
    echo ""
    read -rp "Container-Name: " N8N_CONTAINER
fi

echo "  n8n Container: $N8N_CONTAINER"

# ── Schritt 2: DB-Hostname im Docker-Netzwerk ermitteln ─
echo ""
echo "[2/5] Ermittle PostgreSQL-Hostname im Docker-Netzwerk..."
DB_HOST=$(docker inspect "$N8N_CONTAINER" \
  --format '{{range $k,$v := .NetworkSettings.Networks}}{{$v.NetworkID}}{{end}}' 2>/dev/null | head -1)
# Versuche den postgres-Container im selben Netzwerk zu finden
PG_HOST=$(docker ps --format '{{.Names}}' | grep -i postgres | head -1)
if [ -z "$PG_HOST" ]; then
    PG_HOST="postgres"
fi
echo "  PostgreSQL Container: $PG_HOST"
echo "  (Als Host in n8n Credential eintragen: '$PG_HOST')"

# ── Schritt 3: Tabelle in der DB erstellen ───────────
echo ""
echo "[3/5] Erstelle Tabelle 'pyragogy_behoerde' in der n8n-Datenbank..."
docker exec "$PG_HOST" psql -U n8n -d n8n -c "
CREATE TABLE IF NOT EXISTS public.pyragogy_behoerde (
  id BIGSERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  content TEXT,
  status TEXT DEFAULT 'pending',
  tags TEXT,
  iterations INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);" && echo "  Tabelle erstellt (oder schon vorhanden)" || echo "  Hinweis: Manuelle DB-Erstellung noetig"

# ── Schritt 4: JSON in Container kopieren + importieren ─
echo ""
echo "[4/5] Importiere Workflow in n8n..."
docker cp "$JSON_FILE" "$N8N_CONTAINER:/tmp/pyragogy_behoerde.json"
docker exec "$N8N_CONTAINER" n8n import:workflow --input=/tmp/pyragogy_behoerde.json
echo "  Import abgeschlossen"

# ── Schritt 5: Anleitung ausgeben ───────────────────
echo ""
echo "================================================"
echo "[5/5] Credentials in n8n einrichten:"
echo "================================================"
echo ""
echo "  Oeffne: https://DEINE-N8N-DOMAIN"
echo "  Gehe zu: Settings > Credentials > Add Credential"
echo ""
echo "  1. PostgreSQL — Name: 'Pyragogy n8n PostgreSQL'"
echo "     Host:     $PG_HOST"
echo "     Port:     5432"
echo "     Database: n8n"
echo "     User:     n8n"
echo "     Password: [dein DB-Passwort aus Bitwarden]"
echo "     SSL:      AUS"
echo ""
echo "  2. Anthropic — Name: 'Pyragogy Anthropic'"
echo "     API Key:  sk-ant-...  (von console.anthropic.com)"
echo ""
echo "  3. SMTP — Name: 'Pyragogy Email SMTP'"
echo "     Host:     smtp.gmail.com"
echo "     Port:     587"
echo "     User:     deine@gmail.com"
echo "     Password: [Gmail App-Passwort]"
echo "     TLS:      EIN"
echo ""
echo "  Dann im Workflow:"
echo "  - Node 'Review Email senden' öffnen"
echo "  - [DEINE_EMAIL@DOMAIN.DE] durch echte E-Mail ersetzen"
echo "  - Workflow aktivieren (Toggle oben rechts)"
echo ""
echo "  Test:"
echo "  bash test_pyragogy.sh DEINE-N8N-DOMAIN"
echo ""
echo "================================================"
echo " Setup abgeschlossen!"
echo "================================================"
