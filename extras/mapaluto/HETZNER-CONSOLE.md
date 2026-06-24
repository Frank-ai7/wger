# Hetzner Web-Konsole — Ein-Klick-Fix

Von **hier (Cursor Cloud)** komme ich **nicht** auf deinen Hetzner.  
Du musst **einmal** die Hetzner-Konsole öffnen und **einen Befehl** einfügen.

## Schritt 1: Hetzner Konsole öffnen

1. https://console.hetzner.cloud  
2. Dein Projekt → deinen **Server** anklicken  
3. Oben **„Console“** (Browser-Terminal, kein SSH nötig)  
4. Als **root** einloggen  

## Schritt 2: Diesen Befehl einfügen (alles in einer Zeile)

```bash
curl -fsSL "https://raw.githubusercontent.com/Frank-ai7/wger/cursor/mapaluto-ubuntu-button-fce1/extras/mapaluto/INSTALL-ON-HETZNER.sh" | sudo bash
```

Das Script:

- richtet **app.mapaluto.de/** ein (kein 502/404 mehr auf Root)  
- richtet **mapaluto.de/agent** ein (OpenClaw-Proxy)  
- leitet **/kiloclaw → /agent** um  
- schließt Ports **8080/8765** nach außen  
- sucht automatisch den OpenClaw-Port (Docker)  

## Schritt 3: Cloudflare Tunnel neu starten

Wenn am Ende **cloudflared**-Hinweise erscheinen:

```bash
sudo systemctl restart cloudflared
```

## Schritt 4: Im Browser testen

- https://app.mapaluto.de/  
- https://mapaluto.de/agent  

(jeweils nach Cloudflare-Login)

## Wenn OpenClaw-Port falsch erkannt wurde

In der Konsole:

```bash
docker ps
export OPENCLAW_PORT=DEIN_PORT
curl -fsSL "https://raw.githubusercontent.com/Frank-ai7/wger/cursor/mapaluto-ubuntu-button-fce1/extras/mapaluto/INSTALL-ON-HETZNER.sh" | sudo -E bash
```

## Cursor Ubuntu-Sandbox (separat!)

Nicht auf Hetzner — eigener Link:

https://cursor.com/agents/bc-06981860-e00f-4262-a344-41c9d6c6fce1  

→ danach **Cloud Desktop** in Cursor.
