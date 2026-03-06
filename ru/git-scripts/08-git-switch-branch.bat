@echo off
chcp 65001 >nul
call "%~dp0utils.bat"

echo 🔀 Переключение ветки для репозитория: %~1
echo ==========================================

:: Показываем все ветки
echo Доступные ветки:
echo ----------------
git branch -a
echo.

:: Выбор ветки
set /p "branch_name=Введите название ветки для переключения: "

:: Проверяем наличие неподтвержденных изменений
git status --porcelain | findstr . >nul
if errorlevel 0 (
    echo ⚠ У вас есть неподтвержденные изменения!
    set /p "stash=Спрятать их? (y/n): "
    if /i "!stash!"=="y" (
        git stash
        echo Изменения спрятаны
    )
)

:: Переключаемся
git checkout !branch_name!
if errorlevel 1 (
    echo ❌ Ошибка при переключении на ветку '!branch_name!'
) else (
    echo ✅ Переключено на ветку '!branch_name!'
    
    :: Если были спрятаны изменения, предлагаем восстановить
    if /i "!stash!"=="y" (
        set /p "apply=Восстановить спрятанные изменения? (y/n): "
        if /i "!apply!"=="y" (
            git stash pop
        )
    )
)

echo.
pause