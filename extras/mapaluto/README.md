# mapaluto.de – Ubuntu + Kiloclaw Buttons

## Warum auf mapaluto.de noch nichts sichtbar ist

Die Dateien hier liegen im **wger-Repo** unter `extras/mapaluto/`.
Deine echte Dashboard-Seite (Hetzner Apps, Sandkasten, Khoj, …) ist ein **anderes Projekt** und wurde bisher **nicht geändert**.

Du musst die Karten in **deinem mapaluto.de-Website-Ordner** einfügen und deployen.

## Kiloclaw-URL

`https://mapaluto.de/kiloclaw` funktioniert **nicht** – diese Route gibt es nicht.

Auf deinem Dashboard existiert bereits unter **Sandkasten**:

- **Agent** → OpenClaw → vermutlich `/agent`

**Kiloclaw starten** verlinkt deshalb standardmäßig auf **`/agent`** (gleiche OpenClaw-Route).
Falls Kiloclaw woanders läuft, URL in `config.js` anpassen.

## So einbauen (Cursor Desktop)

1. In Cursor Desktop dein **mapaluto.de-Projekt** öffnen (nicht wger).
2. Die Datei finden, in der die Karten definiert sind (z. B. `index.html`, `dashboard.json`, `services.yaml`).
3. Zwei neue Karten in **Sandkasten** einfügen – siehe `dashboard-cards-patch.json`.
4. Deployen (Cloudflare Pages / Tunnel / nginx).

## Ubuntu-Button

- URL: `https://cursor.com/agents/bc-06981860-e00f-4262-a344-41c9d6c6fce1`
- Danach in Cursor: **Cloud Desktop** klicken

## Hilfe

Wenn du mir den **Pfad zur Dashboard-Datei** schickst (z. B. `index.html` oder `config.json` aus deinem mapaluto-Projekt), kann ich die Karten exakt im richtigen Format einbauen.
