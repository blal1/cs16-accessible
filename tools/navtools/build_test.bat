@echo off
rem Builds the standalone map/path test (all stock maps, spawn to objective paths).
call "%~dp0..\msvc_x86_env.bat" || exit /b 1
set "SRC=%ACCESS_ROOT%\repos\cs16-client\cl_dll\accessibility"
cd /d "%~dp0"
cl.exe /nologo /EHsc /O2 /W4 /DACCESS_MAP_STANDALONE /D_CRT_SECURE_NO_WARNINGS /utf-8 /I"%SRC%" test_access_map.cpp "%SRC%\access_map.cpp" /Fe:test_access_map.exe
