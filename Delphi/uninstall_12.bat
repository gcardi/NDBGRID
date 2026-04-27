@echo off
setlocal EnableExtensions

:: ===========================================================================
:: NDBGRID -- Delphi component uninstaller for RAD Studio 12 (BDS 23.0)
::
:: What this script does:
::   1. Removes the design-time package's entries from the IDE's Known
::      Packages and Disabled Packages keys (no x64 variants in BDS 23 --
::      RAD Studio 12 has a 32-bit-only IDE).
::   2. Deletes the build artifacts (.bpl / .dcp / .bpi / .lib / .a / .hpp /
::      .res / .map / .pdi / .tds / .rsp) under $(BDSCOMMONDIR) for the
::      runtime and design-time packages. The wildcard pattern matches the
::      pre-rename "EnhDbGridDsgn*" name as well as the current
::      "EnhDbGridDsgnPkg*", so leftover legacy artifacts are also cleaned.
::
:: Missing entries / files are silently ignored, so re-running on a clean
:: machine is a no-op.
::
:: Configuration -- keep in sync with install_12.bat
:: ===========================================================================
set "BDS_VERSION=23.0"
set "BDS_ROOT=C:\Program Files (x86)\Embarcadero\Studio\%BDS_VERSION%"
set "RUN_PKG=EnhDbGridRunPkg"
set "DSGN_PKG=EnhDbGridDsgnPkg"

:: {$LIBSUFFIX AUTO} value for this RAD Studio version (see install_12.bat).
set "LIB_SUFFIX=290"

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

set "REG_BASE=HKCU\Software\Embarcadero\BDS\%BDS_VERSION%"
set "DSGN_BPL_WIN32=%BDSCOMMONDIR%\Bpl\%DSGN_PKG%%LIB_SUFFIX%.bpl"
:: Pre-rename legacy path that may still be registered from older installs
set "LEGACY_DSGN_BPL=%BDSCOMMONDIR%\Bpl\EnhDbGridDsgn%LIB_SUFFIX%.bpl"

:: ===========================================================================
:: Unregister from the IDE
:: ===========================================================================
echo === Removing registry entries ===
call :regdel "Known Packages"    "%DSGN_BPL_WIN32%"
call :regdel "Disabled Packages" "%DSGN_BPL_WIN32%"
call :regdel "Known Packages"    "%LEGACY_DSGN_BPL%"
call :regdel "Disabled Packages" "%LEGACY_DSGN_BPL%"

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
  "%BDSCOMMONDIR%\Dcp\Win64\Release"
  "%BDSCOMMONDIR%\Dcp\Win64x"
  "%BDSCOMMONDIR%\Dcp\Win64x\Release"
  "%BDSCOMMONDIR%\hpp\Win32"
  "%BDSCOMMONDIR%\hpp\Win64"
  "%BDSCOMMONDIR%\hpp\Win64x"
) do (
  call :rmpat %%D "%RUN_PKG%*"
  call :rmpat %%D "EnhDbGridDsgn*"
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
for /f "delims=" %%F in ('dir /b /a:-D "%~2" 2^>nul') do (
  del /q "%%F" >nul 2>nul
  echo   del   %~1\%%F
)
popd >nul
exit /b 0

:fail
echo.
echo *** Uninstall failed. ***
exit /b 1
