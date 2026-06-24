@echo off
chcp 65001 >nul
title mapaluto Diagnose
set OUT=%USERPROFILE%\Desktop\mapaluto-diagnose.txt

echo mapaluto Diagnose > "%OUT%"
echo Datum: %DATE% %TIME% >> "%OUT%"
echo. >> "%OUT%"

echo === WO BIST DU? === >> "%OUT%"
echo Dieses Fenster laeuft auf: %COMPUTERNAME% >> "%OUT%"
echo. >> "%OUT%"

echo === DOCKER === >> "%OUT%"
docker ps 2>>"%OUT%" >>"%OUT%"
if errorlevel 1 echo Docker nicht gefunden oder nicht gestartet. >> "%OUT%"
echo. >> "%OUT%"

echo === OFFENE PORTS (Windows) === >> "%OUT%"
netstat -ano | findstr LISTENING >> "%OUT%"
echo. >> "%OUT%"

echo === DIENSTE (cloudflared / Caddy) === >> "%OUT%"
sc query cloudflared 2>>"%OUT%" >>"%OUT%"
sc query caddy 2>>"%OUT%" >>"%OUT%"
echo Hinweis: Caddy laeuft oft in WSL — dann check-mapaluto.sh in WSL nutzen. >> "%OUT%"
echo. >> "%OUT%"

echo === LOKALE TESTS === >> "%OUT%"
curl -sI -m 3 http://127.0.0.1/ 2>>"%OUT%" >>"%OUT%"
curl -sI -m 3 http://127.0.0.1:8080/ 2>>"%OUT%" >>"%OUT%"
curl -sI -m 3 http://127.0.0.1:18789/ 2>>"%OUT%" >>"%OUT%"
echo. >> "%OUT%"

echo Fertig. Ergebnis: %OUT%
notepad "%OUT%"
pause
