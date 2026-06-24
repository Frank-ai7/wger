@echo off
chcp 65001 >nul
title mapaluto Diagnose — auf Desktop laden
set ZIEL=%USERPROFILE%\Desktop\CHECK-MAPALUTO.bat
set URL=https://raw.githubusercontent.com/Frank-ai7/wger/cursor/mapaluto-ubuntu-button-fce1/extras/mapaluto/CHECK-MAPALUTO.bat

echo Lade CHECK-MAPALUTO.bat auf den Desktop...
curl -fsSL "%URL%" -o "%ZIEL%"
if errorlevel 1 (
  echo curl fehlgeschlagen — versuche PowerShell...
  powershell -NoProfile -Command "Invoke-WebRequest -Uri '%URL%' -OutFile '%ZIEL%'"
)
if exist "%ZIEL%" (
  echo OK: %ZIEL%
  echo Starte Diagnose...
  start "" "%ZIEL%"
) else (
  echo FEHLER: Download nicht gelaufen.
  pause
)
