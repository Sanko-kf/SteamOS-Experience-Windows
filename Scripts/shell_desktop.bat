@echo off
title Restore Windows Desktop
color 0B

:: Re-launch the script in hidden mode using PowerShell
if "%1"=="hide" goto :main
echo [DEBUG] Relancement du script en mode caché via PowerShell...
powershell -WindowStyle Hidden -Command "Start-Process '%~0' -ArgumentList 'hide' -WindowStyle Hidden"
exit

:main

:: =========================================================
:: 1. REGISTRY RESTORATION
:: =========================================================
:: Resets the default Windows Shell to explorer.exe
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v Shell /t REG_SZ /d "explorer.exe" /f >nul

:: =========================================================
:: 2. PROCESS CLEANUP
:: =========================================================
:: Terminate any lingering explorer processes to ensure a fresh start
taskkill /F /IM explorer.exe >nul 2>&1

:: =========================================================
:: 3. DESKTOP RELAUNCH
:: =========================================================
:: Triggers the scheduled task to restart the Windows Desktop environment
schtasks /run /tn "RestoreExplorer"

:: =========================================================
:: 4. BACKGROUND STEAM RELAUNCH
:: =========================================================
:: Restarts Steam in silent mode after a short delay
timeout /t 4 /nobreak >nul
start "" "C:\Program Files (x86)\Steam\steam.exe" -silent

:: =========================================================
:: 5. KIOSK TOOLS CLEANUP
:: =========================================================
:: Wait for the transition to complete, then terminate Kiosk-specific utilities
timeout /t 10 /nobreak >nul

:: Stop the mouse auto-hide tool to restore normal cursor behavior on desktop
tasklist /FI "IMAGENAME eq AutoHideMouseCursor_x64.exe" 2>NUL | find /I /N "AutoHideMouseCursor_x64.exe">NUL
if "%ERRORLEVEL%"=="0" (
    taskkill /F /IM "AutoHideMouseCursor_x64.exe" >nul 2>&1
)

exit