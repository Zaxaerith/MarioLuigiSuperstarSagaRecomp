import re

toml_path = r"D:\Project\GameRecomp\MarioLuigiSuperstarSagaRecomp\game.toml"
with open(toml_path, "r", encoding="utf-8", errors="ignore") as f:
    content = f.read()

# Remove the blocks with 0x03002120, 0x03002124, 0x030020BC
# Pattern for extra_func block
pattern = re.compile(r'\[\[extra_func\]\]\s*\naddr\s*=\s*0x0300(2120|2124|20BC)\b[^\n]*\n(?:[^\n]*\n)*?(?=\[\[|\Z)', re.MULTILINE)

new_content, count = pattern.subn('', content)
print(f"Removed {count} blocks.")

with open(toml_path, "w", encoding="utf-8") as f:
    f.write(new_content)

print("Updated game.toml successfully.")
