# MarioLuigiSuperstarSagaRecomp

[English](README.md) | [简体中文](README.zh-CN.md)

> **Status: Experimental Preview**  
> Decomp-assisted static recompilation of **Mario & Luigi: Superstar Saga (USA, Game Code: A88E)** via [GBARecomp](https://github.com/Mr-Wiseguy/GBARecomp) targeting native Windows x64.

This repository provides the **game integration layer**: recompiler configuration, host integration, hardware bindings, and build automation. It does **not** distribute copyrighted ROM files, GBA BIOS dumps, or ROM-derived generated C++ code. Users provide their own legally acquired game ROM locally.

---

## Verified Milestones & Current Status

* [x] **Clean Native Build**: 64-bit Windows binary built with MinGW-w64, CMake, and Ninja (`MarioLuigiSuperstarSagaRecomp.exe`).
* [x] **BIOS / Cold Boot**: LLE BIOS reset, Nintendo logo, and AlphaDream company logo verified (`gba_bios.bin`).
* [x] **Title Screen & Profile Select**: Title screen animations ("PRESS START"), file selection menu, and New Game initialization verified.
* [x] **Opening Gameplay & Cutscenes**: Mario's house bathroom sequence, Toad alert, departure, and Peach's Castle arrival/exploration verified.
* [x] **Bowser Tutorial Battle**: Turn-based combat mechanics, Mario jump action commands, damage calculations, Bowser HP depletion, and victory sequence verified.
* [x] **Post-Battle Transition**: Battle scene fade-out and seamless return to the primary world map process loop (`FLDM`) without 0x0 dispatch crash verified.
* [x] **Save Hardware & Persistence**: Cartridge 8 KB serial EEPROM recognized and verified with disk persistence round-trip (`saves/mlss_usa.sav`).

### Scope & Untested Areas (Community Testing)

This project prioritizes rapid playable integration over exhaustive brute-force test coverage. The following areas remain open for community testing:
* Full campaign progression through the Beanbean Kingdom, Hoohoo Mountain, and later chapters.
* Later boss encounters, advanced bros. attacks, and minigames.
* *Mario Bros.* classic subgame integration.
* Full edge-case audio listening across all sound channels.

---

## Prerequisites

1. **Base ROM**:
   * *Mario & Luigi: Superstar Saga (USA)*
   * Game Code: `A88E`, Revision: `0`
   * Size: 16,777,216 bytes (`0x01000000`)
   * SHA-1: `7c303cdde5061ee329296948060b875cb50ba410`
   * MD5: `4b1a5897d89d9e74ec7f630eefdfd435`
   * Place the `.gba` file in the project root directory as `Mario Luigi - Superstar Saga (USA).gba`. See [baserom.md](baserom.md) for full identity specifications.
2. **GBA BIOS**:
   * Verified GBA BIOS dump (`gba_bios.bin`, 16,384 bytes, SHA-1: `300c20df6731a33952ded8c436f7f186d25d3492`).
3. **Build Environment**:
   * Windows 10 / 11 64-bit
   * MinGW-w64 (GCC 11+ or Clang with C++20 support)
   * CMake 3.20+ and Ninja
   * SDL2 development libraries for MinGW (`x86_64-w64-mingw32`)
   * Python 3.10+ (for validation scripts)
   * [GBARecomp](https://github.com/Mr-Wiseguy/GBARecomp) framework & CLI generator (`gba_recompile.exe`)

---

## Quick Start

### 1. Dependency Provisioning

Run the setup script to verify or clone dependencies:

```powershell
.\tools\setup-deps.ps1
```

### 2. Code Generation

Run the automated regeneration script to verify ROM integrity and generate the static translation:

```powershell
.\tools\regen.ps1
```

### 3. Compilation

Configure and build the native executable using CMake and Ninja:

```powershell
cmake -S . -B build/host -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build build/host
```

The compiled binary will be located at `build/host/MarioLuigiSuperstarSagaRecomp.exe`.

### 4. Launching

Launch the recompiled executable directly:

```powershell
.\build\host\MarioLuigiSuperstarSagaRecomp.exe --rom "Mario Luigi - Superstar Saga (USA).gba" --bios "gba_bios.bin"
```

---

## Controls

### Default Keyboard Mapping

| GBA Button | Default PC Key | Function |
|---|---|---|
| **D-Pad** | `W / A / S / D` or `↑ / ↓ / ← / →` | Movement / Menu Navigation |
| **A** | `Z` / `J` | Action / Jump / Confirm |
| **B** | `X` / `K` | Secondary Action / Cancel |
| **L** | `Q` / `U` | Action Cycle / Bros. Move Select |
| **R** | `E` / `I` | Character Swap / Action Cycle |
| **START** | `Enter` | Pause Menu |
| **SELECT** | `Backspace` / `Tab` | Suitcase / Map |

Custom keybindings can be configured in `game.toml`. Standard XInput / DirectInput game controllers are natively supported.

---

## Repository Structure

```text
MarioLuigiSuperstarSagaRecomp/
├── .gitattributes           # Git line-ending normalization
├── .gitignore               # Ignores ROMs, BIOS, saves, generated code, build trees
├── CMakeLists.txt           # Build definition linking GBARecomp runtime & host
├── LICENSE                  # PolyForm Noncommercial License 1.0.0
├── README.md                # Project documentation (English)
├── README.zh-CN.md          # Project documentation (Simplified Chinese)
├── THIRD_PARTY_NOTICES.md   # Third-party attributions and decomp licensing audit
├── baserom.md               # ROM / BIOS identity specifications & verification
├── docs/
│   └── ROM_IDENTITY.json    # Machine-readable ROM metadata and hashes
├── game.toml                # Core recompiler & runtime configuration
├── src/
│   └── main.cpp             # Host entry point and hardware hooks
└── tools/
    ├── regen.ps1            # Hash-gated code generation runner
    ├── run-smoke.ps1        # Headless regression and smoke test runner
    ├── setup-deps.ps1       # Automated dependency detection and setup
    └── validation/          # Deterministic test replay scripts and analysis tools
```

---

## Architecture & Attributions

* **Static Recompiler & Runtime**: Based on [GBARecomp](https://github.com/Mr-Wiseguy/GBARecomp), providing cycle-accurate GBA hardware emulation, ARM/Thumb AOT static translation, and self-healing dispatch.
* **Decompilation Research**: Appreciation to `jellees` and contributors of the [mlss](https://github.com/jellees/mlss) reverse-engineering project for documenting symbol boundaries, process scheduler structures (`ProcessDefinition`), and state transitions. No unlicensed decompilation code or copyrighted game assets are redistributed within this repository.
* See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) for full licensing details.

---

## License

PolyForm Noncommercial 1.0.0 — see [LICENSE](LICENSE).

Third-party components retain their respective licenses.

---

## Disclaimer

*Mario & Luigi: Superstar Saga*, *Mario*, *Luigi*, *Bowser*, and related characters are trademarks and copyrights of **Nintendo Co., Ltd.** and **AlphaDream Corporation**. This project is an independent, non-commercial software engineering research initiative and is **not** endorsed by, affiliated with, or associated with Nintendo or AlphaDream.
