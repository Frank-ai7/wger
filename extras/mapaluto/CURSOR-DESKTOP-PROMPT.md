# Prompt für Cursor Desktop – mapaluto.de Ubuntu-Button

Kopiere den Block unten **1:1** in Cursor Desktop (Chat oder Composer), nachdem du dein **mapaluto.de-Website-Projekt** geöffnet hast.

---

```
Aufgabe: Erweitere meine Website mapaluto.de um zwei gut sichtbare Start-Buttons:
„Ubuntu starten“ und „Kiloclaw starten“.

Kontext:
- mapaluto.de ist mein persönliches Portal (hinter Cloudflare Access).
- Ubuntu-Button: Cursor Cloud-Sandbox (Ubuntu-Desktop) – danach in Cursor „Cloud Desktop“.
- Kiloclaw-Button: startet OpenClaw unter https://mapaluto.de/agent (NICHT /kiloclaw)

Technische Anforderungen:
1. Zwei prominente Buttons auf der Startseite / im Hero-Bereich.
2. Ubuntu-Link:
   https://cursor.com/agents/bc-06981860-e00f-4262-a344-41c9d6c6fce1
   → target="_blank", rel="noopener noreferrer"
3. Kiloclaw-Link (konfigurierbar):
   https://mapaluto.de/agent
4. Optional: Cursor-Deeplink für Ubuntu:
   cursor://anysphere.cursor-deeplink/background-agent?bcId=bc-06981860-e00f-4262-a344-41c9d6c6fce1
5. URLs zentral in config.js (MAPALUTO_LINKS).
6. Design:
   - Ubuntu: Orange (#e95420)
   - Kiloclaw: Violett (#7c3aed)
   - Mobil-tauglich, passt zum bestehenden mapaluto.de-Stil

Vorgehen:
1. Finde zuerst die echte Startseite / das Dashboard in diesem Projekt (index, portal, dashboard o. ä.).
2. Baue den Button dort ein – minimaler, sauberer Diff.
3. Keine unnötigen Refactorings.
4. Zeige mir am Ende: geänderte Dateien, wo der Button sitzt, und wie ich deploye.

Referenz (falls im Repo vorhanden):
- extras/mapaluto/index.html
- extras/mapaluto/config.js
- extras/mapaluto/snippet-ubuntu-button.html

Akzeptanzkriterien:
- Beide Buttons im Hero sichtbar.
- Ubuntu öffnet Cursor-Agent in neuem Tab.
- Kiloclaw öffnet den konfigurierten Kiloclaw-Pfad.
- Seite auf Deutsch, URLs in config.js.
```
