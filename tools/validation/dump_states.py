from pathlib import Path

iw = Path(r"D:\Project\GameRecomp\MarioLuigiSuperstarSagaRecomp\logs\iwram-s.bin").read_bytes()
ew = Path(r"D:\Project\GameRecomp\MarioLuigiSuperstarSagaRecomp\logs\ewram-s.bin").read_bytes()
base = 0x0300214C
off = base - 0x03000000
blob = iw[off:off + 0x100]
print("OPEN +0x1C..+0x100 (post-Process):")
for i in range(0x1C, 0x100, 16):
    hexs = " ".join(f"{b:02X}" for b in blob[i:i + 16])
    print(f"  +{i:03X}: {hexs}")

print("\nProcess state field =", iw[off])
print("brightness +0x1C =", blob[0x1C])
print("bitfields +0x1D =", f"{blob[0x1D]:02X}")

# try states at several candidate offsets
for so in (0x80, 0x7C, 0x84, 0x88, 0x70):
    print(f"states@+{so:02X}: {list(blob[so:so+6])} timer@+{so+6:02X}={blob[so+6]|(blob[so+7]<<8)}")

# sprites
print("\nsprite array +0xC0:")
names = ["PS_TEXT", "BEAN", "ML", "MB", "OPTS", "SUITCASE", "LICENSE", "SC_VIS", "SS_TEXT"]
for i, n in enumerate(names):
    p = blob[0xC0 + i * 4] | (blob[0xC1 + i * 4] << 8) | (blob[0xC2 + i * 4] << 16) | (blob[0xC3 + i * 4] << 24)
    if 0x02000000 <= p < 0x02040000:
        o = p - 0x02000000
        f12 = ew[o + 0x12]
        print(f"  [{i}] {n:8} @{p:08X} field_12=0x{f12:02X} bit3={bool(f12&8)} step@20={ew[o+0x20]}")
