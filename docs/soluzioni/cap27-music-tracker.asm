; ─────────────────────────────────────────────────────
; Soluzioni esercizi Capitolo 27 — Music Tracker
; ─────────────────────────────────────────────────────

; ─────────────────────────────────────────────────────
; Esercizio 1 — Player scala di note mininale
; ─────────────────────────────────────────────────────

SID_V1_FREQ_LO = $D400
SID_V1_FREQ_HI = $D401
SID_V1_CTRL    = $D404
SID_V1_AD      = $D405
SID_V1_SR      = $D406
SID_VOL        = $D418

SCALE_DATA
    ; freq_lo, freq_hi
    .byte $F1, $0E   ; C5
    .byte $5B, $11   ; D5
    .byte $BB, $13   ; E5
    .byte $F1, $0E   ; C5
    .byte $F1, $0E   ; C5
    .byte $F1, $0E   ; C5
    .byte $5B, $11   ; D5
    .byte $5B, $11   ; D5
    .byte $F1, $0E   ; C5
    .byte $5B, $11   ; D5
    .byte $BB, $13   ; E5
    .byte $00, $00   ; fine

SCALE_INIT
    LDA #$09          ; gate ON
    STA SID_V1_CTRL
    LDA #$41          ; AD: attack 4, decay 1
    STA SID_V1_AD
    LDA #$A0          ; SR: sustain A, release 0
    STA SID_V1_SR
    LDA #15
    STA SID_VOL
    RTS

SCALE_PLAY
    LDX NOTE_PTR
    LDA SCALE_DATA,X
    BNE SP_NEXT
    RTS               ; fine

SP_NEXT
    STA SID_V1_FREQ_LO
    LDA SCALE_DATA+1,X
    STA SID_V1_FREQ_HI

    ; Gate on (re-strike)
    LDA #$00
    STA SID_V1_CTRL
    LDA #$09
    STA SID_V1_CTRL

    INX
    INX
    STX NOTE_PTR
    RTS

NOTE_PTR
    .byte 0

; ─────────────────────────────────────────────────────
; Esercizio 2 — Voce accompagnamento (triangolo)
; ─────────────────────────────────────────────────────

SID_V2_FREQ_LO = $D407
SID_V2_FREQ_HI = $D408
SID_V2_CTRL    = $D40B

; Aggiungere a SCALE_INIT:
;   LDA #$41
;   STA $D40C          ; V2 AD
;   LDA #$A0
;   STA $D40D          ; V2 SR
;   LDA #$11           ; triangolo + gate
;   STA SID_V2_CTRL

; In SCALE_PLAY, duplicare per voce 2
; con frequenza un'ottava sotto (dividi per 2):

BASS_PLAY
    LDA SID_V1_FREQ_LO
    LSR
    STA SID_V2_FREQ_LO
    LDA SID_V1_FREQ_HI
    ROR
    STA SID_V2_FREQ_HI

    ; Gate re-strike per voce 2
    LDA #$00
    STA SID_V2_CTRL
    LDA #$11
    STA SID_V2_CTRL
    RTS

; ─────────────────────────────────────────────────────
; Esercizio 3 — Integrazione IRX nel gioco
; ─────────────────────────────────────────────────────

; In setup:
;   JSR SCALE_INIT
;   JSR MUSIC_INIT

; IRQ raster ($FFFA, $FFFB)
;   .WORD IRQ_HANDLER

; IRQ_HANDLER
;   JSR MUSIC_PLAY
;   JMP $EA31          ; KERNAL IRQ chain

; Titolo → avvia musica:
MUSIC_TITLE
    LDA #1
    STA MUSIC_ON
    JSR MUSIC_INIT
    RTS

; Game over → ferma musica:
MUSIC_STOP
    LDA #0
    STA MUSIC_ON
    ; Silenzia SID
    LDA #$00
    STA SID_V1_CTRL
    STA SID_V2_CTRL
    STA SID_V3_CTRL
    RTS

MUSIC_ON
    .byte 0

; ─────────────────────────────────────────────────────
; Esercizio 4 — Mixer musica + SFX
; ─────────────────────────────────────────────────────
; Musica: voci 1-2, SFX: voce 3

SID_V3_FREQ_LO = $D40E
SID_V3_FREQ_HI = $D40F
SID_V3_CTRL    = $D412
SID_V3_AD      = $D410
SID_V3_SR      = $D411

MIXER_FRAME
    JSR MUSIC_PLAY

    LDA SFX_ACTIVE
    BEQ MX_NOFX

    ; Salva stato voce 3 della musica
    LDA SID_V3_CTRL
    PHA
    LDA SID_V3_FREQ_LO
    PHA
    LDA SID_V3_FREQ_HI
    PHA

    ; SFX
    JSR PLAY_SFX

    ; Ripristina voce 3
    PLA
    STA SID_V3_FREQ_HI
    PLA
    STA SID_V3_FREQ_LO
    PLA
    STA SID_V3_CTRL

MX_NOFX
    RTS

SFX_ACTIVE
    .byte 0

PLAY_SFX
    ; Suona effetto su voce 3
    LDA SFX_FREQ_LO
    STA SID_V3_FREQ_LO
    LDA SFX_FREQ_HI
    STA SID_V3_FREQ_HI
    LDA #$81          ; noise + gate
    STA SID_V3_CTRL
    LDA #$08          ; Attack 0, decay 8
    STA SID_V3_AD
    LDA #$00
    STA SID_V3_SR

    DEC SFX_DURATION
    BNE FX_RUNNING
    ; SFX finito
    LDA #0
    STA SFX_ACTIVE
    LDA #$00
    STA SID_V3_CTRL   ; silent

FX_RUNNING
    RTS

SFX_DURATION
    .byte 16
SFX_FREQ_LO
    .byte $00
SFX_FREQ_HI
    .byte $1A

; Trigger SFX (chiamata esterna):
TRIGGER_SFX
    LDA #1
    STA SFX_ACTIVE
    LDA #16
    STA SFX_DURATION
    LDA #$00
    STA SFX_FREQ_LO
    LDA #$1A
    STA SFX_FREQ_HI
    RTS

; Azzera SFX (chiamata esterna):
STOP_SFX
    LDA #0
    STA SFX_ACTIVE
    LDA #$00
    STA SID_V3_CTRL
    RTS

; ─────────────────────────────────────────────────────
; Esercizio 5 — Integrazione GoatTracker
; ─────────────────────────────────────────────────────
; Esportato da GoatTracker in due file:
;   gt-player.asm     — motore player
;   my-song.asm       — dati canzone

; Per usare:
;   .include "gt-player.asm"
;   .include "my-song.asm"
;
; MUSIC_INIT = inizio dati di inizializzazione
; MUSIC_PLAY = player tick
;
; Chiamare JSR MUSIC_INIT all'avvio
; Chiamare JSR MUSIC_PLAY in IRQ (50 Hz)

; Esempio:
;   INIT
;       JSR GT_INIT     ; GoatTracker init
;       RTS
;
;   PLAY
;       JSR GT_PLAY     ; GoatTracker play
;       RTS
