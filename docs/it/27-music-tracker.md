# Capitolo 27 — Integrazione Music Tracker

## Obiettivi

Al termine di questo capitolo saprai:

- Cos'e un music tracker per C64 (GoatTracker, DefMon, SidFactory)
- Esportare musica in formato `$D400` player
- Integrare un player SID nel gioco
- Gestire musica + SFX contemporaneamente
- Usare interrupt per la musica

---

## 27.1 Music Tracker per C64

Un music tracker e un programma che permette di comporre musica
per il SID del C64 visivamente. I piu diffusi:

```
GoatTracker   — Interfaccia simile a trackers MOD, esporta in .asm
DefMon        — Player compatto, usato in molte demo
SidFactory    — Editor SID completo, esporta player
CheeseCutter  — Moderno, open source
```

### Flusso di lavoro

```
1. Componi musica in GoatTracker
2. Esporta → file .asm con player + dati
3. Includi nel tuo progetto assembly
4. Chiama INIT e PLAY a 50 Hz via IRQ
```

---

## 27.2 Struttura di un Player SID

Un player SID esportato ha tipicamente tre entry point:

```asm
; Struttura tipica di un player SID
; (esportato da GoatTracker o DefMon)

; Labels esportati:
;   MUSIC_INIT     — chiama per inizializzare
;   MUSIC_PLAY     — chiama ogni frame (50 Hz)
;   MUSIC_DATA     — dati della canzone (tabelle)

MUSIC_INIT
    ; Inizializza player
    ; Resetta puntatori, ADSR, volume
    ...
    RTS

MUSIC_PLAY
    ; Avanza di un frame
    ; Legge tabelle, scrive registri SID
    ...
    RTS
```

---

## 27.3 Integrazione nel Gioco

### Inizializzazione

```asm
; Nel setup del gioco
GAME_INIT
    ...
    JSR MUSIC_INIT    ; Avvia musica
    RTS
```

### Player via IRQ

```asm
; Nel raster IRQ (50 Hz)
KERNEL_IRQ
    ...
    JSR MUSIC_PLAY    ; Avanza musica ogni frame
    JSR ENGINE_AUDIO_UPDATE  ; SFX
    ...
```

---

## 27.4 Musica + SFX

Il SID ha 3 voci indipendenti. Tipicamente:

```
Voce 1: melodia
Voce 2: accompagnamento/basso
Voce 3: effetti sonori (SFX)
```

Gestione:

```asm
; Player musica usa voci 1 e 2
; SFX usa voce 3

ENGINE_AUDIO_UPDATE
    ; Se SFX attivo, non sovrascrivere voce 3
    LDA SFX_ACTIVE
    BEQ AU_NOSFX

    ; SFX prende il controllo di voce 3
    LDA SFX_FREQ_LO
    STA SID_V3_FREQ_LO
    LDA SFX_FREQ_HI
    STA SID_V3_FREQ_HI
    LDA #$11           ; Square + gate ON
    STA SID_V3_CTRL
    RTS

AU_NOSFX
    ; Voce 3 libera — il player la gestisce
    RTS
```

---

## 27.5 Player Compatto (DefMon Stile)

Un player minimal puo essere scritto a mano:

```asm
; Player SID minimal — note in tabella
; Struttura: una nota per frame

MUSIC_TABLE
    ; Formato: freq_lo, freq_hi, waveform, durata
    .byte $00, $00, $00, $00   ; pausa

    .byte $F1, $0E, $11, $08   ; nota 1: Do5
    .byte $00, $00, $00, $04   ; pausa
    .byte $5B, $11, $11, $08   ; nota 2: Re5
    .byte $00, $00, $00, $04   ; pausa
    .byte $FF                  ; fine

MUSIC_PLAY
    LDA MUSIC_DATA_PTR
    TAX
    LDA MUSIC_TABLE,X
    CMP #$FF
    BEQ MP_LOOP        ; fine → loop

    ; Frequenza
    LDA MUSIC_TABLE,X
    STA SID_V1_FREQ_LO
    LDA MUSIC_TABLE+1,X
    STA SID_V1_FREQ_HI

    ; Waveform + gate
    LDA MUSIC_TABLE+2,X
    STA SID_V1_CTRL

    ; Durata
    LDA MUSIC_TABLE+3,X
    STA MP_COUNTER

    ; Avanza puntatore
    TXA
    CLC
    ADC #4
    STA MUSIC_DATA_PTR
    RTS

MP_LOOP
    LDA #0
    STA MUSIC_DATA_PTR  ; loop al punto 0
    RTS

MUSIC_DATA_PTR
    .byte 0
MP_COUNTER
    .byte 0
```

---

## 27.6 Volume e Mixaggio

Per mixare musica e SFX senza conflitti:

```asm
MIXER_FRAME
    ; Player musica scrive SID
    JSR MUSIC_PLAY

    ; Se SFX attivo, sovrascrivi solo la voce SFX
    LDA SFX_ACTIVE
    BEQ MX_NOFX

    ; Salva stato voce 3 del player
    LDA SID_V3_CTRL
    PHA

    ; Suona SFX su voce 3
    JSR PLAY_SFX

    ; Dopo SFX, ripristina player
    PLA
    STA SID_V3_CTRL

MX_NOFX
    RTS
```

---

## 27.7 Importare da GoatTracker

GoatTracker esporta in formato `.asm`:

```asm
; File esportato da GoatTracker
; (esempio)
* = $C000

    .include "gt-player.asm"   ; Player engine

; Dati della canzone
    .include "my-song.asm"

; Entry point
INIT
    JSR GT_INIT
    RTS

PLAY
    JSR GT_PLAY
    RTS
```

---

## Esercizi

### Esercizio 1
Scrivi un player SID minimale che riproduce una scala di note
(square wave, voce 1) in loop, avanzando una nota per frame.

### Esercizio 2
Aggiungi una seconda voce di accompagnamento (triangolo, voce 2)
al player dell'esercizio 1.

### Esercizio 3
Integra il player musicale nel gioco tramite IRQ: avvia la musica
nella schermata titolo, fermala in game over.

### Esercizio 4
Implementa un mixer che permette a musica (voci 1-2) e SFX (voce 3)
di coesistere senza conflitti.

### Esercizio 5
Esporta una melodia semplice da GoatTracker e integrala nel progetto
con `.include`. Scrivi le routine INIT/PLAY.

---

## Riferimenti

- [Capitolo 14 — Audio SID Base](14-audio-sid-base.md) — registri SID, waveform, ADSR
- [Capitolo 15 — Audio Engine e SFX](15-audio-engine-e-sfx.md) — coda SFX
- [GoatTracker](https://sourceforge.net/projects/goattracker2/) — music tracker per C64
- [Soluzioni](../soluzioni/cap27-music-tracker.asm) — soluzioni degli esercizi
