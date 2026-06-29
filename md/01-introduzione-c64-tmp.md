# Capitolo 1 — Introduzione al C64 e Turbo Macro Pro

## Obiettivi

Al termine di questo capitolo saprai:

- Cos'è il processore 6510 del Commodore 64
- Come funziona la memoria del C64
- Come creare un progetto in Turbo Macro Pro (TMP)
- Come assemblare ed eseguire un programma
- Come scrivere il tuo primo programma funzionante

---

## 1.1 Il processore del Commodore 64

Il C64 utilizza un processore **MOS 6510**, variante del famoso **6502**.

```
Caratteristica      Valore
─────────────────────────────────
Frequenza PAL       ~0.985 MHz
Registri generali   A, X, Y
Stack               256 byte
Spazio indirizzi    64 KB
```

### I registri della CPU

**Accumulatore (A)** — Il registro piu importante. Tutte le operazioni aritmetiche e logiche passano da qui.

```
LDA #10     ; carica il valore 10 nel registro A
```

**Registro X** — Usato spesso come contatore o indice.

```
LDX #0      ; carica 0 in X
```

**Registro Y** — Molto simile a X.

```
LDY #0      ; carica 0 in Y
```

---

## 1.2 La memoria del C64

Il processore vede 65536 indirizzi: da `$0000` a `$FFFF` (0 a 65535).

### Mappa semplificata

```
  $0000 ┌──────────────────────┐
         │ Zero Page (256 byte) │  RAM piu veloce
  $0100 ├──────────────────────┤
         │ Stack (256 byte)     │
  $0200 ├──────────────────────┤
         │ RAM libera           │
  $0400 ├──────────────────────┤
         │ Screen RAM (video)   │
  $0801 ├──────────────────────┤
         │ Programmi BASIC      │
  $A000 ├──────────────────────┤
         │ BASIC ROM            │
  $D000 ├──────────────────────┤
         │ VIC-II / SID / CIA   │  Chip hardware
  $E000 ├──────────────────────┤
         │ KERNAL ROM           │
  $FFFF └──────────────────────┘
```

### Zone che useremo spesso

| Zona | Indirizzo | Cosa contiene |
|---|---|---|
| **Zero Page** | `$0000`-`$00FF` | RAM veloce per variabili |
| **Screen RAM** | `$0400` | Caratteri sullo schermo |
| **Color RAM** | `$D800` | Colore di ogni carattere |
| **VIC-II** | `$D000`-`$D3FF` | Grafica e sprite |
| **Bordo** | `$D020` | Colore del bordo |
| **Sfondo** | `$D021` | Colore dello sfondo |

---

## 1.3 Turbo Macro Pro (TMP)

TMP e un assembler con editor integrato per C64. Permette di:

- Scrivere codice assembly
- Assemblarlo (tasto `A` o `3`)
- Salvarlo su disco
- Eseguirlo direttamente (tasto `Run`)

### La direttiva `ORG`

```
*=$8000      ; il codice inizia all'indirizzo $8000
```

Oppure:

```
*=$C000      ; indirizzo alternativo per programmi grandi
```

---

## 1.4 Primo programma

Il programma Assembly piu piccolo possibile:

```asm
*=$8000

START
    RTS
```

### Analisi riga per riga

| Istruzione | Significato |
|---|---|
| `*=$8000` | Il codice verra assemblato a partire da $8000 (32768) |
| `START` | Etichetta (label) — TMP associa a questa label l'indirizzo $8000 |
| `RTS` | **R**e**T**urn from **S**ubroutine — termina il programma |

### Come eseguire

Da TMP:

```
A         (Assemble)
Run       (Esegui)
```

Oppure da BASIC:

```
SYS 32768
SYS $8000
```

---

## 1.5 Scrivere nella memoria del C64

Facciamo qualcosa di visibile: cambiamo il **colore del bordo**.

Registro del bordo: `$D020`

```asm
*=$8000

START
    LDA #2      ; carica il valore 2 (rosso) in A
    STA $D020   ; scrive A nel registro del bordo

    RTS
```

### Spiegazione

`LDA #2` — **L**oa**D** **A**ccumulator: carica il valore 2 nell'accumulatore A.

`STA $D020` — **ST**ore **A**ccumulator: copia A nella locazione di memoria `$D020`.

Risultato: `D020 = 2` → bordo rosso.

---

## 1.6 Colori del C64

| Valore | Colore |
|---|---|
| 0 | Nero |
| 1 | Bianco |
| 2 | Rosso |
| 3 | Ciano |
| 4 | Viola |
| 5 | Verde |
| 6 | Blu |
| 7 | Giallo |
| 8 | Arancione |
| 9 | Marrone |
| 10 | Rosa chiaro |
| 11 | Grigio scuro |
| 12 | Grigio medio |
| 13 | Verde chiaro |
| 14 | Blu chiaro |
| 15 | Grigio chiaro |

---

## 1.7 Cambiare bordo e sfondo

Lo sfondo si controlla con `$D021`:

```asm
*=$8000

START
    LDA #6      ; colore blu
    STA $D020   ; bordo blu

    LDA #0      ; colore nero
    STA $D021   ; sfondo nero

    RTS
```

---

## 1.8 Creare un ciclo infinito

Nei giochi il programma rimane in esecuzione per sempre. Usiamo `JMP`.

```asm
*=$8000

START
    LDA #2      ; bordo rosso
    STA $D020

LOOP
    JMP LOOP    ; salta sempre a LOOP — ciclo infinito
```

---

## 1.9 Struttura tipica di un programma TMP

Da subito conviene usare una struttura ordinata:

```asm
*=$8000

; ----------------------------------
; INIZIALIZZAZIONE
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
; ROUTINE
; ----------------------------------
INIT
    RTS

UPDATE
    RTS
```

Questa sara la struttura che utilizzeremo per tutto il corso.

---

## Esercizi

### Esercizio 1
Scrivi un programma che imposti bordo giallo e sfondo blu.

### Esercizio 2
Scrivi un programma che imposti bordo verde e resti in ciclo infinito.

### Esercizio 3
Modifica il programma per usare una label chiamata `GAMELOOP` invece di `LOOP`.

### Esercizio 4
Scrivi un programma che faccia ciclare il bordo attraverso tutti i colori da 0 a 15, uno dopo l'altro, in un ciclo infinito.

### Esercizio 5
Scrivi un programma con la struttura `MAIN`/`UPDATE`: `MAIN` chiama `UPDATE` con `JSR`, `UPDATE` incrementa il bordo e torna con `RTS`, `MAIN` ripete in loop.

> **Soluzioni:** [le soluzioni sono nella cartella `soluzioni/`]

---

## Riepilogo

Hai imparato:

- Il processore 6510 e i suoi registri (A, X, Y)
- La mappa di memoria del C64
- Le istruzioni `LDA`, `STA`, `JMP`, `RTS`
- Come creare, assemblare ed eseguire un programma in TMP
- Come modificare bordo (`$D020`) e sfondo (`$D021`)
- La struttura base di un programma per videogiochi

## Riferimenti

- [Capitolo 2 — Istruzioni fondamentali](02-istruzioni-fondamentali.md) — registri, confronti, delay
- [Capitolo 3 — Indirizzamento e cicli](03-indirizzamento-cicli-ritardi.md) — tabelle, stack, sottoroutine
- [Soluzioni](../soluzioni/cap01-introduzione.asm) — soluzioni degli esercizi
