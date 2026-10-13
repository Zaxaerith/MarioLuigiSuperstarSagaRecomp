param(
    [string]$Version = '0.1.0-preview',
    [string]$Toolchain = 'C:/MYAPPLY/mingw64',
    [string]$SdlRoot = 'D:/Project/GameRecomp/_sdl2/SDL2-2.32.8/x86_64-w64-mingw32',
    [switch]$SkipBuild
)
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot

if ($Version -notmatch '^\d+\.\d+\.\d+(-[a-z0-9.-]+)?$') { throw 'Invalid version' }
if (-not (Test-Path "$Toolchain/bin/gcc.exe")) {
    if ($env:MINGW_ROOT -and (Test-Path "$env:MINGW_ROOT/bin/gcc.exe")) { $Toolchain = $env:MINGW_ROOT }
}
if (-not (Test-Path "$SdlRoot/include/SDL2/SDL.h")) {
    if ($env:SDL2_ROOT -and (Test-Path "$env:SDL2_ROOT/include/SDL2/SDL.h")) { $SdlRoot = $env:SDL2_ROOT }
}

$pin = Get-Content "$root/docs/FRAMEWORK_PIN.json" -Raw | ConvertFrom-Json
foreach ($pair in @(@('gbarecomp',$pin.commit),@('recomp-ui',$pin.recomp_ui_commit),@('.deps/tomlplusplus',$pin.tomlplusplus_commit))) {
    $head = & git -C "$root/$($pair[0])" rev-parse HEAD
    if ($LASTEXITCODE -ne 0 -or $head -ne $pair[1]) { throw "Dependency pin mismatch: $($pair[0])" }
}

if (-not $SkipBuild) {
    & "$PSScriptRoot/build-host.ps1" -Toolchain $Toolchain -SdlRoot $SdlRoot -Jobs 4
}
if (-not (Select-String -LiteralPath "$root/build/host/CMakeCache.txt" -Pattern '^CMAKE_BUILD_TYPE:STRING=Release$')) {
    throw 'Release build required'
}

$name = "MarioLuigiSuperstarSagaRecomp-windows-x64-v$Version"
$stage = "$root/release-stage/$name"
$zip = "$stage.zip"
if (Test-Path -LiteralPath $stage) { Remove-Item -Recurse -Force -LiteralPath $stage }
if (Test-Path -LiteralPath $zip) { Remove-Item -Force -LiteralPath $zip }
if (Test-Path -LiteralPath "$zip.sha256") { Remove-Item -Force -LiteralPath "$zip.sha256" }

New-Item -ItemType Directory -Path "$stage/licenses/mpl-source" -Force | Out-Null

$binaries = @('MarioLuigiSuperstarSagaRecomp.exe','SDL2.dll','libgcc_s_seh-1.dll','libstdc++-6.dll','libwinpthread-1.dll')
foreach ($file in $binaries) {
    Copy-Item -LiteralPath "$root/build/host/$file" -Destination "$stage/$file"
    if (Test-Path "$Toolchain/bin/strip.exe") {
        & "$Toolchain/bin/strip.exe" --strip-debug "$stage/$file"
    }
}

$assets = @(
    'fonts/LatoLatin-Regular.ttf','fonts/LatoLatin-Bold.ttf','fonts/OpenMoji-black-glyf.ttf','fonts/NotoSansSymbols2-Regular.ttf',
    'img/brand_mark.tga','img/verdict_ok.tga','img/verdict_warn.tga','img/verdict_bad.tga','img/verdict_none.tga','img/flags.png','img/pad_gba.tga'
)
foreach ($asset in $assets) {
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent "$stage/assets/$asset") | Out-Null
    Copy-Item -LiteralPath "$root/build/host/assets/$asset" -Destination "$stage/assets/$asset"
}

Copy-Item -LiteralPath "$root/LICENSE" -Destination "$stage/LICENSE"
Copy-Item -LiteralPath "$root/THIRD_PARTY_NOTICES.md" -Destination "$stage/THIRD_PARTY_NOTICES.md"
Copy-Item -LiteralPath "$root/README.md" -Destination "$stage/README.md"
if (Test-Path "$root/README.zh-CN.md") {
    Copy-Item -LiteralPath "$root/README.zh-CN.md" -Destination "$stage/README.zh-CN.md"
}

$licenses = @{
    'GBARecomp'="$root/gbarecomp/LICENSE"
    'RecompUI'="$root/recomp-ui/LICENSE"
    'ImGui'="$root/recomp-ui/src/third_party/imgui/LICENSE.txt"
    'ArmRecompCore'="$root/gbarecomp/external/arm-recomp-core/LICENSE"
    'RecompNet'="$root/gbarecomp/external/recomp-net/LICENSE"
    'Rbengine'="$root/gbarecomp/external/rbengine/LICENSE"
    'Font-Notices'="$root/recomp-ui/assets/common/fonts/NOTICE.md"
    'Image-Notices'="$root/recomp-ui/assets/common/img/NOTICE.md"
    'MPL-2.0'="$root/gbarecomp/third_party/MPL-2.0.txt"
    'Framework-Attribution'="$root/gbarecomp/THIRD_PARTY_ATTRIBUTION.md"
    'TomlPlusPlus'="$root/.deps/tomlplusplus/LICENSE"
}
$sdlLicense = Join-Path (Split-Path -Parent $SdlRoot) 'LICENSE.txt'
if (Test-Path $sdlLicense) { $licenses['SDL2'] = $sdlLicense }

foreach ($key in $licenses.Keys) {
    if (Test-Path $licenses[$key]) {
        Copy-Item -LiteralPath $licenses[$key] -Destination "$stage/licenses/$key.txt"
    }
}
if (Test-Path "$root/docs/licenses") {
    Get-ChildItem -Path "$root/docs/licenses" -Filter "*.txt" | ForEach-Object {
        Copy-Item -LiteralPath $_.FullName -Destination "$stage/licenses/$($_.Name)"
    }
}
foreach ($file in @('bios_hle.cpp','bios_hle.h')) {
    $src = "$root/gbarecomp/src/runtime/$file"
    if (Test-Path $src) {
        Copy-Item -LiteralPath $src -Destination "$stage/licenses/mpl-source/$file"
    }
}

$manifest = @(Get-ChildItem -LiteralPath $stage -Recurse -File | Sort-Object FullName | ForEach-Object {
    [pscustomobject]@{
        file = $_.FullName.Substring($stage.Length+1).Replace('\','/')
        bytes = $_.Length
        sha256 = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
    }
})
$manifest | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath "$stage/manifest.json" -Encoding utf8

Write-Host "==> Creating release archive: $zip"
Compress-Archive -Path "$stage/*" -DestinationPath $zip -CompressionLevel Optimal
$zipHash = (Get-FileHash -LiteralPath $zip -Algorithm SHA256).Hash.ToLowerInvariant()
"$zipHash  $([System.IO.Path]::GetFileName($zip))" | Set-Content -LiteralPath "$zip.sha256" -Encoding ascii

Write-Host "PASS: Windows x64 Preview package created at $stage"
Write-Host "      Archive: $zip ($((Get-Item $zip).Length) bytes, SHA256: $zipHash)"
