# Personal Life Manager (Jackie) – n8n Workflow

Deutscher Setup-Guide für den Workflow [Personal life manager with Telegram, Google services & voice-enabled AI](https://n8n.io/workflows/8237-personal-life-manager-with-telegram-google-services-and-voice-enabled-ai/).

Der Assistent **Jackie** empfängt Telegram-Nachrichten (Text und Sprache), nutzt OpenRouter als KI-Modell und greift auf Gmail, Google Calendar und Google Tasks zu.

## Voraussetzungen

| Dienst | Zweck | Wo erstellen |
| --- | --- | --- |
| **Telegram Bot** | Eingang & Antworten | [@BotFather](https://t.me/BotFather) → `/newbot` |
| **OpenRouter** | KI-Sprachmodell | [openrouter.ai/settings/keys](https://openrouter.ai/settings/keys) |
| **OpenAI** | Sprach-zu-Text (Voice) | [platform.openai.com/api-keys](https://platform.openai.com/api-keys) |
| **Google OAuth2** | Gmail, Calendar, Tasks | [Google Cloud Console](https://console.cloud.google.com/) |

**Wichtig:** Telegram-Webhooks brauchen eine **öffentlich erreichbare HTTPS-URL**. Das Setup-Skript startet automatisch einen **Cloudflare-Tunnel** (`setup-tunnel.sh`).

## Automatisches Setup (empfohlen)

Alles in einem Schritt – n8n starten, Workflow importieren, Tunnel einrichten, Owner-Account anlegen:

```bash
cd extras/n8n
npm install
chmod +x setup-all.sh
./setup-all.sh
```

**Standard-Login (lokal):**

| Feld | Wert |
| --- | --- |
| E-Mail | `admin@local.dev` |
| Passwort | `Admin1234!` |

API-Keys automatisch verbinden:

```bash
cp credentials.env.example credentials.env
# credentials.env bearbeiten: TELEGRAM_BOT_TOKEN, OPENROUTER_API_KEY, OPENAI_API_KEY
python3 setup-credentials.py
```

Google OAuth (Gmail, Calendar, Tasks) musst du einmalig in der n8n-Oberfläche verbinden – das geht nicht per Skript.

## Schnellstart (Docker – empfohlen)

```bash
cd extras/n8n
cp .env.example .env
# .env bearbeiten: WEBHOOK_URL, N8N_ENCRYPTION_KEY setzen
openssl rand -hex 32   # für N8N_ENCRYPTION_KEY

docker compose up -d
chmod +x import-workflow.sh
./import-workflow.sh
```

Öffne [http://localhost:5678](http://localhost:5678), lege ein n8n-Benutzerkonto an und folge den Schritten unten für Credentials.

## Schnellstart (ohne Docker)

```bash
cd extras/n8n
npm install
cp .env.example .env
./start.sh
```

In einem zweiten Terminal:

```bash
cd extras/n8n
./import-workflow.sh
```

Alternativ: **Workflows → Import from File** → `workflow.json` auswählen.

## Schritt-für-Schritt: Credentials verbinden

### 1. Telegram

1. Bei [@BotFather](https://t.me/BotFather) Bot erstellen und **API Token** kopieren.
2. In n8n: **Credentials → Add credential → Telegram API**.
3. Token einfügen und speichern.
4. In diesen Nodes dieselbe Credential auswählen:
   - `Listen for incoming events`
   - `Telegram`
   - `Get Voice File`

### 2. OpenRouter

1. API-Key auf [openrouter.ai](https://openrouter.ai/settings/keys) erstellen.
2. Credential **OpenRouter API** anlegen.
3. Node **OpenRouter** damit verbinden.

### 3. OpenAI (nur für Sprachnachrichten)

1. API-Key auf [platform.openai.com](https://platform.openai.com/api-keys) erstellen.
2. Credential **OpenAI API** anlegen.
3. Node **Transcribe a recording** verbinden.

### 4. Google (Gmail, Calendar, Tasks)

1. In der [Google Cloud Console](https://console.cloud.google.com/) ein Projekt anlegen.
2. APIs aktivieren:
   - Gmail API
   - Google Calendar API
   - Google Tasks API
3. **OAuth consent screen** konfigurieren (External, Testnutzer = deine E-Mail).
4. **OAuth 2.0 Client ID** (Typ: Web application) erstellen.
5. Redirect-URI in n8n steht in der Credential-Maske (typisch: `https://<deine-n8n-url>/rest/oauth2-credential/callback`).
6. Drei Credentials in n8n anlegen (oder eine wiederverwenden, falls n8n es erlaubt):
   - **Gmail OAuth2** → Nodes `Get Email`, `Send Email`
   - **Google Calendar OAuth2** → Node `Google Calendar`
   - **Google Tasks OAuth2** → Nodes `Create a task…`, `Get many tasks…`

### 5. Google Calendar E-Mail eintragen

Im Node **Google Calendar** den Platzhalter `=<insert email here>` durch deine Google-Kalender-ID ersetzen (meist deine Gmail-Adresse).

### 6. Google Tasks Liste wählen

Die Nodes **Create a task in Google Tasks** und **Get many tasks in Google Tasks** enthalten eine feste Task-Listen-ID aus dem Original-Workflow. Nach dem Import:

1. Node öffnen → **Task List** → deine eigene Liste aus der Dropdown-Liste wählen.

## Workflow aktivieren

1. Alle Credentials in allen Nodes zuweisen (rote Warnungen verschwinden).
2. **Publish** / **Activate** klicken.
3. Bot in Telegram eine Nachricht schicken, z. B.:
   - `Welche E-Mails habe ich heute?`
   - `Zeig mir meinen Kalender für morgen`
   - `Erstelle eine neue Aufgabe: Milch kaufen`
   - Sprachnachricht senden

## Öffentliche URL für Telegram (Produktion)

Telegram kann `localhost` nicht erreichen. Optionen:

| Variante | Hinweis |
| --- | --- |
| **VPS + Domain** | n8n hinter Nginx/Caddy mit HTTPS |
| **n8n Cloud** | Workflow importieren, WEBHOOK_URL ist vorkonfiguriert |
| **Tunnel** | z. B. `ngrok http 5678` → `WEBHOOK_URL` in `.env` setzen |

Nach Änderung von `WEBHOOK_URL` n8n neu starten und Workflow erneut aktivieren.

## Dateien

| Datei | Beschreibung |
| --- | --- |
| `workflow.json` | Vollständiger n8n-Workflow zum Import |
| `docker-compose.yml` | Lokale n8n-Instanz |
| `.env.example` | Umgebungsvariablen-Vorlage |
| `import-workflow.sh` | CLI-Import (Docker oder lokales n8n) |
| `start.sh` | n8n lokal starten (npm) |
| `setup-all.sh` | Komplettes Setup (n8n + Workflow + Tunnel + Owner) |
| `setup-tunnel.sh` | Cloudflare-Tunnel für Telegram-Webhooks |
| `setup-credentials.py` | API-Keys aus `credentials.env` verbinden |
| `credentials.env.example` | Vorlage für Telegram/OpenRouter/OpenAI Keys |

## Video-Tutorial

[YouTube: Workflow Setup](https://youtu.be/ROgf5dVqYPQ)

## Fehlerbehebung

- **Bot antwortet nicht:** Workflow aktiv? `WEBHOOK_URL` öffentlich und HTTPS? Bot mit `/start` angeschrieben?
- **Google OAuth schlägt fehl:** Redirect-URI exakt wie in n8n; Testnutzer in Cloud Console eingetragen.
- **Voice funktioniert nicht:** OpenAI-Credential und Guthaben prüfen.
- **Markdown-Fehler in Telegram:** Antwort enthält ungültiges Markdown → im Node **Telegram** ggf. `parse_mode` auf `HTML` stellen.
