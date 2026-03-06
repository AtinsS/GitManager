@echo off
chcp 65001 >nul
call "%~dp0utils-en.bat"

echo 📝 Git Commit for repository: %~1
echo ===================================

:: Show status before commit
echo Current state:
git status -s
echo.

:: Add files
set /p "files=Which files to add? (Enter - all, or specify specific ones): "
if "!files!"=="" (
    git add .
) else (
    git add !files!
)

:: Commit
set /p "commit_msg=Enter commit message: "
if "!commit_msg!"=="" set "commit_msg=Automatic commit"

git commit -m "!commit_msg!"
if errorlevel 1 (
    echo ❌ Commit error!
) else (
    echo ✅ Commit successfully created!
)
echo.
pause