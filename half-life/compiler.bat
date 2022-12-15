@REM ask a name as loop and run spcomp.exe with this name as parameter

@echo off
setlocal

:loop
set /p name=Name: amiral_
if %name%=="" goto :end
start /b /w .\spcomp.exe .\amiral_%name%.sp -o ../plugins/amiral_%name%.smx
goto :loop
:end
 