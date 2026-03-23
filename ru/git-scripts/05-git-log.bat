@echo off
chcp 65001 >nul
call "%~dp0utils.bat"

echo 📜 Git Log для репозитория: %~1
echo ================================

echo 1. Последние 5 коммитов
echo 2. Последние 10 коммитов
echo 3. Все коммиты
echo 4. Граф коммитов
echo 5. Поиск по комментарию
echo.

set /p "log_choice=Выберите: "

if "%log_choice%"=="1" (
    git log --oneline -5
) else if "%log_choice%"=="2" (
    git log --oneline -10
) else if "%log_choice%"=="3" (
    git log --oneline
) else if "%log_choice%"=="4" (
    git log --graph --oneline --all
) else if "%log_choice%"=="5" (
    set /p "search=Введите текст для поиска: "
    git log --oneline --grep="!search!"
) else (
    echo Неверный выбор
)

echo.
pause