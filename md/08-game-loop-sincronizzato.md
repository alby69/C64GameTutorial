# Capitolo 8 — Game Loop Sincronizzato a 50 Hz

## Obiettivi

Al termine di questo capitolo saprai:

- Sincronizzare il gioco a 50 frame al secondo
- Usare un frame counter
- Animare ogni N frame
- Creare l'architettura standard di un gioco C64
- Separare logica e rendering

---

## 8.1 Perche sincronizzare?

Senza sincronizzazione, il loop gira alla massima velocita della CPU (~1 MHz). Risultato:

- Movimenti troppo veloci
- Flickering dello schermo
- Animazioni instabili
- Comportamento diverso su PAL vs NTSC

Con sincronizzazione a 50 Hz (PAL):

```
Ogni frame dura 1/50 di secondo = 20ms
Il loop esegue ESATTAMENTE 50 volte al secondo
Movimenti e animazioni stabili
```

---

## 8.2 Sincronizzare con il raster

Il metodo piu semplice: aspetta che il raster raggiunga una linea specifica.

```asm
WAIT_FRAME
    LDA $D012           ; legge raster corrente
    CMP #$F8            ; linea 248 (vicino al fondo)
    BNE WAIT_FRAME      ; aspetta finche non ci arriva
    RTS
```

### Esempio completo

```asm
*=$8000

START
    LDA #%00000001
    STA $D015

    LDA #1
    STA $D027

    LDA #192
    STA $07F8

    LDA #100
    STA $D000
    STA $D001

MAINLOOP
    JSR WAIT_FRAME      ; sincronizza a 50 Hz
    JSR UPDATE
    JMP MAINLOOP

WAIT_FRAME
    LDA $D012
    CMP #$F8
    BNE WAIT_FRAME
    RTS

UPDATE
    INC $D001           ; sprite scende di 1 pixel al frame
    RTS
```

Lo sprite scendera di 50 pixel al secondo (preciso).

---

## 8.3 Frame Counter

Un contatore che si incrementa ogni frame e utile per temporizzare le azioni:

```asm
FRAME_CNT = $02

START
    LDA #0
    STA FRAME_CNT

MAINLOOP
    JSR WAIT_FRAME

    INC FRAME_CNT       ; +1 ogni frame (50 al sec)

    JSR UPDATE
    JMP MAINLOOP
```

### Timer di gioco

```asm
; Dopo 1 secondo (50 frame)
LDA FRAME_CNT
CMP #50
BNE NOT_YET

; ...fai qualcosa...
LDA #0
STA FRAME_CNT          ; reset contatore
```

---

## 8.4 Animare ogni N frame

Per animare uno sprite ogni 8 frame (circa 6 volte al secondo):

```asm
ANIM_CNT = $03
FRAME_CNT = $02

UPDATE
    LDA FRAME_CNT
    AND #7              ; controlla solo bit 0-2 (ogni 8 frame)
    BNE NO_ANIM         ; se non 8, salta

    INC ANIM_CNT        ; cambia frame animazione
    LDA ANIM_CNT
    AND #3              ; 4 frame di animazione (0-3)
    CLC
    ADC #192            ; pointer base
    STA $07F8           ; aggiorna sprite

NO_ANIM
    RTS
```

### Tabella delle frequenze

| Ogni N frame | Volte al secondo (PAL) |
|---|---|
| 1 | 50 |
| 2 | 25 |
| 4 | 12.5 |
| 6 | ~8.3 |
| 8 | 6.25 |
| 10 | 5 |
| 25 | 2 |
| 50 | 1 |

```asm
; Movimento player ogni 2 frame (25 movimenti/sec)
LDA FRAME_CNT
AND #1
BNE SKIP_MOVE

JSR MOVE_PLAYER

SKIP_MOVE
```

---

## 8.5 IRQ come game loop

Il metodo professionale: la logica di gioco gira dentro il raster interrupt.

```asm
*=$2000

START
    SEI
    LDA #$7F
    STA $DC0D

    LDA #<IRQ
    STA $0314
    LDA #>IRQ
    STA $0315

    LDA #250
    STA $D012

    LDA $D011
    AND #$7F
    STA $D011

    LDA #1
    STA $D01A

    CLI

MAIN
    JMP MAIN            ; il "vero" codice gira nell'IRQ

IRQ
    PHA                 ; salva registri
    TXA
    PHA
    TYA
    PHA

    JSR READ_JOYSTICK
    JSR UPDATE_PLAYER
    JSR UPDATE_ENEMIES
    JSR CHECK_COLLISIONS
    JSR UPDATE_SPRITES

    PLA                 ; recupera registri
    TAY
    PLA
    TAX
    PLA

    LDA $D019
    STA $D019

    JMP $EA31
```

---

## 8.6 Double IRQ: logica + rendering

Per giochi complessi, separiamo i compiti su due interrupt:

```asm
; IRQ1: a fine frame (logica)
IRQ1
    PHA
    TXA
    PHA
    TYA
    PHA

    JSR GAME_LOGIC      ; aggiorna stato gioco

    PLA
    TAY
    PLA
    TAX
    PLA

    ; Installa IRQ2 a meta schermo
    LDA #100
    STA $D012
    LDA #<IRQ2
    STA $0314
    LDA #>IRQ2
    STA $0315

    LDA $D019
    STA $D019
    JMP $EA31

; IRQ2: a meta schermo (sprite/rendering)
IRQ2
    PHA
    TXA
    PHA
    TYA
    PHA

    JSR UPDATE_SPRITES  ; aggiorna sprite per la parte visibile

    PLA
    TAY
    PLA
    TAX
    PLA

    ; Re-installa IRQ1
    LDA #250
    STA $D012
    LDA #<IRQ1
    STA $0314
    LDA #>IRQ1
    STA $0315

    LDA $D019
    STA $D019
    JMP $EA31
```

---

## 8.7 Architettura standard di un gioco C64

```asm
; ----------------------------------
; VARIABILI
; ----------------------------------
FRAME_CNT   = $02
GAME_STATE  = $03
PLAYER_X    = $04
PLAYER_Y    = $05
ENEMY_COUNT = $06
SCORE       = $07

; ----------------------------------
; SETUP INIZIALE
; ----------------------------------
*=$2000

START
    SEI
    JSR INIT_IRQ
    JSR INIT_GAME
    CLI

MAIN_LOOP
    JMP MAIN_LOOP

; ----------------------------------
; INIZIALIZZAZIONE IRQ
; ----------------------------------
INIT_IRQ
    LDA #$7F
    STA $DC0D
    LDA #<GAME_IRQ
    STA $0314
    LDA #>GAME_IRQ
    STA $0315
    LDA #250
    STA $D012
    LDA $D011
    AND #$7F
    STA $D011
    LDA #1
    STA $D01A
    RTS

; ----------------------------------
; GAME IRQ (eseguito 50 volte/sec)
; ----------------------------------
GAME_IRQ
    PHA
    TXA
    PHA
    TYA
    PHA

    INC FRAME_CNT

    JSR READ_INPUT
    JSR UPDATE_LOGIC
    JSR UPDATE_SPRITES

    PLA
    TAY
    PLA
    TAX
    PLA

    LDA $D019
    STA $D019
    JMP $EA31

; ----------------------------------
; LOGICHE
; ----------------------------------
INIT_GAME
    LDA #0
    STA FRAME_CNT
    STA SCORE
    STA GAME_STATE

    LDA #%00000001
    STA $D015
    LDA #1
    STA $D027
    LDA #192
    STA $07F8
    RTS

READ_INPUT
    ; ... leggera joystick ...
    RTS

UPDATE_LOGIC
    ; ... logica di gioco ...
    RTS

UPDATE_SPRITES
    ; ... aggiornamento sprite ...
    RTS
```

---

## 8.8 Frame timing (cicli CPU)

Su PAL, ogni frame offre circa 20000 cicli CPU disponibili.

```
Budget tipico per frame:
┌──────────────────────────────────┐
│ Logica gioco         ~8000 cicli │
│ Aggiornamento sprite ~4000 cicli │
│ Rendering            ~3000 cicli │
│ Audio                 ~2000 cicli│
│ Buffer / overhead    ~3000 cicli │
├──────────────────────────────────┤
│ Totale:             ~20000 cicli │
└──────────────────────────────────┘
```

### Controllare il budget

Usa la tecnica della barra di debug per vedere se stai sforando:

```asm
GAME_IRQ
    LDA #2
    STA $D020          ; bordo rosso INIZIO

    ; ...tutta la logica di gioco...

    LDA #0
    STA $D020          ; bordo nero FINE

    LDA $D019
    STA $D019
    JMP $EA31
```

Se la barra rossa supera la meta del bordo sinistro, stai usando troppo tempo CPU.

---

## Esercizi

### Esercizio 1
Crea un frame counter e fanne visualizzare il valore (in esadecimale) sul bordo usando `STA $D020`.

### Esercizio 2
Muovi uno sprite verso destra di 1 pixel ogni frame. Dovrebbe percorrere 50 pixel al secondo.

### Esercizio 3
Anima uno sprite ogni 4 frame, alternando tra 2 forme diverse (pointer 192 e 193).

### Esercizio 4
Fai in modo che un messaggio a schermo lampeggi ogni 25 frame (2 volte al secondo).

### Esercizio 5
Integra il tuo programma dentro un raster IRQ a 50 Hz, con la struttura standard (INIT, MAINLOOP, GAME_IRQ).

---

## Riepilogo

Hai imparato:

- Sincronizzare a 50 Hz con `WAIT_FRAME`
- Usare un frame counter per temporizzare azioni
- Animare ogni N frame
- Strutturare il gioco con IRQ a 50 Hz
- Separare READ_INPUT, UPDATE_LOGIC, UPDATE_SPRITES
- Gestire il budget di cicli CPU per frame
- Usare la barra di debug per monitorare il tempo CPU
