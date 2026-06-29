# Capitolo 13 — Punteggio e Stati del Gioco

## Obiettivi

Al termine di questo capitolo saprai:

- Gestire un punteggio a 16 bit
- Visualizzare il punteggio a schermo
- Implementare una macchina a stati (MENU, PLAY, GAME OVER)
- Resettare il gioco correttamente
- Creare schermate di transizione

---

## 13.1 Punteggio a 16 bit

Il punteggio in un arcade puo arrivare a 9999 o piu. Usiamo 2 byte (16 bit):

```asm
SCORE_LO  = $02      ; byte basso
SCORE_HI  = $03      ; byte alto
```

### Inizializzazione

```asm
INIT_SCORE
    LDA #0
    STA SCORE_LO
    STA SCORE_HI
    RTS
```

### Aggiungere punti

```asm
ADD_SCORE_10
    CLC
    LDA SCORE_LO
    ADC #10
    STA SCORE_LO
    LDA SCORE_HI
    ADC #0
    STA SCORE_HI
    RTS

ADD_SCORE_100
    CLC
    LDA SCORE_LO
    ADC #100
    STA SCORE_LO
    LDA SCORE_HI
    ADC #0
    STA SCORE_HI
    RTS
```

### Punteggio per tipo nemico

```asm
ADD_SCORE_ENEMY
    CLC
    LDA SCORE_LO
    ADC ENEMY_POINTS,X    ; punti per tipo nemico
    STA SCORE_LO
    LDA SCORE_HI
    ADC #0
    STA SCORE_HI
    RTS

ENEMY_POINTS
    .byte 10, 25, 50, 100
```

---

## 13.2 Visualizzare il punteggio

Per mostrare numeri, dobbiamo convertire il binario in caratteri PETSCII.

### Conversione da binario a 3 cifre (0-999)

```asm
; Converte SCORE_LO (0-255) in 3 caratteri
; scrive a $0420 (SCORE: 000)

DRAW_SCORE
    LDA SCORE_LO
    LDX #0             ; centinaia
DIV100
    CMP #100
    BCC DONE100
    SBC #100
    INX
    JMP DIV100
DONE100
    TXA
    CLC
    ADC #$30          ; converti in PETSCII numero
    STA $0420         ; centinaia

    ; A = resto (0-99)
    LDX #0             ; decine
DIV10
    CMP #10
    BCC DONE10
    SBC #10
    INX
    JMP DIV10
DONE10
    TXA
    CLC
    ADC #$30
    STA $0421         ; decine

    CLC
    ADC #$30
    STA $0422         ; unita
    RTS
```

### Versione 16 bit (fino a 9999)

```asm
; Converte SCORE_HI:SCORE_LO in 4 cifre
DRAW_SCORE_16
    ; Migliaia
    LDA SCORE_HI
    PHA
    JSR WRITE_DIGIT    ; semplificato

    ; Centinaia (resto di SCORE_HI)
    ; ... logica simile ...

    ; Decine e unita da SCORE_LO
    LDA SCORE_LO
    ; ... divisioni ...

    RTS
```

---

## 13.3 Stato del gioco (State Machine)

Un gioco arcade ha stati ben definiti:

```
           ┌──────────────┐
           │    MENU      │
           └──────┬───────┘
                  │ fire premuto
                  v
           ┌──────────────┐
           │    PLAY      │
           └──────┬───────┘
                  │ player morto
                  v
           ┌──────────────┐
           │  GAME OVER   │
           └──────┬───────┘
                  │ fire premuto
                  v
           ┌──────────────┐
           │    MENU      │
           └──────────────┘
```

### Variabile di stato

```asm
GAME_STATE = $10

STATE_MENU     = 0
STATE_PLAY     = 1
STATE_GAMEOVER = 2
```

### Macchina a stati nel loop principale

```asm
*=$8000

START
    JSR INIT_GAME

MAINLOOP
    JSR WAIT_FRAME
    INC FRAME_CNT

    LDA GAME_STATE
    CMP #STATE_MENU
    BEQ DO_MENU

    CMP #STATE_PLAY
    BEQ DO_PLAY

    CMP #STATE_GAMEOVER
    BEQ DO_GAMEOVER

    JMP MAINLOOP

DO_MENU
    JSR UPDATE_MENU
    JMP MAINLOOP

DO_PLAY
    JSR UPDATE_GAME
    JMP MAINLOOP

DO_GAMEOVER
    JSR UPDATE_GAMEOVER
    JMP MAINLOOP
```

---

## 13.4 Stato MENU

```asm
UPDATE_MENU
    JSR DRAW_TITLE
    JSR READ_FIRE
    BEQ MENU_DONE       ; aspetta fire

    ; Passa a PLAY
    LDA #STATE_PLAY
    STA GAME_STATE
    JSR RESET_GAME

MENU_DONE
    RTS

DRAW_TITLE
    ; Disegna titolo una volta sola
    LDA TITLE_DRAWN
    BNE DT_DONE

    ; ... scrive "ARCADE GAME" a schermo ...
    ; ... scrive "PRESS FIRE" ...

    LDA #1
    STA TITLE_DRAWN

DT_DONE
    RTS
```

---

## 13.5 Stato PLAY

```asm
UPDATE_GAME
    JSR READ_JOY
    JSR MOVE_PLAYER
    JSR HANDLE_FIRE
    JSR UPDATE_BULLETS
    JSR UPDATE_WAVE
    JSR MOVE_ENEMIES
    JSR CHECK_EDGES
    JSR CHECK_WAVE_CLEAR
    JSR CHECK_COLLISIONS
    JSR CHECK_PLAYER_DEATH
    JSR DRAW_SCORE
    JSR RENDER_ALL
    RTS
```

---

## 13.6 Stato GAME OVER

```asm
UPDATE_GAMEOVER
    JSR DRAW_GAMEOVER

    LDA GAME_OVER_TIMER
    BNE DEC_TIMER

    JSR READ_FIRE_ONCE
    BCC GO_DONE

    ; Torna al menu
    LDA #STATE_MENU
    STA GAME_STATE
    LDA #0
    STA TITLE_DRAWN

GO_DONE
    RTS

DEC_TIMER
    DEC GAME_OVER_TIMER
    RTS

DRAW_GAMEOVER
    LDA GAMEOVER_DRAWN
    BNE DGO_DONE

    JSR CLEAR_SCREEN

    ; Scrivi "GAME OVER" a schermo
    ; ... codici PETSCII per GAME OVER ...

    LDA #1
    STA GAMEOVER_DRAWN

    LDA #100
    STA GAME_OVER_TIMER ; 2 secondi di pausa

DGO_DONE
    RTS
```

---

## 13.7 Reset del gioco completo

```asm
RESET_GAME
    JSR CLEAR_SCREEN

    ; Reset punteggio
    LDA #0
    STA SCORE_LO
    STA SCORE_HI

    ; Reset player
    LDA #160
    STA PLAYER_X
    LDA #180
    STA PLAYER_Y

    ; Reset proiettili
    LDX #0
RB_LOOP
    STA BULLET_ACTIVE,X
    INX
    CPX #4
    BNE RB_LOOP

    ; Reset nemici
    LDX #0
REN_LOOP
    STA ENEMY_ALIVE,X
    INX
    CPX #16
    BNE REN_LOOP

    ; Reset wave
    LDA #0
    STA WAVE_INDEX
    STA ENEMIES_LEFT
    STA ENEMY_DIR
    STA WAVE_TIMER

    LDA #STATE_MENU
    STA GAME_STATE

    RTS
```

---

## 13.8 Player death e vite

```asm
LIVES = $11

INIT_LIVES
    LDA #3
    STA LIVES
    RTS

PLAYER_DIE
    DEC LIVES
    LDA LIVES
    BEQ GAME_OVER_STATE

    ; Resetta posizione player
    LDA #160
    STA PLAYER_X
    LDA #180
    STA PLAYER_Y

    ; 1 secondo di invincibilita
    LDA #50
    STA INVINCIBLE_TIMER

    RTS

GAME_OVER_STATE
    LDA #STATE_GAMEOVER
    STA GAME_STATE
    LDA #0
    STA GAMEOVER_DRAWN
    RTS
```

---

## 13.9 Schermata di transizione tra wave

```asm
WAVE_TRANSITION
    ; Mostra "WAVE X" per 1 secondo
    JSR CLEAR_SCREEN

    ; Scrivi "WAVE " + WAVE_INDEX
    LDX #0
WT_LOOP
    LDA WAVE_TEXT,X
    BEQ WT_DONE
    STA $0540,X
    INX
    JMP WT_LOOP
WT_DONE

    ; Mostra il numero della wave
    LDA WAVE_INDEX
    CLC
    ADC #$30
    STA $0546

    ; Aspetta 50 frame
    LDA #50
    STA WAVE_DELAY
WTV_LOOP
    JSR WAIT_FRAME
    DEC WAVE_DELAY
    BNE WTV_LOOP

    JSR CLEAR_SCREEN
    JSR INIT_WAVE
    RTS

WAVE_TEXT
    .byte 23, 1, 22, 5, 0   ; "WAVE" in PETSCII + terminatore
```

---

## Esercizi

### Esercizio 1
Crea un punteggio che parte da 0 e aumenta di 10 ogni volta che premi fuoco.

### Esercizio 2
Converti e visualizza il punteggio a 3 cifre in alto a sinistra dello schermo.

### Esercizio 3
Implementa la macchina a stati: MENU → PLAY → GAME OVER → MENU.

### Esercizio 4
Aggiungi 3 vite. Quando il player viene colpito, perde una vita. A 0 vite → GAME OVER.

### Esercizio 5
Mostra "WAVE 1", "WAVE 2", ecc. per 1 secondo tra una wave e l'altra.

---

## Riepilogo

Hai imparato:

- Punteggio a 16 bit con somma e riporto
- Convertire binario in caratteri PETSCII numerici
- Macchina a stati (MENU, PLAY, GAME OVER)
- Transizioni tra stati
- Reset completo del gioco
- Gestione vite e invincibilita
- Schermate di transizione

## Riferimenti

- [Capitolo 4 — Memoria video](04-memoria-video-e-caratteri.md) — visualizzare punteggio a schermo
- [Capitolo 8 — Game loop](08-game-loop-sincronizzato.md) — struttura portante del gioco
- [Capitolo 12 — Wave system](12-wave-system-e-ai-nemici.md) — integrazione onde/punteggio
- [Soluzioni](../soluzioni/cap13-punteggio-stati.asm) — soluzioni degli esercizi
