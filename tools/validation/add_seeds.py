rom_path = r"D:\Project\GameRecomp\MarioLuigiSuperstarSagaRecomp\Mario Luigi - Superstar Saga (USA).gba"
with open(rom_path, "rb") as f:
    rom = f.read()

toml_path = r"D:\Project\GameRecomp\MarioLuigiSuperstarSagaRecomp\game.toml"
with open(toml_path, "r", encoding="utf-8", errors="ignore") as f:
    toml_lines = f.readlines()

have = set()
for l in toml_lines:
    if "addr = 0x" in l:
        have.add(int(l.split("0x")[1].strip()[:8], 16))

to_add = []
for a in [0x08041368, 0x080415A0, 0x0804173C]:
    if a not in have:
        to_add.append((a, "thumb", "opening script"))

for a in range(0x08045000, 0x0804C000, 2):
    off = a - 0x08000000
    hw = int.from_bytes(rom[off:off+2], "little")
    if (hw & 0xFF00) == 0xB500:
        if a not in have:
            to_add.append((a, "thumb", "opening cutscene prologue"))

for a in [0x0801A434, 0x08055668, 0x080562B4, 0x08057160, 0x0805740C, 0x08048572]:
    if a not in have:
        to_add.append((a, "thumb", "missed target / shared epilogue"))

lines = ["\n# ---- 0x08045-0x0804B opening cutscene & misses ----\n"]
for a, m, note in to_add:
    lines.append("[[extra_func]]\n")
    lines.append(f"addr = 0x{a:08X}\n")
    lines.append(f'mode = "{m}"\n')
    lines.append(f'name = "tfunc_{a:x}"\n')
    lines.append(f'note = "{note}"\n\n')

with open(toml_path, "a", encoding="utf-8") as f:
    f.writelines(lines)

print(f"Successfully appended {len(to_add)} extra_func entries to game.toml")
