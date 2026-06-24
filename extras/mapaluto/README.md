# mapaluto.de – Startbuttons (Ubuntu + Kiloclaw)

Portal-Vorlage für mapaluto.de mit zwei Start-Buttons:

- **Ubuntu starten** → Cursor Cloud-Agent (danach „Cloud Desktop“)
- **Kiloclaw starten** → Kiloclaw-Dienst (URL in `config.js`)

## Dateien

| Datei | Zweck |
| --- | --- |
| `index.html` | Komplette Portal-Startseite |
| `config.js` | Zentrale URLs (Ubuntu, Kiloclaw, Cursor-Deeplink) |
| `snippet-ubuntu-button.html` | Beide Buttons zum Einfügen in bestehende Seiten |
| `CURSOR-DESKTOP-PROMPT.md` | Copy-Paste-Prompt für Cursor Desktop |

## URLs anpassen

In `config.js`:

```javascript
window.MAPALUTO_LINKS = {
  ubuntuAgentUrl: "https://cursor.com/agents/bc-...",
  ubuntuCursorDeeplink: "cursor://anysphere.cursor-deeplink/background-agent?bcId=bc-...",
  kiloclawUrl: "https://mapaluto.de/kiloclaw",  // hier anpassen
};
```

## Deployment

1. `index.html`, `config.js` und ggf. Assets auf den Webserver hochladen.
2. Seite liegt hinter **Cloudflare Access** – nach Login sind die Buttons sichtbar.
3. Kiloclaw-URL prüfen: Standard ist `/kiloclaw` auf mapaluto.de.

## Hinweis Ubuntu

Der Ubuntu-Button öffnet den Cursor Agent. Den Desktop startest du in Cursor über **Cloud Desktop** (rechts im Panel).
