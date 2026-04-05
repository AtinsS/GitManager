@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

call "%~dp0utils.bat"

:: Цвета если не загрузились
if not defined ESC (
    for /F %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
)
if "%GREEN%"=="" set "GREEN=%ESC%[92m"
if "%YELLOW%"=="" set "YELLOW=%ESC%[93m"
if "%RED%"=="" set "RED=%ESC%[91m"
if "%CYAN%"=="" set "CYAN=%ESC%[96m"
if "%WHITE%"=="" set "WHITE=%ESC%[97m"
if "%BOLD%"=="" set "BOLD=%ESC%[1m"
if "%RESET%"=="" set "RESET=%ESC%[0m"

cls
echo %BOLD%%CYAN%╔════════════════════════════════════════════════════════════════════╗%RESET%
echo %BOLD%%CYAN%║                        📝 GIT COMMIT                              ║%RESET%
echo %BOLD%%CYAN%╚════════════════════════════════════════════════════════════════════╝%RESET%
echo.
echo %WHITE%  📁 Репозиторий: %GREEN%%~1%RESET%
echo.

:: Проверка Git репозитория
git status >nul 2>&1
if errorlevel 1 (
    echo %RED%  ❌ Ошибка: Текущая папка не является Git репозиторием!%RESET%
    echo.
    echo %YELLOW%  💡 Запустите скрипт из папки с Git репозиторием%RESET%
    pause
    exit /b 1
)

:: Показываем статус
echo %BOLD%%WHITE%  📊 Текущее состояние:%RESET%
echo %CYAN%  ────────────────────────────────────────────────────────────────────────%RESET%
git status -s
echo %CYAN%  ────────────────────────────────────────────────────────────────────────%RESET%
echo.

:: Проверка наличия изменений
git status --porcelain | findstr . >nul 2>&1
if errorlevel 1 (
    echo %YELLOW%  ⚠ Нет изменений для коммита!%RESET%
    echo.
    set /p "continue=%WHITE%  Продолжить? (y/n): %RESET%"
    if /i not "!continue!"=="y" (
        echo %YELLOW%  ❌ Операция отменена%RESET%
        pause
        exit /b 0
    )
)

:: Добавление файлов
echo %BOLD%%WHITE%  📦 Добавление файлов:%RESET%
echo %YELLOW%    Примеры:%RESET%
echo %WHITE%    - Enter %GREEN%→%RESET%%WHITE% все файлы%RESET%
echo %WHITE%    - file1.txt %GREEN%→%RESET%%WHITE% конкретный файл%RESET%
echo %WHITE%    - *.txt %GREEN%→%RESET%%WHITE% все txt файлы%RESET%
echo %WHITE%    - src/ %GREEN%→%RESET%%WHITE% вся папка%RESET%
echo.
set /p "files=%WHITE%  Файлы: %RESET%"

if "!files!"=="" (
    echo %YELLOW%  ⏳ Добавление всех изменений...%RESET%
    git add . 2>nul
) else (
    echo %YELLOW%  ⏳ Добавление: %CYAN%!files!%RESET%...
    git add !files! 2>nul
    if errorlevel 1 (
        echo.
        echo %RED%  ❌ Ошибка добавления файлов!%RESET%
        echo %YELLOW%  💡 Проверьте, существуют ли указанные файлы%RESET%
        pause
        exit /b 1
    )
)

:: Проверка, есть ли что коммитить
git diff --cached --quiet
if errorlevel 1 (
    echo %GREEN%  ✅ Файлы добавлены в индекс%RESET%
) else (
    echo %RED%  ❌ Нет файлов для коммита!%RESET%
    pause
    exit /b 1
)

:: Коммит
echo.
echo %BOLD%%WHITE%  💾 Создание коммита%RESET%
set /p "commit_msg=%WHITE%  Комментарий: %RESET%"
if "!commit_msg!"=="" set "commit_msg=Update %date% %time%"

echo %YELLOW%  ⏳ Создание коммита...%RESET%
git commit -m "!commit_msg!" 2>&1

if errorlevel 1 (
    echo.
    echo %RED%  ❌ Ошибка коммита!%RESET%
    echo %YELLOW%  💡 Возможные причины:%RESET%
    echo %WHITE%     - Не настроен git user%RESET%
    echo %WHITE%     - Нет изменений для коммита%RESET%
    echo.
    echo %WHITE%  Настройка пользователя:%RESET%
    echo %CYAN%     git config user.name "Ваше Имя"%RESET%
    echo %CYAN%     git config user.email "your@email.com"%RESET%
    pause
    exit /b 1
) else (
    echo %GREEN%  ✅ Коммит успешно создан!%RESET%
    echo %WHITE%     📝 Сообщение: %CYAN%!commit_msg!%RESET%
)

:: Отправка
echo.
echo %BOLD%%WHITE%  🚀 Отправка на сервер:%RESET%
set /p "push_confirm=%YELLOW%  Отправить изменения? (y/n): %RESET%"

if /i "!push_confirm!"=="y" (
    echo %YELLOW%  ⏳ Выполняется git push...%RESET%
    
    :: Получаем текущую ветку
    for /f "tokens=*" %%b in ('git branch --show-current 2^>nul') do set "branch=%%b"
    if "!branch!"=="" set "branch=main"
    
    echo %WHITE%     Ветка: %CYAN%!branch!%RESET%
    echo.
    
    git push 2>&1
    
    if errorlevel 1 (
        echo.
        echo %RED%  ❌ Ошибка при отправке!%RESET%
        echo %YELLOW%  💡 Возможные причины:%RESET%
        echo %WHITE%     - Нет подключения к интернету%RESET%
        echo %WHITE%     - Нет прав на запись%RESET%
        echo %WHITE%     - Ветка не настроена для отправки%RESET%
        echo.
        set /p "retry=%YELLOW%  Попробовать git push -u origin !branch!? (y/n): %RESET%"
        if /i "!retry!"=="y" (
            echo %YELLOW%  ⏳ Повторная попытка...%RESET%
            git push -u origin !branch! 2>&1
            if errorlevel 1 (
                echo %RED%  ❌ Снова ошибка!%RESET%
            ) else (
                echo %GREEN%  ✅ Изменения отправлены и ветка настроена!%RESET%
            )
        )
    ) else (
        echo.
        echo %GREEN%  ✅ Изменения успешно отправлены на сервер!%RESET%
    )
) else (
    echo %YELLOW%  ⚠ Отправка отменена.%RESET%
    echo %WHITE%     💡 Чтобы отправить позже: %CYAN%git push%RESET%
)

:: Завершение
echo.
echo %BOLD%%GREEN%╔════════════════════════════════════════════════════════════════════╗%RESET%
echo %BOLD%%GREEN%║                         ✅ ГОТОВО                                  ║%RESET%
echo %BOLD%%GREEN%╚════════════════════════════════════════════════════════════════════╝%RESET%
echo.
echo %WHITE%  Нажмите любую клавишу для выхода...%RESET%
pause >nul

exit /b 0