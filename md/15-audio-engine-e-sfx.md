# Capitolo 15 — Audio Engine e Gestione SFX

## Obiettivi

Al termine di questo capitolo saprai:

- Strutturare un sistema audio modulare
- Usare una coda di richieste SFX
- Separare effetti sonori su canali diversi
- Integrare l'audio nel raster interrupt
- Creare un music player semplice

---

## 15.1 Architettura audio per giochi

Per un gioco professionale, l'audio va separato dalla logica:

```
┌─────────────────────────────────┐
│ GAME LOGIC                      │
│  "set SFX_REQUEST = 1"          │
└──────────┬──────────────────────┘
           │ (non bloccante)
           v
┌─────────────────────────────────┐
│ AUDIO ENGINE (chiamato ogni     │
│ frame nel raster IRQ)           │
│  "legge SFX_REQUEST,            │
│   scrive nel SID"               │
└─────────────────────────────────┘
           │
           v
┌─────────────────────────────────┐
│ SID HARDWARE                    │
│  (suona da solo)                │
└─────────────────────────────────┘
```

### Separazione dei canali

```
Canale 1 → musica di sottofondo
Canale 2 → effetti sonori (spari, esplosioni)
Canale 3 → effetti aggiuntivi (bonus, power-up)
```

---

## 15.2 Sistema di richiesta SFX

Invece di scrivere direttamente nel SID, il gioco imposta una richiesta:

```asm
; Variabili di richiesta
SFX_REQUEST  = $30   ; 0 = nessuno, 1 = sparo, 2 = esplosione, 3 = bonus
SFX_ACTIVE   = $31   ; 0 = inattivo, 1 = in riproduzione
SFX_TIMER    = $32   ; contatore per durata effetto

; Richiesta dal gioco (es. quando spari)
FIRE_GUN
    LDA #1
    STA SFX_REQUEST      ; richiedi suono "sparo"
    ... gestione proiettile ...
    RTS
```

### Engine audio

```asm
UPDATE_AUDIO
    LDA SFX_ACTIVE
    BNE PLAYING_SFX

    ; Nessun suono in corso, possiamo iniziare una richiesta
    LDA SFX_REQUEST
    BEQ AUDIO_DONE

    ; Avvia l'effetto richiesto
    CMP #1
    BEQ START_SHOT
    CMP #2
    BEQ START_EXPLOSION
    CMP #3
    BEQ START_BONUS

AUDIO_DONE
    RTS

PLAYING_SFX
    DEC SFX_TIMER
    BNE AUDIO_DONE

    ; Timer scaduto: spegni suono
    LDA #0
    STA SFX_ACTIVE
    STA SFX_REQUEST

    ; Spegni canale 2
    LDA #$10
    STA $D414       ; CTRL voce 2, gate OFF

    RTS
```

---

## 15.3 Avvio effetti

```asm
START_SHOT
    LDA #$FF
    STA $D410       ; FREQ_LO voce 2
    LDA #$20
    STA $D411       ; FREQ_HI voce 2
    LDA #$11        ; square + gate
    STA $D414       ; CTRL voce 2

    LDA #8
    STA SFX_TIMER   ; 8 frame di durata
    LDA #1
    STA SFX_ACTIVE
    LDA #0
    STA SFX_REQUEST
    RTS

START_EXPLOSION
    LDA #$10
    STA $D410
    LDA #$05
    STA $D411
    LDA #$81        ; noise + gate
    STA $D414

    LDA #20
    STA SFX_TIMER
    LDA #1
    STA SFX_ACTIVE
    LDA #0
    STA SFX_REQUEST
    RTS

START_BONUS
    LDA #$40
    STA $D410
    LDA #$30
    STA $D411
    LDA #$21        ; triangle + gate
    STA $D414

    LDA #15
    STA SFX_TIMER
    LDA #1
    STA SFX_ACTIVE
    LDA #0
    STA SFX_REQUEST
    RTS
```

---

## 15.4 Integrazione con Raster IRQ

L'audio deve girare dentro il raster interrupt per essere stabile:

```asm
GAME_IRQ
    PHA
    TXA
    PHA
    TYA
    PHA

    JSR READ_INPUT
    JSR UPDATE_LOGIC
    JSR UPDATE_SPRITES
    JSR UPDATE_AUDIO      ; chiamato ogni frame!
    JSR UPDATE_MUSIC      ; se c'e musica

    PLA
    TAY
    PLA
    TAX
    PLA

    LDA $D019
    STA $D019
    JMP $EA31
```

---

## 15.5 Music Player semplice (dati sequenziali)

Un player minimalista che legge note da una tabella:

```asm
; Dati musicali: coppie (frequenza_lo, frequenza_hi, durata)
; 0 = fine

MUSIC_DATA
    .byte $40, $10, 8     ; nota 1
    .byte $80, $20, 8     ; nota 2
    .byte $00, $30, 8     ; nota 3
    .byte $40, $10, 4     ; nota 4 (piu breve)
    .byte $00, $00, 0     ; fine

MUSIC_PTR = $40    ; puntatore basso
MUSIC_PTR_H = $41  ; puntatore alto
MUSIC_TICK = $42   ; contatore durata nota

INIT_MUSIC
    LDA #<MUSIC_DATA
    STA MUSIC_PTR
    LDA #>MUSIC_DATA
    STA MUSIC_PTR_H
    LDA #0
    STA MUSIC_TICK
    RTS
```

### Player

```asm
UPDATE_MUSIC
    DEC MUSIC_TICK
    BNE MUSIC_DONE

    ; Leggi prossima nota
    LDY #0
    LDA (MUSIC_PTR),Y    ; FREQ_LO
    BEQ MUSIC_END        ; 0 = fine

    STA $D400            ; voce 1, FREQ_LO

    INY
    LDA (MUSIC_PTR),Y    ; FREQ_HI
    STA $D401

    INY
    LDA (MUSIC_PTR),Y    ; durata
    STA MUSIC_TICK

    ; Gate ON
    LDA #$11
    STA $D404

    ; Avanza puntatore
    CLC
    LDA MUSIC_PTR
    ADC #3
    STA MUSIC_PTR
    LDA MUSIC_PTR_H
    ADC #0
    STA MUSIC_PTR_H

MUSIC_DONE
    RTS

MUSIC_END
    ; Spegni gate
    LDA #$10
    STA $D404
    ; Ricomincia
    JSR INIT_MUSIC
    RTS
```

---

## 15.6 Gestione volume e mix

```asm
SET_VOLUME
    LDA #$0F        ; volume massimo per tutti i canali
    STA $D418
    RTS

MUTE_ALL
    LDA #$00
    STA $D418
    RTS

; Volume separato per canale non esiste fisicamente,
; ma possiamo attenuare usando ADSR:
SET_ADSR
    LDA #$09        ; Attack = 0, Decay = 9
    STA $D405       ; AD voce 1
    LDA #$F0        ; Sustain = F, Release = 0
    STA $D406       ; SR voce 1
    RTS
```

---

## 15.7 Coda di comandi audio (avanzata)

Per piu controllo, una coda circolare di comandi:

```asm
; Coda audio (16 comandi)
AUDIO_QUEUE = $C0
QUEUE_HEAD = $50
QUEUE_TAIL = $51

; Comando: .byte (canale, freq_lo, freq_hi, waveform, durata)

PUSH_AUDIO
    LDX QUEUE_TAIL
    STA AUDIO_QUEUE,X     ; canale
    INX
    TXA
    AND #$0F
    STA QUEUE_TAIL
    RTS

PROCESS_AUDIO_QUEUE
    LDX QUEUE_HEAD
    CPX QUEUE_TAIL
    BEQ AQ_DONE

    LDA AUDIO_QUEUE,X     ; primo byte = canale
    ; ... elabora comando ...
    INX
    TXA
    AND #$0F
    STA QUEUE_HEAD

AQ_DONE
    RTS
```

---

## Esercizi

### Esercizio 1
Crea il sistema SFX_REQUEST: sparo sul canale 2, esplosione sul canale 3.

### Esercizio 2
Integra UPDATE_AUDIO nel raster interrupt a 50 Hz.

### Esercizio 3
Crea una sequenza musicale di 4 note che si ripete in loop.

### Esercizio 4
Usa l'ADSR per creare un suono di "pioggia" con noise e attack lungo.

### Esercizio 5
Implementa una coda audio di 8 comandi per gestire suoni multipli simultanei.

---

## Riepilogo

Hai imparato:

- Architettura audio: Game Logic → Audio Engine → SID
- Canali separati: musica su 1, SFX su 2, effetti su 3
- Sistema di richiesta non bloccante (SFX_REQUEST)
- Integrazione audio nel raster interrupt
- Music player con dati sequenziali
- ADSR per modellare il suono
- Coda di comandi audio
