# Chapter 11 — Bullet System

## Objectives

By the end of this chapter you will know:

- Create a bullet pool
- Shoot with the joystick fire button
- Update bullet position every frame
- Detect when a bullet leaves the screen
- Handle bullet reuse in the pool

---

## 11.1 Bullet pool

In an arcade game you don't create/destroy objects dynamically (too slow). You use a **fixed pool**:

```asm
; Pool of 4 bullets
BULLET_X    = $60     ; 4 bytes
BULLET_Y    = $64     ; 4 bytes
BULLET_ACTIVE = $68   ; 4 bytes (0=inactive, 1=active)

MAX_BULLETS = 4
```

### Initialization

```asm
INIT_BULLETS
    LDA #0
    LDX #0
INIT_BL_LOOP
    STA BULLET_ACTIVE,X
    INX
    CPX #MAX_BULLETS
    BNE INIT_BL_LOOP
    RTS
```

---

## 11.2 Firing a bullet

Find the first free slot in the pool:

```asm
FIRE_BULLET
    LDX #0

FIND_SLOT
    LDA BULLET_ACTIVE,X
    BEQ SLOT_FOUND     ; free slot

    INX
    CPX #MAX_BULLETS
    BNE FIND_SLOT
    RTS                  ; no free slot

SLOT_FOUND
    LDA #1
    STA BULLET_ACTIVE,X ; activate bullet

    LDA PLAYER_X
    CLC
    ADC #4              ; center the bullet
    STA BULLET_X,X

    LDA PLAYER_Y
    SEC
    SBC #8              ; starts above the player
    STA BULLET_Y,X

    LDA #1
    STA BULLET_SPEED

    RTS

PLAYER_X    = $02
PLAYER_Y    = $03
BULLET_SPEED = $06
```

---

## 11.3 Bullet update

Every frame, all active bullets move upward:

```asm
UPDATE_BULLETS
    LDX #0

BL_LOOP
    LDA BULLET_ACTIVE,X
    BEQ BL_NEXT        ; inactive bullet

    ; Move upward
    DEC BULLET_Y,X

    ; Check if it left the screen
    LDA BULLET_Y,X
    CMP #5
    BCS BL_NEXT        ; still visible

    ; Left the screen: deactivate
    LDA #0
    STA BULLET_ACTIVE,X
    BNE BL_DONE        ; unconditional jump

BL_NEXT
BL_DONE
    INX
    CPX #MAX_BULLETS
    BNE BL_LOOP
    RTS
```

---

## 11.4 Drawing bullets as sprites

Assign hardware sprites 4-7 to bullets:

```asm
RENDER_BULLETS
    LDX #0
    STX TEMP          ; hardware sprite index

RN_LOOP
    LDA BULLET_ACTIVE,X
    BEQ RN_NEXT

    ; Assign position to hardware sprite
    LDY TEMP

    LDA BULLET_X,X
    STA $D008,Y       ; X sprite 4 + offset

    LDA BULLET_Y,X
    STA $D009,Y       ; Y sprite 4 + offset

    ; Color
    LDA #7            ; yellow
    STA $D02B,Y       ; color sprite 4 + offset

    ; Enable sprite
    LDA $D015
    ORA SPRITE_MASK,Y
    STA $D015

    INC TEMP
    TYA
    CLC
    ADC #2
    TAY

RN_NEXT
    INX
    CPX #MAX_BULLETS
    BNE RN_LOOP

    ; Disable unused sprites
    LDX TEMP
    CPX #4
    BEQ RN_DONE
    ; ... disable extra sprites ...
RN_DONE
    RTS

SPRITE_MASK
    .byte %00010000    ; sprite 4
    .byte %00100000    ; sprite 5
    .byte %01000000    ; sprite 6
    .byte %10000000    ; sprite 7

TEMP = $05
```

---

## 11.5 Complete fire system

Integrate with the joystick:

```asm
*=$C000

PLAYER_X    = $02
PLAYER_Y    = $03
FRAME_CNT   = $04
TEMP        = $05
FIRE_COOLDOWN = $06

; Bullet pool
BULLET_X    = $60
BULLET_Y    = $64
BULLET_ACTIVE = $68
MAX_BULLETS = 4

START
    JSR INIT_GAME

MAINLOOP
    JSR WAIT_FRAME
    INC FRAME_CNT

    JSR READ_JOY
    JSR MOVE_PLAYER
    JSR HANDLE_FIRE
    JSR UPDATE_BULLETS
    JSR RENDER_BULLETS
    JSR UPDATE_PLAYER_SPRITE
    JMP MAINLOOP

; ----------------------------------
; FIRE HANDLING WITH COOLDOWN
; ----------------------------------
HANDLE_FIRE
    LDA FIRE_COOLDOWN
    BEQ CHECK_FIRE
    DEC FIRE_COOLDOWN
    RTS

CHECK_FIRE
    LDA $DC01
    AND #%00010000      ; fire pressed?
    BNE NO_FIRE

    JSR FIRE_BULLET
    LDA #8
    STA FIRE_COOLDOWN   ; 8 frame pause
NO_FIRE
    RTS

; ----------------------------------
; SHOOT
; ----------------------------------
FIRE_BULLET
    LDX #0
FS_LOOP
    LDA BULLET_ACTIVE,X
    BEQ FS_FOUND
    INX
    CPX #MAX_BULLETS
    BNE FS_LOOP
    RTS

FS_FOUND
    LDA #1
    STA BULLET_ACTIVE,X
    LDA PLAYER_X
    CLC
    ADC #4
    STA BULLET_X,X
    LDA PLAYER_Y
    STA BULLET_Y,X
    RTS

; ----------------------------------
; BULLET UPDATE
; ----------------------------------
UPDATE_BULLETS
    LDX #0
UB_LOOP
    LDA BULLET_ACTIVE,X
    BEQ UB_NEXT
    DEC BULLET_Y,X
    LDA BULLET_Y,X
    CMP #5
    BCS UB_NEXT
    LDA #0
    STA BULLET_ACTIVE,X
UB_NEXT
    INX
    CPX #MAX_BULLETS
    BNE UB_LOOP
    RTS

; ----------------------------------
; RENDER
; ----------------------------------
RENDER_BULLETS
    LDX #0
    STX TEMP
RB_LOOP
    LDA BULLET_ACTIVE,X
    BEQ RB_NEXT
    LDY TEMP
    LDA BULLET_X,X
    STA $D008,Y
    LDA BULLET_Y,X
    STA $D009,Y
    LDA #7
    STA $D02B,Y
    LDA $D015
    ORA SPRTMSK,Y
    STA $D015
    INC TEMP
RB_NEXT
    INX
    CPX #MAX_BULLETS
    BNE RB_LOOP
    RTS

SPRTMSK
    .byte %00010000, %00100000, %01000000, %10000000

; ----------------------------------
; JOYSTICK
; ----------------------------------
READ_JOY
    LDA $DC01
    EOR #$FF
    AND #%00011111
    STA TEMP
    RTS

MOVE_PLAYER
    LDA TEMP
    AND #%00000001
    BEQ M_DOWN
    LDA PLAYER_Y
    CMP #30
    BCC M_DOWN
    DEC PLAYER_Y
M_DOWN
    LDA TEMP
    AND #%00000010
    BEQ M_LEFT
    LDA PLAYER_Y
    CMP #220
    BCS M_LEFT
    INC PLAYER_Y
M_LEFT
    LDA TEMP
    AND #%00000100
    BEQ M_RIGHT
    LDA PLAYER_X
    CMP #10
    BCC M_RIGHT
    DEC PLAYER_X
M_RIGHT
    LDA TEMP
    AND #%00001000
    BEQ M_DONE
    LDA PLAYER_X
    CMP #240
    BCS M_DONE
    INC PLAYER_X
M_DONE
    RTS

UPDATE_PLAYER_SPRITE
    LDA PLAYER_X
    STA $D000
    LDA PLAYER_Y
    STA $D001
    RTS

INIT_GAME
    LDA #%00000001
    STA $D015
    LDA #1
    STA $D027
    LDA #192
    STA $07F8
    LDA #160
    STA PLAYER_X
    LDA #180
    STA PLAYER_Y
    LDA #0
    STA FIRE_COOLDOWN
    STA FRAME_CNT

    ; Initialize bullet pool
    LDX #0
IG_BL
    STA BULLET_ACTIVE,X
    INX
    CPX #4
    BNE IG_BL
    RTS

WAIT_FRAME
    LDA $D012
    CMP #$F8
    BNE WAIT_FRAME
    RTS

*=$3000
SPRITE_DATA
    .byte 0,60,0
    .byte 0,126,0
    .byte 255,255,255
    .byte 255,255,255
    .byte 0,126,0
    .byte 0,60,0
    .byte 0,24,0
    .byte 0,24,0
    .byte 0,0,0
    .byte 0,0,0
    .byte 0,0,0
    .byte 0,0,0
    .byte 0,0,0
    .byte 0,0,0
    .byte 0,0,0
    .byte 0,0,0
    .byte 0,0,0
    .byte 0,0,0
    .byte 0,0,0
    .byte 0,0,0
    .byte 0,0,0
```

---

## 11.6 Enemy bullets (optional)

For enemies that shoot downward:

```asm
ENEMY_BULLET_X = $70
ENEMY_BULLET_Y = $74
ENEMY_BULLET_ACTIVE = $78

FIRE_ENEMY_BULLET
    LDX #0
EF_LOOP
    LDA ENEMY_BULLET_ACTIVE,X
    BEQ EF_FOUND
    INX
    CPX #2              ; 2 enemy bullets
    BNE EF_LOOP
    RTS

EF_FOUND
    LDA #1
    STA ENEMY_BULLET_ACTIVE,X
    LDA ENEMY_X
    STA ENEMY_BULLET_X,X
    LDA ENEMY_Y
    CLC
    ADC #12
    STA ENEMY_BULLET_Y,X
    RTS

UPDATE_ENEMY_BULLETS
    LDX #0
EUB_LOOP
    LDA ENEMY_BULLET_ACTIVE,X
    BEQ EUB_NEXT
    INC ENEMY_BULLET_Y,X    ; moves downward
    LDA ENEMY_BULLET_Y,X
    CMP #230
    BCC EUB_NEXT
    LDA #0
    STA ENEMY_BULLET_ACTIVE,X
EUB_NEXT
    INX
    CPX #2
    BNE EUB_LOOP
    RTS
```

---

## Exercises

### Exercise 1
Create a pool of 2 bullets. Fire them with the fire button.

### Exercise 2
Add cooldown: you can only fire every 10 frames.

### Exercise 3
Bullets must hit a fixed enemy on screen. When they hit it, it disappears.

### Exercise 4
Add enemy bullets: every 30 frames, an enemy fires a bullet downward.

### Exercise 5
Create a power-up: by collecting a special item, the bullet count increases to 6.

---

## Summary

You have learned:

- What a bullet pool is (static array)
- Finding free slots in the pool
- Shooting with joystick and cooldown
- Updating bullets every frame
- Deactivating off-screen bullets
- Assigning hardware sprites to bullets
- Enemy bullets (downward)

## References

- [Chapter 9 — Joystick](09-joystick-input.md) — input for shooting
- [Chapter 10 — Collisions](10-software-collisions.md) — bullets that hit
- [Chapter 12 — Wave system](12-wave-system-ai.md) — enemies to shoot
- [Solutions](../soluzioni/cap11-proiettili.asm) — exercise solutions
