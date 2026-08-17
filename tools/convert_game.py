import os
import re

INSTRUCTIONS = {
    "ADC", "AND", "ASL", "BCC", "BCS", "BEQ", "BIT", "BMI", "BNE", "BPL", "BRK", "BVC", "BVS",
    "CLC", "CLD", "CLI", "CLV", "CMP", "CPX", "CPY", "DEC", "DEX", "DEY", "EOR", "INC", "INX",
    "INY", "JMP", "JSR", "LDA", "LDX", "LDY", "LSR", "NOP", "ORA", "PHA", "PHP", "PLA", "PLP",
    "ROL", "ROR", "RTI", "RTS", "SBC", "SEC", "SED", "SEI", "STA", "STX", "STY", "TAX", "TAY",
    "TSX", "TXA", "TXS", "TYA"
}

def convert_line_comment(line):
    in_string = False
    comment_idx = -1
    for i, char in enumerate(line):
        if char == '"':
            in_string = not in_string
        elif char == ';' and not in_string:
            comment_idx = i
            break
    if comment_idx != -1:
        line = line[:comment_idx] + "//" + line[comment_idx+1:]
    return line

def convert_file(filepath):
    print(f"Converting {filepath}...")
    with open(filepath, "r", encoding="utf-8", errors="ignore") as f:
        lines = f.readlines()

    filename = os.path.basename(filepath)
    new_lines = []
    if filename != "main.asm":
        new_lines.append("#importonce\n")
    else:
        new_lines.append(":BasicUpstart2(START)\n")

    for line in lines:
        # Convert comment ; to //
        line = convert_line_comment(line)

        stripped = line.strip()
        if not stripped or stripped.startswith("//"):
            new_lines.append(line)
            continue

        # Convert equates NAME = $VAL to .const NAME = $VAL
        match_eq = re.match(r'^([A-Za-z0-9_]+)\s*=\s*(.*)', line)
        if match_eq:
            var_name = match_eq.group(1)
            var_val = match_eq.group(2)
            line = f".const {var_name} = {var_val}\n"
            new_lines.append(line)
            continue

        # Replace .include with #import
        if ".include" in line:
            line = re.sub(r'\.include\s+"([^"]+)"', r'#import "\1"', line)

        # Replace !byte, !word, !text, !fill with .byte, .word, .text, .fill
        line = re.sub(r'!(byte|word|text|fill)\b', r'.\1', line)

        # Handle .byte "STRING", $FF or .byte "STRING"
        match_str_byte = re.match(r'^(.*)\.byte\s+"([^"]+)"\s*,\s*(.*)', line)
        if match_str_byte:
            prefix = match_str_byte.group(1)
            string_val = match_str_byte.group(2)
            rest_bytes = match_str_byte.group(3)
            line = f'{prefix}.text "{string_val}"\n{prefix}.byte {rest_bytes}\n'
            new_lines.append(line)
            continue

        match_str_only = re.match(r'^(.*)\.byte\s+"([^"]+)"\s*$', line)
        if match_str_only:
            prefix = match_str_only.group(1)
            string_val = match_str_only.group(2)
            line = f'{prefix}.text "{string_val}"\n'
            new_lines.append(line)
            continue

        # In kernel.asm change * = $0800 to * = $0900 to avoid BASIC upstart overlap
        if filename == "kernel.asm" and "* = $0800" in line:
            line = line.replace("* = $0800", "* = $0900")

        # Convert instruction mnemonics to lowercase
        match_inst = re.match(r'^(\s*)([A-Za-z0-9_]+)(.*)', line)
        if match_inst:
            indent = match_inst.group(1)
            word = match_inst.group(2)
            rest = match_inst.group(3)

            if word.upper() in INSTRUCTIONS:
                line = f"{indent}{word.lower()}{rest}\n"
            elif indent == "" and not word.lower().startswith("const") and not word.lower().startswith("import") and not word.startswith("//") and not word.startswith(".pc") and not word.startswith("*"):
                rest_stripped = rest.strip()
                if not rest_stripped.startswith("=") and not rest_stripped.startswith(":"):
                    line = f"{word}:\n{indent}{rest}\n"

        new_lines.append(line)

    with open(filepath, "w", encoding="utf-8") as f:
        f.writelines(new_lines)

def main():
    game_dir = "game"
    files = [f for f in os.listdir(game_dir) if f.endswith(".asm")]
    for f in files:
        convert_file(os.path.join(game_dir, f))

if __name__ == "__main__":
    main()
