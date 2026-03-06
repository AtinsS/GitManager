@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: Color scheme
:: 0 - Black       8 - Gray
:: 1 - Blue        9 - Light Blue
:: 2 - Green       A - Light Green
:: 3 - Cyan        B - Light Cyan
:: 4 - Red         C - Light Red
:: 5 - Purple      D - Light Purple
:: 6 - Yellow      E - Light Yellow
:: 7 - White       F - Bright White

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

:: Remember the path to the batch file folder (fixed for paths with spaces)
set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"

:: Path to config file (now in the batch file folder)
set "CONFIG_FILE=%SCRIPT_DIR%\git_repos.cfg"
set "TEMP_FILE=%SCRIPT_DIR%\temp.cfg"

:: Check if git is available
where git >nul 2>nul
if errorlevel 1 (
    echo %RED%Git not found! Please install Git for Windows%RESET%
    echo %BLUE%https://git-scm.com/download/win%RESET%
    pause
    exit /b
)

:MENU
cls
echo %BOLD%%CYAN%╔══════════════════════════════════════════════════════════╗%RESET%
echo %BOLD%%CYAN%║                 GIT REPOSITORY MANAGER                   ║%RESET%
echo %BOLD%%CYAN%╚══════════════════════════════════════════════════════════╝%RESET%
echo %YELLOW%=====================By AtinsS==============================%RESET%
echo.

:: Load the list of saved repositories
set count=0
if exist "%CONFIG_FILE%" (
    echo %BOLD%%WHITE%Saved repositories:%RESET%
    echo %BLUE%------------------------%RESET%
    for /f "usebackq tokens=1,2 delims=;" %%a in ("%CONFIG_FILE%") do (
        set /a count+=1
        set "repo_name_!count!=%%a"
        set "repo_path_!count!=%%b"
        echo %GREEN%!count!. %BOLD%%%a%RESET% - %CYAN%%%b%RESET%
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
echo %CYAN%D.%RESET% Delete repository from list
echo %CYAN%S.%RESET% Settings
echo %RED%X.%RESET% Exit
echo.
set /p "action=%BOLD%%WHITE%Your choice: %RESET%"

:: Check if it's a number or letter
set is_number=0
echo %action%| findstr /r "^[0-9][0-9]*$" >nul
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
    if /i "%action%"=="D" goto DELETE_REPO
    if /i "%action%"=="S" goto SETTINGS
    if /i "%action%"=="X" exit /b
    goto MENU
)

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
    echo %RED%3.%RESET% Return to menu
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

:: Check if we successfully changed directory
if errorlevel 1 (
    echo %RED%Error: Cannot change to folder!%RESET%
    pause
    goto :eof
)

:: Check if it's a git repository
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
echo %CYAN%════════════════════════════════════════════════════════════%RESET%
echo %BOLD%%WHITE%      Repository:%RESET% %GREEN%%current_repo%%RESET%
echo %BOLD%%WHITE%      Path:%RESET% %YELLOW%%cd%%RESET%
echo %CYAN%════════════════════════════════════════════════════════════%RESET%
echo.
echo %GREEN%1.%RESET% Git status (check state)
echo %GREEN%2.%RESET% Git pull (update)
echo %GREEN%3.%RESET% Git add + commit (with message)
echo %GREEN%4.%RESET% Git push (send)
echo %GREEN%5.%RESET% Quick commit + push (auto message)
echo %GREEN%6.%RESET% View history (git log)
echo %GREEN%7.%RESET% Create branch
echo %GREEN%8.%RESET% Switch branch
echo %GREEN%9.%RESET% Auto commits (every N minutes)
echo %RED%0.%RESET% Return to main menu
echo.
set /p "repo_action=%BOLD%%WHITE%Choose action: %RESET%"

if "%repo_action%"=="1" call "%SCRIPT_DIR%\git-scripts\01-git-status-en.bat" "%current_repo%"
if "%repo_action%"=="2" call "%SCRIPT_DIR%\git-scripts\02-git-pull-en.bat" "%current_repo%"
if "%repo_action%"=="3" call "%SCRIPT_DIR%\git-scripts\03-git-commit-en.bat" "%current_repo%"
if "%repo_action%"=="4" call "%SCRIPT_DIR%\git-scripts\04-git-push-en.bat" "%current_repo%"
if "%repo_action%"=="5" call "%SCRIPT_DIR%\git-scripts\05-git-quick-push-en.bat" "%current_repo%"
if "%repo_action%"=="6" call "%SCRIPT_DIR%\git-scripts\06-git-log-en.bat" "%current_repo%"
if "%repo_action%"=="7" call "%SCRIPT_DIR%\git-scripts\07-git-create-branch-en.bat" "%current_repo%"
if "%repo_action%"=="8" call "%SCRIPT_DIR%\git-scripts\08-git-switch-branch-en.bat" "%current_repo%"
if "%repo_action%"=="9" call "%SCRIPT_DIR%\git-scripts\09-git-auto-commit-en.bat" "%current_repo%"
if "%repo_action%"=="0" goto MENU

goto REPO_LOOP

:CLONE_REPO
cls
echo %BOLD%%CYAN%=== CLONE REPOSITORY ===%RESET%
echo.
set /p "repo_name=%GREEN%Repository name (to save): %RESET%"
set /p "repo_url=%YELLOW%Repository URL (https://github.com/...): %RESET%"
set /p "clone_path=%BLUE%Path for cloning (Enter - current folder): %RESET%"

if "!clone_path!"=="" set "clone_path=%cd%"

:: Create folder if it doesn't exist
if not exist "!clone_path!" mkdir "!clone_path!"

set "full_path=!clone_path!\!repo_name!"

echo.
echo %BOLD%Cloning %repo_name% from %repo_url% to %full_path%...%RESET%
git clone "%repo_url%" "%full_path%"

if errorlevel 1 (
    echo %RED%Cloning error!%RESET%
    pause
    goto MENU
)

:: Save to config (in the batch file folder!)
echo %repo_name%;%full_path% >> "%CONFIG_FILE%"
echo.
echo %GREEN%Repository successfully cloned and added to list!%RESET%
pause
goto MENU

:ADD_EXISTING
cls
echo %BOLD%%CYAN%=== ADD EXISTING REPOSITORY ===%RESET%
echo.
set /p "repo_name=%GREEN%Repository name: %RESET%"
set /p "repo_path=%YELLOW%Full path to repository: %RESET%"

:: Remove possible quotes from path
set "repo_path=%repo_path:"=%"

:: Check that path is not empty
if "!repo_path!"=="" (
    echo %RED%Error: Path cannot be empty!%RESET%
    pause
    goto MENU
)

:: Check that it's a git repository
if not exist "!repo_path!" (
    echo %RED%Error: Folder not found!%RESET%
    pause
    goto MENU
)

:: Temporarily go to repository folder for verification
pushd "!repo_path!" 2>nul
if errorlevel 1 (
    echo %RED%Error: Cannot change to folder!%RESET%
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

:: Save to config (in the batch file folder!)
echo %repo_name%;!repo_path! >> "%CONFIG_FILE%"
echo.
echo %GREEN%Repository added to list!%RESET%
pause
goto MENU

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
            echo %RED%⚠ Cannot change to folder%RESET%
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

:: Show list with numbers
set idx=1
for /f "usebackq tokens=1,2 delims=;" %%a in ("%CONFIG_FILE%") do (
    echo %GREEN%!idx!.%RESET% %%a - %CYAN%%%b%RESET%
    set /a idx+=1
)

echo.
set /p "del_num=%BOLD%%RED%Number of repository to delete: %RESET%"

:: Create new config without the deleted line
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

echo %GREEN%Repository removed from list!%RESET%
pause
goto MENU

:SETTINGS
cls
echo %BOLD%%CYAN%=== SETTINGS ===%RESET%
echo.
echo %GREEN%1.%RESET% Show all repositories
echo %YELLOW%2.%RESET% Clear list
echo %BLUE%3.%RESET% Manually edit paths
echo %RED%4.%RESET% Back
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
    echo %GREEN%List cleared!%RESET%
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
    echo %RED%Cloning error!%RESET%
) else (
    echo %GREEN%Done!%RESET%
)
echo.
pause
goto :eof

:UPDATE_REPO_PATH
set "repo_name=%~1"
set "new_path=%~2"

:: Update path in config (in the batch file folder!)
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