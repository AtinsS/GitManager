@echo off
chcp 65001 >nul
call "%~dp0utils.bat"

echo ⬇️ Git Pull для репозитория: %~1
echo ================================
git pull
if errorlevel 1 (
  echo %RED%❌ Ошибка при обновлении!%RESET%
  ) else (
  echo %GREEN%✅ Репозиторий успешно обновлен!%RESET%
)
echo.
pause
