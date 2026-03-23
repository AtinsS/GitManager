@echo off
chcp 65001 >nul
call "%~dp0utils.bat"

echo ⛔ Отмена слияния (MERGE --ABORT)
echo =================================
echo.

:: Проверяем идет ли процесс слияния
git status 2>nul | find "merging" >nul
if errorlevel 1 (
    echo %YELLOW%⚠ В данный момент нет активного процесса слияния%RESET%
    echo.
    set /p "force_abort=Принудительно сбросить состояние? (y/n): "
    if /i "!force_abort!"=="y" (
        echo.
        echo ⏳ Выполняется git merge --abort...
        git merge --abort 2>&1
        if errorlevel 1 (
            echo %YELLOW%⚠ Команда не выполнена. Возможно, нет активного слияния%RESET%
        ) else (
            echo %GREEN%✅ Слияние отменено%RESET%
        )
    ) else (
        echo %YELLOW%❌ Отменено%RESET%
    )
    pause
    exit /b
)

echo %RED%⚠ Обнаружен активный процесс слияния!%RESET%
echo.
echo %YELLOW%Выполнение команды git merge --abort отменит текущее слияние%RESET%
echo %YELLOW%и вернет репозиторий в состояние до начала слияния.%RESET%
echo.
set /p "confirm=Подтвердить отмену слияния? (y/n): "

if /i not "!confirm!"=="y" (
    echo %YELLOW%❌ Отмена слияния отменена%RESET%
    pause
    exit /b
)

echo.
echo ⏳ Выполняется git merge --abort...
git merge --abort 2>&1

if errorlevel 1 (
    echo %RED%❌ Ошибка при отмене слияния!%RESET%
    echo %YELLOW%📋 Возможные причины:%RESET%
    echo   - Нет активного слияния
    echo   - Проблемы с правами доступа
) else (
    echo %GREEN%✅ Слияние успешно отменено!%RESET%
    echo %GREEN%📁 Репозиторий восстановлен в исходное состояние%RESET%
)

echo.
pause