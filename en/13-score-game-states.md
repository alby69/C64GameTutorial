# Chapter 13 — Score and Game States

## Objectives

By the end of this chapter you will know:

- Manage a 16-bit score
- Display the score on screen
- Implement a state machine (MENU, PLAY, GAME OVER)
- Reset the game correctly
- Create transition screens

---

## 13.1 16-bit score

The score in an arcade can reach 9999 or more. We use 2 bytes (16-bit):

```asm
SCORE_LO  = $02      ; low byte
SCORE_HI  = $03      ; high byte
```

### Initialization

```asm
INIT_SCORE
    LDA #0
    STA SCORE_LO
    STA SCORE_HI
    RTS
```

### Adding points

```asm
ADD_SCORE_10
    CLC
    LDA SCORE_LO
    ADC #10
    STA SCORE_LO
    LDA SCORE_HI
    ADC #0
    STA SCORE_HI
    RTS

ADD_SCORE_100
    CLC
    LDA SCORE_LO
    ADC #100
    STA SCORE_LO
    LDA SCORE_HI
    ADC #0
    STA SCORE_HI
    RTS
```

### Score by enemy type

```asm
ADD_SCORE_ENEMY
    CLC
    LDA SCORE_LO
    ADC ENEMY_POINTS,X    ; points per enemy type
    STA SCORE_LO
    LDA SCORE_HI
    ADC #0
    STA SCORE_HI
    RTS

ENEMY_POINTS
    .byte 10, 25, 50, 100
```

---

## 13.2 Displaying the score

To show numbers, we must convert binary to PETSCII characters.

### Binary to 3 digits (0-999)

```asm
; Converts SCORE_LO (0-255) into 3 characters
; writes at $0420 (SCORE: 000)

DRAW_SCORE
    LDA SCORE_LO
    LDX #0             ; hundreds
DIV100
    CMP #100
    BCC DONE100
    SBC #100
    INX
    JMP DIV100
DONE100
    TXA
    CLC
    ADC #$30          ; convert to PETSCII digit
    STA $0420         ; hundreds

    ; A = remainder (0-99)
    LDX #0             ; tens
DIV10
    CMP #10
    BCC DONE10
    SBC #10
    INX
    JMP DIV10
DONE10
    TXA
    CLC
    ADC #$30
    STA $0421         ; tens

    CLC
    ADC #$30
    STA $0422         ; units
    RTS
```

### 16-bit version (up to 9999)

```asm
; Converts SCORE_HI:SCORE_LO into 4 digits
DRAW_SCORE_16
    ; Thousands
    LDA SCORE_HI
    PHA
    JSR WRITE_DIGIT    ; simplified

    ; Hundreds (remainder of SCORE_HI)
    ; ... similar logic ...

    ; Tens and units from SCORE_LO
    LDA SCORE_LO
    ; ... divisions ...

    RTS
```

---

## 13.3 Game State Machine

An arcade game has well-defined states:

```
           ┌──────────────┐
           │    MENU      │
           └──────┬───────┘
                  │ fire pressed
                  v
           ┌──────────────┐
           │    PLAY      │
           └──────┬───────┘
                  │ player dead
                  v
           ┌──────────────┐
           │  GAME OVER   │
           └──────┬───────┘
                  │ fire pressed
                  v
           ┌──────────────┐
           │    MENU      │
           └──────────────┘
```

### State variable

```asm
GAME_STATE = $10

STATE_MENU     = 0
STATE_PLAY     = 1
STATE_GAMEOVER = 2
```

### State machine in the main loop

```asm
*=$8000

START
    JSR INIT_GAME

MAINLOOP
    JSR WAIT_FRAME
    INC FRAME_CNT

    LDA GAME_STATE
    CMP #STATE_MENU
    BEQ DO_MENU

    CMP #STATE_PLAY
    BEQ DO_PLAY

    CMP #STATE_GAMEOVER
    BEQ DO_GAMEOVER

    JMP MAINLOOP

DO_MENU
    JSR UPDATE_MENU
    JMP MAINLOOP

DO_PLAY
    JSR UPDATE_GAME
    JMP MAINLOOP

DO_GAMEOVER
    JSR UPDATE_GAMEOVER
    JMP MAINLOOP
```

---

## 13.4 MENU state

```asm
UPDATE_MENU
    JSR DRAW_TITLE
    JSR READ_FIRE
    BEQ MENU_DONE       ; wait for fire

    ; Switch to PLAY
    LDA #STATE_PLAY
    STA GAME_STATE
    JSR RESET_GAME

MENU_DONE
    RTS

DRAW_TITLE
    ; Draw title once
    LDA TITLE_DRAWN
    BNE DT_DONE

    ; ... writes "ARCADE GAME" on screen ...
    ; ... writes "PRESS FIRE" ...

    LDA #1
    STA TITLE_DRAWN

DT_DONE
    RTS
```

---

## 13.5 PLAY state

```asm
UPDATE_GAME
    JSR READ_JOY
    JSR MOVE_PLAYER
    JSR HANDLE_FIRE
    JSR UPDATE_BULLETS
    JSR UPDATE_WAVE
    JSR MOVE_ENEMIES
    JSR CHECK_EDGES
    JSR CHECK_WAVE_CLEAR
    JSR CHECK_COLLISIONS
    JSR CHECK_PLAYER_DEATH
    JSR DRAW_SCORE
    JSR RENDER_ALL
    RTS
```

---

## 13.6 GAME OVER state

```asm
UPDATE_GAMEOVER
    JSR DRAW_GAMEOVER

    LDA GAME_OVER_TIMER
    BNE DEC_TIMER

    JSR READ_FIRE_ONCE
    BCC GO_DONE

    ; Return to menu
    LDA #STATE_MENU
    STA GAME_STATE
    LDA #0
    STA TITLE_DRAWN

GO_DONE
    RTS

DEC_TIMER
    DEC GAME_OVER_TIMER
    RTS

DRAW_GAMEOVER
    LDA GAMEOVER_DRAWN
    BNE DGO_DONE

    JSR CLEAR_SCREEN

    ; Write "GAME OVER" on screen
    ; ... PETSCII codes for GAME OVER ...

    LDA #1
    STA GAMEOVER_DRAWN

    LDA #100
    STA GAME_OVER_TIMER ; 2 second pause

DGO_DONE
    RTS
```

---

## 13.7 Complete game reset

```asm
RESET_GAME
    JSR CLEAR_SCREEN

    ; Reset score
    LDA #0
    STA SCORE_LO
    STA SCORE_HI

    ; Reset player
    LDA #160
    STA PLAYER_X
    LDA #180
    STA PLAYER_Y

    ; Reset bullets
    LDX #0
RB_LOOP
    STA BULLET_ACTIVE,X
    INX
    CPX #4
    BNE RB_LOOP

    ; Reset enemies
    LDX #0
REN_LOOP
    STA ENEMY_ALIVE,X
    INX
    CPX #16
    BNE REN_LOOP

    ; Reset wave
    LDA #0
    STA WAVE_INDEX
    STA ENEMIES_LEFT
    STA ENEMY_DIR
    STA WAVE_TIMER

    LDA #STATE_MENU
    STA GAME_STATE

    RTS
```

---

## 13.8 Player death and lives

```asm
LIVES = $11

INIT_LIVES
    LDA #3
    STA LIVES
    RTS

PLAYER_DIE
    DEC LIVES
    LDA LIVES
    BEQ GAME_OVER_STATE

    ; Reset player position
    LDA #160
    STA PLAYER_X
    LDA #180
    STA PLAYER_Y

    ; 1 second invincibility
    LDA #50
    STA INVINCIBLE_TIMER

    RTS

GAME_OVER_STATE
    LDA #STATE_GAMEOVER
    STA GAME_STATE
    LDA #0
    STA GAMEOVER_DRAWN
    RTS
```

---

## 13.9 Wave transition screen

```asm
WAVE_TRANSITION
    ; Show "WAVE X" for 1 second
    JSR CLEAR_SCREEN

    ; Write "WAVE " + WAVE_INDEX
    LDX #0
WT_LOOP
    LDA WAVE_TEXT,X
    BEQ WT_DONE
    STA $0540,X
    INX
    JMP WT_LOOP
WT_DONE

    ; Show wave number
    LDA WAVE_INDEX
    CLC
    ADC #$30
    STA $0546

    ; Wait 50 frames
    LDA #50
    STA WAVE_DELAY
WTV_LOOP
    JSR WAIT_FRAME
    DEC WAVE_DELAY
    BNE WTV_LOOP

    JSR CLEAR_SCREEN
    JSR INIT_WAVE
    RTS

WAVE_TEXT
    .byte 23, 1, 22, 5, 0   ; "WAVE" in PETSCII + terminator
```

---

## Exercises

### Exercise 1
Create a score that starts at 0 and increases by 10 every time you press fire.

### Exercise 2
Convert and display the 3-digit score at the top-left of the screen.

### Exercise 3
Implement the state machine: MENU → PLAY → GAME OVER → MENU.

### Exercise 4
Add 3 lives. When the player is hit, lose one life. At 0 lives → GAME OVER.

### Exercise 5
Show "WAVE 1", "WAVE 2", etc. for 1 second between waves.

---

## Summary

You have learned:

- 16-bit score with carry addition
- Converting binary to PETSCII numeric characters
- State machine (MENU, PLAY, GAME OVER)
- State transitions
- Complete game reset
- Lives and invincibility management
- Transition screens

## References

- [Chapter 4 — Video memory](04-video-memory-characters.md) — displaying score on screen
- [Chapter 8 — Game loop](08-synchronized-game-loop.md) — core game structure
- [Chapter 12 — Wave system](12-wave-system-ai.md) — wave/score integration
- [Solutions](../soluzioni/cap13-punteggio-stati.asm) — exercise solutions
