from pathlib import Path
iwram = Path(r"D:\Project\GameRecomp\MarioLuigiSuperstarSagaRecomp\logs\iwram-900.bin").read_bytes()
rom = Path(r"D:\Project\GameRecomp\MarioLuigiSuperstarSagaRecomp\Mario Luigi - Superstar Saga (USA).gba").read_bytes()

for addr in (0x03001080, 0x0300111C, 0x0300117C, 0x03001070, 0x03001200):
    off = addr - 0x03000000
    chunk = iwram[off:off + 32]
    print(f"{addr:08x}: {chunk.hex()}  nonzero={sum(1 for x in chunk if x)}")

print("--- seed search ---")
for addr in (0x03001080, 0x0300111C, 0x0300117C):
    off = addr - 0x03000000
    seed = iwram[off:off + 16]
    if seed == b"\x00" * 16:
        print(f"{addr:08x}: all zero")
        continue
    idx = rom.find(seed)
    print(f"{addr:08x}: seed={seed.hex()} rom_match={idx if idx < 0 else hex(idx + 0x08000000)}")

print("--- verify known matches ---")
for a, r, n in [(0x3001edc, 0x081980d8, 16), (0x3002034, 0x08000534, 16), (0x30023d8, 0x08000850, 16)]:
    off = a - 0x03000000
    ro = r - 0x08000000
    ok = iwram[off:off + n] == rom[ro:ro + n]
    print(f"iwram {a:08x} == rom {r:08x}? {ok}")
    print(f"  iwram: {iwram[off:off+16].hex()}")
    print(f"  rom:   {rom[ro:ro+16].hex()}")
