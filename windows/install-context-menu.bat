@echo off
setlocal EnableExtensions DisableDelayedExpansion
chcp 65001 >nul

set "LAUNCHER=%USERPROFILE%\bin\codex-now.cmd"
set "ROOT=HKCU\Software\Classes"
set "ICON=%SystemRoot%\System32\SHELL32.dll,70"
set "LABEL=Open with Codex Now"

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

reg add "%ROOT%\Directory\shell\CodexNow" /ve /d "%LABEL%" /f >nul
reg add "%ROOT%\Directory\shell\CodexNow" /v "Icon" /d "%ICON%" /f >nul
reg add "%ROOT%\Directory\shell\CodexNow\command" /ve /d "\"%LAUNCHER%\" \"%%V\"" /f >nul
if errorlevel 1 (
    echo [ERROR] Failed to add folder context menu.
    exit /b 1
)

reg add "%ROOT%\Directory\Background\shell\CodexNow" /ve /d "%LABEL%" /f >nul
reg add "%ROOT%\Directory\Background\shell\CodexNow" /v "Icon" /d "%ICON%" /f >nul
reg add "%ROOT%\Directory\Background\shell\CodexNow\command" /ve /d "\"%LAUNCHER%\" \"%%V\"" /f >nul
if errorlevel 1 (
    echo [ERROR] Failed to add folder background context menu.
    exit /b 1
)

reg add "%ROOT%\Drive\shell\CodexNow" /ve /d "%LABEL%" /f >nul
reg add "%ROOT%\Drive\shell\CodexNow" /v "Icon" /d "%ICON%" /f >nul
reg add "%ROOT%\Drive\shell\CodexNow\command" /ve /d "\"%LAUNCHER%\" \"%%V\"" /f >nul
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
