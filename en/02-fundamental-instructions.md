# Chapter 2 — Fundamental Instructions

## Objectives

By the end of this chapter you will know:

- How to use the 6502 addressing modes
- How to declare Zero Page variables
- How to use `INX`, `DEX`, `INC`, `DEC`
- How to compare values with `CMP`
- Conditional branches with `BEQ`, `BNE`
- How to create counters and loops

---

## 2.1 How the 6502 sees memory

The 6510 (6502-compatible) addresses 64 KB. Each address holds one byte (0-255).

```
$00 = 0        $0A = 10
$10 = 16       $20 = 32
$FF = 255
```

### Hexadecimal notation

In TMP the `$` symbol indicates a hexadecimal value:

```asm
LDA #$10    ; carica il valore 16 (non 10!)
```

| Decimal | Hexadecimal |
|---|---|
| 0 | `$00` |
| 1 | `$01` |
| 10 | `$0A` |
| 16 | `$10` |
| 32 | `$20` |
| 100 | `$64` |
| 255 | `$FF` |

---

## 2.2 Addressing modes

The 6502 has several modes for reading/writing data.

### Immediate (`#`)

The value is in the instruction itself:

```asm
LDA #10     ; A = 10 (carica il NUMERO 10)
```

### Absolute

The data address follows the instruction:

```asm
LDA $D020   ; A = valore letto da $D020
STA $D020   ; scrive A in $D020
```

### Zero Page

Like absolute, but the address is in the first 256 bytes (uses fewer CPU cycles):

```asm
LDA $02     ; A = valore letto da $0002
STA $02     ; scrive A in $0002
```

> **Advantage:** Zero Page instructions are faster and take fewer bytes.

### Indexed with X/Y

```asm
LDA $0400,X ; A = valore a ($0400 + X)
STA $D800,Y ; scrive A a ($D800 + Y)
```

---

## 2.3 Zero Page variables

We can give symbolic names to addresses:

```asm
; Definizioni inizio programma
XPOS    = $02
YPOS    = $03
TEMP    = $04

; Uso nel codice
    LDA #100
    STA XPOS    ; equivalente a STA $02

    LDA #50
    STA YPOS    ; equivalente a STA $03
```

---

## 2.4 Increment and decrement

### `INX` / `INY` — Increment X or Y

```asm
LDX #0
INX         ; X = 1
INX         ; X = 2
```

### `DEX` / `DEY` — Decrement X or Y

```asm
LDX #10
DEX         ; X = 9
DEX         ; X = 8
```

### `INC` / `DEC` — Increment/Decrement in memory

```asm
INC $D020   ; colore bordo +1
DEC $D021   ; colore sfondo -1
```

---

## 2.5 Comparisons and conditional branches

### `CMP` — Compare A with a value

`CMP` subtracts the value from A **without modifying A**, but sets the CPU flags.

```asm
LDA #10
CMP #10     ; A == 10? Si → Zero flag = 1
CMP #5      ; A >= 5?  Si → Carry flag = 1
```

### `BEQ` — Branch if EQual

Jumps if the previous comparison was equal:

```asm
LDA #10
CMP #10
BEQ UGUALE  ; salta a UGUALE perche A == 10
```

### `BNE` — Branch if Not Equal

Jumps if the comparison was NOT equal:

```asm
LDA #5
CMP #10
BNE DIVERSO ; salta perche A != 10
```

### Conditional branch table

| Instruction | Jump if... |
|---|---|
| `BEQ` | A == value (Zero = 1) |
| `BNE` | A != value (Zero = 0) |
| `BCC` | A < value (Carry = 0) |
| `BCS` | A >= value (Carry = 1) |
| `BMI` | Negative result (Negative = 1) |
| `BPL` | Positive result (Negative = 0) |

---

## 2.6 First counter

```asm
*=$8000

START
    LDX #0      ; X = 0 (inizializza contatore)

LOOP
    STX $D020   ; copia X nel bordo (cambia colore!)
    INX         ; X = X + 1
    JMP LOOP    ; ripeti
```

The border will go from black to white to red... up to color 255, then it wraps around.

---

## 2.7 Loop with comparison

Let's make a loop that counts from 0 to 10:

```asm
*=$8000

START
    LDX #0      ; contatore = 0

LOOP
    STX $D020   ; mostra il contatore sul bordo
    INX         ; contatore++
    CPX #10     ; abbiamo raggiunto 10?
    BNE LOOP    ; se no, continua

FINE
    JMP FINE    ; ciclo infinito (fine)
```

---

## 2.8 Software delay

To slow down the program and make it visible:

```asm
DELAY
    LDX #$FF    ; carica 255
D1
    LDY #$FF    ; carica 255
D2
    DEY
    BNE D2      ; ciclo interno: 255 iterazioni
    DEX
    BNE D1      ; ciclo esterno: 255 iterazioni
    RTS
```

This loop produces about 255 × 255 = ~65000 iterations.

### Using the delay:

```asm
*=$8000

START
    LDA #2
    STA $D020

LOOP
    INC $D020   ; cambia colore
    JSR DELAY   ; aspetta
    JMP LOOP

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

## 2.9 Rainbow effect (worked example)

Let's combine everything we've learned:

```asm
*=$8000

START
    LDA #0
    STA $D020   ; bordo nero

LOOP
    INC $D020   ; cambia colore
    JSR DELAY
    JMP LOOP

DELAY
    LDX #$20    ; ridotto per velocita media
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
Write a program that increments the border from 0 to 15 and then stops (infinite loop at the end).

### Exercise 2
Write a program that keeps the counter in Zero Page (e.g. `COUNTER = $02`) instead of X.

### Exercise 3
Create a delay of about 1 second (hint: 3 nested loops).

### Exercise 4
Make the background flash between blue and black every second or so.

### Exercise 5
Create the rainbow effect: the border should cycle through all colors in an infinite loop, using a delay to slow down the change (see "Worked example" in section 2.9).

---

## Summary

You have learned:

- Addressing modes (immediate, absolute, Zero Page, indexed)
- Zero Page variables
- `INX`, `DEX`, `INC`, `DEC`
- `CMP`, `BEQ`, `BNE`
- Creating counters and loops
- Software delays
- Structuring programs with subroutines (`JSR`)

## References

- [Chapter 1 — Introduction](01-introduzione-c64-tmp.md) — first instructions, C64 memory
- [Chapter 3 — Addressing and loops](03-indirizzamento-cicli-ritardi.md) — advanced addressing modes
- [Solutions](../soluzioni/cap02-istruzioni.asm) — exercise solutions
