@echo off
setlocal EnableExtensions DisableDelayedExpansion
chcp 65001 >nul

set "SCRIPT_DIR=%~dp0"
set "SRC_CMD=%SCRIPT_DIR%codex-now.cmd"
set "SRC_EXPLORER_CMD=%SCRIPT_DIR%codex-now-explorer.cmd"
set "SRC_PS1=%SCRIPT_DIR%codex-now.ps1"
set "ICON_GENERATOR=%SCRIPT_DIR%generate-hourglass-icon.ps1"
set "USER_BIN=%USERPROFILE%\bin"
set "DST_CMD=%USER_BIN%\codex-now.cmd"
set "DST_EXPLORER_CMD=%USER_BIN%\codex-now-explorer.cmd"
set "DST_PS1=%USER_BIN%\codex-now.ps1"
set "DEFAULT_ICON=%USER_BIN%\codex-now-hourglass.ico"
set "ICON_CONFIG_FILE=%USERPROFILE%\.codex-now-menu-icon"

echo.
echo ========================================
echo   Codex Now - Windows Install
echo ========================================
echo.

if not exist "%SRC_CMD%" (
    echo [ERROR] Missing source file: %SRC_CMD%
    exit /b 1
)

if not exist "%SRC_EXPLORER_CMD%" (
    echo [ERROR] Missing source file: %SRC_EXPLORER_CMD%
    exit /b 1
)

if not exist "%SRC_PS1%" (
    echo [ERROR] Missing source file: %SRC_PS1%
    exit /b 1
)

if not exist "%ICON_GENERATOR%" (
    echo [ERROR] Missing source file: %ICON_GENERATOR%
    exit /b 1
)

where codex >nul 2>&1
if errorlevel 1 (
    echo [ERROR] codex command was not found.
    echo         Install Codex CLI first, then rerun this installer.
    echo         Verify with: codex --version
    exit /b 1
)

if not exist "%USER_BIN%" (
    mkdir "%USER_BIN%" >nul 2>&1
    if errorlevel 1 (
        echo [ERROR] Failed to create user bin directory: %USER_BIN%
        exit /b 1
    )
)

copy /y "%SRC_CMD%" "%DST_CMD%" >nul
if errorlevel 1 (
    echo [ERROR] Failed to copy launcher script to: %DST_CMD%
    exit /b 1
)

copy /y "%SRC_EXPLORER_CMD%" "%DST_EXPLORER_CMD%" >nul
if errorlevel 1 (
    echo [ERROR] Failed to copy explorer launcher script to: %DST_EXPLORER_CMD%
    exit /b 1
)

copy /y "%SRC_PS1%" "%DST_PS1%" >nul
if errorlevel 1 (
    echo [ERROR] Failed to copy PowerShell launcher script to: %DST_PS1%
    exit /b 1
)

powershell -NoProfile -ExecutionPolicy Bypass -File "%ICON_GENERATOR%" -OutputPath "%DEFAULT_ICON%" >nul 2>&1
if not exist "%DEFAULT_ICON%" (
    echo [WARN] Failed to generate default hourglass icon.
) else (
    echo [OK] Generated default icon:
    echo      %DEFAULT_ICON%
)

if not exist "%ICON_CONFIG_FILE%" (
    > "%ICON_CONFIG_FILE%" echo(%DEFAULT_ICON%
)

echo [OK] Installed launcher:
echo      %DST_CMD%
echo      %DST_EXPLORER_CMD%
echo      %DST_PS1%
echo.

echo;%PATH%; | find /I ";%USER_BIN%;" >nul
if errorlevel 1 (
    echo [WARN] %USER_BIN% is not in PATH.
    echo        Add it to PATH to run codex-now.cmd from any terminal:
    echo        setx PATH "%%PATH%%;%USER_BIN%"
    echo        Then reopen terminal windows.
) else (
    echo [OK] PATH already includes: %USER_BIN%
)

echo.
echo Next step:
echo   Run install-context-menu.bat to add right-click menus.
echo.
exit /b 0
