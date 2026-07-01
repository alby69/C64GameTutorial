# Chapter 8 — Game Loop Synchronized at 50 Hz

## Objectives

By the end of this chapter you will know:

- Synchronize the game at 50 frames per second
- Use a frame counter
- Animate every N frames
- Create the standard C64 game architecture
- Separate logic and rendering

---

## 8.1 Why synchronize?

Without synchronization, the loop runs at maximum CPU speed (~1 MHz). Result:

- Movements too fast
- Screen flickering
- Unstable animations
- Different behavior on PAL vs NTSC

With 50 Hz synchronization (PAL):

```
Each frame lasts 1/50 second = 20ms
The loop runs EXACTLY 50 times per second
Stable movements and animations
```

---

## 8.2 Synchronizing with the raster

The simplest method: wait until the raster reaches a specific line.

```asm
WAIT_FRAME
    LDA $D012           ; read current raster
    CMP #$F8            ; line 248 (near bottom)
    BNE WAIT_FRAME      ; wait until it gets there
    RTS
```

### Complete example

```asm
*=$C000

START
    LDA #%00000001
    STA $D015

    LDA #1
    STA $D027

    LDA #192
    STA $07F8

    LDA #100
    STA $D000
    STA $D001

MAINLOOP
    JSR WAIT_FRAME      ; synchronize at 50 Hz
    JSR UPDATE
    JMP MAINLOOP

WAIT_FRAME
    LDA $D012
    CMP #$F8
    BNE WAIT_FRAME
    RTS

UPDATE
    INC $D001           ; sprite descends 1 pixel per frame
    RTS
```

The sprite will descend 50 pixels per second (precise).

---

## 8.3 Frame Counter

A counter that increments every frame is useful for timing actions:

```asm
FRAME_CNT = $02

START
    LDA #0
    STA FRAME_CNT

MAINLOOP
    JSR WAIT_FRAME

    INC FRAME_CNT       ; +1 every frame (50 per sec)

    JSR UPDATE
    JMP MAINLOOP
```

### Game timer

```asm
; After 1 second (50 frames)
LDA FRAME_CNT
CMP #50
BNE NOT_YET

; ...do something...
LDA #0
STA FRAME_CNT          ; reset counter
```

---

## 8.4 Animating every N frames

To animate a sprite every 8 frames (about 6 times per second):

```asm
ANIM_CNT = $03
FRAME_CNT = $02

UPDATE
    LDA FRAME_CNT
    AND #7              ; check only bits 0-2 (every 8 frames)
    BNE NO_ANIM         ; if not 8, skip

    INC ANIM_CNT        ; change animation frame
    LDA ANIM_CNT
    AND #3              ; 4 animation frames (0-3)
    CLC
    ADC #192            ; base pointer
    STA $07F8           ; update sprite

NO_ANIM
    RTS
```

### Frequency table

| Every N frames | Times per second (PAL) |
|---|---|
| 1 | 50 |
| 2 | 25 |
| 4 | 12.5 |
| 6 | ~8.3 |
| 8 | 6.25 |
| 10 | 5 |
| 25 | 2 |
| 50 | 1 |

```asm
; Player movement every 2 frames (25 moves/sec)
LDA FRAME_CNT
AND #1
BNE SKIP_MOVE

JSR MOVE_PLAYER

SKIP_MOVE
```

---

## 8.5 IRQ as game loop

The professional method: game logic runs inside the raster interrupt.

```asm
*=$2000

START
    SEI
    LDA #$7F
    STA $DC0D

    LDA #<IRQ
    STA $0314
    LDA #>IRQ
    STA $0315

    LDA #250
    STA $D012

    LDA $D011
    AND #$7F
    STA $D011

    LDA #1
    STA $D01A

    CLI

MAIN
    JMP MAIN            ; the "real" code runs in the IRQ

IRQ
    PHA                 ; save registers
    TXA
    PHA
    TYA
    PHA

    JSR READ_JOYSTICK
    JSR UPDATE_PLAYER
    JSR UPDATE_ENEMIES
    JSR CHECK_COLLISIONS
    JSR UPDATE_SPRITES

    PLA                 ; restore registers
    TAY
    PLA
    TAX
    PLA

    LDA $D019
    STA $D019

    JMP $EA31
```

---

## 8.6 Double IRQ: logic + rendering

For complex games, we split tasks across two interrupts:

```asm
; IRQ1: end of frame (logic)
IRQ1
    PHA
    TXA
    PHA
    TYA
    PHA

    JSR GAME_LOGIC      ; update game state

    PLA
    TAY
    PLA
    TAX
    PLA

    ; Install IRQ2 at mid-screen
    LDA #100
    STA $D012
    LDA #<IRQ2
    STA $0314
    LDA #>IRQ2
    STA $0315

    LDA $D019
    STA $D019
    JMP $EA31

; IRQ2: mid-screen (sprites/rendering)
IRQ2
    PHA
    TXA
    PHA
    TYA
    PHA

    JSR UPDATE_SPRITES  ; update sprites for visible area

    PLA
    TAY
    PLA
    TAX
    PLA

    ; Re-install IRQ1
    LDA #250
    STA $D012
    LDA #<IRQ1
    STA $0314
    LDA #>IRQ1
    STA $0315

    LDA $D019
    STA $D019
    JMP $EA31
```

---

## 8.7 Standard C64 game architecture

```asm
; ----------------------------------
; VARIABLES
; ----------------------------------
FRAME_CNT   = $02
GAME_STATE  = $03
PLAYER_X    = $04
PLAYER_Y    = $05
ENEMY_COUNT = $06
SCORE       = $07

; ----------------------------------
; INITIAL SETUP
; ----------------------------------
*=$2000

START
    SEI
    JSR INIT_IRQ
    JSR INIT_GAME
    CLI

MAIN_LOOP
    JMP MAIN_LOOP

; ----------------------------------
; IRQ INITIALIZATION
; ----------------------------------
INIT_IRQ
    LDA #$7F
    STA $DC0D
    LDA #<GAME_IRQ
    STA $0314
    LDA #>GAME_IRQ
    STA $0315
    LDA #250
    STA $D012
    LDA $D011
    AND #$7F
    STA $D011
    LDA #1
    STA $D01A
    RTS

; ----------------------------------
; GAME IRQ (executed 50 times/sec)
; ----------------------------------
GAME_IRQ
    PHA
    TXA
    PHA
    TYA
    PHA

    INC FRAME_CNT

    JSR READ_INPUT
    JSR UPDATE_LOGIC
    JSR UPDATE_SPRITES

    PLA
    TAY
    PLA
    TAX
    PLA

    LDA $D019
    STA $D019
    JMP $EA31

; ----------------------------------
; LOGIC
; ----------------------------------
INIT_GAME
    LDA #0
    STA FRAME_CNT
    STA SCORE
    STA GAME_STATE

    LDA #%00000001
    STA $D015
    LDA #1
    STA $D027
    LDA #192
    STA $07F8
    RTS

READ_INPUT
    ; ... read joystick ...
    RTS

UPDATE_LOGIC
    ; ... game logic ...
    RTS

UPDATE_SPRITES
    ; ... sprite update ...
    RTS
```

---

## 8.8 Frame timing (CPU cycles)

On PAL, each frame offers about 20000 available CPU cycles.

```
Typical budget per frame:
┌──────────────────────────────────┐
│ Game logic            ~8000 cycles│
│ Sprite update        ~4000 cycles│
│ Rendering            ~3000 cycles│
│ Audio                 ~2000 cycles│
│ Buffer / overhead    ~3000 cycles│
├──────────────────────────────────┤
│ Total:              ~20000 cycles│
└──────────────────────────────────┘
```

### Checking the budget

Use the debug bar technique to see if you're over budget:

```asm
GAME_IRQ
    LDA #2
    STA $D020          ; red border START

    ; ...all game logic...

    LDA #0
    STA $D020          ; black border END

    LDA $D019
    STA $D019
    JMP $EA31
```

If the red bar exceeds half the left border, you're using too much CPU time.

---

## Exercises

### Exercise 1
Create a frame counter and display its value (in hex) on the border using `STA $D020`.

### Exercise 2
Move a sprite right by 1 pixel every frame. It should travel 50 pixels per second.

### Exercise 3
Animate a sprite every 4 frames, alternating between 2 different shapes (pointers 192 and 193).

### Exercise 4
Make a message on screen flash every 25 frames (2 times per second).

### Exercise 5
Integrate your program inside a 50 Hz raster IRQ, with the standard structure (INIT, MAINLOOP, GAME_IRQ).

---

## Summary

You have learned:

- Synchronizing at 50 Hz with `WAIT_FRAME`
- Using a frame counter to time actions
- Animating every N frames
- Structuring the game with 50 Hz IRQ
- Separating READ_INPUT, UPDATE_LOGIC, UPDATE_SPRITES
- Managing CPU cycle budget per frame
- Using the debug bar to monitor CPU time

## References

- [Chapter 7 — Raster interrupt](07-raster-interrupt.md) — IRQ setup and management
- [Chapter 13 — Game states](13-score-game-states.md) — MENU/PLAY/GAMEOVER in the loop
- [Solutions](../soluzioni/cap08-game-loop.asm) — exercise solutions
