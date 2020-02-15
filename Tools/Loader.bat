@echo off
title Injectiine
:Menu
cls
echo :::::::::::::::::::::::::
echo ::Welcome to Injectiine::
echo :::::::::::::::::::::::::
echo.
echo Please select a console.
echo NES  (1) 
echo SNES (2) [BROKEN DO NOT USE]
echo N64  (3) [BROKEN DO NOT USE]
echo GBA  (4) [BROKEN DO NOT USE]
echo NDS  (5) [BROKEN DO NOT USE]
echo.
set /p CHOICE=[Your Choice:] 
if %CHOICE%==1 GOTO:NES
if %CHOICE%==2 GOTO:SNES
if %CHOICE%==3 GOTO:N64
if %CHOICE%==4 GOTO:GBA
if %CHOICE%==5 GOTO:NDS
GOTO:Menu

:NES
cd CONSOLES
call NES.bat
exit

:SNES
cd CONSOLES
call SNES.bat
exit

:N64
cd CONSOLES
call N64.bat
exit

:GBA
cd CONSOLES
call GBA.bat
exit

:NDS
cd CONSOLES
call NDS.bat
exit
