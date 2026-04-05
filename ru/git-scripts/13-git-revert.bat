@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: Подключаем утилиты
call "%~dp0utils.bat"

:: Если цвета не определились, устанавливаем вручную
if not defined ESC (
    for /F %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
)
if "%GREEN%"=="" set "GREEN=%ESC%[92m"
if "%YELLOW%"=="" set "YELLOW=%ESC%[93m"
if "%RED%"=="" set "RED=%ESC%[91m"
if "%WHITE%"=="" set "WHITE=%ESC%[97m"
if "%BLUE%"=="" set "BLUE=%ESC%[94m"
if "%RESET%"=="" set "RESET=%ESC%[0m"

cls
echo %WHITE%╔══════════════════════════════════════════════════════════════╗%RESET%
echo %WHITE%║              🔄 ОТМЕНА КОММИТА (GIT REVERT)                 ║%RESET%
echo %WHITE%╚══════════════════════════════════════════════════════════════╝%RESET%
echo.

:: Проверяем, есть ли коммиты
git log -1 >nul 2>&1
if errorlevel 1 (
    echo %RED%❌ В репозитории нет коммитов!%RESET%
    pause
    exit /b 0
)

:: Показываем последние коммиты
echo %WHITE%Последние 10 коммитов:%RESET%
echo ----------------------------------------
git log --oneline --graph -10
echo ----------------------------------------
echo.

echo %WHITE%Что вы хотите сделать?%RESET%
echo %GREEN%  1.%RESET% Отменить последний коммит
echo %YELLOW%  2.%RESET% Отменить конкретный коммит (по хешу)
echo %BLUE%  3.%RESET% Отменить несколько коммитов (диапазон)
echo %RED%  0.%RESET% Отмена
echo.

set /p "revert_type=%WHITE%Выберите (0-3): %RESET%"

if "%revert_type%"=="0" (
    echo %YELLOW%⚠ Операция отменена%RESET%
    pause
    exit /b 0
)

if "%revert_type%"=="1" (
    echo.
    echo %WHITE%Последний коммит:%RESET%
    git log -1 --oneline
    echo.
    set /p "confirm=%YELLOW%Отменить последний коммит? (y/n): %RESET%"
    if /i "!confirm!"=="y" (
        echo.
        echo ⏳ Выполняется revert...
        git revert HEAD --no-edit 2>&1
        if errorlevel 1 (
            echo %RED%❌ Ошибка при отмене коммита!%RESET%
            echo %YELLOW%💡 Возможные решения:%RESET%
            echo   1. Если есть конфликты, исправьте их и выполните: git revert --continue
            echo   2. Если хотите отменить операцию: git revert --abort
            echo   3. Если нужен ручной ввод сообщения: git revert HEAD
            echo.
            git status
        ) else (
            echo %GREEN%✅ Коммит успешно отменен! Создан новый коммит отмены.%RESET%
        )
    ) else (
        echo %YELLOW%❌ Отменено%RESET%
    )
    goto END
)

if "%revert_type%"=="2" (
    echo.
    set /p "commit_hash=%WHITE%Введите хеш коммита для отмены: %RESET%"
    
    if "!commit_hash!"=="" (
        echo %RED%❌ Хеш не указан!%RESET%
        pause
        exit /b 0
    )
    
    :: Проверяем существование коммита
    git cat-file -e %commit_hash% 2>nul
    if errorlevel 1 (
        echo %RED%❌ Коммит с хешем '%commit_hash%' не найден!%RESET%
        pause
        exit /b 0
    )
    
    echo.
    echo %WHITE%Коммит для отмены:%RESET%
    echo ----------------------------------------
    git show %commit_hash% --stat --oneline
    echo ----------------------------------------
    echo.
    set /p "confirm=%YELLOW%Отменить этот коммит? (y/n): %RESET%"
    
    if /i "!confirm!"=="y" (
        echo.
        echo ⏳ Выполняется revert...
        git revert %commit_hash% --no-edit 2>&1
        if errorlevel 1 (
            echo %RED%❌ Ошибка при отмене коммита!%RESET%
            echo %YELLOW%💡 Возможные решения:%RESET%
            echo   1. Если есть конфликты, исправьте их и выполните: git revert --continue
            echo   2. Если хотите отменить операцию: git revert --abort
            echo   3. Если нужен ручной ввод сообщения: git revert %commit_hash%
            echo.
            git status
        ) else (
            echo %GREEN%✅ Коммит успешно отменен! Создан новый коммит отмены.%RESET%
        )
    ) else (
        echo %YELLOW%❌ Отменено%RESET%
    )
    goto END
)

if "%revert_type%"=="3" (
    echo.
    echo %WHITE%Введите диапазон коммитов:%RESET%
    echo %YELLOW%  Примеры:%RESET%
    echo    - HEAD~3..HEAD     (последние 3 коммита)
    echo    - 1a2b3c4..5d6e7f8 (диапазон между хешами)
    echo    - HEAD~5..HEAD~1   (коммиты 2-5 с конца)
    echo.
    set /p "range=%WHITE%Диапазон: %RESET%"
    
    if "!range!"=="" (
        echo %RED%❌ Диапазон не указан!%RESET%
        pause
        exit /b 0
    )
    
    echo.
    echo %WHITE%Коммиты для отмены:%RESET%
    echo ----------------------------------------
    git log %range% --oneline 2>nul
    if errorlevel 1 (
        echo %RED%❌ Неверный формат диапазона!%RESET%
        pause
        exit /b 0
    )
    echo ----------------------------------------
    echo.
    set /p "confirm=%YELLOW%Отменить эти коммиты? (y/n): %RESET%"
    
    if /i "!confirm!"=="y" (
        echo.
        echo ⏳ Выполняется revert диапазона...
        git revert %range% --no-edit 2>&1
        if errorlevel 1 (
            echo %RED%❌ Ошибка при отмене коммитов!%RESET%
            echo %YELLOW%💡 Возможные решения:%RESET%
            echo   1. Если есть конфликты, исправьте их и выполните: git revert --continue
            echo   2. Если хотите отменить операцию: git revert --abort
            echo   3. Попробуйте отменять коммиты по одному
            echo.
            git status
        ) else (
            echo %GREEN%✅ Коммиты успешно отменены!%RESET%
        )
    ) else (
        echo %YELLOW%❌ Отменено%RESET%
    )
    goto END
)

echo %RED%❌ Неверный выбор!%RESET%

:END
echo.
pause
exit /b 0