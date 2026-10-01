<#
    setup-deps.ps1 — Setup and verify build dependencies for MarioLuigiSuperstarSagaRecomp.
#>
[CmdletBinding()]
param(
    [switch]$IncludeDecomp
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot

Write-Host "==> Verifying dependencies for MarioLuigiSuperstarSagaRecomp..."

# 1. Framework source check
$frameworkFound = $false
$frameworkCandidates = @(
    (Join-Path $root 'reference\gbarecomp'),
    (Join-Path (Split-Path -Parent $root) 'gbarecomp-main'),
    $env:GBARECOMP_ROOT
)

foreach ($c in $frameworkCandidates) {
    if ($c -and (Test-Path (Join-Path $c 'CMakeLists.txt'))) {
        $frameworkFound = $true
        Write-Host "  [OK] Framework found at: $c"
        break
    }
}

if (-not $frameworkFound) {
    Write-Host "  [*] Cloning GBARecomp framework reference into reference\gbarecomp..."
    $refDir = Join-Path $root 'reference\gbarecomp'
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $refDir) | Out-Null
    git clone https://github.com/mstan/gbarecomp.git $refDir
    if ($LASTEXITCODE -ne 0) { throw "Failed to clone gbarecomp framework" }
}

# 2. Generator executable check
$generatorCandidates = @(
    (Join-Path $root 'build\framework\Release\gba_recompile.exe'),
    (Join-Path $root 'build\framework\gba_recompile.exe'),
    (Join-Path (Split-Path -Parent $root) 'gbarecomp-main\build-vs\Release\gba_recompile.exe'),
    (Join-Path (Split-Path -Parent $root) 'gbarecomp-main\build-mingw\gba_recompile.exe')
)
$genFound = $generatorCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if ($genFound) {
    Write-Host "  [OK] Recompiler generator found at: $genFound"
} else {
    Write-Host "  [!] Notice: gba_recompile generator executable will be built by CMake framework target if not pre-built."
}

# 3. SDL2 dependency
$sdl2Candidates = @(
    $env:SDL2_ROOT,
    (Join-Path (Split-Path -Parent $root) '_sdl2\SDL2-2.32.8\x86_64-w64-mingw32'),
    'C:\msys64\mingw64'
)
$sdlFound = $sdl2Candidates | Where-Object { $_ -and (Test-Path (Join-Path $_ 'include\SDL2\SDL.h')) } | Select-Object -First 1
if ($sdlFound) {
    Write-Host "  [OK] SDL2 SDK found at: $sdlFound"
} else {
    Write-Host "  [!] Notice: SDL2 SDK not located in common paths. Ensure SDL2 is installed in MinGW or set SDL2_ROOT."
}

# 4. Optional decomp reference
if ($IncludeDecomp) {
    $decompDir = Join-Path $root 'third_party\mlss'
    if (-not (Test-Path (Join-Path $decompDir 'README.md'))) {
        Write-Host "  [*] Cloning mlss decompilation reference into third_party\mlss..."
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $decompDir) | Out-Null
        git clone https://github.com/jellees/mlss.git $decompDir
        git -C $decompDir checkout --detach b03634c2c700a3ae78f39e576cc88a45c3a724fd
    }
}

Write-Host "==> Setup check completed."
