#!/usr/bin/env python3
"""png2sprite.py — Converte PNG in dati sprite C64 (.asm)

Utilizzo:
  python3 tools/png2sprite.py input.png -o output.asm
  python3 tools/png2sprite.py input.png -o output.asm --multicolor --name SPR_MYSHIP

Opzioni:
  -o, --output FILE     File output .asm (default: stdout)
  -n, --name NAME       Nome del label assembly (default: SPR_DATA)
  -m, --multicolor      Modalita multicolor (12x21 px input)
  --color0 HEX          Colore trasparente (default: 000000)
  --color1 HEX          Colore 1 / sprite color (default: ffffff)
  --color2 HEX          Colore 2 multicolor (default: ff0000)
  --color3 HEX          Colore 3 multicolor (default: 0000ff)
"""

import sys
import os

try:
    from PIL import Image
except ImportError:
    print("Errore: Pillow non installato. 'pip install Pillow'", file=sys.stderr)
    sys.exit(1)


def rgb_to_c64(r, g, b):
    """Approssima RGB al colore C64 piu vicino."""
    colors = [
        (0, 0, 0), (255, 255, 255), (136, 0, 0), (170, 255, 238),
        (204, 68, 204), (0, 204, 85), (0, 0, 170), (238, 238, 119),
        (221, 136, 85), (102, 68, 0), (255, 119, 119), (119, 119, 119),
        (170, 255, 102), (0, 204, 255), (187, 187, 255), (187, 187, 187),
    ]
    best = 0
    best_dist = 999999
    for i, (cr, cg, cb) in enumerate(colors):
        d = (r - cr) ** 2 + (g - cg) ** 2 + (b - cb) ** 2
        if d < best_dist:
            best_dist = d
            best = i
    return best


def parse_hex(s):
    s = s.lstrip("#")
    return tuple(int(s[i:i+2], 16) for i in (0, 2, 4))


def print_preview(pixels, w, h, multicolor, c0, c1, c2, c3):
    """Stampa una preview ASCII dello sprite nel terminale."""
    chars = {0: " ", 1: "█", 2: "▒", 3: "░"}
    if multicolor:
        print("\nPreview Sprite (Multicolor):")
        for row in range(h):
            line = ""
            for col in range(w):
                r, g, b, a = pixels[row * w + col]
                if a < 128 or (r, g, b) == c0: bits = 0
                elif (r, g, b) == c1: bits = 1
                elif (r, g, b) == c2: bits = 2
                else: bits = 3
                line += chars[bits] * 2  # Double width for better aspect ratio
            print(line)
    else:
        print("\nPreview Sprite (HIRES):")
        for row in range(h):
            line = ""
            for col in range(w):
                r, g, b, a = pixels[row * w + col]
                if a < 128 or (r, g, b) in (c0, (0, 0, 0)): bit = 0
                else: bit = 1
                line += chars[bit]
            print(line)
    print()


def convert_png_to_asm(input_path, name="SPR_DATA", multicolor=False, charset=False,
                       color0="000000", color1="ffffff", color2="ff0000", color3="0000ff"):
    """
    Funzione core per la conversione, utilizzabile come modulo.
    """
    img = Image.open(input_path).convert("RGBA")
    w, h = img.size

    if charset:
        if w % 8 != 0 or h % 8 != 0:
            raise ValueError("Modalità charset richiede dimensioni multiple di 8")
    elif multicolor:
        if w != 12 or h != 21:
            raise ValueError("Multicolor richiede 12x21 pixel")
    else:
        if w != 24 or h != 21:
            raise ValueError("HIRES richiede 24x21 pixel")

    c0 = parse_hex(color0)
    c1 = parse_hex(color1)
    c2 = parse_hex(color2)
    c3 = parse_hex(color3)

    pixels = list(img.getdata())

    output = []
    output.append(f"; Convertito da: {input_path}")
    output.append(f"; Formato: {'multicolor' if multicolor else 'HIRES'}")
    output.append(f"; Dimensioni: {w}x{h}")
    output.append("")

    if charset:
        output.append(f"{name}")
        for ty in range(0, h, 8):
            for tx in range(0, w, 8):
                output.append(f"; Tile {tx//8},{ty//8}")
                for py in range(8):
                    byte = 0
                    for px in range(8):
                        r, g, b, a = pixels[(ty + py) * w + (tx + px)]
                        bit = 1 if a >= 128 and (r, g, b) != c0 else 0
                        byte |= (bit << (7 - px))
                    output.append(f"    .byte %{byte:08b}")
    elif multicolor:
        output.append(f"{name}")
        for row in range(21):
            byte0 = byte1 = byte2 = 0
            for col in range(12):
                r, g, b, a = pixels[row * w + col]
                if a < 128 or (r, g, b) == c0: bits = 0
                elif (r, g, b) == c1: bits = 1
                elif (r, g, b) == c2: bits = 2
                else: bits = 3

                shift = (11 - col) * 2
                if shift >= 16: byte0 |= (bits << (shift - 16))
                elif shift >= 8: byte1 |= (bits << (shift - 8))
                else: byte2 |= (bits << shift)
            output.append(f"    .byte ${byte0:02X},${byte1:02X},${byte2:02X}")
    else:
        output.append(f"{name}")
        for row in range(21):
            byte0 = byte1 = byte2 = 0
            for col in range(24):
                r, g, b, a = pixels[row * w + col]
                bit = 0 if a < 128 or (r, g, b) in (c0, (0, 0, 0)) else 1
                shift = 23 - col
                if shift >= 16: byte0 |= (bit << (shift - 16))
                elif shift >= 8: byte1 |= (bit << (shift - 8))
                else: byte2 |= (bit << shift)
            output.append(f"    .byte %{byte0:08b},%{byte1:08b},%{byte2:08b}")

    output.append("")
    return "\n".join(output), pixels, w, h


def main():
    import argparse

    parser = argparse.ArgumentParser(description="Convert PNG to C64 sprite data")
    parser.add_argument("input", help="Input PNG file")
    parser.add_argument("-o", "--output", help="Output .asm file")
    parser.add_argument("-n", "--name", default="SPR_DATA", help="Label name")
    parser.add_argument("-m", "--multicolor", action="store_true", help="Multicolor mode (12x21)")
    parser.add_argument("--charset", action="store_true", help="Charset mode (8x8 chunks)")
    parser.add_argument("--color0", default="000000", help="Transparent color (hex)")
    parser.add_argument("--color1", default="ffffff", help="Sprite/color 1 (hex)")
    parser.add_argument("--color2", default="ff0000", help="Color 2 multicolor (hex)")
    parser.add_argument("--color3", default="0000ff", help="Color 3 multicolor (hex)")

    args = parser.parse_args()

    try:
        asm, pixels, w, h = convert_png_to_asm(
            args.input, args.name, args.multicolor, args.charset,
            args.color0, args.color1, args.color2, args.color3
        )
    except Exception as e:
        print(f"Errore: {e}", file=sys.stderr)
        sys.exit(1)

    c0 = parse_hex(args.color0)
    c1 = parse_hex(args.color1)
    c2 = parse_hex(args.color2)
    c3 = parse_hex(args.color3)

    print_preview(pixels, w, h, args.multicolor, c0, c1, c2, c3)

    if args.output:
        with open(args.output, "w") as f:
            f.write(asm)
        print(f"Scritto: {args.output} ({len(pixels)} pixel)", file=sys.stderr)
    else:
        print(asm)


if __name__ == "__main__":
    main()
