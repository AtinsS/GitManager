@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: Подключаем утилиты
call "%~dp0utils.bat"

:: Проверяем, что цвета определились
if "%WHITE%"=="" set "WHITE="
if "%GREEN%"=="" set "GREEN="
if "%YELLOW%"=="" set "YELLOW="
if "%BLUE%"=="" set "BLUE="
if "%RED%"=="" set "RED="
if "%RESET%"=="" set "RESET="

echo %WHITE%🔄 ОТМЕНА КОММИТА (GIT REVERT)%RESET%
echo %WHITE%===============================%RESET%
echo.

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
echo.

set /p "revert_type=Выберите (1-3): "

if "%revert_type%"=="1" (
    echo.
    echo %WHITE%Последний коммит:%RESET%
    git log -1 --oneline
    echo.
    set /p "confirm=Отменить последний коммит? (y/n): "
    if /i "!confirm!"=="y" (
        echo.
        echo ⏳ Выполняется revert...
        git revert HEAD --no-edit
        if errorlevel 1 (
            echo %RED%❌ Ошибка при отмене коммита!%RESET%
            echo %YELLOW%Возможно, есть конфликты. Исправьте их и выполните 'git revert --continue'%RESET%
        ) else (
            echo %GREEN%✅ Коммит успешно отменен! Создан новый коммит отмены.%RESET%
        )
    )
)

if "%revert_type%"=="2" (
    echo.
    set /p "commit_hash=Введите хеш коммита для отмены: "
    if not "!commit_hash!"=="" (
        echo.
        echo %WHITE%Коммит для отмены:%RESET%
        git show !commit_hash! --stat --oneline
        echo.
        set /p "confirm=Отменить этот коммит? (y/n): "
        if /i "!confirm!"=="y" (
            echo.
            echo ⏳ Выполняется revert...
            git revert !commit_hash! --no-edit
            if errorlevel 1 (
                echo %RED%❌ Ошибка при отмене коммита!%RESET%
                echo %YELLOW%Возможно, есть конфликты. Исправьте их и выполните 'git revert --continue'%RESET%
            ) else (
                echo %GREEN%✅ Коммит успешно отменен! Создан новый коммит отмены.%RESET%
            )
        )
    )
)

if "%revert_type%"=="3" (
    echo.
    echo %WHITE%Введите диапазон коммитов (например: HEAD~3..HEAD):%RESET%
    set /p "range=Диапазон: "
    if not "!range!"=="" (
        echo.
        echo %WHITE%Коммиты для отмены:%RESET%
        git log !range! --oneline
        echo.
        set /p "confirm=Отменить эти коммиты? (y/n): "
        if /i "!confirm!"=="y" (
            echo.
            echo ⏳ Выполняется revert диапазона...
            git revert !range! --no-edit
            if errorlevel 1 (
                echo %RED%❌ Ошибка при отмене коммитов!%RESET%
                echo %YELLOW%Возможно, есть конфликты. Исправьте их и выполните 'git revert --continue'%RESET%
            ) else (
                echo %GREEN%✅ Коммиты успешно отменены!%RESET%
            )
        )
    )
)

echo.
pause
exit /b