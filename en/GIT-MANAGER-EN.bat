@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: Color scheme
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

:: Save script directory (where GIT-MANAGER-EN.bat is located)
set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"

:: Parent directory (where GIT-MANAGER.BAT is located)
set "PARENT_DIR=%SCRIPT_DIR%\.."

:: Config directory (in parent folder)
set "CONFIG_DIR=%PARENT_DIR%\cfg"

:: Create config directory if it doesn't exist
if not exist "%CONFIG_DIR%" mkdir "%CONFIG_DIR%" 2>nul

:: Config files (in cfg directory - shared between RU and EN versions)
set "CONFIG_FILE=%CONFIG_DIR%\git_repos.cfg"
set "GROUPS_FILE=%CONFIG_DIR%\groups.cfg"
set "TEMP_FILE=%CONFIG_DIR%\temp.cfg"

:: Scripts directory (in the same folder as GIT-MANAGER-EN.bat)
set "SCRIPTS_DIR=%SCRIPT_DIR%\git-scripts"

:MENU
cls
echo %BOLD%%CYAN%════════════════════════════════════════════════════════════%RESET%
echo %BOLD%%CYAN%                        GIT MANAGER  🚀 %RESET%
echo %YELLOW%                         by AtinsS%RESET%
echo %CYAN%════════════════════════════════════════════════════════════%RESET%
echo.

set count=0
if exist "%CONFIG_FILE%" (
  echo %BOLD%%WHITE%▸ REPOSITORIES%RESET%
  
  set "MARKED_FILE=%TEMP%\marked_repos_%RANDOM%.tmp"
  type nul > "!MARKED_FILE!"
  
  if exist "%GROUPS_FILE%" (
    for /f "usebackq tokens=1,* delims=;" %%a in ("%GROUPS_FILE%") do (
      echo.
      echo %BOLD%%MAGENTA%  ▸ Group: %%a%RESET%
      set "group_repos=%%b"
      if not "!group_repos!"=="" (
        set "group_repos=!group_repos: =;!"
        set "group_repos=!group_repos:;;=;!"
        for %%r in (!group_repos!) do (
          >> "!MARKED_FILE!" echo %%~r
          set "repo_found=0"
          for /f "usebackq tokens=1,* delims=;" %%x in ("%CONFIG_FILE%") do (
            if "%%x"=="%%r" (
              set /a count+=1
              set "repo_name_!count!=%%x"
              set "repo_path_!count!=%%y"
              call :GET_REPO_STATUS "%%y" status_!count!
              
              :: Display with detailed status
              if "!status_icon!"=="%GREEN%[✓]%RESET%" (
                echo     %GREEN%!count!.%RESET% %%x %CYAN%!branch_info!%RESET% %GREEN%● clean%RESET%
              ) else if "!status_icon!"=="%YELLOW%[!]%RESET%" (
                echo     %GREEN%!count!.%RESET% %%x %CYAN%!branch_info!%RESET% %YELLOW%● changes%RESET%
              ) else if "!status_icon!"=="%RED%[✗]%RESET%" (
                echo     %GREEN%!count!.%RESET% %%x %CYAN%!branch_info!%RESET% %RED%● error%RESET%
              ) else (
                echo     %GREEN%!count!.%RESET% %%x %RED%● not found%RESET%
              )
              set "repo_found=1"
            )
          )
          if !repo_found!==0 echo     %RED%⚠ %%r%RESET%
        )
        ) else echo     %YELLOW%empty%RESET%
    )
  )
  
  set "has_ungrouped=0"
  for /f "usebackq tokens=1,* delims=;" %%a in ("%CONFIG_FILE%") do (
    findstr /x /c:"%%a" "!MARKED_FILE!" >nul 2>&1
    if errorlevel 1 set "has_ungrouped=1"
  )
  
  if !has_ungrouped!==1 (
    echo.
    echo %BOLD%%YELLOW%  ▸ Ungrouped:%RESET%
    for /f "usebackq tokens=1,* delims=;" %%a in ("%CONFIG_FILE%") do (
      findstr /x /c:"%%a" "!MARKED_FILE!" >nul 2>&1
      if errorlevel 1 (
        set /a count+=1
        set "repo_name_!count!=%%a"
        set "repo_path_!count!=%%b"
        call :GET_REPO_STATUS "%%b" status_!count!
        
        :: Display with detailed status
        if "!status_icon!"=="%GREEN%[✓]%RESET%" (
          echo     %GREEN%!count!.%RESET% %%a %CYAN%!branch_info!%RESET% %GREEN%● clean%RESET%
        ) else if "!status_icon!"=="%YELLOW%[!]%RESET%" (
          echo     %GREEN%!count!.%RESET% %%a %CYAN%!branch_info!%RESET% %YELLOW%● changes%RESET%
        ) else if "!status_icon!"=="%RED%[✗]%RESET%" (
          echo     %GREEN%!count!.%RESET% %%a %CYAN%!branch_info!%RESET% %RED%● error%RESET%
        ) else (
          echo     %GREEN%!count!.%RESET% %%a %RED%● not found%RESET%
        )
      )
    )
  )
  
  del "!MARKED_FILE!" 2>nul
  
  ) else (
  echo %YELLOW%▸ No repositories%RESET%
)

echo.
echo %CYAN%════════════════════════════════════════════════════════════%RESET%
echo %BOLD%%WHITE%▸ ACTIONS%RESET%
if %count% gtr 0 echo %GREEN%    [1-%count%]   Select%RESET%
echo %CYAN%    [C] Clone        [A] Add         [U] Update all%RESET%
echo %CYAN%    [G] Groups       [D] Delete      [S] Settings%RESET%
echo %RED%    [X] Exit%RESET%
echo %CYAN%════════════════════════════════════════════════════════════%RESET%
echo.
set /p "action=%BOLD%%WHITE%  → %RESET%"


set is_number=0
echo %action%| findstr /r "^[0-9][0-9]*$" >nul 2>&1
if not errorlevel 1 set is_number=1

if %is_number%==1 (
  if %action% leq %count% (
    set "repo_index=%action%"
    call :SELECT_REPO
    goto MENU
    ) else (
    echo %RED%  ❌ Invalid number!%RESET%
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
  echo %RED%  ❌ Invalid choice!%RESET%
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
    :: Get current branch
    set "branch_info="
    for /f "tokens=*" %%b in ('git branch --show-current 2^>nul') do set "branch_info=%%b"
    if "!branch_info!"=="" (
      for /f "tokens=2" %%b in ('git branch 2^>nul ^| find "*"') do set "branch_info=%%b"
    )
    if not "!branch_info!"=="" (
      set "branch_info= [!branch_info!]"
      ) else (
      set "branch_info= %RED%[no branch]%RESET%"
    )
    
    :: Check status with more details
    git status --porcelain > "%TEMP%\git_status_tmp.txt" 2>&1
    if errorlevel 1 (
      set "status_icon=%RED%[✗]%RESET%"
      set "status_text=%RED%● git error%RESET%"
      ) else (
      set "has_changes=0"
      set "has_added=0"
      set "has_modified=0"
      set "has_deleted=0"
      set "has_untracked=0"
      
      for /f "tokens=1,*" %%i in (%TEMP%\git_status_tmp.txt) do (
        set "line=%%i"
        if "!line:~0,1!"=="A" set "has_added=1"
        if "!line:~0,1!"=="M" set "has_modified=1"
        if "!line:~0,1!"=="D" set "has_deleted=1"
        if "!line:~0,1!"=="?" set "has_untracked=1"
        set "has_changes=1"
      )
      
      if !has_changes!==0 (
        set "status_icon=%GREEN%[✓]%RESET%"
        set "status_text=%GREEN%● clean%RESET%"
        ) else (
        set "status_icon=%YELLOW%[!]%RESET%"
        set "status_text=%YELLOW%●%RESET%"
        if !has_added!==1 set "status_text=!status_text! +"
        if !has_modified!==1 set "status_text=!status_text! M"
        if !has_deleted!==1 set "status_text=!status_text! D"
        if !has_untracked!==1 set "status_text=!status_text! ?"
        set "status_text=!status_text!%RESET%"
      )
    )
    del "%TEMP%\git_status_tmp.txt" 2>nul
    popd
    ) else (
    set "status_icon=%RED%[!]%RESET%"
    set "status_text=%RED%● access denied%RESET%"
    set "branch_info=%RED%[no access]%RESET%"
  )
  ) else (
  set "status_icon=%RED%[?]%RESET%"
  set "status_text=%RED%● folder not found%RESET%"
  set "branch_info=%RED%[not found]%RESET%"
)

set "%status_var%=!status_text!"
set "branch_%count%=!branch_info!"
goto :eof

:SELECT_REPO
set "REPO_NAME=!repo_name_%repo_index%!"
set "REPO_PATH=!repo_path_%repo_index%!"

echo.
echo %BOLD%%WHITE%  Selected repository:%RESET% %GREEN%📁 %REPO_NAME%%RESET%
echo %BOLD%%WHITE%  Path:%RESET% %CYAN%📌 %REPO_PATH%%RESET%

if not exist "%REPO_PATH%" (
  echo.
  echo %RED%  ⚠ WARNING: Folder not found!%RESET%
  echo.
  echo %GREEN%  1.%RESET% Clone again
  echo %YELLOW%  2.%RESET% Specify new path
  echo %RED%  3.%RESET% Back to menu
  echo.
  set /p "fix=%BOLD%%WHITE%    Choose action: %RESET%"
  
  if "!fix!"=="1" (
    call :CLONE_REPO_EXISTING "%REPO_NAME%" "%REPO_PATH%"
    goto :eof
    ) else if "!fix!"=="2" (
    set /p "REPO_PATH=%YELLOW%    New path: %RESET%"
    call :UPDATE_REPO_PATH "%REPO_NAME%" "!REPO_PATH!"
    cd /d "!REPO_PATH!" 2>nul
    ) else (
    goto :eof
  )
  ) else (
  cd /d "%REPO_PATH%" 2>nul
)

if errorlevel 1 (
  echo %RED%  ❌ Error: Cannot navigate to folder!%RESET%
  pause
  goto :eof
)

git status >nul 2>&1
if errorlevel 1 (
  echo %RED%  ❌ Error: Folder is not a git repository!%RESET%
  pause
  goto :eof
)

call :REPO_MENU "%REPO_NAME%"
goto :eof

:REPO_MENU
set "current_repo=%~1"

:REPO_LOOP
cls
set "current_branch="
for /f "tokens=*" %%b in ('git branch --show-current 2^>nul') do set "current_branch=%%b"
if "!current_branch!"=="" (
  for /f "tokens=2" %%b in ('git branch 2^>nul ^| find "*"') do set "current_branch=%%b"
)
if "!current_branch!"=="" set "current_branch=unknown"

git status --porcelain | findstr . >nul 2>&1
if errorlevel 1 (
  set "repo_status=%GREEN%✅ clean%RESET%"
  ) else (
  set "repo_status=%YELLOW%⚠ changes present%RESET%"
)

echo %CYAN%  ════════════════════════════════════════════════════════════%RESET%
echo %BOLD%%WHITE%  Repository:%RESET% %GREEN%%current_repo%%RESET%  %BOLD%%WHITE%Branch:%RESET% %BLUE%!current_branch!%RESET%
echo %BOLD%%WHITE%  Status:%RESET% !repo_status!
echo %CYAN%  ════════════════════════════════════════════════════════════%RESET%
echo.
echo %GREEN%  1.%RESET% Git status
echo %GREEN%  2.%RESET% Git pull
echo %GREEN%  3.%RESET% Git add + commit + push
echo %GREEN%  4.%RESET% Revert changes menu
echo %GREEN%  5.%RESET% View history (git log)
echo %GREEN%  6.%RESET% Git merge
echo %GREEN%  7.%RESET% Git merge --abort
echo %GREEN%  8.%RESET% Show branches for merging
echo %GREEN%  9.%RESET% Create branch
echo %GREEN%  10.%RESET% Switch branch
echo %GREEN%  11.%RESET% Auto-commits (every N minutes)
echo %RED%  0.%RESET% Back to main menu
echo.
set /p "repo_action=%BOLD%%WHITE% → %RESET%"

if not exist "%SCRIPTS_DIR%" mkdir "%SCRIPTS_DIR%" 2>nul

if "%repo_action%"=="1" (
  cls
  if exist "%SCRIPTS_DIR%\01-git-status.bat" (
    call "%SCRIPTS_DIR%\01-git-status.bat" "%current_repo%"
    ) else (
    echo %BOLD%%CYAN%  === GIT STATUS ===%RESET%
    echo.
    git status
    pause
  )
  goto REPO_LOOP
)

if "%repo_action%"=="2" (
  cls
  if exist "%SCRIPTS_DIR%\02-git-pull.bat" (
    call "%SCRIPTS_DIR%\02-git-pull.bat" "%current_repo%"
    ) else (
    echo %BOLD%%CYAN%  === GIT PULL ===%RESET%
    echo.
    git pull
    pause
  )
  goto REPO_LOOP
)

if "%repo_action%"=="3" (
  cls
  if exist "%SCRIPTS_DIR%\03-git-commit.bat" (
    call "%SCRIPTS_DIR%\03-git-commit.bat" "%current_repo%"
    ) else (
    echo %BOLD%%CYAN%  === GIT COMMIT ===%RESET%
    echo.
    set /p "commit_msg=%YELLOW%  Message: %RESET%
    git add .
    git commit -m "!commit_msg!"
    git push
    pause
  )
  goto REPO_LOOP
)

if "%repo_action%"=="4" (
  cls
  if exist "%SCRIPTS_DIR%\04-git-menu-revert.bat" (
    call "%SCRIPTS_DIR%\04-git-menu-revert.bat" "%current_repo%"
    ) else (
    echo %RED%  ❌ Revert menu script not found%RESET%
    pause
  )
  goto REPO_LOOP
)

if "%repo_action%"=="5" (
  cls
  if exist "%SCRIPTS_DIR%\05-git-log.bat" (
    call "%SCRIPTS_DIR%\05-git-log.bat" "%current_repo%"
    ) else (
    echo %BOLD%%CYAN%  === GIT LOG ===%RESET%
    echo.
    git log --oneline --graph --all -n 20
    pause
  )
  goto REPO_LOOP
)

if "%repo_action%"=="6" (
  cls
  if exist "%SCRIPTS_DIR%\06-git-merge.bat" (
    call "%SCRIPTS_DIR%\06-git-merge.bat" "%current_repo%"
    ) else (
    echo %RED%  ❌ Merge script not found%RESET%
    pause
  )
  goto REPO_LOOP
)

if "%repo_action%"=="7" (
  cls
  if exist "%SCRIPTS_DIR%\07-git-merge-abort.bat" (
    call "%SCRIPTS_DIR%\07-git-merge-abort.bat" "%current_repo%"
    ) else (
    echo %RED%  ❌ Merge abort script not found%RESET%
    pause
  )
  goto REPO_LOOP
)

if "%repo_action%"=="8" (
  cls
  if exist "%SCRIPTS_DIR%\08-git-merge-list.bat" (
    call "%SCRIPTS_DIR%\08-git-merge-list.bat" "%current_repo%"
    ) else (
    echo %RED%  ❌ Branch list script not found%RESET%
    pause
  )
  goto REPO_LOOP
)

if "%repo_action%"=="9" (
  cls
  if exist "%SCRIPTS_DIR%\09-git-create-branch.bat" (
    call "%SCRIPTS_DIR%\09-git-create-branch.bat" "%current_repo%"
    ) else (
    echo %BOLD%%CYAN%  === CREATE BRANCH ===%RESET%
    echo.
    set /p "branch_name=%YELLOW%  Branch name: %RESET%
    git branch "!branch_name!"
    echo %GREEN%  ✅ Branch created%RESET%
    pause
  )
  goto REPO_LOOP
)

if "%repo_action%"=="10" (
  cls
  if exist "%SCRIPTS_DIR%\10-git-switch-branch.bat" (
    call "%SCRIPTS_DIR%\10-git-switch-branch.bat" "%current_repo%"
    ) else (
    echo %BOLD%%CYAN%  === SWITCH BRANCH ===%RESET%
    echo.
    git branch
    echo.
    set /p "branch_name=%YELLOW%  Branch to switch: %RESET%
    git checkout "!branch_name!"
    pause
  )
  goto REPO_LOOP
)

if "%repo_action%"=="11" (
  cls
  if exist "%SCRIPTS_DIR%\11-git-auto-commit.bat" (
    call "%SCRIPTS_DIR%\11-git-auto-commit.bat" "%current_repo%"
    ) else (
    echo %RED%  ❌ Auto-commit script not found%RESET%
    pause
  )
  goto REPO_LOOP
)

if "%repo_action%"=="0" goto MENU

echo %RED%  ❌ Invalid choice!%RESET%
pause
goto REPO_LOOP

:CLONE_REPO
cls
echo %BOLD%%CYAN%  📥 CLONE REPOSITORY%RESET%
echo.
set /p "repo_name=%GREEN%    📦 Repository name: %RESET%"
set /p "repo_url=%YELLOW%    🔗 Repository URL: %RESET%"
set /p "clone_path=%BLUE%    📁 Clone path (Enter - current folder): %RESET%"

if "!clone_path!"=="" set "clone_path=%cd%"
if not exist "!clone_path!" mkdir "!clone_path!" 2>nul

set "full_path=!clone_path!\!repo_name!"

echo.
echo %BOLD%  ⏳ Cloning %repo_name% from %repo_url% to %full_path%...%RESET%
git clone "%repo_url%" "%full_path%"

if errorlevel 1 (
  echo %RED%  ❌ Cloning error!%RESET%
  pause
  goto MENU
)

echo %repo_name%;%full_path% >> "%CONFIG_FILE%"
echo %GREEN%  ✅ Repository successfully cloned and added to list!%RESET%

echo.
echo %BOLD%%WHITE%  Add to group:%RESET%
set /p "add_to_group=%YELLOW%    Add repository to group? [y/n]: %RESET%"

if /i "!add_to_group!"=="y" call :ADD_REPO_TO_GROUP "%repo_name%"
if /i "!add_to_group!"=="yes" call :ADD_REPO_TO_GROUP "%repo_name%"

pause
goto MENU

:ADD_EXISTING
cls
echo %BOLD%%CYAN%  📂 ADD EXISTING REPOSITORY%RESET%
echo.
set /p "repo_name=%GREEN%    📦 Repository name: %RESET%"
set /p "repo_path=%YELLOW%    📁 Full path to repository: %RESET%"

set "repo_path=%repo_path:"=%"

if "!repo_path!"=="" (
  echo %RED%  ❌ Error: Path cannot be empty!%RESET%
  pause
  goto MENU
)

if not exist "!repo_path!" (
  echo %RED%  ❌ Error: Folder not found!%RESET%
  pause
  goto MENU
)

pushd "!repo_path!" 2>nul
if errorlevel 1 (
  echo %RED%  ❌ Error: Cannot navigate to folder!%RESET%
  pause
  goto MENU
)

git status >nul 2>&1
if errorlevel 1 (
  echo %RED%  ❌ Error: Folder is not a git repository!%RESET%
  popd
  pause
  goto MENU
)
popd

echo %repo_name%;!repo_path! >> "%CONFIG_FILE%"
echo %GREEN%  ✅ Repository added to list!%RESET%

echo.
echo %BOLD%%WHITE%  Add to group:%RESET%
set /p "add_to_group=%YELLOW%    Add repository to group? [y/n]: %RESET%"

if /i "!add_to_group!"=="y" call :ADD_REPO_TO_GROUP "%repo_name%"
if /i "!add_to_group!"=="yes" call :ADD_REPO_TO_GROUP "%repo_name%"

pause
goto MENU

:ADD_REPO_TO_GROUP
set "repo_to_add=%~1"

if not exist "%GROUPS_FILE%" (
  echo %YELLOW%  ⚠ No groups created. Create a new one?%RESET%
  set /p "create_new=%YELLOW%    [y/n]: %RESET%"
  if /i "!create_new!"=="y" call :CREATE_GROUP_FROM_ADD "%repo_to_add%"
  goto :eof
)

set "group_exists=0"
for /f "usebackq tokens=1 delims=;" %%a in ("%GROUPS_FILE%") do (
  if not "%%a"=="" set "group_exists=1"
)

if !group_exists!==0 (
  echo %YELLOW%  ⚠ No groups created. Create a new one?%RESET%
  set /p "create_new=%YELLOW%    [y/n]: %RESET%"
  if /i "!create_new!"=="y" call :CREATE_GROUP_FROM_ADD "%repo_to_add%"
  goto :eof
)

echo.
echo %BOLD%%WHITE%  Select group:%RESET%
set group_count=0
for /f "usebackq tokens=1 delims=;" %%a in ("%GROUPS_FILE%") do (
  if not "%%a"=="" (
    set /a group_count+=1
    set "group_name_add_!group_count!=%%a"
    echo %GREEN%  !group_count!.%RESET% %%a
  )
)
echo %GREEN%  0.%RESET% Create new group

echo.
set /p "group_choice=%BOLD%%WHITE%    ⚡ Your choice: %RESET%"

if "!group_choice!"=="0" (
  call :CREATE_GROUP_FROM_ADD "%repo_to_add%"
  goto :eof
)

set "selected_group=!group_name_add_%group_choice%!"

set "temp_groups=%TEMP%\groups_%RANDOM%.tmp"
type nul > "!temp_groups!"

set "repo_added=0"
for /f "usebackq tokens=1,* delims=;" %%a in ("%GROUPS_FILE%") do (
  if "%%a"=="!selected_group!" (
    set "current_repos=%%b"
    
    echo "!current_repos!" | find "!repo_to_add!" >nul 2>&1
    if errorlevel 1 (
      if "!current_repos!"=="" (
        echo %%a;!repo_to_add!>> "!temp_groups!"
        ) else (
        echo %%a;!current_repos!;!repo_to_add!>> "!temp_groups!"
      )
      set "repo_added=1"
      echo %GREEN%  ✅ Repository "%repo_to_add%" added to group "%selected_group%"%RESET%
      ) else (
      echo %%a;%%b>> "!temp_groups!"
      echo %YELLOW%  ⚠ Repository "%repo_to_add%" already in group "%selected_group%"%RESET%
    )
    ) else (
    echo %%a;%%b>> "!temp_groups!"
  )
)

move /y "!temp_groups!" "%GROUPS_FILE%" >nul 2>&1

if !repo_added!==0 (
  echo %RED%  ❌ Failed to add repository to group%RESET%
)

pause
goto :eof

:CREATE_GROUP_FROM_ADD
set "repo_to_add=%~1"
echo.
set /p "new_group=%GREEN%    📝 Enter new group name: %RESET%"

if "!new_group!"=="" (
  echo %RED%  ❌ Name cannot be empty!%RESET%
  pause
  goto :eof
)

if exist "%GROUPS_FILE%" (
  findstr /b "!new_group!;" "%GROUPS_FILE%" >nul 2>&1
  if not errorlevel 1 (
    echo %RED%  ❌ Group with this name already exists!%RESET%
    pause
    goto :eof
  )
)

echo !new_group!;%repo_to_add%>> "%GROUPS_FILE%"
echo %GREEN%  ✅ Group "%new_group%" created and repository added!%RESET%
pause
goto :eof

:UPDATE_ALL
cls
echo %BOLD%%CYAN%  🔄 UPDATE ALL REPOSITORIES%RESET%
echo.

if not exist "%CONFIG_FILE%" (
  echo %RED%  ❌ No saved repositories!%RESET%
  pause
  goto MENU
)

for /f "usebackq tokens=1,2 delims=;" %%a in ("%CONFIG_FILE%") do (
  echo.
  echo %BOLD%%BLUE%  [%%a]%RESET%
  if exist "%%b" (
    pushd "%%b" 2>nul
    if not errorlevel 1 (
      echo %YELLOW%  Updating...%RESET%
      git pull
      popd
      ) else (
      echo %RED%  ⚠ Cannot navigate to folder%RESET%
    )
    ) else (
    echo %RED%  ⚠ Folder not found: %%b%RESET%
  )
)

echo.
echo %GREEN%  ✅ Update complete!%RESET%
pause
goto MENU

:DELETE_REPO
cls
echo %BOLD%%CYAN%  🗑️ REMOVE REPOSITORY FROM LIST%RESET%
echo.

if not exist "%CONFIG_FILE%" (
  echo %RED%  ❌ No repositories to delete!%RESET%
  pause
  goto MENU
)

set idx=1
for /f "usebackq tokens=1,2 delims=;" %%a in ("%CONFIG_FILE%") do (
  echo %GREEN%!idx!.%RESET% %%a - %CYAN%%%b%RESET%
  set /a idx+=1
)

echo.
set /p "del_num=%BOLD%%RED%    ⚠ Repository number to delete: %RESET%"

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
            set "new_repo_list=!new_repo_list!;%%r"
          )
        )
      )
    )
    echo %%a;!new_repo_list!>> "!temp_groups!"
  )
  move /y "!temp_groups!" "%GROUPS_FILE%" >nul 2>nul
)

echo %GREEN%  ✅ Repository removed from list and groups!%RESET%
pause
goto MENU

:SETTINGS
cls
echo %BOLD%%CYAN%  ⚙️ SETTINGS%RESET%
echo.
echo %GREEN%  1.%RESET% Show all repositories
echo %YELLOW%  2.%RESET% Clear list
echo %BLUE%  3.%RESET% Edit paths manually
echo %MAGENTA%  4.%RESET% Auto-repair configs
echo %RED%  5.%RESET% Back
echo.
set /p "sett=%BOLD%%WHITE% → %RESET%"

if "%sett%"=="1" (
  cls
  echo %BOLD%%WHITE%  Repository List:%RESET%
  if exist "%CONFIG_FILE%" (
    for /f "usebackq tokens=1,2 delims=;" %%a in ("%CONFIG_FILE%") do (
      echo %GREEN%  📦 %%a%RESET% - %CYAN%%%b%RESET%
    )
    ) else (
    echo %YELLOW%  List is empty%RESET%
  )
  echo.
  pause
  goto SETTINGS
)

if "%sett%"=="2" (
  del "%CONFIG_FILE%" 2>nul
  del "%GROUPS_FILE%" 2>nul
  echo %GREEN%  ✅ Lists cleared!%RESET%
  pause
  goto SETTINGS
)

if "%sett%"=="3" (
  if exist "%CONFIG_FILE%" (
    notepad "%CONFIG_FILE%"
    ) else (
    echo %RED%  ❌ List is empty, nothing to edit%RESET%
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
echo %YELLOW%  Enter URL to clone %repo_name%:%RESET%
set /p "repo_url=%BOLD%    URL: %RESET%"

echo %BOLD%  ⏳ Cloning %repo_name%...%RESET%
if exist "%repo_dir%" rd /s /q "%repo_dir%" 2>nul

git clone "%repo_url%" "%repo_dir%"
if errorlevel 1 (
  echo %RED%  ❌ Cloning error!%RESET%
  ) else (
  echo %GREEN%  ✅ Done!%RESET%
  
  findstr /b "%repo_name%;" "%CONFIG_FILE%" >nul 2>&1
  if errorlevel 1 (
    echo %repo_name%;%repo_dir% >> "%CONFIG_FILE%"
    echo %GREEN%  ✅ Repository added to list!%RESET%
    ) else (
    echo %YELLOW%  ⚠ Repository already in list%RESET%
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
echo %BOLD%%YELLOW%  🔄 Auto-repairing configurations...%RESET%

if exist "%CONFIG_FILE%" (
  set "temp_cfg=%TEMP%\git_repos_fixed.cfg"
  type nul > "!temp_cfg!"
  for /f "usebackq tokens=1,* delims=;" %%a in ("%CONFIG_FILE%") do (
    for /f "tokens=1" %%n in ("%%a") do set "clean_name=%%n"
    set "clean_path=%%b"
    echo !clean_name!;!clean_path!>> "!temp_cfg!"
  )
  move /y "!temp_cfg!" "%CONFIG_FILE%" >nul 2>nul
  echo %GREEN%  ✅ git_repos.cfg repaired%RESET%
)

if exist "%GROUPS_FILE%" (
  set "temp_groups=%TEMP%\groups_fixed.cfg"
  type nul > "!temp_groups!"
  for /f "usebackq tokens=1,* delims=;" %%a in ("%GROUPS_FILE%") do (
    set "new_repo_list="
    set "first_repo=1"
    for %%r in (%%b) do (
      for /f "tokens=1" %%n in ("%%r") do set "clean_repo=%%n"
      if !first_repo!==1 (
        set "new_repo_list=!clean_repo!"
        set "first_repo=0"
        ) else (
        set "new_repo_list=!new_repo_list!;!clean_repo!"
      )
    )
    echo %%a;!new_repo_list!>> "!temp_groups!"
  )
  move /y "!temp_groups!" "%GROUPS_FILE%" >nul 2>nul
  echo %GREEN%  ✅ groups.cfg repaired%RESET%
)

echo.
echo %GREEN%  ✅ Repair complete!%RESET%
pause
goto :eof

:MANAGE_GROUPS
cls
echo %BOLD%%CYAN%  📚 GROUP MANAGEMENT%RESET%
echo.
echo %GREEN%  1.%RESET% Create new group
echo %GREEN%  2.%RESET% Add repository to group
echo %GREEN%  3.%RESET% Remove repository from group
echo %GREEN%  4.%RESET% Show all groups
echo %GREEN%  5.%RESET% Delete group
echo %RED%  6.%RESET% Back
echo.
set /p "grp_act=%BOLD%%WHITE%    ⚡ Choose: %RESET%"

if "!grp_act!"=="1" goto CREATE_GROUP
if "!grp_act!"=="2" goto ADD_TO_GROUP
if "!grp_act!"=="3" goto REMOVE_FROM_GROUP
if "!grp_act!"=="4" goto SHOW_GROUPS
if "!grp_act!"=="5" goto DELETE_GROUP
if "!grp_act!"=="6" goto MENU
goto MANAGE_GROUPS

:CREATE_GROUP
cls
echo %BOLD%%CYAN%  ✨ CREATE GROUP%RESET%
echo.
set /p "new_group=%GREEN%    📝 Enter group name: %RESET%"

if "!new_group!"=="" (
  echo %RED%  ❌ Name cannot be empty!%RESET%
  pause
  goto MANAGE_GROUPS
)

if exist "%GROUPS_FILE%" (
  findstr /b "!new_group!;" "%GROUPS_FILE%" >nul 2>&1
  if not errorlevel 1 (
    echo %RED%  ❌ Group with this name already exists!%RESET%
    pause
    goto MANAGE_GROUPS
  )
)

echo !new_group!;>> "%GROUPS_FILE%"
echo %GREEN%  ✅ Group "%new_group%" created!%RESET%
pause
goto MANAGE_GROUPS

:ADD_TO_GROUP
cls
echo %BOLD%%CYAN%  📌 ADD TO GROUP%RESET%
echo.

echo %BOLD%%WHITE%  Existing groups:%RESET%
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
  echo %YELLOW%  No groups created%RESET%
  pause
  goto MANAGE_GROUPS
)

if !group_count!==0 (
  echo %YELLOW%  No groups created%RESET%
  pause
  goto MANAGE_GROUPS
)

echo.
set /p "group_num=%BOLD%%WHITE%    ⚡ Select group number: %RESET%"
set "selected_group=!group_name_%group_num%!"

echo.
echo %BOLD%%WHITE%  Repositories not in groups:%RESET%
set repo_count=0
for /f "usebackq tokens=1,* delims=;" %%a in ("%CONFIG_FILE%") do (
  set "in_group=0"
  if exist "%GROUPS_FILE%" (
    for /f "usebackq tokens=2 delims=;" %%g in ("%GROUPS_FILE%") do (
      echo "%%g" | find "%%a" >nul 2>&1 && set "in_group=1"
    )
  )
  if !in_group!==0 (
    set /a repo_count+=1
    set "repo_name_add_!repo_count!=%%a"
    echo %GREEN%  !repo_count!.%RESET% %%a
  )
)

if !repo_count!==0 (
  echo %YELLOW%  No repositories to add%RESET%
  pause
  goto MANAGE_GROUPS
  ) else (
  echo.
  set /p "repo_num=%BOLD%%WHITE%    ⚡ Select repository number: %RESET%"
  set "selected_repo=!repo_name_add_%repo_num%!"
)

set "temp_groups=%TEMP%\groups.tmp"
type nul > "!temp_groups!"
if exist "%GROUPS_FILE%" (
  for /f "usebackq tokens=1,* delims=;" %%a in ("%GROUPS_FILE%") do (
    if "%%a"=="!selected_group!" (
      if "%%b"=="" (
        echo %%a;!selected_repo!>> "!temp_groups!"
        ) else (
        echo %%a;%%b;!selected_repo!>> "!temp_groups!"
      )
      ) else (
      echo %%a;%%b>> "!temp_groups!"
    )
  )
  move /y "!temp_groups!" "%GROUPS_FILE%" >nul 2>&1
)

echo %GREEN%  ✅ Repository "%selected_repo%" added to group "%selected_group%"%RESET%
pause
goto MANAGE_GROUPS

:REMOVE_FROM_GROUP
cls
echo %BOLD%%CYAN%  🗑️ REMOVE FROM GROUP%RESET%
echo.

echo %BOLD%%WHITE%  Groups and their repositories:%RESET%
if exist "%GROUPS_FILE%" (
  for /f "usebackq tokens=1,* delims=;" %%a in ("%GROUPS_FILE%") do (
    echo %BOLD%%MAGENTA%  📁 %%a%RESET%
    if not "%%b"=="" (
      for %%r in (%%b) do (
        echo %GREEN%  -%RESET% %%r
      )
      ) else (
      echo %YELLOW%  empty%RESET%
    )
  )
  ) else (
  echo %YELLOW%  No groups%RESET%
  pause
  goto MANAGE_GROUPS
)

echo.
set /p "group_del=%BOLD%%WHITE%    Enter group name: %RESET%"
set /p "repo_del=%BOLD%%WHITE%    Enter repository name to remove: %RESET%"

set "temp_groups=%TEMP%\groups.tmp"
type nul > "!temp_groups!"
if exist "%GROUPS_FILE%" (
  for /f "usebackq tokens=1,* delims=;" %%a in ("%GROUPS_FILE%") do (
    if "%%a"=="!group_del!" (
      set "new_repo_list="
      set "first=1"
      for %%r in (%%b) do (
        if not "%%r"=="!repo_del!" (
          if !first!==1 (
            set "new_repo_list=%%r"
            set "first=0"
            ) else (
            set "new_repo_list=!new_repo_list!;%%r"
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

echo %GREEN%  ✅ Repository removed from group%RESET%
pause
goto MANAGE_GROUPS

:SHOW_GROUPS
cls
echo %BOLD%%CYAN%  📚 ALL GROUPS%RESET%
echo.

if exist "%GROUPS_FILE%" (
  for /f "usebackq tokens=1,* delims=;" %%a in ("%GROUPS_FILE%") do (
    echo %BOLD%%MAGENTA%  [%%a]%RESET%
    if not "%%b"=="" (
      for %%r in (%%b) do (
        echo %GREEN%  -%RESET% %%r
      )
      ) else (
      echo %YELLOW%  empty%RESET%
    )
    echo.
  )
  ) else (
  echo %YELLOW%  No groups created%RESET%
)

pause
goto MANAGE_GROUPS

:DELETE_GROUP
cls
echo %BOLD%%CYAN%  🗑️ DELETE GROUP%RESET%
echo.

if exist "%GROUPS_FILE%" (
  for /f "usebackq tokens=1 delims=;" %%a in ("%GROUPS_FILE%") do (
    echo %GREEN%  -%RESET% %%a
  )
  ) else (
  echo %YELLOW%  No groups to delete%RESET%
  pause
  goto MANAGE_GROUPS
)

echo.
set /p "group_del_name=%BOLD%%WHITE%    Enter group name to delete: %RESET%"

set "temp_groups=%TEMP%\groups.tmp"
type nul > "!temp_groups!"
if exist "%GROUPS_FILE%" (
  for /f "usebackq tokens=1,* delims=;" %%a in ("%GROUPS_FILE%") do (
    if not "%%a"=="!group_del_name!" (
      echo %%a;%%b>> "!temp_groups!"
    )
  )
  move /y "!temp_groups!" "%GROUPS_FILE%" >nul 2>&1
)

echo %GREEN%  ✅ Group deleted%RESET%
pause
goto MANAGE_GROUPS
