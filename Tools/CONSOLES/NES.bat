@echo off
title Injectiine [NES]
cls
cd ..
cd ..
cd Files

echo ::::::::::::::::::::
echo ::INJECTIINE [NES]::
echo ::::::::::::::::::::
SLEEP 3

IF NOT EXIST *.nes GOTO:404ROMnotFound
IF NOT EXIST bootTvTex.png GOTO:404ImagesNotFound
IF NOT EXIST iconTex.png GOTO:404ImagesNotFound

cd ..
cd Tools

:::::BASES:::::
:BASE
cls
echo Which base do you want to use?
echo Punch-Out!! [EUR]        (1)
echo Duck Hunt [EUR]          (2)
echo Base supplied from Files (3)
echo.
set /p BASEDECIDE=[Your Choice:] 
IF %BASEDECIDE%==1 GOTO:PO
IF %BASEDECIDE%==2 GOTO:DH
IF %BASEDECIDE%==3 GOTO:BaseNotice
GOTO:BASE

:PO
set BASEID=0005000010108c00
set BASEPDC=FAKP
set BASEFOLDER="Punch-Out!! [FAKP01]"
GOTO:EnterKeyPO

:DH
cls
echo Duck Hunt (EUR):
echo This base supports emulation of the NES Zapper via the Wii Remote.
SLEEP 3
cls
set BASEID=0005000010192600
set BASEPDC=FEHP
set BASEFOLDER="Duck Hunt [FEHP01]"
goto:EnterKeyDH


:BaseNotice
cls
echo Please supply your base, including the code, content and meta
echo folders, in a directory called "Base" within the Files directory.
echo.
echo Press any key to continue.
pause>NUL
cd ..
cd Files
IF NOT EXIST Base GOTO:BASEFAIL
cd ..
cd Tools
GOTO:EnterCommon
:::::END BASES:::::


:::::KEYS:::::
:EnterKeyPO
cls
IF EXIST Keys/TK/TitleKeyPO goto:ReadKeyPO
echo This step will not be required the next time you start Injectiine.
echo Enter the title key for Punch-Out!! (EUR):
set /p TITLEKEY=Enter TitleKey: 
echo %TITLEKEY:~0,32%>Keys/TK/TitleKeyPO
:ReadKeyPO
set /p TITLEKEY=<Keys/TK/TitleKeyPO
IF "%TitleKEY:~0,4%"=="ef15" GOTO:EnterCommon ELSE GOTO:WrongKeyPO

:EnterKeyDH
cls
IF EXIST Keys/TK/TitleKeyDH goto:ReadKeyDH
echo This step will not be required the next time you start Injectiine.
echo Enter the title key for Duck Hunt (EUR):
set /p TITLEKEY=Enter TitleKey: 
echo %TITLEKEY:~0,32%>Keys/TK/TitleKeyDH
:ReadKeyDH
set /p TITLEKEY=<Keys/TK/TitleKeyDH
cls
IF "%TitleKEY:~0,4%"=="f72a" GOTO:EnterCommon ELSE GOTO:WrongKeyDH

:EnterCommon
IF EXIST Keys/commonKey goto:ReadCKey
echo This step will not be required the next time you start Injectiine.
set /p COMMON=Enter the Wii U Common Key: 
set /p %COMMON:~0,32%>Keys/commonKey
:ReadCKey
set /p COMMON=<Keys/commonKey
IF "%COMMON:~0,4%"=="D7B0" GOTO:EnterParameters ELSE GOTO:WrongCommon

:::ERRORS:::
:WrongKeyPO
cls
echo Title key is incorrect. Please try again.
SLEEP 2
goto:EnterKeyPO

:WrongKeyDH
cls
echo Title key is incorrect. Please try again.
SLEEP 2
goto:EnterKeyDH

:WrongCommon
cls
echo Wii U Common Key is incorrect. Please try again.
SLEEP 2
goto:EnterCommon
:::END ERRORS:::
:::::END KEYS:::::


:::::PARAMETERS:::::
:EnterParameters
cls

set TITLEID=%random:~-1%%random:~-1%%random:~-1%%random:~-1%


GOTO:LINE1

:LINE1
echo Enter the name of the game.
set /p GAMENAME=[Game Name:] 
echo.
GOTO:RestOfParameters


:RestOfParameters
echo Enter a 4-digit product code.
set /p PRODUCTCODE=[0-Z:] 
echo.

echo Do you want to enter a title ID manually?
echo If you don't, one will be randomly assigned.
set /p TITLEDECIDE=[Y/N:] 
echo.
IF /i "%TITLEDECIDE%"=="y" (
echo Enter a 4-digit meta title ID. Must only be hex values.
set /p TITLEID=[0-F:] 
)
goto:ConfirmParemeters

:ConfirmParemeters
cls
echo Injectiine will now create an NES injection.
echo If you don't accept this, you will need to reenter your parameters.
CHOICE /C YN
IF errorlevel 2 goto :EnterParameters
IF errorlevel 1 goto :DownloadingStuff
:::::END PARAMETERS:::::

:::::DOWNLOADING:::::
:DownloadingStuff
cls
IF %BASEDECIDE%==3 GOTO:EnterBaseCode
echo Testing Internet connection...
C:\windows\system32\PING.EXE google.com
if %errorlevel% GTR 0 goto:InternetSucks

IF EXIST WORKDIR echo Cleaning up working directory from last failed conversion...
IF EXIST WORKDIR rd /s /q WORKDIR
SLEEP 1
cls
echo Downloading encrypted Base Files...
mkdir WORKDIR
cd WORKDIR
call "../Tools/_General/Download/WiiUDownloader.exe" %BASEID% %TITLEKEY:~0,32% ENC
goto:decryptFiles

:decryptFiles
cd ..
cd Tools
cd _General
cd Download
call CDecrypt.exe %COMMON% ..\..\..\WORKDIR\ENC ..\..\..\WORKDIR\
rmdir /s /q ..\..\..\WORKDIR\ENC
goto:InjectRom

:EnterBaseCode
cls
echo Please enter the 4-digit product code of your base.
echo You can find it in either the meta.xml or cos.xml files.
echo EXAMPLES: FAKP, FAAE, FAEJ
set /p BASEPDC=[Base Product Code:] 
goto:CopyBase

:CopyBase
cls
echo Moving base to work directory...
C:\Windows\System32\Robocopy.exe ..\..\..\..\Files\Base ..\..\..\WORKDIR\ /MIR
IF NOT EXIST WORKDIR GOTO:ROBOFAIL
rmdir /s /q ..\..\..\..\Files\Base
cls
goto:InjectRom
:::::END DOWNLOADING:::::


:::::Injecting Game:::::
:InjectRom
cls
echo Injecting ROM...
cd ..
cd ..
cd ..
cd ..
cd Files
::Checking Images
IF EXIST ..\Tools\Tools\_General\Images\Input (rmdir /s /q ..\Tools\Tools\_General\Images\Input)
mkdir ..\Tools\Tools\_General\Images\Input
IF EXIST iconTex.png (move iconTex.png ..\Tools\Tools\_General\Images\Input)
IF NOT EXIST bootDrcTex.png (copy bootTvTex.png bootDrcTex.png)
IF EXIST bootTvTex.png (move bootTvTex.png ..\Tools\Tools\_General\Images\Input)
IF EXIST bootDrcTex.png (move bootDrcTex.png ..\Tools\Tools\_General\Images\Input)
IF EXIST bootLogoTex.png (move bootLogoTex.png ..\Tools\Tools\_General\Images\Input)
ren *.nes ROM.nes

move ROM.nes "../Tools/Tools/SNES_NES/Injecting/ROM.nes"
cd ..
cd Tools
cd WORKDIR
Cd code
move WUP-%BASEPDC%.rpx "../../Tools/SNES_NES/Injecting/WUP-%BASEPDC%.rpx"
cd ..
cd ..
cd Tools
cd SNES_NES
cd Injecting
call wiiurpxtool -d "WUP-%BASEPDC%.rpx"
call RetroInject.exe "WUP-%BASEPDC%.rpx" "ROM.nes" "WUP-%BASEPDC%_new.rpx"
 IF NOT EXIST WUP-%BASEPDC%_new.rpx GOTO:InjectError
del /f /q WUP-%BASEPDC%.rpx
ren WUP-%BASEPDC%_new.rpx WUP-%BASEPDC%.rpx
wiiurpxtool -c "WUP-%BASEPDC%.rpx"
del /f /q ROM.nes
move WUP-%BASEPDC%.rpx "../../../WORKDIR/code"
IF NOT EXIST "..\..\..\WORKDIR\code\WUP-%BASEPDC%.rpx" GOTO:InjectError
cls
goto:EditXMLs
:::::END Injecting Game:::::


:::::Editing XMLs:::::
:EditXMLs
cd ..
cd ..
cd ..
echo Generating app.xml...
cd WORKDIR
cd code
del /s app.xml >nul 2>&1
echo ^<?xml version="1.0" encoding="utf-8"?^>>app.xml
echo ^<app type="complex" access="777"^>>>app.xml
echo   ^<version type="unsignedInt" length="4"^>14^</version^>>>app.xml
echo   ^<os_version type="hexBinary" length="8"^>000500101000400A^</os_version^>>>app.xml
echo   ^<title_id type="hexBinary" length="8"^>000500001337%TITLEID%^</title_id^>>>app.xml
echo   ^<title_version type="hexBinary" length="2"^>0000^</title_version^>>>app.xml
echo   ^<sdk_version type="unsignedInt" length="4"^>20811^</sdk_version^>>>app.xml
echo   ^<app_type type="hexBinary" length="4"^>80000000^</app_type^>>>app.xml
echo   ^<group_id type="hexBinary" length="4"^>00001337^</group_id^>>>app.xml
echo ^</app^>>>app.xml
SLEEP 1
cls

echo Generating meta.xml...
cd ..
cd meta
echo ^<?xml version="1.0" encoding="utf-8"?^>>meta.xml
echo ^<menu type="complex" access="777"^>>>meta.xml
echo   ^<version type="unsignedInt" length="4"^>33^</version^>>>meta.xml
echo   ^<product_code type="string" length="32"^>WUP-N-%PRODUCTCODE%^</product_code^>>>meta.xml
echo   ^<content_platform type="string" length="32"^>WUP^</content_platform^>>>meta.xml
echo   ^<company_code type="string" length="8"^>0001^</company_code^>>>meta.xml
echo   ^<mastering_date type="string" length="32"^>^</mastering_date^>>>meta.xml
echo   ^<logo_type type="unsignedInt" length="4"^>0^</logo_type^>>>meta.xml
echo   ^<app_launch_type type="hexBinary" length="4"^>00000000^</app_launch_type^>>>meta.xml
echo   ^<invisible_flag type="hexBinary" length="4"^>00000000^</invisible_flag^>>>meta.xml
echo   ^<no_managed_flag type="hexBinary" length="4"^>00000000^</no_managed_flag^>>>meta.xml
echo   ^<no_event_log type="hexBinary" length="4"^>00000000^</no_event_log^>>>meta.xml
echo   ^<no_icon_database type="hexBinary" length="4"^>00000000^</no_icon_database^>>>meta.xml
echo   ^<launching_flag type="hexBinary" length="4"^>00000004^</launching_flag^>>>meta.xml
echo   ^<install_flag type="hexBinary" length="4"^>00000000^</install_flag^>>>meta.xml
echo   ^<closing_msg type="unsignedInt" length="4"^>0^</closing_msg^>>>meta.xml
echo   ^<title_version type="unsignedInt" length="4"^>0^</title_version^>>>meta.xml
echo   ^<title_id type="hexBinary" length="8"^>000500001337%TITLEID%^</title_id^>>>meta.xml
echo   ^<group_id type="hexBinary" length="4"^>00001337^</group_id^>>>meta.xml
echo   ^<boss_id type="hexBinary" length="8"^>0000000000000000^</boss_id^>>>meta.xml
echo   ^<os_version type="hexBinary" length="8"^>000500101000400A^</os_version^>>>meta.xml
echo   ^<app_size type="hexBinary" length="8"^>0000000000000000^</app_size^>>>meta.xml
echo   ^<common_save_size type="hexBinary" length="8"^>0000000000000000^</common_save_size^>>>meta.xml
echo   ^<account_save_size type="hexBinary" length="8"^>0000000000200000^</account_save_size^>>>meta.xml
echo   ^<common_boss_size type="hexBinary" length="8"^>0000000000000000^</common_boss_size^>>>meta.xml
echo   ^<account_boss_size type="hexBinary" length="8"^>0000000000000000^</account_boss_size^>>>meta.xml
echo   ^<save_no_rollback type="unsignedInt" length="4"^>0^</save_no_rollback^>>>meta.xml
echo   ^<join_game_id type="hexBinary" length="4"^>00000000^</join_game_id^>>>meta.xml
echo   ^<join_game_mode_mask type="hexBinary" length="8"^>0000000000000000^</join_game_mode_mask^>>>meta.xml
echo   ^<bg_daemon_enable type="unsignedInt" length="4"^>1^</bg_daemon_enable^>>>meta.xml
echo   ^<olv_accesskey type="unsignedInt" length="4"^>3640111597^</olv_accesskey^>>>meta.xml
echo   ^<wood_tin type="unsignedInt" length="4"^>0^</wood_tin^>>>meta.xml
echo   ^<e_manual type="unsignedInt" length="4"^>0^</e_manual^>>>meta.xml
echo   ^<e_manual_version type="unsignedInt" length="4"^>0^</e_manual_version^>>>meta.xml
echo   ^<region type="hexBinary" length="4"^>00000004^</region^>>>meta.xml
echo   ^<pc_cero type="unsignedInt" length="4"^>128^</pc_cero^>>>meta.xml
echo   ^<pc_esrb type="unsignedInt" length="4"^>128^</pc_esrb^>>>meta.xml
echo   ^<pc_bbfc type="unsignedInt" length="4"^>192^</pc_bbfc^>>>meta.xml
echo   ^<pc_usk type="unsignedInt" length="4"^>6^</pc_usk^>>>meta.xml
echo   ^<pc_pegi_gen type="unsignedInt" length="4"^>7^</pc_pegi_gen^>>>meta.xml
echo   ^<pc_pegi_fin type="unsignedInt" length="4"^>192^</pc_pegi_fin^>>>meta.xml
echo   ^<pc_pegi_prt type="unsignedInt" length="4"^>6^</pc_pegi_prt^>>>meta.xml
echo   ^<pc_pegi_bbfc type="unsignedInt" length="4"^>7^</pc_pegi_bbfc^>>>meta.xml
echo   ^<pc_cob type="unsignedInt" length="4"^>0^</pc_cob^>>>meta.xml
echo   ^<pc_grb type="unsignedInt" length="4"^>128^</pc_grb^>>>meta.xml
echo   ^<pc_cgsrr type="unsignedInt" length="4"^>128^</pc_cgsrr^>>>meta.xml
echo   ^<pc_oflc type="unsignedInt" length="4"^>0^</pc_oflc^>>>meta.xml
echo   ^<pc_reserved0 type="unsignedInt" length="4"^>192^</pc_reserved0^>>>meta.xml
echo   ^<pc_reserved1 type="unsignedInt" length="4"^>192^</pc_reserved1^>>>meta.xml
echo   ^<pc_reserved2 type="unsignedInt" length="4"^>192^</pc_reserved2^>>>meta.xml
echo   ^<pc_reserved3 type="unsignedInt" length="4"^>192^</pc_reserved3^>>>meta.xml
echo   ^<ext_dev_nunchaku type="unsignedInt" length="4"^>1^</ext_dev_nunchaku^>>>meta.xml
echo   ^<ext_dev_classic type="unsignedInt" length="4"^>1^</ext_dev_classic^>>>meta.xml
echo   ^<ext_dev_urcc type="unsignedInt" length="4"^>1^</ext_dev_urcc^>>>meta.xml
echo   ^<ext_dev_board type="unsignedInt" length="4"^>0^</ext_dev_board^>>>meta.xml
echo   ^<ext_dev_usb_keyboard type="unsignedInt" length="4"^>0^</ext_dev_usb_keyboard^>>>meta.xml
echo   ^<ext_dev_etc type="unsignedInt" length="4"^>0^</ext_dev_etc^>>>meta.xml
echo   ^<ext_dev_etc_name type="string" length="512"^>^</ext_dev_etc_name^>>>meta.xml
echo   ^<eula_version type="unsignedInt" length="4"^>0^</eula_version^>>>meta.xml
echo   ^<drc_use type="unsignedInt" length="4"^>1^</drc_use^>>>meta.xml
echo   ^<network_use type="unsignedInt" length="4"^>0^</network_use^>>>meta.xml
echo   ^<online_account_use type="unsignedInt" length="4"^>0^</online_account_use^>>>meta.xml
echo   ^<direct_boot type="unsignedInt" length="4"^>0^</direct_boot^>>>meta.xml
echo   ^<reserved_flag0 type="hexBinary" length="4"^>00020002^</reserved_flag0^>>>meta.xml
echo   ^<reserved_flag1 type="hexBinary" length="4"^>00000000^</reserved_flag1^>>>meta.xml
echo   ^<reserved_flag2 type="hexBinary" length="4"^>00000000^</reserved_flag2^>>>meta.xml
echo   ^<reserved_flag3 type="hexBinary" length="4"^>00000000^</reserved_flag3^>>>meta.xml
echo   ^<reserved_flag4 type="hexBinary" length="4"^>00000000^</reserved_flag4^>>>meta.xml
echo   ^<reserved_flag5 type="hexBinary" length="4"^>00000000^</reserved_flag5^>>>meta.xml
echo   ^<reserved_flag6 type="hexBinary" length="4"^>00000000^</reserved_flag6^>>>meta.xml
echo   ^<reserved_flag7 type="hexBinary" length="4"^>00000000^</reserved_flag7^>>>meta.xml
echo   ^<longname_ja type="string" length="512"^>%GAMENAME%^</longname_ja^>>>meta.xml
echo   ^<longname_en type="string" length="512"^>%GAMENAME%^</longname_en^>>>meta.xml
echo   ^<longname_fr type="string" length="512"^>%GAMENAME%^</longname_fr^>>>meta.xml
echo   ^<longname_de type="string" length="512"^>%GAMENAME%^</longname_de^>>>meta.xml
echo   ^<longname_it type="string" length="512"^>%GAMENAME%^</longname_it^>>>meta.xml
echo   ^<longname_es type="string" length="512"^>%GAMENAME%^</longname_es^>>>meta.xml
echo   ^<longname_zhs type="string" length="512"^>%GAMENAME%^</longname_zhs^>>>meta.xml
echo   ^<longname_ko type="string" length="512"^>%GAMENAME%^</longname_ko^>>>meta.xml
echo   ^<longname_nl type="string" length="512"^>%GAMENAME%^</longname_nl^>>>meta.xml
echo   ^<longname_pt type="string" length="512"^>%GAMENAME%^</longname_pt^>>>meta.xml
echo   ^<longname_ru type="string" length="512"^>%GAMENAME%^</longname_ru^>>>meta.xml
echo   ^<longname_zht type="string" length="512"^>%GAMENAME%^</longname_zht^>>>meta.xml
echo   ^<shortname_ja type="string" length="256"^>%GAMENAME%^</shortname_ja^>>>meta.xml
echo   ^<shortname_en type="string" length="256"^>%GAMENAME%^</shortname_en^>>>meta.xml
echo   ^<shortname_fr type="string" length="256"^>%GAMENAME%^</shortname_fr^>>>meta.xml
echo   ^<shortname_de type="string" length="256"^>%GAMENAME%^</shortname_de^>>>meta.xml
echo   ^<shortname_it type="string" length="256"^>%GAMENAME%^</shortname_it^>>>meta.xml
echo   ^<shortname_es type="string" length="256"^>%GAMENAME%^</shortname_es^>>>meta.xml
echo   ^<shortname_zhs type="string" length="256"^>%GAMENAME%^</shortname_zhs^>>>meta.xml
echo   ^<shortname_ko type="string" length="256"^>%GAMENAME%^</shortname_ko^>>>meta.xml
echo   ^<shortname_nl type="string" length="256"^>%GAMENAME%^</shortname_nl^>>>meta.xml
echo   ^<shortname_pt type="string" length="256"^>%GAMENAME%^</shortname_pt^>>>meta.xml
echo   ^<shortname_ru type="string" length="256"^>%GAMENAME%^</shortname_ru^>>>meta.xml
echo   ^<shortname_zht type="string" length="256"^>%GAMENAME%^</shortname_zht^>>>meta.xml
echo   ^<publisher_ja type="string" length="256"^>Nintendo^</publisher_ja^>>>meta.xml
echo   ^<publisher_en type="string" length="256"^>Nintendo^</publisher_en^>>>meta.xml
echo   ^<publisher_fr type="string" length="256"^>Nintendo^</publisher_fr^>>>meta.xml
echo   ^<publisher_de type="string" length="256"^>Nintendo^</publisher_de^>>>meta.xml
echo   ^<publisher_it type="string" length="256"^>Nintendo^</publisher_it^>>>meta.xml
echo   ^<publisher_es type="string" length="256"^>Nintendo^</publisher_es^>>>meta.xml
echo   ^<publisher_zhs type="string" length="256"^>Nintendo^</publisher_zhs^>>>meta.xml
echo   ^<publisher_ko type="string" length="256"^>Nintendo^</publisher_ko^>>>meta.xml
echo   ^<publisher_nl type="string" length="256"^>Nintendo^</publisher_nl^>>>meta.xml
echo   ^<publisher_pt type="string" length="256"^>Nintendo^</publisher_pt^>>>meta.xml
echo   ^<publisher_ru type="string" length="256"^>Nintendo^</publisher_ru^>>>meta.xml
echo   ^<publisher_zht type="string" length="256"^>Nintendo^</publisher_zht^>>>meta.xml
echo   ^<add_on_unique_id0 type="hexBinary" length="4"^>00000000^</add_on_unique_id0^>>>meta.xml
echo   ^<add_on_unique_id1 type="hexBinary" length="4"^>00000000^</add_on_unique_id1^>>>meta.xml
echo   ^<add_on_unique_id2 type="hexBinary" length="4"^>00000000^</add_on_unique_id2^>>>meta.xml
echo   ^<add_on_unique_id3 type="hexBinary" length="4"^>00000000^</add_on_unique_id3^>>>meta.xml
echo   ^<add_on_unique_id4 type="hexBinary" length="4"^>00000000^</add_on_unique_id4^>>>meta.xml
echo   ^<add_on_unique_id5 type="hexBinary" length="4"^>00000000^</add_on_unique_id5^>>>meta.xml
echo   ^<add_on_unique_id6 type="hexBinary" length="4"^>00000000^</add_on_unique_id6^>>>meta.xml
echo   ^<add_on_unique_id7 type="hexBinary" length="4"^>00000000^</add_on_unique_id7^>>>meta.xml
echo   ^<add_on_unique_id8 type="hexBinary" length="4"^>00000000^</add_on_unique_id8^>>>meta.xml
echo   ^<add_on_unique_id9 type="hexBinary" length="4"^>00000000^</add_on_unique_id9^>>>meta.xml
echo   ^<add_on_unique_id10 type="hexBinary" length="4"^>00000000^</add_on_unique_id10^>>>meta.xml
echo   ^<add_on_unique_id11 type="hexBinary" length="4"^>00000000^</add_on_unique_id11^>>>meta.xml
echo   ^<add_on_unique_id12 type="hexBinary" length="4"^>00000000^</add_on_unique_id12^>>>meta.xml
echo   ^<add_on_unique_id13 type="hexBinary" length="4"^>00000000^</add_on_unique_id13^>>>meta.xml
echo   ^<add_on_unique_id14 type="hexBinary" length="4"^>00000000^</add_on_unique_id14^>>>meta.xml
echo   ^<add_on_unique_id15 type="hexBinary" length="4"^>00000000^</add_on_unique_id15^>>>meta.xml
echo   ^<add_on_unique_id16 type="hexBinary" length="4"^>00000000^</add_on_unique_id16^>>>meta.xml
echo   ^<add_on_unique_id17 type="hexBinary" length="4"^>00000000^</add_on_unique_id17^>>>meta.xml
echo   ^<add_on_unique_id18 type="hexBinary" length="4"^>00000000^</add_on_unique_id18^>>>meta.xml
echo   ^<add_on_unique_id19 type="hexBinary" length="4"^>00000000^</add_on_unique_id19^>>>meta.xml
echo   ^<add_on_unique_id20 type="hexBinary" length="4"^>00000000^</add_on_unique_id20^>>>meta.xml
echo   ^<add_on_unique_id21 type="hexBinary" length="4"^>00000000^</add_on_unique_id21^>>>meta.xml
echo   ^<add_on_unique_id22 type="hexBinary" length="4"^>00000000^</add_on_unique_id22^>>>meta.xml
echo   ^<add_on_unique_id23 type="hexBinary" length="4"^>00000000^</add_on_unique_id23^>>>meta.xml
echo   ^<add_on_unique_id24 type="hexBinary" length="4"^>00000000^</add_on_unique_id24^>>>meta.xml
echo   ^<add_on_unique_id25 type="hexBinary" length="4"^>00000000^</add_on_unique_id25^>>>meta.xml
echo   ^<add_on_unique_id26 type="hexBinary" length="4"^>00000000^</add_on_unique_id26^>>>meta.xml
echo   ^<add_on_unique_id27 type="hexBinary" length="4"^>00000000^</add_on_unique_id27^>>>meta.xml
echo   ^<add_on_unique_id28 type="hexBinary" length="4"^>00000000^</add_on_unique_id28^>>>meta.xml
echo   ^<add_on_unique_id29 type="hexBinary" length="4"^>00000000^</add_on_unique_id29^>>>meta.xml
echo   ^<add_on_unique_id30 type="hexBinary" length="4"^>00000000^</add_on_unique_id30^>>>meta.xml
echo   ^<add_on_unique_id31 type="hexBinary" length="4"^>00000000^</add_on_unique_id31^>>>meta.xml
echo ^</menu^>>>meta.xml
SLEEP 1
cls
goto:InjectImages
:::::END Editing XMLs:::::


:::::Injecting Images:::::
:InjectImages
cd ..
cd ..
cd Tools
cd _General
cd Images
echo Converting images to TGA....
IF EXIST Output ( rmdir /s /q Output)
mkdir Output
cd Input
call "../png2tga.exe" iconTex.png "../Output/iconTex.tga"

call "../png2tga.exe" bootTvTex.png "../Output/bootTvTex.tga"

call "../png2tga.exe" bootDrcTex.png "../Output/bootDrcTex.tga"

IF EXIST bootLogoTex.png (call "../png2tga.exe" bootLogoTex.png "../Output/bootLogoTex.tga")
cd ..
rmdir /s /q Input
goto:VerifyImages

:VerifyImages
call tga_verify.exe "Output" ^| find /i "Error"

if not errorlevel 1 (
    goto:FixImages
)
goto:MoveImages

:FixImages
call tga_verify.exe --fixup "Output"

goto:MoveImages

:MoveImages
cd Output
IF EXIST iconTex.tga (move iconTex.tga "../../../../WORKDIR/meta/iconTex.tga")

IF EXIST bootDrcTex.tga (move bootDrcTex.tga "../../../../WORKDIR/meta/bootDrcTex.tga")

IF EXIST bootTvTex.tga (move bootTvTex.tga "../../../../WORKDIR/meta/bootTvTex.tga")

IF EXIST bootLogoTex.tga (move bootLogoTex.tga "../../../../WORKDIR/meta/bootLogoTex.tga")
cd ..
rmdir /s /q Output

:::::END Injecting Images:::::


:::::Packing:::::
:PackPrompt
cls
echo Do you want to pack the game using CNUSPacker?
echo If you don't wish to, the game will be created in Loadiine format.
set /p PACKDECIDE=[Y/N:] 
IF /i "%PACKDECIDE%"=="n" (GOTO:LoadiinePack)
IF /i "%PACKDECIDE%"=="y" (GOTO:PackGame)
GOTO:PackPrompt

:LoadiinePack
cls
cd ../../../
move WORKDIR "..\Output\[NES] %GAMENAME% [%PRODUCTCODE%]"
GOTO:FinalCheckLoadiine

:PackGame
echo Packing game...
cd ../../../
move WORKDIR "Tools/_General/Packing/WORKDIR"
cd Tools
cd _General
cd Packing
call CNUSPACKER -in WORKDIR -out "[NES] %GAMENAME% (000500001337%TITLEID%)" -encryptKeyWith %COMMON%
rd /s /q tmp
rd /s /q WORKDIR
rd /s /q output
move "[NES] %GAMENAME% (000500001337%TITLEID%)" "../../../../Output"
goto:FinalCheck
:::::END Packing:::::


:::::Inject Checking:::::
:FinalCheck
cd ..\..\..\..\Output
IF NOT EXIST "[NES] %GAMENAME% (000500001337%TITLEID%)" GOTO:GameError
GOTO:GameComplete
:FinalCheckLoadiine

cd ..\Output
IF NOT EXIST "[NES] %GAMENAME% [%PRODUCTCODE%]" GOTO:LoadiineError
GOTO:GameComplete
:::::End Inject Checking:::::

:GameComplete
cls
echo ::::::::::::::::::::::
echo ::INJECTION COMPLETE::
echo ::::::::::::::::::::::
echo.
echo A folder has been created named
IF /i "%PACKDECIDE%"=="y" echo "[NES] %GAMENAME% (000500001337%TITLEID%)"
IF /i "%PACKDECIDE%"=="n" echo "[NES] %GAMENAME% [%PRODUCTCODE%]"
echo in the Output directory with the injected game. You can install this using
echo WUP Installer GX2, WUP Installer Y Mod or System Config Tool.
echo.
echo It is recommended to install to USB in case of game corruption.
echo.
echo Press any key to exit.
pause>NUL
exit

:::::ERRORS:::::
:404ROMnotFound
cls
echo :::::::::
echo ::ERROR::
echo :::::::::
echo.
echo NES ROM not found.
echo.
echo Aborting in five seconds.
SLEEP 5
exit

:404ImagesNotFound
cls
echo :::::::::
echo ::ERROR::
echo :::::::::
echo.
echo Images not found.
echo.
echo Make sure you have the following images in the Files directory:
echo bootTvTex.png (1280 x 720)
echo iconTex.png (128 x 128)
echo.
echo Aborting in five seconds.
SLEEP 5
exit

:LoadiineError
cls
echo :::::::::
echo ::ERROR::
echo :::::::::
echo.
echo Failed to create a Loadiine package.
echo.
echo Aborting in five seconds.
SLEEP 5
exit

:GameError
cls
echo :::::::::
echo ::ERROR::
echo :::::::::
echo.
echo Failed to create a WUP package.
echo.
echo Aborting in five seconds.
SLEEP 5
exit

:InjectError
cls
echo :::::::::
echo ::ERROR::
echo :::::::::
echo.
echo Failed to inject the ROM.
echo.
echo Aborting in five seconds.
SLEEP 5
exit

:ROBOFAIL
cls
echo :::::::::
echo ::ERROR::
echo :::::::::
echo.
echo Robocopy failed to create a working directory with the JNUSTool
echo base files.
echo.
echo Aborting in five seconds.
SLEEP 5
exit

:InternetSucks
cls
echo :::::::::
echo ::ERROR::
echo :::::::::
echo.
echo Internet connection test failed.
echo.
echo Aborting in five seconds.
SLEEP 5
exit
:::::END ERRORS:::::