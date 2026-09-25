@echo off
rem Builds the procedural audio cue test (plays every cue, exports WAV files).
call "%~dp0..\msvc_x86_env.bat" || exit /b 1
set "SRC=%ACCESS_ROOT%\repos\cs16-client\cl_dll\accessibility"
cd /d "%~dp0"
cl.exe /nologo /EHsc /O2 /W3 /D_CRT_SECURE_NO_WARNINGS /I"%SRC%" test_access_audio.cpp /Fe:test_access_audio.exe
