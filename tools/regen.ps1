<#
    regen.ps1 — regenerate cartridge and BIOS translation from verified inputs.

    Gates before any generation:
      1. exactly one *.gba in the project root
      2. its MD5/SHA-1/SHA-256 match docs/ROM_IDENTITY.json
      3. the BIOS dump SHA-1 matches docs/ROM_IDENTITY.json

    Outputs (local-only, gitignored):
        generated/cart/   recompiled_*.cpp, dispatch_table.cpp, symbol_map.cpp
        generated/bios/   bios_recompiled.cpp, bios_dispatch_table.cpp
#>
[CmdletBinding()]
param(
    [string]$Bios,
    [string]$Generator,
    [int]$MaxFunctions = 65536,
    [switch]$CartOnly,
    [switch]$SkipBios
)

$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $PSScriptRoot
$LogDir = Join-Path $Root 'logs'
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null

function Step($m) { Write-Host "==> $m" }
function Fail($m) { throw $m }

# ---------------------------------------------------------------- ROM identity
$roms = @(Get-ChildItem -LiteralPath $Root -Filter '*.gba' -File)
if ($roms.Count -ne 1) { Fail "Expected exactly one .gba in $Root, found $($roms.Count)." }
$rom = $roms[0].FullName
$identity = Get-Content -LiteralPath (Join-Path $Root 'docs\ROM_IDENTITY.json') -Raw | ConvertFrom-Json
$want = $identity.rom
$have = [ordered]@{
    md5    = (Get-FileHash $rom -Algorithm MD5).Hash.ToLower()
    sha1   = (Get-FileHash $rom -Algorithm SHA1).Hash.ToLower()
    sha256 = (Get-FileHash $rom -Algorithm SHA256).Hash.ToLower()
}
foreach ($k in @('md5','sha1','sha256')) {
    if ($have[$k] -ne $want.$k) { Fail "ROM $k mismatch: have $($have[$k]), expected $($want.$k)." }
}
if ((Get-Item $rom).Length -ne $want.size_bytes) { Fail 'ROM size mismatch.' }
Step "ROM verified: $([System.IO.Path]::GetFileName($rom))  sha1=$($have.sha1)"

# ------------------------------------------------------------------- generator
if (-not $Generator) {
    $candidates = @(
        (Join-Path $Root 'build\framework\Release\gba_recompile.exe'),
        (Join-Path $Root 'build\framework\gba_recompile.exe'),
        (Join-Path (Split-Path -Parent $Root) 'gbarecomp-main\build-vs\Release\gba_recompile.exe'),
        (Join-Path (Split-Path -Parent $Root) 'gbarecomp-main\build-mingw\gba_recompile.exe')
    )
    $Generator = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
}
if (-not $Generator -or -not (Test-Path $Generator)) {
    Fail 'gba_recompile.exe not found.'
}
Step "generator: $Generator"

# ----------------------------------------------------------------------- BIOS
if (-not $Bios) {
    $SharedRoot = Split-Path -Parent $Root
    $candidates = @(
        (Join-Path $Root 'bios\gba_bios.bin'),
        (Join-Path $SharedRoot 'gbarecomp-cli-windows-x86_64\gbabios\gba_bios.bin')
    )
    $Bios = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
}
if (-not $SkipBios) {
    if (-not $Bios) { Fail 'No BIOS dump found. Pass -Bios <path> or place bios/gba_bios.bin.' }
    $biosSha1 = (Get-FileHash $Bios -Algorithm SHA1).Hash.ToLower()
    if ($biosSha1 -ne $identity.bios.sha1) { Fail "BIOS SHA-1 mismatch: $biosSha1" }
    Step "BIOS verified: $Bios"
}

$config = Join-Path $Root 'game.toml'
$frameworkBiosToml = Join-Path (Split-Path -Parent $Root) 'gbarecomp-main\bios\gba_bios.toml'
if (-not (Test-Path $frameworkBiosToml)) {
    $frameworkBiosToml = Join-Path $Root 'reference\gbarecomp\bios\gba_bios.toml'
}

# ----------------------------------------------------------------- cartridge
$cartOut = Join-Path $Root 'generated\cart'
New-Item -ItemType Directory -Force -Path $cartOut | Out-Null
$cartLog = Join-Path $LogDir 'cart-generation.log'
Step "cartridge generation -> $cartOut"
& $Generator --rom $rom --config $config --out $cartOut --max-functions $MaxFunctions *>&1 |
    Tee-Object -FilePath $cartLog
if ($LASTEXITCODE -ne 0) { Fail "Cartridge generation failed (exit $LASTEXITCODE); see $cartLog" }
if (-not (Test-Path (Join-Path $cartOut 'dispatch_table.cpp'))) { Fail 'No dispatch_table.cpp' }
$shards = @(Get-ChildItem -LiteralPath $cartOut -Filter 'recompiled_*.cpp' -File)
if ($shards.Count -lt 1) { Fail 'No recompiled_*.cpp shard' }
Step "cartridge shards: $($shards.Count)"

# ---------------------------------------------------------------------- BIOS
if (-not $SkipBios -and -not $CartOnly) {
    $biosOut = Join-Path $Root 'generated\bios'
    New-Item -ItemType Directory -Force -Path $biosOut | Out-Null
    $biosLog = Join-Path $LogDir 'bios-generation.log'
    Step "BIOS generation -> $biosOut"
    & $Generator --bios $Bios --config $frameworkBiosToml --out $biosOut *>&1 |
        Tee-Object -FilePath $biosLog
    if ($LASTEXITCODE -ne 0) { Fail "BIOS generation failed (exit $LASTEXITCODE); see $biosLog" }
    if (-not (Test-Path (Join-Path $biosOut 'bios_recompiled.cpp'))) { Fail 'No bios_recompiled.cpp' }

    # codegen_tail_macros.h is hand-written framework source the build force-includes.
    $tailCandidates = @(
        (Join-Path (Split-Path -Parent $Root) 'gbarecomp-main\src\runtime\generated_bios\codegen_tail_macros.h'),
        (Join-Path $Root 'reference\gbarecomp\src\runtime\generated_bios\codegen_tail_macros.h')
    )
    $tail = $tailCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1
    if (-not $tail) { Fail 'codegen_tail_macros.h not found in framework' }
    Copy-Item $tail (Join-Path $biosOut 'codegen_tail_macros.h') -Force
    Step "BIOS translation done"
}

Step 'regeneration complete'
