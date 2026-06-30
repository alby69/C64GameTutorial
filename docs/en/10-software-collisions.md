# Chapter 10 — Software Collisions Between Sprites

## Objectives

By the end of this chapter you will know:

- Detect collisions via software
- Use bounding boxes for comparison
- Leverage VIC-II hardware collision registers
- Handle collision reactions
- Optimize checks across multiple entities

---

## 10.1 Why collision detection is needed

In an arcade game, collisions are used for:

```
Bullet → Enemy   = damage/enemy destroyed
Player → Enemy   = game over / damage
Player → PowerUp = bonus
Enemy  → Enemy   = bounce (optional)
```

On the C64 there are two ways to detect collisions:

1. **Hardware** (VIC-II) — `$D01E` and `$D01F`
2. **Software** (CPU) — coordinate comparison

We'll use both, combining speed and precision.

---

## 10.2 Software Collision Detection (bounding box)

The most flexible method: compare the coordinates of two sprites.

```
Sprite A:       Sprite B:
┌────────┐      ┌────────┐
│   XX   │      │    YY  │
│   XX   │      │   YY   │
└────────┘      └────────┘

Collision if:
  |A.x - B.x| < 16  (sprite width)
  |A.y - B.y| < 16  (sprite height)
```

### Basic implementation

```asm
; Compare position of two sprites
; A_X, A_Y = first sprite
; B_X, B_Y = second sprite
; Returns: A = 1 if collision, 0 otherwise

CHECK_COLLISION
    ; X difference
    LDA A_X
    SEC
    SBC B_X
    BPL POS_X
    EOR #$FF        ; absolute value
    CLC
    ADC #1
POS_X
    CMP #16         ; collision if < 16 pixels
    BCS NO_HIT

    ; Y difference
    LDA A_Y
    SEC
    SBC B_Y
    BPL POS_Y
    EOR #$FF
    CLC
    ADC #1
POS_Y
    CMP #16
    BCS NO_HIT

    ; COLLISION!
    LDA #1
    RTS

NO_HIT
    LDA #0
    RTS

A_X = $02
A_Y = $03
B_X = $04
B_Y = $05
```

---

## 10.3 Optimized version

```asm
; Input: X = entity 1 index, Y = entity 2 index
; Output: C = 1 if collision

CHECK_COL
    LDA SPRITE_X,X
    SEC
    SBC SPRITE_X,Y
    BCS COL_X_OK
    EOR #$FF
    ADC #1
COL_X_OK
    CMP #16
    BCS COL_END

    LDA SPRITE_Y,X
    SEC
    SBC SPRITE_Y,Y
    BCS COL_Y_OK
    EOR #$FF
    ADC #1
COL_Y_OK
    CMP #16
    BCS COL_END

    SEC             ; collision! C = 1
    RTS

COL_END
    CLC             ; no collision
    RTS

SPRITE_X = $40     ; X table
SPRITE_Y = $50     ; Y table
```

---

## 10.4 Hardware Collision Detection (VIC-II)

The VIC-II has registers that automatically detect collisions:

```
$D01E = Sprite-Sprite collision register
$D01F = Sprite-Background collision register
```

Each bit represents one sprite (0-7).

```asm
; Read sprite-sprite collisions
LDA $D01E
STA COLL_MASK

; IMPORTANT: reset the register
LDA $D01E
STA $D01E       ; yes, writing the same value resets it
```

### Usage example

```asm
CHECK_HW_COLLISION
    LDA $D01E
    BEQ NO_COL      ; no bits = no collision

    ; Save and reset
    STA $D01E       ; acknowledge

    ; Analyze which sprites collided
    ; Bit 0 = sprite 0 (player)
    ; Bit 1 = sprite 1 (bullet)
    ; Bit 2 = sprite 2 (enemy)

    ; Example: player + bullet + enemy
    TAX
    AND #%00000111  ; sprites 0,1,2 involved?
    CMP #%00000111  ; all three?
    BEQ HIT_COMPLETE

    RTS

NO_COL
    RTS

HIT_COMPLETE
    ; ... handle hit ...
    RTS
```

---

## 10.5 Hybrid system (hardware + software)

The best method: use hardware to detect QUICKLY if there's a collision, then use software to figure out WHO hit WHOM.

```asm
CHECK_ALL_COLLISIONS
    LDA $D01E
    BEQ DONE_COL
    STA $D01E          ; acknowledge

    ; Save collision mask
    STA COLL_MASK

    ; Now software filter: who hit whom?
    ; Compare coordinates to determine the pair

    ; Bullet (sprite 1) vs enemies (sprites 2-7)
    LDX #1             ; bullet
    LDY #2             ; first enemy
COL_LOOP
    JSR CHECK_COL      ; software collision
    BCC NEXT_ENEMY

    ; Hit! Bullet X hit enemy Y
    JSR HANDLE_HIT

NEXT_ENEMY
    INY
    CPY #8
    BNE COL_LOOP

DONE_COL
    RTS
```

---

## 10.6 Handling a collision

When a collision occurs, we must decide what to do:

```asm
HANDLE_HIT
    ; Disable enemy
    LDA #0
    STA ENEMY_ALIVE,Y

    ; Disable bullet
    STA BULLET_ACTIVE,X

    ; Increment score
    LDA SCORE
    CLC
    ADC #10
    STA SCORE

    ; Sound effect
    JSR PLAY_HIT_SOUND

    RTS

ENEMY_ALIVE = $60     ; enemy state table
BULLET_ACTIVE = $70   ; bullet state table
SCORE       = $08     ; score
```

---

## 10.7 Player-enemy collision

```asm
CHECK_PLAYER_COL
    LDX #2             ; first enemy
COL_PL_LOOP
    LDA ENEMY_ALIVE,X
    BEQ SKIP_PL        ; dead enemy, skip

    ; Compare with player (sprite 0)
    JSR CHECK_COL_PLAYER
    BCC SKIP_PL

    ; Player-enemy collision!
    JSR GAME_OVER

SKIP_PL
    INX
    CPX #8
    BNE COL_PL_LOOP
    RTS

CHECK_COL_PLAYER
    ; Compare PLAYER_X/Y with ENEMY_X/Y
    LDA PLAYER_X
    SEC
    SBC ENEMY_X,X
    BPL PX_OK
    EOR #$FF
    ADC #1
PX_OK
    CMP #20            ; slightly wider hitbox
    BCS NO_PL_COL

    LDA PLAYER_Y
    SEC
    SBC ENEMY_Y,X
    BPL PY_OK
    EOR #$FF
    ADC #1
PY_OK
    CMP #20
    BCS NO_PL_COL

    SEC
    RTS

NO_PL_COL
    CLC
    RTS
```

---

## 10.8 Organizing data for collisions

```asm
; ----------------------------------
; ENTITY STRUCTURE
; ----------------------------------
; Each entity has:
;   - X, Y (position)
;   - Active (0 = dead, 1 = alive)
;   - Type (0 = player, 1 = bullet, 2 = enemy)

ENEMY_X     = $80     ; 8 bytes
ENEMY_Y     = $88     ; 8 bytes
ENEMY_ACTIVE = $90    ; 8 bytes
ENEMY_TYPE  = $98     ; 8 bytes

BULLET_X    = $60     ; 4 bytes
BULLET_Y    = $64     ; 4 bytes
BULLET_ACTIVE = $68   ; 4 bytes

PLAYER_X    = $02
PLAYER_Y    = $03
PLAYER_ALIVE = $04
```

---

## Exercises

### Exercise 1
Create two sprites: one controlled by joystick and one fixed. Detect when they touch and change color.

### Exercise 2
Implement the `$D01E` register to detect a collision between sprite 0 and sprite 1.

### Exercise 3
Create 3 fixed enemies. Move the player with the joystick. When you touch an enemy, disable it (set `ENEMY_ACTIVE = 0`).

### Exercise 4
Extend exercise 3: when all enemies are dead, show "VICTORY!" on screen.

### Exercise 5
Implement a post-collision invincibility system: after being hit, the player cannot be damaged for 60 frames.

---

## Summary

You have learned:

- Collision detection with bounding boxes (absolute value)
- The hardware register `$D01E` (sprite-sprite)
- Hybrid system: hardware for speed + software for precision
- Handling hits: disable, score, sound
- Organizing entity data for collisions
- Different hitboxes (player vs bullet)

## References

- [Chapter 11 — Bullet system](11-bullet-system.md) — bullet-enemy collisions
- [Chapter 18 — Boss system](18-boss-system.md) — multi-phase boss collisions
- [Solutions](../soluzioni/cap10-collisioni.asm) — exercise solutions
