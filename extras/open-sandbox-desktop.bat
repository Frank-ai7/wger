@echo off
chcp 65001 >nul
setlocal

set "AGENT_ID=bc-06981860-e00f-4262-a344-41c9d6c6fce1"
set "WEB_URL=https://cursor.com/agents/%AGENT_ID%"
set "APP_URL=cursor://anysphere.cursor-deeplink/background-agent?bcId=%AGENT_ID%"

echo.
echo ============================================================
echo   Cursor Sandbox (Ubuntu) oeffnen
echo ============================================================
echo.
echo WICHTIG:
echo   Eine .bat-Datei kann den Desktop NICHT direkt oeffnen.
echo   Der Zugriff laeuft nur ueber Cursor (Sicherheits-Sandbox).
echo.
echo Diese Datei macht Folgendes:
echo   1. Oeffnet deinen Cloud-Agent im Browser
echo   2. Versucht zusaetzlich die Cursor Desktop-App zu oeffnen
echo.
echo Danach in Cursor den Desktop starten:
echo   - Im Browser: Agent oeffnen ^> rechts "Cloud Desktop"
echo   - In der Desktop-App: Agent oeffnen ^> "Open Virtual Machine"
echo     (Dropdown im Agent-Hauptfenster)
echo.
echo ============================================================
echo.

echo [1/2] Oeffne Agent im Browser...
start "" "%WEB_URL%"

timeout /t 2 /nobreak >nul

echo [2/2] Oeffne Agent in der Cursor Desktop-App (falls installiert)...
start "" "%APP_URL%"

echo.
echo Fertig.
echo.
echo Wenn kein Desktop erscheint:
echo   - In Cursor anmelden (gleicher Account wie der Agent)
echo   - Agent-Session oeffnen und "Cloud Desktop" klicken
echo   - Cursor Desktop-App aktualisieren (neuere Version noetig)
echo.
pause
