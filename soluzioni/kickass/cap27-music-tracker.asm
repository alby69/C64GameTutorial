// Converted to Kick Assembler syntax
.segmentdef Ex1 [start=$c000]

// --- Shared Constants ---
.const MUSIC_INIT = $1000
.const MUSIC_PLAY = $1003
.const SID_V1_FREQ_LO = $D400
.const SID_V1_FREQ_HI = $D401
.const SID_V1_CTRL = $D404
.const SID_V1_AD = $D405
.const SID_V1_SR = $D406
.const SID_VOL = $D418
.const SID_V2_FREQ_LO = $D407
.const SID_V2_FREQ_HI = $D408
.const SID_V2_CTRL = $D40B
.const SID_V3_FREQ_LO = $D40E
.const SID_V3_FREQ_HI = $D40F
.const SID_V3_CTRL = $D412
.const SID_V3_AD = $D410
.const SID_V3_SR = $D411

// ─────────────────────────────────────────────────────
// Soluzioni esercizi Capitolo 27 — Music Tracker
// --- METADATA ---
// chapter: 27
// title: Music Tracker
// difficulty: advanced
// --- END METADATA ---
// ─────────────────────────────────────────────────────


// ─────────────────────────────────────────────────────
// Esercizio 1 — Player scala di note mininale
// ─────────────────────────────────────────────────────


SCALE_DATA:

    // freq_lo, freq_hi
    .byte $F1, $0E   // C5
    .byte $5B, $11   // D5
    .byte $BB, $13   // E5
    .byte $F1, $0E   // C5
    .byte $F1, $0E   // C5
    .byte $F1, $0E   // C5
    .byte $5B, $11   // D5
    .byte $5B, $11   // D5
    .byte $F1, $0E   // C5
    .byte $5B, $11   // D5
    .byte $BB, $13   // E5
    .byte $00, $00   // fine

SCALE_INIT:

    lda #$09          // gate ON
    sta SID_V1_CTRL
    lda #$41          // AD: attack 4, decay 1
    sta SID_V1_AD
    lda #$A0          // SR: sustain A, release 0
    sta SID_V1_SR
    lda #15
    sta SID_VOL
    rts

SCALE_PLAY:

    ldx NOTE_PTR
    lda SCALE_DATA,X
    bne SP_NEXT
    rts               // fine

SP_NEXT:

    sta SID_V1_FREQ_LO
    lda SCALE_DATA+1,X
    sta SID_V1_FREQ_HI

    // Gate on (re-strike)
    lda #$00
    sta SID_V1_CTRL
    lda #$09
    sta SID_V1_CTRL

    inx
    inx
    stx NOTE_PTR
    rts

NOTE_PTR:

    .byte 0

// ─────────────────────────────────────────────────────
// Esercizio 2 — Voce accompagnamento (triangolo)
// ─────────────────────────────────────────────────────


// Aggiungere a SCALE_INIT:
//   LDA #$41
//   STA $D40C          ; V2 AD
//   LDA #$A0
//   STA $D40D          ; V2 SR
//   LDA #$11           ; triangolo + gate
//   STA SID_V2_CTRL

// In SCALE_PLAY, duplicare per voce 2
// con frequenza un'ottava sotto (dividi per 2):

BASS_PLAY:

    lda SID_V1_FREQ_LO
    lsr
    sta SID_V2_FREQ_LO
    lda SID_V1_FREQ_HI
    ror
    sta SID_V2_FREQ_HI

    // Gate re-strike per voce 2
    lda #$00
    sta SID_V2_CTRL
    lda #$11
    sta SID_V2_CTRL
    rts

// ─────────────────────────────────────────────────────
// Esercizio 3 — Integrazione IRX nel gioco
// ─────────────────────────────────────────────────────

// In setup:
//   JSR SCALE_INIT
//   JSR MUSIC_INIT

// IRQ raster ($FFFA, $FFFB)
//   .WORD IRQ_HANDLER

// IRQ_HANDLER
//   JSR MUSIC_PLAY
//   JMP $EA31          ; KERNAL IRQ chain

// Titolo → avvia musica:
MUSIC_TITLE:

    lda #1
    sta MUSIC_ON
    jsr MUSIC_INIT
    rts

// Game over → ferma musica:
MUSIC_STOP:

    lda #0
    sta MUSIC_ON
    // Silenzia SID
    lda #$00
    sta SID_V1_CTRL
    sta SID_V2_CTRL
    sta SID_V3_CTRL
    rts

MUSIC_ON:

    .byte 0

// ─────────────────────────────────────────────────────
// Esercizio 4 — Mixer musica + SFX
// ─────────────────────────────────────────────────────
// Musica: voci 1-2, SFX: voce 3


MIXER_FRAME:

    jsr MUSIC_PLAY

    lda SFX_ACTIVE
    beq MX_NOFX

    // Salva stato voce 3 della musica
    lda SID_V3_CTRL
    pha
    lda SID_V3_FREQ_LO
    pha
    lda SID_V3_FREQ_HI
    pha

    // SFX
    jsr PLAY_SFX

    // Ripristina voce 3
    pla
    sta SID_V3_FREQ_HI
    pla
    sta SID_V3_FREQ_LO
    pla
    sta SID_V3_CTRL

MX_NOFX:

    rts

SFX_ACTIVE:

    .byte 0

PLAY_SFX:

    // Suona effetto su voce 3
    lda SFX_FREQ_LO
    sta SID_V3_FREQ_LO
    lda SFX_FREQ_HI
    sta SID_V3_FREQ_HI
    lda #$81          // noise + gate
    sta SID_V3_CTRL
    lda #$08          // Attack 0, decay 8
    sta SID_V3_AD
    lda #$00
    sta SID_V3_SR

    dec SFX_DURATION
    bne FX_RUNNING
    // SFX finito
    lda #0
    sta SFX_ACTIVE
    lda #$00
    sta SID_V3_CTRL   // silent

FX_RUNNING:

    rts

SFX_DURATION:

    .byte 16
SFX_FREQ_LO:

    .byte $00
SFX_FREQ_HI:

    .byte $1A

// Trigger SFX (chiamata esterna):
TRIGGER_SFX:

    lda #1
    sta SFX_ACTIVE
    lda #16
    sta SFX_DURATION
    lda #$00
    sta SFX_FREQ_LO
    lda #$1A
    sta SFX_FREQ_HI
    rts

// Azzera SFX (chiamata esterna):
STOP_SFX:

    lda #0
    sta SFX_ACTIVE
    lda #$00
    sta SID_V3_CTRL
    rts

// ─────────────────────────────────────────────────────
// Esercizio 5 — Integrazione GoatTracker
// ─────────────────────────────────────────────────────
// Esportato da GoatTracker in due file:
//   gt-player.asm     — motore player
//   my-song.asm       — dati canzone

// Per usare:
//   .include "gt-player.asm"
//   .include "my-song.asm"
//
// MUSIC_INIT = inizio dati di inizializzazione
// MUSIC_PLAY = player tick
//
// Chiamare JSR MUSIC_INIT all'avvio
// Chiamare JSR MUSIC_PLAY in IRQ (50 Hz)

// Esempio:
//   INIT
//       JSR GT_INIT     ; GoatTracker init
//       RTS
//
//   PLAY
//       JSR GT_PLAY     ; GoatTracker play
//       RTS
