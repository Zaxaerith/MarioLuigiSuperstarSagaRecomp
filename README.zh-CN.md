# MarioLuigiSuperstarSagaRecomp

[English](README.md) | [简体中文](README.zh-CN.md)

> **状态：Experimental Preview（实验性预览）**  
> 基于 [GBARecomp](https://github.com/Mr-Wiseguy/GBARecomp) 与反编译工程知识构建的《马力欧与路易吉RPG》（*Mario & Luigi: Superstar Saga*, USA, Game Code: A88E）原生 Windows x64 静态重编译移植版。

本仓库仅提供**游戏集成层**：重编译器配置、宿主集成、硬件绑定与构建自动化脚本。**绝不分发**受版权保护的游戏 ROM、GBA BIOS 固件镜像或任何 ROM 衍生的生成 C++ 代码。用户需自行在本地提供合法获取的原版游戏 ROM。

---

## 阶段成果与已验证状态

* [x] **纯净原生构建**：使用 MinGW-w64、CMake 与 Ninja 编译生成的 64 位 Windows 原生可执行文件（`MarioLuigiSuperstarSagaRecomp.exe`）。
* [x] **BIOS / 冷启动**：低级仿真（LLE）BIOS 重置路径、任天堂商标与 AlphaDream 制作方商标验证通过（`gba_bios.bin`）。
* [x] **标题画面与存档选择**：标题界面动画（"PRESS START"）、档案管理菜单及 New Game 新存档初始化流程验证通过。
* [x] **开篇流程与过场动画**：马力欧居所浴室动画、奇诺比奥报信、出门场景切换及桃花公主城堡探访与场景交互验证通过。
* [x] **库巴教学战斗**：回合制指令选择、马力欧跳跃 Action Command 精确判定、打击伤害计算、库巴 HP 归零结算与战败退场过场验证通过。
* [x] **战后平滑过渡**：战斗场景淡出、无缝切回大地图主循环进程（`FLDM`），且无任何 0x0 分发悬空崩溃，验证通过。
* [x] **存档硬件与持久化**：卡带 8 KB 串行 EEPROM 硬件签名自动识别，存档落盘与往返读取校验通过（`saves/mlss_usa.sav`）。

### 范围说明与未测试区域（社区测试）

本项目优先推进可玩集成与主干逻辑贯通，而非盲目追求纸面绝对覆盖率。以下区域留待社区玩家进行广泛体验与测试：
* 豆豆王国、呼呼山及后续章节的完整长篇战役通关。
* 后期首领战斗、高级兄弟合体技能与迷你游戏。
* *Mario Bros.* 经典内置副游戏集成。
* 各声音通道全场景听觉主观体验验证。

---

## 前置准备

1. **基础 ROM**：
   * *Mario & Luigi - Superstar Saga (USA)*
   * 游戏代码：`A88E`，版本修订：`0`
   * 文件大小：16,777,216 字节（`0x01000000`）
   * SHA-1：`7c303cdde5061ee329296948060b875cb50ba410`
   * MD5：`4b1a5897d89d9e74ec7f630eefdfd435`
   * 将 `.gba` 文件放置于项目根目录下，命名为 `Mario Luigi - Superstar Saga (USA).gba`。详见 [baserom.md](baserom.md)。
2. **GBA BIOS**：
   * 官方 GBA BIOS 固件镜像（`gba_bios.bin`，16,384 字节，SHA-1：`300c20df6731a33952ded8c436f7f186d25d3492`）。
3. **构建环境**：
   * Windows 10 / 11 64-bit
   * MinGW-w64（GCC 11+ 或支持 C++20 的 Clang）
   * CMake 3.20+ 与 Ninja
   * MinGW 版本的 SDL2 开发库（`x86_64-w64-mingw32`）
   * Python 3.10+（用于运行自动化验证脚本）
   * [GBARecomp](https://github.com/Mr-Wiseguy/GBARecomp) 框架及 CLI 代码生成器（`gba_recompile.exe`）

---

## 快速上手

### 1. 依赖就绪

运行自动化依赖脚本，检查或拉取所需组件：

```powershell
.\tools\setup-deps.ps1
```

### 2. 代码生成

运行自动化生成脚本，校验 ROM 完整性并生成静态重编译 C++ 代码：

```powershell
.\tools\regen.ps1
```

### 3. 项目编译

使用 CMake 与 Ninja 配置并编译原生可执行文件：

```powershell
cmake -S . -B build/host -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build build/host
```

编译产物位于 `build/host/MarioLuigiSuperstarSagaRecomp.exe`。

### 4. 运行游戏

直接启动重编译后的原生可执行文件：

```powershell
.\build\host\MarioLuigiSuperstarSagaRecomp.exe --rom "Mario Luigi - Superstar Saga (USA).gba" --bios "gba_bios.bin"
```

---

## 操作说明

### 默认键盘按键映射

| GBA 按键 | PC 默认按键 | 功能说明 |
|---|---|---|
| **方向键** | `W / A / S / D` 或 `↑ / ↓ / ← / →` | 角色移动 / 菜单选择 |
| **A 键** | `Z` / `J` | 确认 / 跳跃 / 交互 |
| **B 键** | `X` / `K` | 取消 / 次要动作 |
| **L 键** | `Q` / `U` | 动作切换 / 技能轮换 |
| **R 键** | `E` / `I` | 角色切换 / 技能轮换 |
| **START** | `Enter` | 暂停菜单 |
| **SELECT** | `Backspace` / `Tab` | 地图与手提箱 |

可在 `game.toml` 中自定义按键映射，原生支持 XInput / DirectInput 游戏手柄。

---

## 仓库结构

```text
MarioLuigiSuperstarSagaRecomp/
├── .gitattributes           # Git 换行符标准化配置
├── .gitignore               # 忽略 ROM、BIOS、存档、生成源码及编译树
├── CMakeLists.txt           # 构建规范，链接 GBARecomp 运行时与宿主层
├── LICENSE                  # PolyForm Noncommercial License 1.0.0
├── README.md                # 英文项目主文档
├── README.zh-CN.md          # 简体中文项目文档
├── THIRD_PARTY_NOTICES.md   # 第三方开源组件署名与许可审计
├── baserom.md               # ROM / BIOS 规格规范与哈希校验标准
├── docs/
│   └── ROM_IDENTITY.json    # 机器可读的 ROM 元数据与 SHA-1
├── game.toml                # 重编译器核心配置与运行时参数
├── src/
│   └── main.cpp             # 宿主入口点与硬件钩子
└── tools/
    ├── regen.ps1            # 基于哈希门禁的代码重新生成脚本
    ├── run-smoke.ps1        # 无头回归与冒烟测试运行器
    ├── setup-deps.ps1       # 依赖自动化检测与配置脚本
    └── validation/          # 确定性自动化回放测试脚本与分析工具
```

---

## 架构说明与致谢

* **静态重编译器与运行时**：基于 [GBARecomp](https://github.com/Mr-Wiseguy/GBARecomp)，提供精准的 GBA 硬件外设仿真、ARM/Thumb AOT 静态翻译与自愈式分发（Self-Healing Dispatch）。
* **反编译逆向工程参考**：感谢 `jellees` 及 [mlss](https://github.com/jellees/mlss) 逆向工程贡献者，为本项目的符号命名、进程调度结构（`ProcessDefinition`）与状态转移提供了关键依据。本仓库绝不包含未授权的反编译源码或商业游戏资源。
* 更多版权与第三方许可证详情见 [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)。

---

## 许可证 / License

本项目采用 **PolyForm Noncommercial License 1.0.0** — 详情请参阅 [LICENSE](LICENSE)。

PolyForm Noncommercial 1.0.0 — see [LICENSE](LICENSE).

Third-party components retain their respective licenses.

---

## 免责声明

*Mario & Luigi: Superstar Saga*（马力欧与路易吉RPG）、*Mario*、*Luigi*、*Bowser* 及相关角色资产均为 **任天堂（Nintendo Co., Ltd.）** 及 **AlphaDream** 的注册商标与版权财产。本项目为独立的非商业性软件工程研究项目，与任天堂及 AlphaDream 没有任何关联。
