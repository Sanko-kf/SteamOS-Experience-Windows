@echo off
setlocal EnableDelayedExpansion
title SteamOS Experience - Setup Wizard (NATIVE)
color 0F
chcp 65001 >nul
cd /d "%~dp0"

:: ============================================================================
:: 0. COLOR SETUP
:: ============================================================================
for /F %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
set "C_RESET=%ESC%[0m"
set "C_ACCENT=%ESC%[38;2;102;192;244m"
set "C_TEXT=%ESC%[38;2;199;213;224m"
set "C_GREEN=%ESC%[32m"
set "C_RED=%ESC%[31m"
set "C_YELLOW=%ESC%[33m"

:: ============================================================================
:: 1. ADMINISTRATOR PRIVILEGES CHECK
:: ============================================================================
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo.
    echo %C_RED%[ERROR] This script requires Administrator privileges.%C_RESET%
    pause
    exit
)

:MENU
cls
echo.
echo %C_ACCENT%    _____ __                        ____  _____ %C_RESET%
echo %C_ACCENT%   / ___// /____  ____ _____ ___    / __ \/ ___/ %C_RESET%
echo %C_ACCENT%   \__ \/ __/ _ \/ __ `/ __ `__ \ / / / /\__ \  %C_RESET%
echo %C_ACCENT%  ___/ / /_/  __/ /_/ / / / / / // /_/ /___/ /  %C_RESET%
echo %C_ACCENT% /____/\__/\___/\__,_/_/ /_/ /_(_)____//____/   %C_RESET%
echo.
echo    %C_TEXT%Please select an operation:%C_RESET%
echo.
echo    %C_ACCENT%[1]%C_RESET% INIT USER     %C_TEXT%(init_user.bat + Reboot)%C_RESET%
echo    %C_ACCENT%[2]%C_RESET% INSTALL SYS   %C_TEXT%(Full Deployment + Scripts Sequence)%C_RESET%
echo    %C_ACCENT%[3]%C_RESET% UPDATE        %C_TEXT%(Check for updates)%C_RESET%
echo    %C_ACCENT%[4]%C_RESET% UNINSTALL     %C_TEXT%(Restore Windows)%C_RESET%
echo    %C_ACCENT%[5]%C_RESET% EXIT%C_RESET%
echo.
set /p "CHOICE=    👉 Selection: "
if "%CHOICE%"=="1" goto INIT_USER
if "%CHOICE%"=="2" goto INSTALL_SYS
if "%CHOICE%"=="3" goto UPDATE
if "%CHOICE%"=="4" goto UNINSTALL
if "%CHOICE%"=="5" exit
goto MENU

:: ============================================================================
:: SECTION 1 : INIT USER
:: ============================================================================
:INIT_USER
cls
echo.
echo %C_ACCENT%[INIT USER CONFIGURATION]%C_RESET%
set "RawUrl=https://raw.githubusercontent.com/Sanko-kf/SteamOS-Experience/main/Installation/init_user.bat"
call :FAKELOADING "Downloading init_user.bat..."
curl -L -s -o "%TEMP%\init_user.bat" "%RawUrl%"
call :FAKELOADING "Executing..."
call "%TEMP%\init_user.bat"
echo %C_GREEN%✓ Done. Restarting in 10s...%C_RESET%
timeout /t 10
shutdown /r /t 0
exit

:: ============================================================================
:: SECTION 2 : INSTALL SYSTEM (FULL SEQUENCE)
:: ============================================================================
:INSTALL_SYS
cls
echo.
echo %C_ACCENT%[SYSTEM INSTALLATION - DOWNLOADING COMPONENTS]%C_RESET%
echo.

set "WorkDir=C:\SteamOS_Temp"
set "RepoZip=https://github.com/Sanko-kf/SteamOS-Experience/archive/refs/heads/main.zip"

:: 1. Preparation
if exist "%WorkDir%" rd /s /q "%WorkDir%"
mkdir "%WorkDir%"

:: 2. Download & Extract
call :FAKELOADING "Downloading Repository..."
curl -L -s -o "%WorkDir%\repo.zip" "%RepoZip%"
call :FAKELOADING "Extracting Components..."
powershell -Command "Expand-Archive -Path '%WorkDir%\repo.zip' -DestinationPath '%WorkDir%' -Force"

set "ExtractedFolder=%WorkDir%\SteamOS-Experience-main"
set "InstallPath=%ExtractedFolder%\Installation"

:: 3. Deploying Assets / Scripts
call :FAKELOADING "Deploying C:\Assets..."
if exist "C:\Assets" rd /s /q "C:\Assets"
xcopy "%ExtractedFolder%\Assets" "C:\Assets\" /E /I /H /Y >nul

call :FAKELOADING "Deploying C:\Scripts..."
if exist "C:\Scripts" rd /s /q "C:\Scripts"
xcopy "%ExtractedFolder%\Scripts" "C:\Scripts\" /E /I /H /Y >nul

:: 4. Build Tools (RAW URLs)
call :FAKELOADING "Downloading Tools..."
curl -L -s -o "C:\Scripts\desktop_detector.exe" "https://raw.githubusercontent.com/Sanko-kf/SteamOS-Experience/main/Builds/desktop_detector.exe"
curl -L -s -o "C:\Scripts\sleep_mode_detector.exe" "https://raw.githubusercontent.com/Sanko-kf/SteamOS-Experience/main/Builds/sleep_mode_detector.exe"

:: 5. INSTALLATION SEQUENCE (FORCED)
echo.
echo %C_YELLOW%[STARTING INSTALLATION SEQUENCE]%C_RESET%
echo.

set "ScriptsList=debloat.bat update_blocker.bat steam_installation.bat CSSLoader_installation.bat custom_sleep_mode.bat utilities_tweaks.bat schedule_task.bat theme.bat temp_remove.bat"

for %%G in (%ScriptsList%) do (
    if exist "%InstallPath%\%%G" (
        echo %C_ACCENT%[RUNNING] %%G%C_RESET%
        :: Using START /WAIT to completely isolate execution
        start /wait /d "%InstallPath%" cmd /c "call %%G"
        echo %C_GREEN%[FINISHED] %%G%C_RESET%
        echo ------------------------------------------
    ) else (
        echo %C_RED%[MISSING] %%G not found.%C_RESET%
    )
)

:: 6. Final cleanup and Video Download (Heavy file 4GB)
echo.
echo %C_YELLOW%[ACTION REQUIRED - LARGE FILE]%C_RESET%
echo %C_TEXT%The sleep mode video (4GB) requires a manual download.%C_RESET%
echo %C_TEXT%1. A browser window will open for the download.%C_RESET%
echo %C_TEXT%2. The destination folder will also open.%C_RESET%
echo %C_TEXT%3. Move the file into this folder once finished.%C_RESET%
echo.
pause

:: Create and open destination folder
set "VideoDest=%USERPROFILE%\Videos\SleepVideos"
if not exist "%VideoDest%" mkdir "%VideoDest%"
start "" "%VideoDest%"

:: Open link (Replace with your real link)
set "BigVideoURL=https://drive.google.com/file/d/1G3u-DCPymFIjMztuKyWxvHCWtoNvd79G/view?usp=sharing"
start "" "%BigVideoURL%"

echo.
echo %C_ACCENT%Waiting for file transfer...%C_RESET%
echo %C_TEXT%(You may continue even if the download is still in progress)%C_RESET%
pause

:: ============================================================================
:: SECTION : CONFIGURATION VLC & SLEEP
:: ============================================================================
cls
echo.
echo %C_ACCENT%[SLEEP MODE CONFIGURATION]%C_RESET%
echo.
if exist "%VideoDest%\screensaver.mkv" (
    echo %C_TEXT%Launching VLC for verification...%C_RESET%
    start "" vlc "%VideoDest%\screensaver.mkv"
) else (
    echo %C_RED%[INFO] screensaver.mkv not found, launching VLC alone...%C_RESET%
    start "" vlc
)

echo.
echo %C_YELLOW%⚠️ IMPORTANT INSTRUCTIONS:%C_RESET%
echo %C_TEXT%1. Adjust VLC volume to your preference.%C_RESET%
echo %C_TEXT%2. Ensure %C_ACCENT%LOOP%C_TEXT% and %C_ACCENT%SHUFFLE%C_TEXT% modes are enabled.%C_RESET%
echo %C_TEXT%3. You may add other videos to this folder: %C_RESET%%C_TEXT%the script will pick one at random on every sleep event.%C_RESET%
echo.
pause

:: ============================================================================
:: SECTION : STEAM INPUT CONFIGURATION
:: ============================================================================
cls
echo.
echo %C_ACCENT%[STEAM INPUT CONFIGURATION]%C_RESET%
echo.
echo %C_TEXT%1. Enable %C_ACCENT%Steam Input%C_TEXT% for your controller.%C_RESET%
echo %C_TEXT%2. Verify that a %C_ACCENT%Desktop Layout%C_TEXT% is active.%C_RESET%
echo.
echo %C_YELLOW%This is crucial for controlling Windows with a controller!%C_RESET%
echo.
set /p "C_STEAM=Have you verified these settings? (Y/N) : "

:: ============================================================================
:: SECTION : LOSSLESS SCALING
:: ============================================================================
cls
echo.
echo %C_ACCENT%[LOSSLESS SCALING INSTALLATION]%C_RESET%
echo.
echo %C_RED%WARNING: CRITICAL STEP - DO THIS NOW IF YOU PLAN TO USE LOSSLESS SCALING!%C_RESET%
echo.
echo %C_TEXT%1. Install Lossless Scaling %C_ACCENT%without changing the default path%C_TEXT%.%C_RESET%
echo %C_TEXT%2. Configure it according to your preferences.%C_RESET%
echo %C_TEXT%3. Enable: %C_ACCENT%Run as Admin%C_TEXT%, %C_ACCENT%Minimize on Launch%C_TEXT%%C_RESET%
echo    %C_TEXT%and %C_ACCENT%Close minimizes to tray%C_TEXT%.%C_RESET%
echo %C_YELLOW%DO NOT ENABLE: "Start with Windows".%C_RESET%
echo.
echo %C_YELLOW%Perform this directly before continuing!%C_RESET%
echo.
pause

:: ============================================================================
:: SECTION : GUIDE BUTTON SHORTCUTS & DRIVERS
:: ============================================================================
cls
echo.
echo %C_ACCENT%[GUIDE BUTTON SHORTCUTS AND DRIVERS]%C_RESET%
echo.
echo %C_TEXT%In %C_ACCENT%Settings > Controller%C_TEXT%, look for %C_ACCENT%Guide Button Chord Layout%C_TEXT%.%C_RESET%
echo %C_TEXT%Here you can create macros (Alt+F4, Alt+Tab, etc.).%C_RESET%
echo %C_TEXT%Useful for crashes and general navigation!%C_RESET%
echo.
echo %C_RED%MANDATORY:%C_RESET%
echo %C_TEXT%Assign a key (e.g., Ctrl+Alt+S) to %C_ACCENT%activate Lossless Scaling%C_TEXT%.%C_RESET%
echo %C_TEXT%Assign an ALT + F4 binding to %C_ACCENT%Force Close apps%C_TEXT%.%C_RESET%
echo %C_TEXT%Assign an ALT + TAB binding to %C_ACCENT%Avoid future system blocks%C_TEXT%.%C_RESET%
echo %C_TEXT%Assign a REBOOT binding to %C_ACCENT%Reboot in case of issues%C_TEXT%.%C_RESET%
echo %C_TEXT%Assign a KEYBOARD binding to %C_ACCENT%Open the on-screen keyboard when needed%C_TEXT%.%C_RESET%
echo.
echo %C_TEXT%Finally, if Steam offers to %C_ACCENT%install controller drivers%C_TEXT%,%C_RESET%
echo %C_TEXT%do so AT THE NEXT REBOOT.%C_RESET%
echo.
set /p "C_FIN=Configuration finished? (Y/N) : "

:: Final Cleanup
call :FAKELOADING "Cleaning up temporary files..."
if exist "%WorkDir%" rd /s /q "%WorkDir%"

echo.
echo %C_GREEN%✓ Installation and Configuration complete!%C_RESET%
echo %C_TEXT%Returning to main menu...%C_RESET%
pause
goto MENU

:: ============================================================================
:: SECTION 3 : UPDATE
:: ============================================================================
:UPDATE
cls
echo.
echo %C_ACCENT%[CHECKING FOR UPDATES]%C_RESET%

:: Check Scripts folder
if not exist "C:\Scripts" mkdir "C:\Scripts"

:: 1. Remove old version if it exists
if exist "C:\Scripts\update.bat" (
    echo %C_TEXT%Removing old update script...%C_RESET%
    del /f /q "C:\Scripts\update.bat"
)

:: 2. Download new version (RAW Link)
echo %C_TEXT%Downloading fresh update script...%C_RESET%
curl -L "https://raw.githubusercontent.com/Sanko-kf/SteamOS-Experience/9d2892bd01c0f6afffcc04c70458ccdc96e7040a/Scripts/update.bat" -o "C:\Scripts\update.bat"

:: 3. Execution
if exist "C:\Scripts\update.bat" (
    echo %C_TEXT%Launching C:\Scripts\update.bat...%C_RESET%
    start /wait /d "C:\Scripts" cmd /c "call update.bat"
    echo.
    echo %C_GREEN%Update process finished.%C_RESET%
) else (
    echo %C_RED%[ERROR] Download failed. update.bat not found.%C_RESET%
)
pause
goto MENU

:: ============================================================================
:: SECTION 4 : UNINSTALL
:: ============================================================================
:UNINSTALL
cls
echo.
echo %C_RED%[UNINSTALL - SYSTEM RESTORATION]%C_RESET%

:: Check Scripts folder
if not exist "C:\Scripts" mkdir "C:\Scripts"

:: 1. Remove old version if it exists
if exist "C:\Scripts\uninstall.bat" (
    echo %C_TEXT%Removing old uninstall script...%C_RESET%
    del /f /q "C:\Scripts\uninstall.bat"
)

:: 2. Download new version (RAW Link)
echo %C_TEXT%Downloading fresh uninstall script...%C_RESET%
curl -L "https://raw.githubusercontent.com/Sanko-kf/SteamOS-Experience/9d2892bd01c0f6afffcc04c70458ccdc96e7040a/Scripts/uninstall.bat" -o "C:\Scripts\uninstall.bat"

:: 3. Execution
if exist "C:\Scripts\uninstall.bat" (
    echo %C_TEXT%Launching C:\Scripts\uninstall.bat...%C_RESET%
    start /wait /d "C:\Scripts" cmd /c "call uninstall.bat"
    echo.
    echo %C_GREEN%Uninstall process finished.%C_RESET%
) else (
    echo %C_RED%[ERROR] Download failed. uninstall.bat not found.%C_RESET%
)
pause
goto MENU

:: ============================================================================
:: VISUAL FUNCTION
:: ============================================================================
:FAKELOADING
echo | set /p="%C_ACCENT%[..]%C_RESET% %~1"
timeout /t 1 >nul
echo      %C_GREEN%OK%C_RESET%
exit /b