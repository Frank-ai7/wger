@echo off
setlocal EnableExtensions
REM OpenClaw Gateway auf dem Sandbox-VPS reparieren und starten
REM Anpassen: SANDBOX_HOST, SANDBOX_USER, SSH_KEY

set "SANDBOX_HOST=IHRE-SANDBOX-IP"
set "SANDBOX_USER=root"
set "SSH_KEY=%USERPROFILE%\.ssh\id_rsa"
set "SCRIPT=/tmp/fix-openclaw-gateway.sh"

echo === OpenClaw Gateway Reparatur (Remote) ===
echo Host: %SANDBOX_USER%@%SANDBOX_HOST%
echo.

if "%SANDBOX_HOST%"=="IHRE-SANDBOX-IP" (
  echo FEHLER: Bitte SANDBOX_HOST in dieser BAT-Datei eintragen.
  exit /b 1
)

REM Skript auf Server kopieren und ausfuehren
scp -i "%SSH_KEY%" "%~dp0fix-openclaw-gateway.sh" "%SANDBOX_USER%@%SANDBOX_HOST%:%SCRIPT%"
if errorlevel 1 (
  echo FEHLER: SCP fehlgeschlagen. SSH-Key und Host pruefen.
  exit /b 1
)

ssh -i "%SSH_KEY%" "%SANDBOX_USER%@%SANDBOX_HOST%" "chmod +x %SCRIPT% && bash %SCRIPT%"
if errorlevel 1 (
  echo FEHLER: Remote-Reparatur fehlgeschlagen.
  exit /b 1
)

echo.
echo === Gateway auf Server repariert ===
echo.
echo WICHTIG: OpenClaw laeuft auf dem VPS unter 127.0.0.1:18789
echo Von Ihrem PC aus oeffnen Sie es NUR mit SSH-Tunnel:
echo   ssh -N -L 18789:127.0.0.1:18789 %SANDBOX_USER%@%SANDBOX_HOST%
echo Dann Browser: http://127.0.0.1:18789/chat
echo.
echo Oder Kachel "OpenClaw Extern (CLOUDFLARE)" wenn Tunnel eingerichtet.
pause
