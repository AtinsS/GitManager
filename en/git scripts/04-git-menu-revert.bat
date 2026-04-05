@echo off
setlocal enabledelayedexpansion

:: Get script directory
set "SCRIPT_DIR=%~dp0"

:: Colors
for /F %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
set "RED=%ESC%[91m"
set "GREEN=%ESC%[92m"
set "YELLOW=%ESC%[93m"
set "CYAN=%ESC%[96m"
set "WHITE=%ESC%[97m"
set "BOLD=%ESC%[1m"
set "RESET=%ESC%[0m"

:MENU_LOOP
cls
echo %BOLD%%CYAN%    ════════════════════════════════════════════════════════════%RESET%
echo %BOLD%%CYAN%    🔄 REVERT CHANGES MENU%RESET%
echo %BOLD%%CYAN%    ════════════════════════════════════════════════════════════%RESET%
echo.
echo %GREEN%  1.%RESET% Git reset (revert to a commit)
echo %GREEN%  2.%RESET% Git revert (undo commit preserving history)
echo %RED%  0.%RESET% Back to main menu
echo.
set /p "reset_action=%BOLD%%WHITE%    ⚡ Choose action: %RESET%"

if "%reset_action%"=="1" (
    if exist "%SCRIPT_DIR%12-git-reset.bat" (
        call "%SCRIPT_DIR%12-git-reset.bat"
    ) else (
        echo %RED%    ❌ Script 12-git-reset.bat not found%RESET%
        echo %WHITE%    Press any key...%RESET%
        pause >nul
    )
    goto MENU_LOOP
)

if "%reset_action%"=="2" (
    if exist "%SCRIPT_DIR%13-git-revert.bat" (
        call "%SCRIPT_DIR%13-git-revert.bat"
    ) else (
        echo %RED%    ❌ Script 13-git-revert.bat not found%RESET%
        echo %WHITE%    Press any key...%RESET%
        pause >nul
    )
    goto MENU_LOOP
)

if "%reset_action%"=="0" exit /b

echo %RED%❌ Invalid choice!%RESET%
echo %WHITE%Press any key...%RESET%
pause >nul
goto MENU_LOOP