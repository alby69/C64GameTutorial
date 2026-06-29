# Capitolo 17 — Raster Split e Profondita Finta (Parallax)

## Obiettivi

Al termine di questo capitolo saprai:

- Usare il raster split per effetti multizona
- Creare un finto parallax scrolling
- Cambiare colore e scroll a meta schermo
- Separare HUD dall'area di gioco
- Creare l'illusione di profondita

---

## 17.1 Raster Split Multi-Zona

Il raster split permette di cambiare i registri VIC-II **mentre** lo schermo viene disegnato.

```
         ┌──────────────────────┐
Zona 0   │ HUD (sfondo BLU)     │ ← IRQ 1 cambia colore
         │                      │
Zona 1   │ Area di gioco        │ ← IRQ 2 cambia scroll
         │ (sfondo NERO)        │
         │                      │
Zona 2   │ Barra informativa    │ ← IRQ 3 cambia colore
         │ (sfondo GRIGIO)      │
         └──────────────────────┘
```

### Setup a 3 zone

```asm
INIT_SPLIT
    SEI
    LDA #$7F
    STA $DC0D

    LDA #<IRQ_SPLIT1
    STA $0314
    LDA #>IRQ_SPLIT1
    STA $0315

    LDA #40              ; HUD fino a riga 40
    STA $D012

    LDA $D011
    AND #$7F
    STA $D011

    LDA #1
    STA $D01A
    CLI
    RTS

; ----------------------------------
; IRQ 1: inizio area gioco
; ----------------------------------
IRQ_SPLIT1
    ; Cambia sfondo per HUD (blu)
    LDA #6
    STA $D021

    ; Prepara prossimo split
    LDA #200
    STA $D012
    LDA #<IRQ_SPLIT2
    STA $0314
    LDA #>IRQ_SPLIT2
    STA $0315

    LDA $D019
    STA $D019
    JMP $EA31

; ----------------------------------
; IRQ 2: barra inferiore
; ----------------------------------
IRQ_SPLIT2
    ; Cambia sfondo per barra info (grigio)
    LDA #12
    STA $D021

    ; Torna a IRQ 1 per prossimo frame
    LDA #40
    STA $D012
    LDA #<IRQ_SPLIT1
    STA $0314
    LDA #>IRQ_SPLIT1
    STA $0315

    LDA $D019
    STA $D019
    JMP $EA31
```

---

## 17.2 HUD separato dal gioco

L'HUD (Heads-Up Display) rimane fisso mentre il gioco scorre sotto:

```asm
; Setup: zona HUD (righe 0-39) e zona gioco (righe 40-199)

IRQ_SPLIT
    ; Arrivati a riga 40: zona gioco
    ; Cambia colore sfondo
    LDA #0
    STA $D021           ; sfondo nero per il gioco

    ; Se necessario, cambia banco caratteri
    ; ... logica opzionale ...

    ; Re-installa
    LDA #0
    STA $D012
    LDA #<IRQ_SPLIT_END
    STA $0314
    LDA #>IRQ_SPLIT_END
    STA $0315

    LDA $D019
    STA $D019
    JMP $EA31

IRQ_SPLIT_END
    ; Fine schermo: torna colore HUD
    LDA #6
    STA $D021

    LDA #40
    STA $D012
    LDA #<IRQ_SPLIT
    STA $0314
    LDA #>IRQ_SPLIT
    STA $0315

    LDA $D019
    STA $D019
    JMP $EA31
```

---

## 17.3 Scrolling con raster split

Possiamo fare scorrere lo sfondo in modo diverso per ogni zona:

```asm
; Registri di scroll VIC-II
; $D016: scroll orizzontale (bit 0-2 = fine scroll, bit 3 = 40/38 colonne)
; $D011: bit 4-5 = scroll verticale fine

IRQ_SCROLL
    ; Zona 0: nessuno scroll (HUD fisso)
    LDA #$C8            ; 40 colonne, scroll 0
    STA $D016

    ; Prepara zona 1 (gioco)
    LDA #100
    STA $D012
    LDA #<IRQ_SCROLL2
    STA $0314
    LDA #>IRQ_SCROLL2
    STA $0315

    LDA $D019
    STA $D019
    JMP $EA31

IRQ_SCROLL2
    ; Zona 1: scroll orizzontale variabile
    LDA SCROLL_X
    STA $D016           ; scroll fine

    ; Torna su
    LDA #0
    STA $D012
    LDA #<IRQ_SCROLL
    STA $0314
    LDA #>IRQ_SCROLL
    STA $0315

    LDA $D019
    STA $D019
    JMP $EA31
```

---

## 17.4 Fake Parallax Scrolling

Il C64 non ha scrolling multilayer hardware. Simuliamo la profondita cosi:

```
         Velocita diversa per ogni "layer":
Strato 0 (cielo):    scroll lentissimo (cambio colore ogni 8 frame)
Strato 1 (montagne): scroll lento (cambio ogni 4 frame)
Strato 2 (suolo):    scroll normale (ogni frame)
Strato 3 (sprite):   movimento libero (sprite HW)
```

```asm
; Ogni N frame, cambiamo lo sfondo per simulare movimento

SCROLL_TIMER = $40
SCROLL_X    = $41

UPDATE_PARALLAX
    INC SCROLL_TIMER
    LDA SCROLL_TIMER
    AND #7                  ; ogni 8 frame
    BNE CHECK_MID

    ; Layer 0 (cielo): cambia colore sfondo lentamente
    LDA SKY_COLOR
    INC
    AND #15
    STA SKY_COLOR
    STA $D021

CHECK_MID
    LDA SCROLL_TIMER
    AND #3                  ; ogni 4 frame
    BNE DO_SCROLL

    ; Layer 1 (mid): cambia caratteri di sfondo
    ; ... logica per shiftare tile ...

DO_SCROLL
    ; Layer 2 (suolo): scroll ogni frame
    INC SCROLL_X
    LDA SCROLL_X
    AND #7
    STA $D016               ; scroll VIC fine

    RTS
```

---

## 17.5 Multi-colore di sfondo per zona

Cambiamo colore dello sfondo piu volte per creare un effetto "cielo che sfuma":

```asm
; Palette del cielo (8 colori per 8 zone)
SKY_PALETTE
    .byte 6, 6, 14, 1, 7, 7, 1, 14

IRQ_SKY
    LDX SKY_INDEX
    LDA SKY_PALETTE,X
    STA $D021

    INC SKY_INDEX
    LDA SKY_INDEX
    CMP #8
    BNE SKY_NEXT

    LDA #0
    STA SKY_INDEX

SKY_NEXT
    ; Prossima riga split
    CLC
    LDA $D012
    ADC #4                  ; 4 righe dopo
    STA $D012

    ; Re-installa se stesso
    LDA #<IRQ_SKY
    STA $0314
    LDA #>IRQ_SKY
    STA $0315

    LDA $D019
    STA $D019
    JMP $EA31
```

---

## 17.6 Schermata di gioco completa con split

```asm
*=$2000

START
    SEI
    JSR INIT_SPLIT
    JSR INIT_GAME
    CLI

MAINLOOP
    JMP MAINLOOP

INIT_SPLIT
    LDA #$7F
    STA $DC0D

    LDA #<IRQ_TOP
    STA $0314
    LDA #>IRQ_TOP
    STA $0315

    LDA #40
    STA $D012

    LDA $D011
    AND #$7F
    STA $D011

    LDA #1
    STA $D01A
    RTS

; ----------------------------------
; HUD (righe 0-39, sfondo blu)
; ----------------------------------
IRQ_TOP
    PHA
    TXA
    PHA
    TYA
    PHA

    LDA #6
    STA $D021               ; sfondo blu

    JSR DRAW_HUD

    ; Prepara zona gioco
    LDA #200
    STA $D012
    LDA #<IRQ_BOTTOM
    STA $0314
    LDA #>IRQ_BOTTOM
    STA $0315

    PLA
    TAY
    PLA
    TAX
    PLA

    LDA $D019
    STA $D019
    JMP $EA31

; ----------------------------------
; Area gioco (righe 40-199, sfondo nero)
; + barra info (righe 200+, sfondo grigio)
; ----------------------------------
IRQ_BOTTOM
    PHA
    TXA
    PHA
    TYA
    PHA

    LDA #0
    STA $D021               ; sfondo nero per gioco

    JSR UPDATE_GAME
    JSR UPDATE_SPRITES

    LDA #40
    STA $D012
    LDA #<IRQ_TOP
    STA $0314
    LDA #>IRQ_TOP
    STA $0315

    PLA
    TAY
    PLA
    TAX
    PLA

    LDA $D019
    STA $D019
    JMP $EA31

INIT_GAME
    ; ... inizializza gioco ...
    RTS

DRAW_HUD
    ; ... disegna HUD ...
    RTS

UPDATE_GAME
    ; ... logica gioco ...
    RTS

UPDATE_SPRITES
    ; ... aggiorna sprite ...
    RTS
```

---

## 17.7 Illusione di profondita

Tecniche per dare profondita visiva:

```
1. Parallax: strati a velocita diverse
2. Sfumatura colore: cielo piu scuro in alto
3. Dimensione sprite: nemici piccoli in alto, grandi in basso
4. Priorita sprite: $D01B per mettere sprite dietro/frontali
```

### Priorita sprite-sfondo (`$D01B`)

```asm
; Mette sprite 0 DIETRO lo sfondo
LDA #%00000001
STA $D01B
```

### Dimensione variabile per profondita

```asm
; Nemici in alto (lontani) = sprite normale
; Nemici in basso (vicini) = sprite espanso

LDA ENEMY_Y,X
CMP #100
BCS BIG_ENEMY

; Normale
LDA $D017
AND #%11111110          ; sprite 0 non espanso
STA $D017
JMP DONE_SIZE

BIG_ENEMY
LDA $D017
ORA #%00000001          ; sprite 0 espanso
STA $D017

DONE_SIZE
```

---

## Esercizi

### Esercizio 1
Dividi lo schermo in 3 zone con 3 colori di sfondo diversi.

### Esercizio 2
Crea un HUD fisso in alto (punteggio) e l'area di gioco sotto con colore diverso.

### Esercizio 3
Implementa lo scrolling fine (`$D016`) che si incrementa ogni frame e si azzera a 7.

### Esercizio 4
Fai un finto parallax: cambia il colore dello sfondo ogni 8 frame (cielo che si muove).

### Esercizio 5
Usa $D01B per far passare uno sprite "dietro" un elemento dello sfondo.

---

## Riepilogo

Hai imparato:

- Raster split con 3+ zone
- HUD fisso separato dall'area di gioco
- Scrolling VIC-II fine (`$D016`)
- Fake parallax con cambio colore e tile
- Palette del cielo con sfumatura
- Priorita sprite/sfondo (`$D01B`)
- Illusione di profondita con dimensione sprite

## Riferimenti

- [Capitolo 7 — Raster interrupt](07-raster-interrupt.md) — setup IRQ per split
- [Capitolo 16 — Sprite multiplexing](16-sprite-multiplexing.md) — zone raster multiple
- [Capitolo 19 — Kernel engine](19-kernel-engine-riutilizzabile.md) — scheduler a priorita
- [Soluzioni](../soluzioni/cap17-parallax-raster-split.asm) — soluzioni degli esercizi
