@echo off
chcp 65001 >nul
call "%~dp0utils.bat"

echo 📝 Git Commit для репозитория: %~1
echo ===================================

:: Показываем статус перед коммитом
echo Текущее состояние:
git status -s
echo.

:: Добавление файлов
set /p "files=Какие файлы добавить? (Enter - все, или укажите конкретные): "
if "!files!"=="" (
    git add .
) else (
    git add !files!
)

:: Коммит
set /p "commit_msg=Введите комментарий к коммиту: "
if "!commit_msg!"=="" set "commit_msg=Автоматический коммит"

git commit -m "!commit_msg!"
if errorlevel 1 (
    echo ❌ Ошибка при коммите!
) else (
    echo ✅ Коммит успешно создан!
)
echo.
pause