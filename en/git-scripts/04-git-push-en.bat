@echo off
chcp 65001 >nul
call "%~dp0utils-en.bat"

echo ⬆️ Git Push for repository: %~1
echo =================================

:: Check if there's anything to push
git status | findstr "nothing to commit" >nul
if errorlevel 1 (
    echo ⚠ There are uncommitted changes!
    echo Please commit first.
) else (
    echo Sending changes to remote...
    git push
    if errorlevel 1 (
        echo ❌ Push error!
    ) else (
        echo ✅ Changes sent!
    )
)
echo.
pause