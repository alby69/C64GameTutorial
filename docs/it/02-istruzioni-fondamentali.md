# Capitolo 2 — Istruzioni Fondamentali del 6502

## Obiettivi

Al termine di questo capitolo saprai:

- Usare le modalita di indirizzamento del 6502
- Dichiarare variabili in Zero Page
- Usare `INX`, `DEX`, `INC`, `DEC`
- Confrontare valori con `CMP`
- Salti condizionati con `BEQ`, `BNE`
- Creare contatori e cicli

---

## 2.1 Come vede la memoria il 6502

Il 6510 (compatibile 6502) indirizza 64 KB. Ogni indirizzo contiene un byte (0-255).

```
$00 = 0        $0A = 10
$10 = 16       $20 = 32
$FF = 255
```

### Notazione esadecimale

In TMP il simbolo `$` indica un valore esadecimale:

```asm
LDA #$10    ; carica il valore 16 (non 10!)
```

| Decimale | Esadecimale |
|---|---|
| 0 | `$00` |
| 1 | `$01` |
| 10 | `$0A` |
| 16 | `$10` |
| 32 | `$20` |
| 100 | `$64` |
| 255 | `$FF` |

---

## 2.2 Modalita di indirizzamento

Il 6502 ha diverse modalita per leggere/scrivere dati.

### Immediato (`#`)

Il valore e nella stessa istruzione:

```asm
LDA #10     ; A = 10 (carica il NUMERO 10)
```

### Assoluto

L'indirizzo del dato segue l'istruzione:

```asm
LDA $D020   ; A = valore letto da $D020
STA $D020   ; scrive A in $D020
```

### Zero Page

Come assoluto, ma l'indirizzo e nei primi 256 byte (usa meno cicli CPU):

```asm
LDA $02     ; A = valore letto da $0002
STA $02     ; scrive A in $0002
```

> **Vantaggio:** Le istruzioni in Zero Page sono piu veloci e occupano meno byte.

### Indicizzato con X/Y

```asm
LDA $0400,X ; A = valore a ($0400 + X)
STA $D800,Y ; scrive A a ($D800 + Y)
```

---

## 2.3 Variabili in Zero Page

Possiamo dare nomi simbolici agli indirizzi:

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

## 2.4 Incrementare e decrementare

### `INX` / `INY` — Incrementa X o Y

```asm
LDX #0
INX         ; X = 1
INX         ; X = 2
```

### `DEX` / `DEY` — Decrementa X o Y

```asm
LDX #10
DEX         ; X = 9
DEX         ; X = 8
```

### `INC` / `DEC` — Incrementa/Decrementa in memoria

```asm
INC $D020   ; colore bordo +1
DEC $D021   ; colore sfondo -1
```

---

## 2.5 Confronti e salti condizionati

### `CMP` — Confronta A con un valore

`CMP` sottrae il valore da A **senza modificare A**, ma impostando i flag della CPU.

```asm
LDA #10
CMP #10     ; A == 10? Si → Zero flag = 1
CMP #5      ; A >= 5?  Si → Carry flag = 1
```

### `BEQ` — Branch if EQual

Salta se il confronto precedente ha dato uguaglianza:

```asm
LDA #10
CMP #10
BEQ UGUALE  ; salta a UGUALE perche A == 10
```

### `BNE` — Branch if Not Equal

Salta se il confronto NON ha dato uguaglianza:

```asm
LDA #5
CMP #10
BNE DIVERSO ; salta perche A != 10
```

### Tabella dei salti condizionati

| Istruzione | Salta se... |
|---|---|
| `BEQ` | A == valore (Zero = 1) |
| `BNE` | A != valore (Zero = 0) |
| `BCC` | A < valore (Carry = 0) |
| `BCS` | A >= valore (Carry = 1) |
| `BMI` | Risultato negativo (Negative = 1) |
| `BPL` | Risultato positivo (Negative = 0) |

---

## 2.6 Primo contatore

```asm
*=$8000

START
    LDX #0      ; X = 0 (inizializza contatore)

LOOP
    STX $D020   ; copia X nel bordo (cambia colore!)
    INX         ; X = X + 1
    JMP LOOP    ; ripeti
```

Il bordo andra da nero a bianco a rosso... fino al colore 255 poi ricomincia.

---

## 2.7 Ciclo con confronto

Facciamo un ciclo che conta da 0 a 10:

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

## 2.8 Delay software (ritardo)

Per rallentare il programma e renderlo visibile:

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

Questo ciclo produce circa 255 × 255 = ~65000 iterazioni.

### Uso del delay:

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

> **💡 ESEMPIO SVOLTO — Rainbow effetto**
> Questo esempio combina tutto quello che hai imparato finora. Non e un esercizio,
> ma un riferimento da studiare prima di affrontare gli esercizi qui sotto.

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

## Esercizi

### Esercizio 1
Scrivi un programma che incrementi il bordo da 0 a 15 e poi si fermi (ciclo infinito alla fine).

### Esercizio 2
Scrivi un programma che tenga il contatore in Zero Page (es. `COUNTER = $02`) invece che in X.

### Esercizio 3
Crea un delay di circa 1 secondo (suggerimento: 3 cicli annidati).

### Esercizio 4
Fai lampeggiare lo sfondo tra blu e nero ogni secondo circa.

### Esercizio 5
Realizza l'effetto rainbow: il bordo deve scorrere attraverso tutti i colori in un ciclo infinito, usando un delay per rallentare il cambiamento (vedi "Esempio svolto" nella sezione 2.9).

---

## Riepilogo

Hai imparato:

- Modalita di indirizzamento (immediato, assoluto, Zero Page, indicizzato)
- Variabili in Zero Page
- `INX`, `DEX`, `INC`, `DEC`
- `CMP`, `BEQ`, `BNE`
- Creare contatori e cicli
- Delay software
- Strutturare il programma con sottoroutine (`JSR`)

## Riferimenti

- [Capitolo 1 — Introduzione](01-introduzione-c64-tmp.md) — prime istruzioni, memoria C64
- [Capitolo 3 — Indirizzamento e cicli](03-indirizzamento-cicli-ritardi.md) — modalita di indirizzamento avanzate
- [Soluzioni](../soluzioni/cap02-istruzioni.asm) — soluzioni degli esercizi
