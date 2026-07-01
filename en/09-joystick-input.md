# Chapter 9 — Joystick and Player Control

## Objectives

By the end of this chapter you will know:

- Read the joystick from the CIA register
- Convert joystick bits into directions
- Move the player with the joystick
- Detect the fire button
- Handle multiple joystick ports

---

## 9.1 Joystick registers

The C64 has two joystick ports, controlled by the CIA (Complex Interface Adapter) chip:

```
Port 1: $DC01   (used by player 1)
Port 2: $DC00   (used by player 2)
```

Each register contains the state of the directional controls and button:

```
Bit:  7   6   5   4   3   2   1   0
      F   E   D   C   B   A   9   8  (no meaning)
      |   |   |   |
      |   |   |   +── Right (port 1) / Up (port 2)
      |   |   +────── Left
      |   +────────── Down
      +────────────── Up (port 1) / Right (port 2)
```

> **Warning:** Bits are active **low** (0 = pressed, 1 = not pressed).

### Port 1 (`$DC01`) — bit layout

```
Bit 0 = Up      (0 = pressed)
Bit 1 = Down    (0 = pressed)
Bit 2 = Left    (0 = pressed)
Bit 3 = Right   (0 = pressed)
Bit 4 = Fire    (0 = pressed)
Bit 5-7 = unused (always 1)
```

---

## 9.2 Reading the joystick

Basic reading:

```asm
LDA $DC01       ; read port 1 joystick state
```

The value read will be like `$FF` (no button pressed) or with some bits at 0.

### Direction masks

```asm
; Masks for port 1
MASK_UP      = %11111110    ; bit 0
MASK_DOWN    = %11111101    ; bit 1
MASK_LEFT    = %11111011    ; bit 2
MASK_RIGHT   = %11110111    ; bit 3
MASK_FIRE    = %11101111    ; bit 4
```

### Detecting a direction

```asm
LDA $DC01

; Check UP
AND #%00000001      ; isolate bit 0
BEQ PRESSED_UP      ; if 0, UP pressed

; Check DOWN
LDA $DC01
AND #%00000010      ; isolate bit 1
BEQ PRESSED_DOWN
```

---

## 9.3 Reading the joystick cleanly

```asm
JOYSTICK = $DC01

READ_JOY
    LDA JOYSTICK    ; read state
    EOR #$FF        ; invert bits (1 = pressed)
    AND #%00011111  ; mask only bits 0-4
    STA JOY_STATE   ; save
    RTS

JOY_STATE = $02
```

After this routine, `JOY_STATE` contains:

```
Bit 0 = Up      (1 = pressed)
Bit 1 = Down    (1 = pressed)
Bit 2 = Left    (1 = pressed)
Bit 3 = Right   (1 = pressed)
Bit 4 = Fire    (1 = pressed)
```

---

## 9.4 Complete example: moving a sprite with joystick

```asm
PLAYER_X   = $02
PLAYER_Y   = $03
JOY_STATE  = $04

*=$C000

START
    JSR INIT_GAME

MAINLOOP
    JSR WAIT_FRAME
    JSR READ_JOY
    JSR MOVE_PLAYER
    JSR UPDATE_SPRITES
    JMP MAINLOOP

; ----------------------------------
; INITIALIZATION
; ----------------------------------
INIT_GAME
    LDA #%00000001
    STA $D015
    LDA #1
    STA $D027
    LDA #192
    STA $07F8

    LDA #160
    STA PLAYER_X
    STA $D000

    LDA #150
    STA PLAYER_Y
    STA $D001
    RTS

; ----------------------------------
; JOYSTICK READING
; ----------------------------------
READ_JOY
    LDA $DC01
    EOR #$FF
    AND #%00011111
    STA JOY_STATE
    RTS

; ----------------------------------
; PLAYER MOVEMENT
; ----------------------------------
MOVE_PLAYER
    LDA JOY_STATE
    AND #%00000001      ; UP?
    BEQ CHECK_DOWN

    LDA PLAYER_Y
    CMP #30             ; top boundary
    BCC CHECK_DOWN
    DEC PLAYER_Y

CHECK_DOWN
    LDA JOY_STATE
    AND #%00000010      ; DOWN?
    BEQ CHECK_LEFT

    LDA PLAYER_Y
    CMP #220            ; bottom boundary
    BCS CHECK_LEFT
    INC PLAYER_Y

CHECK_LEFT
    LDA JOY_STATE
    AND #%00000100      ; LEFT?
    BEQ CHECK_RIGHT

    LDA PLAYER_X
    CMP #10             ; left boundary
    BCC CHECK_RIGHT
    DEC PLAYER_X

CHECK_RIGHT
    LDA JOY_STATE
    AND #%00001000      ; RIGHT?
    BEQ DONE_MOVE

    LDA PLAYER_X
    CMP #240            ; right boundary
    BCS DONE_MOVE
    INC PLAYER_X

DONE_MOVE
    RTS

; ----------------------------------
; SPRITE UPDATE
; ----------------------------------
UPDATE_SPRITES
    LDA PLAYER_X
    STA $D000
    LDA PLAYER_Y
    STA $D001
    RTS

; ----------------------------------
; FRAME SYNC
; ----------------------------------
WAIT_FRAME
    LDA $D012
    CMP #$F8
    BNE WAIT_FRAME
    RTS
```

---

## 9.5 Detecting the fire button

```asm
READ_FIRE
    LDA $DC01
    AND #%00010000      ; bit 4 = fire
    BNE NOT_FIRED       ; if 1, not pressed
    ; FIRE pressed!
    ; ... handle shooting ...
NOT_FIRED
    RTS
```

### Fire with rising edge (single shot)

To prevent continuous fire while holding the button:

```asm
OLD_FIRE = $05

READ_FIRE_ONCE
    LDA $DC01
    AND #%00010000
    BNE NOT_FIRED

    LDA OLD_FIRE
    BNE NOT_FIRED       ; if already pressed, ignore

    ; This is the first frame it's pressed!

    LDA #1
    STA OLD_FIRE
    JMP FIRE_ACTION

NOT_FIRED
    LDA #0
    STA OLD_FIRE
    RTS

FIRE_ACTION
    ; ... shoot! ...
    RTS
```

---

## 9.6 Port 2 (`$DC00`)

Port 2 has a different bit layout:

```
Port 2 ($DC00):
Bit 0 = Right
Bit 1 = Left
Bit 2 = Down
Bit 3 = Up
Bit 4 = Fire
```

```asm
; Reading port 2
LDA $DC00
```

---

## 9.7 Complete input routines

```asm
; ----------------------------------
; COMPLETE INPUT SYSTEM
; ----------------------------------
JOY1      = $DC01
JOY2      = $DC00

JOY_STATE = $02      ; normalized state
OLD_JOY   = $03      ; previous frame
EDGE_JOY  = $04      ; detected presses

; Read joystick 1 and normalize
READ_INPUT
    LDA JOY1
    EOR #$FF
    AND #%00011111
    STA JOY_STATE

    ; Edge detection (just pressed)
    TAX
    EOR OLD_JOY
    AND JOY_STATE
    STA EDGE_JOY

    STX OLD_JOY
    RTS

; Usage examples
CHECK_UP
    LDA JOY_STATE
    AND #1
    BNE DO_UP
    RTS
DO_UP
    ; ... up action ...
    RTS

CHECK_FIRE_PRESSED
    LDA EDGE_JOY
    AND #%00010000      ; fire just pressed?
    BNE DO_FIRE
    RTS
DO_FIRE
    ; ... shoot ...
    RTS
```

---

## 9.8 Diagonal movement

The joystick allows diagonal directions. Handle the case where two directions are pressed together:

```asm
MOVE_PLAYER
    LDA JOY_STATE
    STA TEMP

    ; UP (with or without diagonal)
    LDA TEMP
    AND #%00000001
    BEQ CHECK_DOWN2
    DEC PLAYER_Y

CHECK_DOWN2
    LDA TEMP
    AND #%00000010
    BEQ CHECK_LEFT2
    INC PLAYER_Y

CHECK_LEFT2
    LDA TEMP
    AND #%00000100
    BEQ CHECK_RIGHT2
    DEC PLAYER_X

CHECK_RIGHT2
    LDA TEMP
    AND #%00001000
    BEQ DONE_MOVE2
    INC PLAYER_X

DONE_MOVE2
    RTS
```

---

## Exercises

### Exercise 1
Read the joystick and move a sprite in all 4 directions.

### Exercise 2
Add boundary checking: the player must not leave the screen.

### Exercise 3
Using the fire button, change the sprite's color.

### Exercise 4
Implement "single shot": each fire press increments a counter (but not while held down).

### Exercise 5
Move one sprite with port 1 and a second sprite with port 2.

---

## Summary

You have learned:

- The joystick registers `$DC00` and `$DC01`
- Bits are active low (0 = pressed)
- How to normalize state with `EOR #$FF`
- Moving the player with boundary checking
- Detecting the fire button with rising edge
- Handling diagonal directions
- Edge detection for "single shot" input

## References

- [Chapter 6 — Sprite movement](06-sprite-movement-control.md) — moving sprites
- [Chapter 11 — Bullet system](11-bullet-system.md) — shooting with fire button
- [Solutions](../soluzioni/cap09-joystick.asm) — exercise solutions
