# Chapter 12 — Wave System and Enemy AI

## Objectives

By the end of this chapter you will know:

- Create waves of enemies
- Move groups of enemies together
- Implement direction changes
- Handle increasing difficulty
- Use tables to define patterns

---

## 12.1 Wave architecture

In an arcade game, enemies don't all appear at once. They arrive in **waves**.

```
Wave 0: 4 slow enemies, linear pattern
Wave 1: 6 enemies, medium speed
Wave 2: 8 enemies, fast, with direction change
...     increasing difficulty
```

### Data structure

```asm
WAVE_INDEX      = $20    ; current wave number (0,1,2...)
WAVE_STATE      = $21    ; 0=spawn, 1=battle, 2=complete
WAVE_TIMER      = $22    ; timer for progressive spawn
ENEMIES_LEFT    = $23    ; enemies still alive in this wave
ENEMY_DIR       = $24    ; 0=left, 1=right
ENEMY_SPEED     = $25    ; movement speed
```

---

## 12.2 Enemy tables

```asm
; Maximum 16 enemies per wave
ENEMY_X      = $80     ; 16 bytes
ENEMY_Y      = $90     ; 16 bytes
ENEMY_ALIVE  = $A0     ; 16 bytes (0=dead, 1=alive)
ENEMY_TYPE   = $B0     ; 16 bytes (enemy type)

MAX_ENEMIES  = 16
```

---

## 12.3 Progressive enemy spawn

Each wave makes enemies appear one at a time:

```asm
UPDATE_WAVE
    LDA WAVE_STATE
    CMP #0
    BEQ DO_SPAWN
    CMP #1
    BEQ DO_BATTLE
    CMP #2
    BEQ DO_NEXT_WAVE
    RTS

DO_SPAWN
    DEC WAVE_TIMER
    BNE SPAWN_DONE

    LDA #20             ; 20 frames between spawns
    STA WAVE_TIMER

    JSR SPAWN_ENEMY

    LDA ENEMIES_LEFT
    CLC
    ADC #1
    STA ENEMIES_LEFT

    CMP #16             ; max enemies reached?
    BNE SPAWN_DONE

    LDA #1
    STA WAVE_STATE      ; switch to battle

SPAWN_DONE
    RTS
```

### Spawn routine

```asm
SPAWN_ENEMY
    ; Find first free slot
    LDX #0
SE_LOOP
    LDA ENEMY_ALIVE,X
    BEQ SE_FOUND
    INX
    CPX #MAX_ENEMIES
    BNE SE_LOOP
    RTS                    ; no slot

SE_FOUND
    LDA #1
    STA ENEMY_ALIVE,X

    ; Position using predefined table
    LDA SPAWN_X_TAB,X
    STA ENEMY_X,X

    LDA SPAWN_Y_TAB,X
    STA ENEMY_Y,X

    ; Enemy type based on wave
    LDA WAVE_INDEX
    AND #3
    STA ENEMY_TYPE,X

    RTS

; Spawn tables
SPAWN_X_TAB
    .byte 30, 70, 110, 150, 190, 30, 70, 110
    .byte 150, 190, 30, 70, 110, 150, 190, 210

SPAWN_Y_TAB
    .byte 40, 40, 40, 40, 40, 60, 60, 60
    .byte 60, 60, 80, 80, 80, 80, 80, 80
```

---

## 12.4 Collective movement (Space Invaders style)

Enemies all move together, as a formation:

```asm
MOVE_ENEMIES
    LDX #0
ME_LOOP
    LDA ENEMY_ALIVE,X
    BEQ ME_NEXT

    LDA ENEMY_DIR
    BEQ MOVE_LEFT

MOVE_RIGHT
    LDA ENEMY_X,X
    CLC
    ADC ENEMY_SPEED
    STA ENEMY_X,X
    JMP ME_NEXT

MOVE_LEFT
    LDA ENEMY_X,X
    SEC
    SBC ENEMY_SPEED
    STA ENEMY_X,X

ME_NEXT
    INX
    CPX #MAX_ENEMIES
    BNE ME_LOOP
    RTS
```

---

## 12.5 Direction change and descent

When the group touches the edge, it changes direction and descends:

```asm
CHECK_EDGES
    LDX #0
CE_LOOP
    LDA ENEMY_ALIVE,X
    BEQ CE_NEXT

    ; Check left edge
    LDA ENEMY_X,X
    CMP #5
    BCC FLIP_DIR

    ; Check right edge
    CMP #250
    BCS FLIP_DIR

    JMP CE_NEXT

FLIP_DIR
    LDA ENEMY_DIR
    EOR #1              ; invert direction
    STA ENEMY_DIR

    JSR MOVE_DOWN       ; all down a few pixels

    JMP CE_DONE

CE_NEXT
    INX
    CPX #MAX_ENEMIES
    BNE CE_LOOP

CE_DONE
    RTS

MOVE_DOWN
    LDX #0
MD_LOOP
    LDA ENEMY_ALIVE,X
    BEQ MD_NEXT

    LDA ENEMY_Y,X
    CLC
    ADC #4              ; descend 4 pixels

    STA ENEMY_Y,X

MD_NEXT
    INX
    CPX #MAX_ENEMIES
    BNE MD_LOOP
    RTS
```

---

## 12.6 Wave complete

When all enemies are dead:

```asm
CHECK_WAVE_CLEAR
    LDX #0
    LDA #0
CWC_LOOP
    CLC
    ADC ENEMY_ALIVE,X
    INX
    CPX #MAX_ENEMIES
    BNE CWC_LOOP

    CMP #0
    BNE CWC_DONE       ; still enemies alive

    ; Wave complete!
    LDA #2
    STA WAVE_STATE

    JSR PREPARE_NEXT_WAVE

CWC_DONE
    RTS

PREPARE_NEXT_WAVE
    INC WAVE_INDEX

    ; Increase difficulty
    LDA ENEMY_SPEED
    CLC
    ADC #1
    STA ENEMY_SPEED

    ; Reduce spawn timer
    LDA WAVE_TIMER
    CMP #5
    BCC SPEED_OK
    SEC
    SBC #2
    STA WAVE_TIMER
SPEED_OK

    ; Reset state
    LDA #0
    STA WAVE_STATE
    STA ENEMIES_LEFT

    RTS
```

---

## 12.7 Rendering enemies to hardware sprites

```asm
RENDER_ENEMIES
    LDX #0              ; enemy index
    LDY #0              ; HW sprite index (offset)

RE_LOOP
    LDA ENEMY_ALIVE,X
    BEQ RE_NEXT

    TXA
    PHA                 ; save X

    ; Assign position to hardware sprite
    LDA ENEMY_X,X
    STA $D002,Y         ; sprite 1 + offset

    LDA ENEMY_Y,X
    STA $D003,Y

    ; Color based on type
    LDA ENEMY_TYPE,X
    TAX
    LDA ENEMY_COLORS,X
    STA $D028,Y

    ; Enable sprite
    TYA
    LSR
    TAX
    LDA SPRITE_EN_MASK,X
    ORA $D015
    STA $D015

    ; Sprite pointer based on type
    LDA ENEMY_TYPE,X
    CLC
    ADC #193            ; pointer for frame 0
    STA $07F9,Y

    PLA
    TAX

    INY
    INY                 ; next HW sprite

RE_NEXT
    INX
    CPX #MAX_ENEMIES
    BNE RE_LOOP
    RTS

SPRITE_EN_MASK
    .byte %00000010     ; sprite 1
    .byte %00000100     ; sprite 2
    .byte %00001000     ; sprite 3

ENEMY_COLORS
    .byte 2, 5, 7, 4    ; red, green, yellow, purple
```

---

## 12.8 Alternative movement patterns

Besides linear movement, we can use pattern tables:

```asm
; Movement pattern table
; Each wave uses a different pattern

PATTERN_TABLE
    .word PATTERN_LINEAR     ; wave 0
    .word PATTERN_ZIGZAG     ; wave 1
    .word PATTERN_SINE       ; wave 2

PATTERN_LINEAR
    ; linear movement: already implemented
    RTS

PATTERN_ZIGZAG
    ; Each enemy moves differently
    LDX #0
PZ_LOOP
    LDA ENEMY_ALIVE,X
    BEQ PZ_NEXT

    LDA ENEMY_X,X
    CLC
    ADC ENEMY_SPEED
    STA ENEMY_X,X

    ; Alternate up/down
    TXA
    AND #1
    BEQ PZ_UP
    INC ENEMY_Y,X
    JMP PZ_NEXT
PZ_UP
    DEC ENEMY_Y,X

PZ_NEXT
    INX
    CPX #MAX_ENEMIES
    BNE PZ_LOOP
    RTS

PATTERN_SINE
    ; Approximate sinusoidal movement
    LDX #0
PS_LOOP
    LDA ENEMY_ALIVE,X
    BEQ PS_NEXT

    LDA ENEMY_X,X
    CLC
    ADC ENEMY_SPEED
    STA ENEMY_X,X

    ; Y oscillation based on frame
    TXA
    CLC
    ADC FRAME_CNT
    AND #15
    SEC
    SBC #7
    CLC
    ADC ENEMY_Y,X
    STA ENEMY_Y,X

PS_NEXT
    INX
    CPX #MAX_ENEMIES
    BNE PS_LOOP
    RTS
```

---

## 12.9 Enemy AI: random shooting

An enemy occasionally shoots:

```asm
ENEMY_SHOOT
    ; Every 30 frames, one alive enemy shoots
    LDA FRAME_CNT
    AND #31              ; every 32 frames
    BNE ES_DONE

    ; Pick a random alive enemy
    LDX #0
ES_FIND
    LDA ENEMY_ALIVE,X
    BNE ES_SHOOT
    INX
    CPX #MAX_ENEMIES
    BNE ES_FIND
    RTS

ES_SHOOT
    ; Create enemy bullet at its position
    JSR FIRE_ENEMY_BULLET

ES_DONE
    RTS
```

---

## Exercises

### Exercise 1
Create 4 enemies that move together from left to right. When they touch the edge, they descend and reverse.

### Exercise 2
Implement progressive spawn: one enemy appears every 30 frames.

### Exercise 3
Each subsequent wave increases enemy speed by 1.

### Exercise 4
Add an enemy that shoots every 40 frames.

### Exercise 5
Create 3 different movement patterns (linear, zigzag, random) and assign one per wave.

---

## Summary

You have learned:

- Managing waves with SPAWN, BATTLE, CLEAR states
- Enemy pool with static arrays
- Collective movement with edge direction change
- Gradual descent Space Invaders style
- Spawn tables for positioning
- Increasing difficulty (speed, timer)
- Alternative movement patterns (zigzag, sine)
- Random enemy shooting

## References

- [Chapter 11 — Bullet system](11-bullet-system.md) — enemies that shoot
- [Chapter 13 — Score](13-score-game-states.md) — score for killed enemies
- [Chapter 18 — Boss system](18-boss-system.md) — final wave with boss
- [Solutions](../soluzioni/cap12-wave-ai.asm) — exercise solutions
