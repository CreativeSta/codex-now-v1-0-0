@echo off
setlocal EnableExtensions DisableDelayedExpansion
chcp 65001 >nul

set "PAUSE_ON_EXIT=1"
if /i "%~1"=="--no-pause" set "PAUSE_ON_EXIT=0"

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

call :require_file "%SRC_CMD%" "launcher script" || goto fail_package
call :require_file "%SRC_EXPLORER_CMD%" "Explorer helper script" || goto fail_package
call :require_file "%SRC_PS1%" "PowerShell launcher script" || goto fail_package
call :require_file "%ICON_GENERATOR%" "icon generator script" || goto fail_package

where codex >nul 2>&1
if errorlevel 1 (
    echo [ERROR] codex command was not found.
    echo         Install Codex CLI first, then rerun this installer.
    echo         Verify with: codex --version
    goto fail
)

if not exist "%USER_BIN%" (
    mkdir "%USER_BIN%" >nul 2>&1
    if errorlevel 1 (
        echo [ERROR] Failed to create user bin directory: %USER_BIN%
        echo         Check folder permissions or create it manually, then rerun install.bat.
        goto fail
    )
)

copy /y "%SRC_CMD%" "%DST_CMD%" >nul
if errorlevel 1 (
    echo [ERROR] Failed to copy launcher script to: %DST_CMD%
    goto fail
)

copy /y "%SRC_EXPLORER_CMD%" "%DST_EXPLORER_CMD%" >nul
if errorlevel 1 (
    echo [ERROR] Failed to copy explorer launcher script to: %DST_EXPLORER_CMD%
    goto fail
)

copy /y "%SRC_PS1%" "%DST_PS1%" >nul
if errorlevel 1 (
    echo [ERROR] Failed to copy PowerShell launcher script to: %DST_PS1%
    goto fail
)

powershell -NoProfile -ExecutionPolicy RemoteSigned -File "%ICON_GENERATOR%" -OutputPath "%DEFAULT_ICON%" >nul 2>&1
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
set "EXIT_CODE=0"
goto finish

:require_file
if exist "%~1" exit /b 0
echo [ERROR] Missing %~2: %~1
exit /b 1

:fail_package
echo         Current package looks incomplete or outdated.
echo         Please re-download the latest release and extract the whole zip before running install.bat.
goto fail

:fail
echo.
echo [INFO] Installer stopped. Review the message above, then rerun install.bat.
set "EXIT_CODE=1"
goto finish

:finish
if "%PAUSE_ON_EXIT%"=="1" (
    echo Press any key to close this window...
    pause >nul
)
exit /b %EXIT_CODE%
