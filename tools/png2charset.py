#!/usr/bin/env python3
"""
png2charset.py — Utility to convert 8x8 PNG tiles into C64 assembly/binary charset data.
"""

import os
import sys
from PIL import Image

def png_to_charset(png_path, threshold=128):
    im = Image.open(png_path).convert('L')
    width, height = im.size

    bytes_data = []
    # Process 8x8 tiles
    for ty in range(0, height, 8):
        for tx in range(0, width, 8):
            for y in range(8):
                byte_val = 0
                for x in range(8):
                    px = im.getpixel((tx + x, ty + y))
                    bit = 1 if px < threshold else 0
                    byte_val = (byte_val << 1) | bit
                bytes_data.append(byte_val)
    return bytes_data

def main():
    if len(sys.argv) < 2:
        print("Usage: python3 png2charset.py <input.png> [output.asm/bin]")
        sys.exit(1)

    infile = sys.argv[1]
    outfile = sys.argv[2] if len(sys.argv) > 2 else "charset.asm"

    data = png_to_charset(infile)
    if outfile.endswith(".asm"):
        with open(outfile, "w") as f:
            f.write("// Converted Charset Data (8x8 tiles)\nCHARSET:\n")
            for i in range(0, len(data), 8):
                chunk = data[i:i+8]
                f.write("    .byte " + ", ".join(f"${b:02x}" for b in chunk) + "\n")
    else:
        with open(outfile, "wb") as f:
            f.write(bytes(data))
    print(f"Converted {infile} -> {outfile} ({len(data)} bytes)")

if __name__ == "__main__":
    main()
