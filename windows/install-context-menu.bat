@echo off
setlocal EnableExtensions DisableDelayedExpansion
chcp 65001 >nul

set "LAUNCHER=%USERPROFILE%\bin\codex-now.cmd"
set "ROOT=HKCU\Software\Classes"
set "ICON=%SystemRoot%\System32\SHELL32.dll,70"
set "LABEL=Open with Codex Now"
set "CODEX_EXE_ICON="

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

call :build_label
call :detect_codex_icon
echo [INFO] Icon source: %ICON%
echo [INFO] Menu text: %LABEL%

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

:detect_codex_icon
for /f "usebackq delims=" %%I in (`where.exe codex 2^>nul`) do (
    if not defined CODEX_EXE_ICON (
        if /i "%%~xI"==".exe" (
            if exist "%%~fI" set "CODEX_EXE_ICON=%%~fI"
        )
    )
)

if defined CODEX_EXE_ICON (
    set "ICON=%CODEX_EXE_ICON%"
)
exit /b 0

:build_label
for /f "usebackq delims=" %%L in (`powershell -NoProfile -Command "[char]36890+[char]36807+'codex now '+[char]25171+[char]24320"`) do (
    set "LABEL=%%L"
)
exit /b 0
