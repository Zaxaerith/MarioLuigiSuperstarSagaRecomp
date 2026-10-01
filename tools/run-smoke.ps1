<#
    run-smoke.ps1 — headless smoke with the env this box needs.

    GBARECOMP_HEAL_CXX must point at a real g++ (the framework default
    C:/msys64/mingw64/bin/g++.exe does not exist here).
    GBARECOMP_DEMO_INPUT=1 mashes Start/A/D-pad so we leave the title.
#>
[CmdletBinding()]
param(
    [int]$Frames = 1800,
    [string]$DumpPng = "",
    [switch]$NoDemo,
    [switch]$NoHeal
)

$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $PSScriptRoot
if ((Split-Path -Leaf $PSScriptRoot) -ne 'tools') { $Root = $PSScriptRoot }

$Exe  = Join-Path $Root 'build\host\MarioLuigiSuperstarSagaRecomp.exe'
$Rom  = Get-ChildItem -LiteralPath $Root -Filter '*.gba' -File | Select-Object -First 1
if (-not $Rom) { throw 'no .gba in project root' }
$Bios = Join-Path (Split-Path -Parent $Root) 'gbarecomp-cli-windows-x86_64\gbabios\gba_bios.bin'
if (-not (Test-Path $Bios)) { $Bios = Join-Path $Root 'bios\gba_bios.bin' }

$env:PATH = "C:\MYAPPLY\mingw64\bin;$env:PATH"
$env:GBARECOMP_HEAL_CXX = 'C:\MYAPPLY\mingw64\bin\g++.exe'
if ($NoHeal) { $env:GBARECOMP_SELFHEAL = '0' }
if (-not $NoDemo) { $env:GBARECOMP_DEMO_INPUT = '1' }

$logDir = Join-Path $Root 'logs'
New-Item -ItemType Directory -Force -Path $logDir | Out-Null
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$log = Join-Path $logDir "smoke-$stamp.log"

$pngArgs = @()
if ($DumpPng) {
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $DumpPng) | Out-Null
    $pngArgs = @('--dump-png', $DumpPng)
}

Write-Host "==> $Exe --frames $Frames"
& $Exe --config (Join-Path $Root 'game.toml') --rom $Rom.FullName --bios $Bios `
    --frames $Frames @pngArgs *>&1 | Tee-Object -FilePath $log

Write-Host "==> log: $log"
if (Test-Path 'D:\Project\GameRecomp\recomp_coverage_A88E.json') {
    Copy-Item 'D:\Project\GameRecomp\recomp_coverage_A88E.json' (Join-Path $logDir 'coverage.json') -Force
}
if (Test-Path 'D:\Project\GameRecomp\recomp_master_misses_A88E.toml.frag') {
    Copy-Item 'D:\Project\GameRecomp\recomp_master_misses_A88E.toml.frag' (Join-Path $logDir 'misses.toml.frag') -Force
}
