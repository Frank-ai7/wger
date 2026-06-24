# Wo gebe ich die Befehle ein?

## Kurzantwort

**Auf dem Rechner, der mapaluto/OpenClaw betreibt** — also dein **Heim-PC** mit Docker/Caddy (IP **178.105.175.183**).

**Nicht** in Cursor Cloud, **nicht** in Hetzner Cloud (0 Server), **nicht** im Browser.

---

## Einfachste Methode (Windows) — Doppelklick

1. Datei **`CHECK-MAPALUTO.bat`** auf den **Heim-PC** kopieren  
   (aus dem Repo: `extras/mapaluto/CHECK-MAPALUTO.bat`)
2. **Doppelklick**
3. Notepad öffnet **`mapaluto-diagnose.txt`** auf dem Desktop  
4. Inhalt hier posten oder selbst lesen

Download-Link (Raw):

https://raw.githubusercontent.com/Frank-ai7/wger/cursor/mapaluto-ubuntu-button-fce1/extras/mapaluto/CHECK-MAPALUTO.bat

---

## Manuell — Windows

1. **Win + R** → `cmd` → Enter  
2. Befehle nacheinander:

```cmd
docker ps
netstat -ano | findstr LISTENING
sc query cloudflared
```

(`ss` und `systemctl` gibt es unter Windows **nicht** — nur in Linux/WSL.)

---

## Manuell — WSL oder Linux (Caddy/docker dort)

1. **WSL** oder **Terminal auf dem Linux-Rechner** öffnen  
2.:

```bash
docker ps
ss -tlnp | grep LISTEN
sudo systemctl status caddy cloudflared
```

Oder ein Script:

```bash
bash extras/mapaluto/check-mapaluto.sh
```

---

## Wo NICHT eingeben

| Ort | Warum nicht |
|---|---|
| Cursor Cloud Agent Chat | Kein Zugriff auf deinen PC |
| Hetzner Cloud Konsole | Kein Server dort |
| Browser-Adresszeile | Kein Terminal |
| mapaluto.de Website | Kein Terminal |

---

## Danach

Wenn `docker ps` **leer** ist → OpenClaw/Docker Desktop **starten**.  
Wenn **cloudflared inactive** → Tunnel **openclaw-sandbox** starten.  
Diagnose-Datei posten → nächster Fix-Schritt.
