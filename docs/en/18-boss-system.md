# Chapter 18 — Multi-Phase Boss Fight

## Objectives

By the end of this chapter you will know:

- Design a boss with multiple phases
- Implement attack patterns
- Handle phase transitions
- Simulate "intelligent" behavior
- Create a death sequence

---

## 18.1 Boss Architecture

An arcade boss is not a normal enemy. It is a **state machine** with multiple phases:

```
PHASE 0: Intro  — boss appears, entry animation
PHASE 1: Base attack — simple pattern
PHASE 2: Advanced attack — faster pattern
PHASE 3: Enrage — maximum speed, random pattern
PHASE 4: Death — destruction animation
```

### Data structure

```asm
BOSS_HP     = $50    ; hit points (0-255)
BOSS_STATE  = $51    ; current phase (0-4)
BOSS_TIMER  = $52    ; pattern timer
BOSS_X      = $53    ; X position
BOSS_Y      = $54    ; Y position
BOSS_DIR    = $55    ; movement direction
BOSS_SEED   = $56    ; seed for "randomness"

BOSS_ACTIVE = $57    ; 0 = inactive, 1 = active
```

---

## 18.2 Boss state machine

```asm
UPDATE_BOSS
    LDA BOSS_ACTIVE
    BEQ BOSS_DONE

    LDA BOSS_STATE
    CMP #0
    BEQ BOSS_INTRO
    CMP #1
    BEQ BOSS_PATTERN_A
    CMP #2
    BEQ BOSS_PATTERN_B
    CMP #3
    BEQ BOSS_ENRAGE
    CMP #4
    BEQ BOSS_DEATH

BOSS_DONE
    RTS

; ----------------------------------
; INTRO: boss appears
; ----------------------------------
BOSS_INTRO
    LDA BOSS_Y
    CMP #60
    BCS INTRO_DONE

    INC BOSS_Y         ; descend onto screen
    RTS

INTRO_DONE
    LDA #1
    STA BOSS_STATE     ; switch to pattern A
    LDA #0
    STA BOSS_TIMER
    RTS

; ----------------------------------
; PATTERN A: linear movement
; ----------------------------------
BOSS_PATTERN_A
    DEC BOSS_TIMER
    BPL PA_MOVE
    LDA #20
    STA BOSS_TIMER

    ; Shoot every 20 frames
    JSR BOSS_SHOOT

PA_MOVE
    JSR BOSS_MOVE
    RTS

; ----------------------------------
; PATTERN B: movement + rapid fire
; ----------------------------------
BOSS_PATTERN_B
    DEC BOSS_TIMER
    BPL PB_MOVE
    LDA #10
    STA BOSS_TIMER

    ; Shoot every 10 frames
    JSR BOSS_SHOOT
    JSR BOSS_SHOOT     ; two bullets

PB_MOVE
    JSR BOSS_MOVE_FAST
    RTS

; ----------------------------------
; ENRAGE: maximum speed
; ----------------------------------
BOSS_ENRAGE
    DEC BOSS_TIMER
    BPL PE_MOVE
    LDA #5
    STA BOSS_TIMER

    ; Shoot every 5 frames
    JSR BOSS_SHOOT
    JSR BOSS_SHOOT
    JSR BOSS_SHOOT     ; burst!

PE_MOVE
    JSR BOSS_MOVE_RANDOM
    RTS

; ----------------------------------
; DEATH
; ----------------------------------
BOSS_DEATH
    JSR DEATH_ANIMATION

    DEC BOSS_HP
    LDA BOSS_HP
    BEQ BOSS_DEAD

    RTS

BOSS_DEAD
    LDA #0
    STA BOSS_ACTIVE
    JSR SPAWN_EXPLOSION
    JSR ADD_SCORE_BOSS
    RTS
```

---

## 18.3 Movement patterns

```asm
BOSS_MOVE
    ; Left-right movement
    LDA BOSS_DIR
    BEQ BM_LEFT

BM_RIGHT
    INC BOSS_X
    LDA BOSS_X
    CMP #240
    BCC BM_DONE
    LDA #0
    STA BOSS_DIR
    JMP BM_DONE

BM_LEFT
    DEC BOSS_X
    LDA BOSS_X
    CMP #20
    BCS BM_DONE
    LDA #1
    STA BOSS_DIR

BM_DONE
    RTS

BOSS_MOVE_FAST
    ; Like BOSS_MOVE but faster
    LDA BOSS_DIR
    BEQ BMF_LEFT

BMF_RIGHT
    INC BOSS_X
    INC BOSS_X          ; 2 pixels per frame!
    LDA BOSS_X
    CMP #240
    BCC BMF_DONE
    LDA #0
    STA BOSS_DIR
    JMP BMF_DONE

BMF_LEFT
    DEC BOSS_X
    DEC BOSS_X
    LDA BOSS_X
    CMP #20
    BCS BMF_DONE
    LDA #1
    STA BOSS_DIR

BMF_DONE
    RTS

BOSS_MOVE_RANDOM
    ; Erratic movement
    LDA BOSS_SEED
    EOR $D012           ; use raster for randomness
    STA BOSS_SEED

    AND #3
    BEQ BM_R_UP
    CMP #1
    BEQ BM_R_DOWN
    CMP #2
    BEQ BM_R_LEFT
    JMP BM_R_RIGHT

BM_R_UP
    DEC BOSS_Y
    JMP BM_R_DONE
BM_R_DOWN
    INC BOSS_Y
    JMP BM_R_DONE
BM_R_LEFT
    DEC BOSS_X
    JMP BM_R_DONE
BM_R_RIGHT
    INC BOSS_X

BM_R_DONE
    ; Keep within bounds
    LDA BOSS_X
    CMP #10
    BCS CHK_R_MAX
    LDA #10
    STA BOSS_X
CHK_R_MAX
    CMP #250
    BCC CHK_R_Y
    LDA #250
    STA BOSS_X
CHK_R_Y
    LDA BOSS_Y
    CMP #40
    BCS CHK_R_Y2
    LDA #40
    STA BOSS_Y
CHK_R_Y2
    CMP #200
    BCC BM_R_END
    LDA #200
    STA BOSS_Y
BM_R_END
    RTS
```

---

## 18.4 Phase transition

Phase changes are triggered by HP loss:

```asm
CHECK_BOSS_PHASE
    LDA BOSS_HP
    CMP #120
    BCS PHASE_DONE      ; HP > 120: current phase

    CMP #80
    BCS PHASE_B         ; HP 80-120: phase B

    CMP #40
    BCS PHASE_ENRAGE    ; HP 40-80: enrage

    ; HP < 40: imminent death
    LDA BOSS_STATE
    CMP #4
    BEQ PHASE_DONE
    LDA #4
    STA BOSS_STATE
    RTS

PHASE_B
    LDA BOSS_STATE
    CMP #2
    BEQ PHASE_DONE
    CMP #3
    BEQ PHASE_DONE
    CMP #4
    BEQ PHASE_DONE
    LDA #2
    STA BOSS_STATE
    RTS

PHASE_ENRAGE
    LDA BOSS_STATE
    CMP #3
    BEQ PHASE_DONE
    CMP #4
    BEQ PHASE_DONE
    LDA #3
    STA BOSS_STATE
    LDA #1
    STA BOSS_TIMER

PHASE_DONE
    RTS
```

---

## 18.5 Boss shooting

```asm
BOSS_SHOOT
    ; Find a free enemy bullet slot
    LDX #0
BS_LOOP
    LDA ENEMY_BULLET_ACTIVE,X
    BEQ BS_FOUND
    INX
    CPX #4
    BNE BS_LOOP
    RTS                     ; no free slot

BS_FOUND
    LDA #1
    STA ENEMY_BULLET_ACTIVE,X

    LDA BOSS_X
    CLC
    ADC #12
    STA ENEMY_BULLET_X,X

    LDA BOSS_Y
    CLC
    ADC #16
    STA ENEMY_BULLET_Y,X

    RTS
```

---

## 18.6 Death animation

```asm
DEATH_ANIMATION
    INC $D020               ; flash border

    ; Alternate sprite color
    LDA FRAME_CNT
    AND #3
    TAX
    LDA DEATH_COLORS,X
    STA $D027               ; boss sprite color

    ; Sound effect
    JSR EXPLOSION_SOUND

    RTS

DEATH_COLORS
    .byte 2, 1, 2, 0        ; red, white, red, black
```

---

## 18.7 Boss "Pseudo-AI"

We simulate adaptive intelligence based on player behavior:

```asm
; Player tracker
PLAYER_HITS   = $58    ; how many times the player hit
PLAYER_MISSES = $59    ; how many times the player missed

; The boss "learns":
ADAPT_BOSS
    LDA PLAYER_HITS
    SEC
    SBC PLAYER_MISSES
    BMI PLAYER_BAD      ; player is losing

    ; Player is doing well: increase difficulty!
    LDA BOSS_TIMER
    CMP #5
    BCC ADAPT_DONE
    SBC #2
    STA BOSS_TIMER
    RTS

PLAYER_BAD
    ; Player is struggling: slow down a bit
    LDA BOSS_TIMER
    CMP #30
    BCS ADAPT_DONE
    CLC
    ADC #2
    STA BOSS_TIMER

ADAPT_DONE
    RTS
```

---

## 18.8 Boss rendering

```asm
RENDER_BOSS
    LDA BOSS_ACTIVE
    BEQ RB_DONE

    ; Use sprite 0 for the boss
    LDA BOSS_X
    STA $D000
    LDA BOSS_Y
    STA $D001

    ; Color changes per phase
    LDA BOSS_STATE
    TAX
    LDA BOSS_COLORS,X
    STA $D027

    ; Enable sprite 0
    LDA $D015
    ORA #%00000001
    STA $D015

RB_DONE
    RTS

BOSS_COLORS
    .byte 7, 2, 4, 1, 0    ; yellow, red, purple, white, black
```

---

## 18.9 Boss activation

```asm
; Activate the boss when a condition is met (e.g. wave 5)
ACTIVATE_BOSS
    LDA WAVE_INDEX
    CMP #5
    BNE AB_DONE

    LDA BOSS_ACTIVE
    BNE AB_DONE             ; already active

    LDA #1
    STA BOSS_ACTIVE
    STA BOSS_DIR

    LDA #200
    STA BOSS_HP

    LDA #0
    STA BOSS_STATE          ; intro

    LDA #160
    STA BOSS_X
    LDA #0
    STA BOSS_Y              ; starts from top

AB_DONE
    RTS
```

---

## Exercises

### Exercise 1
Create a boss with 3 phases: intro + pattern A + death.

### Exercise 2
The boss moves left to right and shoots one bullet every 30 frames.

### Exercise 3
When the boss loses half HP, switch to enrage phase (faster, shoots 2 bullets).

### Exercise 4
Implement the death animation: border flash and color cycling.

### Exercise 5
The boss adapts difficulty: if the player hits often, the boss accelerates.

---

## Summary

You have learned:

- Boss as a multi-phase state machine
- Movement patterns (linear, fast, random)
- Boss shooting into a bullet pool
- HP-based phase transition
- Death animation with flash
- Adaptive pseudo-AI
- Boss activation at a specific wave

## References

- [Chapter 10 — Collisions](10-software-collisions.md) — detect hits on the boss
- [Chapter 12 — Wave system](12-wave-system-ai.md) — pre-boss wave management
- [Chapter 16 — Sprite multiplexing](16-sprite-multiplexing.md) — extra sprites for the boss
- [Solutions](../soluzioni/cap18-boss.asm) — exercise solutions
