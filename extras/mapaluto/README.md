# mapaluto.de – Ubuntu Startbutton

Dieses Paket erweitert die mapaluto.de-Seite um einen **Ubuntu starten**-Button für die Cursor Cloud-Sandbox.

## Dateien

| Datei | Zweck |
| --- | --- |
| `index.html` | Komplette Portal-Startseite mit Ubuntu-Button |
| `snippet-ubuntu-button.html` | Nur der Button zum Einfügen in eine bestehende Seite |

## Deployment auf mapaluto.de

Die Live-Seite liegt hinter **Cloudflare Access**. Dieses Repo enthält nur die HTML-Dateien – du musst sie auf deinen Webserver/Cloudflare Pages hochladen.

### Option A: Komplette Startseite ersetzen

1. `index.html` auf deinen Server kopieren (z. B. als `/index.html` hinter Cloudflare Access).
2. In Cloudflare Pages / nginx / deinem Hosting deployen.

### Option B: Button in bestehende Seite einfügen

Den Inhalt aus `snippet-ubuntu-button.html` in deine vorhandene HTML-Seite kopieren.

## Agent-ID ändern

In beiden Dateien diese URL anpassen:

```text
https://cursor.com/agents/bc-06981860-e00f-4262-a344-41c9d6c6fce1
```

Neue Agent-ID einsetzen, wenn du einen anderen Cloud-Agent nutzt.

## Hinweis

Der Button öffnet den **Cursor Agent**. Den Ubuntu-Desktop startest du danach in Cursor über **Cloud Desktop** (rechts im Panel).
