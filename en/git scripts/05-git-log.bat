@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
call "%~dp0utils.bat"

cls
echo %GREEN%📜 Git Log for repository: %~1%RESET%
echo %WHITE%================================%RESET%
echo.
echo %GREEN% 1.%RESET% Last 5 commits
echo %GREEN% 2.%RESET% Last 10 commits
echo %GREEN% 3.%RESET% All commits
echo %GREEN% 4.%RESET% Commit graph
echo %GREEN% 5.%RESET% Search by message
echo %RED% 0.%RESET% Back
echo.

set /p "log_choice=%WHITE%Choose: %RESET%"

if "%log_choice%"=="1" git log --oneline -5
if "%log_choice%"=="2" git log --oneline -10
if "%log_choice%"=="3" git log --oneline
if "%log_choice%"=="4" git log --graph --oneline --all
if "%log_choice%"=="5" (
    set /p "search=%WHITE%Enter search text: %RESET%"
    git log --oneline --grep="!search!"
)
if "%log_choice%"=="0" exit /b

echo.
pause