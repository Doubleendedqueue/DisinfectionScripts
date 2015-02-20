@echo off

::-----------------------------------
:: Main Script
::-----------------------------------

echo.Conduit SP Disinfector is cleaning your system ...

(
call :killProcess "cltmng.exe"
call :killProcess "cltmngui.exe"
call :killProcess "HPNotify.exe"
call :killProcess "CmdShell.exe"
call :deleteService "CltMngSvc"
call :deleteService "IHProtect Service"

call :deleteDirectory "%PROGRAMFILES%\SearchProtect"
call :deleteDirectory "%SYSTEMDRIVE%\Progra~2\SearchProtect"
call :deleteDirectory "%PROGRAMFILES%\XTab"
call :deleteDirectory "%SYSTEMDRIVE%\Progra~2\XTab"
call :deleteDirectory "%PROGRAMFILES%\STab"
call :deleteDirectory "%SYSTEMDRIVE%\Progra~2\STab"
call :deleteDirectory "%PROGRAMDATA%\IHProtectUpDate"
call :deleteDirectory "%ALLUSERSAPPDATA%\SearchProtect"
call :deleteDirectory "%APPDATA%\SearchProtect"
call :deleteDirectory "%LOCALAPPDATA%\SearchProtect"

reg delete "HKLM\SOFTWARE\SearchProtect" /f
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\SearchProtect" /f

call :cleanTemps
call :resetIE
call :resetFirefox
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
if exist "%~1" (
  attrib /s /d -s -h -r "%~1"
  rd /s /q "%~1"
) else echo.not found
goto :eof

:: deleteFile filename
:deleteFile
echo.removing file %~1
if exist "%~1" (
  attrib -s -h -r "%~1"
  del /f /q "%~1"
) else echo.not found
goto :eof

:: cleanFolder foldername
:cleanFolder
if exist "%~1" (
   echo.cleaning folder %~1
   for /d %%D in ("%~1\*") do rd /s /q "%%D"
   del /f /q "%~1\*"
)
goto :eof

:: soft reset of Firefox settings after CSP infection
:resetFirefox
echo.resetting Firefox
call :killProcess firefox.exe
for /d %%D in ("%APPDATA%\Mozilla\Firefox\Profiles\*.default") do (
  echo user_pref^("browser.startup.homepage","about:home"^);>>"%%D\prefs.js"
  echo user_pref^("browser.newtab.url","about:newtab"^);>>"%%D\prefs.js"
  echo user_pref^("browser.search.defaultenginename","Google"^);>>"%%D\prefs.js"
  echo user_pref^("browser.search.selectedEngine",""^);>>"%%D\prefs.js"
)
goto :eof

:: soft reset of IE settings after CSP infection
:resetIE
echo.resetting Internet Explorer
call :killProcess iexplore.exe
reg delete "HKCU\Software\Microsoft\Internet Explorer\Main" /v "Start Page" /f
reg delete "HKCU\Software\Microsoft\Internet Explorer\SearchScopes" /f
goto :eof

:: clean temporary folders and internet caches
:cleanTemps
echo.cleaning temporary files
call :cleanFolder "%TEMP%"
call :cleanFolder "%USERPROFILE%\Local Settings\Temporary Internet Files"
call :cleanFolder "%USERPROFILE%\Local Settings\Temp"
call :cleanFolder "%LOCALAPPDATA%\Microsoft\Windows\Temporary Internet Files\Low\Content.IE5"
goto :eof
