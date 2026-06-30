# Capitolo 4 — Memoria Video e Caratteri

## Obiettivi

Al termine di questo capitolo saprai:

- Come funziona la memoria video del C64
- Scrivere testo a schermo con formule di posizione
- Usare i colori in modo avanzato
- Creare schermate statiche per menu e HUD
- Costruire semplici animazioni testuali

---

## 4.1 Layout dello schermo testo

Il C64 in modalita testo mostra:

```
40 colonne × 25 righe = 1000 caratteri
```

### Mappa della memoria video

```
Indirizzo        Contenuto
─────────────────────────────────────
$0400-$0427      Riga 0 (colonne 0-39)
$0428-$044F      Riga 1
$0450-$0477      Riga 2
...              ...
$07C0-$07E7      Riga 24 (ultima)
```

### Indirizzo colore corrispondente

```
Colore del carattere in $0400 → $D800
Colore del carattere in $0428 → $D828
                  ...               ...
Formula:  $D800 + offset = $D800 + (indirizzo_carattere - $0400)
```

---

## 4.2 Calcolare la posizione a schermo

### Formula completa

```
offset  = (riga × 40) + colonna
indirizzo_carattere = $0400 + offset
indirizzo_colore    = $D800 + offset
```

### Esempi

| Riga | Colonna | Offset | Carattere | Colore |
|---|---|---|---|---|
| 0 | 0 | 0 | `$0400` | `$D800` |
| 0 | 39 | 39 | `$0427` | `$D827` |
| 12 | 20 | 500 | `$05F4` | `$D9F4` |
| 24 | 0 | 960 | `$07C0` | `$DBC0` |
| 24 | 39 | 999 | `$07E7` | `$DBE7` |

---

## 4.3 Scrivere una stringa a schermo

```asm
*=$8000

START
    LDX #0
LOOP
    LDA TESTO,X     ; legge carattere
    BEQ FINE        ; se 0, fine stringa
    STA $0400,X     ; scrive a schermo
    INX
    JMP LOOP

FINE
    JMP FINE

TESTO
    .byte 1, 0      ; "A" + terminatore (0)
```

### Stringa piu lunga

```asm
TESTO
    .byte 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
    .byte 11, 12, 13, 14, 15, 16, 17, 18
    .byte 19, 20, 21, 22, 23, 24, 25, 26
    .byte 0          ; terminatore
```

---

## 4.4 Scrivere in una riga specifica

```asm
*=$8000

; Scrive "CIAO" alla riga 12, colonna 18

START
    LDA #1          ; C
    STA $05F2       ; $0400 + (12*40) + 18 = $05F2

    LDA #9          ; I (PETSCII)
    STA $05F3

    LDA #1          ; A
    STA $05F4

    LDA #15         ; O (PETSCII)
    STA $05F5

    ; Colori: tutti gialli
    LDA #7
    STA $D9F2
    STA $D9F3
    STA $D9F4
    STA $D9F5

LOOP
    JMP LOOP
```

> **Nota:** I codici PETSCII possono differire dall'ASCII standard. La lettera 'A' = 1, 'B' = 2, ecc. Consulta una tabella PETSCII.

---

## 4.5 HUD: creare un pannello informativo

In molti giochi c'e un HUD (Heads-Up Display) in alto o in basso. Vediamo come creare bordi e testo:

```asm
*=$8000

START
    JSR DRAW_HUD
LOOP
    JMP LOOP

DRAW_HUD
    ; Colora tutta la prima riga di blu su sfondo giallo
    LDX #0
HUD_LOOP
    LDA #$20        ; spazio pieno (carattere 32)
    STA $0400,X     ; prima riga

    LDA #1          ; colore bianco per il bordo
    STA $D800,X
    INX
    CPX #40
    BNE HUD_LOOP

    ; Scrivi "SCORE: 0000" a partire da riga 0, col 2
    LDA #19         ; S
    STA $0402
    LDA #3          ; C
    STA $0403
    LDA #15         ; O
    STA $0404
    LDA #18         ; R
    STA $0405
    LDA #5          ; E
    STA $0406
    LDA #26         ; :
    STA $0407

    RTS
```

---

## 4.6 Animazione testuale semplice

Facciamo lampeggiare un messaggio modificando il colore:

```asm
*=$8000

START
    LDA #0
    STA $D020       ; bordo nero

    ; Scrivi un messaggio fisso
    LDA #1
    STA $0540       ; riga 5, col 0
    LDA #2
    STA $0541
    LDA #3
    STA $0542
    LDA #4
    STA $0543
    ; ... altri caratteri ...

LOOP
    INC $D800       ; anima colore primo carattere
    JSR DELAY
    JMP LOOP

DELAY
    LDX #$30
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

## 4.7 Cancellare lo schermo (CLS)

Routine universale per pulire lo schermo:

```asm
CLEAR_SCREEN
    LDX #0
    TXA             ; A = 0
CLS_LOOP
    STA $0400,X
    STA $0500,X
    STA $0600,X
    STA $06E8,X     ; fino a $07E8 (1000 byte)
    INX
    CPX #250        ; 4 × 250 = 1000
    BNE CLS_LOOP
    RTS
```

---

## 4.8 Scrivere numeri a schermo

Per mostrare il punteggio serve convertire un numero in caratteri:

```asm
; Converte il valore in A (0-99) in due caratteri e li scrive
; in $0400 (decine) e $0401 (unita)

WRITE_NUMBER
    LDX #0          ; contatore decine
DIV_LOOP
    CMP #10
    BCC DONE_DIV
    SBC #10
    INX
    JMP DIV_LOOP

DONE_DIV
    ; X = decine, A = unita
    TXA
    CLC
    ADC #$30        ; converti in PETSCII numero
    STA $0400

    TYA             ; recupera unita
    CLC
    ADC #$30
    STA $0401
    RTS
```

> **Nota:** I numeri PETSCII 0-9 corrispondono ai codici $30-$39.

---

## 4.9 Combinare testo e sprite

Nei giochi, testo e sprite convivono. Ecco un esempio che prepara lo schermo e poi passa al loop di gioco:

```asm
*=$8000

; ---- Variabili ----
SCORE       = $02
SCORE_TXT   = $03   ; puntatore per conversioni

; ---- Programma ----
START
    JSR CLEAR_SCREEN
    JSR DRAW_HUD
    JSR INIT_PLAYER

MAINLOOP
    JSR UPDATE
    JSR DRAW_SPRITES
    JMP MAINLOOP

CLEAR_SCREEN
    LDX #0
    LDA #$20        ; spazio
CLS
    STA $0400,X
    STA $0500,X
    STA $0600,X
    STA $06E8,X
    INX
    BNE CLS
    RTS

DRAW_HUD
    LDX #0
    LDA #$60        ; carattere BORDO superiore
    STA $0400,X
    INX
    CPX #40
    BNE DRAW_HUD-2
    RTS

INIT_PLAYER
    ; ... setup sprite giocatore ...
    RTS

UPDATE
    ; ... logica di gioco ...
    RTS

DRAW_SPRITES
    ; ... aggiornamento sprite ...
    RTS
```

---

## Esercizi

### Esercizio 1
Scrivi il tuo nome alla riga 10, centrato (calcola la colonna di partenza come `(40 - lunghezza) / 2`).

### Esercizio 2
Crea un effetto "matrix" che faccia cadere caratteri casuali dalla prima all'ultima riga.

### Esercizio 3
Costruisci una semplice schermata titolo con bordo decorato e testo "GIOCO ARCADE" centrato.

### Esercizio 4
Scrivi il numero 42 (in decimale) in alto a destra dello schermo.

### Esercizio 5
Crea un effetto "scrolling marquee": scrivi "CIAO" alla riga 0 e fallo scorrere verso destra di una posizione ogni secondo.

---

## Riepilogo

Hai imparato:

- Il layout della memoria video (`$0400`-`$07E7`)
- Calcolare posizioni con la formula `$0400 + riga×40 + colonna`
- Colorare i caratteri con `$D800 + offset`
- Creare un HUD
- Animare il testo modificando i colori
- Cancellare lo schermo con cicli
- Convertire numeri per visualizzarli

## Riferimenti

- [Capitolo 5 — Sprite hardware](05-sprite-hardware-vic-ii.md) — sprite pointer e visualizzazione
- [Capitolo 13 — Punteggio](13-punteggio-e-stati-gioco.md) — visualizzare punteggio a video
- [Soluzioni](../soluzioni/cap04-memoria-video.asm) — soluzioni degli esercizi
