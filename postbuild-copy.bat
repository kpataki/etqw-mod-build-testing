@echo off
setlocal

echo Running postbuild-copy.bat

REM Check if ETQW_SDK_DIR is defined
if not defined ETQW_SDK_DIR (
    echo [ERROR] ETQW_SDK_DIR environment variable is not set.
    exit /b 1
)

REM Check if ETQW_SDK_DIR folder exists
if not exist "%ETQW_SDK_DIR%\" (
    echo [ERROR] ETQW_SDK_DIR folder does not exist: %ETQW_SDK_DIR%
    exit /b 1
)

REM Rename existing DLL if it exists
if not exist "%ETQW_SDK_DIR%\gamex86.dll.orig" if exist "%ETQW_SDK_DIR%\gamex86.dll" (
    ren "%ETQW_SDK_DIR%\gamex86.dll" "gamex86.dll.orig"
)

REM Create mod folder if it doesn't exist
if not exist "%ETQW_SDK_DIR%" (
    echo [ERROR] ETQW_SDK_DIR folder does not exist: %ETQW_SDK_DIR%
    exit /b 1
)

echo Copying to SDK folder

REM Copy DLL
copy /Y "%~1" "%ETQW_SDK_DIR%\gamex86.dll"
if errorlevel 1 exit /b 1

REM Copy PDB
copy /Y "%~2" "%ETQW_SDK_DIR%\gamex86.pdb"
if errorlevel 1 exit /b 1

echo Copy complete.
endlocal
