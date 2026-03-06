@echo off
chcp 65001 >nul
call "%~dp0utils.bat"

echo 📊 Git Status для репозитория: %~1
echo =================================
git status
echo.
pause