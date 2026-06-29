# Chapter 17 — Raster Split and Fake Depth (Parallax)

## Objectives

By the end of this chapter you will know:

- Use raster split for multi-zone effects
- Create fake parallax scrolling
- Change color and scroll mid-screen
- Separate the HUD from the game area
- Create the illusion of depth

---

## 17.1 Multi-Zone Raster Split

Raster split allows changing VIC-II registers **while** the screen is being drawn.

```
         ┌──────────────────────┐
Zone 0   │ HUD (background BLUE)│ ← IRQ 1 changes color
         │                      │
Zone 1   │ Game area            │ ← IRQ 2 changes scroll
         │ (background BLACK)   │
         │                      │
Zone 2   │ Info bar             │ ← IRQ 3 changes color
         │ (background GRAY)    │
         └──────────────────────┘
```

### 3-zone setup

```asm
INIT_SPLIT
    SEI
    LDA #$7F
    STA $DC0D

    LDA #<IRQ_SPLIT1
    STA $0314
    LDA #>IRQ_SPLIT1
    STA $0315

    LDA #40              ; HUD up to line 40
    STA $D012

    LDA $D011
    AND #$7F
    STA $D011

    LDA #1
    STA $D01A
    CLI
    RTS

; ----------------------------------
; IRQ 1: game area start
; ----------------------------------
IRQ_SPLIT1
    ; Change background for HUD (blue)
    LDA #6
    STA $D021

    ; Prepare next split
    LDA #200
    STA $D012
    LDA #<IRQ_SPLIT2
    STA $0314
    LDA #>IRQ_SPLIT2
    STA $0315

    LDA $D019
    STA $D019
    JMP $EA31

; ----------------------------------
; IRQ 2: bottom bar
; ----------------------------------
IRQ_SPLIT2
    ; Change background for info bar (gray)
    LDA #12
    STA $D021

    ; Return to IRQ 1 for next frame
    LDA #40
    STA $D012
    LDA #<IRQ_SPLIT1
    STA $0314
    LDA #>IRQ_SPLIT1
    STA $0315

    LDA $D019
    STA $D019
    JMP $EA31
```

---

## 17.2 HUD separated from game area

The HUD (Heads-Up Display) stays fixed while the game scrolls beneath:

```asm
; Setup: HUD zone (lines 0-39) and game zone (lines 40-199)

IRQ_SPLIT
    ; Arrived at line 40: game zone
    ; Change background color
    LDA #0
    STA $D021           ; black background for game

    ; If needed, switch character bank
    ; ... optional logic ...

    ; Re-install
    LDA #0
    STA $D012
    LDA #<IRQ_SPLIT_END
    STA $0314
    LDA #>IRQ_SPLIT_END
    STA $0315

    LDA $D019
    STA $D019
    JMP $EA31

IRQ_SPLIT_END
    ; End of screen: return HUD color
    LDA #6
    STA $D021

    LDA #40
    STA $D012
    LDA #<IRQ_SPLIT
    STA $0314
    LDA #>IRQ_SPLIT
    STA $0315

    LDA $D019
    STA $D019
    JMP $EA31
```

---

## 17.3 Scrolling with raster split

We can scroll the background differently for each zone:

```asm
; VIC-II scroll registers
; $D016: horizontal scroll (bits 0-2 = fine scroll, bit 3 = 40/38 columns)
; $D011: bits 4-5 = vertical fine scroll

IRQ_SCROLL
    ; Zone 0: no scroll (fixed HUD)
    LDA #$C8            ; 40 columns, scroll 0
    STA $D016

    ; Prepare zone 1 (game)
    LDA #100
    STA $D012
    LDA #<IRQ_SCROLL2
    STA $0314
    LDA #>IRQ_SCROLL2
    STA $0315

    LDA $D019
    STA $D019
    JMP $EA31

IRQ_SCROLL2
    ; Zone 1: variable horizontal scroll
    LDA SCROLL_X
    STA $D016           ; fine scroll

    ; Return to top
    LDA #0
    STA $D012
    LDA #<IRQ_SCROLL
    STA $0314
    LDA #>IRQ_SCROLL
    STA $0315

    LDA $D019
    STA $D019
    JMP $EA31
```

---

## 17.4 Fake Parallax Scrolling

The C64 doesn't have multilayer hardware scrolling. We simulate depth like this:

```
         Different speed for each "layer":
Layer 0 (sky):       very slow scroll (color change every 8 frames)
Layer 1 (mountains): slow scroll (change every 4 frames)
Layer 2 (ground):    normal scroll (every frame)
Layer 3 (sprites):   free movement (HW sprites)
```

```asm
; Every N frames, change the background to simulate movement

SCROLL_TIMER = $40
SCROLL_X    = $41

UPDATE_PARALLAX
    INC SCROLL_TIMER
    LDA SCROLL_TIMER
    AND #7                  ; every 8 frames
    BNE CHECK_MID

    ; Layer 0 (sky): change background color slowly
    LDA SKY_COLOR
    INC
    AND #15
    STA SKY_COLOR
    STA $D021

CHECK_MID
    LDA SCROLL_TIMER
    AND #3                  ; every 4 frames
    BNE DO_SCROLL

    ; Layer 1 (mid): change background characters
    ; ... logic to shift tiles ...

DO_SCROLL
    ; Layer 2 (ground): scroll every frame
    INC SCROLL_X
    LDA SCROLL_X
    AND #7
    STA $D016               ; VIC fine scroll

    RTS
```

---

## 17.5 Multi-color background per zone

Change the background color multiple times to create a "gradient sky" effect:

```asm
; Sky palette (8 colors for 8 zones)
SKY_PALETTE
    .byte 6, 6, 14, 1, 7, 7, 1, 14

IRQ_SKY
    LDX SKY_INDEX
    LDA SKY_PALETTE,X
    STA $D021

    INC SKY_INDEX
    LDA SKY_INDEX
    CMP #8
    BNE SKY_NEXT

    LDA #0
    STA SKY_INDEX

SKY_NEXT
    ; Next split line
    CLC
    LDA $D012
    ADC #4                  ; 4 lines later
    STA $D012

    ; Re-install itself
    LDA #<IRQ_SKY
    STA $0314
    LDA #>IRQ_SKY
    STA $0315

    LDA $D019
    STA $D019
    JMP $EA31
```

---

## 17.6 Complete game screen with split

```asm
*=$2000

START
    SEI
    JSR INIT_SPLIT
    JSR INIT_GAME
    CLI

MAINLOOP
    JMP MAINLOOP

INIT_SPLIT
    LDA #$7F
    STA $DC0D

    LDA #<IRQ_TOP
    STA $0314
    LDA #>IRQ_TOP
    STA $0315

    LDA #40
    STA $D012

    LDA $D011
    AND #$7F
    STA $D011

    LDA #1
    STA $D01A
    RTS

; ----------------------------------
; HUD (lines 0-39, blue background)
; ----------------------------------
IRQ_TOP
    PHA
    TXA
    PHA
    TYA
    PHA

    LDA #6
    STA $D021               ; blue background

    JSR DRAW_HUD

    ; Prepare game zone
    LDA #200
    STA $D012
    LDA #<IRQ_BOTTOM
    STA $0314
    LDA #>IRQ_BOTTOM
    STA $0315

    PLA
    TAY
    PLA
    TAX
    PLA

    LDA $D019
    STA $D019
    JMP $EA31

; ----------------------------------
; Game area (lines 40-199, black background)
; + info bar (lines 200+, gray background)
; ----------------------------------
IRQ_BOTTOM
    PHA
    TXA
    PHA
    TYA
    PHA

    LDA #0
    STA $D021               ; black background for game

    JSR UPDATE_GAME
    JSR UPDATE_SPRITES

    LDA #40
    STA $D012
    LDA #<IRQ_TOP
    STA $0314
    LDA #>IRQ_TOP
    STA $0315

    PLA
    TAY
    PLA
    TAX
    PLA

    LDA $D019
    STA $D019
    JMP $EA31

INIT_GAME
    ; ... initialize game ...
    RTS

DRAW_HUD
    ; ... draw HUD ...
    RTS

UPDATE_GAME
    ; ... game logic ...
    RTS

UPDATE_SPRITES
    ; ... update sprites ...
    RTS
```

---

## 17.7 Illusion of depth

Techniques for visual depth:

```
1. Parallax: layers at different speeds
2. Color gradient: darker sky at top
3. Sprite size: small enemies at top, large at bottom
4. Sprite priority: $D01B for sprites behind/foreground
```

### Sprite-background priority (`$D01B`)

```asm
; Puts sprite 0 BEHIND the background
LDA #%00000001
STA $D01B
```

### Variable size for depth

```asm
; Enemies at top (far) = normal sprite
; Enemies at bottom (close) = expanded sprite

LDA ENEMY_Y,X
CMP #100
BCS BIG_ENEMY

; Normal
LDA $D017
AND #%11111110          ; sprite 0 not expanded
STA $D017
JMP DONE_SIZE

BIG_ENEMY
LDA $D017
ORA #%00000001          ; sprite 0 expanded
STA $D017

DONE_SIZE
```

---

## Exercises

### Exercise 1
Divide the screen into 3 zones with 3 different background colors.

### Exercise 2
Create a fixed HUD at the top (score) and a game area below with a different color.

### Exercise 3
Implement fine scrolling (`$D016`) that increments every frame and resets at 7.

### Exercise 4
Create fake parallax: change background color every 8 frames (moving sky).

### Exercise 5
Use $D01B to make a sprite pass "behind" a background element.

---

## Summary

You have learned:

- Raster split with 3+ zones
- Fixed HUD separated from game area
- VIC-II fine scrolling (`$D016`)
- Fake parallax with color and tile changes
- Sky palette with gradient
- Sprite/background priority (`$D01B`)
- Depth illusion with sprite size

## References

- [Chapter 7 — Raster interrupt](07-raster-interrupt.md) — IRQ setup for split
- [Chapter 16 — Sprite multiplexing](16-sprite-multiplexing.md) — multiple raster zones
- [Chapter 19 — Kernel engine](19-reusable-kernel-engine.md) — priority scheduler
- [Solutions](../soluzioni/cap17-parallax-raster-split.asm) — exercise solutions
