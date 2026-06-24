# OpenClaw + Ubuntu-Sandbox (Chrome) – Netzwerk-Lösung

## Problem

Dein **Heim-/Firmen-Netz** blockiert ausgehend **Port 8080** und **8765** zum Hetzner-Server `195.201.129.16`.

OpenClaw testet dann z. B. `http://195.201.129.16:8080` → **Timeout/Fehler**, obwohl der Server intern läuft.

## Beste Lösung: `app.mapaluto.de` Proxy (HTTPS, Port 443)

Statt direkter Ports diese URLs nutzen:

| Dienst | Alt (blockiert) | Neu (HTTPS) |
|---|---|---|
| Tom's Mal App | `:8080` | `https://app.mapaluto.de/toms-mal-app/` |
| Festung / PDF | `:8765` | `https://app.mapaluto.de/festung/` |
| OpenClaw Agent | — | `https://mapaluto.de/agent` |

Die Pfade existieren bereits bei Cloudflare – nach Login erreichbar.

**Wichtig:** `https://app.mapaluto.de/` (Root `/`) braucht eine eigene nginx-Regel. Ohne `location = /` kommt **502 Bad Gateway** nach dem Cloudflare-Login. Nutze direkt `/toms-mal-app/` oder `/festung/`, oder setze die Root-Regel aus `nginx-app-proxy.conf`.

## OpenClaw konfigurieren

In der OpenClaw-Konfiguration (Browser-/Fetch-URLs) **alle** Verweise ersetzen:

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

Kein `localhost:8080`, kein `195.201.129.16:8765` mehr.

## Ubuntu-Sandbox (Cursor Cloud Desktop)

So nutzt OpenClaw Chrome in der Sandbox:

1. **Cloud Desktop** in Cursor öffnen (Ubuntu + Chrome).
2. Einmalig bei **Cloudflare Access** anmelden:
   - `https://app.mapaluto.de`
   - `https://mapaluto.de/agent`
3. Danach kann OpenClaw/Browser-Tools die HTTPS-URLs aufrufen – **Port 443**, nicht blockiert.

Chrome in der Sandbox hat **kein** Tailscale und **keinen** SSH-Tunnel zu deinem PC – deshalb **nur HTTPS über app.mapaluto.de**.

## Server: Proxy prüfen (Hetzner SSH)

Auf dem Server muss nginx (oder Cloudflare Tunnel) weiterleiten:

```nginx
# /etc/nginx/sites-available/app.mapaluto.de (Auszug)
location /toms-mal-app/ {
    proxy_pass http://127.0.0.1:8080/;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
}

location /festung/ {
    proxy_pass http://127.0.0.1:8765/;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
}
```

Test auf dem Server:

```bash
curl -s -o /dev/null -w "%{http_code}\n" http://127.0.0.1:8080/
curl -s -o /dev/null -w "%{http_code}\n" http://127.0.0.1:8765/
```

## Alternative Wege (nur für deinen PC, nicht Sandbox)

| Weg | Für Sandbox? | Hinweis |
|---|---|---|
| **app.mapaluto.de Proxy** | ✅ Ja | Empfohlen |
| **SSH-Tunnel** | ❌ Nein | Nur lokal: `ssh -L 8080:localhost:8080 -L 8765:localhost:8765 user@195.201.129.16` |
| **Tailscale** `100.113.103.97` | ❌ Nein* | Sandbox ist nicht in deinem Tailnet |
| **Webchat-Embeds** | ✅ Teilweise | Wenn als iframe auf mapaluto.de eingebettet |

\* Tailscale funktioniert nur, wenn der Ubuntu-Sandbox-Rechner auch im Tailnet ist (bei Cursor Cloud Agent normalerweise nicht).

## Kurz-Antwort

**Ja, du kannst etwas machen:** OpenClaw auf **`https://app.mapaluto.de/toms-mal-app/`** und **`/festung/`** umstellen, einmal in der Sandbox-Chrome bei Cloudflare einloggen – dann funktioniert der Browser-Zugriff ohne blockierte Ports.
