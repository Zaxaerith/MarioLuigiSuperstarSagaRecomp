# baserom.md — required base ROM

This project is a **recompilation**, not a ROM distribution. No ROM, no GBA BIOS and no
ROM-derived generated code is stored in any public repository. The user supplies the
base ROM locally; every generation, build and validation run starts by re-verifying the
bytes below.

## Required input

| item | value |
| --- | --- |
| file | `Mario Luigi - Superstar Saga (USA).gba` in `PROJECT_ROOT` |
| region | USA |
| game code | `A88E` |
| internal title | `MARIO&LUIGIU` |
| maker code | `01` |
| software version (`0xBC`) | `0x00` |
| size | 16,777,216 bytes (`0x01000000`) |
| MD5 | `4b1a5897d89d9e74ec7f630eefdfd435` |
| SHA-1 | `7c303cdde5061ee329296948060b875cb50ba410` |
| SHA-256 | `af9066e7eacdab919e92987db8856d038e4b75d4ed011259c893702085a886be` |
| ARM entry point | file offset `0x000` = `0xEA00002E` → `0x080000C0` |
| fixed value (`0x04`) | `0x51AEFF24` |

SHA-1 matches the canonical USA Rev0 dump **and** `jellees/mlss` `rom.sha1`:

```text
7c303cdde5061ee329296948060b875cb50ba410 *mlss.gba
```

Only this image may be treated as the reliable address/ELF/symbol reference for
`third_party/mlss`. Any other dump is out of scope.

## How the identity is enforced

| gate | where |
| --- | --- |
| ROM MD5/SHA-1/SHA-256 before generation | `tools/regen.ps1` |
| hard hash check inside the generator | `game.toml` `[identity] sha1 = "7c303c…"` |
| raw record | `docs/ROM_IDENTITY.json` |

A mismatch aborts before anything is generated.

## Save hardware (resolved from ROM signature + runtime)

**EEPROM, 8 KB (`eeprom` / `size = 8192`).**

Evidence:

1. ROM bytes at `0x21DBA0` hold ASCII `EEPROM_V124` (Nintendo SDK save-library
   signature). `detect_save_type()` reports `EEPROM`.
2. Headless boot banner (`logs/boot-smoke-eeprom.log`):
   `save=EEPROM signature=EEPROM_V` and
   `save_config source=game-config type=EEPROM size=8192 (detected=EEPROM …)`.
3. `third_party/mlss/include/gba/flash_internal.h` still defines a 1 Mbit
   dual-bank flash API (`MX29L010`, `LE26FV10N1TS`). That decomp material is
   real, but the cartridge image does **not** advertise Flash — it is not used
   for `game.toml`.

Still **not** considered fully verified until:

```text
in-game save → full exit → relaunch → load → state correct
```

and the 8 KB size is confirmed by a successful write/readback.

## BIOS

The GBA BIOS is **not** in this repository. Use
`gbarecomp-cli-windows-x86_64/gbabios/gba_bios.bin` (16,384 bytes,
SHA-1 `300c20df6731a33952ded8c436f7f186d25d3492`) or a user-supplied dump with the
same hash. BIOS-derived generated C++ stays local-only.

## Decompilation

`jellees/mlss` (no root LICENSE at pin time), pinned commit
`b03634c2c700a3ae78f39e576cc88a45c3a724fd`, local clone under `third_party/mlss`.
Used for names, function boundaries, code/data split and already verified
C/ASM — never as an execution oracle. Direct copies of its implementation stay
local-only until upstream licensing is resolved.

## Local-only material (never committed)

ROM, BIOS, saves, `build/`, `generated/`, `recomp_cache/`, debug dumps, traces.
See `.gitignore`.
