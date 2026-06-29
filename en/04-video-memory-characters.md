# Chapter 4 — Video Memory and Characters

## Objectives

By the end of this chapter you will know:

- How the C64's video memory works
- Write text to the screen with position formulas
- Use colors in an advanced way
- Create static screens for menus and HUDs
- Build simple text animations

---

## 4.1 Text screen layout

The C64 in text mode displays:

```
40 columns × 25 rows = 1000 characters
```

### Video memory map

```
Address          Content
─────────────────────────────────────
$0400-$0427      Row 0 (columns 0-39)
$0428-$044F      Row 1
$0450-$0477      Row 2
...              ...
$07C0-$07E7      Row 24 (last)
```

### Corresponding color address

```
Color of char at $0400 → $D800
Color of char at $0428 → $D828
                  ...               ...
Formula: $D800 + offset = $D800 + (char_address - $0400)
```

---

## 4.2 Calculating the screen position

### Complete formula

```
offset  = (row × 40) + column
char_address = $0400 + offset
color_address = $D800 + offset
```

### Examples

| Row | Column | Offset | Character | Color |
|---|---|---|---|---|
| 0 | 0 | 0 | `$0400` | `$D800` |
| 0 | 39 | 39 | `$0427` | `$D827` |
| 12 | 20 | 500 | `$05F4` | `$D9F4` |
| 24 | 0 | 960 | `$07C0` | `$DBC0` |
| 24 | 39 | 999 | `$07E7` | `$DBE7` |

---

## 4.3 Writing a string to screen

```asm
*=$8000

START
    LDX #0
LOOP
    LDA TEXT,X      ; read character
    BEQ DONE        ; if 0, end of string
    STA $0400,X     ; write to screen
    INX
    JMP LOOP

DONE
    JMP DONE

TEXT
    .byte 1, 0      ; "A" + terminator (0)
```

### Longer string

```asm
TEXT
    .byte 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
    .byte 11, 12, 13, 14, 15, 16, 17, 18
    .byte 19, 20, 21, 22, 23, 24, 25, 26
    .byte 0          ; terminator
```

---

## 4.4 Writing to a specific row

```asm
*=$8000

; Writes "CIAO" at row 12, column 18

START
    LDA #1          ; C
    STA $05F2       ; $0400 + (12*40) + 18 = $05F2

    LDA #9          ; I (PETSCII)
    STA $05F3

    LDA #1          ; A
    STA $05F4

    LDA #15         ; O (PETSCII)
    STA $05F5

    ; Colors: all yellow
    LDA #7
    STA $D9F2
    STA $D9F3
    STA $D9F4
    STA $D9F5

LOOP
    JMP LOOP
```

> **Note:** PETSCII codes may differ from standard ASCII. The letter 'A' = 1, 'B' = 2, etc. Consult a PETSCII table.

---

## 4.5 HUD: creating an information panel

Many games have a HUD (Heads-Up Display) at the top or bottom. Here's how to create borders and text:

```asm
*=$8000

START
    JSR DRAW_HUD
LOOP
    JMP LOOP

DRAW_HUD
    ; Color the entire first row blue on yellow
    LDX #0
HUD_LOOP
    LDA #$20        ; full space (char 32)
    STA $0400,X     ; first row

    LDA #1          ; white color for border
    STA $D800,X
    INX
    CPX #40
    BNE HUD_LOOP

    ; Write "SCORE: 0000" starting from row 0, col 2
    LDA #19         ; S
    STA $0402
    LDA #3          ; C
    STA $0403
    LDA #15         ; O
    STA $0404
    LDA #18         ; R
    STA $0405
    LDA #5          ; E
    STA $0406
    LDA #26         ; :
    STA $0407

    RTS
```

---

## 4.6 Simple text animation

Let's make a message flash by modifying the color:

```asm
*=$8000

START
    LDA #0
    STA $D020       ; black border

    ; Write a fixed message
    LDA #1
    STA $0540       ; row 5, col 0
    LDA #2
    STA $0541
    LDA #3
    STA $0542
    LDA #4
    STA $0543
    ; ... more characters ...

LOOP
    INC $D800       ; animate first character's color
    JSR DELAY
    JMP LOOP

DELAY
    LDX #$30
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

## 4.7 Clearing the screen (CLS)

Universal routine to clear the screen:

```asm
CLEAR_SCREEN
    LDX #0
    TXA             ; A = 0
CLS_LOOP
    STA $0400,X
    STA $0500,X
    STA $0600,X
    STA $06E8,X     ; up to $07E8 (1000 bytes)
    INX
    CPX #250        ; 4 × 250 = 1000
    BNE CLS_LOOP
    RTS
```

---

## 4.8 Writing numbers to screen

To display a score you need to convert a number into characters:

```asm
; Converts value in A (0-99) into two characters and writes them
; at $0400 (tens) and $0401 (units)

WRITE_NUMBER
    LDX #0          ; tens counter
DIV_LOOP
    CMP #10
    BCC DONE_DIV
    SBC #10
    INX
    JMP DIV_LOOP

DONE_DIV
    ; X = tens, A = units
    TXA
    CLC
    ADC #$30        ; convert to PETSCII digit
    STA $0400

    TYA             ; recover units
    CLC
    ADC #$30
    STA $0401
    RTS
```

> **Note:** PETSCII digits 0-9 correspond to codes $30-$39.

---

## 4.9 Combining text and sprites

In games, text and sprites coexist. Here's an example that prepares the screen and then enters the game loop:

```asm
*=$8000

; ---- Variables ----
SCORE       = $02
SCORE_TXT   = $03   ; pointer for conversions

; ---- Program ----
START
    JSR CLEAR_SCREEN
    JSR DRAW_HUD
    JSR INIT_PLAYER

MAINLOOP
    JSR UPDATE
    JSR DRAW_SPRITES
    JMP MAINLOOP

CLEAR_SCREEN
    LDX #0
    LDA #$20        ; space
CLS
    STA $0400,X
    STA $0500,X
    STA $0600,X
    STA $06E8,X
    INX
    BNE CLS
    RTS

DRAW_HUD
    LDX #0
    LDA #$60        ; TOP border character
    STA $0400,X
    INX
    CPX #40
    BNE DRAW_HUD-2
    RTS

INIT_PLAYER
    ; ... player sprite setup ...
    RTS

UPDATE
    ; ... game logic ...
    RTS

DRAW_SPRITES
    ; ... sprite update ...
    RTS
```

---

## Exercises

### Exercise 1
Write your name at row 10, centered (calculate the starting column as `(40 - length) / 2`).

### Exercise 2
Create a "matrix" effect that makes random characters fall from the top to the bottom row.

### Exercise 3
Build a simple title screen with a decorated border and centered text "ARCADE GAME".

### Exercise 4
Write the number 42 (in decimal) at the top-right of the screen.

### Exercise 5
Create a "scrolling marquee" effect: write "HELLO" at row 0 and scroll it one position to the right every second.

---

## Summary

You have learned:

- The video memory layout (`$0400`-`$07E7`)
- Calculating positions with the formula `$0400 + row×40 + column`
- Coloring characters with `$D800 + offset`
- Creating a HUD
- Animating text by modifying colors
- Clearing the screen with loops
- Converting numbers for display

## References

- [Chapter 5 — Hardware sprites](05-sprite-hardware-vic-ii.md) — sprite pointers and display
- [Chapter 13 — Score and game states](13-score-game-states.md) — displaying score on screen
- [Solutions](../soluzioni/cap04-memoria-video.asm) — exercise solutions
