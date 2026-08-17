#!/usr/bin/env python3
import os
import re
import subprocess
import sys

OPCODES = {
    "adc", "and", "asl", "bcc", "bcs", "beq", "bit", "bmi", "bne", "bpl", "brk", "bvc", "bvs",
    "clc", "cld", "cli", "clv", "cmp", "cpx", "cpy", "dec", "dex", "dey", "eor", "inc", "inx",
    "iny", "jmp", "jsr", "lda", "ldx", "ldy", "lsr", "nop", "ora", "pha", "php", "pla", "plp",
    "rol", "ror", "rti", "rts", "sbc", "sec", "sed", "sei", "sta", "stx", "sty", "tax", "tay",
    "tsx", "txa", "txs", "tya"
}

DIRECTIVES = {
    "byte", "word", "text", "petscii", "fill", "import", "const", "var", "namespace", "pc",
    "struct", "macro", "filenamespace", "importonce", "basicupstart2", "segment", "segmentdef"
}

def convert_line(line):
    if not line.strip():
        return line

    in_quote = False
    comment_idx = -1
    for i, char in enumerate(line):
        if char == '"':
            in_quote = not in_quote
        elif char == ';' and not in_quote:
            comment_idx = i
            break

    if comment_idx != -1:
        comment_part = line[comment_idx+1:]
        line = line[:comment_idx] + "//" + comment_part

    stripped = line.strip()
    if not stripped or stripped.startswith("//"):
        return line

    # Convert Equate: NAME = VALUE -> .const NAME = VALUE
    eq_match = re.match(r'^([A-Za-z0-9_]+)\s*=\s*(.*)', line)
    if eq_match and not stripped.startswith("*") and not stripped.startswith(".pc"):
        var_name = eq_match.group(1)
        var_val = eq_match.group(2)
        indent = line[:line.find(var_name)]
        return f"{indent}.const {var_name} = {var_val}\n"

    # Replace .include with #import
    line = re.sub(r'\.include\s+"([^"]+)"', r'#import "\1"', line)

    # Replace .repeat N, VAL with .fill N, VAL
    line = re.sub(r'\.repeat\s+([^,]+),\s*(.*)', r'.fill \1, \2', line)

    # Replace .null "STRING" with .text "STRING"\n.byte $00
    null_match = re.search(r'\.null\s+"([^"]+)"', line)
    if null_match:
        str_val = null_match.group(1)
        line = re.sub(r'\.null\s+"[^"]+"', f'.text "{str_val}"\n.byte $00', line)

    # Remove * = $C000 line as segmentdef sets start address
    if re.match(r'^\s*\*=\s*\$[0-9A-Fa-f]+', line) or re.match(r'^\s*\*\s*=\s*\$[0-9A-Fa-f]+', line):
        return "// " + line

    # Convert opcodes to lowercase
    def replace_op(match):
        op = match.group(0)
        if op.lower() in OPCODES:
            return op.lower()
        return op

    line = re.sub(r'\b([A-Za-z]{3})\b', replace_op, line)

    # Add colon to labels
    m_label = re.match(r'^(\s*)([A-Za-z0-9_]+)(\s*)(.*)', line)
    if m_label:
        indent = m_label.group(1)
        word = m_label.group(2)
        space = m_label.group(3)
        rest = m_label.group(4)

        if (word.lower() not in OPCODES and
            word.lower() not in DIRECTIVES and
            not word.startswith(".") and
            not word.startswith("#") and
            not word.startswith("*") and
            not word.startswith("//")):

            if not word.endswith(":"):
                first_rest_word = rest.split()[0].lower() if rest and rest.split() else ""
                if not rest or rest.startswith("//") or first_rest_word in OPCODES or first_rest_word in DIRECTIVES or first_rest_word.startswith("."):
                    line = f"{indent}{word}:{space}{rest}\n"

    return line

def process_file(src_path, dst_path):
    with open(src_path, 'r', encoding='utf-8', errors='ignore') as f:
        lines = f.readlines()

    converted_lines = [convert_line(l) for l in lines]

    # Collect .const statements
    top_consts = []
    seen_const_names = set()

    for line in converted_lines:
        stripped = line.strip()
        if stripped.startswith(".const "):
            m = re.match(r'\.const\s+([A-Za-z0-9_]+)\s*=\s*(.*)', stripped)
            if m:
                cname = m.group(1)
                cval = m.group(2)
                if cname not in seen_const_names:
                    seen_const_names.add(cname)
                    top_consts.append(f".const {cname} = {cval}\n")

    ex_count = sum(1 for l in converted_lines if "ESERCIZIO" in l.strip() and ("---" in l or "//" in l))
    if ex_count == 0:
        ex_count = 1

    out_lines = ["// Converted to Kick Assembler syntax\n"]
    for i in range(1, ex_count + 1):
        out_lines.append(f".segmentdef Ex{i} [start=$c000]\n")
    out_lines.append("\n// --- Shared Constants ---\n")
    out_lines.extend(top_consts)
    out_lines.append("\n")

    ex_counter = 0
    in_namespace = False

    for line in converted_lines:
        stripped = line.strip()

        if stripped.startswith(".const "):
            m = re.match(r'\.const\s+([A-Za-z0-9_]+)\s*=', stripped)
            if m and m.group(1) in seen_const_names:
                continue

        if "ESERCIZIO" in stripped and ("---" in stripped or "//" in stripped):
            if in_namespace:
                out_lines.append("}\n\n")
                in_namespace = False

            ex_counter += 1
            out_lines.append(line)
            out_lines.append(f".segment Ex{ex_counter}\n")
            out_lines.append(f".namespace Ex{ex_counter} {{\n")
            in_namespace = True
            continue

        if in_namespace:
            out_lines.append("    " + line)
        else:
            out_lines.append(line)

    if in_namespace:
        out_lines.append("}\n")

    os.makedirs(os.path.dirname(dst_path), exist_ok=True)
    with open(dst_path, 'w', encoding='utf-8') as f:
        f.writelines(out_lines)

def fix_missing_symbols(dst_path):
    for pass_idx in range(10):
        res = subprocess.run(["java", "-jar", "tools/KickAss.jar", "-o", "/tmp/test.prg", dst_path], capture_output=True, text=True)
        if res.returncode == 0:
            break

        missing_syms = set()
        for l in res.stdout.split("\n"):
            m = re.search(r"Unknown symbol '([A-Za-z0-9_]+)'", l)
            if m:
                missing_syms.add(m.group(1))

        if not missing_syms:
            break

        with open(dst_path, 'r', encoding='utf-8') as f:
            content = f.read()

        added_aliases = []
        for sym in missing_syms:
            # Find which namespace contains sym
            m_def = re.search(r'\b(Ex\d+)\b[^{}]*\{[^{}]*\b' + re.escape(sym) + r':', content)
            if m_def:
                ns = m_def.group(1)
                added_aliases.append(f".const {sym} = {ns}.{sym}\n")
            else:
                # Search anywhere for label
                m_any = re.search(r'\b(Ex\d+)\b.*?\b' + re.escape(sym) + r':', content, re.DOTALL)
                if m_any:
                    ns = m_any.group(1)
                    added_aliases.append(f".const {sym} = {ns}.{sym}\n")
                else:
                    added_aliases.append(f".const {sym} = $00\n")

        if added_aliases:
            lines = content.split("\n")
            idx = 0
            for i, l in enumerate(lines):
                if "// --- Shared Constants ---" in l:
                    idx = i + 1
                    break
            lines[idx:idx] = [a.strip() for a in added_aliases]
            with open(dst_path, 'w', encoding='utf-8') as f:
                f.write("\n".join(lines))

def main():
    sol_dir = "soluzioni"
    out_dir = os.path.join(sol_dir, "kickass")
    os.makedirs(out_dir, exist_ok=True)

    files = [f for f in os.listdir(sol_dir) if f.endswith(".asm")]
    for f in sorted(files):
        src = os.path.join(sol_dir, f)
        dst = os.path.join(out_dir, f)
        print(f"Migrating {src} -> {dst}")
        process_file(src, dst)
        fix_missing_symbols(dst)

if __name__ == "__main__":
    main()
