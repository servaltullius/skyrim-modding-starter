@echo off
rem Builds this SKSE plugin. Usage:
rem   build.cmd        configure + build; the DLL lands in <build root>\<folder name>\package\SKSE\Plugins
rem   build.cmd zip    same, plus a release zip (DLL + licence notices) next to the package folder
rem
rem Optional settings (set them in the same window before running):
rem   SKSE_BUILD_ROOT  where build files go. Default: %SystemDrive%\skse-build (usually C:\skse-build).
rem   VCPKG_ROOT       your vcpkg folder. Default: C:\vcpkg, then %USERPROFILE%\vcpkg. No spaces in the path.
rem   DEPLOY_DIR       an MO2 mod folder; each build also copies the DLL to DEPLOY_DIR\SKSE\Plugins.
rem                    It stays set for the rest of the window: clear it with  set DEPLOY_DIR=
rem
rem This file is ASCII only: cmd reads it in the system code page.
rem Delayed expansion stays off so that "!" in a path is kept as it is.
setlocal DisableDelayedExpansion

rem --- arguments
set "KIT_ZIP="
if "%~1"=="" goto args_ok
if /i not "%~1"=="zip" goto bad_args
if not "%~2"=="" goto bad_args
set "KIT_ZIP=1"
:args_ok

rem --- vcpkg (vcvars64 below replaces VCPKG_ROOT with Visual Studio's own copy, so remember ours first)
set "KIT_VCPKG_ROOT=%VCPKG_ROOT%"
if not defined KIT_VCPKG_ROOT if exist "C:\vcpkg\scripts\buildsystems\vcpkg.cmake" set "KIT_VCPKG_ROOT=C:\vcpkg"
if not defined KIT_VCPKG_ROOT if exist "%USERPROFILE%\vcpkg\scripts\buildsystems\vcpkg.cmake" set "KIT_VCPKG_ROOT=%USERPROFILE%\vcpkg"
if not defined KIT_VCPKG_ROOT goto no_vcpkg
if not exist "%KIT_VCPKG_ROOT%\scripts\buildsystems\vcpkg.cmake" goto bad_vcpkg
rem The compiler flags in cmake\triplets carry the vcpkg path; a space in it splits the flag.
if not "%KIT_VCPKG_ROOT: =%"=="%KIT_VCPKG_ROOT%" goto vcpkg_space

if not defined SKSE_BUILD_ROOT set "SKSE_BUILD_ROOT=%SystemDrive%\skse-build"

rem A trailing backslash would escape the closing quote of "-DDEPLOY_DIR=..." below.
rem The trim runs in a subroutine: %DEPLOY_DIR:~-1% written on a line here breaks parsing when DEPLOY_DIR is unset.
if defined DEPLOY_DIR call :trim_deploy_dir

rem --- Visual Studio: prefer 2022 (v143), the toolset this template was tested with; otherwise a newer one
set "VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
if not exist "%VSWHERE%" goto no_vs
rem A name of its own per run, so two builds at the same time do not read each other's file
set "KIT_VSDIR_FILE=%TEMP%\skse-template-vsdir-%RANDOM%%RANDOM%.txt"
set "KIT_VSDIR="
"%VSWHERE%" -version "[17.0,18.0)" -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -latest -property installationPath > "%KIT_VSDIR_FILE%"
set /p KIT_VSDIR=<"%KIT_VSDIR_FILE%"
if not defined KIT_VSDIR "%VSWHERE%" -version 17.0 -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -latest -property installationPath > "%KIT_VSDIR_FILE%"
if not defined KIT_VSDIR set /p KIT_VSDIR=<"%KIT_VSDIR_FILE%"
del "%KIT_VSDIR_FILE%" >nul 2>&1
if not defined KIT_VSDIR goto no_vs

call "%KIT_VSDIR%\VC\Auxiliary\Build\vcvars64.bat" >nul
if errorlevel 1 goto vcvars_failed
set "VCPKG_ROOT=%KIT_VCPKG_ROOT%"
rem vcpkg must build the dependencies with the same Visual Studio as this build (path without a trailing backslash)
set "VCPKG_VISUAL_STUDIO_PATH=%KIT_VSDIR%"

echo Visual Studio : "%KIT_VSDIR%" (MSVC %VCToolsVersion%)
echo vcpkg         : "%VCPKG_ROOT%"
echo Build root    : "%SKSE_BUILD_ROOT%"
if defined DEPLOY_DIR echo Deploy to     : "%DEPLOY_DIR%"

cd /d "%~dp0" || goto cd_failed
cmake --preset release "-DDEPLOY_DIR=%DEPLOY_DIR%"
if errorlevel 1 goto configure_failed
cmake --build --preset release
if errorlevel 1 goto build_failed
if defined KIT_ZIP cmake --build --preset release --target release_zip
if errorlevel 1 goto zip_failed

for %%I in ("%~dp0.") do set "KIT_NAME=%%~nxI"
echo.
echo BUILD OK
echo DLL: "%SKSE_BUILD_ROOT%\%KIT_NAME%\package\SKSE\Plugins"
if defined KIT_ZIP echo Zip: "%SKSE_BUILD_ROOT%\%KIT_NAME%"
exit /b 0

:trim_deploy_dir
if not "%DEPLOY_DIR:~-1%"=="\" exit /b 0
set "DEPLOY_DIR=%DEPLOY_DIR:~0,-1%"
if defined DEPLOY_DIR goto trim_deploy_dir
exit /b 0

:bad_args
echo Usage: build.cmd [zip]
echo [FAILED] Unknown argument. Only "zip" is accepted.
exit /b 2

:no_vcpkg
echo [FAILED] vcpkg was not found in C:\vcpkg or "%USERPROFILE%\vcpkg". See 05-SKSE.md, step 1.
exit /b 1

:bad_vcpkg
echo [FAILED] VCPKG_ROOT is "%KIT_VCPKG_ROOT%", but that is not a vcpkg folder.
exit /b 1

:vcpkg_space
echo [FAILED] The vcpkg folder "%KIT_VCPKG_ROOT%" has a space in its path. Install vcpkg to C:\vcpkg (05-SKSE.md, step 1).
exit /b 1

:no_vs
echo [FAILED] No Visual Studio 2022 or newer with the C++ tools was found. Install Visual Studio 2022 with "Desktop development with C++".
exit /b 1

:vcvars_failed
echo [FAILED] Could not set up the C++ tools from "%KIT_VSDIR%".
exit /b 1

:cd_failed
echo [FAILED] Could not change to the template folder "%~dp0".
exit /b 1

:configure_failed
echo [FAILED] CMake configure step. The first error above is the one to read.
exit /b 1

:build_failed
echo [FAILED] Build step. The first "error" line above is the one to read.
exit /b 1

:zip_failed
echo [FAILED] Release zip step.
exit /b 1
