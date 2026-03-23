@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: Цветовое оформление
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

:: Запоминаем путь к папке с батником
set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"

:: Путь к конфигам
set "CONFIG_FILE=%SCRIPT_DIR%\git_repos.cfg"
set "GROUPS_FILE=%SCRIPT_DIR%\groups.cfg"
set "TEMP_FILE=%SCRIPT_DIR%\temp.cfg"

:MENU
cls
echo %BOLD%%CYAN%  🚀 GIT МЕНЕДЖЕР - Управление репозиториями  %RESET%
echo %YELLOW%  ═══════════════════ By AtinsS ═══════════════════%RESET%
echo.

:: Загружаем список сохраненных репозиториев
set count=0
if exist "%CONFIG_FILE%" (
  echo %BOLD%%WHITE%  Список репозиториев:%RESET%
  
  :: Сначала показываем по группам
  if exist "%GROUPS_FILE%" (
    for /f "usebackq tokens=1,* delims=;" %%a in ("%GROUPS_FILE%") do (
      echo.
      echo %BOLD%%MAGENTA%  📁 Группа: %%a%RESET%
      set "group_repos=%%b"
      if not "!group_repos!"=="" (
        for %%r in (!group_repos!) do (
          set "repo_found=0"
          for /f "usebackq tokens=1,* delims=;" %%x in ("%CONFIG_FILE%") do (
            if "%%x"=="%%r" (
              set /a count+=1
              set "repo_name_!count!=%%x"
              set "repo_path_!count!=%%y"
              call :GET_REPO_STATUS "%%y" status_!count!
              echo  %GREEN%!count!.%RESET% !status_! %%x !branch_!
              set "repo_found=1"
            )
          )
          if !repo_found!==0 (
            echo  %RED%⚠ Репозиторий "%%r" не найден%RESET%
          )
        )
        ) else (
        echo  %YELLOW%группа пуста%RESET%
      )
    )
  )
  
  :: Показываем репозитории без группы
  set "temp_count=0"
  for /f "usebackq tokens=1,* delims=;" %%a in ("%CONFIG_FILE%") do (
    set "found=0"
    if exist "%GROUPS_FILE%" (
      for /f "usebackq tokens=2 delims=;" %%g in ("%GROUPS_FILE%") do (
        echo "%%g" | find "%%a" >nul && set "found=1"
      )
    )
    if !found!==0 (
      set /a temp_count+=1
    )
  )
  
  if !temp_count! gtr 0 (
    echo.
    echo %BOLD%%YELLOW%  📁 Без группы:%RESET%
    for /f "usebackq tokens=1,* delims=;" %%a in ("%CONFIG_FILE%") do (
      set "found=0"
      if exist "%GROUPS_FILE%" (
        for /f "usebackq tokens=2 delims=;" %%g in ("%GROUPS_FILE%") do (
          echo "%%g" | find "%%a" >nul && set "found=1"
        )
      )
      if !found!==0 (
        set /a count+=1
        set "repo_name_!count!=%%a"
        set "repo_path_!count!=%%b"
        call :GET_REPO_STATUS "%%b" status_!count!
        echo  %GREEN%!count!.%RESET% !status_! %%a !branch_!
      )
    )
  )
  ) else (
  echo %YELLOW%  Список репозиториев пока пуст%RESET%
)

echo.
echo %BOLD%%WHITE%  Меню действий:%RESET%
if %count% gtr 0 echo %GREEN%  1-%count%:%RESET% Выбрать репозиторий по номеру
echo %CYAN%  C:%RESET% Клонировать новый репозиторий
echo %CYAN%  A:%RESET% Добавить существующий локальный репозиторий
echo %CYAN%  U:%RESET% Обновить все репозитории
echo %CYAN%  G:%RESET% Управление группами
echo %CYAN%  D:%RESET% Удалить репозиторий из списка
echo %CYAN%  S:%RESET% Настройки
echo %RED%  X:%RESET% Выход
echo.
set /p "action=%BOLD%%WHITE%    ⚡ Ваш выбор: %RESET%"

:: Проверяем, число или буква
set is_number=0
echo %action%| findstr /r "^[0-9][0-9]*$" >nul 2>&1
if not errorlevel 1 set is_number=1

if %is_number%==1 (
  if %action% leq %count% (
    set "repo_index=%action%"
    call :SELECT_REPO
    goto MENU
    ) else (
    echo %RED%  ❌ Неверный номер!%RESET%
    pause
    goto MENU
  )
  ) else (
  if /i "%action%"=="C" goto CLONE_REPO
  if /i "%action%"=="A" goto ADD_EXISTING
  if /i "%action%"=="U" goto UPDATE_ALL
  if /i "%action%"=="G" goto MANAGE_GROUPS
  if /i "%action%"=="D" goto DELETE_REPO
  if /i "%action%"=="S" goto SETTINGS
  if /i "%action%"=="X" exit
  echo %RED%  ❌ Неверный выбор!%RESET%
  pause
  goto MENU
)

:GET_REPO_STATUS
set "repo_path=%~1"
set "status_var=%~2"
set "branch_info="

if exist "%repo_path%" (
  pushd "%repo_path%" 2>nul
  if not errorlevel 1 (
    :: Получаем текущую ветку
    set "branch_info="
    for /f "tokens=*" %%b in ('git branch --show-current 2^>nul') do set "branch_info=%%b"
    if "!branch_info!"=="" (
      for /f "tokens=2" %%b in ('git branch 2^>nul ^| find "*"') do set "branch_info=%%b"
    )
    if not "!branch_info!"=="" (
      set "branch_info=%CYAN%[!branch_info!]%RESET%"
      ) else (
      set "branch_info=%RED%[нет ветки]%RESET%"
    )
    
    :: Проверяем статус
    git status --porcelain >nul 2>&1
    if errorlevel 1 (
      set "status_icon=%RED%[✗]%RESET%"
      ) else (
      git status --porcelain | findstr . >nul 2>&1
      if errorlevel 1 (
        set "status_icon=%GREEN%[✓]%RESET%"
        ) else (
        set "status_icon=%YELLOW%[!]%RESET%"
      )
    )
    popd
    ) else (
    set "status_icon=%RED%[!]%RESET%"
    set "branch_info=%RED%[нет доступа]%RESET%"
  )
  ) else (
  set "status_icon=%RED%[?]%RESET%"
  set "branch_info=%RED%[папка не найдена]%RESET%"
)

set "%status_var%=!status_icon!"
set "branch_%count%=!branch_info!"
goto :eof

:SELECT_REPO
:: Получаем имя и путь по индексу
set "REPO_NAME=!repo_name_%repo_index%!"
set "REPO_PATH=!repo_path_%repo_index%!"

echo.
echo %BOLD%%WHITE%  Выбран репозиторий:%RESET% %GREEN%📁 %REPO_NAME%%RESET%
echo %BOLD%%WHITE%  Путь:%RESET% %CYAN%📌 %REPO_PATH%%RESET%

:: Проверяем существует ли папка
if not exist "%REPO_PATH%" (
  echo.
  echo %RED%  ⚠ ПРЕДУПРЕЖДЕНИЕ: Папка не найдена!%RESET%
  echo.
  echo %GREEN%  1.%RESET% Клонировать заново
  echo %YELLOW%  2.%RESET% Указать новый путь
  echo %RED%  3.%RESET% Вернуться в меню
  echo.
  set /p "fix=%BOLD%%WHITE%    Выберите действие: %RESET%"
  
  if "!fix!"=="1" (
    call :CLONE_REPO_EXISTING "%REPO_NAME%" "%REPO_PATH%"
    goto :eof
    ) else if "!fix!"=="2" (
    set /p "REPO_PATH=%YELLOW%    Новый путь: %RESET%"
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
  echo %RED%  ❌ Ошибка: Не могу перейти в папку!%RESET%
  pause
  goto :eof
)

:: Проверяем что это git репозиторий
git status >nul 2>&1
if errorlevel 1 (
  echo %RED%  ❌ Ошибка: Папка не является git репозиторием!%RESET%
  pause
  goto :eof
)

call :REPO_MENU "%REPO_NAME%"
goto :eof

:REPO_MENU
set "current_repo=%~1"

:REPO_LOOP
cls
:: Получаем текущую ветку для отображения
set "current_branch="
for /f "tokens=*" %%b in ('git branch --show-current 2^>nul') do set "current_branch=%%b"
if "!current_branch!"=="" (
  for /f "tokens=2" %%b in ('git branch 2^>nul ^| find "*"') do set "current_branch=%%b"
)
if "!current_branch!"=="" set "current_branch=неизвестно"

:: Получаем статус
git status --porcelain | findstr . >nul 2>&1
if errorlevel 1 (
  set "repo_status=%GREEN%✅ чисто%RESET%"
  ) else (
  set "repo_status=%YELLOW%⚠ есть изменения%RESET%"
)

echo %CYAN%  ════════════════════════════════════════════════════════════%RESET%
echo %BOLD%%WHITE%  Репозиторий:%RESET% %GREEN%%current_repo%%RESET%  %BOLD%%WHITE%Ветка:%RESET% %BLUE%!current_branch!%RESET%
echo %BOLD%%WHITE%  Статус:%RESET% !repo_status!
echo %CYAN%  ════════════════════════════════════════════════════════════%RESET%
echo.
echo %GREEN%  1.%RESET% Git status (проверить состояние)
echo %GREEN%  2.%RESET% Git pull (обновить)
echo %GREEN%  3.%RESET% Git add + commit + push (с комментарием)
echo %GREEN%  4.%RESET% Перейти в меню отмены изменений
echo %GREEN%  5.%RESET% Просмотр истории (git log)
echo %GREEN%  6.%RESET% Git merge (слияние веток)
echo %GREEN%  7.%RESET% Git merge --abort (отменить слияние)
echo %GREEN%  8.%RESET% Показать ветки для слияния
echo %GREEN%  9.%RESET% Создать ветку
echo %GREEN%  10.%RESET% Переключить ветку
echo %GREEN%  11.%RESET% Авто-коммиты (каждые N минут)

echo %RED%  0.%RESET% Вернуться в главное меню
echo.
set /p "repo_action=%BOLD%%WHITE%    ⚡ Выберите действие: %RESET%"

:: Проверяем существование скриптов
if not exist "%SCRIPT_DIR%\git-scripts" (
  mkdir "%SCRIPT_DIR%\git-scripts" 2>nul
)

if "%repo_action%"=="1" (
  cls
  echo %BOLD%%CYAN%  === GIT STATUS ===%RESET%
  echo.
  if exist "%SCRIPT_DIR%\git-scripts\01-git-status.bat" (
    call "%SCRIPT_DIR%\git-scripts\01-git-status.bat" "%current_repo%"
    ) else (
    git status
  )
  pause
  goto REPO_LOOP
)
if "%repo_action%"=="2" (
  cls
  echo %BOLD%%CYAN%  === GIT PULL ===%RESET%
  echo.
  if exist "%SCRIPT_DIR%\git-scripts\02-git-pull.bat" (
    call "%SCRIPT_DIR%\git-scripts\02-git-pull.bat" "%current_repo%"
    ) else (
    git pull
  )
  pause
  goto REPO_LOOP
)
if "%repo_action%"=="3" (
  cls
  echo %BOLD%%CYAN%  === GIT COMMIT ===%RESET%
  echo.
  if exist "%SCRIPT_DIR%\git-scripts\03-git-commit.bat" (
    call "%SCRIPT_DIR%\git-scripts\03-git-commit.bat" "%current_repo%"
    ) else (
    set /p "commit_msg=%YELLOW%    Комментарий: %RESET%"
    git add . && git commit -m "!commit_msg!"
  )
  pause
  goto REPO_LOOP
)

if "%repo_action%"=="4" (
    cls
  if exist "%SCRIPT_DIR%\git-scripts\04-git-menu-revert.bat" (
    call "%SCRIPT_DIR%\git-scripts\04-git-menu-revert.bat" "%current_repo%"
    ) else (
    echo %RED%  ❌ Скрипт меню отката не найден%RESET%
  )
  pause
  goto REPO_LOOP
)

if "%repo_action%"=="5" (
  cls
  echo %BOLD%%CYAN%  === GIT LOG ===%RESET%
  echo.
  if exist "%SCRIPT_DIR%\git-scripts\05-git-log.bat" (
    call "%SCRIPT_DIR%\git-scripts\05-git-log.bat" "%current_repo%"
    ) else (
    git log --oneline --graph --all -n 20
  )
  pause
  goto REPO_LOOP
  
)

if "%repo_action%"=="6" (
  
  if exist "%SCRIPT_DIR%\git-scripts\06-git-merge.bat" (
    call "%SCRIPT_DIR%\git-scripts\06-git-merge.bat" "%current_repo%"
    ) else (
    echo %RED%  ❌ Скрипт слияния не найден%RESET%
    pause
  )
  goto REPO_LOOP
)
if "%repo_action%"=="7" (
  
  if exist "%SCRIPT_DIR%\git-scripts\07-git-merge-abort.bat" (
    call "%SCRIPT_DIR%\git-scripts\07-git-merge-abort.bat" "%current_repo%"
    ) else (
    echo %RED%  ❌ Скрипт отмены слияния не найден%RESET%
    pause
  )
  goto REPO_LOOP
)
if "%repo_action%"=="8" (
  
  if exist "%SCRIPT_DIR%\git-scripts\08-git-merge-list.bat" (
    call "%SCRIPT_DIR%\git-scripts\08-git-merge-list.bat" "%current_repo%"
    ) else (
    echo %RED%  ❌ Скрипт просмотра веток не найден%RESET%
    pause
  )
  goto REPO_LOOP
)
if "%repo_action%"=="9" (
  cls
  echo %BOLD%%CYAN%  === СОЗДАНИЕ ВЕТКИ ===%RESET%
  echo.
  if exist "%SCRIPT_DIR%\git-scripts\09-git-create-branch.bat" (
    call "%SCRIPT_DIR%\git-scripts\09-git-create-branch.bat" "%current_repo%"
    ) else (
    set /p "branch_name=%YELLOW%    Имя ветки: %RESET%"
    git branch "!branch_name!"
  )
  pause
  goto REPO_LOOP
)
if "%repo_action%"=="10" (
  cls
  echo %BOLD%%CYAN%  === ПЕРЕКЛЮЧЕНИЕ ВЕТКИ ===%RESET%
  echo.
  if exist "%SCRIPT_DIR%\git-scripts\10-git-switch-branch.bat" (
    call "%SCRIPT_DIR%\git-scripts\10-git-switch-branch.bat" "%current_repo%"
    ) else (
    git branch
    echo.
    set /p "branch_name=%YELLOW%    Ветка для переключения: %RESET%"
    git checkout "!branch_name!"
  )
  pause
  goto REPO_LOOP
)
if "%repo_action%"=="11" (
  cls
  echo %BOLD%%CYAN%  === АВТО-КОММИТЫ ===%RESET%
  echo.
  if exist "%SCRIPT_DIR%\git-scripts\11-git-auto-commit.bat" (
    call "%SCRIPT_DIR%\git-scripts\11-git-auto-commit.bat" "%current_repo%"
    ) else (
    echo %RED%  ❌ Скрипт авто-коммитов не найден%RESET%
  )
  pause
  goto REPO_LOOP
)
if "%repo_action%"=="0" goto MENU

echo %RED%  ❌ Неверный выбор!%RESET%
pause
goto REPO_LOOP

:CLONE_REPO
cls
echo %BOLD%%CYAN%  📥 КЛОНИРОВАНИЕ РЕПОЗИТОРИЯ%RESET%
echo.
set /p "repo_name=%GREEN%    📦 Имя репозитория: %RESET%"
set /p "repo_url=%YELLOW%    🔗 URL репозитория: %RESET%"
set /p "clone_path=%BLUE%    📁 Путь для клонирования (Enter - текущая папка): %RESET%"

if "!clone_path!"=="" set "clone_path=%cd%"
if not exist "!clone_path!" mkdir "!clone_path!" 2>nul

set "full_path=!clone_path!\!repo_name!"

echo.
echo %BOLD%  ⏳ Клонирование %repo_name% из %repo_url% в %full_path%...%RESET%
git clone "%repo_url%" "%full_path%"

if errorlevel 1 (
  echo %RED%  ❌ Ошибка клонирования!%RESET%
  pause
  goto MENU
)

echo %repo_name%;%full_path% >> "%CONFIG_FILE%"
echo %GREEN%  ✅ Репозиторий успешно клонирован и добавлен в список!%RESET%

:: Спрашиваем про группу
echo.
echo %BOLD%%WHITE%  Добавление в группу:%RESET%
set /p "add_to_group=%YELLOW%    Добавить репозиторий в группу? [д/н]: %RESET%"

if /i "!add_to_group!"=="д" (
  call :ADD_REPO_TO_GROUP "%repo_name%"
  ) else if /i "!add_to_group!"=="y" (
  call :ADD_REPO_TO_GROUP "%repo_name%"
  ) else if /i "!add_to_group!"=="да" (
  call :ADD_REPO_TO_GROUP "%repo_name%"
)

pause
goto MENU

:ADD_EXISTING
cls
echo %BOLD%%CYAN%  📂 ДОБАВЛЕНИЕ СУЩЕСТВУЮЩЕГО РЕПОЗИТОРИЯ%RESET%
echo.
set /p "repo_name=%GREEN%    📦 Имя репозитория: %RESET%"
set /p "repo_path=%YELLOW%    📁 Полный путь к репозиторию: %RESET%"

set "repo_path=%repo_path:"=%"

if "!repo_path!"=="" (
  echo %RED%  ❌ Ошибка: Путь не может быть пустым!%RESET%
  pause
  goto MENU
)

if not exist "!repo_path!" (
  echo %RED%  ❌ Ошибка: Папка не найдена!%RESET%
  pause
  goto MENU
)

pushd "!repo_path!" 2>nul
if errorlevel 1 (
  echo %RED%  ❌ Ошибка: Не могу перейти в папку!%RESET%
  pause
  goto MENU
)

git status >nul 2>&1
if errorlevel 1 (
  echo %RED%  ❌ Ошибка: Папка не является git репозиторием!%RESET%
  popd
  pause
  goto MENU
)
popd

:: Сохраняем в конфиг
echo %repo_name%;!repo_path! >> "%CONFIG_FILE%"
echo %GREEN%  ✅ Репозиторий добавлен в список!%RESET%

:: Спрашиваем про группу
echo.
echo %BOLD%%WHITE%  Добавление в группу:%RESET%
set /p "add_to_group=%YELLOW%    Добавить репозиторий в группу? [д/н]: %RESET%"

if /i "!add_to_group!"=="д" (
  call :ADD_REPO_TO_GROUP "%repo_name%"
  ) else if /i "!add_to_group!"=="y" (
  call :ADD_REPO_TO_GROUP "%repo_name%"
  ) else if /i "!add_to_group!"=="да" (
  call :ADD_REPO_TO_GROUP "%repo_name%"
)

pause
goto MENU

:ADD_REPO_TO_GROUP
set "repo_to_add=%~1"

:: Проверяем есть ли группы
if not exist "%GROUPS_FILE%" (
  echo %YELLOW%  ⚠ Нет созданных групп. Хотите создать новую?%RESET%
  set /p "create_new=%YELLOW%    [д/н]: %RESET%"
  if /i "!create_new!"=="д" (
    call :CREATE_GROUP_FROM_ADD "%repo_to_add%"
    ) else if /i "!create_new!"=="y" (
    call :CREATE_GROUP_FROM_ADD "%repo_to_add%"
    ) else if /i "!create_new!"=="да" (
    call :CREATE_GROUP_FROM_ADD "%repo_to_add%"
  )
  goto :eof
  ) else (
  :: Проверяем, есть ли вообще группы в файле (может быть пустой файл)
  set "group_exists=0"
  for /f "usebackq tokens=1 delims=;" %%a in ("%GROUPS_FILE%") do (
    if not "%%a"=="" set "group_exists=1"
  )
  
  if !group_exists!==0 (
    echo %YELLOW%  ⚠ Нет созданных групп. Хотите создать новую?%RESET%
    set /p "create_new=%YELLOW%    [д/н]: %RESET%"
    if /i "!create_new!"=="д" (
      call :CREATE_GROUP_FROM_ADD "%repo_to_add%"
      ) else if /i "!create_new!"=="y" (
      call :CREATE_GROUP_FROM_ADD "%repo_to_add%"
      ) else if /i "!create_new!"=="да" (
      call :CREATE_GROUP_FROM_ADD "%repo_to_add%"
    )
    goto :eof
  )
  
  :: Показываем существующие группы
  echo.
  echo %BOLD%%WHITE%  Выберите группу:%RESET%
  set group_count=0
  for /f "usebackq tokens=1 delims=;" %%a in ("%GROUPS_FILE%") do (
    if not "%%a"=="" (
      set /a group_count+=1
      set "group_name_add_!group_count!=%%a"
      echo %GREEN%  !group_count!.%RESET% %%a
    )
  )
  echo %GREEN%  0.%RESET% Создать новую группу
  
  echo.
  set /p "group_choice=%BOLD%%WHITE%    ⚡ Ваш выбор: %RESET%"
  
  if "!group_choice!"=="0" (
    call :CREATE_GROUP_FROM_ADD "%repo_to_add%"
    ) else (
    set "selected_group=!group_name_add_%group_choice%!"
    
    :: Добавляем в выбранную группу
    set "temp_groups=%TEMP%\groups.tmp"
    if exist "%GROUPS_FILE%" (
      type nul > "!temp_groups!"
      for /f "usebackq tokens=1,* delims=;" %%a in ("%GROUPS_FILE%") do (
        if "%%a"=="!selected_group!" (
          :: Проверяем, не пустой ли список репозиториев
          if "%%b"=="" (
            echo %%a;!repo_to_add!>> "!temp_groups!"
            ) else (
            :: Проверяем, не находится ли репозиторий уже в группе
            echo "%%b" | find "!repo_to_add!" >nul 2>&1
            if errorlevel 1 (
              echo %%a;%%b !repo_to_add!>> "!temp_groups!"
              echo %GREEN%  ✅ Репозиторий "%repo_to_add%" добавлен в группу "%selected_group%"%RESET%
              ) else (
              echo %%a;%%b>> "!temp_groups!"
              echo %YELLOW%  ⚠ Репозиторий "%repo_to_add%" уже находится в группе "%selected_group%"%RESET%
            )
          )
          ) else (
          echo %%a;%%b>> "!temp_groups!"
        )
      )
      move /y "!temp_groups!" "%GROUPS_FILE%" >nul 2>&1
    )
  )
)
goto :eof

:CREATE_GROUP_FROM_ADD
set "repo_to_add=%~1"
echo.
set /p "new_group=%GREEN%    📝 Введите название новой группы: %RESET%"

if "!new_group!"=="" (
  echo %RED%  ❌ Название не может быть пустым!%RESET%
  pause
  goto :eof
)

:: Проверяем, существует ли уже такая группа
if exist "%GROUPS_FILE%" (
  findstr /b "!new_group!;" "%GROUPS_FILE%" >nul 2>&1
  if not errorlevel 1 (
    echo %RED%  ❌ Группа с таким именем уже существует!%RESET%
    pause
    goto :eof
  )
)

:: Создаем группу и добавляем репозиторий
echo !new_group!;%repo_to_add%>> "%GROUPS_FILE%"
echo %GREEN%  ✅ Группа "%new_group%" создана и репозиторий добавлен!%RESET%
pause
goto :eof

:UPDATE_ALL
cls
echo %BOLD%%CYAN%  🔄 ОБНОВЛЕНИЕ ВСЕХ РЕПОЗИТОРИЕВ%RESET%
echo.

if not exist "%CONFIG_FILE%" (
  echo %RED%  ❌ Нет сохраненных репозиториев!%RESET%
  pause
  goto MENU
)

for /f "usebackq tokens=1,2 delims=;" %%a in ("%CONFIG_FILE%") do (
  echo.
  echo %BOLD%%BLUE%  [%%a]%RESET%
  if exist "%%b" (
    pushd "%%b" 2>nul
    if not errorlevel 1 (
      echo %YELLOW%  Обновление...%RESET%
      git pull
      popd
      ) else (
      echo %RED%  ⚠ Не могу перейти в папку%RESET%
    )
    ) else (
    echo %RED%  ⚠ Папка не найдена: %%b%RESET%
  )
)

echo.
echo %GREEN%  ✅ Обновление завершено!%RESET%
pause
goto MENU

:DELETE_REPO
cls
echo %BOLD%%CYAN%  🗑️ УДАЛЕНИЕ РЕПОЗИТОРИЯ ИЗ СПИСКА%RESET%
echo.

if not exist "%CONFIG_FILE%" (
  echo %RED%  ❌ Нет репозиториев для удаления!%RESET%
  pause
  goto MENU
)

set idx=1
for /f "usebackq tokens=1,2 delims=;" %%a in ("%CONFIG_FILE%") do (
  echo %GREEN%!idx!.%RESET% %%a - %CYAN%%%b%RESET%
  set /a idx+=1
)

echo.
set /p "del_num=%BOLD%%RED%    ⚠ Номер репозитория для удаления: %RESET%"

set skip_line=%del_num%
set current=0
type nul > "%TEMP_FILE%"
if exist "%CONFIG_FILE%" (
  for /f "usebackq tokens=1,2 delims=;" %%a in ("%CONFIG_FILE%") do (
    set /a current+=1
    if not !current!==%skip_line% (
      echo %%a;%%b >> "%TEMP_FILE%"
      ) else (
      set "deleted_repo=%%a"
    )
  )
  move /y "%TEMP_FILE%" "%CONFIG_FILE%" >nul 2>nul
)

:: Удаляем репозиторий из всех групп
if exist "%GROUPS_FILE%" (
  set "temp_groups=%TEMP%\groups.tmp"
  type nul > "!temp_groups!"
  for /f "usebackq tokens=1,* delims=;" %%a in ("%GROUPS_FILE%") do (
    set "new_repo_list="
    set "first_repo=1"
    if not "%%b"=="" (
      for %%r in (%%b) do (
        if not "%%r"=="!deleted_repo!" (
          if !first_repo!==1 (
            set "new_repo_list=%%r"
            set "first_repo=0"
            ) else (
            set "new_repo_list=!new_repo_list! %%r"
          )
        )
      )
    )
    echo %%a;!new_repo_list!>> "!temp_groups!"
  )
  move /y "!temp_groups!" "%GROUPS_FILE%" >nul 2>nul
)

echo %GREEN%  ✅ Репозиторий удален из списка и групп!%RESET%
pause
goto MENU

:SETTINGS
cls
echo %BOLD%%CYAN%  ⚙️ НАСТРОЙКИ%RESET%
echo.
echo %GREEN%  1.%RESET% Показать все репозитории
echo %YELLOW%  2.%RESET% Очистить список
echo %BLUE%  3.%RESET% Редактировать пути вручную
echo %MAGENTA%  4.%RESET% Авто-исправление конфигов
echo %RED%  5.%RESET% Назад
echo.
set /p "sett=%BOLD%%WHITE%    ⚡ Выберите: %RESET%"

if "%sett%"=="1" (
  cls
  echo %BOLD%%WHITE%  Список репозиториев:%RESET%
  if exist "%CONFIG_FILE%" (
    for /f "usebackq tokens=1,2 delims=;" %%a in ("%CONFIG_FILE%") do (
      echo %GREEN%  📦 %%a%RESET% - %CYAN%%%b%RESET%
    )
    ) else (
    echo %YELLOW%  Список пуст%RESET%
  )
  echo.
  pause
  goto SETTINGS
)

if "%sett%"=="2" (
  del "%CONFIG_FILE%" 2>nul
  del "%GROUPS_FILE%" 2>nul
  echo %GREEN%  ✅ Списки очищены!%RESET%
  pause
  goto SETTINGS
)

if "%sett%"=="3" (
  if exist "%CONFIG_FILE%" (
    notepad "%CONFIG_FILE%"
    ) else (
    echo %RED%  ❌ Список пуст, нечего редактировать%RESET%
    pause
  )
  goto SETTINGS
)

if "%sett%"=="4" (
  call :AUTO_REPAIR_CONFIGS
  goto MENU
)

goto MENU

:CLONE_REPO_EXISTING
set "repo_name=%~1"
set "repo_path=%~2"
set "repo_dir=%repo_path%"

echo.
echo %YELLOW%  Введите URL для клонирования %repo_name%:%RESET%
set /p "repo_url=%BOLD%    URL: %RESET%"

echo %BOLD%  ⏳ Клонирование %repo_name%...%RESET%
if exist "%repo_dir%" (
  rd /s /q "%repo_dir%" 2>nul
)
git clone "%repo_url%" "%repo_dir%"
if errorlevel 1 (
  echo %RED%  ❌ Ошибка клонирования!%RESET%
  ) else (
  echo %GREEN%  ✅ Готово!%RESET%
  
  :: Проверяем, есть ли уже такой репозиторий в конфиге
  findstr /b "%repo_name%;" "%CONFIG_FILE%" >nul 2>&1
  if errorlevel 1 (
    :: Добавляем репозиторий в конфиг, если его там нет
    echo %repo_name%;%repo_dir% >> "%CONFIG_FILE%"
    echo %GREEN%  ✅ Репозиторий добавлен в список!%RESET%
    ) else (
    echo %YELLOW%  ⚠ Репозиторий уже есть в списке%RESET%
  )
)
echo.
pause
goto :eof

:UPDATE_REPO_PATH
set "repo_name=%~1"
set "new_path=%~2"

type nul > "%TEMP_FILE%"
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

:AUTO_REPAIR_CONFIGS
echo %BOLD%%YELLOW%  🔄 Автоматическое исправление конфигураций...%RESET%

:: Исправляем git_repos.cfg
if exist "%CONFIG_FILE%" (
  set "temp_cfg=%TEMP%\git_repos_fixed.cfg"
  type nul > "!temp_cfg!"
  for /f "usebackq tokens=1,* delims=;" %%a in ("%CONFIG_FILE%") do (
    :: Очищаем имя - берем только первое слово
    for /f "tokens=1" %%n in ("%%a") do set "clean_name=%%n"
    :: Очищаем путь - убираем лишние слова в конце
    set "clean_path=%%b"
    echo !clean_name!;!clean_path!>> "!temp_cfg!"
  )
  move /y "!temp_cfg!" "%CONFIG_FILE%" >nul 2>nul
  echo %GREEN%  ✅ git_repos.cfg исправлен%RESET%
)

:: Исправляем groups.cfg
if exist "%GROUPS_FILE%" (
  set "temp_groups=%TEMP%\groups_fixed.cfg"
  type nul > "!temp_groups!"
  for /f "usebackq tokens=1,* delims=;" %%a in ("%GROUPS_FILE%") do (
    set "new_repo_list="
    set "first_repo=1"
    for %%r in (%%b) do (
      :: Очищаем имя репозитория от дубликатов
      for /f "tokens=1" %%n in ("%%r") do set "clean_repo=%%n"
      if !first_repo!==1 (
        set "new_repo_list=!clean_repo!"
        set "first_repo=0"
        ) else (
        set "new_repo_list=!new_repo_list! !clean_repo!"
      )
    )
    echo %%a;!new_repo_list!>> "!temp_groups!"
  )
  move /y "!temp_groups!" "%GROUPS_FILE%" >nul 2>nul
  echo %GREEN%  ✅ groups.cfg исправлен%RESET%
)

echo.
echo %GREEN%  ✅ Исправление завершено! Запустите программу заново.%RESET%
pause
exit /b

:MANAGE_GROUPS
cls
echo %BOLD%%CYAN%  📚 УПРАВЛЕНИЕ ГРУППАМИ%RESET%
echo.
echo %GREEN%  1.%RESET% Создать новую группу
echo %GREEN%  2.%RESET% Добавить репозиторий в группу
echo %GREEN%  3.%RESET% Удалить репозиторий из группы
echo %GREEN%  4.%RESET% Показать все группы
echo %GREEN%  5.%RESET% Удалить группу
echo %RED%  6.%RESET% Назад
echo.
set /p "grp_act=%BOLD%%WHITE%    ⚡ Выберите: %RESET%"

if "!grp_act!"=="1" goto CREATE_GROUP
if "!grp_act!"=="2" goto ADD_TO_GROUP
if "!grp_act!"=="3" goto REMOVE_FROM_GROUP
if "!grp_act!"=="4" goto SHOW_GROUPS
if "!grp_act!"=="5" goto DELETE_GROUP
if "!grp_act!"=="6" goto MENU
goto MANAGE_GROUPS

:CREATE_GROUP
cls
echo %BOLD%%CYAN%  ✨ СОЗДАНИЕ ГРУППЫ%RESET%
echo.
set /p "new_group=%GREEN%    📝 Введите название группы: %RESET%"

if "!new_group!"=="" (
  echo %RED%  ❌ Название не может быть пустым!%RESET%
  pause
  goto MANAGE_GROUPS
)

if exist "%GROUPS_FILE%" (
  findstr /b "!new_group!;" "%GROUPS_FILE%" >nul 2>&1
  if not errorlevel 1 (
    echo %RED%  ❌ Группа с таким именем уже существует!%RESET%
    pause
    goto MANAGE_GROUPS
  )
)

echo !new_group!;>> "%GROUPS_FILE%"
echo %GREEN%  ✅ Группа "%new_group%" создана!%RESET%
pause
goto MANAGE_GROUPS

:ADD_TO_GROUP
cls
echo %BOLD%%CYAN%  📌 ДОБАВЛЕНИЕ В ГРУППУ%RESET%
echo.

echo %BOLD%%WHITE%  Существующие группы:%RESET%
set group_count=0
if exist "%GROUPS_FILE%" (
  for /f "usebackq tokens=1 delims=;" %%a in ("%GROUPS_FILE%") do (
    if not "%%a"=="" (
      set /a group_count+=1
      set "group_name_!group_count!=%%a"
      echo %GREEN%  !group_count!.%RESET% %%a
    )
  )
  ) else (
  echo %YELLOW%  Нет созданных групп%RESET%
  pause
  goto MANAGE_GROUPS
)

if !group_count!==0 (
  echo %YELLOW%  Нет созданных групп%RESET%
  pause
  goto MANAGE_GROUPS
)

echo.
set /p "group_num=%BOLD%%WHITE%    ⚡ Выберите номер группы: %RESET%"
set "selected_group=!group_name_%group_num%!"

echo.
echo %BOLD%%WHITE%  Репозитории не в группах:%RESET%
set repo_count=0
for /f "usebackq tokens=1,* delims=;" %%a in ("%CONFIG_FILE%") do (
  set "in_group=0"
  if exist "%GROUPS_FILE%" (
    for /f "usebackq tokens=2 delims=;" %%g in ("%GROUPS_FILE%") do (
      echo "%%g" | find "%%a" >nul && set "in_group=1"
    )
  )
  if !in_group!==0 (
    set /a repo_count+=1
    set "repo_name_add_!repo_count!=%%a"
    echo %GREEN%  !repo_count!.%RESET% %%a
  )
)

if !repo_count!==0 (
  echo %YELLOW%  Нет репозиториев для добавления%RESET%
  pause
  goto MANAGE_GROUPS
  ) else (
  echo.
  set /p "repo_num=%BOLD%%WHITE%    ⚡ Выберите номер репозитория: %RESET%"
  set "selected_repo=!repo_name_add_%repo_num%!"
)

set "temp_groups=%TEMP%\groups.tmp"
type nul > "!temp_groups!"
if exist "%GROUPS_FILE%" (
  for /f "usebackq tokens=1,* delims=;" %%a in ("%GROUPS_FILE%") do (
    if "%%a"=="!selected_group!" (
      :: Проверяем, не пустой ли список репозиториев
      if "%%b"=="" (
        echo %%a;!selected_repo!>> "!temp_groups!"
        ) else (
        echo %%a;%%b !selected_repo!>> "!temp_groups!"
      )
      ) else (
      echo %%a;%%b>> "!temp_groups!"
    )
  )
  move /y "!temp_groups!" "%GROUPS_FILE%" >nul 2>&1
)

echo %GREEN%  ✅ Репозиторий "%selected_repo%" добавлен в группу "%selected_group%"%RESET%
pause
goto MANAGE_GROUPS

:REMOVE_FROM_GROUP
cls
echo %BOLD%%CYAN%  🗑️ УДАЛЕНИЕ ИЗ ГРУППЫ%RESET%
echo.

echo %BOLD%%WHITE%  Группы и их репозитории:%RESET%
if exist "%GROUPS_FILE%" (
  for /f "usebackq tokens=1,* delims=;" %%a in ("%GROUPS_FILE%") do (
    echo %BOLD%%MAGENTA%  📁 %%a%RESET%
    if not "%%b"=="" (
      for %%r in (%%b) do (
        echo %GREEN%  -%RESET% %%r
      )
      ) else (
      echo %YELLOW%  пусто%RESET%
    )
  )
  ) else (
  echo %YELLOW%  Нет групп%RESET%
  pause
  goto MANAGE_GROUPS
)

echo.
set /p "group_del=%BOLD%%WHITE%    Введите название группы: %RESET%"
set /p "repo_del=%BOLD%%WHITE%    Введите название репозитория для удаления: %RESET%"

set "temp_groups=%TEMP%\groups.tmp"
type nul > "!temp_groups!"
if exist "%GROUPS_FILE%" (
  for /f "usebackq tokens=1,* delims=;" %%a in ("%GROUPS_FILE%") do (
    if "%%a"=="!group_del!" (
      set "new_repo_list="
      set "first_repo=1"
      for %%r in (%%b) do (
        if not "%%r"=="!repo_del!" (
          if !first_repo!==1 (
            set "new_repo_list=%%r"
            set "first_repo=0"
            ) else (
            set "new_repo_list=!new_repo_list! %%r"
          )
        )
      )
      echo %%a;!new_repo_list!>> "!temp_groups!"
      ) else (
      echo %%a;%%b>> "!temp_groups!"
    )
  )
  move /y "!temp_groups!" "%GROUPS_FILE%" >nul 2>&1
)

echo %GREEN%  ✅ Репозиторий удален из группы%RESET%
pause
goto MANAGE_GROUPS

:SHOW_GROUPS
cls
echo %BOLD%%CYAN%  📚 ВСЕ ГРУППЫ%RESET%
echo.

if exist "%GROUPS_FILE%" (
  for /f "usebackq tokens=1,2 delims=;" %%a in ("%GROUPS_FILE%") do (
    echo %BOLD%%MAGENTA%  [%%a]%RESET%
    if not "%%b"=="" (
      for %%r in (%%b) do (
        echo %GREEN%  -%RESET% %%r
      )
      ) else (
      echo %YELLOW%  пусто%RESET%
    )
    echo.
  )
  ) else (
  echo %YELLOW%  Нет созданных групп%RESET%
)

pause
goto MANAGE_GROUPS

:DELETE_GROUP
cls
echo %BOLD%%CYAN%  🗑️ УДАЛЕНИЕ ГРУППЫ%RESET%
echo.

if exist "%GROUPS_FILE%" (
  for /f "usebackq tokens=1 delims=;" %%a in ("%GROUPS_FILE%") do (
    echo %GREEN%  -%RESET% %%a
  )
  ) else (
  echo %YELLOW%  Нет групп для удаления%RESET%
  pause
  goto MANAGE_GROUPS
)

echo.
set /p "group_del_name=%BOLD%%WHITE%    Введите название группы для удаления: %RESET%"

set "temp_groups=%TEMP%\groups.tmp"
type nul > "!temp_groups!"
if exist "%GROUPS_FILE%" (
  for /f "usebackq tokens=1,2 delims=;" %%a in ("%GROUPS_FILE%") do (
    if not "%%a"=="!group_del_name!" (
      echo %%a;%%b>> "!temp_groups!"
    )
  )
  move /y "!temp_groups!" "%GROUPS_FILE%" >nul 2>&1
)

echo %GREEN%  ✅ Группа удалена%RESET%
pause
goto MANAGE_GROUPS
