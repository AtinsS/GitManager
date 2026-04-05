@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: COLORS
for /F %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
set "GREEN=%ESC%[92m"
set "YELLOW=%ESC%[93m"
set "RED=%ESC%[91m"
set "CYAN=%ESC%[96m"
set "WHITE=%ESC%[97m"
set "BOLD=%ESC%[1m"
set "RESET=%ESC%[0m"

:: Check Git repository
git status >nul 2>&1
if errorlevel 1 (
    cls
    echo %RED%❌ Current folder is not a Git repository!%RESET%
    timeout /t 2 >nul
    exit /b 1
)

cls
echo %BOLD%%CYAN%    RESET TO SPECIFIC COMMIT%RESET%
echo.

:: Show commits
echo %WHITE%Last 10 commits:%RESET%
echo %CYAN%----------------------------------------%RESET%
git log --oneline -10
echo %CYAN%----------------------------------------%RESET%
echo.

set /p "commit_hash=%WHITE%Commit hash: %RESET%"
if "!commit_hash!"=="" exit /b 0

echo.
echo %GREEN% 1.%RESET% Soft (--soft) - changes remain in index
echo %YELLOW% 2.%RESET% Mixed (--mixed) - changes remain in working directory
echo %RED% 3.%RESET% Hard (--hard) - ALL changes will be LOST!
echo %RED% 0.%RESET% Cancel
echo.

set /p "reset_type=%WHITE%Choice: %RESET%"

if "%reset_type%"=="0" exit /b 0
if "%reset_type%"=="1" git reset --soft %commit_hash%
if "%reset_type%"=="2" git reset --mixed %commit_hash%
if "%reset_type%"=="3" git reset --hard %commit_hash%

echo.
echo %GREEN%✅ Done!%RESET%
echo.
echo %BOLD%%YELLOW%════════════════════════════════════════════════════════════%RESET%
echo %BOLD%%WHITE%  Press any key to exit...%RESET%
echo %BOLD%%YELLOW%════════════════════════════════════════════════════════════%RESET%
pause >nul

exit /b 0