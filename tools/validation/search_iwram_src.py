from pathlib import Path
iwram = Path(r"D:\Project\GameRecomp\MarioLuigiSuperstarSagaRecomp\logs\iwram-900.bin").read_bytes()
rom = Path(r"D:\Project\GameRecomp\MarioLuigiSuperstarSagaRecomp\Mario Luigi - Superstar Saga (USA).gba").read_bytes()

def search(seed, label):
    hits = []
    start = 0
    while True:
        i = rom.find(seed, start)
        if i < 0:
            break
        hits.append(i + 0x08000000)
        start = i + 1
        if len(hits) >= 5:
            break
    print(f"{label}: seed={seed.hex()} hits={[hex(h) for h in hits]}")

# 8-byte seeds at each audio entry
for addr in (0x03001080, 0x0300111C, 0x0300117C):
    off = addr - 0x03000000
    search(iwram[off:off + 8], f"{addr:08x}+0")
    search(iwram[off + 1:off + 9], f"{addr:08x}+1")
    search(iwram[off + 2:off + 10], f"{addr:08x}+2")
    search(iwram[off + 4:off + 12], f"{addr:08x}+4")
    search(iwram[off + 5:off + 13], f"{addr:08x}+5")

# Also check if ROM at 0x0819A4B1 matches IWRAM 0x03001080 for more than 16 bytes
print("--- 0x0819A4B1 vs 0x03001080 ---")
rom_off = 0x19A4B1
iw_off = 0x1080
n = 0
while iw_off + n < 0x1200 and rom_off + n < len(rom) and iwram[iw_off + n] == rom[rom_off + n]:
    n += 1
print(f"match length from 0x0819A4B1: {n} (0x{n:x})")
print(f"rom 0x0819A4B1: {rom[rom_off:rom_off+16].hex()}")
print(f"iw  0x03001080: {iwram[iw_off:iw_off+16].hex()}")

# How far does the 0x03001080 blob go (until zeros or mismatch)?
print("--- 0x03001080 blob extent ---")
end = iw_off
while end < len(iwram) and iwram[end] != 0:
    end += 1
print(f"nonzero run ends at 0x{0x03000000+end:x} size=0x{end-iw_off:x}")
