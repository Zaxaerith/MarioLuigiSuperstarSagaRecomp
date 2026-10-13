param(
    [int]$Jobs = 4,
    [string]$Toolchain = "C:/MYAPPLY/mingw64",
    [string]$SdlRoot = "D:/Project/GameRecomp/_sdl2/SDL2-2.32.8/x86_64-w64-mingw32",
    [switch]$GeneratorOnly
)
. "$PSScriptRoot\common.ps1"
if ($Jobs -lt 1) { throw 'Jobs must be positive.' }
if (-not (Test-Path "$Toolchain/bin/gcc.exe")) {
    if ($env:MINGW_ROOT -and (Test-Path "$env:MINGW_ROOT/bin/gcc.exe")) {
        $Toolchain = $env:MINGW_ROOT
    }
}
if (-not (Test-Path "$Toolchain/bin/gcc.exe")) {
    throw "MinGW toolchain not found at $Toolchain. Pass -Toolchain or set MINGW_ROOT."
}
if (-not (Test-Path "$SdlRoot/include/SDL2/SDL.h")) {
    if ($env:SDL2_ROOT -and (Test-Path "$env:SDL2_ROOT/include/SDL2/SDL.h")) {
        $SdlRoot = $env:SDL2_ROOT
    }
}
if (-not (Test-Path "$SdlRoot/include/SDL2/SDL.h")) {
    throw "SDL2 SDK not found at $SdlRoot. Pass -SdlRoot or set SDL2_ROOT."
}

$sdl = (Resolve-Path -LiteralPath $SdlRoot).Path.Replace('\','/')
$tc = (Resolve-Path -LiteralPath $Toolchain).Path.Replace('\','/')
New-Item -ItemType Directory -Force -Path "$ProjectRoot\logs" | Out-Null
$argsConfigure = @('-S',$ProjectRoot,'-B',"$ProjectRoot\build\host",'-G','Ninja','-DCMAKE_BUILD_TYPE=Release',
    "-DCMAKE_C_COMPILER=$tc/bin/gcc.exe","-DCMAKE_CXX_COMPILER=$tc/bin/g++.exe",
    "-DSDL2_INCLUDE_DIR=$sdl/include/SDL2","-DSDL2_LIBRARY=$sdl/lib/libSDL2.dll.a","-DSDL2_DLL=$sdl/bin/SDL2.dll",
    "-DGBARECOMP_MINGW_RUNTIME_BIN=$tc/bin",
    "-DGBARECOMP_ROOT=$ProjectRoot/gbarecomp","-DGBARECOMP_TOMLPP_INCLUDE_DIR=$ProjectRoot/.deps/tomlplusplus",
    "-DRECOMP_UI_ROOT=$ProjectRoot/recomp-ui")
Invoke-Logged 'cmake' $argsConfigure "$ProjectRoot\logs\host-configure.log"
$target = 'MarioLuigiSuperstarSagaRecomp'
if ($GeneratorOnly) { $target = 'gba_recompile' }
Invoke-Logged 'cmake' @('--build',"$ProjectRoot\build\host",'--target',$target,'--parallel',"$Jobs") "$ProjectRoot\logs\host-build.log"
if (-not $GeneratorOnly) { Get-Item -LiteralPath "$ProjectRoot\build\host\MarioLuigiSuperstarSagaRecomp.exe" | Select-Object FullName,Length }
