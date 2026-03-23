@echo off
chcp 65001 >nul
call "%~dp0utils.bat"

echo 🔀 Слияние веток для репозитория: %~1
echo ======================================
echo.

:: Получаем текущую ветку
for /f "tokens=*" %%b in ('git branch --show-current 2^>nul') do set "current_branch=%%b"
if "!current_branch!"=="" (
    for /f "tokens=2" %%b in ('git branch 2^>nul ^| find "*"') do set "current_branch=%%b"
)
if "!current_branch!"=="" set "current_branch=неизвестно"

echo Текущая ветка: %GREEN%!current_branch!%RESET%
echo.
echo %YELLOW%⚠ ВНИМАНИЕ: Вы будете сливать выбранную ветку в ТЕКУЩУЮ ветку (!current_branch!)%RESET%
echo.

:: Показываем все ветки
echo Доступные ветки:
echo ----------------
git branch -a
echo.

:: Выбор ветки для слияния
set /p "merge_branch=Введите имя ветки для слияния: "

if "!merge_branch!"=="" (
    echo %RED%❌ Имя ветки не может быть пустым!%RESET%
    pause
    exit /b
)

:: Проверяем существование ветки (локальной)
git show-ref --verify --quiet refs/heads/!merge_branch!
if errorlevel 1 (
    :: Проверяем удаленную ветку
    git show-ref --verify --quiet refs/remotes/origin/!merge_branch!
    if errorlevel 1 (
        echo %RED%❌ Ветка '!merge_branch!' не существует!%RESET%
        pause
        exit /b
    ) else (
        echo %YELLOW%⚠ Ветка '!merge_branch!' является удаленной. Локально её нет.%RESET%
        set /p "fetch_first=Сначала выполнить git fetch? (y/n): "
        if /i "!fetch_first!"=="y" (
            git fetch origin !merge_branch!
        )
    )
)

:: Подтверждение
echo.
echo %YELLOW%⚠ Вы собираетесь выполнить слияние ветки '!merge_branch!' в '!current_branch!'%RESET%
set /p "confirm=Подтвердить слияние? (y/n): "

if /i not "!confirm!"=="y" (
    echo %YELLOW%❌ Слияние отменено%RESET%
    pause
    exit /b
)

:: Проверяем наличие неподтвержденных изменений перед слиянием
git status --porcelain | findstr . >nul
if errorlevel 0 (
    echo %YELLOW%⚠ У вас есть неподтвержденные изменения!%RESET%
    set /p "stash=Спрятать их перед слиянием? (y/n): "
    if /i "!stash!"=="y" (
        git stash
        echo Изменения спрятаны
        set "stashed=1"
    )
)

:: Выполняем слияние
echo.
echo ⏳ Выполняется слияние...
git merge "!merge_branch!" --no-edit 2>&1

if errorlevel 1 (
    echo.
    echo %RED%❌ КОНФЛИКТ ПРИ СЛИЯНИИ!%RESET%
    echo %YELLOW%📋 Рекомендации:%RESET%
    echo   1. Исправьте конфликты вручную в файлах
    echo   2. Затем выполните: git add . ^&^& git commit -m "Merge resolved"
    echo   3. Или отмените слияние командой: git merge --abort
    echo.
    git status
) else (
    echo %GREEN%✅ Слияние выполнено успешно!%RESET%
)

:: Восстанавливаем спрятанные изменения, если были
if defined stashed (
    echo.
    set /p "apply_stash=Восстановить спрятанные изменения? (y/n): "
    if /i "!apply_stash!"=="y" (
        git stash pop
        if errorlevel 1 (
            echo %YELLOW%⚠ Возможны конфликты при восстановлении изменений%RESET%
        ) else (
            echo Изменения восстановлены
        )
    )
)

echo.
pause