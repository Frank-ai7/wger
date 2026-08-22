# Mapaluto Sandbox – OpenClaw Reparatur

## Problem

`ERR_CONNECTION_REFUSED` auf `http://127.0.0.1:18789` bedeutet:

1. **OpenClaw Gateway laeuft nicht** auf dem VPS, oder
2. Sie oeffnen `127.0.0.1` auf **Ihrem PC**, obwohl OpenClaw nur auf dem **Server** laeuft (SSH-Tunnel fehlt).

## Schnellfix auf dem Server (SSH einloggen)

```bash
curl -fsSL -o /tmp/fix-openclaw-gateway.sh \
  https://raw.githubusercontent.com/frank-ai7/wger/master/extras/mapaluto-tools/fix-openclaw-gateway.sh
bash /tmp/fix-openclaw-gateway.sh
```

Oder Dateien aus diesem Ordner per `scp` kopieren.

## Von Windows (Toolsammlung)

1. `SANDBOX_HOST` in `SANDBOX_OPENCLAW_GATEWAY_REPARIEREN.bat` eintragen
2. BAT ausfuehren oder in TOOLS.html verlinken
3. Danach SSH-Tunnel oder Cloudflare-URL nutzen

## Nach der Reparatur testen

**Auf dem Server:**

```bash
curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:18789/
# Erwartung: 200 oder 302
```

**Auf Ihrem PC (Tunnel-Fenster offen lassen):**

```
http://127.0.0.1:18789/chat
```
