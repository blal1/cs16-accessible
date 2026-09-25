@echo off
rem Sets up an x86 MSVC build environment for this project (called by the build scripts).
rem  - Visual Studio 2022/2026 (or Build Tools) with C++ and CMake is found with vswhere;
rem    set VSINSTALL to force a specific installation folder.
rem  - Windows SDK: the local NuGet copy in tools\winsdk is used when present (no admin rights
rem    needed); otherwise the SDK installed with Visual Studio is used through vcvarsall.
set "ACCESS_ROOT=%~dp0.."
for %%I in ("%ACCESS_ROOT%") do set "ACCESS_ROOT=%%~fI"

if not defined VSINSTALL (
  for /f "usebackq delims=" %%I in (`"%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 Microsoft.VisualStudio.Component.VC.CMake.Project -property installationPath`) do set "VSINSTALL=%%I"
)
if not defined VSINSTALL (
  echo Visual Studio avec "Developpement Desktop en C++" et "Outils CMake C++" est introuvable.
  exit /b 1
)
set /p VCVER=<"%VSINSTALL%\VC\Auxiliary\Build\Microsoft.VCToolsVersion.default.txt"
set "VC=%VSINSTALL%\VC\Tools\MSVC\%VCVER%"
set "CMAKEDIRS=%VSINSTALL%\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin;%VSINSTALL%\Common7\IDE\CommonExtensions\Microsoft\CMake\Ninja"

set "SDK=%ACCESS_ROOT%\tools\winsdk\c"
if exist "%SDK%\Include" (
  for /f "delims=" %%V in ('dir /b /ad "%SDK%\Include"') do set "SDKV=%%V"
  goto :local_sdk
)
rem No local SDK: let Visual Studio configure everything (requires the Windows SDK component).
call "%VSINSTALL%\VC\Auxiliary\Build\vcvarsall.bat" x86 >nul || exit /b 1
set "PATH=%CMAKEDIRS%;%PATH%"
set ACCESS_LOCAL_SDK=
exit /b 0

:local_sdk
set "INCLUDE=%VC%\include;%SDK%\Include\%SDKV%\ucrt;%SDK%\Include\%SDKV%\um;%SDK%\Include\%SDKV%\shared;%SDK%\Include\%SDKV%\winrt"
set "LIB=%VC%\lib\x86;%SDK%\ucrt\x86;%SDK%\um\x86"
set "PATH=%VC%\bin\Hostx64\x86;%VC%\bin\Hostx64\x64;%SDK%\bin\%SDKV%\x64;%CMAKEDIRS%;%PATH%"
set ACCESS_LOCAL_SDK=1
exit /b 0
