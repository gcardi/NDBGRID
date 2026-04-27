@echo off
setlocal EnableExtensions

:: ===========================================================================
:: NDBGRID -- Delphi component uninstaller for RAD Studio
::
:: What this script does:
::   1. Removes the design-time package's entries from the IDE's
::      Known Packages / Known Packages x64 / Disabled Packages /
::      Disabled Packages x64 keys.
::   2. Deletes the build artifacts (.bpl / .dcp / .bpi / .lib / .a / .hpp /
::      .res / .map / .pdi / .tds / .rsp) under $(BDSCOMMONDIR) for the
::      runtime and design-time packages.
::
:: It tries to remove BOTH the Win64 and Win64x design-time BPL paths from
:: the x64 IDE keys, so it works regardless of which IDE_X64_PLATFORM was
:: used at install time. Missing entries / files are silently ignored, so
:: re-running on a clean machine is a no-op.
::
:: Configuration -- keep in sync with install.bat
:: ===========================================================================
set "BDS_VERSION=37.0"
set "BDS_ROOT=C:\Program Files (x86)\Embarcadero\Studio\%BDS_VERSION%"
set "RUN_PKG=EnhDbGridRunPkg"
set "DSGN_PKG=EnhDbGridDsgnPkg"

:: ===========================================================================
:: Sanity checks + MSBuild env (needed for $BDSCOMMONDIR)
:: ===========================================================================
if not exist "%BDS_ROOT%\bin\rsvars.bat" (
  echo ERROR: rsvars.bat not found at "%BDS_ROOT%\bin\rsvars.bat".
  echo Edit BDS_VERSION / BDS_ROOT at the top of this script.
  goto :fail
)

call "%BDS_ROOT%\bin\rsvars.bat" || goto :fail
if not defined BDSCOMMONDIR (
  echo ERROR: BDSCOMMONDIR not set after running rsvars.bat.
  goto :fail
)

set "LIB_SUFFIX=%BDS_VERSION:.=%"
set "REG_BASE=HKCU\Software\Embarcadero\BDS\%BDS_VERSION%"

:: Both possible paths for the 64-bit IDE host's design-time BPL
set "DSGN_BPL_WIN32=%BDSCOMMONDIR%\Bpl\%DSGN_PKG%%LIB_SUFFIX%.bpl"
set "DSGN_BPL_W64=%BDSCOMMONDIR%\Bpl\Win64\%DSGN_PKG%%LIB_SUFFIX%.bpl"
set "DSGN_BPL_W64X=%BDSCOMMONDIR%\Bpl\Win64x\%DSGN_PKG%%LIB_SUFFIX%.bpl"

:: ===========================================================================
:: Unregister from the IDE
:: ===========================================================================
echo === Removing registry entries ===
call :regdel "Known Packages"        "%DSGN_BPL_WIN32%"
call :regdel "Disabled Packages"     "%DSGN_BPL_WIN32%"
call :regdel "Known Packages x64"    "%DSGN_BPL_W64%"
call :regdel "Known Packages x64"    "%DSGN_BPL_W64X%"
call :regdel "Disabled Packages x64" "%DSGN_BPL_W64%"
call :regdel "Disabled Packages x64" "%DSGN_BPL_W64X%"

:: ===========================================================================
:: Delete build artifacts under $(BDSCOMMONDIR)
:: ===========================================================================
echo.
echo === Removing build artifacts from %BDSCOMMONDIR% ===
for %%D in (
  "%BDSCOMMONDIR%\Bpl"
  "%BDSCOMMONDIR%\Bpl\Win64"
  "%BDSCOMMONDIR%\Bpl\Win64x"
  "%BDSCOMMONDIR%\Dcp"
  "%BDSCOMMONDIR%\Dcp\Win64"
  "%BDSCOMMONDIR%\Dcp\Win64x"
  "%BDSCOMMONDIR%\hpp\Win32"
  "%BDSCOMMONDIR%\hpp\Win64"
  "%BDSCOMMONDIR%\hpp\Win64x"
) do (
  call :rmpat %%D "%RUN_PKG%*"
  call :rmpat %%D "%DSGN_PKG%*"
)

echo.
echo Uninstall complete.
echo Restart RAD Studio for the IDE to drop the component from the Tool Palette.
exit /b 0

:: ---------------------------------------------------------------------------
:: :regdel  <subkey>  <full BPL path used as value name>
:: ---------------------------------------------------------------------------
:regdel
reg query "%REG_BASE%\%~1" /v "%~2" >nul 2>nul
if errorlevel 1 exit /b 0
reg delete "%REG_BASE%\%~1" /v "%~2" /f >nul 2>nul
if errorlevel 1 (
  echo   FAIL  %~1 ^| %~2
) else (
  echo   gone  %~1 ^| %~2
)
exit /b 0

:: ---------------------------------------------------------------------------
:: :rmpat  <dir>  <glob>     -- silent if dir missing or no matches
:: ---------------------------------------------------------------------------
:rmpat
if not exist "%~1" exit /b 0
pushd "%~1" >nul
for %%F in ("%~2") do (
  if exist "%%~F" (
    del /q "%%~F" >nul 2>nul
    echo   del   %~1\%%~F
  )
)
popd >nul
exit /b 0

:fail
echo.
echo *** Uninstall failed. ***
exit /b 1
