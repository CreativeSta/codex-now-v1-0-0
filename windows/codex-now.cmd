@echo off
setlocal EnableExtensions DisableDelayedExpansion
chcp 65001 >nul

set "LAST_DIR_FILE=%USERPROFILE%\.codex-now-last-dir"
set "FAST_MODE=0"
set "TARGET_DIR="
set "CODEX_PATH="

:parse_args
if "%~1"=="" goto args_done

if /i "%~1"=="--fast" (
    set "FAST_MODE=1"
    shift
    goto parse_args
)

if /i "%~1"=="-f" (
    set "FAST_MODE=1"
    shift
    goto parse_args
)

if defined TARGET_DIR (
    echo [ERROR] Too many arguments.
    echo Usage: codex-now.cmd [target_dir] [--fast]
    goto fail
)

set "TARGET_DIR=%~1"
shift
goto parse_args

:args_done
if not defined TARGET_DIR (
    if exist "%LAST_DIR_FILE%" (
        set /p TARGET_DIR=<"%LAST_DIR_FILE%"
    )
)

if defined TARGET_DIR (
    set "FIRST_CHAR=%TARGET_DIR:~0,1%"
    set "LAST_CHAR=%TARGET_DIR:~-1%"
    if "%FIRST_CHAR%"=="\"" if "%LAST_CHAR%"=="\"" (
        set "TARGET_DIR=%TARGET_DIR:~1,-1%"
    )
)

if not defined TARGET_DIR (
    set "TARGET_DIR=%USERPROFILE%"
)

if not defined TARGET_DIR (
    echo [ERROR] Could not determine target directory.
    goto fail
)

call :contains_unsafe_chars "%TARGET_DIR%"
if errorlevel 1 (
    echo [ERROR] Target directory contains blocked characters.
    echo         Blocked: ^& ^| ^< ^> ^^ %%
    goto fail
)

if not exist "%TARGET_DIR%\." (
    echo [ERROR] Target directory does not exist or is not a directory:
    echo         "%TARGET_DIR%"
    goto fail
)

call :find_codex
if not defined CODEX_PATH (
    echo [ERROR] codex command not found.
    echo         Install Codex CLI first and verify with: codex --version
    goto fail
)

> "%LAST_DIR_FILE%" echo(%TARGET_DIR%

echo [INFO] Working directory: "%TARGET_DIR%"
if "%FAST_MODE%"=="1" (
    echo [AUDIT] Command: "%CODEX_PATH%" -C "%TARGET_DIR%" --full-auto
) else (
    echo [AUDIT] Command: "%CODEX_PATH%" -C "%TARGET_DIR%" -a on-request -s workspace-write
)

cd /d "%TARGET_DIR%" || (
    echo [ERROR] Failed to switch directory.
    goto fail
)

if "%FAST_MODE%"=="1" (
    "%CODEX_PATH%" -C "%TARGET_DIR%" --full-auto
) else (
    "%CODEX_PATH%" -C "%TARGET_DIR%" -a on-request -s workspace-write
)

set "EXIT_CODE=%ERRORLEVEL%"
exit /b %EXIT_CODE%

:contains_unsafe_chars
set "INPUT=%~1"
if not defined INPUT exit /b 1

setlocal EnableDelayedExpansion
set "WORK=!INPUT:^=!"
if not "!WORK!"=="!INPUT!" (
    endlocal
    exit /b 1
)

set "WORK=!INPUT:|=!"
if not "!WORK!"=="!INPUT!" (
    endlocal
    exit /b 1
)

set "WORK=!INPUT:&=!"
if not "!WORK!"=="!INPUT!" (
    endlocal
    exit /b 1
)

set "WORK=!INPUT:<=!"
if not "!WORK!"=="!INPUT!" (
    endlocal
    exit /b 1
)

set "WORK=!INPUT:>=!"
if not "!WORK!"=="!INPUT!" (
    endlocal
    exit /b 1
)

set "WORK=!INPUT:%%=!"
if not "!WORK!"=="!INPUT!" (
    endlocal
    exit /b 1
)

endlocal
exit /b 0

:find_codex
for /f "usebackq delims=" %%I in (`where codex 2^>nul`) do (
    if not defined CODEX_PATH (
        call :validate_codex_candidate "%%~fI"
    )
)
exit /b 0

:validate_codex_candidate
set "CANDIDATE=%~1"
if not exist "%CANDIDATE%" exit /b 0

for %%E in ("%CANDIDATE%") do (
    set "CANDIDATE_NAME=%%~nE"
    set "CANDIDATE_EXT=%%~xE"
)

if /i not "%CANDIDATE_NAME%"=="codex" exit /b 0

if /i "%CANDIDATE_EXT%"==".cmd" set "CODEX_PATH=%CANDIDATE%"
if /i "%CANDIDATE_EXT%"==".exe" set "CODEX_PATH=%CANDIDATE%"
if /i "%CANDIDATE_EXT%"==".bat" set "CODEX_PATH=%CANDIDATE%"
exit /b 0

:fail
exit /b 1
