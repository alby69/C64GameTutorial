// =============================================
// CAP28 — Self-Modifying Code / SMC
// Difficulty: Expert
// =============================================
:BasicUpstart2(start)

start:
    // Invece di LDA ($FB),Y usiamo LDA assoluto modificato

    lda #$C0
    sta modify+2    // Modifica high byte dell'istruzione LDA

    ldy #0
modify:
    lda $C000, y    // Questo indirizzo viene modificato!
    sta $D020

    rts
