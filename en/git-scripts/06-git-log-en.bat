@echo off
chcp 65001 >nul
call "%~dp0utils-en.bat"

echo 📜 Git Log for repository: %~1
echo ================================

echo 1. Last 5 commits
echo 2. Last 10 commits
echo 3. All commits
echo 4. Commit graph
echo 5. Search by message
echo.

set /p "log_choice=Choose: "

if "%log_choice%"=="1" (
    git log --oneline -5
) else if "%log_choice%"=="2" (
    git log --oneline -10
) else if "%log_choice%"=="3" (
    git log --oneline
) else if "%log_choice%"=="4" (
    git log --graph --oneline --all
) else if "%log_choice%"=="5" (
    set /p "search=Enter text to search: "
    git log --oneline --grep="!search!"
) else (
    echo Invalid choice
)

echo.
pause