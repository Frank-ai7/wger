# 404 auf mapaluto.de — Schnellhilfe

## Richtige URLs (nach Cloudflare-Login)

| Ziel | Richtig | Falsch (→ 404) |
|---|---|---|
| **OpenClaw / Kiloclaw** | https://mapaluto.de/agent | `/kiloclaw`, `app.mapaluto.de/agent` |
| **Tom's Mal App** | https://app.mapaluto.de/toms-mal-app/ | `:8080` direkt |
| **Festung / PDF** | https://app.mapaluto.de/festung/ | `:8765` direkt |
| **Portal Start** | https://mapaluto.de/ | — |
| **app-Subdomain** | https://app.mapaluto.de/ | OpenClaw liegt **nicht** hier |

**Wichtig:** OpenClaw = **`mapaluto.de`**, nicht **`app.mapaluto.de`**.

---

## Wenn `https://mapaluto.de/agent` 404 zeigt

Der Pfad `/agent` ist auf dem Server **nicht eingerichtet** oder OpenClaw läuft nicht.

**Auf dem Hetzner prüfen:**

```bash
# Läuft OpenClaw?
docker ps | grep -i claw
ss -tlnp | grep -E '8080|8765|18789|3000'

# Antwortet /agent lokal?
curl -sI http://127.0.0.1:DEIN_OPENCLAW_PORT/ | head
```

**Fix:** In nginx oder Cloudflare Tunnel `/agent` auf den OpenClaw-Port proxen.
Vorlage: `nginx-mapaluto-agent.conf.example` (Port anpassen!).

**Redirect von /kiloclaw (optional):**

```nginx
location = /kiloclaw { return 301 /agent; }
```

---

## Wenn `https://app.mapaluto.de/` 404 zeigt

Deploy-Script ausführen:

```bash
sudo bash extras/mapaluto/DEPLOY-HETZNER.sh
sudo systemctl restart cloudflared
```

---

## Wenn du Cursor Ubuntu-Sandbox meinst (nicht OpenClaw)

Das ist **kein** mapaluto-Pfad, sondern:

https://cursor.com/agents/bc-06981860-e00f-4262-a344-41c9d6c6fce1

Danach in Cursor auf **Cloud Desktop** klicken.
