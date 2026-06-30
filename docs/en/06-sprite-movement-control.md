# Chapter 6 — Sprite Movement and Control

## Objectives

By the end of this chapter you will know:

- Move a sprite with variables and loops
- Handle the X coordinate beyond 255
- Use expansion and multicolor
- Change animation frames
- Organize sprite data for a game

---

## 6.1 Moving a sprite with variables

We use a Zero Page variable for position:

```asm
SPRITE_X = $02
SPRITE_Y = $03

*=$8000

START
    LDA #%00000001
    STA $D015       ; enable sprite 0

    LDA #1
    STA $D027       ; white color

    LDA #192
    STA $07F8       ; pointer

    LDA #50
    STA SPRITE_X    ; initial X
    STA SPRITE_Y    ; initial Y

    STA $D000       ; update VIC
    STA $D001

MAINLOOP
    INC SPRITE_X    ; X++
    LDA SPRITE_X
    STA $D000       ; update VIC

    JSR DELAY
    JMP MAINLOOP

DELAY
    LDX #$20
D1
    LDY #$FF
D2
    DEY
    BNE D2
    DEX
    BNE D1
    RTS

*=$3000
SPRITE_DATA
    .byte 0,60,0
    .byte 0,126,0
    .byte 255,255,255
    .byte 255,255,255
    .byte 0,126,0
    .byte 0,60,0
    .byte 0,24,0
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

---

## 6.2 Moving with boundaries (bounce)

Let's add boundary checking:

```asm
SPRITE_X   = $02
DIRECTION  = $03   ; 0 = right, 1 = left

*=$8000

START
    LDA #%00000001
    STA $D015
    LDA #1
    STA $D027
    LDA #192
    STA $07F8

    LDA #50
    STA SPRITE_X
    STA $D000

    LDA #100
    STA $D001

    LDA #0         ; initial direction: right
    STA DIRECTION

MAINLOOP
    LDA DIRECTION
    BEQ MOVE_RIGHT

MOVE_LEFT
    DEC SPRITE_X
    LDA SPRITE_X
    CMP #10
    BCS CHECK_RIGHT
    LDA #0          ; invert
    STA DIRECTION
    JMP UPDATE_X

MOVE_RIGHT
    INC SPRITE_X
    LDA SPRITE_X
    CMP #240
    BCC UPDATE_X
    LDA #1          ; invert
    STA DIRECTION

UPDATE_X
    LDA SPRITE_X
    STA $D000

    JSR DELAY
    JMP MAINLOOP

DELAY
    LDX #$20
D1
    LDY #$FF
D2
    DEY
    BNE D2
    DEX
    BNE D1
    RTS
```

---

## 6.3 Handling X beyond 255 (MSB)

The screen is 320 pixels wide but X is only 8 bits (0-255). For values > 255 we need the MSB bit in `$D010`.

```
$D010 bit 0 = MSB for sprite 0 (1 = right side of screen)
```

```asm
SPRITE_X = $02
SPRITE_X_MSB = $03   ; 0 or 1 for right side

    ; Before updating, check
    LDA SPRITE_X
    CMP #255
    BCC NO_MSB

    ; X > 255: enable MSB and subtract 256
    LDA #%00000001
    STA $D010
    LDA SPRITE_X
    SEC
    SBC #256
    STA $D000
    JMP DONE

NO_MSB
    LDA #%11111110
    AND $D010       ; turn off MSB sprite 0
    STA $D010
    LDA SPRITE_X
    STA $D000

DONE
```

### Full version: sprite crossing the entire screen

```asm
SPRITE_X = $02

*=$8000

START
    LDA #%00000001
    STA $D015
    LDA #1
    STA $D027
    LDA #192
    STA $07F8

    LDA #0
    STA SPRITE_X
    STA $D000
    LDA #100
    STA $D001

MAINLOOP
    INC SPRITE_X

    ; MSB check
    LDA SPRITE_X
    CMP #100        ; beyond 100 handle MSB for testing
    BCS SET_MSB

    LDA #%11111110
    AND $D010
    STA $D010
    LDA SPRITE_X
    STA $D000
    JMP CONTINUE

SET_MSB
    LDA #%00000001
    STA $D010
    LDA SPRITE_X
    SEC
    SBC #100
    STA $D000

CONTINUE
    JSR DELAY
    JMP MAINLOOP

DELAY
    LDX #$10
D1
    LDY #$FF
D2
    DEY
    BNE D2
    DEX
    BNE D1
    RTS
```

---

## 6.4 Sprite expansion

### Horizontal expansion (`$D01D`)

```asm
LDA #%00000001    ; expand sprite 0 horizontally
STA $D01D
```

### Vertical expansion (`$D017`)

```asm
LDA #%00000001    ; expand sprite 0 vertically
STA $D017
```

### Both expansions

```asm
LDA #%00000001
STA $D01D
STA $D017         ; sprite 0 twice as big!
```

---

## 6.5 Multicolor sprite

Enable multicolor mode for a sprite:

```asm
LDA #%00000001    ; sprite 0 multicolor
STA $D01C
```

In multicolor each pair of bits defines a color:

```
Bit pair   Color
──────────────────────
00         Transparent
01         Sprite color ($D027)
10         Common color 1 ($D025)
11         Common color 2 ($D026)
```

### Multicolor setup

```asm
    LDA #%00000001
    STA $D01C       ; sprite 0 multicolor

    LDA #5
    STA $D025       ; common color 1 (green)

    LDA #7
    STA $D026       ; common color 2 (yellow)

    LDA #2
    STA $D027       ; sprite 0 color (red)
```

---

## 6.6 Animation: changing frame

We can change sprite data by modifying the pointer:

```asm
; Sprite 0: two animation frames
; Frame 0 at $3000 (pointer 192)
; Frame 1 at $3040 (pointer 193)

FRAME = $02

START
    LDA #%00000001
    STA $D015
    LDA #1
    STA $D027
    LDA #100
    STA $D000
    LDA #100
    STA $D001

    LDA #0
    STA FRAME

MAINLOOP
    LDA FRAME
    CLC
    ADC #192        ; base pointer + frame
    STA $07F8

    INC FRAME
    LDA FRAME
    AND #1          ; toggle 0/1
    STA FRAME

    JSR DELAY
    JMP MAINLOOP

*=$3000
; Frame 0: normal ship
FRAME0
    .byte 0,60,0
    .byte 0,126,0
    .byte 255,255,255
    ; ... (21 rows)

*=$3040
; Frame 1: ship with flames
FRAME1
    .byte 0,60,0
    .byte 0,126,0
    .byte 255,255,255
    ; ... (21 rows, different)
```

---

## 6.7 Professional sprite data organization

In real games, data is organized like this:

```
$3000 - $3FFF   Sprite data
   │
   ├─ $3000   Sprite 0, frame 0  (64 bytes)
   ├─ $3040   Sprite 0, frame 1  (64 bytes)
   ├─ $3080   Sprite 0, frame 2  (64 bytes)
   ├─ $30C0   Sprite 1, frame 0  (64 bytes)
   ├─ $3100   Sprite 1, frame 1  (64 bytes)
   └─ ...
```

Each sprite frame occupies exactly 64 bytes ($40).

```
Pointer for sprite 0 frame 2:  $3080 / 64 = 194
Pointer for sprite 1 frame 0:  $30C0 / 64 = 195
```

---

## Exercises

### Exercise 1
Move a sprite from left to right. When it reaches X=250, return to X=50.

### Exercise 2
Add Y-axis movement too: the sprite should move diagonally.

### Exercise 3
Create a sprite that changes color each time it touches a border.

### Exercise 4
Create a 4-frame animation for an alien flapping its wings. Change frame every 8 loop iterations.

### Exercise 5
Create 3 sprites aligned horizontally that move together as a formation.

---

## Summary

You have learned:

- Moving sprites with variables
- Handling bounce at screen edges
- Using `$D010` for X beyond 255 pixels
- Expanding sprites horizontally and vertically
- Using multicolor mode
- Animating sprites by changing pointers
- Organizing sprite frames in memory

## References

- [Chapter 5 — Hardware sprites](05-sprite-hardware-vic-ii.md) — sprite basics, pointers, registers
- [Chapter 9 — Joystick input](09-joystick-input.md) — controlling sprites with joystick
- [Chapter 16 — Sprite multiplexing](16-sprite-multiplexing.md) — multiple sprites
- [Solutions](../soluzioni/cap06-movimento-sprite.asm) — exercise solutions
