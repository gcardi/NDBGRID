@echo off
setlocal EnableExtensions

:: ===========================================================================
:: NDBGRID -- Delphi component installer for RAD Studio
::
:: What this script does:
::   1. Builds the Delphi runtime + design-time packages for Win32, Win64
::      and Win64x via MSBuild. The build naturally produces the C++Builder
::      consumption artifacts (.hpp, .bpi, .lib, .a) alongside the .bpl.
::   2. Registers the design-time BPLs with the RAD Studio IDE so the
::      component appears in the Tool Palette:
::        - "Known Packages"     -> 32-bit IDE host (bds.exe)   -> Win32 BPL
::        - "Known Packages x64" -> 64-bit IDE host (bds64.exe) -> Win64 BPL
::
:: Run from a normal user prompt (no admin needed -- writes to HKCU only).
:: Re-runnable: re-running just rebuilds and rewrites the same registry
:: entries.
::
:: Configuration -- edit for a different RAD Studio version
:: ===========================================================================
set "BDS_VERSION=37.0"
set "BDS_ROOT=C:\Program Files (x86)\Embarcadero\Studio\%BDS_VERSION%"
set "RUN_PKG=EnhDbGridRunPkg"
set "DSGN_PKG=EnhDbGridDsgnPkg"
set "PKG_DESCRIPTION=Enhanced DBGrid"

:: {$LIBSUFFIX AUTO} value for this RAD Studio version. NOT always equal to
:: BDS_VERSION with the dot stripped (BDS 23 produces "290", not "230") --
:: check the auto-built BPL filename under %BDSCOMMONDIR%\Bpl after a
:: manual build to confirm.
set "LIB_SUFFIX=370"

:: Which 64-bit BPL the 64-bit IDE host should load. Most third-party
:: packages use Win64; flip to Win64x if you specifically need the Clang-x64
:: design-time build.
set "IDE_X64_PLATFORM=Win64"

:: ===========================================================================
:: Sanity checks
:: ===========================================================================
if not exist "%BDS_ROOT%\bin\rsvars.bat" (
  echo ERROR: rsvars.bat not found at "%BDS_ROOT%\bin\rsvars.bat".
  echo Edit BDS_VERSION / BDS_ROOT at the top of this script.
  goto :fail
)

set "SCRIPT_DIR=%~dp0"
if not exist "%SCRIPT_DIR%%RUN_PKG%.dproj"  ( echo ERROR: %RUN_PKG%.dproj not found next to install.bat.  & goto :fail )
if not exist "%SCRIPT_DIR%%DSGN_PKG%.dproj" ( echo ERROR: %DSGN_PKG%.dproj not found next to install.bat. & goto :fail )

:: ===========================================================================
:: MSBuild environment (rsvars.bat exports BDS, BDSCOMMONDIR, PATH, ...)
:: ===========================================================================
call "%BDS_ROOT%\bin\rsvars.bat" || goto :fail
if not defined BDSCOMMONDIR (
  echo ERROR: BDSCOMMONDIR not set after running rsvars.bat.
  goto :fail
)

:: ===========================================================================
:: Build runtime + design-time on all three platforms.
:: Clean and Build are issued as separate MSBuild invocations on purpose:
:: chaining /t:Clean;Build can leave the project's main .res unregenerated
:: under the C++Builder target chain. Two calls is reliable for both Delphi
:: and C++ builds.
:: ===========================================================================
for %%P in (Win32 Win64 Win64x) do (
  call :build "%SCRIPT_DIR%%RUN_PKG%.dproj"  %%P || goto :fail
)
for %%P in (Win32 Win64 Win64x) do (
  call :build "%SCRIPT_DIR%%DSGN_PKG%.dproj" %%P || goto :fail
)

:: ===========================================================================
:: Locate the freshly built design-time BPLs
:: ===========================================================================
set "DSGN_BPL_WIN32=%BDSCOMMONDIR%\Bpl\%DSGN_PKG%%LIB_SUFFIX%.bpl"
if /I "%IDE_X64_PLATFORM%"=="Win64x" (
  set "DSGN_BPL_X64=%BDSCOMMONDIR%\Bpl\Win64x\%DSGN_PKG%%LIB_SUFFIX%.bpl"
) else (
  set "DSGN_BPL_X64=%BDSCOMMONDIR%\Bpl\Win64\%DSGN_PKG%%LIB_SUFFIX%.bpl"
)

if not exist "%DSGN_BPL_WIN32%" ( echo ERROR: missing %DSGN_BPL_WIN32% & goto :fail )
if not exist "%DSGN_BPL_X64%"   ( echo ERROR: missing %DSGN_BPL_X64%   & goto :fail )

:: ===========================================================================
:: Register design-time BPLs with the IDE
:: ===========================================================================
set "REG_BASE=HKCU\Software\Embarcadero\BDS\%BDS_VERSION%"

echo.
echo === Registering with RAD Studio %BDS_VERSION% ===
reg add "%REG_BASE%\Known Packages"     /v "%DSGN_BPL_WIN32%" /t REG_SZ /d "%PKG_DESCRIPTION%" /f >nul || goto :fail
reg add "%REG_BASE%\Known Packages x64" /v "%DSGN_BPL_X64%"   /t REG_SZ /d "%PKG_DESCRIPTION%" /f >nul || goto :fail

:: ===========================================================================
:: Add the runtime source folder to the IDE's per-platform Library Search Path
:: so consumer projects can resolve NDBGrid / ColTitleAttrs without the user
:: editing Tools > Options > Language > Delphi > Library by hand. Without this
:: dcc32/dcc64/dcc64x report F2613 "Unit 'NDBGrid' not found" even though the
:: component is on the Tool Palette.
:: ===========================================================================
set "SOURCE_DIR=%SCRIPT_DIR:~0,-1%"

echo.
echo === Updating IDE Library Search Path ===
for %%P in (Win32 Win64 Win64x) do (
  call :libpath_add "%BDS_VERSION%" "%%P" "%SOURCE_DIR%"
)

echo.
echo Install complete.
echo   32-bit IDE (bds.exe)   --^> %DSGN_BPL_WIN32%
echo   64-bit IDE (bds64.exe) --^> %DSGN_BPL_X64%
echo.
echo Restart RAD Studio to pick up the component.
exit /b 0

:: ---------------------------------------------------------------------------
:: :build  <dproj_path>  <platform>
:: ---------------------------------------------------------------------------
:build
echo.
echo === Building %~n1 / %2 ===
msbuild %1 /t:Clean /p:Config=Release /p:Platform=%2 /v:minimal /nologo || exit /b 1
msbuild %1 /t:Build /p:Config=Release /p:Platform=%2 /v:minimal /nologo || exit /b 1
exit /b 0

:: ---------------------------------------------------------------------------
:: :libpath_add  <BDS_VERSION>  <Platform>  <Path>
:: Idempotently appends <Path> to HKCU\...\BDS\<ver>\Library\<Platform>\Search Path
:: using inline PowerShell (read-modify-write of the semicolon-delimited REG_SZ).
:: Args are passed via env vars to keep the PS one-liner free of nested quoting.
:: ---------------------------------------------------------------------------
:libpath_add
set "PS_VER=%~1"
set "PS_PLAT=%~2"
set "PS_PATH=%~3"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$k = 'HKCU:\Software\Embarcadero\BDS\' + $env:PS_VER + '\Library\' + $env:PS_PLAT; $n = 'Search Path'; $a = $env:PS_PATH; if(!(Test-Path $k)){ New-Item -Path $k -Force | Out-Null }; $c = (Get-ItemProperty -Path $k -Name $n -ErrorAction SilentlyContinue).$n; $p = @(); if($c){ $p = $c -split ';' | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' } }; if(-not ($p -icontains $a)){ $p += $a; Set-ItemProperty -Path $k -Name $n -Value ($p -join ';') -Type String; Write-Host ('  added ' + $env:PS_PLAT + ' Search Path += ' + $a) } else { Write-Host ('  ok    ' + $env:PS_PLAT + ' Search Path already has ' + $a) }"
exit /b 0

:fail
echo.
echo *** Install failed. ***
exit /b 1
