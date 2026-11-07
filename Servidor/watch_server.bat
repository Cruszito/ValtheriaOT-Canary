@echo off
setlocal EnableDelayedExpansion
title Endless - Watchdog Canary
cd /d "%~dp0"

set "SERVER_EXE=canary.exe"

if not exist "logs" mkdir "logs"

:loop
tasklist /NH /FI "IMAGENAME eq %SERVER_EXE%" | find /I "%SERVER_EXE%" >nul

if errorlevel 1 (
    for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format yyyy-MM-dd_HH-mm-ss"') do set "TS=%%i"

    set "SERVER_LOG=logs\server_!TS!.log"

    echo [%date% %time%] Servidor cerrado. Iniciando %SERVER_EXE%...
    echo [%date% %time%] Servidor cerrado. Iniciando %SERVER_EXE%... >> "logs\watchdog.log"
    echo [%date% %time%] Log del servidor: !SERVER_LOG! >> "logs\watchdog.log"

    start "Canary Server" /D "%~dp0" powershell -NoProfile -ExecutionPolicy Bypass -Command "& { .\%SERVER_EXE% 2>&1 | Tee-Object -FilePath '!SERVER_LOG!' -Append }"
)

timeout /t 60 /nobreak >nul
goto loop