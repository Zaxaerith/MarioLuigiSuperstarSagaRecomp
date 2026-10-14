# MarioLuigiSuperstarSagaRecomp

[English](README.md) | [简体中文](README.zh-CN.md)

基于 [GBARecomp](https://github.com/mstan/gbarecomp) 与 [recomp-ui](https://github.com/mstan/recomp-ui) 构建的《马力欧与路易吉RPG》（*Mario & Luigi: Superstar Saga*, USA, Game Code: A88E, Revision 0）原生 64 位 Windows 静态重编译移植版。

> **v0.1.1-preview — Experimental Preview（实验性预览）**  
> 本项目为非官方、非商业性质的研究与数字化保护项目，与任天堂（Nintendo）及 AlphaDream 无任何关联。玩家需自行提供合法获取的 GBA 原版 ROM 与官方 GBA BIOS 固件。本项目不声明完整游戏流程的百分之百全要素兼容。

《马力欧与路易吉RPG》是 AlphaDream 与任天堂在 Game Boy Advance 平台上推出的经典动作 RPG 游戏。本 Windows 原生移植版将原始 ARM/Thumb 机器码静态翻译为原生 x64 机器指令，在完美保留原版战斗时机、动作指令判定、物理机制、图像音效与卡带存档特性的同时，提供开箱即用的现代化图形启动器（Launcher GUI）。

---

## 阶段成果与已验证状态

* [x] **BIOS / 冷启动**：低级仿真（LLE）BIOS 重置流程、官方任天堂商标与 AlphaDream 制作方 Logo 验证通过（`gba_bios.bin`）。
* [x] **标题画面与存档选择**：标题界面动画（"PRESS START"）、档案管理菜单及 New Game 新存档创建初始化流程验证通过。
* [x] **开篇流程与过场动画**：桃花公主城堡使者开场、马力欧居所浴室动画、奇诺比奥报信、出门场景切换及桃花公主城堡探访与场景交互验证通过。
* [x] **库巴教学战斗**：回合制战斗指令、马力欧跳跃 Action Command 动作指令判定、打击伤害计算、库巴 HP 归零结算与战败退场过场验证通过。
* [x] **战后平滑过渡**：战斗场景淡出、无缝切回大地图主循环进程（`FLDM`），且无任何 0x0 分发悬空崩溃，验证通过。
* [x] **卡带 EEPROM 存档持久化**：卡带 8 KB 串行 EEPROM 硬件签名自动识别，存档落盘与往返读取校验通过（`saves/mlss_usa.sav`）。
* [x] **原生玩家启动器**：集成基于 Dear ImGui 的图形启动器（`recomp-ui`），支持 ROM/BIOS 文件选择、SHA-1 哈希校验、按键映射、画面缩放及设置持久化。

### 社区测试范围说明

本预览版以快速建立稳定可靠的可玩原生基础为目标。以下章节与特性欢迎社区玩家在体验过程中进行测试与反馈：
* 豆豆王国、呼呼山、噗噗热带雨林及后续所有战役章节与主线探索。
* 进阶兄弟合体技能、后期首领战斗与内置迷你游戏。
* 经典内置副游戏 *Mario Bros.*（马力欧兄弟）。
* 复杂战斗与音乐切换下各声音通道的长时间听觉体验。

---

## 快速上手（玩家指南）

**普通玩家无需安装任何开发工具（无需 CMake、Ninja、GCC 编译器、Python 或命令行环境）：**

1. **下载解压**：前往仓库 Releases 页面下载 `MarioLuigiSuperstarSagaRecomp-windows-x64-v0.1.1-preview.zip`，并解压到电脑任意**可写目录**。确保主程序 `MarioLuigiSuperstarSagaRecomp.exe`、动态链接库（`SDL2.dll`、`libgcc_s_seh-1.dll`、`libstdc++-6.dll`、`libwinpthread-1.dll`）、`assets/` 资源目录及 `licenses/` 许可目录处于同一文件夹下。
2. **启动程序**：双击运行 `MarioLuigiSuperstarSagaRecomp.exe`。
3. **启动器配置**：
   * 点击 **Browse** 分别选择你拥有的美版 GBA ROM（`.gba`）和官方 GBA BIOS（`.bin`）。
   * 启动器将自动计算并核对文件 SHA-1 哈希与文件体积，校验通过后显示绿色对勾。
   * 在控制（Input）、显示（Display）与音频（Audio）选项卡中调整手柄/键盘按键、窗口缩放比例与音量。
4. **开始游戏**：点击 **Play** 即可进入游戏！

> [!TIP]
> 启动器会自动记住你所选择的文件路径与设置参数（分别保存在同一目录下的 `rom.cfg`、`bios.cfg`、`config.ini` 与 `keybinds.ini` 中）。如果勾选了“Skip Launcher”后希望重新打开配置界面，只需从命令行或快捷方式传入 `--launcher` 参数（或删除 `config.ini`）即可。

---

## 必需私有文件（ROM 与 BIOS）

玩家必须自行提供合法获取的游戏 ROM 和 GBA BIOS 镜像。本仓库及发布压缩包中**严禁且绝不分发**任何商业文件。

| 文件类型 | 适用版本与规格 | 文件大小 | SHA-1 哈希 | MD5 校验和 |
|---|---|---:|---|---|
| **游戏 ROM** | *Mario & Luigi: Superstar Saga* (美版 USA, 代码 `A88E`, 修订版 0) | 16,777,216 字节 | `7c303cdde5061ee329296948060b875cb50ba410` | `4b1a5897d89d9e74ec7f630eefdfd435` |
| **GBA BIOS** | 官方零售版 Game Boy Advance 固件镜像 | 16,384 字节 | `300c20df6731a33952ded8c436f7f186d25d3492` | `a860e8c0b6d573d191e4ec7db1b1e4f6` |

> [!WARNING]
> 其他区域版本（日版、欧版）、修改版 ROM 或高级仿真（HLE）替代 BIOS 将被启动器严格拦截。单纯重命名文件无法通过 SHA-1 哈希门禁。详细规格说明请参见 [baserom.md](baserom.md)。

---

## 操作、显示与音频

### 默认键盘按键映射

| GBA 按键 | PC 默认按键 | 功能说明 |
|---|---|---|
| **方向键** | `W / A / S / D` 或 `↑ / ↓ / ← / →` | 角色移动 / 菜单选择 |
| **A 键** | `Z` / `J` | 确认 / 跳跃 / 交互 |
| **B 键** | `X` / `K` | 取消 / 次要动作 |
| **L 键** | `Q` / `U` | 动作切换 / 技能轮换 |
| **R 键** | `E` / `I` | 角色切换 / 技能轮换 |
| **START** | `Enter` | 暂停菜单 |
| **SELECT** | `Backspace` / `Tab` | 手提箱 / 大地图 |

### 游戏手柄支持

通过 SDL2 原生支持主流现代游戏手柄（Xbox / XInput、PlayStation DualShock 4 / DualSense、Nintendo Switch Pro 手柄及通用 DirectInput 手柄）。可在启动器 **Input** 界面进行个性化键位映射。

### 显示与音频设置

* **窗口缩放**：支持 1x 至 6x 整数倍缩放或无边框全屏切换。
* **画面比例**：保持原版 GBA 3:2 显示比例（240 × 160 原生像素）。
* **音频输出**：集成音量控制滑块与 16 位 44.1 kHz 低延迟双声道音频输出。

---

## 游戏存档与配置

* **卡带存档**：通过双击或启动器运行游戏时，存档将保存在可执行文件旁的 **`saves/mlss_usa.sav`**。此为标准的 8 KiB 串行 EEPROM 原始镜像，与 GBA 真实烧录卡及主流模拟器通用。
* **配置持久化**：玩家配置（`rom.cfg`、`bios.cfg`、`config.ini`、`keybinds.ini`）保存在程序同目录下。
* **版本更新**：解压新版本时，只需将旧目录下的 `saves/` 文件夹与 `.cfg`/`.ini` 配置文件复制到新目录，即可无缝继承游戏进度与偏好设置。

---

## 技术架构

* **AOT 静态重编译**：基于 [GBARecomp](https://github.com/mstan/gbarecomp)，将 GBA ARMv4T / Thumb 指令在构建期翻译为高效的 C++ 源码。
* **解释器兜底（Interpreter Fallback）**：未在 AOT 覆盖范围内的动态跳转或罕见分支自动回退至高精度 ARMv4T 解释器。本预览版无需终端用户安装 C++ 编译器。
* **图形启动器**：通过固定的 [recomp-ui](https://github.com/mstan/recomp-ui)（基于 Dear ImGui）提供跨平台窗口管理、文件校验与持久化。
* **宿主集成**：基于 SDL2 负责窗口创建、OpenGL 硬件渲染、低延迟音频流及手柄热插拔处理。
* **反编译逆向工程参考**：感谢 `jellees` 及 [mlss](https://github.com/jellees/mlss) 逆向工程贡献者，为本项目的符号命名、进程调度结构（`ProcessDefinition`）与状态转移提供了重要参考依据。本仓库绝不包含未授权的反编译源码或商业游戏资源。

---

## 源码构建指南（开发者向）

如果你是开发者或希望自行在 Windows 环境下编译：

### 环境要求

* Windows 10 / 11 64-bit
* MinGW-w64（GCC 11+ 或支持 C++20 的 Clang）
* CMake 3.20+ 与 Ninja
* MinGW 版本的 SDL2 开发库（`x86_64-w64-mingw32`）
* Git

### 构建步骤

1. 克隆代码仓库及子模块：
   ```powershell
   git clone --recurse-submodules https://github.com/Zaxaerith/MarioLuigiSuperstarSagaRecomp.git
   cd MarioLuigiSuperstarSagaRecomp
   ```

2. 准备依赖库与 toml++：
   ```powershell
   .\tools\setup-deps.ps1
   ```

3. 基于你本地的 ROM 与 BIOS 生成重编译 C++ 代码：
   ```powershell
   .\tools\regen.ps1 -Rom "path\to\Mario Luigi - Superstar Saga (USA).gba" -Bios "path\to\gba_bios.bin"
   ```

4. 编译原生可执行文件：
   ```powershell
   .\tools\build-host.ps1 -Jobs 4 -Toolchain "C:/path/to/mingw64" -SdlRoot "D:/path/to/SDL2/x86_64-w64-mingw32"
   ```

5. 运行生成程序：
   ```powershell
   .\build\host\MarioLuigiSuperstarSagaRecomp.exe
   ```

### 开发者命令行参数

主程序保留了完整的开发者命令行支持：
* `--rom <path>`：直接指定 GBA ROM 路径（跳过启动器）。
* `--bios <path>`：直接指定 GBA BIOS 路径。
* `--save <path>`：指定自定义存档路径。
* `--launcher`：即使之前跳过了启动器，也强制唤起 GUI 启动界面。
* `--frames <count>`：运行指定帧数后正常退出（用于自动化冒烟回归测试）。
* `--no-window`：无头模式运行（不创建图形窗口）。

---

## 实验性预览限制说明

* 已验证范围覆盖开场动画、马力欧家、城堡探索至库巴教学战胜利退场回地图。
* 解释器兜底路径始终有效；现代 PC 运行流畅，但在首次进入复杂未翻译函数时可能存在轻微微卡顿。
* 经典《马力欧兄弟》副游戏与联机通信功能暂未支持。
* 手柄与键盘输入经过自动化测试与基础游玩验证，但全流程通关仍有待社区玩家完善。

---

## 致谢与许可证

* **GBARecomp**：作者 Matthew Stanley ([mstan/gbarecomp](https://github.com/mstan/gbarecomp))，采用 [PolyForm Noncommercial 1.0.0](https://polyformproject.org/licenses/noncommercial/1.0.0/) 许可证。
* **recomp-ui**：作者 Matthew Stanley ([mstan/recomp-ui](https://github.com/mstan/recomp-ui))，采用 MIT 许可证。
* **MarioLuigiSuperstarSagaRecomp 集成层**：由 Zaxaerith 开发，采用 [PolyForm Noncommercial 1.0.0](LICENSE) 许可证。
* **第三方组件**：
  * [Dear ImGui](https://github.com/ocornut/imgui) — MIT 许可证
  * [toml++](https://github.com/marzer/tomlplusplus) — MIT 许可证
  * [Simple DirectMedia Layer (SDL2)](https://www.libsdl.org/) — zlib 许可证
  * [arm-recomp-core](https://github.com/mstan/arm-recomp-core) — MIT 许可证
  * mGBA 衍生的 BIOS HLE 源码 — MPL-2.0 许可证（打包于 `licenses/mpl-source/`）
  * 字体资产（*LatoLatin*, *OpenMoji*, *NotoSansSymbols2*）— OFL-1.1 / CC BY-SA 4.0（详见 `licenses/`）
  * MinGW-w64 / GCC 运行库（`libgcc`, `libstdc++`, `libwinpthread`）— GPLv3 附带 GCC Runtime Library Exception / MinGW 许可条款
* 详细第三方许可清单参见 [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)。

---

## 免责声明

*Mario & Luigi: Superstar Saga*（马力欧与路易吉RPG）、*Mario*、*Luigi*、*Bowser* 及所有相关角色资产均为 **任天堂（Nintendo Co., Ltd.）** 及 **AlphaDream** 的注册商标与版权财产。

本项目为独立的非商业性软件工程与数字保存研究项目，与任天堂及 AlphaDream 没有任何关联，亦未获得其官方授权或赞助。本仓库严禁且不包含任何商业 ROM 镜像或受版权保护的专属数据。
