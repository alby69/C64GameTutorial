# Chapter 19 — Reusable Kernel Engine

## Objectives

By the end of this chapter you will know:

- Design a kernel engine separate from game logic
- Use a 3-layer structure
- Organize memory professionally
- Create an entity update system
- Manage the game lifecycle

---

## 19.1 Why a Kernel Engine?

So far we have written "monolithic" code: everything together. For more complex games we need to separate:

```
┌─────────────────────────────────────┐
│ GAME MODULE (specific logic)        │
│ - game rules                        │
│ - enemy AI                          │
│ - scoring                           │
├─────────────────────────────────────┤
│ ENGINE SERVICES (reusable)          │
│ - sprite system                     │
│ - collisions                        │
│ - input                             │
│ - audio                             │
├─────────────────────────────────────┤
│ KERNEL CORE (fixed)                 │
│ - raster sync                       │
│ - frame control                     │
│ - interrupt handler                 │
└─────────────────────────────────────┘
```

Benefits:

- Write once, use for all games
- Fewer bugs (tested code)
- Separation of concerns
- Easier to maintain

---

## 19.2 3-layer structure

### Kernel Core (fixed, never changes)

```asm
; kernel.asm
*=$0800

KERNEL_INIT
    SEI
    JSR SETUP_IRQ
    JSR SETUP_VIC
    CLI
    RTS

KERNEL_MAIN
    JMP KERNEL_MAIN      ; everything runs in IRQ

KERNEL_IRQ
    PHA
    TXA
    PHA
    TYA
    PHA

    INC FRAME_COUNTER

    JSR ENGINE_INPUT
    JSR ENGINE_SPRITES
    JSR ENGINE_SOUND

    JSR GAME_UPDATE       ; calls the game module!

    PLA
    TAY
    PLA
    TAX
    PLA
    LDA $D019
    STA $D019
    JMP $EA31

FRAME_COUNTER = $02
```

### Engine Services (reusable)

```asm
; engine_input.asm
ENGINE_INPUT
    LDA $DC01
    EOR #$FF
    AND #%00011111
    STA JOY_STATE

    ; Edge detection
    TAX
    EOR JOY_OLD
    AND JOY_STATE
    STA JOY_EDGE
    STX JOY_OLD
    RTS

JOY_STATE = $10
JOY_OLD   = $11
JOY_EDGE  = $12
```

```asm
; engine_sprites.asm
ENGINE_SPRITES
    ; ... update multiplexing ...
    ; ... colors ...
    ; ... pointers ...
    RTS
```

### Game Module (specific)

```asm
; game_logic.asm
GAME_UPDATE
    JSR GAME_READ_INPUT
    JSR GAME_UPDATE_PLAYER
    JSR GAME_UPDATE_ENEMIES
    JSR GAME_CHECK_COLLISIONS
    JSR GAME_RENDER
    RTS
```

---

## 19.3 Jump table for the game module

The kernel calls the module through a pointer table:

```asm
; The game module defines these labels:
GAME_INIT     = $C000
GAME_UPDATE   = $C003
GAME_RENDER   = $C006
GAME_RESET    = $C009

; The kernel jumps through the table
KERNEL_CALL_GAME
    JSR (GAME_PTR)       ; jump to current routine
    RTS

GAME_PTR = $20   ; 2-byte pointer
```

---

## 19.4 Memory organization

Professional layout for a C64 game:

```
$0002-$00FF   Zero Page variables (fast)
$0100-$01FF   Stack
$0200-$03FF   Engine variables + game state
$0400-$07E7   Screen RAM (video)
$0800-$1FFF   Kernel engine (fixed)
$2000-$3FFF   Sprite data and animations
$4000-$7FFF   Game module (logic)
$8000-$9FFF   Level data, tables
$C000-$CFFF   Jump table + dispatcher
$D000-$DFFF   VIC-II / SID / CIA (hardware)
```

### Zone definitions

```asm
; kernel.asm — header with definitions

; ---- Zero Page ----
FRAME_CNT  = $02
JOY_STATE  = $03
GAME_STATE = $04
PLAYER_X   = $05
PLAYER_Y   = $06
SCORE_LO   = $07
SCORE_HI   = $08
TEMP       = $09

; ---- Extended variables ($0200+) ----
ENEMY_X    = $0200
ENEMY_Y    = $0210
ENEMY_ALIVE = $0220
BULLET_X   = $0230
BULLET_Y   = $0240
BULLET_ACTIVE = $0250

; ---- Sprite data ----
SPRITE_PTR_BASE = $2000
SPRITE_DATA_0   = $2000   ; frame 0
SPRITE_DATA_1   = $2040   ; frame 1
SPRITE_DATA_2   = $2080   ; frame 2
```

---

## 19.5 Simple Entity System

An entity has data grouped by "component":

```asm
; Entity 0: player
; Entity 1-8: enemies
; Entity 9-12: bullets

ENTITY_X       = $40     ; 16 bytes (X of each entity)
ENTITY_Y       = $50     ; 16 bytes
ENTITY_TYPE    = $60     ; 16 bytes (0=player,1=bullet,2=enemy)
ENTITY_ACTIVE  = $70     ; 16 bytes
ENTITY_SPRITE  = $80     ; 16 bytes (sprite frame)
ENTITY_HP      = $90     ; 16 bytes

MAX_ENTITIES = 16

; Entity initialization
INIT_ENTITIES
    LDX #0
    LDA #0
IE_LOOP
    STA ENTITY_ACTIVE,X
    INX
    CPX #MAX_ENTITIES
    BNE IE_LOOP

    ; Entity 0 = player
    LDA #1
    STA ENTITY_ACTIVE
    LDA #0
    STA ENTITY_TYPE
    LDA #160
    STA ENTITY_X
    LDA #180
    STA ENTITY_Y
    RTS
```

---

## 19.6 Update all entities

```asm
UPDATE_ALL_ENTITIES
    LDX #0
UAE_LOOP
    LDA ENTITY_ACTIVE,X
    BEQ UAE_NEXT

    LDA ENTITY_TYPE,X
    CMP #0
    BEQ UAE_PLAYER
    CMP #1
    BEQ UAE_BULLET
    CMP #2
    BEQ UAE_ENEMY

UAE_PLAYER
    JSR UPDATE_PLAYER_ENTITY
    JMP UAE_NEXT

UAE_BULLET
    JSR UPDATE_BULLET_ENTITY
    JMP UAE_NEXT

UAE_ENEMY
    JSR UPDATE_ENEMY_ENTITY

UAE_NEXT
    INX
    CPX #MAX_ENTITIES
    BNE UAE_LOOP
    RTS
```

### Player entity movement

```asm
UPDATE_PLAYER_ENTITY
    ; Use JOY_STATE to move entity 0
    LDA JOY_STATE
    AND #%00000001          ; UP
    BEQ UPE_DOWN
    DEC ENTITY_Y
UPE_DOWN
    LDA JOY_STATE
    AND #%00000010
    BEQ UPE_LEFT
    INC ENTITY_Y
UPE_LEFT
    LDA JOY_STATE
    AND #%00000100
    BEQ UPE_RIGHT
    DEC ENTITY_X
UPE_RIGHT
    LDA JOY_STATE
    AND #%00001000
    BEQ UPE_DONE
    INC ENTITY_X
UPE_DONE
    RTS
```

---

## 19.7 Cooperative scheduler

To manage multiple tasks without overlap:

```asm
; Table of tasks executed each frame
TASK_TABLE
    .word TASK_INPUT       ; task 0
    .word TASK_PHYSICS     ; task 1
    .word TASK_AI          ; task 2
    .word TASK_RENDER      ; task 3
    .word TASK_AUDIO       ; task 4

NUM_TASKS = 5

RUN_SCHEDULER
    LDX #0
RS_LOOP
    LDA TASK_TABLE,X       ; low byte pointer
    STA TEMP
    LDA TASK_TABLE+1,X     ; high byte
    STA TEMP+1

    JSR CALL_TASK          ; JMP (TEMP)

    INX
    INX
    CPX #NUM_TASKS*2
    BNE RS_LOOP
    RTS

CALL_TASK
    JMP (TEMP)

TEMP = $20    ; 2 bytes
```

---

## 19.8 Complete kernel flow

```asm
; kernel.asm — complete

*=$0800

; ---- INITIALIZATION ----
START
    SEI
    JSR KERNEL_SETUP
    JSR ENGINE_INIT
    JSR GAME_INIT          ; calls the game module
    CLI

    JMP MAIN_LOOP

KERNEL_SETUP
    LDA #$7F
    STA $DC0D
    LDA #<KERNEL_IRQ
    STA $0314
    LDA #>KERNEL_IRQ
    STA $0315
    LDA #250
    STA $D012
    LDA $D011
    AND #$7F
    STA $D011
    LDA #1
    STA $D01A
    RTS

MAIN_LOOP
    JMP MAIN_LOOP

; ---- MAIN IRQ ----
KERNEL_IRQ
    PHA
    TXA
    PHA
    TYA
    PHA

    INC FRAME_CNT
    JSR RUN_SCHEDULER

    PLA
    TAY
    PLA
    TAX
    PLA
    LDA $D019
    STA $D019
    JMP $EA31

; ---- ENGINE SERVICES ----
ENGINE_INIT
    JSR ENGINE_INPUT_INIT
    JSR ENGINE_SPRITE_INIT
    JSR ENGINE_AUDIO_INIT
    RTS

ENGINE_INPUT_INIT
    LDA #0
    STA JOY_STATE
    STA JOY_OLD
    RTS

ENGINE_SPRITE_INIT
    LDA #%00000001
    STA $D015
    LDA #1
    STA $D027
    RTS

ENGINE_AUDIO_INIT
    LDA #$0F
    STA $D418
    RTS
```

---

## Exercises

### Exercise 1
Separate your project into 3 files: `kernel.asm`, `engine.asm`, `game.asm`.

### Exercise 2
Create a jump table for INIT, UPDATE, RENDER of the game module.

### Exercise 3
Implement RUN_SCHEDULER with 3 tasks: INPUT, LOGIC, RENDER.

### Exercise 4
Organize all entity data into arrays (ENTITY_X, ENTITY_Y, ENTITY_ACTIVE).

### Exercise 5
Restructure your previous project to use the 3-layer architecture.

---

## Summary

You have learned:

- 3-layer architecture (Kernel, Engine, Game)
- Jump table for module calls
- Professional memory organization
- Entity system with component arrays
- Cooperative scheduler for tasks
- Separate initialization for each layer
- Separation of game logic from engine services

## References

- [Chapter 8 — Game loop](08-synchronized-game-loop.md) — basic structure that the kernel replaces
- [Chapter 16 — Sprite multiplexing](16-sprite-multiplexing.md) — Engine layer component
- [Chapter 20 — Arcade OS](20-arcade-os-beyond.md) — evolution of the kernel
- [Solutions](../soluzioni/cap19-kernel-engine.asm) — exercise solutions
