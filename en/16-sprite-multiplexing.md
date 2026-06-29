# Chapter 16 — Sprite Multiplexing (8+ Sprites)

## Objectives

By the end of this chapter you will know:

- Why sprite multiplexing is needed
- Divide the screen into raster zones
- Reuse the 8 hardware sprites across multiple entities
- Update sprite positions during the raster
- Manage 16+ virtual enemies

---

## 16.1 The problem of 8 sprites

The VIC-II has only 8 hardware sprites. An arcade game needs more entities:

```
8 HW sprites   →   Only 8 visible enemies
But we want:       16, 24, 32 enemies!
```

### The solution: multiplexing

The trick: reuse the same 8 sprites in different **vertical zones** of the screen.

```
Screen divided into zones:
┌──────────────────────┐
│ ZONE 0   (0-79 px)   │ ← HW sprites 0-7 for enemies 0-7
├──────────────────────┤
│ ZONE 1   (80-159 px) │ ← Same HW sprites 0-7 for enemies 8-15
├──────────────────────┤
│ ZONE 2  (160-239 px) │ ← Same HW sprites 0-7 for enemies 16-23
└──────────────────────┘
```

The VIC-II draws one line at a time. When a zone finishes, we change the sprite coordinates for the next zone. This all happens during the raster interrupt.

---

## 16.2 Raster interrupt for multiplexing

```asm
; IRQ setup for multiplexing

INIT_MULTIPLEX
    SEI
    LDA #$7F
    STA $DC0D

    LDA #<IRQ_ZONE0
    STA $0314
    LDA #>IRQ_ZONE0
    STA $0315

    LDA #80              ; first zone: line 80
    STA $D012

    LDA $D011
    AND #$7F
    STA $D011

    LDA #1
    STA $D01A

    CLI
    RTS
```

---

## 16.3 Data structure for 24 enemies

```asm
; 24 logical enemies (not hardware)
ENEMY_X      = $80     ; 24 bytes
ENEMY_Y      = $98     ; 24 bytes
ENEMY_ALIVE  = $B0     ; 24 bytes
ENEMY_SPRITE = $C8     ; 24 bytes (sprite type/frame)

MAX_LOGICAL_ENEMIES = 24
SPRITE_SLOTS = 8
```

### Zone subdivision

```asm
; Each zone handles a group of enemies
ZONE0_START = 0     ; enemies 0-7
ZONE1_START = 8     ; enemies 8-15
ZONE2_START = 16    ; enemies 16-23

ZONE0_Y_MAX = 80
ZONE1_Y_MAX = 160
ZONE2_Y_MAX = 240
```

---

## 16.4 IRQ for each zone

### Zone 0 (line 80)

```asm
IRQ_ZONE0
    PHA
    TXA
    PHA
    TYA
    PHA

    ; Update sprites for enemies 0-7
    JSR UPDATE_ZONE0

    ; Prepare next IRQ at line 160
    LDA #160
    STA $D012

    LDA #<IRQ_ZONE1
    STA $0314
    LDA #>IRQ_ZONE1
    STA $0315

    PLA
    TAY
    PLA
    TAX
    PLA

    LDA $D019
    STA $D019
    JMP $EA31
```

### Zone 1 (line 160)

```asm
IRQ_ZONE1
    PHA
    TXA
    PHA
    TYA
    PHA

    ; Update sprites for enemies 8-15
    JSR UPDATE_ZONE1

    ; Prepare next IRQ at line 240
    LDA #240
    STA $D012

    LDA #<IRQ_ZONE2
    STA $0314
    LDA #>IRQ_ZONE2
    STA $0315

    PLA
    TAY
    PLA
    TAX
    PLA

    LDA $D019
    STA $D019
    JMP $EA31
```

### Zone 2 (line 240)

```asm
IRQ_ZONE2
    PHA
    TXA
    PHA
    TYA
    PHA

    ; Update sprites for enemies 16-23
    JSR UPDATE_ZONE2

    ; Return to zone 0 for next frame
    LDA #80
    STA $D012

    LDA #<IRQ_ZONE0
    STA $0314
    LDA #>IRQ_ZONE0
    STA $0315

    PLA
    TAY
    PLA
    TAX
    PLA

    LDA $D019
    STA $D019
    JMP $EA31
```

---

## 16.5 Sprite update per zone

```asm
; Update sprites 0-7 with enemies from the zone
; INPUT: X = first enemy index (0, 8, 16)

UPDATE_ZONE
    LDY #0              ; Y = HW sprite offset (0,2,4,...14)

UZ_LOOP
    LDA ENEMY_ALIVE,X
    BEQ UZ_NEXT         ; dead enemy

    LDA ENEMY_X,X
    STA $D000,Y         ; X hardware sprite

    LDA ENEMY_Y,X
    STA $D001,Y         ; Y hardware sprite

    ; Enable sprite
    LDA SPR_HW_MASK,Y
    ORA $D015
    STA $D015

    JMP UZ_CONT

UZ_NEXT
    ; Disable sprite
    LDA SPR_HW_MASK,Y
    EOR #$FF
    AND $D015
    STA $D015

UZ_CONT
    INX
    INY
    INY                 ; next HW sprite (Y+2)

    CPY #16             ; 8 sprites × 2 byte offset
    BNE UZ_LOOP

    RTS

; Sprite enable masks
SPR_HW_MASK
    .byte %00000001     ; sprite 0
    .byte %00000010     ; sprite 1
    .byte %00000100     ; sprite 2
    .byte %00001000     ; sprite 3
    .byte %00010000     ; sprite 4
    .byte %00100000     ; sprite 5
    .byte %01000000     ; sprite 6
    .byte %10000000     ; sprite 7
    .byte 0,0,0,0,0,0,0,0  ; padding for INY
```

### Zone-specific routines

```asm
UPDATE_ZONE0
    LDX #ZONE0_START
    JSR UPDATE_ZONE
    RTS

UPDATE_ZONE1
    LDX #ZONE1_START
    JSR UPDATE_ZONE
    RTS

UPDATE_ZONE2
    LDX #ZONE2_START
    JSR UPDATE_ZONE
    RTS
```

---

## 16.6 Color and pointer management per zone

```asm
UPDATE_ZONE_COLORS
    ; Assign color to each sprite slot based on enemy
    LDY #0
    LDX #ZONE0_START
UZC_LOOP
    LDA ENEMY_ALIVE,X
    BEQ UZC_SKIP

    LDA ENEMY_TYPE,X
    TAX
    LDA ENEMY_COLORS,X
    STA $D027,Y         ; sprite Y color

UZC_SKIP
    INY
    CPY #8
    BNE UZC_LOOP
    RTS

ENEMY_COLORS
    .byte 2, 5, 7, 4    ; red, green, yellow, purple
```

---

## 16.7 Dynamic slot assignment

For advanced multiplexing, slots are not fixed but assigned based on Y:

```asm
; Sort enemies by Y and assign to 8 slots
; (simplified version)

ASSIGN_SPRITE_SLOTS
    ; Find the 8 nearest enemies by Y
    ; and assign them to hardware sprites

    ; Reset assignments
    LDX #0
    LDA #$FF
AS_CLEAR
    STA SPRITE_SLOT,X
    INX
    CPX #8
    BNE AS_CLEAR

    ; Base scan: assign in ascending Y order
    ; (for each slot, find the enemy with smallest Y not yet assigned)

    LDY #0              ; hardware slot (0-7)
AS_SLOT
    LDA #255
    STA BEST_Y
    LDA #$FF
    STA BEST_ENEMY

    LDX #0              ; logical enemy
AS_FIND
    LDA ENEMY_ALIVE,X
    BEQ AS_NEXT

    ; Already assigned?
    LDA ENEMY_SLOT,X
    CMP #$FF
    BNE AS_NEXT

    LDA ENEMY_Y,X
    CMP BEST_Y
    BCS AS_NEXT

    STA BEST_Y
    STX BEST_ENEMY

AS_NEXT
    INX
    CPX #MAX_LOGICAL_ENEMIES
    BNE AS_FIND

    LDA BEST_ENEMY
    BMI AS_DONE          ; no enemy found

    TAX
    TYA
    STA ENEMY_SLOT,X     ; assign slot

    INY
    CPY #8
    BNE AS_SLOT

AS_DONE
    RTS

BEST_Y     = $70
BEST_ENEMY = $71
ENEMY_SLOT = $D0        ; slot assigned to each enemy
```

---

## 16.8 Limitations and performance

```
Each zone:    ~40-60 CPU cycles per update
3 zones:      120-180 CPU cycles (out of 20000 available)
              Very affordable!

Real limits:
- Max 8 sprites per vertical zone
- Minimum distance between sprites in same zone: ~21 pixels
- Each zone consumes one raster interrupt
```

### Typical budget

```asm
; 3 multiplexing IRQs = 3 × ~60 cycles = 180 cycles
; Full frame (PAL) = ~20000 cycles
; Multiplexing percentage: ~1% of frame!
```

---

## Exercises

### Exercise 1
Divide the screen into 2 zones (0-120 and 121-240). Show 4 sprites per zone.

### Exercise 2
Create 16 logical enemies. The first 8 go in the upper zone, the other 8 in the lower zone.

### Exercise 3
Implement 3 zones with 8 enemies each (24 total). Move them all.

### Exercise 4
Add dynamic assignment: HW sprites are assigned to enemies closest to the zone.

### Exercise 5
Measure the CPU time consumed by multiplexing using the debug bar (`$D020`).

---

## Summary

You have learned:

- Why multiplexing is needed (8 HW sprite limit)
- Dividing the screen into vertical zones
- Using multiple raster interrupts to update each zone
- Managing 24 logical enemies with 8 HW sprites
- Dynamic slot assignment by Y
- Calculating the CPU budget of multiplexing

## References

- [Chapter 6 — Sprite movement](06-sprite-movement-control.md) — sprite basics
- [Chapter 7 — Raster interrupt](07-raster-interrupt.md) — IRQ for zone switching
- [Chapter 19 — Kernel engine](19-reusable-kernel-engine.md) — integrated entity system
- [Solutions](../soluzioni/cap16-multiplexing.asm) — exercise solutions
