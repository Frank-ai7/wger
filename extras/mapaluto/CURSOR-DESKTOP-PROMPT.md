# Prompt für Cursor Desktop – mapaluto.de Ubuntu-Button

Kopiere den Block unten **1:1** in Cursor Desktop (Chat oder Composer), nachdem du dein **mapaluto.de-Website-Projekt** geöffnet hast.

---

```
Aufgabe: Erweitere meine Website mapaluto.de um einen gut sichtbaren Start-Button „Ubuntu starten“.

Kontext:
- mapaluto.de ist mein persönliches Portal (hinter Cloudflare Access).
- Der Button soll die Cursor Cloud-Sandbox (Ubuntu-Desktop) starten – nicht einen lokalen Rechner.
- Nach dem Klick öffnet sich der Cursor Cloud-Agent; dort wähle ich rechts „Cloud Desktop“ für den Ubuntu-Desktop.

Technische Anforderungen:
1. Füge einen prominenten Button „Ubuntu starten“ auf der Startseite / im Dashboard ein.
2. Link-Ziel (primär):
   https://cursor.com/agents/bc-06981860-e00f-4262-a344-41c9d6c6fce1
   → target="_blank", rel="noopener noreferrer"
3. Optional zweiter Link „In Cursor öffnen“ (deeplink):
   cursor://anysphere.cursor-deeplink/background-agent?bcId=bc-06981860-e00f-4262-a344-41c9d6c6fce1
4. Kurze Hilfe unter dem Button (3 Schritte):
   - Agent öffnet sich
   - In Cursor „Cloud Desktop“ klicken
   - Ubuntu-Desktop erscheint
5. Design:
   - Ubuntu-Orange (#e95420) als Button-Farbe
   - Modern, klar, mobil-tauglich
   - Passt zum bestehenden Stil von mapaluto.de (bestehende Klassen/Variablen nutzen, nicht alles neu erfinden)
6. Agent-ID zentral konfigurierbar machen (Konstante, Config oder data-Attribut), damit ich sie später leicht tauschen kann.

Vorgehen:
1. Finde zuerst die echte Startseite / das Dashboard in diesem Projekt (index, portal, dashboard o. ä.).
2. Baue den Button dort ein – minimaler, sauberer Diff.
3. Keine unnötigen Refactorings.
4. Zeige mir am Ende: geänderte Dateien, wo der Button sitzt, und wie ich deploye.

Referenz (falls im Repo vorhanden):
- extras/mapaluto/index.html (komplette Portal-Vorlage)
- extras/mapaluto/snippet-ubuntu-button.html (nur Button-Snippet)

Akzeptanzkriterien:
- Button ist auf der Startseite sichtbar ohne Scrollen (oder klar im Hero-Bereich).
- Klick öffnet den Cursor-Agent-Link in neuem Tab.
- Seite bleibt auf Deutsch.
- Keine Secrets/API-Keys hardcoden außer der öffentlichen Agent-URL.
```
