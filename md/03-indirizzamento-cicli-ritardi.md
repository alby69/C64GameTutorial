# Capitolo 3 — Indirizzamento, Cicli e Prime Routine Grafiche

> **Comandi introdotti:** `PHA`, `PLA`, `PHP`, `PLP`, `TSX`, `TXS`, `ROL`, `ROR`, `JSR`.

## Obiettivi

Al termine di questo capitolo saprai:

- Usare la Zero Page come variabile veloce
- Scrivere caratteri sullo schermo
- Usare lo Stack con `PHA` e `PLA`
- Creare array con `LDA` indicizzato
- Usare le istruzioni di rotazione `ROL` e `ROR`
- Strutturare il programma con `JSR` e `RTS`

---

## 3.1 La Zero Page in dettaglio

La Zero Page (`$0000`-`$00FF`) e la RAM piu veloce del C64. Le istruzioni che accedono alla Zero Page usano **meno byte** e **meno cicli CPU**.

| Istruzione | Byte | Cicli |
|---|---|---|
| `LDA $C000` (assoluto) | 3 | 4 |
| `LDA $02` (Zero Page) | 2 | 3 |

### Definire variabili in Zero Page

```asm
; Variabili di gioco (mettere all'inizio del sorgente)
PLAYER_X    = $02
PLAYER_Y    = $03
SCORE_LOW   = $04
SCORE_HIGH  = $05
TEMP        = $06
FRAME_CNT   = $07
```

> **Nota bene:** I primi byte della Zero Page (`$00`-$01) e `$FF` sono usati dal sistema. Inizia da `$02` per sicurezza.

---

## 3.2 Lo Stack

Lo stack occupa `$0100`-`$01FF`. Cresce verso il basso (da `$01FF` a `$0100`).

### Istruzioni per lo Stack

```asm
PHA     ; Push A nello stack
PLA     ; Pull (carica) A dallo stack

PHP     ; Push flag nello stack
PLP     ; Pull flag dallo stack

JSR     ; salva indirizzo di ritorno nello stack
RTS     ; recupera indirizzo e torna indietro
```

### Esempio

```asm
    LDA #10
    PHA         ; salva A (10) nello stack

    LDA #20     ; A = 20
    ; ... fai cose ...

    PLA         ; recupera A: A = 10
```

> Lo stack e **LIFO** (Last In, First Out). L'ultimo valore salvato e il primo restituito.

---

## 3.3 Rotazioni: ROL e ROR

Queste istruzioni spostano i bit a sinistra o destra, facendo passare il bit che "esce" attraverso il Carry.

### `ROL` (Rotate Left)
```asm
SEC         ; Carry = 1
LDA #%10000000
ROL A       ; A = %00000001, Carry = 1
```

### `ROR` (Rotate Right)
```asm
CLC         ; Carry = 0
LDA #%00000001
ROR A       ; A = %00000000, Carry = 1
```

---

## 3.4 Scrivere sullo schermo

La memoria video (Screen RAM) inizia a `$0400`. Ogni byte rappresenta un carattere PETSCII.

### Coordinate schermo

```
40 colonne × 25 righe = 1000 caratteri
```

Formula per calcolare l'indirizzo:

```
indirizzo = $0400 + (riga × 40) + colonna
```

### Esempio: scrivere 'A' in alto a sinistra

Il codice PETSCII della 'A' e 1:

```asm
*=$C000

START
    LDA #1          ; codice PETSCII per 'A'
    STA $0400       ; angolo superiore sinistro

LOOP
    JMP LOOP
```

### Scrivere con colore

I colori dei caratteri si trovano in `$D800`-`$DBE7`:

```asm
*=$C000

START
    LDA #1          ; carattere 'A'
    STA $0400

    LDA #7          ; colore giallo
    STA $D800       ; colore del primo carattere

LOOP
    JMP LOOP
```

---

## 3.5 Scrivere in qualsiasi posizione

Calcoliamo l'indirizzo per riga 5, colonna 10:

```
indirizzo = $0400 + (5 × 40) + 10
          = $0400 + 200 + 10
          = $0400 + 210
          = $04D2
```

```asm
*=$C000

START
    LDA #1          ; 'A'
    STA $04D2       ; riga 5, colonna 10

    LDA #7          ; giallo
    STA $D8D2       ; colore corrispondente

LOOP
    JMP LOOP
```

---

## 3.6 Riempire lo schermo con un ciclo

Usiamo l'indirizzamento indicizzato per riempire righe di caratteri:

```asm
*=$C000

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

### Riempire con colori diversi

```asm
*=$C000

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

## 3.7 Array e tabelle in memoria

Possiamo creare dati predefiniti con `.byte`:

```asm
*=$C000

START
    LDX #0

LOOP
    LDA TABELLA,X   ; legge dalla tabella
    STA $0400,X     ; scrive sullo schermo
    INX
    CPX #5
    BNE LOOP
    JMP LOOP

; Dati (messi dopo il codice, a $C000 + ...)
TABELLA
    .byte 1, 2, 3, 4, 5   ; A, B, C, D, E in PETSCII
```

---

## 3.8 Primo effetto grafico animato

Combiniamo tabella, ciclo e delay:

```asm
*=$C000

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

## 3.9 Struttura professionale con JSR

Per giochi seri, il codice va suddiviso in sottoroutine:

```asm
*=$C000

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

## Esercizi

### Esercizio 1
Scrivi 'A' in riga 10, colonna 15. Poi cambiane il colore in verde.

### Esercizio 2
Scrivi le lettere A B C D nelle prime 4 celle dello schermo.

### Esercizio 3
Riempi tutte le 40 celle della prima riga con il carattere '*' (codice 42). Ogni cella deve avere un colore diverso.

### Esercizio 4
Crea una tabella con i numeri da 0 a 9 e visualizzali nelle prime 10 posizioni dello schermo.

### Esercizio 5
Fai scorrere un messaggio di 4 lettere sullo schermo, spostandolo a destra di una posizione ogni secondo.

---

## Riepilogo

Hai imparato:

- Usare la Zero Page per variabili veloci
- Scrivere caratteri sullo schermo con indirizzamento assoluto e indicizzato
- Usare lo Stack
- Creare tabelle dati con `.byte`
- Strutturare il programma con `JSR`
- Cancellare lo schermo con un ciclo

## Riferimenti

- [Capitolo 2 — Istruzioni fondamentali](02-istruzioni-fondamentali.md) — loop, confronti, CMP/BEQ
- [Capitolo 4 — Memoria video](04-memoria-video-e-caratteri.md) — puntare a schermo con indicizzato
- [Soluzioni](../soluzioni/cap03-indirizzamento.asm) — soluzioni degli esercizi
