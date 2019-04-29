rem - installation of appropriate Matlab drivers
@echo off
cls
if exist LuDispatcher.mexw32 	del /q LuDispatcher.mexw32
if exist LuDispatcher.mexw64 	del /q LuDispatcher.mexw64
if exist lumeneraimaq.dll del /q lumeneraimaq.dll
if exist lumeneraimaq09_32.dll 	del /q lumeneraimaq09_32.dll
if exist lumeneraimaq9_32.dll del /q lumeneraimaq09_32.dll
if exist lumeneraimaq10_32.dll 	del /q lumeneraimaq10_32.dll
if exist lumeneraimaq10_64.dll 	del /q lumeneraimaq10_64.dll
if "%1" == "1" goto w3209
if "%1" == "2" goto w3210
if "%1" == "3" goto w64 


:Menu
echo.
echo ......................................................................
echo .
echo Lumenera camera drivers configurator for Matlab.
echo .
echo Press 1- Windows 32 bits with Matlab IMAQ 2009 and before. 
echo Press 2- Windows 32 bits with Matlab IMAQ 2010
echo Press 3- Windows 64 bits with Matlab IMAQ 2010 the only one supported for 64bits.
echo Press 4- EXIT
echo ......................................................................
echo.
set /p m=Type 1, 2, 3, or 4 then press ENTER:
if %m%==1 goto w3209
if %m%==2 goto w3210
if %m%==3 goto w64
if %m%==4 goto eof

:w3209
:: echo Windows 32 bit with Matlabe Imaq 2009 and before.
copy LuDispatcher9_32.mexw32.tmp   LuDispatcher.mexw32 /y
copy lumeneraimaq9_32.dll.tmp lumeneraimaq.dll /y
goto eof

:w3210
:: echo Windows 32 bits with Matalab Imaq 2010.
copy LuDispatcher10_32.mexw32.tmp   LuDispatcher.mexw32 /y
copy lumeneraimaq10_32.dll.tmp lumeneraimaq.dll /y
goto eof


:w64
:: echo Windows 64 bit with Matlab IMAQ 2010 
copy LuDispatcher10_64.mexw64.tmp LuDispatcher.mexw64 /y
copy lumeneraimaq10_64.dll.tmp lumeneraimaq.dll /y
goto eof


:eof
::echo Matlab Drivers configuration done!!!!
