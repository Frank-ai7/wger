# mapaluto.de Dashboard – Deploy-Anleitung

## Enthaltene Buttons

| Karte | Bereich | Link |
|---|---|---|
| **Ubuntu starten** | Sandkasten | Cursor Cloud-Agent |
| **Kiloclaw starten** | Sandkasten | `/agent` (OpenClaw) |

## Auf mapaluto.de deployen

Kopiere diese 2 Dateien auf deinen Webserver (Cloudflare Pages / Tunnel):

```text
extras/mapaluto/index.html   →  /index.html  (oder dein Dashboard-Pfad)
extras/mapaluto/config.js    →  /config.js
```

**Wichtig:** Beide Dateien müssen im **gleichen Ordner** liegen.

## URLs anpassen

In `config.js`:

```javascript
kiloclawUrl: "/agent",  // Kiloclaw / OpenClaw
ubuntuAgentUrl: "https://cursor.com/agents/bc-...",  // Cursor Agent
```

Einzelne Karten-URLs in `MAPALUTO_CARDS` in derselben Datei.

## Hinweis

Falls du bereits ein anderes Dashboard hast: Nur die **Sandkasten**-Karten aus `config.js` (`MAPALUTO_CARDS`) in deine bestehende Config übernehmen – oder die komplette `index.html` ersetzen.
