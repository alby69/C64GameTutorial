# Appendice C — Schemi Rapidi: CPU e Memoria

## CPU 6510/6502 — Modello di Programmazione

```
       ┌────────────────────────────────────────┐
       │             6510 CPU                    │
       │                                        │
       │  ┌──────────┐  ┌──────────┐            │
       │  │     A    │  │    X     │            │
       │  │ Accumul. │  │ Indice X │            │
       │  └──────────┘  └──────────┘            │
       │  ┌──────────┐  ┌──────────┐            │
       │  │     Y    │  │    SP    │            │
       │  │ Indice Y │  │ Stack Pt │            │
       │  └──────────┘  └──────────┘            │
       │  ┌──────────────────────────────────┐  │
       │  │         Status Register (P)      │  │
       │  │  N  V  -  B  D  I  Z  C          │  │
       │  │  7  6  5  4  3  2  1  0          │  │
       │  └──────────────────────────────────┘  │
       │  ┌──────────────────────────────────┐  │
       │  │      Program Counter (PC)        │  │
       │  └──────────────────────────────────┘  │
       └────────────────────────────────────────┘
```

### Flag Register (P) — Bit per bit

| Bit | Flag | Nome | =1 significa |
|-----|------|------|-------------|
| 7 | N | Negative | Risultato negativo (bit 7 = 1) |
| 6 | V | Overflow | Overflow aritmetico |
| 5 | — | (non usato) | — |
| 4 | B | Break | Interruzione software (BRK) |
| 3 | D | Decimal | Modo BCD attivo |
| 2 | I | Interrupt | Interrupt disabilitati |
| 1 | Z | Zero | Risultato uguale a zero |
| 0 | C | Carry | Riporto / prestito |

---

## Mappa Memoria — Schema a Blocchi

```
 $0000 ┌──────────────────────────┐
       │   ZERO PAGE  (256 B)     │  Accesso piu veloce, variabili di gioco
 $0100 ├──────────────────────────┤
       │   STACK (256 B)          │  LIFO, cresce verso $0100
 $0200 ├──────────────────────────┤
       │   RAM LIBERA             │  Variabili, tabelle, buffer
 $0400 ├──────────────────────────┤
       │   SCREEN RAM (1000 B)    │  Caratteri visibili a schermo
 $07F8 ├──────────────────────────┤
       │   SPRITE POINTERS (8 B)  │  8 byte per puntatori sprite
 $0800 ├──────────────────────────┤
       │   RAM PROGRAMMA          │  Qui carichiamo il nostro codice
 $A000 ├──────────────────────────┤
       │   BASIC ROM              │  (puo essere disabilitata)
 $C000 ├──────────────────────────┤
       │   RAM (swap su richiesta)│  Spazio extra se serve
 $D000 ├──────────────────────────┤
       │   VIC-II / SID / CIA     │  Registri hardware
 $E000 ├──────────────────────────┤
       │   KERNAL ROM             │  Routine di sistema
 $FFFF └──────────────────────────┘
```

---

## Layout della Pila (Stack)

Lo stack occupa `$0100`-$01FF`. Cresce verso il basso:

```
 Indirizzi alti
 ┌──── $01FF ────┐  ← SP parte da qui (S=$FF)
 │               │
 │  Dati salvati │  ↓ PHA, JSR scrivono qui
 │  (crescono    │
 │   verso il   │
 │   basso)     │
 │               │
 ├──── $0100 ────┤
 │  Limite       │
 └───────────────┘
 Indirizzi bassi
```

**Istruzioni Stack:**

| Istruzione | Effetto |
|---|---|
| `PHA` | Push A sullo stack, SP-- |
| `PLA` | SP++, Pull A dallo stack |
| `PHP` | Push flag sullo stack |
| `PLP` | Pull flag dallo stack |
| `JSR` | Push indirizzo-1, salta |
| `RTS` | Pull indirizzo, torna |
| `RTI` | Pull flag + indirizzo |

---

## Modalita di Indirizzamento 6502

```
Immediato:       LDA #$10       ; A=16, valore nell'istruzione stessa
                 ┌──────┐
                 │ $10  │
                 └──────┘

Assoluto:        LDA $D020      ; A = byte in $D020
                 ┌──────┐
                 │ $D020│─────→ [memoria]
                 └──────┘

Zero Page:       LDA $02        ; A = byte in $0002 (1 byte indirizzo, piu veloce)
                 ┌──────┐
                 │ $02  │─────→ [$0002]
                 └──────┘

Indicizzato X:   LDA $0400,X    ; A = byte in $0400 + X
                 ┌──────┐
                 │$0400 │─┬─→ [$0400 + X]
                 └──────┘ │
                          X

Indiretto:       LDA ($02),Y    ; A = byte in (indirizzo in $02/$03) + Y
                 ┌──────┐
                 │ $02  │─────→ [indirizzo] + Y
                 └──────┘
```

### Tabella Cicli CPU per Modalita

| Modalita | Byte | Cicli | Esempio |
|---|---|---|---|
| Immediato | 2 | 2 | `LDA #$10` |
| Zero Page | 2 | 3 | `LDA $02` |
| Zero Page,X | 2 | 4 | `LDA $02,X` |
| Assoluto | 3 | 4 | `LDA $D020` |
| Assoluto,X | 3 | 4+ | `LDA $0400,X` |
| Indicizzato Y | 2 | 5+ | `LDA ($02),Y` |

---

## Diagramma di Esecuzione Istruzione

```
 1. FETCH     → Prende l'opcode dalla memoria (PC)
 2. DECODE    → Capisce che istruzione e
 3. EXECUTE   → Esegue l'operazione (ALU, memoria, registri)
 4. STORE     → Salva il risultato
               ───→ Riparte dal passo 1 con PC incrementato
```

### Esempio: LDA $D020

```
Ciclo 1: FETCH opcode ($AD) da $8000
Ciclo 2: FETCH indirizzo basso ($20) da $8001
Ciclo 3: FETCH indirizzo alto ($D0) da $8002
Ciclo 4: LEGGE byte da $D020 → A
```

---

## Registri CIA (Joystick)

```
 $DC00  ┌──────────────────────────────┐
        │  PORTA JOYSTICK 2            │
        │  (bit 0-4 = direzioni/fuoco) │
 $DC01  ├──────────────────────────────┤
        │  PORTA JOYSTICK 1            │
        │  (stessa codifica)           │
 ───────┴──────────────────────────────┘

 JOYSTICK PORTA 1 ($DC01):
 Bit:  7  6  5  4   3    2    1    0
       x  x  x  FIRE DXS  SX   GIU  SU
                |    |    |    |    |
                |    |    |    |    +── 0 = Su premuto
                |    |    |    +─────── 0 = Giu premuto
                |    |    +──────────── 0 = Sinistra premuto
                |    +───────────────── 0 = Destra premuto
                +────────────────────── 0 = Fuoco premuto

 NOTA: Attivi bassi! 0 = premuto, 1 = rilasciato
```
