# Third-Party Notices & Licenses

This project incorporates, links against, or references software and documentation from third-party open-source projects. Below are the corresponding notices, attributions, and license summaries. Full license texts accompany the release candidate in `licenses/` and are tracked in `docs/licenses/`.

---

## 1. GBARecomp
- **Repository**: [https://github.com/mstan/gbarecomp](https://github.com/mstan/gbarecomp)
- **Author**: Matthew Stanley (`mstan`)
- **Pinned Commit**: `e3c834d399b66f5a823c2f0f9d878b62dc05d25a` (see [docs/FRAMEWORK_PIN.json](docs/FRAMEWORK_PIN.json))
- **License**: [PolyForm Noncommercial License 1.0.0](https://polyformproject.org/licenses/noncommercial/1.0.0/)
- **Description**: Static recompiler framework for the Game Boy Advance, providing ARM/Thumb ahead-of-time code translation, PPU/APU bus emulation, cycle-accurate timing, and runtime environment.
- **Attribution**: Retains upstream `THIRD_PARTY_ATTRIBUTION.md` (reproduced in `licenses/Framework-Attribution.txt`).

## 2. recomp-ui
- **Repository**: [https://github.com/mstan/recomp-ui](https://github.com/mstan/recomp-ui)
- **Author**: Matthew Stanley (`mstan`)
- **Pinned Commit**: `6374aae201b930c97425718249f5d39b2275ca13`
- **License**: MIT License (`licenses/RecompUI.txt`)
- **Description**: Cross-platform Dear ImGui-based player launcher GUI, settings manager, and input configuration layer.

## 3. arm-recomp-core
- **Repository**: [https://github.com/mstan/arm-recomp-core](https://github.com/mstan/arm-recomp-core)
- **Author**: Matthew Stanley (`mstan`)
- **License**: MIT License (`licenses/ArmRecompCore.txt`)
- **Description**: Core ARMv4T / Thumb instruction recompiler and code generator.

## 4. recomp-net & rbengine
- **Repositories**: Pinned nested submodules within GBARecomp (`external/recomp-net`, `external/rbengine`)
- **License**: MIT License (`licenses/RecompNet.txt`, `licenses/Rbengine.txt`)

## 5. Dear ImGui
- **Repository**: [https://github.com/ocornut/imgui](https://github.com/ocornut/imgui)
- **Author**: Omar Cornut and Dear ImGui contributors
- **License**: MIT License (`licenses/ImGui.txt`)
- **Description**: Immediate-mode GUI library used by `recomp-ui`.

## 6. SDL2 (Simple DirectMedia Layer)
- **Website**: [https://www.libsdl.org/](https://www.libsdl.org/)
- **Version**: 2.32.8
- **License**: zlib License (`licenses/SDL2.txt`)
- **Description**: Cross-platform audio streaming, window and OpenGL context creation, keyboard and game controller input.

## 7. toml++
- **Repository**: [https://github.com/marzer/tomlplusplus](https://github.com/marzer/tomlplusplus)
- **Author**: Mark Gillard
- **Pinned Commit**: `30172438cee64926dc41fdd9c11fb3ba5b2ba9de`
- **License**: MIT License (`licenses/TomlPlusPlus.txt`)
- **Description**: TOML parser used during development by the recompiler generator (`gba_recompile`).

## 8. JRickey / gba-recomp Attributions
- **Upstream**: [https://github.com/JRickey/gba-recomp](https://github.com/JRickey/gba-recomp)
- **Author**: JRickey
- **License**: MIT OR Apache-2.0 (used under MIT option, `licenses/JRickey-MIT.txt`)
- **Ported Logic**: Portions ported into GBARecomp include MP2K sound driver detection and struct offsets, display colorimetry simulation, cartridge RTC state machine, and audio shadow verification.

## 9. mGBA-Derived Covered Software (MPL-2.0)
- **Upstream**: [https://github.com/mgba-emu/mgba](https://github.com/mgba-emu/mgba)
- **Author**: Jeffrey Pfau and contributors
- **License**: Mozilla Public License 2.0 (MPL-2.0) (`licenses/MPL-2.0.txt`)
- **Covered Files**: GBARecomp's `src/runtime/bios_hle.cpp` and `bios_hle.h` derive from mGBA's `src/gba/bios.c` and are licensed under MPL-2.0 (not PolyForm Noncommercial).
- **Source Availability Compliance**: In accordance with MPL-2.0 Section 3.2, the full Source Code Form of these files is bundled in the release candidate at `licenses/mpl-source/bios_hle.cpp` and `licenses/mpl-source/bios_hle.h`. Note that retail BIOS LLE remains the default execution mode. `libmgba` is not linked into the native shipping build.

## 10. Fonts and UI Visual Assets
- **Lato**: Designed by Łukasz Dziedzic — SIL Open Font License 1.1 (`licenses/Lato-OFL.txt`)
- **Noto Sans Symbols 2**: Designed by Google / Noto Project Authors — SIL Open Font License 1.1 (`licenses/NotoSymbols-OFL.txt`)
- **OpenMoji**: Designed by OpenMoji project — Creative Commons Attribution-ShareAlike 4.0 International (CC BY-SA 4.0) (`licenses/OpenMoji-LICENSE.txt`)
- **Launcher Icons & Flags**: Derived from Noto Color Emoji and custom launcher textures (see `licenses/Image-Notices.txt` and `licenses/Font-Notices.txt`).

## 11. MinGW-w64 & GCC Runtime Libraries
- **`libgcc_s_seh-1.dll` & `libstdc++-6.dll`**: Distributed under the GNU General Public License v3 with the [GCC Runtime Library Exception (RLE)](https://www.gnu.org/licenses/gcc-exception-3.1.en.html). The exception permits distributing independent binaries compiled with GCC without subjecting the entire work to GPL copyleft.
- **`libwinpthread-1.dll`**: Developed by the MinGW-w64 project, distributed under permissive MIT / BSD-style terms.

## 12. Decompilation Research Reference (`mlss`)
- **Repository**: [https://github.com/jellees/mlss](https://github.com/jellees/mlss)
- **Author**: `jellees` and contributors
- **Usage & Boundary**: Used strictly as an informational and structural reference for function boundaries, symbol names, and process scheduling layouts (`struct ProcessDefinition`).
- **Notice**: **No unlicensed C source code, assembly routines, or proprietary game assets from the `jellees/mlss` project are vendored, copied, or redistributed in this repository.**

## 13. Project Integration Layer
- **Integration Author**: Zaxaerith
- **License**: [PolyForm Noncommercial License 1.0.0](LICENSE) (Copyright (c) 2026 Zaxaerith).
- **Scope**: Covers project-owned host bootstrap, launcher glue, build automation scripts, and technical documentation. Third-party components retain their respective upstream licenses.

---

## 14. Copyright Disclaimer & Public Binary Distribution Assessment

*Mario & Luigi: Superstar Saga*, *Mario*, *Luigi*, *Bowser*, and all related characters and assets are registered trademarks and copyrights of **Nintendo Co., Ltd.** and **AlphaDream Corporation**.

This project is an independent, non-commercial software engineering and digital preservation research initiative. It is not affiliated with, sponsored by, or endorsed by Nintendo or AlphaDream.

> **Important Notice on Binary Redistribution**:  
> A technical exclusion audit (confirming that an archive contains zero raw ROM images, zero BIOS binaries, and zero personal save files) validates archive hygiene, but does not resolve the underlying intellectual property assessment of statically translated commercial game code. Any public release or redistribution of a compiled, game-derived executable must be evaluated independently under applicable copyright and fair use frameworks. Intended use of this project is local, personal non-commercial study and research.
