# Capitolo 24 — Scrolling su C64

## Obiettivi

Al termine di questo capitolo saprai:

- Usare lo scrolling hardware del VIC-II
- Implementare scrolling fine (1-8 pixel)
- Implementare scrolling grossolano (tilemap)
- Creare uno scrolling orizzontale smooth
- Gestire split-screen con diverse velocita di scroll
- Usare lo scrolling verticale

---

## 24.1 Registri di Scroll del VIC-II

Il VIC-II ha due registri chiave per lo scrolling:

```
$D016 — controllo orizzontale (bit 0-2: scroll fine X)
  bit 3:  0=38 colonne, 1=40 colonne
  bit 4:  1=multicolor mode
  bit 5-7: non usati

$D011 — controllo verticale (bit 0-2: scroll fine Y)
  bit 3:  1=25 righe, 0=24 righe (ECM/BMM)
  bit 4:  1=character map a $2000
  bit 5:  1=bitmap mode
  bit 6:  1=extended color mode
  bit 7:  raster line MSB
```

### Valori tipici

```asm
; 40 colonne, nessuno scroll
LDA #%11001000
STA $D016

; 38 colonne (bordo si allarga)
LDA #%11000000
STA $D016

; Scroll orizzontale di 3 pixel
LDA #%11001011
STA $D016
;               ^^^— scroll fine X (0-7)
```

---

## 24.2 Scrolling Orizzontale Fine

Lo scroll fine sposta il contenuto video di 1-7 pixel a sinistra.

```asm
; Scrolling orizzontale continuo
*= $C000

    ; Setup schermo con una riga di caratteri
    LDA #$01
    STA $D021           ; sfondo bianco
    LDA #$0B
    STA $D020           ; bordo grigio

    ; Scrivi una riga di testo
    LDX #0
FILL
    LDA #$41            ; carattere "A"
    STA $0400+40*12,X
    INX
    CPX #40
    BNE FILL

    ; Loop di scroll
SCROLL_LOOP
    ; Scorri da 0 a 7 pixel
    LDA SCROLL_X
    STA $D016           ; bit 0-2 = scroll fine

    INC SCROLL_X
    LDA SCROLL_X
    AND #7
    STA SCROLL_X

    ; Ritardo per renderlo visibile
    LDX #0
DELAY
    NOP
    NOP
    INX
    BNE DELAY

    JMP SCROLL_LOOP

SCROLL_X
    .byte 0
```

---

## 24.3 Scrolling con Raster Split

Possiamo avere zone diverse con scroll diverso:

```asm
; Split screen: HUD fisso in alto, area scrollabile sotto
*= $C000

    SEI
    LDA #<SCROLL_IRQ
    STA $0314
    LDA #>SCROLL_IRQ
    STA $0315
    LDA #40             ; IRQ a riga 40
    STA $D012
    LDA #1
    STA $D01A
    CLI

    ; HUD statico (40 colonne)
    LDA #%11001000
    STA $D016

    JMP MAIN_LOOP

SCROLL_IRQ
    ; Cambia scroll per la zona di gioco
    LDA SCROLL_VALUE
    ORA #%11001000
    STA $D016

    LDA $D019
    STA $D019
    RTI

MAIN_LOOP
    INC SCROLL_VALUE
    LDA SCROLL_VALUE
    AND #7
    STA SCROLL_VALUE

    ; Aspetta il frame
    LDA FRAME_CNT
WAIT
    CMP FRAME_CNT
    BEQ WAIT
    JMP MAIN_LOOP

SCROLL_VALUE
    .byte 0
FRAME_CNT
    .byte 0

; IRQ incrementa FRAME_CNT (codice omesso per brevita)
```

---

## 24.4 Scrolling Grossolano (Tilemap)

Quando lo scroll fine arriva a 7, dobbiamo shiftare la mappa:

```asm
; Scroll grossolano: muove l'intera screen RAM
COARSE_SCROLL
    LDA COARSE_X
    CMP #40            ; fine della mappa?
    BEQ CS_RESET

    ; Shift screen RAM a sinistra di una colonna
    LDX #0
CS_LOOP
    LDA $0400+1,X      ; prendi carattere a destra
    STA $0400,X        ; spostalo a sinistra
    LDA $D801,X
    STA $D800,X
    INX
    CPX #39*25-1
    BNE CS_LOOP

    ; Inserisci nuova colonna a destra
    ; (qui: leggi dalla tilemap)
    LDA #$41           ; carattere "A"
    STA $0400+39
    LDA #5
    STA $D800+39

    INC COARSE_X
CS_RESET
    RTS

COARSE_X
    .byte 0
```

### Integrazione scroll fine + grossolano

```asm
UPDATE_SCROLL
    INC FINE_X
    LDA FINE_X
    AND #7
    STA FINE_X
    BNE US_DONE        ; non serve grossolano

    JSR COARSE_SCROLL  ; ogni 8 pixel, shift mappa

US_DONE
    LDA FINE_X
    ORA #%11001000
    STA $D016
    RTS

FINE_X
    .byte 0
```

---

## 24.5 Scrolling Verticale

Lo scrolling verticale funziona come quello orizzontale,
ma usa $D011 bit 0-2:

```asm
; Scroll verticale fine
VERTICAL_SCROLL
    INC FINE_Y
    LDA FINE_Y
    AND #7
    STA FINE_Y

    ; Prepara valore $D011
    LDA #$1B           ; 25 righe, bitmap off, screen $0400
    ORA FINE_Y         ; aggiungi scroll fine Y
    STA $D011
    RTS

FINE_Y
    .byte 0
```

Per scroll verticale grossolano, bisogna shiftare le righe
della screen RAM verso l'alto o il basso:

```asm
; Scroll verticale grossolano (su)
COARSE_VERTICAL_UP
    LDX #0
CVU_LOOP
    LDA $0400+40,X     ; riga successiva
    STA $0400,X        ; sovrascrivi riga corrente
    LDA $D800+40,X
    STA $D800,X
    INX
    CPX #40*24
    BNE CVU_LOOP

    ; Nuova ultima riga vuota
    LDX #0
CVU_NEW
    LDA #$20
    STA $0400+40*24,X
    INX
    CPX #40
    BNE CVU_NEW
    RTS
```

---

## 24.6 Scrolling Smooth Completo

Unendo scroll fine + grossolano, otteniamo scrolling smooth:

```asm
SMOOTH_SCROLL_UPDATE
    ; Incrementa scroll fine X
    INC SCROLL_FINE_X
    LDA SCROLL_FINE_X
    AND #7
    STA SCROLL_FINE_X
    BNE SS_APPLY

    ; Ogni 8 frame: shift mappa e incrementa tile counter
    JSR COARSE_SCROLL
    INC MAP_OFFSET

SS_APPLY
    LDA SCROLL_FINE_X
    ORA #%11001000
    STA $D016
    RTS

SCROLL_FINE_X
    .byte 0

MAP_OFFSET
    .byte 0
```

---

## 24.7 Parallax con Scroll

Due layer che scorrono a velocita diverse:

```asm
; Parallax: sfondo + primo piano
; (usando raster split per cambiare scroll a meta schermo)

PARALLAX_IRQ_1
    ; Zona superiore: cielo (scroll lento)
    LDA SKY_SCROLL
    ORA #%11001000
    STA $D016

    LDA #<PARALLAX_IRQ_2
    STA $0314
    LDA #>PARALLAX_IRQ_2
    STA $0315
    LDA #100
    STA $D012

    LDA $D019
    STA $D019
    JMP $EA31

PARALLAX_IRQ_2
    ; Zona inferiore: terreno (scroll veloce)
    LDA GROUND_SCROLL
    ORA #%11001000
    STA $D016

    LDA #<PARALLAX_IRQ_1
    STA $0314
    LDA #>PARALLAX_IRQ_1
    STA $0315
    LDA #0
    STA $D012

    LDA $D019
    STA $D019
    JMP $EA31

SKY_SCROLL
    .byte 0

GROUND_SCROLL
    .byte 0

GAME_LOOP
    ; Aggiorna scroll a velocita diverse
    INC SKY_SCROLL
    LDA SKY_SCROLL
    AND #7
    STA SKY_SCROLL

    INC GROUND_SCROLL
    INC GROUND_SCROLL     ; 2x piu veloce!
    LDA GROUND_SCROLL
    AND #7
    STA GROUND_SCROLL

    JMP GAME_LOOP
```

---

## Riepilogo

| Registro | Cosa controlla | Bit |
|---|---|---|
| `$D016` | Scroll orizzontale fine (0-7), 38/40 colonne | 0-2: scroll X, 3: 40/38 col |
| `$D011` | Scroll verticale fine (0-7), 24/25 righe, modalita | 0-2: scroll Y |
| `$D012` | Linea raster per IRQ (usato per split) | 0-7: linea |
| Screen RAM | Shift dei caratteri per scroll grossolano | — |

---

## Esercizi

### Esercizio 1
Scrivi un programma che fa scorrere una riga di caratteri da destra a sinistra usando solo $D016 (scroll fine).

### Esercizio 2
Aggiungi scroll grossolano: quando lo scroll fine arriva a 7, shift la screen RAM e resetta.

### Esercizio 3
Implementa raster split: HUD fisso in alto (40 colonne) e area gioco scrollabile sotto.

### Esercizio 4
Crea scrolling verticale continuo: una colonna di caratteri che scorre verso l'alto.

### Esercizio 5
Implementa parallax a 2 layer con raster split: cielo (scroll lento) e terreno (scroll veloce).

---

## Riferimenti

- [Capitolo 17 — Parallax](17-parallax-e-raster-split.md) — base per raster split e parallax
- [Capitolo 7 — Raster Interrupt](07-raster-interrupt.md) — setup IRQ per split
- [Appendice A](appendice-a-tabelle.md) — registri VIC-II ($D016, $D011)
- [Soluzioni](../soluzioni/cap24-scrolling.asm) — soluzioni degli esercizi
