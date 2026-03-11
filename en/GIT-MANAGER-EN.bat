@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: Color formatting
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

:: Remember the path to the batch file folder
set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"

:: Path to configs
set "CONFIG_FILE=%SCRIPT_DIR%\git_repos.cfg"
set "GROUPS_FILE=%SCRIPT_DIR%\groups.cfg"
set "TEMP_FILE=%SCRIPT_DIR%\temp.cfg"

:MENU
cls
echo %BOLD%%CYAN%╔══════════════════════════════════════════════════════════╗%RESET%
echo %BOLD%%CYAN%║              GIT REPOSITORY MANAGER                      ║%RESET%
echo %BOLD%%CYAN%╚══════════════════════════════════════════════════════════╝%RESET%
echo %YELLOW%=====================By AtinsS==============================%RESET%
echo.

:: Load saved repositories list
set count=0
if exist "%CONFIG_FILE%" (
    echo %BOLD%%WHITE%Saved repositories:%RESET%
    echo %BLUE%------------------------%RESET%
    
    :: First show by groups
    if exist "%GROUPS_FILE%" (
        for /f "usebackq tokens=1,* delims=;" %%a in ("%GROUPS_FILE%") do (
            echo.
            echo %BOLD%%MAGENTA%[Group: %%a]%RESET%
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
                            echo !status_! %GREEN%!count!. %BOLD%%%x%RESET% - %CYAN%%%y%RESET% !branch_!
                            set "repo_found=1"
                        )
                    )
                    if !repo_found!==0 (
                        echo %RED%  ⚠ Repository "%%r" not found in list%RESET%
                    )
                )
            ) else (
                echo %YELLOW%  group is empty%RESET%
            )
        )
    )
    
    :: Show repositories without group
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
        echo %BOLD%%YELLOW%[No group]%RESET%
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
                echo !status_! %GREEN%!count!. %BOLD%%%a%RESET% - %CYAN%%%b%RESET% !branch_!!!
            )
        )
    )
) else (
    echo %YELLOW%Repository list is empty%RESET%
)

echo.
echo %BOLD%%WHITE%Actions:%RESET%
echo %BLUE%========%RESET%
if %count% gtr 0 echo %GREEN%Enter repository number (1-%count%)%RESET%
echo %CYAN%C.%RESET% Clone new repository
echo %CYAN%A.%RESET% Add existing local repository
echo %CYAN%U.%RESET% Update all repositories
echo %CYAN%G.%RESET% Manage groups
echo %CYAN%D.%RESET% Delete repository from list
echo %CYAN%S.%RESET% Settings
echo %RED%X.%RESET% Exit
echo.
set /p "action=%BOLD%%WHITE%Your choice: %RESET%"

:: Check if number or letter
set is_number=0
echo %action%| findstr /r "^[0-9][0-9]*$" >nul 2>&1
if not errorlevel 1 set is_number=1

if %is_number%==1 (
    if %action% leq %count% (
        set "repo_index=%action%"
        call :SELECT_REPO
        goto MENU
    ) else (
        echo %RED%Invalid number!%RESET%
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
    if /i "%action%"=="X" exit /b
    echo %RED%Invalid choice!%RESET%
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
            set "branch_info=%CYAN%[!branch_info!]%RESET%"
        ) else (
            set "branch_info=%RED%[no branch]%RESET%"
        )
        
        :: Check status
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
        set "branch_info=%RED%[no access]%RESET%"
    )
) else (
    set "status_icon=%RED%[?]%RESET%"
    set "branch_info=%RED%[folder not found]%RESET%"
)

set "%status_var%=!status_icon!"
set "branch_%count%=!branch_info!"
goto :eof

:SELECT_REPO
:: Get name and path by index
set "REPO_NAME=!repo_name_%repo_index%!"
set "REPO_PATH=!repo_path_%repo_index%!"

echo.
echo %BOLD%%WHITE%Selected repository:%RESET% %GREEN%%REPO_NAME%%RESET%
echo %BOLD%%WHITE%Path:%RESET% %CYAN%%REPO_PATH%%RESET%

:: Check if folder exists
if not exist "%REPO_PATH%" (
    echo.
    echo %RED%⚠ WARNING: Folder not found!%RESET%
    echo.
    echo %GREEN%1.%RESET% Clone again
    echo %YELLOW%2.%RESET% Specify new path
    echo %RED%3.%RESET% Back to menu
    echo.
    set /p "fix=%BOLD%%WHITE%Choose action: %RESET%"
    
    if "!fix!"=="1" (
        call :CLONE_REPO_EXISTING "%REPO_NAME%" "%REPO_PATH%"
        goto :eof
    ) else if "!fix!"=="2" (
        set /p "REPO_PATH=%YELLOW%New path: %RESET%"
        call :UPDATE_REPO_PATH "%REPO_NAME%" "!REPO_PATH!"
        cd /d "!REPO_PATH!" 2>nul
    ) else (
        goto :eof
    )
) else (
    cd /d "%REPO_PATH%" 2>nul
)

:: Check if navigation succeeded
if errorlevel 1 (
    echo %RED%Error: Cannot navigate to folder!%RESET%
    pause
    goto :eof
)

:: Check if this is a git repository
git status >nul 2>&1
if errorlevel 1 (
    echo %RED%Error: Folder is not a git repository!%RESET%
    pause
    goto :eof
)

call :REPO_MENU "%REPO_NAME%"
goto :eof

:REPO_MENU
set "current_repo=%~1"

:REPO_LOOP
cls
:: Get current branch for display
set "current_branch="
for /f "tokens=*" %%b in ('git branch --show-current 2^>nul') do set "current_branch=%%b"
if "!current_branch!"=="" (
    for /f "tokens=2" %%b in ('git branch 2^>nul ^| find "*"') do set "current_branch=%%b"
)
if "!current_branch!"=="" set "current_branch=unknown"

:: Get status
git status --porcelain | findstr . >nul 2>&1
if errorlevel 1 (
    set "repo_status=%GREEN%clean%RESET%"
) else (
    set "repo_status=%YELLOW%has changes%RESET%"
)

echo %CYAN%════════════════════════════════════════════════════════════%RESET%
echo %BOLD%%WHITE%      Repository:%RESET% %GREEN%%current_repo%%RESET%
echo %BOLD%%WHITE%      Path:%RESET% %YELLOW%%cd%%RESET%
echo %BOLD%%WHITE%      Branch:%RESET% %BLUE%!current_branch!%RESET%  %BOLD%%WHITE%Status:%RESET% !repo_status!
echo %CYAN%════════════════════════════════════════════════════════════%RESET%
echo.
echo %GREEN%1.%RESET% Git status (check state)
echo %GREEN%2.%RESET% Git pull (update)
echo %GREEN%3.%RESET% Git add + commit (with message)
echo %GREEN%4.%RESET% Git push (send)
echo %GREEN%5.%RESET% Quick commit + push (auto-message)
echo %GREEN%6.%RESET% View history (git log)
echo %GREEN%7.%RESET% Create branch
echo %GREEN%8.%RESET% Switch branch
echo %GREEN%9.%RESET% Auto-commits (every N minutes)
echo %RED%0.%RESET% Back to main menu
echo.
set /p "repo_action=%BOLD%%WHITE%Choose action: %RESET%"

:: Check if scripts exist
if not exist "%SCRIPT_DIR%\git-scripts" (
    mkdir "%SCRIPT_DIR%\git-scripts" 2>nul
)

if "%repo_action%"=="1" (
    if exist "%SCRIPT_DIR%\git-scripts\01-git-status.bat" (
        call "%SCRIPT_DIR%\git-scripts\01-git-status.bat" "%current_repo%"
    ) else (
        echo %RED%Script not found!%RESET%
        git status
    )
    pause
    goto REPO_LOOP
)
if "%repo_action%"=="2" (
    if exist "%SCRIPT_DIR%\git-scripts\02-git-pull.bat" (
        call "%SCRIPT_DIR%\git-scripts\02-git-pull.bat" "%current_repo%"
    ) else (
        git pull
    )
    pause
    goto REPO_LOOP
)
if "%repo_action%"=="3" (
    if exist "%SCRIPT_DIR%\git-scripts\03-git-commit.bat" (
        call "%SCRIPT_DIR%\git-scripts\03-git-commit.bat" "%current_repo%"
    ) else (
        set /p "commit_msg=%YELLOW%Commit message: %RESET%"
        git add . && git commit -m "!commit_msg!"
    )
    pause
    goto REPO_LOOP
)
if "%repo_action%"=="4" (
    if exist "%SCRIPT_DIR%\git-scripts\04-git-push.bat" (
        call "%SCRIPT_DIR%\git-scripts\04-git-push.bat" "%current_repo%"
    ) else (
        git push
    )
    pause
    goto REPO_LOOP
)
if "%repo_action%"=="5" (
    if exist "%SCRIPT_DIR%\git-scripts\05-git-quick-push.bat" (
        call "%SCRIPT_DIR%\git-scripts\05-git-quick-push.bat" "%current_repo%"
    ) else (
        git add . && git commit -m "Quick update %date% %time%" && git push
    )
    pause
    goto REPO_LOOP
)
if "%repo_action%"=="6" (
    if exist "%SCRIPT_DIR%\git-scripts\06-git-log.bat" (
        call "%SCRIPT_DIR%\git-scripts\06-git-log.bat" "%current_repo%"
    ) else (
        git log --oneline --graph --all -n 20
    )
    pause
    goto REPO_LOOP
)
if "%repo_action%"=="7" (
    if exist "%SCRIPT_DIR%\git-scripts\07-git-create-branch.bat" (
        call "%SCRIPT_DIR%\git-scripts\07-git-create-branch.bat" "%current_repo%"
    ) else (
        set /p "branch_name=%YELLOW%Branch name: %RESET%"
        git branch "!branch_name!"
    )
    pause
    goto REPO_LOOP
)
if "%repo_action%"=="8" (
    if exist "%SCRIPT_DIR%\git-scripts\08-git-switch-branch.bat" (
        call "%SCRIPT_DIR%\git-scripts\08-git-switch-branch.bat" "%current_repo%"
    ) else (
        git branch
        set /p "branch_name=%YELLOW%Branch to switch to: %RESET%"
        git checkout "!branch_name!"
    )
    pause
    goto REPO_LOOP
)
if "%repo_action%"=="9" (
    if exist "%SCRIPT_DIR%\git-scripts\09-git-auto-commit.bat" (
        call "%SCRIPT_DIR%\git-scripts\09-git-auto-commit.bat" "%current_repo%"
    ) else (
        echo %RED%Auto-commit script not found%RESET%
    )
    pause
    goto REPO_LOOP
)
if "%repo_action%"=="0" goto MENU

echo %RED%Invalid choice!%RESET%
pause
goto REPO_LOOP

:CLONE_REPO
cls
echo %BOLD%%CYAN%=== CLONE REPOSITORY ===%RESET%
echo.
set /p "repo_name=%GREEN%Repository name (to save): %RESET%"
set /p "repo_url=%YELLOW%Repository URL (https://github.com/...): %RESET%"
set /p "clone_path=%BLUE%Path for cloning (Enter - current folder): %RESET%"

if "!clone_path!"=="" set "clone_path=%cd%"
if not exist "!clone_path!" mkdir "!clone_path!" 2>nul

set "full_path=!clone_path!\!repo_name!"

echo.
echo %BOLD%Cloning %repo_name% from %repo_url% to %full_path%...%RESET%
git clone "%repo_url%" "%full_path%"

if errorlevel 1 (
    echo %RED%Clone error!%RESET%
    pause
    goto MENU
)

echo %repo_name%;%full_path% >> "%CONFIG_FILE%"
echo %GREEN%Repository successfully cloned and added to list!%RESET%

:: Ask about group
echo.
echo %BOLD%%WHITE%Add repository to group?%RESET%
set /p "add_to_group=%YELLOW%[y/n]: %RESET%"

if /i "!add_to_group!"=="y" (
    call :ADD_REPO_TO_GROUP "%repo_name%"
)

pause
goto MENU

:ADD_EXISTING
cls
echo %BOLD%%CYAN%=== ADD EXISTING REPOSITORY ===%RESET%
echo.
set /p "repo_name=%GREEN%Repository name: %RESET%"
set /p "repo_path=%YELLOW%Full path to repository: %RESET%"

set "repo_path=%repo_path:"=%"

if "!repo_path!"=="" (
    echo %RED%Error: Path cannot be empty!%RESET%
    pause
    goto MENU
)

if not exist "!repo_path!" (
    echo %RED%Error: Folder not found!%RESET%
    pause
    goto MENU
)

pushd "!repo_path!" 2>nul
if errorlevel 1 (
    echo %RED%Error: Cannot navigate to folder!%RESET%
    pause
    goto MENU
)

git status >nul 2>&1
if errorlevel 1 (
    echo %RED%Error: Folder is not a git repository!%RESET%
    popd
    pause
    goto MENU
)
popd

:: Save to config
echo %repo_name%;!repo_path! >> "%CONFIG_FILE%"
echo %GREEN%Repository added to list!%RESET%

:: Ask about group
echo.
echo %BOLD%%WHITE%Add repository to group?%RESET%
set /p "add_to_group=%YELLOW%[y/n]: %RESET%"

if /i "!add_to_group!"=="y" (
    call :ADD_REPO_TO_GROUP "%repo_name%"
)

pause
goto MENU

:ADD_REPO_TO_GROUP
set "repo_to_add=%~1"

:: Check if groups exist
if not exist "%GROUPS_FILE%" (
    echo %YELLOW%No groups created. Want to create a new one?%RESET%
    set /p "create_new=%YELLOW%[y/n]: %RESET%"
    if /i "!create_new!"=="y" (
        call :CREATE_GROUP_FROM_ADD "%repo_to_add%"
    )
    goto :eof
) else (
    :: Check if there are actually any groups in the file (file might be empty)
    set "group_exists=0"
    for /f "usebackq tokens=1 delims=;" %%a in ("%GROUPS_FILE%") do (
        if not "%%a"=="" set "group_exists=1"
    )
    
    if !group_exists!==0 (
        echo %YELLOW%No groups created. Want to create a new one?%RESET%
        set /p "create_new=%YELLOW%[y/n]: %RESET%"
        if /i "!create_new!"=="y" (
            call :CREATE_GROUP_FROM_ADD "%repo_to_add%"
        )
        goto :eof
    )
    
    :: Show existing groups
    echo.
    echo %BOLD%%WHITE%Select group:%RESET%
    set group_count=0
    for /f "usebackq tokens=1 delims=;" %%a in ("%GROUPS_FILE%") do (
        if not "%%a"=="" (
            set /a group_count+=1
            set "group_name_add_!group_count!=%%a"
            echo %GREEN%!group_count!.%RESET% %%a
        )
    )
    echo %GREEN%0.%RESET% Create new group
    
    echo.
    set /p "group_choice=%BOLD%%WHITE%Your choice: %RESET%"
    
    if "!group_choice!"=="0" (
        call :CREATE_GROUP_FROM_ADD "%repo_to_add%"
    ) else (
        set "selected_group=!group_name_add_%group_choice%!"
        
        :: Add to selected group
        set "temp_groups=%TEMP%\groups.tmp"
        if exist "%GROUPS_FILE%" (
            type nul > "!temp_groups!"
            for /f "usebackq tokens=1,* delims=;" %%a in ("%GROUPS_FILE%") do (
                if "%%a"=="!selected_group!" (
                    :: Check if repository list is empty
                    if "%%b"=="" (
                        echo %%a;!repo_to_add!>> "!temp_groups!"
                    ) else (
                        echo %%a;%%b !repo_to_add!>> "!temp_groups!"
                    )
                ) else (
                    echo %%a;%%b>> "!temp_groups!"
                )
            )
            move /y "!temp_groups!" "%GROUPS_FILE%" >nul 2>&1
        )
        echo %GREEN%Repository "%repo_to_add%" added to group "%selected_group%"%RESET%
    )
)
goto :eof

:CREATE_GROUP_FROM_ADD
set "repo_to_add=%~1"
echo.
set /p "new_group=%GREEN%Enter new group name: %RESET%"

if "!new_group!"=="" (
    echo %RED%Name cannot be empty!%RESET%
    pause
    goto :eof
)

:: Check if group already exists
if exist "%GROUPS_FILE%" (
    findstr /b "!new_group!;" "%GROUPS_FILE%" >nul 2>&1
    if not errorlevel 1 (
        echo %RED%A group with this name already exists!%RESET%
        pause
        goto :eof
    )
)

:: Create group and add repository
echo !new_group!;!repo_to_add!>> "%GROUPS_FILE%"
echo %GREEN%Group "%new_group%" created and repository added!%RESET%
goto :eof

:UPDATE_ALL
cls
echo %BOLD%%CYAN%=== UPDATE ALL REPOSITORIES ===%RESET%
echo.

if not exist "%CONFIG_FILE%" (
    echo %RED%No saved repositories!%RESET%
    pause
    goto MENU
)

for /f "usebackq tokens=1,2 delims=;" %%a in ("%CONFIG_FILE%") do (
    echo.
    echo %BOLD%%BLUE%===== Processing:%RESET% %GREEN%%%a%RESET% %BLUE%=====%RESET%
    if exist "%%b" (
        pushd "%%b" 2>nul
        if not errorlevel 1 (
            echo %YELLOW%Updating...%RESET%
            git pull
            popd
        ) else (
            echo %RED%⚠ Cannot navigate to folder%RESET%
        )
    ) else (
        echo %RED%⚠ Folder not found: %%b%RESET%
    )
)

echo.
echo %GREEN%Update completed!%RESET%
pause
goto MENU

:DELETE_REPO
cls
echo %BOLD%%CYAN%=== DELETE REPOSITORY FROM LIST ===%RESET%
echo.

if not exist "%CONFIG_FILE%" (
    echo %RED%No repositories to delete!%RESET%
    pause
    goto MENU
)

set idx=1
for /f "usebackq tokens=1,2 delims=;" %%a in ("%CONFIG_FILE%") do (
    echo %GREEN%!idx!.%RESET% %%a - %CYAN%%%b%RESET%
    set /a idx+=1
)

echo.
set /p "del_num=%BOLD%%RED%Repository number to delete: %RESET%"

set skip_line=%del_num%
set current=0
type nul > "%TEMP_FILE%"
if exist "%CONFIG_FILE%" (
    for /f "usebackq tokens=1,2 delims=;" %%a in ("%CONFIG_FILE%") do (
        set /a current+=1
        if not !current!==%skip_line% (
            echo %%a;%%b >> "%TEMP_FILE%"
        )
    )
    move /y "%TEMP_FILE%" "%CONFIG_FILE%" >nul 2>nul
)

echo %GREEN%Repository removed from list!%RESET%
pause
goto MENU

:SETTINGS
cls
echo %BOLD%%CYAN%=== SETTINGS ===%RESET%
echo.
echo %GREEN%1.%RESET% Show all repositories
echo %YELLOW%2.%RESET% Clear list
echo %BLUE%3.%RESET% Edit paths manually
echo %MAGENTA%4.%RESET% Auto-repair configs
echo %RED%5.%RESET% Back
echo.
set /p "sett=%BOLD%%WHITE%Choose: %RESET%"

if "%sett%"=="1" (
    cls
    echo %BOLD%%WHITE%Repository list:%RESET%
    echo %BLUE%===================%RESET%
    if exist "%CONFIG_FILE%" (
        for /f "usebackq tokens=1,2 delims=;" %%a in ("%CONFIG_FILE%") do (
            echo %GREEN%%%a%RESET% - %CYAN%%%b%RESET%
        )
    ) else (
        echo %YELLOW%List is empty%RESET%
    )
    echo.
    pause
    goto SETTINGS
)

if "%sett%"=="2" (
    del "%CONFIG_FILE%" 2>nul
    del "%GROUPS_FILE%" 2>nul
    echo %GREEN%Lists cleared!%RESET%
    pause
    goto SETTINGS
)

if "%sett%"=="3" (
    if exist "%CONFIG_FILE%" (
        notepad "%CONFIG_FILE%"
    ) else (
        echo %RED%List is empty, nothing to edit%RESET%
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
echo %YELLOW%Enter URL to clone %repo_name%:%RESET%
set /p "repo_url=%BOLD%URL: %RESET%"

echo %BOLD%Cloning %repo_name%...%RESET%
if exist "%repo_dir%" (
    rd /s /q "%repo_dir%" 2>nul
)
git clone "%repo_url%" "%repo_dir%"
if errorlevel 1 (
    echo %RED%Clone error!%RESET%
) else (
    echo %GREEN%Done!%RESET%
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
echo %BOLD%%YELLOW%Auto-repairing configurations...%RESET%

:: Repair git_repos.cfg
if exist "%CONFIG_FILE%" (
    set "temp_cfg=%TEMP%\git_repos_fixed.cfg"
    type nul > "!temp_cfg!"
    for /f "usebackq tokens=1,* delims=;" %%a in ("%CONFIG_FILE%") do (
        :: Clean name - take only first word
        for /f "tokens=1" %%n in ("%%a") do set "clean_name=%%n"
        :: Clean path - remove extra words at the end
        set "clean_path=%%b"
        echo !clean_name!;!clean_path!>> "!temp_cfg!"
    )
    move /y "!temp_cfg!" "%CONFIG_FILE%" >nul 2>nul
    echo %GREEN%git_repos.cfg repaired%RESET%
)

:: Repair groups.cfg
if exist "%GROUPS_FILE%" (
    set "temp_groups=%TEMP%\groups_fixed.cfg"
    type nul > "!temp_groups!"
    for /f "usebackq tokens=1,* delims=;" %%a in ("%GROUPS_FILE%") do (
        set "new_repo_list="
        for %%r in (%%b) do (
            :: Clean repository name from duplicates
            for /f "tokens=1" %%n in ("%%r") do set "clean_repo=%%n"
            set "new_repo_list=!new_repo_list! !clean_repo!"
        )
        echo %%a;!new_repo_list!>> "!temp_groups!"
    )
    move /y "!temp_groups!" "%GROUPS_FILE%" >nul 2>nul
    echo %GREEN%groups.cfg repaired%RESET%
)

echo.
echo %GREEN%Repair completed! Restart the program.%RESET%
pause
exit /b

:MANAGE_GROUPS
cls
echo %BOLD%%CYAN%=== MANAGE GROUPS ===%RESET%
echo.
echo %GREEN%1.%RESET% Create new group
echo %GREEN%2.%RESET% Add repository to group
echo %GREEN%3.%RESET% Remove repository from group
echo %GREEN%4.%RESET% Show all groups
echo %GREEN%5.%RESET% Delete group
echo %RED%6.%RESET% Back
echo.
set /p "grp_act=%BOLD%%WHITE%Choose: %RESET%"

if "!grp_act!"=="1" goto CREATE_GROUP
if "!grp_act!"=="2" goto ADD_TO_GROUP
if "!grp_act!"=="3" goto REMOVE_FROM_GROUP
if "!grp_act!"=="4" goto SHOW_GROUPS
if "!grp_act!"=="5" goto DELETE_GROUP
if "!grp_act!"=="6" goto MENU
goto MANAGE_GROUPS

:CREATE_GROUP
cls
echo %BOLD%%CYAN%=== CREATE GROUP ===%RESET%
echo.
set /p "new_group=%GREEN%Enter group name: %RESET%"

if "!new_group!"=="" (
    echo %RED%Name cannot be empty!%RESET%
    pause
    goto MANAGE_GROUPS
)

if exist "%GROUPS_FILE%" (
    findstr /b "!new_group!;" "%GROUPS_FILE%" >nul 2>&1
    if not errorlevel 1 (
        echo %RED%A group with this name already exists!%RESET%
        pause
        goto MANAGE_GROUPS
    )
)

echo !new_group!;>> "%GROUPS_FILE%"
echo %GREEN%Group "%new_group%" created!%RESET%
pause
goto MANAGE_GROUPS

:ADD_TO_GROUP
cls
echo %BOLD%%CYAN%=== ADD TO GROUP ===%RESET%
echo.

echo %BOLD%%WHITE%Existing groups:%RESET%
set group_count=0
if exist "%GROUPS_FILE%" (
    for /f "usebackq tokens=1 delims=;" %%a in ("%GROUPS_FILE%") do (
        if not "%%a"=="" (
            set /a group_count+=1
            set "group_name_!group_count!=%%a"
            echo %GREEN%!group_count!.%RESET% %%a
        )
    )
) else (
    echo %YELLOW%No groups created%RESET%
    pause
    goto MANAGE_GROUPS
)

if !group_count!==0 (
    echo %YELLOW%No groups created%RESET%
    pause
    goto MANAGE_GROUPS
)

echo.
set /p "group_num=%BOLD%%WHITE%Select group number: %RESET%"
set "selected_group=!group_name_%group_num%!"

echo.
echo %BOLD%%WHITE%Repositories not in groups:%RESET%
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
        echo %GREEN%!repo_count!.%RESET% %%a
    )
)

if !repo_count!==0 (
    echo %YELLOW%No repositories to add%RESET%
    pause
    goto MANAGE_GROUPS
)

echo.
set /p "repo_num=%BOLD%%WHITE%Select repository number: %RESET%"
set "selected_repo=!repo_name_add_%repo_num%!"

set "temp_groups=%TEMP%\groups.tmp"
type nul > "!temp_groups!"
if exist "%GROUPS_FILE%" (
    for /f "usebackq tokens=1,* delims=;" %%a in ("%GROUPS_FILE%") do (
        if "%%a"=="!selected_group!" (
            :: Check if repository list is empty
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

echo %GREEN%Repository "%selected_repo%" added to group "%selected_group%"%RESET%
pause
goto MANAGE_GROUPS

:REMOVE_FROM_GROUP
cls
echo %BOLD%%CYAN%=== REMOVE FROM GROUP ===%RESET%
echo.

echo %BOLD%%WHITE%Groups and their repositories:%RESET%
if exist "%GROUPS_FILE%" (
    for /f "usebackq tokens=1,* delims=;" %%a in ("%GROUPS_FILE%") do (
        echo.
        echo %BOLD%%MAGENTA%Group: %%a%RESET%
        for %%r in (%%b) do (
            echo   %GREEN%-%RESET% %%r
        )
    )
) else (
    echo %YELLOW%No groups%RESET%
    pause
    goto MANAGE_GROUPS
)

echo.
set /p "group_del=%BOLD%%WHITE%Enter group name: %RESET%"
set /p "repo_del=%BOLD%%WHITE%Enter repository name to remove: %RESET%"

set "temp_groups=%TEMP%\groups.tmp"
type nul > "!temp_groups!"
if exist "%GROUPS_FILE%" (
    for /f "usebackq tokens=1,* delims=;" %%a in ("%GROUPS_FILE%") do (
        if "%%a"=="!group_del!" (
            set "new_repo_list="
            for %%r in (%%b) do (
                if not "%%r"=="!repo_del!" set "new_repo_list=!new_repo_list! %%r"
            )
            echo %%a;!new_repo_list!>> "!temp_groups!"
        ) else (
            echo %%a;%%b>> "!temp_groups!"
        )
    )
    move /y "!temp_groups!" "%GROUPS_FILE%" >nul 2>&1
)

echo %GREEN%Repository removed from group%RESET%
pause
goto MANAGE_GROUPS

:SHOW_GROUPS
cls
echo %BOLD%%CYAN%=== ALL GROUPS ===%RESET%
echo.

if exist "%GROUPS_FILE%" (
    for /f "usebackq tokens=1,2 delims=;" %%a in ("%GROUPS_FILE%") do (
        echo %BOLD%%MAGENTA%[%%a]%RESET%
        if not "%%b"=="" (
            for %%r in (%%b) do (
                echo   %GREEN%-%RESET% %%r
            )
        ) else (
            echo   %YELLOW%empty%RESET%
        )
        echo.
    )
) else (
    echo %YELLOW%No groups created%RESET%
)

pause
goto MANAGE_GROUPS

:DELETE_GROUP
cls
echo %BOLD%%CYAN%=== DELETE GROUP ===%RESET%
echo.

if exist "%GROUPS_FILE%" (
    for /f "usebackq tokens=1 delims=;" %%a in ("%GROUPS_FILE%") do (
        echo %GREEN%-%RESET% %%a
    )
) else (
    echo %YELLOW%No groups to delete%RESET%
    pause
    goto MANAGE_GROUPS
)

echo.
set /p "group_del_name=%BOLD%%WHITE%Enter group name to delete: %RESET%"

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

echo %GREEN%Group deleted%RESET%
pause
goto MANAGE_GROUPS