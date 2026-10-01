with open('logs/iwram-undefined.bin', 'rb') as f:
    iwram = f.read()

base = 0x03000000
proc_addr = 0x0300214C

visited = set()
while proc_addr and proc_addr >= base and proc_addr < base + len(iwram) and proc_addr not in visited:
    visited.add(proc_addr)
    off = proc_addr - base
    state = iwram[off]
    priority = iwram[off+1]
    flag = int.from_bytes(iwram[off+2:off+4], 'little')
    frames = int.from_bytes(iwram[off+4:off+8], 'little')
    label = iwram[off+8:off+12].decode('ascii', errors='ignore')
    prev_p = int.from_bytes(iwram[off+12:off+16], 'little')
    next_p = int.from_bytes(iwram[off+16:off+20], 'little')
    parent_p = int.from_bytes(iwram[off+20:off+24], 'little')
    definition = int.from_bytes(iwram[off+24:off+28], 'little')
    print(f'Process at {hex(proc_addr)}: label="{label}" state={state} prio={priority} flag=0x{flag:x} frames={frames} def={hex(definition)} next={hex(next_p)}')
    proc_addr = next_p
