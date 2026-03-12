@echo off
setlocal EnableExtensions DisableDelayedExpansion
chcp 65001 >nul

set "ROOT=HKCU\Software\Classes"

echo.
echo ========================================
echo   Codex Now - Uninstall Context Menu
echo ========================================
echo.

reg delete "%ROOT%\Directory\shell\CodexNow" /f >nul 2>&1
if errorlevel 1 (
    echo [INFO] Directory menu not found or already removed.
) else (
    echo [OK] Removed directory menu.
)

reg delete "%ROOT%\Directory\Background\shell\CodexNow" /f >nul 2>&1
if errorlevel 1 (
    echo [INFO] Directory background menu not found or already removed.
) else (
    echo [OK] Removed directory background menu.
)

reg delete "%ROOT%\Drive\shell\CodexNow" /f >nul 2>&1
if errorlevel 1 (
    echo [INFO] Drive menu not found or already removed.
) else (
    echo [OK] Removed drive menu.
)

echo.
echo [DONE] Context menu cleanup complete.
echo.
exit /b 0
