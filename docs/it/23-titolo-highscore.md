# Capitolo 23 — Schermate Titolo e High Score

## Obiettivi

Al termine di questo capitolo saprai:

- Creare una schermata titolo con sprite animati
- Gestire l'input per avviare il gioco
- Salvare e caricare high score su disco
- Usare le routine KERNAL per I/O su file
- Integrare titolo e high score nel ciclo di gioco

---

## 23.1 Schermata Titolo Animata

Una schermata titolo non e una scritta ferma. Puo avere:
- Titolo in caratteri grandi (PETSCII)
- Sprite animati (astronave, logo)
- Effetto raster sul bordo
- Lampeggio "PREMI FIRE PER INIZIARE"

### Struttura base

```asm
; Schermata titolo minimal
*= $C000

TITLE_INIT
    ; Sfondo scuro
    LDA #0
    STA $D021
    LDA #$0B           ; bordo grigio
    STA $D020

    ; Stampa titolo
    LDX #0
TI_LOOP
    LDA TITLE_TEXT,X
    BEQ TI_SPRITE
    STA $0400+40*5+8,X
    LDA #7             ; giallo
    STA $D800+40*5+8,X
    INX
    JMP TI_LOOP

TI_SPRITE
    ; Attiva sprite 0 per il logo animato
    LDA #%00000001
    STA $D015
    LDA #160
    STA $D000
    LDA #100
    STA $D001
    LDA #7
    STA $D027

    ; Imposta raster per lampeggio
    SEI
    LDA #<TITLE_IRQ
    STA $0314
    LDA #>TITLE_IRQ
    STA $0315
    LDA #200
    STA $D012
    LDA #1
    STA $D01A
    CLI
    RTS

TITLE_LOOP
    ; Aspetta fire
    LDA $DC01
    AND #%00010000
    BNE TITLE_LOOP
    ; Fire premuto → esci
    RTS

TITLE_TEXT
    .byte "SPACE COMMANDER",0
```

### Animazione del titolo

Per animare il titolo, possiamo cambiare i colori dello sprite
ogni N frame usando il raster interrupt:

```asm
TITLE_IRQ
    INC $D020          ; bordo che cambia colore

    ; Cambia colore sprite ogni 8 frame
    LDA FRAME_CNT
    AND #$07
    TAX
    LDA RAINBOW,X
    STA $D027

    LDA $D019
    STA $D019
    RTI

RAINBOW
    .byte 2,4,7,5,3,1,13,6
```

---

## 23.2 High Score: dove salvarlo?

Il C64 puo salvare dati su disco tramite il KERNAL.
La struttura per l'high score:

```
DISCO:
  File "HI" (1 blocco)
  ┌──────────────────────────────┐
  │ Byte 0:   high score MSB     │
  │ Byte 1:   high score byte 1  │
  │ Byte 2:   high score LSB     │
  │ Byte 3-63: nome giocatore    │
  └──────────────────────────────┘
```

### Salvare l'high score

```asm
; Salva high score su disco
; (usa KERNAL: SETNAM, SETLFS, OPEN, CLOSE)
SAVE_HIGH_SCORE
    ; Prepara nome file "HI"
    LDA #2             ; lunghezza nome
    LDX #<FNAME_HI
    LDY #>FNAME_HI
    JSR $FFBD          ; SETNAM

    ; Parametri dispositivo
    LDA #1             ; numero file logico
    LDX #8             ; device 8
    LDY #1             ; canale 1
    JSR $FFBA          ; SETLFS

    ; Indirizzo dei dati da salvare
    LDA #<HIGH_SCORE
    LDX #>HIGH_SCORE
    LDY #$C0           ; bank, non serve su C64
    JSR $FFD8          ; SAVE

    RTS

FNAME_HI
    .text "HI"

HIGH_SCORE
    .byte $00, $00, $00  ; 24-bit high score
    .byte "GIOCATORE",0
```

### Attenzione: SAVE ($FFD8) richiede

- `A` = low byte indirizzo
- `X` = high byte indirizzo
- `Y` = indirizzo bank (64) o $FF per I/O (C64: ignorato)
- Il nome e i device devono essere impostati prima

**Nota:** SAVE su un C64 reale con 1541 richiede che il file
non esista gia (altrimenti errore). Usare `SCRATCH` prima o
gestire l'errore.

---

## 23.3 Caricare l'high score

```asm
; Carica high score da disco
LOAD_HIGH_SCORE
    LDA #2
    LDX #<FNAME_HI
    LDY #>FNAME_HI
    JSR $FFBD          ; SETNAM

    LDA #1
    LDX #8
    LDY #0             ; 0 = caricamento
    JSR $FFBA          ; SETLFS

    LDA #0
    LDX #<HIGH_SCORE
    LDY #>HIGH_SCORE
    JSR $FFD5          ; LOAD

    ; Se il file non esiste, carica zero
    BCS LHS_FAIL
    RTS

LHS_FAIL
    LDA #0
    STA HIGH_SCORE
    STA HIGH_SCORE+1
    STA HIGH_SCORE+2
    RTS
```

### Gestione errore file inesistente

Al primo avvio, il file "HI" non esiste. `$FFD5` ritorna
**Carry set** in caso di errore. Controlla sempre `BCS` dopo LOAD.

---

## 23.4 Confronto e aggiornamento high score

```asm
; Confronta (A=score LO, X=score HI) con HIGH_SCORE
; Se maggiore, aggiorna e salva
CHECK_HIGH_SCORE
    CMP HIGH_SCORE
    BCC CHS_OLD        ; score < high score
    CMP HIGH_SCORE+1
    BCC CHS_OLD
    ; Nuovo record!
    STA HIGH_SCORE+1
    STX HIGH_SCORE+2
    JSR SAVE_HIGH_SCORE
CHS_OLD
    RTS
```

---

## 23.5 Schermata Game Over con High Score

Dopo la morte del giocatore, mostra il punteggio e il record:

```asm
GAMEOVER_SCREEN
    ; Stampa "GAME OVER"
    LDX #0
GOV_LOOP
    LDA GOV_TEXT,X
    BEQ GOV_SCORE
    STA $0400+40*8+12,X
    INX
    JMP GOV_LOOP

GOV_SCORE
    ; Stampa punteggio
    LDA SCORE_HI
    JSR PRINT_HEX
    LDA SCORE_LO
    JSR PRINT_HEX

    ; Stampa high score
    LDX #0
GOV_HS_LOOP
    LDA HS_TEXT,X
    BEQ GOV_CHECK
    STA $0400+40*10+10,X
    INX
    JMP GOV_HS_LOOP

    LDA HIGH_SCORE+1
    JSR PRINT_HEX
    LDA HIGH_SCORE
    JSR PRINT_HEX

GOV_CHECK
    ; Verifica se nuovo record
    LDA SCORE_HI
    CMP HIGH_SCORE+1
    BCC GOV_WAIT
    LDA SCORE_LO
    CMP HIGH_SCORE
    BCC GOV_WAIT
    ; Nuovo record!
    JSR SAVE_HIGH_SCORE
    ; Stampa "NUOVO RECORD!"

GOV_WAIT
    ; Aspetta fire
    LDA $DC01
    AND #%00010000
    BNE GOV_WAIT
    RTS

GOV_TEXT
    .byte "GAME OVER",0

HS_TEXT
    .byte "HIGH SCORE:",0
```

---

## 23.6 Schermata Titolo Completa

Unendo tutto:

```asm
TITLE_FULL
    JSR TITLE_INIT
    JSR TITLE_SPRITES
    JSR LOAD_HIGH_SCORE   ; carica record all'avvio

TF_LOOP
    ; Mostra high score
    LDX #0
TF_HS
    LDA HS_LABEL,X
    BEQ TF_BLINK
    STA $0400+40*15+10,X
    INX
    JMP TF_HS

TF_BLINK
    ; Lampeggio "PREMI FIRE"
    LDA FRAME_CNT
    AND #$20
    BEQ TF_INPUT
    LDX #0
TF_BL
    LDA FIRE_TEXT,X
    BEQ TF_INPUT
    STA $0400+40*20+12,X
    INX
    JMP TF_BL
    JMP TF_INPUT

TF_HIDE
    ; Nascondi testo lampeggiante
    LDX #0
TF_HL
    LDA FIRE_TEXT,X
    BEQ TF_INPUT
    LDA #$20
    STA $0400+40*20+12,X
    INX
    JMP TF_HL

TF_INPUT
    LDA $DC01
    AND #%00010000
    BNE TF_LOOP
    RTS

HS_LABEL
    .byte "HIGH:",0

FIRE_TEXT
    .byte "PREMI FIRE",0
```

---

## 23.7 Integrazione nel ciclo di gioco

Il flusso completo:

```
                   ┌──────────────┐
                   │  AVVIO       │
                   │  Carica HS   │
                   └──────┬───────┘
                          ↓
                   ┌──────────────┐
         ┌────────→│ TITLE SCREEN │
         │         │ (animata)    │
         │         └──────┬───────┘
         │                ↓ FIRE
         │         ┌──────────────┐
         │         │   GAME PLAY  │
         │         │  (gioca...)  │
         │         └──────┬───────┘
         │                ↓ PLAYER DIES
         │         ┌──────────────┐
         │         │  GAME OVER   │
         │         │ Mostra score │
         │         │ Confronta HS │
         │         │ Salva se OK  │
         │         └──────┬───────┘
         │                ↓ FIRE
         └────────────────┘
```

---

## Esercizi

### Esercizio 1
Crea una schermata titolo con il testo "SHOOTER 64" in giallo su sfondo nero, centrato.

### Esercizio 2
Aggiungi uno sprite animato alla schermata titolo che cambia colore ogni 8 frame.

### Esercizio 3
Scrivi le routine per salvare e caricare un high score di 3 byte su disco.

### Esercizio 4
Integra la schermata game over che mostra il punteggio attuale e l'high score.

### Esercizio 5
Completa il ciclo: titolo → gioco → game over → verifica HS → torna al titolo.

---

## Riferimenti

- [Capitolo 13 — Stati Gioco](13-punteggio-e-stati-gioco.md) — state machine per integrare titolo/HS
- [Capitolo 21 — Caricatore](21-caricatore-personalizzato.md) — I/O su disco (SETNAM, SETLFS, LOAD)
- [Appendice A](appendice-a-tabelle.md) — tabella KERNAL ($FFD5 LOAD, $FFD8 SAVE)
- [Soluzioni](../soluzioni/cap23-titolo-highscore.asm) — soluzioni degli esercizi
