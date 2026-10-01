from pathlib import Path

ew = Path(r"D:\Project\GameRecomp\MarioLuigiSuperstarSagaRecomp\logs\ewram-s.bin").read_bytes()
iw = Path(r"D:\Project\GameRecomp\MarioLuigiSuperstarSagaRecomp\logs\iwram-s.bin").read_bytes()


def ew_u8(a):
    return ew[a - 0x02000000]


def ew_u16(a):
    o = a - 0x02000000
    return ew[o] | (ew[o + 1] << 8)


def ew_u32(a):
    o = a - 0x02000000
    return ew[o] | (ew[o + 1] << 8) | (ew[o + 2] << 16) | (ew[o + 3] << 24)


# Suitcase sprite from OPEN+0xD4
sp = 0x0203D2F8
print(f"Sprite @ {sp:08X}")
print(f"  +0x00 x,y s16 = {ew_u16(sp):04X} {ew_u16(sp+2):04X}")
print(f"  +0x04 x,y scale = {ew_u16(sp+4):04X} {ew_u16(sp+6):04X}")
print(f"  +0x08.. = {ew[sp-0x02000000+8:sp-0x02000000+16].hex()}")
f12 = ew_u8(sp + 0x12)
print(f"  +0x12 field_12 = 0x{f12:02X}  bit3(field_12_3)={bool(f12 & 8)} bits1-2(mode)={(f12>>1)&3} bit4={bool(f12&16)} bit5={bool(f12&32)}")
print(f"  +0x11 = 0x{ew_u8(sp+0x11):02X}")
print(f"  +0x20 step/int8 = {ew_u8(sp+0x20):02X} ({ew_u8(sp+0x20)})")
print(f"  +0x22 = {ew_u8(sp+0x22)}  +0x23 = {ew_u8(sp+0x23)}  +0x24 = {ew_u8(sp+0x24)}  +0x25 = {ew_u8(sp+0x25)}")
print(f"  +0x26 = {ew_u8(sp+0x26)}  +0x27 = {ew_u8(sp+0x27)}")
print(f"  +0x28 u16 = {ew_u16(sp+0x28):04X}")
print(f"  +0x38 ptr = {ew_u32(sp+0x38):08X}")
print(f"  +0x3C ptr = {ew_u32(sp+0x3C):08X}")
print(f"  +0x44 ptr = {ew_u32(sp+0x44):08X}")

# TitleScreen states at OPEN+0x80
print("\nTitleScreen OPEN+0x80:")
base = 0x0300214C
off = base - 0x03000000
print(f"  states bytes: {iw[off+0x80:off+0x86].hex()}")
print(f"  timer = {iw[off+0x86] | (iw[off+0x87]<<8)}")
print(f"  +0x88-0x9F: {iw[off+0x88:off+0xA0].hex()}")

# dump all 9 sprites field_12
print("\nall sprites field_12:")
names = ["PS_TEXT", "BEAN", "ML", "MB", "OPTS", "SUITCASE", "LICENSE", "SC_VIS", "SS_TEXT"]
for i, n in enumerate(names):
    p = ew_u32(0x0300214C + 0xC0 + i * 4)
    if 0x02000000 <= p < 0x02040000:
        f = ew_u8(p + 0x12)
        st = ew_u8(p + 0x20)
        print(f"  [{i}] {n:8} @{p:08X} field_12=0x{f:02X} bit3={bool(f&8)} step={st}")
