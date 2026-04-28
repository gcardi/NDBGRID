@echo off
setlocal EnableExtensions

:: ===========================================================================
:: NDBGRID -- Delphi component installer for RAD Studio
::
:: What this script does:
::   1. Builds the runtime package for Win32, Win64 and Win64x via MSBuild,
::      and the design-time package for the platforms hosted by an installed
::      IDE: Win32 always, plus Win64/Win64x when bin64\bds.exe is present.
::      Default IDE artifact locations under %BDSCOMMONDIR% are used (no
::      path overrides):
::         BPL  -> %BDSCOMMONDIR%\Bpl[\Win64|\Win64x]
::         DCP/BPI/LIB/A -> %BDSCOMMONDIR%\Dcp[\Win64|\Win64x]
::         HPP  -> %BDSCOMMONDIR%\hpp[\<platform>]
::      The C++Builder consumption artifacts (.hpp, .bpi, .lib, .a) are
::      produced alongside the .bpl by DCC_CBuilderOutput=All in the dproj.
::   2. Registers the design-time BPLs with the RAD Studio IDE so the
::      component appears in the Tool Palette:
::        - "Known Packages"     -> 32-bit IDE host (bds.exe)   -> Win32 BPL
::        - "Known Packages x64" -> 64-bit IDE host (bds64.exe) -> Win64 BPL
::      The x64 entry is skipped on RAD Studio versions without a 64-bit IDE
::      (e.g. RAD Studio 12 / BDS 23.0 ships bds.exe only).
::
:: BDS_VERSION is derived from the script's location:
::   ...\Studio\<VER>\NDBGRID\Delphi\install.bat  ->  BDS_VERSION = <VER>
::
:: Run from a normal user prompt (no admin needed -- writes to HKCU only).
:: Re-runnable: re-running just rebuilds and rewrites the same registry
:: entries.
:: ===========================================================================

set "SCRIPT_DIR=%~dp0"

:: Walk two levels up: ...\Studio\<VER>\NDBGRID\Delphi\  ->  ...\Studio\<VER>
for %%I in ("%~dp0..\..") do set "BDS_VER_DIR=%%~fI"
for %%I in ("%BDS_VER_DIR%") do set "BDS_VERSION=%%~nxI"

if "%BDS_VERSION%"=="" (
  echo ERROR: Could not derive BDS_VERSION from script path "%SCRIPT_DIR%".
  echo Expected layout: ...\Studio\^<VER^>\NDBGRID\Delphi\install.bat
  goto :fail
)

set "BDS_ROOT=C:\Program Files (x86)\Embarcadero\Studio\%BDS_VERSION%"
set "RUN_PKG=EnhDbGridRunPkg"
set "DSGN_PKG=EnhDbGridDsgnPkg"
set "PKG_DESCRIPTION=Enhanced DBGrid"

:: Which 64-bit BPL the 64-bit IDE host should load. Most third-party
:: packages use Win64; flip to Win64x if you specifically need the Clang-x64
:: design-time build.
set "IDE_X64_PLATFORM=Win64"

:: ===========================================================================
:: Sanity checks
:: ===========================================================================
if not exist "%BDS_ROOT%\bin\rsvars.bat" (
  echo ERROR: rsvars.bat not found at "%BDS_ROOT%\bin\rsvars.bat".
  echo Verify that RAD Studio %BDS_VERSION% is installed at the expected path.
  goto :fail
)

if not exist "%SCRIPT_DIR%%RUN_PKG%.dproj"  ( echo ERROR: %RUN_PKG%.dproj not found next to install.bat.  & goto :fail )
if not exist "%SCRIPT_DIR%%DSGN_PKG%.dproj" ( echo ERROR: %DSGN_PKG%.dproj not found next to install.bat. & goto :fail )

:: ===========================================================================
:: Detect whether this RAD Studio install ships a 64-bit IDE host. Older
:: versions (e.g. RAD Studio 12 / BDS 23.0) are 32-bit-only -- in that case
:: there is no "Known Packages x64" registry key, designide.dcp is shipped
:: Win32-only, and the design-time package can only build for Win32. The
:: runtime package is still built for all targets so C++Builder consumer
:: projects get the full set of artifacts.
:: ===========================================================================
set "HAS_X64_IDE="
if exist "%BDS_ROOT%\bin64\bds.exe" set "HAS_X64_IDE=1"

:: ===========================================================================
:: MSBuild environment (rsvars.bat exports BDS, BDSCOMMONDIR, PATH, ...)
:: ===========================================================================
call "%BDS_ROOT%\bin\rsvars.bat" || goto :fail
if not defined BDSCOMMONDIR (
  echo ERROR: BDSCOMMONDIR not set after running rsvars.bat.
  goto :fail
)

echo.
if defined HAS_X64_IDE (
  echo === RAD Studio %BDS_VERSION%   64-bit IDE host: yes   BDSCOMMONDIR=%BDSCOMMONDIR% ===
) else (
  echo === RAD Studio %BDS_VERSION%   64-bit IDE host: no  -- Win32 design-time only   BDSCOMMONDIR=%BDSCOMMONDIR% ===
)

:: ===========================================================================
:: Build runtime on all three platforms (so C++Builder consumers get the
:: full set of artifacts on every target). Build design-time only for the
:: platforms hosted by an installed IDE: Win32 always, plus Win64/Win64x
:: when a 64-bit IDE is present.
:: Clean and Build are issued as separate MSBuild invocations on purpose:
:: chaining /t:Clean;Build can leave the project's main .res unregenerated
:: under the C++Builder target chain. Two calls is reliable for both Delphi
:: and C++ builds.
:: ===========================================================================
for %%P in (Win32 Win64 Win64x) do (
  call :build "%SCRIPT_DIR%%RUN_PKG%.dproj"  %%P || goto :fail
)
call :build "%SCRIPT_DIR%%DSGN_PKG%.dproj" Win32 || goto :fail
if defined HAS_X64_IDE (
  call :build "%SCRIPT_DIR%%DSGN_PKG%.dproj" Win64  || goto :fail
  call :build "%SCRIPT_DIR%%DSGN_PKG%.dproj" Win64x || goto :fail
)

:: ===========================================================================
:: Copy *_resources.res alongside the generated .bpi/.lib/.a so C++Builder
:: consumer projects can link against the runtime package. The .dpk has
:: {$R *.res} so the .bpi references the .res by name; ld.lld (Clang-x64)
:: in particular fails with "file 'EnhDbGridRunPkg_resources.res' does not
:: exist" when the .res is not on its library search path. The build only
:: emits the .res to the project source dir (via RcCompile), so we mirror
:: it into the per-platform Dcp output dirs, which are already on the
:: default IDE C++ library search path.
:: ===========================================================================
echo.
echo === Copying resource .res files alongside C++ static artifacts ===
for %%P in ("%BDSCOMMONDIR%\Dcp" "%BDSCOMMONDIR%\Dcp\Win64" "%BDSCOMMONDIR%\Dcp\Win64x") do (
  if exist "%%~P" (
    call :copy_res "%SCRIPT_DIR%%RUN_PKG%_resources.res"  "%%~P"
    call :copy_res "%SCRIPT_DIR%%DSGN_PKG%_resources.res" "%%~P"
  )
)

:: ===========================================================================
:: Locate the freshly built design-time BPLs. The {$LIBSUFFIX AUTO} compiler
:: directive appends a compiler-version digit string (e.g. "370" for v37,
:: "290" for v29) to the BPL name, so we discover the actual filename via
:: glob instead of hard-coding the suffix.
:: ===========================================================================
set "DSGN_BPL_WIN32="
for %%F in ("%BDSCOMMONDIR%\Bpl\%DSGN_PKG%*.bpl") do set "DSGN_BPL_WIN32=%%~fF"
if not defined DSGN_BPL_WIN32 ( echo ERROR: missing %BDSCOMMONDIR%\Bpl\%DSGN_PKG%*.bpl & goto :fail )

set "DSGN_BPL_X64="
if defined HAS_X64_IDE (
  for %%F in ("%BDSCOMMONDIR%\Bpl\%IDE_X64_PLATFORM%\%DSGN_PKG%*.bpl") do set "DSGN_BPL_X64=%%~fF"
)
if defined HAS_X64_IDE if not defined DSGN_BPL_X64 ( echo ERROR: missing %BDSCOMMONDIR%\Bpl\%IDE_X64_PLATFORM%\%DSGN_PKG%*.bpl & goto :fail )

:: ===========================================================================
:: Register design-time BPLs with the IDE
:: ===========================================================================
set "REG_BASE=HKCU\Software\Embarcadero\BDS\%BDS_VERSION%"

echo.
echo === Registering with RAD Studio %BDS_VERSION% ===
reg add "%REG_BASE%\Known Packages"     /v "%DSGN_BPL_WIN32%" /t REG_SZ /d "%PKG_DESCRIPTION%" /f >nul || goto :fail
if defined HAS_X64_IDE (
  reg add "%REG_BASE%\Known Packages x64" /v "%DSGN_BPL_X64%" /t REG_SZ /d "%PKG_DESCRIPTION%" /f >nul || goto :fail
)

:: ===========================================================================
:: Add the runtime source folder to the IDE's per-platform Library Search Path
:: so consumer projects can resolve NDBGrid / ColTitleAttrs without the user
:: editing Tools > Options > Language > Delphi > Library by hand. Without this
:: dcc32/dcc64/dcc64x report F2613 "Unit 'NDBGrid' not found" even though the
:: component is on the Tool Palette. The default %BDSCOMMONDIR%\Dcp[\<plat>]
:: paths are already in the IDE's library search path so we don't add them.
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
if defined HAS_X64_IDE echo   64-bit IDE (bds64.exe) --^> %DSGN_BPL_X64%
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
:: :copy_res  <src_file>  <dst_dir>     -- silent if either side missing
:: ---------------------------------------------------------------------------
:copy_res
if not exist "%~1" exit /b 0
if not exist "%~2" exit /b 0
copy /Y "%~1" "%~2\" >nul || exit /b 1
echo   copy  %~nx1 ^> %~2
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
