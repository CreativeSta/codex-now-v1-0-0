@echo off
setlocal EnableExtensions DisableDelayedExpansion
chcp 65001 >nul

set "SCRIPT_DIR=%~dp0"
set "SRC_CMD=%SCRIPT_DIR%codex-now.cmd"
set "USER_BIN=%USERPROFILE%\bin"
set "DST_CMD=%USER_BIN%\codex-now.cmd"

echo.
echo ========================================
echo   Codex Now - Windows Install
echo ========================================
echo.

if not exist "%SRC_CMD%" (
    echo [ERROR] Missing source file: %SRC_CMD%
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

echo [OK] Installed launcher:
echo      %DST_CMD%
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
