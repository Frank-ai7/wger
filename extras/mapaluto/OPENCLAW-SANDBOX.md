# OpenClaw + Ubuntu-Sandbox (Chrome) – Netzwerk-Lösung

## Problem

Heim-/Firmen-Netze blockieren oft ausgehend **Port 8080** und **8765**. Direkte IP:Port-URLs scheitern → Timeout, obwohl die Dienste auf dem Server laufen.

**Sicherheitslücke:** Dienste auf 8080/8765 öffentlich erreichbar statt nur über HTTPS + Cloudflare Access.

## Lösung: `app.mapaluto.de` (HTTPS, Port 443)

| Dienst | Unsicher (schließen) | Sicher (nutzen) |
|---|---|---|
| Tom's Mal App | `:8080` direkt | `https://app.mapaluto.de/toms-mal-app/` |
| Festung / PDF | `:8765` direkt | `https://app.mapaluto.de/festung/` |
| OpenClaw Agent | — | `https://mapaluto.de/agent` |

## 502 auf `https://app.mapaluto.de/` beheben (Server)

Ursache: Kein Backend für `/` — nur Unterpfade konfiguriert.

**Einmal auf dem Hetzner deployen:**

```bash
cd /pfad/zum/wger
sudo bash extras/mapaluto/DEPLOY-HETZNER.sh
sudo bash extras/mapaluto/secure-firewall.sh
sudo systemctl restart cloudflared   # falls Cloudflare Tunnel
```

Danach lokal testen:

```bash
curl -s -o /dev/null -w "%{http_code}\n" http://127.0.0.1:8081/
curl -s -o /dev/null -w "%{http_code}\n" http://127.0.0.1:8080/
curl -s -o /dev/null -w "%{http_code}\n" http://127.0.0.1:8765/
```

Erwartung: **8081 → 200**, 8080/8765 → 200 oder 302.

Cloudflare Tunnel: Ingress auf `http://127.0.0.1:8081` — siehe `cloudflared-app-ingress.snippet.yml`.

## OpenClaw konfigurieren

Alle Browser-/Fetch-URLs ersetzen — **kein** `localhost:8080`, **keine** direkten `:8765`-Links mehr:

```json
{
  "browser": {
    "allowedOrigins": [
      "https://app.mapaluto.de",
      "https://mapaluto.de"
    ]
  },
  "services": {
    "tomsMalApp": "https://app.mapaluto.de/toms-mal-app/",
    "festung": "https://app.mapaluto.de/festung/",
    "openclawAgent": "https://mapaluto.de/agent"
  }
}
```

## Ubuntu-Sandbox (Cursor Cloud Desktop)

1. **Cloud Desktop** öffnen.
2. Einmalig bei **Cloudflare Access** anmelden (`app.mapaluto.de`, `mapaluto.de/agent`).
3. OpenClaw nutzt danach HTTPS-URLs über Port 443.

## Copy-Paste für OpenClaw (Server-Deploy)

```
Führe auf dem Hetzner-Server aus dem wger-Repo aus:
1. sudo bash extras/mapaluto/DEPLOY-HETZNER.sh
2. sudo bash extras/mapaluto/secure-firewall.sh
3. cloudflared config: app.mapaluto.de → http://127.0.0.1:8081 (siehe cloudflared-app-ingress.snippet.yml)
4. sudo systemctl restart cloudflared nginx
5. Melde HTTP-Codes von curl auf 127.0.0.1:8081/, :8080/, :8765/
6. Ersetze in OpenClaw-Config alle :8080/:8765-URLs durch https://app.mapaluto.de/... Pfade
```
