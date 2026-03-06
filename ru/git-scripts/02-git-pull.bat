@echo off
chcp 65001 >nul
call "%~dp0utils.bat"

echo ⬇️ Git Pull для репозитория: %~1
echo ================================
git pull
if errorlevel 1 (
    echo ❌ Ошибка при обновлении!
) else (
    echo ✅ Репозиторий успешно обновлен!
)
echo.
pause