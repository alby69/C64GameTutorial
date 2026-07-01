# Chapter 1 — Introduction to C64 and Turbo Macro Pro

## Objectives

By the end of this chapter you will know:

- What the Commodore 64's 6510 processor is
- How the C64's memory works
- How to create a project in Turbo Macro Pro (TMP)
- How to assemble and run a program
- How to write your first working program

---

## 1.1 The Commodore 64 processor

The C64 uses a **MOS 6510** processor, a variant of the famous **6502**.

```
Feature             Value
─────────────────────────────────
PAL frequency       ~0.985 MHz
General registers   A, X, Y
Stack               256 bytes
Address space       64 KB
```

### CPU registers

**Accumulator (A)** — The most important register. All arithmetic and logic operations go through here.

```
LDA #10     ; load value 10 into register A
```

**X register** — Often used as a counter or index.

```
LDX #0      ; load 0 into X
```

**Y register** — Very similar to X.

```
LDY #0      ; load 0 into Y
```

---

## 1.2 The C64 memory

The processor sees 65536 addresses: from `$0000` to `$FFFF` (0 to 65535).

### Simplified map

```
  $0000 ┌──────────────────────┐
         │ Zero Page (256 bytes)│  Fastest RAM
  $0100 ├──────────────────────┤
         │ Stack (256 bytes)    │
  $0200 ├──────────────────────┤
         │ Free RAM             │
  $0400 ├──────────────────────┤
         │ Screen RAM (video)   │
  $0801 ├──────────────────────┤
         │ BASIC programs       │
  $A000 ├──────────────────────┤
         │ BASIC ROM            │
  $D000 ├──────────────────────┤
         │ VIC-II / SID / CIA   │  Hardware chips
  $E000 ├──────────────────────┤
         │ KERNAL ROM           │
  $FFFF └──────────────────────┘
```

### Areas we will use often

| Area | Address | Contains |
|---|---|---|
| **Zero Page** | `$0000`-`$00FF` | Fast RAM for variables |
| **Screen RAM** | `$0400` | Characters on screen |
| **Color RAM** | `$D800` | Color of each character |
| **VIC-II** | `$D000`-`$D3FF` | Graphics and sprites |
| **Border** | `$D020` | Border color |
| **Background** | `$D021` | Background color |

---

## 1.3 Turbo Macro Pro (TMP)

TMP is an assembler with a built-in editor for the C64. It allows you to:

- Write assembly code
- Assemble it (key `A` or `3`)
- Save it to disk
- Run it directly (key `Run`)

### The `ORG` directive

```
*=$C000      ; code starts at address $C000 (49152)
```

In the first chapters, we will use the address `$C000` (49152), a RAM area that is traditionally free on the Commodore 64 and generally compatible with Turbo Macro Pro.

---

## 1.4 First program

The smallest possible Assembly program:

```asm
*=$C000

START
    RTS
```

### Line-by-line analysis

| Instruction | Meaning |
|---|---|
| `*=$C000` | The code will be assembled starting at $C000 (49152) |
| `START` | Label — TMP associates address $C000 with this label |
| `RTS` | **R**e**T**urn from **S**ubroutine — terminates the program and returns to TMP |

### How to run

From TMP:

1. Press **←** (left arrow key, top left on the keyboard) to enter the menu.
2. Press **A** to assemble.
3. If there are no errors, press **J** (or the `Run` command) to execute.

Or from BASIC:

```
SYS 49152
```

> **Note:** The C64's BASIC V2 only accepts decimal numbers for the `SYS` command.

---

## 1.5 Writing to C64 memory

Let's do something visible: change the **border color**.

Border register: `$D020`

```asm
*=$C000

START
    LDA #2      ; load value 2 (red) into A
    STA $D020   ; write A to the border register

    RTS
```

### Explanation

`LDA #2` — **L**oa**D** **A**ccumulator: loads the value 2 into accumulator A.

`STA $D020` — **ST**ore **A**ccumulator: copies A to memory location `$D020`.

Result: `D020 = 2` → red border.

---

## 1.6 C64 colors

| Value | Color |
|---|---|
| 0 | Black |
| 1 | White |
| 2 | Red |
| 3 | Cyan |
| 4 | Purple |
| 5 | Green |
| 6 | Blue |
| 7 | Yellow |
| 8 | Orange |
| 9 | Brown |
| 10 | Light red |
| 11 | Dark gray |
| 12 | Medium gray |
| 13 | Light green |
| 14 | Light blue |
| 15 | Light gray |

---

## 1.7 Changing border and background

The background is controlled by `$D021`:

```asm
*=$C000

START
    LDA #6      ; blue color
    STA $D020   ; blue border

    LDA #0      ; black color
    STA $D021   ; black background

    RTS
```

---

## 1.8 Creating an infinite loop

In games, the program runs forever. We use `JMP`.

```asm
*=$C000

START
    LDA #2      ; red border
    STA $D020

LOOP
    JMP LOOP    ; always jump to LOOP — infinite loop
```

> **Warning:** A program with an infinite loop will never return to TMP. To regain control, you will need to press **RUN/STOP + RESTORE** or perform a reset.

---

## 1.9 Typical TMP program structure

From the start it's good to use an organized structure:

```asm
*=$C000

; ----------------------------------
; INITIALIZATION
; ----------------------------------
START
    JSR INIT

; ----------------------------------
; GAME LOOP
; ----------------------------------
MAINLOOP
    JSR UPDATE
    JMP MAINLOOP

; ----------------------------------
; ROUTINES
; ----------------------------------
INIT
    RTS

UPDATE
    RTS
```

This will be the structure we use throughout the course.

---

## Exercises

### Exercise 1
Write a program that sets the border to yellow and the background to blue.

### Exercise 2
Write a program that sets the border to green and stays in an infinite loop.

### Exercise 3
Modify the program to use a label called `GAMELOOP` instead of `LOOP`.

### Exercise 4
Write a program that cycles the border through all colors from 0 to 15, one after another, in an infinite loop.

### Exercise 5
Write a program with the `MAIN`/`UPDATE` structure: `MAIN` calls `UPDATE` with `JSR`, `UPDATE` increments the border and returns with `RTS`, `MAIN` repeats in a loop.

> **Solutions:** [solutions are in the `soluzioni/` folder]

---

## Summary

You have learned:

- The 6510 processor and its registers (A, X, Y)
- The C64 memory map
- The `LDA`, `STA`, `JMP`, `RTS` instructions
- How to create, assemble, and run a program in TMP
- How to change the border (`$D020`) and background (`$D021`)
- The basic structure of a video game program

## References

- [Chapter 2 — Fundamental instructions](02-istruzioni-fondamentali.md) — registers, comparisons, delays
- [Chapter 3 — Addressing and loops](03-indirizzamento-cicli-ritardi.md) — tables, stack, subroutines
- [Solutions](../soluzioni/cap01-introduzione.asm) — exercise solutions
