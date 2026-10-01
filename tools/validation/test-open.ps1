param(
    [int]$Frames = 6000,
    [string]$PngName = "f6000-o9.png",
    [string]$ReplayFile = "smoke-open3.txt",
    [string]$OutFile = "open9.out",
    [string]$ErrFile = "open9.err"
)

$root = "D:\Project\GameRecomp\MarioLuigiSuperstarSagaRecomp"
Get-Process MarioLuigiSuperstarSagaRecomp -ErrorAction SilentlyContinue | ForEach-Object { $_.Kill() }

$exe = Join-Path $root "build\host\MarioLuigiSuperstarSagaRecomp.exe"
$bios = "D:\Project\GameRecomp\gbarecomp-cli-windows-x86_64\gbabios\gba_bios.bin"
$rom = Join-Path $root "Mario Luigi - Superstar Saga (USA).gba"
$config = Join-Path $root "game.toml"
$replay = Join-Path $root "tools\validation\$ReplayFile"
$out = Join-Path $root "logs\$OutFile"
$err = Join-Path $root "logs\$ErrFile"
$png = Join-Path $root "logs\frames\$PngName"

$env:GBARECOMP_HEAL_CXX = "C:\MYAPPLY\mingw64\bin\g++.exe"
$env:PATH = "C:\MYAPPLY\mingw64\bin;" + $env:PATH
$env:GBARECOMP_INPUT_REPLAY = $replay
$env:GBARECOMP_MISS_IWRAM_DUMP = Join-Path $root "logs\iwram-miss.bin"
$env:GBARECOMP_TRACE_DUMP_DEPTH = "96"

Remove-Item (Join-Path $root "logs\iwram-miss.bin") -ErrorAction SilentlyContinue

Remove-Item $out, $err -ErrorAction SilentlyContinue

$argLine = "--config `"$config`" --rom `"$rom`" --bios `"$bios`" --frames $Frames --dump-png `"$png`""

Write-Host "Running $exe with $Frames frames..."
$p = Start-Process -FilePath $exe -ArgumentList $argLine -NoNewWindow -PassThru -RedirectStandardOutput $out -RedirectStandardError $err

$timeoutSec = 150
$stepSec = 2
$elapsed = 0

while ($elapsed -lt $timeoutSec) {
    Start-Sleep -Seconds $stepSec
    $elapsed += $stepSec
    if ($p.HasExited) {
        Write-Host "Process exited after ${elapsed}s with code $($p.ExitCode)"
        break
    }
}

if (-not $p.HasExited) {
    Write-Host "Process timed out after ${timeoutSec}s; killing process."
    $p.Kill()
}

if (Test-Path $out) {
    Write-Host "--- STDOUT summary ---"
    Get-Content $out | Select-Object -Last 10
}
if (Test-Path $err) {
    Write-Host "--- STDERR summary ---"
    Get-Content $err | Select-Object -Last 5
}
