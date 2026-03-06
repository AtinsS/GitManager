@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: Цветовое оформление
:: 0 - Черный       8 - Серый
:: 1 - Синий        9 - Светло-синий
:: 2 - Зеленый      A - Светло-зеленый
:: 3 - Голубой      B - Светло-голубой
:: 4 - Красный      C - Светло-красный
:: 5 - Фиолетовый   D - Светло-фиолетовый
:: 6 - Желтый       E - Светло-желтый
:: 7 - Белый        F - Ярко-белый

set "ESC="
set "RED=%ESC%[91m"
set "GREEN=%ESC%[92m"
set "YELLOW=%ESC%[93m"
set "BLUE=%ESC%[94m"
set "MAGENTA=%ESC%[95m"
set "CYAN=%ESC%[96m"
set "WHITE=%ESC%[97m"
set "BOLD=%ESC%[1m"
set "RESET=%ESC%[0m"

:: Запоминаем путь к папке с батником (исправлено для путей с пробелами)
set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"

:: Путь к конфигу теперь в папке с батником
set "CONFIG_FILE=%SCRIPT_DIR%\git_repos.cfg"
set "TEMP_FILE=%SCRIPT_DIR%\temp.cfg"

:: Проверка наличия git
where git >nul 2>nul
if errorlevel 1 (
    echo %RED%Git не найден! Установите Git для Windows%RESET%
    echo %BLUE%https://git-scm.com/download/win%RESET%
    pause
    exit /b
)

:MENU
cls
echo %BOLD%%CYAN%╔══════════════════════════════════════════════════════════╗%RESET%
echo %BOLD%%CYAN%║              GIT МЕНЕДЖЕР РЕПОЗИТОРИЕВ                   ║%RESET%
echo %BOLD%%CYAN%╚══════════════════════════════════════════════════════════╝%RESET%
echo %YELLOW%=====================By AtinsS==============================%RESET%
echo.

:: Загружаем список сохраненных репозиториев
set count=0
if exist "%CONFIG_FILE%" (
    echo %BOLD%%WHITE%Сохраненные репозитории:%RESET%
    echo %BLUE%------------------------%RESET%
    for /f "usebackq tokens=1,2 delims=;" %%a in ("%CONFIG_FILE%") do (
        set /a count+=1
        set "repo_name_!count!=%%a"
        set "repo_path_!count!=%%b"
        echo %GREEN%!count!. %BOLD%%%a%RESET% - %CYAN%%%b%RESET%
    )
) else (
    echo %YELLOW%Список репозиториев пуст%RESET%
)

echo.
echo %BOLD%%WHITE%Действия:%RESET%
echo %BLUE%========%RESET%
if %count% gtr 0 echo %GREEN%Введите номер репозитория (1-%count%)%RESET%
echo %CYAN%C.%RESET% Клонировать новый репозиторий
echo %CYAN%A.%RESET% Добавить существующий локальный репозиторий
echo %CYAN%U.%RESET% Обновить все репозитории
echo %CYAN%D.%RESET% Удалить репозиторий из списка
echo %CYAN%S.%RESET% Настройки
echo %RED%X.%RESET% Выход
echo.
set /p "action=%BOLD%%WHITE%Ваш выбор: %RESET%"

:: Проверяем, число или буква
set is_number=0
echo %action%| findstr /r "^[0-9][0-9]*$" >nul
if not errorlevel 1 set is_number=1

if %is_number%==1 (
    if %action% leq %count% (
        set "repo_index=%action%"
        call :SELECT_REPO
        goto MENU
    ) else (
        echo %RED%Неверный номер!%RESET%
        pause
        goto MENU
    )
) else (
    if /i "%action%"=="C" goto CLONE_REPO
    if /i "%action%"=="A" goto ADD_EXISTING
    if /i "%action%"=="U" goto UPDATE_ALL
    if /i "%action%"=="D" goto DELETE_REPO
    if /i "%action%"=="S" goto SETTINGS
    if /i "%action%"=="X" exit /b
    goto MENU
)

:SELECT_REPO
:: Получаем имя и путь по индексу
set "REPO_NAME=!repo_name_%repo_index%!"
set "REPO_PATH=!repo_path_%repo_index%!"

echo.
echo %BOLD%%WHITE%Выбран репозиторий:%RESET% %GREEN%%REPO_NAME%%RESET%
echo %BOLD%%WHITE%Путь:%RESET% %CYAN%%REPO_PATH%%RESET%

:: Проверяем существует ли папка
if not exist "%REPO_PATH%" (
    echo.
    echo %RED%⚠ ПРЕДУПРЕЖДЕНИЕ: Папка не найдена!%RESET%
    echo.
    echo %GREEN%1.%RESET% Клонировать заново
    echo %YELLOW%2.%RESET% Указать новый путь
    echo %RED%3.%RESET% Вернуться в меню
    echo.
    set /p "fix=%BOLD%%WHITE%Выберите действие: %RESET%"
    
    if "!fix!"=="1" (
        call :CLONE_REPO_EXISTING "%REPO_NAME%" "%REPO_PATH%"
        goto :eof
    ) else if "!fix!"=="2" (
        set /p "REPO_PATH=%YELLOW%Новый путь: %RESET%"
        call :UPDATE_REPO_PATH "%REPO_NAME%" "!REPO_PATH!"
        cd /d "!REPO_PATH!" 2>nul
    ) else (
        goto :eof
    )
) else (
    cd /d "%REPO_PATH%" 2>nul
)

:: Проверяем что перешли успешно
if errorlevel 1 (
    echo %RED%Ошибка: Не могу перейти в папку!%RESET%
    pause
    goto :eof
)

:: Проверяем что это git репозиторий
git status >nul 2>&1
if errorlevel 1 (
    echo %RED%Ошибка: Папка не является git репозиторием!%RESET%
    pause
    goto :eof
)

call :REPO_MENU "%REPO_NAME%"
goto :eof

:REPO_MENU
set "current_repo=%~1"

:REPO_LOOP
cls
echo %CYAN%════════════════════════════════════════════════════════════%RESET%
echo %BOLD%%WHITE%      Репозиторий:%RESET% %GREEN%%current_repo%%RESET%
echo %BOLD%%WHITE%      Путь:%RESET% %YELLOW%%cd%%RESET%
echo %CYAN%════════════════════════════════════════════════════════════%RESET%
echo.
echo %GREEN%1.%RESET% Git status (проверить состояние)
echo %GREEN%2.%RESET% Git pull (обновить)
echo %GREEN%3.%RESET% Git add + commit (с комментарием)
echo %GREEN%4.%RESET% Git push (отправить)
echo %GREEN%5.%RESET% Быстрый commit + push (авто-комментарий)
echo %GREEN%6.%RESET% Просмотр истории (git log)
echo %GREEN%7.%RESET% Создать ветку
echo %GREEN%8.%RESET% Переключить ветку
echo %GREEN%9.%RESET% Авто-коммиты (каждые N минут)
echo %RED%0.%RESET% Вернуться в главное меню
echo.
set /p "repo_action=%BOLD%%WHITE%Выберите действие: %RESET%"

if "%repo_action%"=="1" call "%SCRIPT_DIR%\git-scripts\01-git-status.bat" "%current_repo%"
if "%repo_action%"=="2" call "%SCRIPT_DIR%\git-scripts\02-git-pull.bat" "%current_repo%"
if "%repo_action%"=="3" call "%SCRIPT_DIR%\git-scripts\03-git-commit.bat" "%current_repo%"
if "%repo_action%"=="4" call "%SCRIPT_DIR%\git-scripts\04-git-push.bat" "%current_repo%"
if "%repo_action%"=="5" call "%SCRIPT_DIR%\git-scripts\05-git-quick-push.bat" "%current_repo%"
if "%repo_action%"=="6" call "%SCRIPT_DIR%\git-scripts\06-git-log.bat" "%current_repo%"
if "%repo_action%"=="7" call "%SCRIPT_DIR%\git-scripts\07-git-create-branch.bat" "%current_repo%"
if "%repo_action%"=="8" call "%SCRIPT_DIR%\git-scripts\08-git-switch-branch.bat" "%current_repo%"
if "%repo_action%"=="9" call "%SCRIPT_DIR%\git-scripts\09-git-auto-commit.bat" "%current_repo%"
if "%repo_action%"=="0" goto MENU

goto REPO_LOOP

:CLONE_REPO
cls
echo %BOLD%%CYAN%=== КЛОНИРОВАНИЕ РЕПОЗИТОРИЯ ===%RESET%
echo.
set /p "repo_name=%GREEN%Имя репозитория (для сохранения): %RESET%"
set /p "repo_url=%YELLOW%URL репозитория (https://github.com/...): %RESET%"
set /p "clone_path=%BLUE%Путь для клонирования (Enter - текущая папка): %RESET%"

if "!clone_path!"=="" set "clone_path=%cd%"

:: Создаем папку если её нет
if not exist "!clone_path!" mkdir "!clone_path!"

set "full_path=!clone_path!\!repo_name!"

echo.
echo %BOLD%Клонирование %repo_name% из %repo_url% в %full_path%...%RESET%
git clone "%repo_url%" "%full_path%"

if errorlevel 1 (
    echo %RED%Ошибка клонирования!%RESET%
    pause
    goto MENU
)

:: Сохраняем в конфиг (в папку с батником!)
echo %repo_name%;%full_path% >> "%CONFIG_FILE%"
echo.
echo %GREEN%Репозиторий успешно клонирован и добавлен в список!%RESET%
pause
goto MENU

:ADD_EXISTING
cls
echo %BOLD%%CYAN%=== ДОБАВЛЕНИЕ СУЩЕСТВУЮЩЕГО РЕПОЗИТОРИЯ ===%RESET%
echo.
set /p "repo_name=%GREEN%Имя репозитория: %RESET%"
set /p "repo_path=%YELLOW%Полный путь к репозиторию: %RESET%"

:: Убираем возможные кавычки из пути
set "repo_path=%repo_path:"=%

:: Проверяем, что путь не пустой
if "!repo_path!"=="" (
    echo %RED%Ошибка: Путь не может быть пустым!%RESET%
    pause
    goto MENU
)

:: Проверяем, что это git репозиторий
if not exist "!repo_path!" (
    echo %RED%Ошибка: Папка не найдена!%RESET%
    pause
    goto MENU
)

:: Временно переходим в папку репозитория для проверки
pushd "!repo_path!" 2>nul
if errorlevel 1 (
    echo %RED%Ошибка: Не могу перейти в папку!%RESET%
    pause
    goto MENU
)

git status >nul 2>&1
if errorlevel 1 (
    echo %RED%Ошибка: Папка не является git репозиторием!%RESET%
    popd
    pause
    goto MENU
)
popd

:: Сохраняем в конфиг (в папку с батником!)
echo %repo_name%;!repo_path! >> "%CONFIG_FILE%"
echo.
echo %GREEN%Репозиторий добавлен в список!%RESET%
pause
goto MENU

:UPDATE_ALL
cls
echo %BOLD%%CYAN%=== ОБНОВЛЕНИЕ ВСЕХ РЕПОЗИТОРИЕВ ===%RESET%
echo.

if not exist "%CONFIG_FILE%" (
    echo %RED%Нет сохраненных репозиториев!%RESET%
    pause
    goto MENU
)

for /f "usebackq tokens=1,2 delims=;" %%a in ("%CONFIG_FILE%") do (
    echo.
    echo %BOLD%%BLUE%===== Обработка:%RESET% %GREEN%%%a%RESET% %BLUE%=====%RESET%
    if exist "%%b" (
        pushd "%%b" 2>nul
        if not errorlevel 1 (
            echo %YELLOW%Обновление...%RESET%
            git pull
            popd
        ) else (
            echo %RED%⚠ Не могу перейти в папку%RESET%
        )
    ) else (
        echo %RED%⚠ Папка не найдена: %%b%RESET%
    )
)

echo.
echo %GREEN%Обновление завершено!%RESET%
pause
goto MENU

:DELETE_REPO
cls
echo %BOLD%%CYAN%=== УДАЛЕНИЕ РЕПОЗИТОРИЯ ИЗ СПИСКА ===%RESET%
echo.

if not exist "%CONFIG_FILE%" (
    echo %RED%Нет репозиториев для удаления!%RESET%
    pause
    goto MENU
)

:: Показываем список с номерами
set idx=1
for /f "usebackq tokens=1,2 delims=;" %%a in ("%CONFIG_FILE%") do (
    echo %GREEN%!idx!.%RESET% %%a - %CYAN%%%b%RESET%
    set /a idx+=1
)

echo.
set /p "del_num=%BOLD%%RED%Номер репозитория для удаления: %RESET%"

:: Создаем новый конфиг без удаленной строки
set skip_line=%del_num%
set current=0
if exist "%CONFIG_FILE%" (
    for /f "usebackq tokens=1,2 delims=;" %%a in ("%CONFIG_FILE%") do (
        set /a current+=1
        if not !current!==%skip_line% (
            echo %%a;%%b >> "%TEMP_FILE%"
        )
    )
    move /y "%TEMP_FILE%" "%CONFIG_FILE%" >nul 2>nul
)

echo %GREEN%Репозиторий удален из списка!%RESET%
pause
goto MENU

:SETTINGS
cls
echo %BOLD%%CYAN%=== НАСТРОЙКИ ===%RESET%
echo.
echo %GREEN%1.%RESET% Показать все репозитории
echo %YELLOW%2.%RESET% Очистить список
echo %BLUE%3.%RESET% Редактировать пути вручную
echo %RED%4.%RESET% Назад
echo.
set /p "sett=%BOLD%%WHITE%Выберите: %RESET%"

if "%sett%"=="1" (
    cls
    echo %BOLD%%WHITE%Список репозиториев:%RESET%
    echo %BLUE%===================%RESET%
    if exist "%CONFIG_FILE%" (
        for /f "usebackq tokens=1,2 delims=;" %%a in ("%CONFIG_FILE%") do (
            echo %GREEN%%%a%RESET% - %CYAN%%%b%RESET%
        )
    ) else (
        echo %YELLOW%Список пуст%RESET%
    )
    echo.
    pause
    goto SETTINGS
)

if "%sett%"=="2" (
    del "%CONFIG_FILE%" 2>nul
    echo %GREEN%Список очищен!%RESET%
    pause
    goto SETTINGS
)

if "%sett%"=="3" (
    if exist "%CONFIG_FILE%" (
        notepad "%CONFIG_FILE%"
    ) else (
        echo %RED%Список пуст, нечего редактировать%RESET%
        pause
    )
    goto SETTINGS
)

goto MENU

:CLONE_REPO_EXISTING
set "repo_name=%~1"
set "repo_path=%~2"
set "repo_dir=%repo_path%"

echo.
echo %YELLOW%Введите URL для клонирования %repo_name%:%RESET%
set /p "repo_url=%BOLD%URL: %RESET%"

echo %BOLD%Клонирование %repo_name%...%RESET%
if exist "%repo_dir%" (
    rd /s /q "%repo_dir%" 2>nul
)
git clone "%repo_url%" "%repo_dir%"
if errorlevel 1 (
    echo %RED%Ошибка клонирования!%RESET%
) else (
    echo %GREEN%Готово!%RESET%
)
echo.
pause
goto :eof

:UPDATE_REPO_PATH
set "repo_name=%~1"
set "new_path=%~2"

:: Обновляем путь в конфиге (который в папке с батником!)
if exist "%CONFIG_FILE%" (
    for /f "usebackq tokens=1,2 delims=;" %%a in ("%CONFIG_FILE%") do (
        if "%%a"=="%repo_name%" (
            echo %%a;%new_path% >> "%TEMP_FILE%"
        ) else (
            echo %%a;%%b >> "%TEMP_FILE%"
        )
    )
    move /y "%TEMP_FILE%" "%CONFIG_FILE%" >nul 2>nul
)
goto :eof