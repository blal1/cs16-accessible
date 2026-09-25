@echo off
rem Builds the accessible Xash3D FWGS engine, Release x86, and installs it into repos\xash3d-fwgs\out.
rem First time (or after changing tools): build_xash.bat configure
call "%~dp0..\msvc_x86_env.bat" || exit /b 1
if defined ACCESS_LOCAL_SDK (
  rem waf detects MSVC through vcvars, which cannot see the local SDK: pass it explicitly.
  set CFLAGS=/I"%SDK%\Include\%SDKV%\ucrt" /I"%SDK%\Include\%SDKV%\um" /I"%SDK%\Include\%SDKV%\shared"
  set LINKFLAGS=/LIBPATH:"%SDK%\ucrt\x86" /LIBPATH:"%SDK%\um\x86"
)
set "CXXFLAGS=%CFLAGS%"
cd /d "%ACCESS_ROOT%\repos\xash3d-fwgs" || exit /b 1
if "%1"=="configure" (
  py waf configure -s "%ACCESS_ROOT%\tools\SDL2-2.32.10" -T release || exit /b 1
)
py waf build || exit /b 1
py waf install --destdir=out || exit /b 1
