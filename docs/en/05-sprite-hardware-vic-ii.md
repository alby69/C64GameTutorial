# Chapter 5 — VIC-II Hardware Sprites

## Objectives

By the end of this chapter you will know:

- What C64 sprites are
- The registers for controlling sprites
- How to create sprite data
- How to display the first sprite
- How to assign color and position

---

## 5.1 What is a sprite

A sprite is an independent image that the VIC-II draws without needing to rewrite video memory. Each sprite:

```
Width:       24 pixels
Height:      21 pixels
Size:        63 bytes (21 rows × 3 bytes)
Number:      8 hardware sprites (0-7)
```

```
+----------------------------+
|                            |
|         24 pixels          |
|                            |
+----------------------------+
         21 lines
```

Each row = 24 bits = 3 bytes. A bit = 1 on, 0 off.

```
Byte 0        Byte 1        Byte 2
┌──────────┐ ┌──────────┐ ┌──────────┐
│xxxxxxxx  │ │xxxxxxxx  │ │xxxxxxxx  │  ← row 0
│xxxxxxxx  │ │xxxxxxxx  │ │xxxxxxxx  │  ← row 1
│...       │ │...       │ │...       │  ← ...
│xxxxxxxx  │ │xxxxxxxx  │ │xxxxxxxx  │  ← row 20
└──────────┘ └──────────┘ └──────────┘
PPHHHHHH    PPHHHHHH    PPHHHHHH
P = pixels 0-1, H = pixels 2-7
```

---

## 5.2 Main sprite registers

### Coordinates

```
Sprite 0: X = $D000  Y = $D001
Sprite 1: X = $D002  Y = $D003
Sprite 2: X = $D004  Y = $D005
Sprite 3: X = $D006  Y = $D007
Sprite 4: X = $D008  Y = $D009
Sprite 5: X = $D00A  Y = $D00B
Sprite 6: X = $D00C  Y = $D00D
Sprite 7: X = $D00E  Y = $D00F
```

### Enable (`$D015`)

Each bit controls one sprite:

```
Bit 0 = Sprite 0   Bit 4 = Sprite 4
Bit 1 = Sprite 1   Bit 5 = Sprite 5
Bit 2 = Sprite 2   Bit 6 = Sprite 6
Bit 3 = Sprite 3   Bit 7 = Sprite 7
```

```asm
LDA #%00000001   ; enable only Sprite 0
STA $D015
```

### Sprite color

```
Sprite 0: $D027   Sprite 4: $D02B
Sprite 1: $D028   Sprite 5: $D02C
Sprite 2: $D029   Sprite 6: $D02D
Sprite 3: $D02A   Sprite 7: $D02E
```

```asm
LDA #1           ; white
STA $D027        ; sprite 0 color
```

---

## 5.3 Where to put sprite data

Sprites are not defined in VIC-II registers. Data goes in RAM and the VIC-II reads it through a **pointer**.

```
Sprite data → RAM (e.g. $3000)
                   ↓
Sprite pointer → $07F8 (for sprite 0)
                   ↓
VIC-II reads data and draws the sprite
```

### The 64 bytes of a sprite

The data address must be a multiple of 64 (aligned).

```
Pointer = address ÷ 64

Example: $3000 = 12288
12288 ÷ 64 = 192

LDA #192
STA $07F8   ; sprite 0 points to $3000
```

---

## 5.4 Sprite Pointer Table

With screen RAM at `$0400`, pointers are at `$07F8`-`$07FF`:

```
$07F8 → Sprite 0
$07F9 → Sprite 1
$07FA → Sprite 2
$07FB → Sprite 3
$07FC → Sprite 4
$07FD → Sprite 5
$07FE → Sprite 6
$07FF → Sprite 7
```

---

## 5.5 First sprite displayed

Here's the complete program to see a sprite on screen:

```asm
*=$8000

START
    ; Enable sprite 0
    LDA #%00000001
    STA $D015

    ; White color
    LDA #1
    STA $D027

    ; Initial position
    LDA #100
    STA $D000       ; X = 100
    STA $D001       ; Y = 100

    ; Pointer to $3000 (192 = 12288/64)
    LDA #192
    STA $07F8

LOOP
    JMP LOOP

; ----------------------------------
; Sprite data at $3000
; ----------------------------------
*=$3000

SPRITE_DATA
    .byte 0,0,0
    .byte 0,60,0
    .byte 0,126,0
    .byte 255,255,255
    .byte 255,255,255
    .byte 0,126,0
    .byte 0,60,0
    .byte 0,24,0
    .byte 0,0,0
    .byte 0,0,0
    .byte 0,0,0
    .byte 0,0,0
    .byte 0,0,0
    .byte 0,0,0
    .byte 0,0,0
    .byte 0,0,0
    .byte 0,0,0
    .byte 0,0,0
    .byte 0,0,0
    .byte 0,0,0
    .byte 0,0,0
```

> **Warning:** the file must be assembled all together. TMP handles the two sections `*=$8000` and `*=$3000` in the same source.

---

## 5.6 Drawing your own sprite

Each byte represents 8 horizontal pixels. Bit 1 = pixel on, Bit 0 = off.

### Drawing tool

Use grid paper 24×21 and convert each row into 3 bytes:

```
Row 0:  00000000 00000000 00000000  → .byte 0,0,0
Row 1:  00011000 00100100 00011000  → .byte $18,$24,$18
Row 2:  00111100 01000010 00111100  → .byte $3C,$42,$3C
...
```

### Visual calculator

```
Bit: 7 6 5 4 3 2 1 0
     x x x x x x x x
     | | | | | | | |
    128 64 32 16 8 4 2 1

00011000 = 16+8 = 24 = $18
00100100 = 32+4 = 36 = $24
```

---

## 5.7 Organizing multiple sprites

To manage multiple sprites in an organized way:

```asm
; Enable sprites 0 and 1
LDA #%00000011
STA $D015

; Colors
LDA #1
STA $D027       ; sprite 0 white
LDA #7
STA $D028       ; sprite 1 yellow

; Positions
LDA #50
STA $D000       ; sprite 0 X
LDA #100
STA $D002       ; sprite 1 X

LDA #80
STA $D001       ; sprite 0 Y
LDA #80
STA $D003       ; sprite 1 Y

; Pointers
LDA #192
STA $07F8       ; sprite 0 → $3000
INC             ; 193
STA $07F9       ; sprite 1 → $3040 (192+1)*64 = $3040
```

---

## 5.8 Sprite register summary

| Register | Function |
|---|---|
| `$D000`-`$D00F` | X/Y coordinates sprites 0-7 |
| `$D010` | MSB X (bits 0-7 for sprites 0-7) |
| `$D015` | Sprite enable |
| `$D017` | Vertical expansion (bits 0-7) |
| `$D01B` | Sprite background priority |
| `$D01C` | Sprite multicolor |
| `$D01D` | Horizontal expansion (bits 0-7) |
| `$D027`-`$D02E` | Sprite colors 0-7 |
| `$07F8`-`$07FF` | Sprite pointer |

---

## Exercises

### Exercise 1
Display a spaceship-shaped sprite (16×16 pixels centered in the 24×21 area) at the center of the screen.

### Exercise 2
Create two sprites: one white on the left, one red on the right.

### Exercise 3
Hand-draw an alien 24×21 on grid paper, convert to bytes, and display it.

### Exercise 4
Assign Sprite 0 data at $3100 (calculate the correct pointer).

### Exercise 5
Display a sprite whose color changes every loop iteration, cycling through all 16 available colors.

---

## Summary

You have learned:

- What VIC-II sprites are
- Control registers (position, color, enable)
- Sprite pointers ($07F8-$07FF) and address÷64 calculation
- How to organize 63-byte sprite data
- Displaying the first sprite on screen

## References

- [Chapter 6 — Sprite movement](06-sprite-movement-control.md) — animation, MSB, multicolor
- [Chapter 16 — Sprite multiplexing](16-sprite-multiplexing.md) — managing 8+ sprites
- [Solutions](../soluzioni/cap05-sprite.asm) — exercise solutions
