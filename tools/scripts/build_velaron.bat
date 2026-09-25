@echo off
rem Builds the accessible CS client (client.dll), menus (menu.dll) and server (mp.dll), Release x86,
rem into repos\cs16-client\build-x86.
call "%~dp0..\msvc_x86_env.bat" || exit /b 1
cd /d "%ACCESS_ROOT%\repos\cs16-client" || exit /b 1
set "SDKOPT="
if defined ACCESS_LOCAL_SDK set "SDKOPT=-DCMAKE_SYSTEM_VERSION=%SDKV%"
cmake -S . -B build-x86 -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_COMPILER=cl -DCMAKE_CXX_COMPILER=cl %SDKOPT% >nul || exit /b 1
cmake --build build-x86 || exit /b 1
