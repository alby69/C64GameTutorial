# Chapter 7 — Raster Interrupt

## Objectives

By the end of this chapter you will know:

- What the VIC-II raster beam is
- How interrupts work on the C64
- Install a raster interrupt
- Change color mid-screen
- Use multiple cascading interrupts

---

## 7.1 What is the Raster Beam

The VIC-II draws the screen one line at a time, top to bottom. The electron beam (raster beam) travels:

```
On PAL:
  312 raster lines total
  63 CPU cycles per line
  ~50 frames per second

Visible lines: 0-311
  (first 24 and last 24 are off-screen)
```

```
Row 0     → ┌──────────────────────┐
             │                      │
Row 100   → │   The beam is here    │
             │                      │
Row 199   → │                      │
             └──────────────────────┘
Row 255   → (vertical retrace)
```

### Current raster register

```asm
$D012   ; contains the current raster line (0-255)
$D011   ; bit 7 = high bit of raster (256-311)
```

```asm
LDA $D012   ; A = current row
```

---

## 7.2 What is an Interrupt

Normally the CPU executes a loop:

```
MAINLOOP
    JMP MAINLOOP   ; always does the same thing
```

An interrupt is a signal that "disturbs" the CPU:

```
1. CPU is executing MAINLOOP
2. An interrupt signal arrives
3. CPU: saves everything, runs special routine
4. CPU: returns to MAINLOOP (where it stopped)
```

### Why do we need raster interrupt?

Without interrupt: code runs unsynchronized.

With interrupt: we can execute code EXACTLY when the raster beam reaches a certain line.

```
Frame 50Hz (PAL)
│
├─ IRQ: game logic (synchronized)
├─ IRQ: music
├─ IRQ: sprite update
│
└─ wait for next frame
```

---

## 7.3 Related registers

| Register | Function |
|---|---|
| `$D012` | Raster compare line (0-255) |
| `$D011` | Bit 7: MSB of raster (lines 256-311) |
| `$D019` | Interrupt Control Register (acknowledge) |
| `$D01A` | Interrupt Enable Register |

### `$D019` — Interrupt Control

```
Bit 0: raster interrupt occurred (1 = yes)
Bit 1: sprite-background collision
Bit 2: sprite-sprite collision
Bit 3: light pen
```

To acknowledge the IRQ:

```asm
LDA $D019
STA $D019       ; writing the same value resets it
```

Or:

```asm
ASL $D019       ; left shift (compact method)
```

### `$D01A` — Interrupt Enable

```
Bit 0: 1 = enable raster interrupt
Bit 1: 1 = enable sprite-background collision IRQ
Bit 2: 1 = enable sprite-sprite collision IRQ
```

---

## 7.4 First Raster Interrupt

```asm
*=$2000

START
    SEI                     ; disable IRQ during setup

    LDA #$7F
    STA $DC0D              ; disable CIA IRQ

    LDA #<IRQ              ; IRQ vector low
    STA $0314
    LDA #>IRQ              ; IRQ vector high
    STA $0315

    LDA #100               ; raster line 100
    STA $D012

    LDA $D011
    AND #$7F               ; MSB raster = 0
    STA $D011

    LDA #1                 ; enable raster interrupt
    STA $D01A

    CLI                    ; re-enable IRQ

LOOP
    JMP LOOP               ; main program

; ----------------------------------
; IRQ ROUTINE
; ----------------------------------
IRQ
    INC $D020              ; change border color (debug)

    LDA $D019
    STA $D019              ; acknowledge IRQ

    JMP $EA31              ; jump to standard IRQ handler
```

### What happens

1. At line 100, the VIC-II generates an interrupt
2. The CPU executes `IRQ`: increments border color
3. Acknowledges the interrupt
4. Returns to the operating system (which returns to LOOP)

You'll see a colored line on screen at line 100.

---

## 7.5 Correct Acknowledge

TYPICAL MISTAKE that freezes the C64:

```asm
IRQ
    INC $D020
    RTI                     ; WRONG! no acknowledge
```

CORRECT:

```asm
IRQ
    INC $D020
    LDA $D019
    STA $D019              ; acknowledge
    JMP $EA31              ; standard IRQ chain
```

---

## 7.6 Changing color mid-screen

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

    LDA #120
    STA $D012

    LDA $D011
    AND #$7F
    STA $D011

    LDA #1
    STA $D01A

    CLI

LOOP
    JMP LOOP

IRQ
    LDA #2                 ; red
    STA $D021              ; change background

    LDA $D019
    STA $D019

    JMP $EA31
```

Result: above line 120 the background is blue (initial value), below it is red.

---

## 7.7 Two Raster Interrupts

To have two mid-screen changes, each IRQ installs the next one:

```asm
IRQ1
    LDA #6                 ; blue background
    STA $D021

    ; Install IRQ2 at line 150
    LDA #150
    STA $D012

    LDA #<IRQ2
    STA $0314
    LDA #>IRQ2
    STA $0315

    LDA $D019
    STA $D019

    JMP $EA31

IRQ2
    LDA #2                 ; red background
    STA $D021

    ; Re-install IRQ1 at line 50
    LDA #50
    STA $D012

    LDA #<IRQ1
    STA $0314
    LDA #>IRQ1
    STA $0315

    LDA $D019
    STA $D019

    JMP $EA31
```

Result:

```
line 0-49:   black background (default)
line 50-149: BLUE background
line 150+:   RED background
```

---

## 7.8 Raster Bars (classic effect)

Change the border color every few lines to create colored bars:

```asm
; IRQ1 at line 50
IRQ1
    LDA #2                 ; red
    STA $D020

    LDA #52
    STA $D012
    LDA #<IRQ2
    STA $0314
    LDA #>IRQ2
    STA $0315

    LDA $D019
    STA $D019
    JMP $EA31

; IRQ2 at line 52
IRQ2
    LDA #7                 ; yellow
    STA $D020

    LDA #54
    STA $D012
    LDA #<IRQ3
    STA $0314
    LDA #>IRQ3
    STA $0315

    LDA $D019
    STA $D019
    JMP $EA31

; IRQ3 at line 54
IRQ3
    LDA #1                 ; white
    STA $D020

    LDA #50
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

## 7.9 Debug bar for raster timing

A technique used in commercial games to see how much CPU time a routine consumes:

```asm
IRQ
    ; At the start of the routine
    LDA #2
    STA $D020              ; red border

    ; ...the routine to measure...

    LDA #0
    STA $D020              ; black border (end)

    LDA $D019
    STA $D019
    JMP $EA31
```

The width of the red band on the left border indicates the time taken.

---

## Exercises

### Exercise 1
Create a raster interrupt at line 50 that changes the border to red.

### Exercise 2
Create two IRQs: one at line 50 (red border), one at line 150 (blue border).

### Exercise 3
Create a raster bar with 4 consecutive lines of different colors.

### Exercise 4
Use the raster interrupt to change the background every frame from blue to black (flash effect).

### Exercise 5
Make a single character on screen flash by changing its color via raster interrupt.

---

## Summary

You have learned:

- What the raster beam and `$D012` register are
- How interrupts work on the C64
- Installing a raster interrupt with vector `$0314/$0315`
- The importance of acknowledge on `$D019`
- Changing color mid-screen
- Using multiple cascading IRQs
- Raster bars and CPU debugging

## References

- [Chapter 8 — Game loop](08-synchronized-game-loop.md) — integrating IRQ into the main loop
- [Chapter 17 — Raster split](17-parallax-raster-split.md) — multiple raster zones
- [Chapter 20 — Arcade OS](20-arcade-os-beyond.md) — interrupt chaining
- [Solutions](../soluzioni/cap07-raster.asm) — exercise solutions
