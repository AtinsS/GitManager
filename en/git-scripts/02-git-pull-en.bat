@echo off
chcp 65001 >nul
call "%~dp0utils-en.bat"

echo ⬇️ Git Pull for repository: %~1
echo ================================
git pull
if errorlevel 1 (
    echo ❌ Update error!
) else (
    echo ✅ Repository successfully updated!
)
echo.
pause