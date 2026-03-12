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

if defined TARGET_DIR call :strip_path_quotes

call :normalize_target_dir

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
    echo         Blocked: ^& ^| ^< ^> ^^ %% ; ^( ^) !
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

call :save_last_dir "%TARGET_DIR%"
if errorlevel 1 (
    echo [WARN] Failed to save last directory file:
    echo        "%LAST_DIR_FILE%"
)

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
if not defined INPUT exit /b 0

set "WORK=%INPUT:!=%"
if not "%WORK%"=="%INPUT%" exit /b 1

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

set "WORK=!INPUT:;=!"
if not "!WORK!"=="!INPUT!" (
    endlocal
    exit /b 1
)

set "WORK=!INPUT:(=!"
if not "!WORK!"=="!INPUT!" (
    endlocal
    exit /b 1
)

set "WORK=!INPUT:)=!"
if not "!WORK!"=="!INPUT!" (
    endlocal
    exit /b 1
)

endlocal
exit /b 0

:strip_path_quotes
if not defined TARGET_DIR exit /b 0

:strip_quotes_loop
set "FIRST_CHAR=%TARGET_DIR:~0,1%"
set "LAST_CHAR=%TARGET_DIR:~-1%"
set "HAS_LEAD_DQ=0"
set "HAS_TAIL_DQ=0"
set "HAS_LEAD_SQ=0"
set "HAS_TAIL_SQ=0"

if not "%FIRST_CHAR%"=="%FIRST_CHAR:"=%" set "HAS_LEAD_DQ=1"
if not "%LAST_CHAR%"=="%LAST_CHAR:"=%" set "HAS_TAIL_DQ=1"
if not "%FIRST_CHAR%"=="%FIRST_CHAR:'=%" set "HAS_LEAD_SQ=1"
if not "%LAST_CHAR%"=="%LAST_CHAR:'=%" set "HAS_TAIL_SQ=1"

if "%HAS_LEAD_DQ%%HAS_TAIL_DQ%"=="11" (
    set "TARGET_DIR=%TARGET_DIR:~1,-1%"
    goto strip_quotes_loop
)
if "%HAS_LEAD_SQ%%HAS_TAIL_SQ%"=="11" (
    set "TARGET_DIR=%TARGET_DIR:~1,-1%"
    goto strip_quotes_loop
)

if "%HAS_LEAD_DQ%"=="1" set "TARGET_DIR=%TARGET_DIR:~1%"
if "%HAS_LEAD_SQ%"=="1" set "TARGET_DIR=%TARGET_DIR:~1%"

set "LAST_CHAR=%TARGET_DIR:~-1%"
set "HAS_TAIL_DQ=0"
set "HAS_TAIL_SQ=0"
if not "%LAST_CHAR%"=="%LAST_CHAR:"=%" set "HAS_TAIL_DQ=1"
if not "%LAST_CHAR%"=="%LAST_CHAR:'=%" set "HAS_TAIL_SQ=1"
if "%HAS_TAIL_DQ%"=="1" set "TARGET_DIR=%TARGET_DIR:~0,-1%"
if "%HAS_TAIL_SQ%"=="1" set "TARGET_DIR=%TARGET_DIR:~0,-1%"
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
if not exist "%CANDIDATE%" exit /b 1

for %%E in ("%CANDIDATE%") do (
    set "CANDIDATE_NAME=%%~nE"
    set "CANDIDATE_EXT=%%~xE"
)

if /i not "%CANDIDATE_NAME%"=="codex" exit /b 0

if /i "%CANDIDATE_EXT%"==".cmd" set "CODEX_PATH=%CANDIDATE%"
if /i "%CANDIDATE_EXT%"==".exe" set "CODEX_PATH=%CANDIDATE%"
if /i "%CANDIDATE_EXT%"==".bat" set "CODEX_PATH=%CANDIDATE%"
exit /b 0

:normalize_target_dir
if not defined TARGET_DIR exit /b 0

set "OUT=%TARGET_DIR%"

:trim_loop
if "%OUT%"=="" goto trim_done
if not "%OUT:~-1%"=="\" goto trim_done
if "%OUT:~1,2%"==":\" if "%OUT:~3%"=="" goto trim_done
if "%OUT:~0,2%"=="\\" (
    call :is_unc_share_root "%OUT%"
    if not errorlevel 1 goto trim_done
)
set "OUT=%OUT:~0,-1%"
goto trim_loop

:trim_done
set "TARGET_DIR=%OUT%"
exit /b 0

:is_unc_share_root
set "UNC_INPUT=%~1"
if not "%UNC_INPUT:~0,2%"=="\\" exit /b 1
set "UNC_REST=%UNC_INPUT:~2%"
for /f "tokens=1,2,3* delims=\" %%A in ("%UNC_REST%") do (
    if not "%%A"=="" if not "%%B"=="" if "%%C"=="" exit /b 0
)
exit /b 1

:save_last_dir
set "SAVE_VALUE=%~1"
if not defined SAVE_VALUE exit /b 1
set "LAST_DIR_TMP=%TEMP%\codex-now-last-dir.%RANDOM%%RANDOM%.tmp"

> "%LAST_DIR_TMP%" (
    echo(%SAVE_VALUE%
)
if not exist "%LAST_DIR_TMP%" (
    del /q "%LAST_DIR_TMP%" >nul 2>&1
    exit /b 1
)

move /y "%LAST_DIR_TMP%" "%LAST_DIR_FILE%" >nul 2>&1
if errorlevel 1 (
    del /q "%LAST_DIR_TMP%" >nul 2>&1
    > "%LAST_DIR_FILE%" (
        echo(%SAVE_VALUE%
    )
    if not exist "%LAST_DIR_FILE%" exit /b 1
)
exit /b 0

:fail
exit /b 1
