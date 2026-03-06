@echo off
chcp 65001 >nul
call "%~dp0utils.bat"

echo ⬆️ Git Push для репозитория: %~1
echo =================================

:: Проверяем есть ли что пушить
git status | findstr "nothing to commit" >nul
if errorlevel 1 (
    echo ⚠ Есть незакоммиченные изменения!
    echo Сначала сделайте коммит.
) else (
    echo Отправка изменений в remote...
    git push
    if errorlevel 1 (
        echo ❌ Ошибка при отправке!
    ) else (
        echo ✅ Изменения отправлены!
    )
)
echo.
pause