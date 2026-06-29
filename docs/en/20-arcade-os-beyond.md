# Chapter 20 — Towards an Arcade OS and Beyond

## Objectives

By the end of this chapter you will know:

- Advanced Arcade OS Kernel concepts
- How interrupt chaining works
- What self-modifying code is
- How to evolve your engine
- Where to find resources to go further

---

## 20.1 Evolution into an Arcade OS

Combining the Kernel Engine (ch. 19) with advanced rendering leads to the concept of **Arcade OS**: a micro operating system that runs the game as a scheduled process.

```
┌─────────────────────────────────────┐
│ ARCADE OS KERNEL                    │
│  - Priority scheduler               │
│  - Raster interrupt management      │
│  - VIC resource time-slicing        │
├─────────────────────────────────────┤
│ SUBSYSTEMS                          │
│  - Sprite Virtualization Layer      │
│  - Raster Split Manager             │
│  - Unified Scroll Engine            │
│  - Audio Engine                     │
├─────────────────────────────────────┤
│ GAME (scheduled task)               │
│  - Enemy AI                         │
│  - Collisions                       │
│  - Game logic                       │
└─────────────────────────────────────┘
```

### The raster as scheduler

The heart of the Arcade OS is not a loop. It is the **raster interrupt** that becomes the system clock:

```
Raster 0-50   → Game logic (AI, physics, collisions)
Raster 50-150 → Sprite multiplexing (zone A)
Raster 150-230→ Sprite multiplexing (zone B), scroll
Raster 230-250→ Audio update, end-of-frame cleanup
```

---

## 20.2 Interrupt Chaining

Instead of a single IRQ, we can create a **chain of interrupts**:

```asm
; Each IRQ installs the next handler

IRQ_CHAIN_0
    PHA
    JSR GAME_LOGIC

    ; Install next
    LDA #<IRQ_CHAIN_1
    STA $0314
    LDA #>IRQ_CHAIN_1
    STA $0315

    LDA #80
    STA $D012

    PLA
    LDA $D019
    STA $D019
    JMP $EA31

IRQ_CHAIN_1
    PHA
    JSR SPRITE_ZONE_A

    LDA #<IRQ_CHAIN_2
    STA $0314
    LDA #>IRQ_CHAIN_2
    STA $0315

    LDA #160
    STA $D012

    PLA
    LDA $D019
    STA $D019
    JMP $EA31

IRQ_CHAIN_2
    PHA
    JSR SPRITE_ZONE_B
    JSR AUDIO_UPDATE

    LDA #<IRQ_CHAIN_0
    STA $0314
    LDA #>IRQ_CHAIN_0
    STA $0315

    LDA #0
    STA $D012

    PLA
    LDA $D019
    STA $D019
    JMP $EA31
```

---

## 20.3 Self-Modifying Code

A powerful (but dangerous) technique: code that modifies itself.

```asm
; Example: patching an instruction at runtime

    ; Based on state, change the jump target
    LDA GAME_STATE
    ASL
    TAX
    LDA JUMP_TABLE,X
    STA PATCH_ADDR
    LDA JUMP_TABLE+1,X
    STA PATCH_ADDR+1

    ; The JMP will be modified before execution
PATCH_ADDR
    JMP $0000          ; gets overwritten

JUMP_TABLE
    .word MENU_UPDATE
    .word PLAY_UPDATE
    .word GAMEOVER_UPDATE
```

### Why use it?

- Speed: avoids comparisons in hot paths
- Flexibility: changes behavior at runtime
- Compact code

### Why avoid it (if possible)

- Hard to debug
- Does not work on ROM
- Dangerous on C64 (code in RAM)

---

## 20.4 Sprite Virtualization Layer

Advanced concept: instead of thinking about HW sprites, we work with **virtual sprites**:

```asm
; Virtual sprite pool (max 32)
VSPRITE_X   = $0300    ; 32 bytes
VSPRITE_Y   = $0320    ; 32 bytes
VSPRITE_TYPE = $0340   ; 32 bytes
VSPRITE_ACTIVE = $0360 ; 32 bytes

MAX_VSPRITE = 32

; The kernel automatically maps virtual sprites
; onto the 8 hardware sprites using multiplexing

RESOLVE_VSPRITES
    ; Sort by Y
    ; Assign to 8 HW slots
    ; Update in raster interrupts
    RTS
```

---

## 20.5 Unified Scroll Engine

A scrolling engine that handles everything:

```asm
SCROLL_X    = $F0      ; fine horizontal scroll (0-7)
SCROLL_Y    = $F1      ; fine vertical scroll (0-7)
SCROLL_MAP  = $F2      ; map pointer

UPDATE_SCROLL
    INC SCROLL_X
    LDA SCROLL_X
    CMP #8
    BNE US_DONE

    LDA #0
    STA SCROLL_X
    JSR SCROLL_MAP_X    ; coarse tilemap scroll

US_DONE
    LDA SCROLL_X
    ORA #%11001000      ; keep 40 columns + video bits
    STA $D016

    RTS

SCROLL_MAP_X
    ; Shift tilemap left by one column
    ; ... memory copy logic ...
    RTS
```

---

## 20.6 Advanced techniques summary

| Technique | Description | When to use |
|---|---|---|
| **Raster chain** | Multiple cascading IRQs | Always, for complex games |
| **Entity system** | Component arrays | Games with 10+ entities |
| **Multiplexing** | HW sprite reuse | Games with 8+ sprites |
| **Self-modify** | Self-modifying code | Hot paths, dynamic jumps |
| **Raster split** | VIC-II changes mid-screen | HUD, effects, parallax |
| **Double buffer** | Two sprite buffers | Anti-flicker |
| **Audio queue** | SID command queue | Multiple simultaneous SFX |

---

## 20.7 Checklist for a complete arcade game

```
[ ] Initial setup (IRQ, VIC, SID)
[ ] Menu/title screen
[ ] Joystick input
[ ] Player (movement, shooting)
[ ] Bullet pool
[ ] Wave system (enemy waves)
[ ] Enemy AI (movement, shooting)
[ ] Collision detection
[ ] Score and lives
[ ] Game Over / restart
[ ] Audio (SFX, basic music)
[ ] HUD (score, lives)
[ ] Transition screens
[ ] Optimizations (multiplexing if needed)
[ ] Testing and balancing
```

---

## 20.8 Where to go from here

### Resources to go deeper

| Resource | Description |
|---|---|
| **Codebase64** | C64 tutorials and code |
| **Lemon64** | C64 programming forum |
| **CSDb** | Scene Database: code examples |
| **Mapper 64** | VIC-II register documentation |
| **Programming the 6502** | Book by Rodney Zaks |

### Possible next projects

1. **Space Invaders** — with everything you have learned
2. **Galaga** — add enemy formations
3. **Pac-Man** — maze management and ghosts
4. **Arkanoid** — ball, bricks, bouncing
5. **Scroller** — horizontal scrolling game
6. **Platform** — jumping, gravity, tilemap collisions

### Final advice

```
1. Start small, finish the game
2. Make it work first, then optimize
3. Use debug raster for CPU time
4. Save often to disk!
5. Test on real hardware if possible
6. One finished game teaches more than 10 started
```

---

## Exercises

### Exercise 1
Explain the difference between interrupt chaining and polling. In which situations does one work better than the other?

### Exercise 2
Describe how sprite virtualization works: how can you manage 32 logical sprites with only 8 hardware sprites? Which component of the Arcade OS handles this?

### Exercise 3
What does self-modifying code mean? Give an example of when it can be useful and explain what risks it involves.

### Exercise 4
Draw the 3-layer architecture diagram (Kernel → Engine → Game) and explain the flow of a typical call: where it starts, which layers it traverses, what each one does.

### Exercise 5
Take the final checklist from this chapter and mentally apply it to a game you would like to develop. List: genre choice, resolution, how many sprites needed, audio type, control scheme.

> **Note:** The exercises in this chapter are conceptual and do not require assembly solutions.

---

## Summary

You have learned:

- The concept of Arcade OS as a scheduled kernel
- Interrupt chaining for multi-phase pipeline
- Self-modifying code (use and risks)
- Sprite virtualization to manage 32 sprites
- Unified scroll engine
- Complete checklist for an arcade game
- Resources to continue learning

## References

- [Chapter 19 — Kernel engine](19-reusable-kernel-engine.md) — foundation for the Arcade OS
- [Chapter 7 — Raster interrupt](07-raster-interrupt.md) — interrupt chaining
- [Chapter 16 — Sprite multiplexing](16-sprite-multiplexing.md) — sprite virtualization
- [All previous chapters](../md/) — prerequisites to get here
