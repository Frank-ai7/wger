@echo off
chcp 65001 >nul
title mapaluto Diagnose + Auto-Start
set OUT=%USERPROFILE%\Desktop\mapaluto-diagnose.txt

echo mapaluto Diagnose > "%OUT%"
echo Datum: %DATE% %TIME% >> "%OUT%"
echo. >> "%OUT%"

echo === WO BIST DU? === >> "%OUT%"
echo Dieses Fenster laeuft auf: %COMPUTERNAME% >> "%OUT%"
echo. >> "%OUT%"

echo === AUTO-START (Docker Desktop) === >> "%OUT%"
tasklist /FI "IMAGENAME eq Docker Desktop.exe" 2>NUL | find /I "Docker Desktop.exe" >NUL
if errorlevel 1 (
  echo Docker Desktop nicht aktiv — starte... >> "%OUT%"
  start "" "C:\Program Files\Docker\Docker\Docker Desktop.exe" 2>>"%OUT%"
  timeout /t 25 /nobreak >nul
) else (
  echo Docker Desktop laeuft bereits. >> "%OUT%"
)
echo. >> "%OUT%"

echo === DOCKER === >> "%OUT%"
docker ps 2>>"%OUT%" >>"%OUT%"
if errorlevel 1 (
  echo Docker nicht bereit — bitte Docker Desktop Icon unten rechts pruefen. >> "%OUT%"
) else (
  for /f %%i in ('docker ps -q 2^>nul') do set HAS=1
  if not defined HAS (
    echo Keine laufenden Container — versuche alle zu starten... >> "%OUT%"
    for /f %%c in ('docker ps -aq 2^>nul') do docker start %%c 2>>"%OUT%" >>"%OUT%"
  )
)
echo. >> "%OUT%"

echo === OFFENE PORTS (Windows) === >> "%OUT%"
netstat -ano | findstr LISTENING >> "%OUT%"
echo. >> "%OUT%"

echo === DIENSTE (cloudflared / Caddy) === >> "%OUT%"
sc query cloudflared 2>>"%OUT%" >>"%OUT%"
sc query caddy 2>>"%OUT%" >>"%OUT%"
sc query cloudflared | find "RUNNING" >nul
if errorlevel 1 (
  echo cloudflared nicht RUNNING — versuche net start... >> "%OUT%"
  net start cloudflared 2>>"%OUT%" >>"%OUT%"
)
echo Hinweis: Caddy laeuft oft in WSL — dann check-mapaluto.sh in WSL nutzen. >> "%OUT%"
echo. >> "%OUT%"

echo === LOKALE TESTS === >> "%OUT%"
curl -sI -m 3 http://127.0.0.1/ 2>>"%OUT%" >>"%OUT%"
curl -sI -m 3 http://127.0.0.1:8080/ 2>>"%OUT%" >>"%OUT%"
curl -sI -m 3 http://127.0.0.1:8765/ 2>>"%OUT%" >>"%OUT%"
curl -sI -m 3 http://127.0.0.1:18789/ 2>>"%OUT%" >>"%OUT%"
echo. >> "%OUT%"

echo === NAECHSTER SCHRITT === >> "%OUT%"
echo 1. Diese Datei in Cursor Chat posten >> "%OUT%"
echo 2. Browser: https://mapaluto.de/agent und https://app.mapaluto.de/ testen >> "%OUT%"
echo 3. Wenn 8080 DOWN: OpenClaw docker compose manuell starten >> "%OUT%"
echo. >> "%OUT%"

echo Fertig. Ergebnis: %OUT%
notepad "%OUT%"
pause
