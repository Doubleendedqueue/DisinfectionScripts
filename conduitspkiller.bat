@echo off

::-----------------------------------
:: Main Script
::-----------------------------------

(
call :killProcess "cltmng.exe"
call :killProcess "cltmngui.exe"
call :deleteService "CltMngSvc"

call :deleteDirectory "%programfiles%\SearchProtect"
call :deleteDirectory "%allusersappdata%\SearchProtect"
call :deleteDirectory "%appdata%\SearchProtect"

reg delete "HKLM\SOFTWARE\SearchProtect" /f
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\SearchProtect" /f

call :resetIE
call :resetFirefox
call :cleanTemps
echo.disinfection done
) 1> log.txt 2>&1

del %0

goto :eof

::-----------------------------------
:: Function Section
::-----------------------------------

:: killProcess processname
:killProcess
echo.killing process %~1
taskkill /f /im "%~1"
goto :eof

:: deleteService servicename
:deleteService
echo.deleting service %~1
sc stop "%~1"
sc delete "%~1"
goto :eof

:: deleteDirectory directoryname
:deleteDirectory
echo.removing directory %~1
if exist %~1 (
  attrib /s /d -s -h -r "%~1"
  rd /s /q "%~1"
) else echo.not found
goto :eof

:: deleteFile filename
:deleteFile
echo.removing file %~1
if exist %~1 (
  attrib -s -h -r "%~1"
  del /f /q "%~1"
) else echo.not found
goto :eof

:: cleanFolder foldername
:cleanFolder
if exist "%~1" (
   echo.cleaning folder "%~1"
   for /d %%D in ("%~1\*") do rd /s /q "%%D"
   del /f /q "%~1\*"
)
goto :eof

:: reset Firefox settings
:resetFirefox
echo.resetting Firefox
call :killProcess firefox.exe
call :deleteDirectory "%UserProfile%\AppData\Local\Mozilla\Firefox\Profiles"
call :deleteDirectory "%AppData%\Mozilla\Firefox"
goto :eof

:: reset IE settings
:resetIE
echo.resetting Internet Explorer
call :killProcess iexplore.exe
reg delete "HKCU\Software\Microsoft\Internet Explorer" /f
goto :eof

:: clean temporary folders and internet caches
:cleanTemps
echo.cleaning temporary files
call :cleanFolder "%temp%"
call :cleanFolder "%USERPROFILE%\Local Settings\Temporary Internet Files"
call :cleanFolder "%USERPROFILE%\Local Settings\Temp"
call :cleanFolder "%LOCALAPPDATA%\Microsoft\Windows\Temporary Internet Files\Low\Content.IE5"
goto :eof
