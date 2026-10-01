param(
    [int]$Frames = 10700
)

$root = "D:\Project\GameRecomp\MarioLuigiSuperstarSagaRecomp"
Get-Process MarioLuigiSuperstarSagaRecomp -ErrorAction SilentlyContinue | ForEach-Object { $_.Kill() }

$exe = Join-Path $root "build\host\MarioLuigiSuperstarSagaRecomp.exe"
$bios = "D:\Project\GameRecomp\gbarecomp-cli-windows-x86_64\gbabios\gba_bios.bin"
$rom = Join-Path $root "Mario Luigi - Superstar Saga (USA).gba"
$config = Join-Path $root "game.toml"
$replay = Join-Path $root "tools\validation\smoke-dress-up.txt"
$png = Join-Path $root "logs\frames\f${Frames}_dbg.png"

$env:GBARECOMP_HEAL_CXX = "C:\MYAPPLY\mingw64\bin\g++.exe"
$env:PATH = "C:\MYAPPLY\mingw64\bin;" + $env:PATH
$env:GBARECOMP_INPUT_REPLAY = $replay
$env:GBARECOMP_MISS_IWRAM_DUMP = Join-Path $root "logs\iwram-miss.bin"
$env:GBARECOMP_TRACE_DUMP_DEPTH = "96"

$gdb = "C:\MYAPPLY\mingw64\bin\gdb.exe"
$exeFwd = $exe.Replace('\', '/')
$configFwd = $config.Replace('\', '/')
$romFwd = $rom.Replace('\', '/')
$biosFwd = $bios.Replace('\', '/')
$pngFwd = $png.Replace('\', '/')
$gdbScript = Join-Path $root "logs\run.gdb"

@"
set pagination off
file $exeFwd
set args --config "$configFwd" --rom "$romFwd" --bios "$biosFwd" --frames $Frames --dump-png "$pngFwd"
run
bt 30
print /x *(unsigned int(*)[16])&g_cpu
quit
"@ | Set-Content -Path $gdbScript -Encoding utf8

& $gdb --batch -x $gdbScript
