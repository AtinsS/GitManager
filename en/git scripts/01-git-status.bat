@echo off
chcp 65001 >nul
call "%~dp0utils.bat"

echo 📊 Git Status for repository: %~1
echo =================================
git status
echo.
pause