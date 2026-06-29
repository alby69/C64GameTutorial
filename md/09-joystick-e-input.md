# Capitolo 9 — Joystick e Controllo del Giocatore

## Obiettivi

Al termine di questo capitolo saprai:

- Leggere il joystick dal registro CIA
- Convertire i bit del joystick in direzioni
- Muovere il player con il joystick
- Rilevare il pulsante di fuoco
- Gestire piu porte joystick

---

## 9.1 I registri del joystick

Il C64 ha due porte joystick, controllate dal chip CIA (Complex Interface Adapter):

```
Porta 1: $DC01   (usata dal giocatore 1)
Porta 2: $DC00   (usata dal giocatore 2)
```

Ogni registro contiene lo stato dei direzionali e del pulsante:

```
Bit:  7   6   5   4   3   2   1   0
      F   E   D   C   B   A   9   8  (nessun significato)
      |   |   |   |
      |   |   |   +── Destra (port 1) / Su (port 2)
      |   |   +────── Sinistra
      |   +────────── Giù
      +────────────── Su (port 1) / Destra (port 2)
```

> **Attenzione:** I bit sono attivi **bassi** (0 = premuto, 1 = non premuto).

### Porta 1 (`$DC01`) — disposizione bit

```
Bit 0 = Su      (0 = premuto)
Bit 1 = Giù     (0 = premuto)
Bit 2 = Sinistra (0 = premuto)
Bit 3 = Destra  (0 = premuto)
Bit 4 = Pulsante (0 = premuto)
Bit 5-7 = non usati (sono 1)
```

---

## 9.2 Leggere il joystick

La lettura base:

```asm
LDA $DC01       ; legge stato joystick porta 1
```

Il valore letto sara tipo `$FF` (nessun tasto premuto) o con alcuni bit a 0.

### Maschere per le direzioni

```asm
; Maschere per porte 1
MASK_UP      = %11111110    ; bit 0
MASK_DOWN    = %11111101    ; bit 1
MASK_LEFT    = %11111011    ; bit 2
MASK_RIGHT   = %11110111    ; bit 3
MASK_FIRE    = %11101111    ; bit 4
```

### Rilevare una direzione

```asm
LDA $DC01

; Controlla SU
AND #%00000001      ; isola bit 0
BEQ PRESSED_UP      ; se 0, SU premuto

; Controlla GIU
LDA $DC01
AND #%00000010      ; isola bit 1
BEQ PRESSED_DOWN
```

---

## 9.3 Leggere il joystick in modo pulito

```asm
JOYSTICK = $DC01

READ_JOY
    LDA JOYSTICK    ; legge stato
    EOR #$FF        ; inverte bit (1 = premuto)
    AND #%00011111  ; maschera solo bit 0-4
    STA JOY_STATE   ; salva
    RTS

JOY_STATE = $02
```

Dopo questa routine, `JOY_STATE` contiene:

```
Bit 0 = Su      (1 = premuto)
Bit 1 = Giù     (1 = premuto)
Bit 2 = Sinistra (1 = premuto)
Bit 3 = Destra  (1 = premuto)
Bit 4 = Pulsante (1 = premuto)
```

---

## 9.4 Esempio completo: muovere sprite con joystick

```asm
PLAYER_X   = $02
PLAYER_Y   = $03
JOY_STATE  = $04

*=$8000

START
    JSR INIT_GAME

MAINLOOP
    JSR WAIT_FRAME
    JSR READ_JOY
    JSR MOVE_PLAYER
    JSR UPDATE_SPRITES
    JMP MAINLOOP

; ----------------------------------
; INIZIALIZZAZIONE
; ----------------------------------
INIT_GAME
    LDA #%00000001
    STA $D015
    LDA #1
    STA $D027
    LDA #192
    STA $07F8

    LDA #160
    STA PLAYER_X
    STA $D000

    LDA #150
    STA PLAYER_Y
    STA $D001
    RTS

; ----------------------------------
; LETTURA JOYSTICK
; ----------------------------------
READ_JOY
    LDA $DC01
    EOR #$FF
    AND #%00011111
    STA JOY_STATE
    RTS

; ----------------------------------
; MOVIMENTO PLAYER
; ----------------------------------
MOVE_PLAYER
    LDA JOY_STATE
    AND #%00000001      ; SU?
    BEQ CHECK_DOWN

    LDA PLAYER_Y
    CMP #30             ; limite superiore
    BCC CHECK_DOWN
    DEC PLAYER_Y

CHECK_DOWN
    LDA JOY_STATE
    AND #%00000010      ; GIU?
    BEQ CHECK_LEFT

    LDA PLAYER_Y
    CMP #220            ; limite inferiore
    BCS CHECK_LEFT
    INC PLAYER_Y

CHECK_LEFT
    LDA JOY_STATE
    AND #%00000100      ; SINISTRA?
    BEQ CHECK_RIGHT

    LDA PLAYER_X
    CMP #10             ; limite sinistro
    BCC CHECK_RIGHT
    DEC PLAYER_X

CHECK_RIGHT
    LDA JOY_STATE
    AND #%00001000      ; DESTRA?
    BEQ DONE_MOVE

    LDA PLAYER_X
    CMP #240            ; limite destro
    BCS DONE_MOVE
    INC PLAYER_X

DONE_MOVE
    RTS

; ----------------------------------
; AGGIORNAMENTO SPRITE
; ----------------------------------
UPDATE_SPRITES
    LDA PLAYER_X
    STA $D000
    LDA PLAYER_Y
    STA $D001
    RTS

; ----------------------------------
; SYNC FRAME
; ----------------------------------
WAIT_FRAME
    LDA $D012
    CMP #$F8
    BNE WAIT_FRAME
    RTS
```

---

## 9.5 Rilevare il pulsante di fuoco

```asm
READ_FIRE
    LDA $DC01
    AND #%00010000      ; bit 4 = fire
    BNE NOT_FIRED       ; se 1, non premuto
    ; FUOCO premuto!
    ; ... gestione sparo ...
NOT_FIRED
    RTS
```

### Fire con fronte di salita (single shot)

Per evitare che tenendo premuto spari continuamente:

```asm
OLD_FIRE = $05

READ_FIRE_ONCE
    LDA $DC01
    AND #%00010000
    BNE NOT_FIRED

    LDA OLD_FIRE
    BNE NOT_FIRED       ; se era gia premuto, ignora

    ; E il primo frame in cui e premuto!

    LDA #1
    STA OLD_FIRE
    JMP FIRE_ACTION

NOT_FIRED
    LDA #0
    STA OLD_FIRE
    RTS

FIRE_ACTION
    ; ... spara! ...
    RTS
```

---

## 9.6 Porta 2 (`$DC00`)

La porta 2 ha una disposizione diversa dei bit:

```
Porta 2 ($DC00):
Bit 0 = Destra
Bit 1 = Sinistra
Bit 2 = Giù
Bit 3 = Su
Bit 4 = Pulsante
```

```asm
; Lettura porta 2
LDA $DC00
```

---

## 9.7 Routines complete di input

```asm
; ----------------------------------
; INPUT SYSTEM COMPLETO
; ----------------------------------
JOY1      = $DC01
JOY2      = $DC00

JOY_STATE = $02      ; stato normalizzato
OLD_JOY   = $03      ; frame precedente
EDGE_JOY  = $04      ; pressioni rilevate

; Legge joystick 1 e normalizza
READ_INPUT
    LDA JOY1
    EOR #$FF
    AND #%00011111
    STA JOY_STATE

    ; Edge detection (appena premuto)
    TAX
    EOR OLD_JOY
    AND JOY_STATE
    STA EDGE_JOY

    STX OLD_JOY
    RTS

; Esempi di uso
CHECK_UP
    LDA JOY_STATE
    AND #1
    BNE DO_UP
    RTS
DO_UP
    ; ... azione su ...
    RTS

CHECK_FIRE_PRESSED
    LDA EDGE_JOY
    AND #%00010000      ; fire appena premuto?
    BNE DO_FIRE
    RTS
DO_FIRE
    ; ... spara ...
    RTS
```

---

## 9.8 Movimento diagonale

Il joystick permette direzioni diagonali. Gestiamo il caso in cui due direzioni sono premute insieme:

```asm
MOVE_PLAYER
    LDA JOY_STATE
    STA TEMP

    ; SU (con o senza diagonale)
    LDA TEMP
    AND #%00000001
    BEQ CHECK_DOWN2
    DEC PLAYER_Y

CHECK_DOWN2
    LDA TEMP
    AND #%00000010
    BEQ CHECK_LEFT2
    INC PLAYER_Y

CHECK_LEFT2
    LDA TEMP
    AND #%00000100
    BEQ CHECK_RIGHT2
    DEC PLAYER_X

CHECK_RIGHT2
    LDA TEMP
    AND #%00001000
    BEQ DONE_MOVE2
    INC PLAYER_X

DONE_MOVE2
    RTS
```

---

## Esercizi

### Esercizio 1
Leggi il joystick e muovi uno sprite in tutte e 4 le direzioni.

### Esercizio 2
Aggiungi il controllo dei bordi: il player non deve uscire dallo schermo.

### Esercizio 3
Usando il pulsante di fuoco, cambia il colore dello sprite.

### Esercizio 4
Implementa il "single shot": a ogni pressione del fuoco, incrementa un contatore (ma non se tenuto premuto).

### Esercizio 5
Muovi uno sprite con la porta 1 e un secondo sprite con la porta 2.

---

## Riepilogo

Hai imparato:

- I registri joystick `$DC00` e `$DC01`
- Che i bit sono attivi bassi (0 = premuto)
- Come normalizzare lo stato con `EOR #$FF`
- Muovere il player con controllo dei bordi
- Rilevare il pulsante con fronte di salita
- Gestire direzioni diagonali
- Edge detection per input "single shot"
