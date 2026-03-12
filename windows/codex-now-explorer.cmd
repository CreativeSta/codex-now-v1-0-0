@echo off
setlocal EnableExtensions DisableDelayedExpansion

set "MAIN_LAUNCHER=%~dp0codex-now.cmd"

if not exist "%MAIN_LAUNCHER%" (
    echo [ERROR] Missing launcher: %MAIN_LAUNCHER%
    exit /b 1
)

if "%~1"=="" (
    set "TARGET_DIR=%CD%"
) else (
    set "TARGET_DIR=%~1"
)

start "" cmd.exe /d /k ""%MAIN_LAUNCHER%" "%TARGET_DIR%""
exit /b 0
