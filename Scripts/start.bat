@echo off
title Steam Experience Startup
color 0B

:: =========================================================
:: 0. INVISIBILITY TRICK
:: =========================================================
:: Re-launch the script in hidden mode using PowerShell
if "%1"=="hide" goto :main
echo [DEBUG] Restart script in silent mode
powershell -WindowStyle Hidden -Command "Start-Process '%~0' -ArgumentList 'hide' -WindowStyle Hidden"
exit

:main

:: =========================================================
:: 1. STARTUP DELAY (15 Seconds)
:: =========================================================
:: Allows system services and drivers to initialize before launching tools
timeout /t 15 /nobreak >nul

:: =========================================================
:: 2. LAUNCH MONITORING UTILITIES & TOOLS (C:\Scripts)
:: =========================================================
:: Background monitoring tools for sleep mode and desktop recovery
start "" "C:\Scripts\sleep_mode_detector.exe"
start "" "C:\Scripts\desktop_detector.exe"

:: AutoHideMouseCursor - Running in background mode (-bg)
start "" "C:\Scripts\AutoHideMouseCursor_x64.exe" -bg

:: =========================================================
:: 3. LAUNCH CSS LOADER
:: =========================================================
:: Applies visual themes for the Steam Deck-like interface
set "CSSPath=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\CssLoader-Standalone-Headless.exe"

if exist "%CSSPath%" (
    start "" "%CSSPath%"
)

:: =========================================================
:: 4. LAUNCH & MINIMIZE LOSSLESS SCALING
:: =========================================================
set "LosslessPath=C:\Program Files (x86)\Steam\steamapps\common\Lossless Scaling\LosslessScaling.exe"

if exist "%LosslessPath%" (
    :: 1. Initial application launch
    start "" "%LosslessPath%" -StartMinimized
    
    :: 2. Wait for the window to initialize (5 sec)
    timeout /t 5 /nobreak >nul
    
    :: 3. Force minimize to system tray via PowerShell (State 6 = MINIMIZE)
    powershell -command "$d='[DllImport(\"user32.dll\")] public static extern bool ShowWindow(int h, int s);';$t=Add-Type -MemberDefinition $d -Name W -PassThru;$p=Get-Process LosslessScaling -ErrorAction SilentlyContinue;if($p){$t::ShowWindow($p.MainWindowHandle, 6)}"
)

exit