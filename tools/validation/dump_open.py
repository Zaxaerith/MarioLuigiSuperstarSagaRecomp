from pathlib import Path
iw = Path(r"D:\Project\GameRecomp\MarioLuigiSuperstarSagaRecomp\logs\iwram-hold.bin").read_bytes()
base = 0x0300214C
off = base - 0x03000000
blob = iw[off:off + 0x180]
print("OPEN object dump:")
for i in range(0, len(blob), 16):
    hexs = " ".join(f"{b:02X}" for b in blob[i:i + 16])
    words = []
    for j in range(0, 16, 4):
        if i + j + 4 <= len(blob):
            w = blob[i + j] | (blob[i + j + 1] << 8) | (blob[i + j + 2] << 16) | (blob[i + j + 3] << 24)
            words.append(f"{w:08X}")
    joined = " ".join(words)
    print(f"  +{i:03X}: {hexs}  {joined}")

# Find likely Sprite* pointers (EWRAM 0x0200xxxx or IWRAM 0x0300xxxx)
print("\nlikely sprite pointers:")
for i in range(0, len(blob) - 3, 4):
    w = blob[i] | (blob[i + 1] << 8) | (blob[i + 2] << 16) | (blob[i + 3] << 24)
    if 0x02000000 <= w < 0x02040000 or 0x03000000 <= w < 0x03008000:
        print(f"  +{i:03X}: {w:08X}")
