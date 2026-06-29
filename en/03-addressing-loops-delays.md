# Chapter 3 — Addressing, Loops, and Delays

## Objectives

By the end of this chapter you will know:

- How to use the Zero Page as fast variables
- How to write characters to the screen
- How to use the Stack with `PHA` and `PLA`
- How to create arrays with indexed `LDA`
- How to structure a program with `JSR`

---

## 3.1 The Zero Page in detail

The Zero Page (`$0000`-`$00FF`) is the fastest RAM on the C64. Instructions that access the Zero Page use **fewer bytes** and **fewer CPU cycles**.

| Instruction | Bytes | Cycles |
|---|---|---|
| `LDA $C000` (absolute) | 3 | 4 |
| `LDA $02` (Zero Page) | 2 | 3 |

### Defining variables in Zero Page

```asm
; Variabili di gioco (mettere all'inizio del sorgente)
PLAYER_X    = $02
PLAYER_Y    = $03
SCORE_LOW   = $04
SCORE_HIGH  = $05
TEMP        = $06
FRAME_CNT   = $07
```

> **Note:** The first bytes of the Zero Page (`$00`-`$01`) and `$FF` are used by the system. Start at `$02` to be safe.

---

## 3.2 The Stack

The stack occupies `$0100`-`$01FF`. It grows downward (from `$01FF` to `$0100`).

### Stack instructions

```asm
PHA     ; Push A onto the stack
PLA     ; Pull (load) A from the stack

PHP     ; Push flags onto the stack
PLP     ; Pull flags from the stack

JSR     ; save return address on the stack
RTS     ; retrieve address and return
```

### Example

```asm
    LDA #10
    PHA         ; save A (10) on the stack

    LDA #20     ; A = 20
    ; ... do things ...

    PLA         ; restore A: A = 10
```

> The stack is **LIFO** (Last In, First Out). The last value saved is the first one retrieved.

---

## 3.3 Writing to the screen

The screen memory (Screen RAM) starts at `$0400`. Each byte represents a PETSCII character.

### Screen coordinates

```
40 columns × 25 rows = 1000 characters
```

Formula to calculate the address:

```
address = $0400 + (row × 40) + column
```

### Example: write 'A' at the top-left

The PETSCII code for 'A' is 1:

```asm
*=$8000

START
    LDA #1          ; codice PETSCII per 'A'
    STA $0400       ; angolo superiore sinistro

LOOP
    JMP LOOP
```

### Writing with color

Character colors are located at `$D800`-`$DBE7`:

```asm
*=$8000

START
    LDA #1          ; carattere 'A'
    STA $0400

    LDA #7          ; colore giallo
    STA $D800       ; colore del primo carattere

LOOP
    JMP LOOP
```

---

## 3.4 Writing at any position

Let's calculate the address for row 5, column 10:

```
address = $0400 + (5 × 40) + 10
        = $0400 + 200 + 10
        = $0400 + 210
        = $04D2
```

```asm
*=$8000

START
    LDA #1          ; 'A'
    STA $04D2       ; riga 5, colonna 10

    LDA #7          ; giallo
    STA $D8D2       ; colore corrispondente

LOOP
    JMP LOOP
```

---

## 3.5 Filling the screen with a loop

We use indexed addressing to fill rows of characters:

```asm
*=$8000

START
    LDX #0          ; contatore = 0
    LDA #1          ; carattere 'A'

LOOP
    STA $0400,X     ; scrive alla posizione $0400 + X
    INX
    CPX #40         ; prime 40 celle (una riga)
    BNE LOOP

DONE
    JMP DONE
```

### Filling with different colors

```asm
*=$8000

START
    LDX #0

LOOP
    LDA #1
    STA $0400,X     ; carattere

    TXA
    STA $D800,X     ; colore = numero colonna (0-39)

    INX
    CPX #40
    BNE LOOP

DONE
    JMP DONE
```

---

## 3.6 Arrays and tables in memory

We can create predefined data with `.byte`:

```asm
*=$8000

START
    LDX #0

LOOP
    LDA TABELLA,X   ; legge dalla tabella
    STA $0400,X     ; scrive sullo schermo
    INX
    CPX #5
    BNE LOOP
    JMP LOOP

; Dati (messi dopo il codice, a $8000 + ...)
TABELLA
    .byte 1, 2, 3, 4, 5   ; A, B, C, D, E in PETSCII
```

---

## 3.7 First animated graphic effect

We combine a table, a loop, and a delay:

```asm
*=$8000

START
    LDX #0

SCROLL
    LDA MESSAGGIO,X
    STA $0400       ; scrive a sinistra
    JSR DELAY
    INC $0400       ; sposta a destra? No, usiamo INC per variare
    INX
    CPX #13
    BNE SCROLL

    JMP START       ; ricomincia

MESSAGGIO
    .byte 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13

DELAY
    LDX #$FF
D1
    LDY #$FF
D2
    DEY
    BNE D2
    DEX
    BNE D1
    RTS
```

---

## 3.8 Professional structure with JSR

For serious games, code should be split into subroutines:

```asm
*=$8000

; ----------------------------------
; INIT
; ----------------------------------
START
    JSR INIT
    JSR SETUP_SCREEN

; ----------------------------------
; GAME LOOP
; ----------------------------------
MAINLOOP
    JSR UPDATE
    JSR DRAW
    JSR DELAY
    JMP MAINLOOP

; ----------------------------------
; ROUTINE
; ----------------------------------
INIT
    LDA #0
    STA $D020       ; bordo nero
    LDA #6
    STA $D021       ; sfondo blu
    RTS

SETUP_SCREEN
    LDX #0
    LDA #1
CLS
    STA $0400,X
    STA $0500,X
    STA $0600,X
    STA $0700,X
    INX
    BNE CLS         ; riempie tutta la screen RAM
    RTS

UPDATE
    INC $D020       ; anima il bordo
    RTS

DRAW
    ; qui disegneremo sprite e caratteri
    RTS

DELAY
    LDX #$10
D1
    LDY #$FF
D2
    DEY
    BNE D2
    DEX
    BNE D1
    RTS
```

---

## Exercises

### Exercise 1
Write 'A' at row 10, column 15. Then change its color to green.

### Exercise 2
Write the letters A B C D in the first 4 cells of the screen.

### Exercise 3
Fill all 40 cells of the first row with the character '*' (code 42). Each cell must have a different color.

### Exercise 4
Create a table with the numbers 0 to 9 and display them in the first 10 screen positions.

### Exercise 5
Scroll a 4-letter message across the screen, moving it one position to the right every second.

---

## Summary

You have learned:

- How to use the Zero Page for fast variables
- How to write characters to the screen with absolute and indexed addressing
- How to use the Stack
- How to create data tables with `.byte`
- How to structure a program with `JSR`
- How to clear the screen with a loop

## References

- [Chapter 2 — Basic Instructions](02-istruzioni-fondamentali.md) — loops, comparisons, CMP/BEQ
- [Chapter 4 — Video Memory](04-memoria-video-e-caratteri.md) — pointing to the screen with indexed addressing
- [Solutions](../soluzioni/cap03-indirizzamento.asm) — exercise solutions
