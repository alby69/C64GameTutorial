# Chapter 24 — Scrolling on the C64

## Objectives

By the end of this chapter you will know:

- Use VIC-II hardware scrolling registers
- Implement fine scrolling (1-8 pixels)
- Implement coarse scrolling (tilemap shift)
- Create smooth horizontal scrolling
- Handle split-screen with different scroll speeds
- Use vertical scrolling

---

## 24.1 VIC-II Scroll Registers

The VIC-II has two key registers for scrolling:

```
$D016 — horizontal control (bit 0-2: fine X scroll)
  bit 3:  0=38 columns, 1=40 columns
  bit 4:  1=multicolor mode
  bit 5-7: unused

$D011 — vertical control (bit 0-2: fine Y scroll)
  bit 3:  1=25 rows, 0=24 rows (ECM/BMM)
  bit 4:  1=character map at $2000
  bit 5:  1=bitmap mode
  bit 6:  1=extended color mode
  bit 7:  raster line MSB
```

### Typical values

```asm
; 40 columns, no scroll
LDA #%11001000
STA $D016

; 38 columns (border widens)
LDA #%11000000
STA $D016

; Horizontal scroll 3 pixels
LDA #%11001011
STA $D016
;               ^^^— fine scroll X (0-7)
```

---

## 24.2 Fine Horizontal Scrolling

Fine scrolling shifts the video content by 1-7 pixels left.

```asm
; Continuous horizontal scrolling
*= $C000

    ; Setup screen with a row of characters
    LDA #$01
    STA $D021           ; white background
    LDA #$0B
    STA $D020           ; gray border

    ; Write a row of text
    LDX #0
FILL
    LDA #$41            ; character "A"
    STA $0400+40*12,X
    INX
    CPX #40
    BNE FILL

    ; Scroll loop
SCROLL_LOOP
    ; Scroll from 0 to 7 pixels
    LDA SCROLL_X
    STA $D016           ; bit 0-2 = fine scroll

    INC SCROLL_X
    LDA SCROLL_X
    AND #7
    STA SCROLL_X

    ; Delay for visibility
    LDX #0
DELAY
    NOP
    NOP
    INX
    BNE DELAY

    JMP SCROLL_LOOP

SCROLL_X
    .byte 0
```

---

## 24.3 Scrolling with Raster Split

We can have different zones with different scroll values:

```asm
; Split screen: fixed HUD on top, scrollable area below
*= $C000

    SEI
    LDA #<SCROLL_IRQ
    STA $0314
    LDA #>SCROLL_IRQ
    STA $0315
    LDA #40             ; IRQ at line 40
    STA $D012
    LDA #1
    STA $D01A
    CLI

    ; Static HUD (40 columns)
    LDA #%11001000
    STA $D016

    JMP MAIN_LOOP

SCROLL_IRQ
    ; Change scroll for game area
    LDA SCROLL_VALUE
    ORA #%11001000
    STA $D016

    LDA $D019
    STA $D019
    RTI

MAIN_LOOP
    INC SCROLL_VALUE
    LDA SCROLL_VALUE
    AND #7
    STA SCROLL_VALUE

    ; Wait for frame
    LDA FRAME_CNT
WAIT
    CMP FRAME_CNT
    BEQ WAIT
    JMP MAIN_LOOP

SCROLL_VALUE
    .byte 0
FRAME_CNT
    .byte 0

; IRQ increments FRAME_CNT (code omitted for brevity)
```

---

## 24.4 Coarse Scrolling (Tilemap)

When fine scroll reaches 7, we must shift the map:

```asm
; Coarse scroll: shifts the entire screen RAM
COARSE_SCROLL
    LDA COARSE_X
    CMP #40            ; end of map?
    BEQ CS_RESET

    ; Shift screen RAM left by one column
    LDX #0
CS_LOOP
    LDA $0400+1,X      ; pick character to the right
    STA $0400,X        ; move it left
    LDA $D801,X
    STA $D800,X
    INX
    CPX #39*25-1
    BNE CS_LOOP

    ; Insert new column on the right
    ; (here: read from tilemap)
    LDA #$41           ; character "A"
    STA $0400+39
    LDA #5
    STA $D800+39

    INC COARSE_X
CS_RESET
    RTS

COARSE_X
    .byte 0
```

### Fine + coarse integration

```asm
UPDATE_SCROLL
    INC FINE_X
    LDA FINE_X
    AND #7
    STA FINE_X
    BNE US_DONE        ; no coarse needed

    JSR COARSE_SCROLL  ; every 8 pixels, shift map

US_DONE
    LDA FINE_X
    ORA #%11001000
    STA $D016
    RTS

FINE_X
    .byte 0
```

---

## 24.5 Vertical Scrolling

Vertical scrolling works like horizontal, but uses $D011 bit 0-2:

```asm
; Fine vertical scroll
VERTICAL_SCROLL
    INC FINE_Y
    LDA FINE_Y
    AND #7
    STA FINE_Y

    ; Prepare $D011 value
    LDA #$1B           ; 25 rows, bitmap off, screen $0400
    ORA FINE_Y         ; add fine Y scroll
    STA $D011
    RTS

FINE_Y
    .byte 0
```

For coarse vertical scroll, shift screen RAM rows up or down:

```asm
; Coarse vertical scroll (up)
COARSE_VERTICAL_UP
    LDX #0
CVU_LOOP
    LDA $0400+40,X     ; next row
    STA $0400,X        ; overwrite current row
    LDA $D800+40,X
    STA $D800,X
    INX
    CPX #40*24
    BNE CVU_LOOP

    ; New empty last row
    LDX #0
CVU_NEW
    LDA #$20
    STA $0400+40*24,X
    INX
    CPX #40
    BNE CVU_NEW
    RTS
```

---

## 24.6 Complete Smooth Scrolling

Combining fine + coarse scrolling gives smooth scrolling:

```asm
SMOOTH_SCROLL_UPDATE
    ; Increment fine X scroll
    INC SCROLL_FINE_X
    LDA SCROLL_FINE_X
    AND #7
    STA SCROLL_FINE_X
    BNE SS_APPLY

    ; Every 8 frames: shift map and increment tile counter
    JSR COARSE_SCROLL
    INC MAP_OFFSET

SS_APPLY
    LDA SCROLL_FINE_X
    ORA #%11001000
    STA $D016
    RTS

SCROLL_FINE_X
    .byte 0

MAP_OFFSET
    .byte 0
```

---

## 24.7 Parallax with Scroll

Two layers scrolling at different speeds:

```asm
; Parallax: background + foreground
; (using raster split to change scroll mid-screen)

PARALLAX_IRQ_1
    ; Top zone: sky (slow scroll)
    LDA SKY_SCROLL
    ORA #%11001000
    STA $D016

    LDA #<PARALLAX_IRQ_2
    STA $0314
    LDA #>PARALLAX_IRQ_2
    STA $0315
    LDA #100
    STA $D012

    LDA $D019
    STA $D019
    JMP $EA31

PARALLAX_IRQ_2
    ; Bottom zone: ground (fast scroll)
    LDA GROUND_SCROLL
    ORA #%11001000
    STA $D016

    LDA #<PARALLAX_IRQ_1
    STA $0314
    LDA #>PARALLAX_IRQ_1
    STA $0315
    LDA #0
    STA $D012

    LDA $D019
    STA $D019
    JMP $EA31

SKY_SCROLL
    .byte 0

GROUND_SCROLL
    .byte 0

GAME_LOOP
    ; Update scroll at different speeds
    INC SKY_SCROLL
    LDA SKY_SCROLL
    AND #7
    STA SKY_SCROLL

    INC GROUND_SCROLL
    INC GROUND_SCROLL     ; 2x faster!
    LDA GROUND_SCROLL
    AND #7
    STA GROUND_SCROLL

    JMP GAME_LOOP
```

---

## Summary

| Register | Controls | Bits |
|---|---|---|
| `$D016` | Fine horizontal scroll (0-7), 38/40 cols | 0-2: scroll X, 3: 40/38 col |
| `$D011` | Fine vertical scroll (0-7), 24/25 rows, modes | 0-2: scroll Y |
| `$D012` | Raster line for IRQ (used for split) | 0-7: line |
| Screen RAM | Character shift for coarse scroll | — |

---

## Exercises

### Exercise 1
Write a program that scrolls a row of characters right to left using only $D016 (fine scroll).

### Exercise 2
Add coarse scrolling: when fine scroll reaches 7, shift the screen RAM and reset.

### Exercise 3
Implement raster split: fixed HUD on top (40 columns) and scrollable game area below.

### Exercise 4
Create continuous vertical scrolling: a column of characters moving upward.

### Exercise 5
Implement 2-layer parallax with raster split: sky (slow scroll) and ground (fast scroll).

---

## References

- [Chapter 17 — Parallax](17-parallax-raster-split.md) — raster split and parallax foundation
- [Chapter 7 — Raster Interrupt](07-raster-interrupt.md) — IRQ setup for split
- [Appendix A](appendix-a-reference-tables.md) — VIC-II registers ($D016, $D011)
- [Solutions](../soluzioni/cap24-scrolling.asm) — exercise solutions
