# Chapter 23 — Title Screens and High Score

## Objectives

By the end of this chapter you will know:

- Create an animated title screen
- Handle input to start the game
- Save and load high scores from disk
- Use KERNAL routines for file I/O
- Integrate title and high score into the game loop

---

## 23.1 Animated Title Screen

A title screen is more than static text. It can include:
- Large PETSCII title text
- Animated sprites (ship, logo)
- Raster border effects
- Blinking "PRESS FIRE TO START"

### Basic structure

```asm
; Minimal title screen
*= $C000

TITLE_INIT
    ; Dark background
    LDA #0
    STA $D021
    LDA #$0B           ; gray border
    STA $D020

    ; Print title
    LDX #0
TI_LOOP
    LDA TITLE_TEXT,X
    BEQ TI_SPRITE
    STA $0400+40*5+8,X
    LDA #7             ; yellow
    STA $D800+40*5+8,X
    INX
    JMP TI_LOOP

TI_SPRITE
    ; Enable sprite 0 for animated logo
    LDA #%00000001
    STA $D015
    LDA #160
    STA $D000
    LDA #100
    STA $D001
    LDA #7
    STA $D027

    ; Setup raster for blinking
    SEI
    LDA #<TITLE_IRQ
    STA $0314
    LDA #>TITLE_IRQ
    STA $0315
    LDA #200
    STA $D012
    LDA #1
    STA $D01A
    CLI
    RTS

TITLE_LOOP
    ; Wait for fire
    LDA $DC01
    AND #%00010000
    BNE TITLE_LOOP
    ; Fire pressed → exit
    RTS

TITLE_TEXT
    .byte "SPACE COMMANDER",0
```

### Title animation

Animate the title by cycling sprite colors every N frames
using the raster interrupt:

```asm
TITLE_IRQ
    INC $D020          ; cycling border

    ; Cycle sprite color every 8 frames
    LDA FRAME_CNT
    AND #$07
    TAX
    LDA RAINBOW,X
    STA $D027

    LDA $D019
    STA $D019
    RTI

RAINBOW
    .byte 2,4,7,5,3,1,13,6
```

---

## 23.2 High Score: Where to Save It?

The C64 can save data to disk using KERNAL routines.
Structure for high score:

```
DISK:
  File "HI" (1 block)
  ┌──────────────────────────────┐
  │ Byte 0:   high score MSB     │
  │ Byte 1:   high score byte 1  │
  │ Byte 2:   high score LSB     │
  │ Byte 3-63: player name       │
  └──────────────────────────────┘
```

### Saving the high score

```asm
; Save high score to disk
; (uses KERNAL: SETNAM, SETLFS, OPEN, CLOSE)
SAVE_HIGH_SCORE
    ; Prepare file name "HI"
    LDA #2             ; name length
    LDX #<FNAME_HI
    LDY #>FNAME_HI
    JSR $FFBD          ; SETNAM

    ; Device parameters
    LDA #1             ; logical file number
    LDX #8             ; device 8
    LDY #1             ; channel 1
    JSR $FFBA          ; SETLFS

    ; Data address to save
    LDA #<HIGH_SCORE
    LDX #>HIGH_SCORE
    LDY #$C0           ; bank, ignored on C64
    JSR $FFD8          ; SAVE

    RTS

FNAME_HI
    .text "HI"

HIGH_SCORE
    .byte $00, $00, $00  ; 24-bit high score
    .byte "PLAYER",0
```

### Warning: SAVE ($FFD8) requires

- `A` = low byte of address
- `X` = high byte of address
- `Y` = bank address (64) or $FF for I/O (C64: ignored)
- Name and device must be set beforehand

**Note:** SAVE on a real C64 with 1541 requires the file
to not exist (otherwise error). Use `SCRATCH` first or
handle the error.

---

## 23.3 Loading the High Score

```asm
; Load high score from disk
LOAD_HIGH_SCORE
    LDA #2
    LDX #<FNAME_HI
    LDY #>FNAME_HI
    JSR $FFBD          ; SETNAM

    LDA #1
    LDX #8
    LDY #0             ; 0 = load
    JSR $FFBA          ; SETLFS

    LDA #0
    LDX #<HIGH_SCORE
    LDY #>HIGH_SCORE
    JSR $FFD5          ; LOAD

    ; If file does not exist, init to zero
    BCS LHS_FAIL
    RTS

LHS_FAIL
    LDA #0
    STA HIGH_SCORE
    STA HIGH_SCORE+1
    STA HIGH_SCORE+2
    RTS
```

### Handling missing file

On first launch, the "HI" file does not exist. `$FFD5` returns
**Carry set** on error. Always check `BCS` after LOAD.

---

## 23.4 Comparing and Updating High Score

```asm
; Compare (A=score LO, X=score HI) with HIGH_SCORE
; If greater, update and save
CHECK_HIGH_SCORE
    CMP HIGH_SCORE
    BCC CHS_OLD        ; score < high score
    CMP HIGH_SCORE+1
    BCC CHS_OLD
    ; New record!
    STA HIGH_SCORE+1
    STX HIGH_SCORE+2
    JSR SAVE_HIGH_SCORE
CHS_OLD
    RTS
```

---

## 23.5 Game Over Screen with High Score

After the player dies, show the score and the record:

```asm
GAMEOVER_SCREEN
    ; Print "GAME OVER"
    LDX #0
GOV_LOOP
    LDA GOV_TEXT,X
    BEQ GOV_SCORE
    STA $0400+40*8+12,X
    INX
    JMP GOV_LOOP

GOV_SCORE
    ; Print score
    LDA SCORE_HI
    JSR PRINT_HEX
    LDA SCORE_LO
    JSR PRINT_HEX

    ; Print high score
    LDX #0
GOV_HS_LOOP
    LDA HS_TEXT,X
    BEQ GOV_CHECK
    STA $0400+40*10+10,X
    INX
    JMP GOV_HS_LOOP

    LDA HIGH_SCORE+1
    JSR PRINT_HEX
    LDA HIGH_SCORE
    JSR PRINT_HEX

GOV_CHECK
    ; Check if new record
    LDA SCORE_HI
    CMP HIGH_SCORE+1
    BCC GOV_WAIT
    LDA SCORE_LO
    CMP HIGH_SCORE
    BCC GOV_WAIT
    ; New record!
    JSR SAVE_HIGH_SCORE
    ; Print "NEW RECORD!"

GOV_WAIT
    ; Wait for fire
    LDA $DC01
    AND #%00010000
    BNE GOV_WAIT
    RTS

GOV_TEXT
    .byte "GAME OVER",0

HS_TEXT
    .byte "HIGH SCORE:",0
```

---

## 23.6 Complete Title Screen

Putting it all together:

```asm
TITLE_FULL
    JSR TITLE_INIT
    JSR TITLE_SPRITES
    JSR LOAD_HIGH_SCORE   ; load record at startup

TF_LOOP
    ; Show high score
    LDX #0
TF_HS
    LDA HS_LABEL,X
    BEQ TF_BLINK
    STA $0400+40*15+10,X
    INX
    JMP TF_HS

TF_BLINK
    ; Blink "PRESS FIRE"
    LDA FRAME_CNT
    AND #$20
    BEQ TF_INPUT
    LDX #0
TF_BL
    LDA FIRE_TEXT,X
    BEQ TF_INPUT
    STA $0400+40*20+12,X
    INX
    JMP TF_BL
    JMP TF_INPUT

TF_HIDE
    ; Hide blinking text
    LDX #0
TF_HL
    LDA FIRE_TEXT,X
    BEQ TF_INPUT
    LDA #$20
    STA $0400+40*20+12,X
    INX
    JMP TF_HL

TF_INPUT
    LDA $DC01
    AND #%00010000
    BNE TF_LOOP
    RTS

HS_LABEL
    .byte "HIGH:",0

FIRE_TEXT
    .byte "PRESS FIRE",0
```

---

## 23.7 Game Loop Integration

The complete flow:

```
                   ┌──────────────┐
                   │  START       │
                   │  Load HS     │
                   └──────┬───────┘
                          ↓
                   ┌──────────────┐
         ┌────────→│ TITLE SCREEN │
         │         │ (animated)   │
         │         └──────┬───────┘
         │                ↓ FIRE
         │         ┌──────────────┐
         │         │   GAME PLAY  │
         │         │  (play...)   │
         │         └──────┬───────┘
         │                ↓ PLAYER DIES
         │         ┌──────────────┐
         │         │  GAME OVER   │
         │         │ Show score   │
         │         │ Compare HS   │
         │         │ Save if new  │
         │         └──────┬───────┘
         │                ↓ FIRE
         └────────────────┘
```

---

## Exercises

### Exercise 1
Create a title screen with "SHOOTER 64" text in yellow on black background, centered.

### Exercise 2
Add an animated sprite to the title screen that cycles colors every 8 frames.

### Exercise 3
Write routines to save and load a 3-byte high score from disk.

### Exercise 4
Integrate a game over screen that shows the current score and the high score.

### Exercise 5
Complete the cycle: title → game → game over → check HS → return to title.

---

## References

- [Chapter 13 — Game States](13-score-game-states.md) — state machine for title/HS integration
- [Chapter 21 — Custom Loader](21-custom-loader.md) — disk I/O (SETNAM, SETLFS, LOAD)
- [Appendix A](appendix-a-reference-tables.md) — KERNAL jump table ($FFD5 LOAD, $FFD8 SAVE)
- [Solutions](../soluzioni/cap23-titolo-highscore.asm) — exercise solutions
