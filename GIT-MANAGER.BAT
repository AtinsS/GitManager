@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: Color scheme
set "ESC="
set "GREEN=%ESC%[92m"
set "YELLOW=%ESC%[93m"
set "CYAN=%ESC%[96m"
set "RED=%ESC%[91m"
set "WHITE=%ESC%[97m"
set "BOLD=%ESC%[1m"
set "RESET=%ESC%[0m"

:: Get script directory
set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"

:: Paths to language versions
set "RU_MAIN=%SCRIPT_DIR%\ru\GIT-MANAGER-RU.bat"
set "EN_MAIN=%SCRIPT_DIR%\en\GIT-MANAGER-EN.bat"

:: Check if Git is installed
where git >nul 2>nul
if errorlevel 1 (
    echo %YELLOW%Git not found! Please install Git for Windows%RESET%
    echo https://git-scm.com/download/win
    pause
    exit /b
)

:: Detect system language - for Russian
echo %BOLD%%CYAN%Detecting system language...%RESET%

:: Initialize language as English by default
set "LANG=EN"

:: Method 1: Check Windows UI language (most reliable)
for /f "tokens=2 delims== " %%a in ('wmic os get locale /value 2^>nul') do set "LOCALE=%%a"
if defined LOCALE (
    :: Russian locale codes
    if "%LOCALE%"=="0419" set "LANG=RU"
    if "%LOCALE%"=="0819" set "LANG=RU"
)

:: Method 2: Check system UI language via PowerShell if needed
if not defined LANG (
    for /f "usebackq delims=" %%a in (`powershell -Command "& {[System.Threading.Thread]::CurrentThread.CurrentCulture.Name}" 2^>nul`) do set "CULTURE=%%a"
    if defined CULTURE (
        if "!CULTURE!"=="ru-RU" set "LANG=RU"
        if "!CULTURE!"=="ru" set "LANG=RU"
    )
)

:: Method 3: Check keyboard layout as fallback
if "!LANG!"=="EN" (
    for /f "tokens=3" %%a in ('reg query "HKCU\Keyboard Layout\Preload" /s 2^>nul ^| findstr /i "0419"') do (
        set "LANG=RU"
    )
)

cls
echo %BOLD%%CYAN%╔══════════════════════════════════════════════════════════╗%RESET%
echo %BOLD%%CYAN%║              GIT MANAGER - AUTO LAUNCHER                 ║%RESET%
echo %BOLD%%CYAN%╚══════════════════════════════════════════════════════════╝%RESET%
echo.

:: Display detection result
if "%LANG%"=="RU" (
    echo %GREEN%✓ Обнаружена русская система%RESET%
    echo %GREEN%✓ Russian system detected%RESET%
) else (
    echo %GREEN%✓ Non-Russian system detected%RESET%
    echo %GREEN%✓ Обнаружена нерусская система%RESET%
)
echo.

:: Auto-launch based on language
if "%LANG%"=="RU" (
    if exist "%RU_MAIN%" (
        echo %WHITE%Запуск русской версии...%RESET%
        echo %CYAN%Starting Russian version...%RESET%
        echo.
        timeout /t 1 /nobreak >nul
        call "%RU_MAIN%"
    ) else (
        echo %RED%❌ Русская версия не найдена!%RESET%
        echo %YELLOW%Поиск: %RU_MAIN%%RESET%
        echo.
        goto FALLBACK_MENU
    )
) else (
    if exist "%EN_MAIN%" (
        echo %WHITE%Starting English version...%RESET%
        echo %CYAN%Запуск английской версии...%RESET%
        echo.
        timeout /t 1 /nobreak >nul
        call "%EN_MAIN%"
    ) else (
        echo %RED%❌ English version not found!%RESET%
        echo %YELLOW%Looking for: %EN_MAIN%%RESET%
        echo.
        goto FALLBACK_MENU
    )
)

:: After the called program exits, return to launcher
echo.
echo %CYAN%════════════════════════════════════════════════════════════%RESET%
echo %WHITE%Press any key to return to launcher...%RESET%
pause >nul
goto MENU

:FALLBACK_MENU
cls
echo %BOLD%%YELLOW%╔══════════════════════════════════════════════════════════╗%RESET%
echo %BOLD%%YELLOW%║              LANGUAGE VERSION NOT FOUND                 ║%RESET%
echo %BOLD%%YELLOW%║              ЯЗЫКОВАЯ ВЕРСИЯ НЕ НАЙДЕНА                 ║%RESET%
echo %BOLD%%YELLOW%╚══════════════════════════════════════════════════════════╝%RESET%
echo.

:: Check available versions
set "RU_AVAILABLE=0"
set "EN_AVAILABLE=0"

if exist "%RU_MAIN%" set "RU_AVAILABLE=1"
if exist "%EN_MAIN%" set "EN_AVAILABLE=1"

echo %WHITE%Available versions / Доступные версии:%RESET%
echo.
if %RU_AVAILABLE%==1 (
    echo %GREEN%[1]%RESET% Русская версия (Russian)
) else (
    echo %RED%[1]%RESET% Русская версия %YELLOW%(не найдена)%RESET%
)

if %EN_AVAILABLE%==1 (
    echo %GREEN%[2]%RESET% English version
) else (
    echo %RED%[2]%RESET% English version %YELLOW%(not found)%RESET%
)

echo %CYAN%[3]%RESET% Check folder structure / Проверить структуру папок
echo %RED%[X]%RESET% Exit / Выход
echo.

set /p "choice=%BOLD%%WHITE%Your choice / Ваш выбор: %RESET%"

if "%choice%"=="1" (
    if %RU_AVAILABLE%==1 (
        call "%RU_MAIN%"
    ) else (
        echo %RED%Русская версия не установлена%RESET%
        timeout /t 2 >nul
        goto FALLBACK_MENU
    )
) else if "%choice%"=="2" (
    if %EN_AVAILABLE%==1 (
        call "%EN_MAIN%"
    ) else (
        echo %RED%English version not installed%RESET%
        timeout /t 2 >nul
        goto FALLBACK_MENU
    )
) else if "%choice%"=="3" (
    goto CHECK_STRUCTURE
) else if /i "%choice%"=="X" (
    exit /b
) else (
    goto FALLBACK_MENU
)

goto MENU

:CHECK_STRUCTURE
cls
echo %BOLD%%CYAN%=== CHECKING FOLDER STRUCTURE / ПРОВЕРКА СТРУКТУРЫ ===%RESET%
echo.

:: Check ru folder
echo %WHITE%Russian folder / Русская папка:%RESET%
echo ╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌
if exist "%SCRIPT_DIR%\ru" (
    echo %GREEN%✓%RESET% ru folder found
    
    if exist "%SCRIPT_DIR%\ru\GIT-MANAGER.bat" (
        echo %GREEN%  ✓%RESET% GIT-MANAGER.bat
    ) else (
        echo %RED%  ✗%RESET% GIT-MANAGER.bat %YELLOW%(missing)%RESET%
    )
    
    if exist "%SCRIPT_DIR%\ru\git-scripts" (
        echo %GREEN%  ✓%RESET% git-scripts folder
        
        :: Count Russian scripts
        set ru_count=0
        for %%f in ("%SCRIPT_DIR%\ru\git-scripts\*.bat") do set /a ru_count+=1
        echo %CYAN%    Scripts found: %ru_count%%RESET%
    ) else (
        echo %RED%  ✗%RESET% git-scripts folder %YELLOW%(missing)%RESET%
    )
) else (
    echo %RED%✗%RESET% ru folder %YELLOW%(not found)%RESET%
)

echo.
echo %WHITE%English folder / Английская папка:%RESET%
echo ╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌
if exist "%SCRIPT_DIR%\en" (
    echo %GREEN%✓%RESET% en folder found
    
    if exist "%SCRIPT_DIR%\en\GIT-MANAGER-EN.bat" (
        echo %GREEN%  ✓%RESET% GIT-MANAGER-EN.bat
    ) else (
        echo %RED%  ✗%RESET% GIT-MANAGER-EN.bat %YELLOW%(missing)%RESET%
    )
    
    if exist "%SCRIPT_DIR%\en\git-scripts" (
        echo %GREEN%  ✓%RESET% git-scripts folder
        
        :: Count English scripts
        set en_count=0
        for %%f in ("%SCRIPT_DIR%\en\git-scripts\*.bat") do set /a en_count+=1
        echo %CYAN%    Scripts found: %en_count%%RESET%
    ) else (
        echo %RED%  ✗%RESET% git-scripts folder %YELLOW%(missing)%RESET%
    )
) else (
    echo %RED%✗%RESET% en folder %YELLOW%(not found)%RESET%
)

echo.
echo %WHITE%Options / Действия:%RESET%
echo ╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌
echo %GREEN%[1]%RESET% Create missing folders / Создать недостающие папки
echo %GREEN%[2]%RESET% Return to menu / Вернуться в меню
echo.

set /p "struct_choice=%BOLD%Choice / Выбор: %RESET%"

if "!struct_choice!"=="1" goto CREATE_FOLDERS
goto FALLBACK_MENU

:CREATE_FOLDERS
cls
echo %BOLD%%CYAN%=== CREATING FOLDERS / СОЗДАНИЕ ПАПОК ===%RESET%
echo.

:: Create ru folder structure
if not exist "%SCRIPT_DIR%\ru" (
    mkdir "%SCRIPT_DIR%\ru"
    echo %GREEN%✓ Created ru folder%RESET%
)

if not exist "%SCRIPT_DIR%\ru\git-scripts" (
    mkdir "%SCRIPT_DIR%\ru\git-scripts"
    echo %GREEN%✓ Created ru\git-scripts folder%RESET%
)

:: Create en folder structure
if not exist "%SCRIPT_DIR%\en" (
    mkdir "%SCRIPT_DIR%\en"
    echo %GREEN%✓ Created en folder%RESET%
)

if not exist "%SCRIPT_DIR%\en\git-scripts" (
    mkdir "%SCRIPT_DIR%\en\git-scripts"
    echo %GREEN%✓ Created en\git-scripts folder%RESET%
)

:: Create placeholder files with instructions
if not exist "%SCRIPT_DIR%\ru\GIT-MANAGER-RU.bat" (
    echo @echo off > "%SCRIPT_DIR%\ru\GIT-MANAGER-RU.bat"
    echo chcp 65001 ^>nul >> "%SCRIPT_DIR%\ru\GIT-MANAGER-RU.bat"
    echo echo. >> "%SCRIPT_DIR%\ru\GIT-MANAGER-RU.bat"
    echo echo %ESC%[93m================================================%ESC%[0m >> "%SCRIPT_DIR%\ru\GIT-MANAGER.bat"
    echo echo %ESC%[93m      RUSSIAN GIT MANAGER - PLACEHOLDER         %ESC%[0m >> "%SCRIPT_DIR%\ru\GIT-MANAGER.bat"
    echo echo %ESC%[93m================================================%ESC%[0m >> "%SCRIPT_DIR%\ru\GIT-MANAGER.bat"
    echo echo. >> "%SCRIPT_DIR%\ru\GIT-MANAGER-RU.bat"
    echo echo %ESC%[91mPlease add the actual Russian Git Manager content%ESC%[0m >> "%SCRIPT_DIR%\ru\GIT-MANAGER.bat"
    echo echo %ESC%[91mПожалуйста, добавьте содержимое русской версии%ESC%[0m >> "%SCRIPT_DIR%\ru\GIT-MANAGER.bat"
    echo echo. >> "%SCRIPT_DIR%\ru\GIT-MANAGER-RU.bat"
    echo pause >> "%SCRIPT_DIR%\ru\GIT-MANAGER-RU.bat"
    echo %GREEN%✓ Created placeholder ru\GIT-MANAGER-RU.bat%RESET%
)

if not exist "%SCRIPT_DIR%\en\GIT-MANAGER-EN.bat" (
    echo @echo off > "%SCRIPT_DIR%\en\GIT-MANAGER-EN.bat"
    echo chcp 65001 ^>nul >> "%SCRIPT_DIR%\en\GIT-MANAGER-EN.bat"
    echo echo. >> "%SCRIPT_DIR%\en\GIT-MANAGER-EN.bat"
    echo echo %ESC%[93m================================================%ESC%[0m >> "%SCRIPT_DIR%\en\GIT-MANAGER-EN.bat"
    echo echo %ESC%[93m      ENGLISH GIT MANAGER - PLACEHOLDER         %ESC%[0m >> "%SCRIPT_DIR%\en\GIT-MANAGER-EN.bat"
    echo echo %ESC%[93m================================================%ESC%[0m >> "%SCRIPT_DIR%\en\GIT-MANAGER-EN.bat"
    echo echo. >> "%SCRIPT_DIR%\en\GIT-MANAGER-EN.bat"
    echo echo %ESC%[91mPlease add the actual English Git Manager content%ESC%[0m >> "%SCRIPT_DIR%\en\GIT-MANAGER-EN.bat"
    echo echo. >> "%SCRIPT_DIR%\en\GIT-MANAGER-EN.bat"
    echo pause >> "%SCRIPT_DIR%\en\GIT-MANAGER-EN.bat"
    echo %GREEN%✓ Created placeholder en\GIT-MANAGER-EN.bat%RESET%
)

:: Create simple utils files
if not exist "%SCRIPT_DIR%\ru\git-scripts\utils.bat" (
    echo @echo off > "%SCRIPT_DIR%\ru\git-scripts\utils.bat"
    echo chcp 65001 ^>nul >> "%SCRIPT_DIR%\ru\git-scripts\utils.bat"
    echo echo Russian utilities placeholder >> "%SCRIPT_DIR%\ru\git-scripts\utils.bat"
    echo %GREEN%✓ Created ru\git-scripts\utils.bat%RESET%
)

if not exist "%SCRIPT_DIR%\en\git-scripts\utils-en.bat" (
    echo @echo off > "%SCRIPT_DIR%\en\git-scripts\utils-en.bat"
    echo chcp 65001 ^>nul >> "%SCRIPT_DIR%\en\git-scripts\utils-en.bat"
    echo echo English utilities placeholder >> "%SCRIPT_DIR%\en\git-scripts\utils-en.bat"
    echo %GREEN%✓ Created en\git-scripts\utils-en.bat%RESET%
)

echo.
echo %GREEN%Folder structure created!%RESET%
echo %YELLOW%Please add the full content of the scripts to the created files.%RESET%
echo %YELLOW%Пожалуйста, добавьте полное содержимое скриптов в созданные файлы.%RESET%
echo.
pause
goto FALLBACK_MENU

:MENU
cls
echo %BOLD%%CYAN%╔══════════════════════════════════════════════════════════╗%RESET%
echo %BOLD%%CYAN%║              GIT MANAGER - AUTO LAUNCHER                 ║%RESET%
echo %BOLD%%CYAN%╚══════════════════════════════════════════════════════════╝%RESET%
echo.

:: Show current language setting
echo %WHITE%Current language detection / Текущее определение языка:%RESET%
echo.
if "%LANG%"=="RU" (
    echo %GREEN%  Auto-selected: RUSSIAN / РУССКИЙ%RESET%
) else (
    echo %GREEN%  Auto-selected: ENGLISH / АНГЛИЙСКИЙ%RESET%
)
echo.

echo %WHITE%Options / Действия:%RESET%
echo %BLUE%════════════════════%RESET%
echo %GREEN%[1]%RESET% Auto-launch (based on system language)
echo      %CYAN%(Russian = RU version, everything else = EN version)%RESET%
echo      %CYAN%(Только русский = ру версия, всё остальное = en версия)%RESET%
echo.
echo %GREEN%[2]%RESET% Force Russian / Принудительно русский
echo %GREEN%[3]%RESET% Force English / Принудительно английский
echo.
echo %YELLOW%[4]%RESET% Check folder structure / Проверить структуру
echo %RED%[X]%RESET% Exit / Выход
echo.

set /p "main_choice=%BOLD%%WHITE%Your choice / Ваш выбор: %RESET%"

if "!main_choice!"=="1" (
    goto AUTO_LAUNCH
) else if "!main_choice!"=="2" (
    set "LANG=RU"
    goto AUTO_LAUNCH
) else if "!main_choice!"=="3" (
    set "LANG=EN"
    goto AUTO_LAUNCH
) else if "!main_choice!"=="4" (
    goto CHECK_STRUCTURE
) else if /i "!main_choice!"=="X" (
    exit /b
) else (
    goto MENU
)

:AUTO_LAUNCH
cls
if "%LANG%"=="RU" (
    echo %WHITE%Запуск русской версии...%RESET%
    echo %CYAN%Starting Russian version...%RESET%
    echo.
    if exist "%RU_MAIN%" (
        call "%RU_MAIN%"
    ) else (
        echo %RED%Русская версия не найдена!%RESET%
        echo %RED%Russian version not found!%RESET%
        pause
        goto MENU
    )
) else (
    echo %WHITE%Starting English version...%RESET%
    echo %CYAN%Запуск английской версии...%RESET%
    echo.
    if exist "%EN_MAIN%" (
        call "%EN_MAIN%"
    ) else (
        echo %RED%English version not found!%RESET%
        echo %RED%Английская версия не найдена!%RESET%
        pause
        goto MENU
    )
)

:: Return to menu after the program exits
goto MENU