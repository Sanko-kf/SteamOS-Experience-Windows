@echo off
title Steam Experience Shell
color 0B

:: =========================================================
:: 1. AUTO-ELEVATION (ADMIN PRIVILEGES)
:: =========================================================
:: Validates elevated permissions and re-launches as Admin if necessary
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    exit /B
)
if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )

:: =========================================================
:: 2. REGISTRY PERSISTENCE (SHELL REPLACEMENT)
:: =========================================================
:: Replaces the default Windows Explorer shell with Steam in Big Picture mode
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v Shell /t REG_SZ /d "\"C:\Program Files (x86)\Steam\steam.exe\" -bigpicture" /f >nul

:: =========================================================
:: 3. TERMINATE WINDOWS EXPLORER
:: =========================================================
:: Forcefully closes the taskbar and desktop to free up system resources
taskkill /F /IM explorer.exe >nul 2>&1

:: =========================================================
:: 4. STEAM EXECUTION
:: =========================================================
:: Checks if Steam is already running to determine the launch method
tasklist /FI "IMAGENAME eq steam.exe" 2>NUL | find /I /N "steam.exe">NUL

start "" "steam://open/bigpicture"

exit