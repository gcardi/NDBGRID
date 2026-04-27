@echo off
setlocal EnableExtensions

:: ===========================================================================
:: NDBGRID -- Delphi component installer for RAD Studio 12 (BDS 23.0)
::
:: What this script does:
::   1. Builds the Delphi runtime package for Win32, Win64 and Win64x via
::      MSBuild. The build naturally produces the C++Builder consumption
::      artifacts (.hpp, .bpi, .lib, .a) alongside the .bpl.
::   2. Builds the Delphi design-time package for Win32 only -- RAD Studio
::      12 has only a 32-bit IDE host (bds.exe) and the design-time
::      framework (designide.dcp) is shipped Win32-only.
::   3. Registers the Win32 design-time BPL with the IDE so the component
::      appears in the Tool Palette ("Known Packages").
::
:: Run from a normal user prompt (no admin needed -- writes to HKCU only).
:: Re-runnable: re-running just rebuilds and rewrites the same registry
:: entry.
::
:: Configuration -- edit if your install path differs
:: ===========================================================================
set "BDS_VERSION=23.0"
set "BDS_ROOT=C:\Program Files (x86)\Embarcadero\Studio\%BDS_VERSION%"
set "RUN_PKG=EnhDbGridRunPkg"
set "DSGN_PKG=EnhDbGridDsgnPkg"
set "PKG_DESCRIPTION=Enhanced DBGrid"

:: {$LIBSUFFIX AUTO} value for this RAD Studio version. RAD Studio 12 (BDS
:: 23.0) produces "290" (compiler series), NOT "230". Verify by checking
:: the auto-built BPL filename under %BDSCOMMONDIR%\Bpl after a manual
:: build.
set "LIB_SUFFIX=290"

:: ===========================================================================
:: Sanity checks
:: ===========================================================================
if not exist "%BDS_ROOT%\bin\rsvars.bat" (
  echo ERROR: rsvars.bat not found at "%BDS_ROOT%\bin\rsvars.bat".
  echo Edit BDS_VERSION / BDS_ROOT at the top of this script.
  goto :fail
)

set "SCRIPT_DIR=%~dp0"
if not exist "%SCRIPT_DIR%%RUN_PKG%.dproj"  ( echo ERROR: %RUN_PKG%.dproj not found next to install_12.bat.  & goto :fail )
if not exist "%SCRIPT_DIR%%DSGN_PKG%.dproj" ( echo ERROR: %DSGN_PKG%.dproj not found next to install_12.bat. & goto :fail )

:: ===========================================================================
:: MSBuild environment (rsvars.bat exports BDS, BDSCOMMONDIR, PATH, ...)
:: ===========================================================================
call "%BDS_ROOT%\bin\rsvars.bat" || goto :fail
if not defined BDSCOMMONDIR (
  echo ERROR: BDSCOMMONDIR not set after running rsvars.bat.
  goto :fail
)

:: ===========================================================================
:: Build runtime on all three platforms (so C++Builder consumers get the
:: full set of artifacts), and design-time on Win32 only.
:: Clean and Build are issued as separate MSBuild invocations on purpose
:: (chained /t:Clean;Build is unreliable across the C++Builder targets).
:: ===========================================================================
for %%P in (Win32 Win64 Win64x) do (
  call :build "%SCRIPT_DIR%%RUN_PKG%.dproj"  %%P || goto :fail
)
call :build "%SCRIPT_DIR%%DSGN_PKG%.dproj" Win32 || goto :fail

:: ===========================================================================
:: Locate the freshly built design-time BPL
:: ===========================================================================
set "DSGN_BPL_WIN32=%BDSCOMMONDIR%\Bpl\%DSGN_PKG%%LIB_SUFFIX%.bpl"
if not exist "%DSGN_BPL_WIN32%" ( echo ERROR: missing %DSGN_BPL_WIN32% & goto :fail )

:: ===========================================================================
:: Register design-time BPL with the IDE
:: ===========================================================================
set "REG_BASE=HKCU\Software\Embarcadero\BDS\%BDS_VERSION%"

echo.
echo === Registering with RAD Studio 12 (BDS %BDS_VERSION%) ===
reg add "%REG_BASE%\Known Packages" /v "%DSGN_BPL_WIN32%" /t REG_SZ /d "%PKG_DESCRIPTION%" /f >nul || goto :fail

echo.
echo Install complete.
echo   IDE (bds.exe, 32-bit only) --^> %DSGN_BPL_WIN32%
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

:fail
echo.
echo *** Install failed. ***
exit /b 1
