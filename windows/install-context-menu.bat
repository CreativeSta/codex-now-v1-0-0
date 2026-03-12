@echo off
setlocal EnableExtensions DisableDelayedExpansion
chcp 65001 >nul

set "LAUNCHER=%USERPROFILE%\bin\codex-now.ps1"
set "ROOT=HKCU\Software\Classes"
set "ICON=%SystemRoot%\System32\SHELL32.dll,70"
set "LABEL=codex now"
set "DEFAULT_ICON=%USERPROFILE%\bin\codex-now-hourglass.ico"
set "ICON_CONFIG_FILE=%USERPROFILE%\.codex-now-menu-icon"
set "CUSTOM_ICON="
set "MENU_COMMAND=powershell.exe -NoProfile -ExecutionPolicy RemoteSigned -WindowStyle Hidden -File \"%LAUNCHER%\" \"%%V \""

echo.
echo ========================================
echo   Codex Now - Install Context Menu
echo ========================================
echo.

if not exist "%LAUNCHER%" (
    echo [ERROR] Launcher not found:
    echo         %LAUNCHER%
    echo         Run install.bat first.
    exit /b 1
)

if exist "%DEFAULT_ICON%" set "ICON=%DEFAULT_ICON%"
call :load_custom_icon
echo [INFO] Icon source: %ICON%
echo [INFO] Menu text: %LABEL%
echo [INFO] Menu command: %MENU_COMMAND%

reg add "%ROOT%\Directory\shell\CodexNow" /ve /d "%LABEL%" /f >nul
reg add "%ROOT%\Directory\shell\CodexNow" /v "Icon" /d "%ICON%" /f >nul
reg add "%ROOT%\Directory\shell\CodexNow\command" /ve /d "%MENU_COMMAND%" /f >nul
if errorlevel 1 (
    echo [ERROR] Failed to add folder context menu.
    exit /b 1
)

reg add "%ROOT%\Directory\Background\shell\CodexNow" /ve /d "%LABEL%" /f >nul
reg add "%ROOT%\Directory\Background\shell\CodexNow" /v "Icon" /d "%ICON%" /f >nul
reg add "%ROOT%\Directory\Background\shell\CodexNow\command" /ve /d "%MENU_COMMAND%" /f >nul
if errorlevel 1 (
    echo [ERROR] Failed to add folder background context menu.
    exit /b 1
)

reg add "%ROOT%\Drive\shell\CodexNow" /ve /d "%LABEL%" /f >nul
reg add "%ROOT%\Drive\shell\CodexNow" /v "Icon" /d "%ICON%" /f >nul
reg add "%ROOT%\Drive\shell\CodexNow\command" /ve /d "%MENU_COMMAND%" /f >nul
if errorlevel 1 (
    echo [ERROR] Failed to add drive context menu.
    exit /b 1
)

echo [OK] Context menus installed for:
echo      1) Directory
echo      2) Directory background
echo      3) Drive
echo.
exit /b 0

:load_custom_icon
if not exist "%ICON_CONFIG_FILE%" exit /b 0
set /p CUSTOM_ICON=<"%ICON_CONFIG_FILE%"
if not defined CUSTOM_ICON exit /b 0
set "ICON=%CUSTOM_ICON%"
exit /b 0
