// =============================================
// CAP25 — Turbo Loader / Turbo Loader
// Difficulty: Expert
// =============================================
* = $0801

.byte $0C, $08, $0A, $00, $9E, $20, $32, $30, $36, $34, $00, $00, $00
* = $0810

start:
    sei
    lda #$00
    sta $DD00       // Porta seriale

    // Invia comando turbo al drive
    jsr sendTurboCommand

    // Ricevi dati a alta velocità
    jsr receiveFast

    // Esegui
    jmp $2000

sendTurboCommand:
    // Implementazione specifica per drive 1541
    rts

receiveFast:
    ldx #0
!loop:
    lda $DD00       // Legge bit seriale
    // ... decodifica
    sta $2000, x
    inx
    bne !loop-
    rts
