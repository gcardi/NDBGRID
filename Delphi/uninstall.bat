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
::      .obj / .o / .res / .map / .pdi / .tds / .rsp) under the default IDE
::      output locations: %BDSCOMMONDIR%\Bpl[\Win64|\Win64x],
::      %BDSCOMMONDIR%\Dcp[\Win64|\Win64x] and %BDSCOMMONDIR%\hpp[\<plat>].
::
:: It tries to remove BOTH the Win64 and Win64x design-time BPL paths from
:: the x64 IDE keys, so it works regardless of which IDE_X64_PLATFORM was
:: used at install time. The x64 cleanup steps are skipped on RAD Studio
:: versions without a 64-bit IDE host (e.g. RAD Studio 12 / BDS 23.0).
:: Missing entries / files are silently ignored, so re-running on a clean
:: machine is a no-op.
::
:: BDS_VERSION is derived from the script's location (same scheme as
:: install.bat): ...\Studio\<VER>\NDBGRID\Delphi\uninstall.bat -> <VER>.
:: ===========================================================================

set "SCRIPT_DIR=%~dp0"

for %%I in ("%~dp0..\..") do set "BDS_VER_DIR=%%~fI"
for %%I in ("%BDS_VER_DIR%") do set "BDS_VERSION=%%~nxI"

if "%BDS_VERSION%"=="" (
  echo ERROR: Could not derive BDS_VERSION from script path "%SCRIPT_DIR%".
  echo Expected layout: ...\Studio\^<VER^>\NDBGRID\Delphi\uninstall.bat
  goto :fail
)

set "BDS_ROOT=C:\Program Files (x86)\Embarcadero\Studio\%BDS_VERSION%"
set "RUN_PKG=EnhDbGridRunPkg"
set "DSGN_PKG=EnhDbGridDsgnPkg"

:: ===========================================================================
:: Sanity checks + MSBuild env (needed for $BDSCOMMONDIR)
:: ===========================================================================
if not exist "%BDS_ROOT%\bin\rsvars.bat" (
  echo ERROR: rsvars.bat not found at "%BDS_ROOT%\bin\rsvars.bat".
  echo Verify that RAD Studio %BDS_VERSION% is installed at the expected path.
  goto :fail
)

call "%BDS_ROOT%\bin\rsvars.bat" || goto :fail
if not defined BDSCOMMONDIR (
  echo ERROR: BDSCOMMONDIR not set after running rsvars.bat.
  goto :fail
)

:: ===========================================================================
:: Detect whether this RAD Studio install ships a 64-bit IDE host (mirrors
:: the same probe in install.bat). Older versions (e.g. RAD Studio 12 /
:: BDS 23.0) are 32-bit-only -- in that case the "Known Packages x64" /
:: "Disabled Packages x64" registry keys do not exist and the Bpl\Win64[x]
:: directories were never populated by install.
:: ===========================================================================
set "HAS_X64_IDE="
if exist "%BDS_ROOT%\bin64\bds.exe" set "HAS_X64_IDE=1"

echo.
if defined HAS_X64_IDE (
  echo === RAD Studio %BDS_VERSION%   64-bit IDE host: yes   BDSCOMMONDIR=%BDSCOMMONDIR% ===
) else (
  echo === RAD Studio %BDS_VERSION%   64-bit IDE host: no  -- skipping x64 cleanup   BDSCOMMONDIR=%BDSCOMMONDIR% ===
)

set "REG_BASE=HKCU\Software\Embarcadero\BDS\%BDS_VERSION%"

:: ===========================================================================
:: Unregister from the IDE. Glob the actual BPL filenames so we don't depend
:: on knowing the {$LIBSUFFIX AUTO} value.
:: ===========================================================================
echo.
echo === Removing registry entries ===
for %%F in ("%BDSCOMMONDIR%\Bpl\%DSGN_PKG%*.bpl") do (
  call :regdel "Known Packages"    "%%~fF"
  call :regdel "Disabled Packages" "%%~fF"
)
if defined HAS_X64_IDE (
  for %%F in ("%BDSCOMMONDIR%\Bpl\Win64\%DSGN_PKG%*.bpl") do (
    call :regdel "Known Packages x64"    "%%~fF"
    call :regdel "Disabled Packages x64" "%%~fF"
  )
  for %%F in ("%BDSCOMMONDIR%\Bpl\Win64x\%DSGN_PKG%*.bpl") do (
    call :regdel "Known Packages x64"    "%%~fF"
    call :regdel "Disabled Packages x64" "%%~fF"
  )
)

:: ===========================================================================
:: Delete build artifacts under %BDSCOMMONDIR%
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
  "%BDSCOMMONDIR%\hpp"
  "%BDSCOMMONDIR%\hpp\Win32"
  "%BDSCOMMONDIR%\hpp\Win64"
  "%BDSCOMMONDIR%\hpp\Win64x"
) do (
  call :rmpat %%D "%RUN_PKG%*"
  call :rmpat %%D "%DSGN_PKG%*"
  call :rmpat %%D "NDBGrid.*"
  call :rmpat %%D "NDBGridDsgn.*"
  call :rmpat %%D "ColTitleAttrs.*"
  call :rmpat %%D "ComponentEditors.*"
)

:: ===========================================================================
:: Remove the runtime source folder from the IDE's Library Search Path
:: (no-op if absent or already cleaned up).
:: ===========================================================================
set "SOURCE_DIR=%SCRIPT_DIR:~0,-1%"

echo.
echo === Updating IDE Library Search Path ===
for %%P in (Win32 Win64 Win64x) do (
  call :libpath_del "%BDS_VERSION%" "%%P" "%SOURCE_DIR%"
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

:: ---------------------------------------------------------------------------
:: :libpath_del  <BDS_VERSION>  <Platform>  <Path>
:: Removes <Path> from HKCU\...\BDS\<ver>\Library\<Platform>\Search Path
:: (case-insensitive exact-string match). No-op if key/value/path absent.
:: ---------------------------------------------------------------------------
:libpath_del
set "PS_VER=%~1"
set "PS_PLAT=%~2"
set "PS_PATH=%~3"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$k = 'HKCU:\Software\Embarcadero\BDS\' + $env:PS_VER + '\Library\' + $env:PS_PLAT; $n = 'Search Path'; $rm = $env:PS_PATH; if(!(Test-Path $k)){ exit 0 }; $c = (Get-ItemProperty -Path $k -Name $n -ErrorAction SilentlyContinue).$n; if(-not $c){ exit 0 }; $orig = $c; $p = $c -split ';' | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' -and $_ -ine $rm }; $new = ($p -join ';'); if($new -ne $orig){ Set-ItemProperty -Path $k -Name $n -Value $new -Type String; Write-Host ('  removed ' + $env:PS_PLAT + ' Search Path -= ' + $rm) } else { Write-Host ('  skip    ' + $env:PS_PLAT + ' Search Path did not contain ' + $rm) }"
exit /b 0

:fail
echo.
echo *** Uninstall failed. ***
exit /b 1
