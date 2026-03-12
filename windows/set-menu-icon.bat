@echo off
setlocal EnableExtensions DisableDelayedExpansion
chcp 65001 >nul

set "ROOT=HKCU\Software\Classes"
set "ICON_CONFIG_FILE=%USERPROFILE%\.codex-now-menu-icon"
set "ICON_VALUE="
set "MODE=%~1"

if "%MODE%"=="" goto usage

if /i "%MODE%"=="codex" (
    call :detect_codex_icon
    goto apply
)

if /i "%MODE%"=="system" (
    set "ICON_VALUE=%SystemRoot%\System32\SHELL32.dll,70"
    goto apply
)

if /i "%MODE%"=="legacy" (
    set "ICON_VALUE=%SystemRoot%\System32\SHELL32.dll,43"
    goto apply
)

if /i "%MODE%"=="hourglass" goto mode_hourglass

if /i "%MODE%"=="custom" (
    if "%~2"=="" goto usage
    set "ICON_VALUE=%~2"
    goto apply
)

goto usage

:mode_hourglass
set "ICON_VALUE=%USERPROFILE%\bin\codex-now-hourglass.ico"
if not exist "%ICON_VALUE%" (
    echo [ERROR] Missing hourglass icon: %ICON_VALUE%
    echo         Run install.bat first.
    exit /b 1
)
goto apply

:apply
if not defined ICON_VALUE (
    echo [ERROR] Failed to resolve icon.
    exit /b 1
)

> "%ICON_CONFIG_FILE%" echo(%ICON_VALUE%

reg add "%ROOT%\Directory\shell\CodexNow" /v "Icon" /d "%ICON_VALUE%" /f >nul 2>&1
reg add "%ROOT%\Directory\Background\shell\CodexNow" /v "Icon" /d "%ICON_VALUE%" /f >nul 2>&1
reg add "%ROOT%\Drive\shell\CodexNow" /v "Icon" /d "%ICON_VALUE%" /f >nul 2>&1

echo [OK] Icon set to: %ICON_VALUE%
echo [INFO] If menu not refreshed, restart Explorer or sign out/in.
exit /b 0

:detect_codex_icon
for /f "usebackq delims=" %%I in (`where.exe codex 2^>nul`) do (
    if not defined ICON_VALUE (
        if /i "%%~xI"==".exe" (
            if exist "%%~fI" set "ICON_VALUE=%%~fI"
        )
    )
)
if not defined ICON_VALUE set "ICON_VALUE=%SystemRoot%\System32\SHELL32.dll,70"
exit /b 0

:usage
echo Usage:
echo   set-menu-icon.bat codex
echo   set-menu-icon.bat system
echo   set-menu-icon.bat legacy
echo   set-menu-icon.bat hourglass
echo   set-menu-icon.bat custom "C:\path\icon.ico"
echo   set-menu-icon.bat custom "C:\path\app.exe,0"
exit /b 1
