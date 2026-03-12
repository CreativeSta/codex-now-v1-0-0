@echo off
setlocal EnableExtensions DisableDelayedExpansion
chcp 65001 >nul

set "USER_BIN=%USERPROFILE%\bin"
set "LAUNCHER=%USER_BIN%\codex-now.cmd"
set "LAST_DIR_FILE=%USERPROFILE%\.codex-now-last-dir"
set "ROOT=HKCU\Software\Classes"

echo.
echo ========================================
echo   Codex Now - Diagnose
echo ========================================
echo.

echo [System]
echo   OS: %OS%
echo   User: %USERNAME%
echo   Home: %USERPROFILE%
echo   Current dir: %CD%
echo.

echo [Files]
if exist "%LAUNCHER%" (
    echo   [OK] Launcher exists: %LAUNCHER%
) else (
    echo   [ERROR] Launcher missing: %LAUNCHER%
)

if exist "%LAST_DIR_FILE%" (
    set /p LAST_DIR=<"%LAST_DIR_FILE%"
    setlocal EnableDelayedExpansion
    echo   [OK] Last dir file exists: %LAST_DIR_FILE%
    echo        Saved dir: "!LAST_DIR!"
    endlocal
) else (
    echo   [INFO] Last dir file not found yet: %LAST_DIR_FILE%
)
echo.

echo [Codex CLI]
where codex >nul 2>&1
if errorlevel 1 (
    echo   [ERROR] codex not found in PATH.
) else (
    for /f "usebackq delims=" %%I in (`where codex`) do (
        echo   [OK] where codex: %%I
    )
    codex --version
)
echo.

echo [PATH]
echo;%PATH%; | find /I ";%USER_BIN%;" >nul
if errorlevel 1 (
    echo   [WARN] %USER_BIN% is not in PATH.
) else (
    echo   [OK] %USER_BIN% is in PATH.
)
echo.

echo [Registry]
call :check_key "%ROOT%\Directory\shell\CodexNow" "Directory menu"
call :check_key "%ROOT%\Directory\Background\shell\CodexNow" "Background menu"
call :check_key "%ROOT%\Drive\shell\CodexNow" "Drive menu"
call :show_icon "%ROOT%\Directory\shell\CodexNow"
echo.

echo [Tips]
echo   1) Run install.bat first.
echo   2) Run install-context-menu.bat next.
echo   3) If PATH changed, reopen terminal windows.
echo.
exit /b 0

:check_key
reg query "%~1" >nul 2>&1
if errorlevel 1 (
    echo   [MISSING] %~2
) else (
    echo   [OK] %~2
)
exit /b 0

:show_icon
for /f "tokens=1,2,*" %%A in ('reg query "%~1" /v Icon 2^>nul ^| findstr /I "Icon"') do (
    echo   [INFO] Menu icon: %%C
    exit /b 0
)
echo   [INFO] Menu icon: (not set)
exit /b 0
