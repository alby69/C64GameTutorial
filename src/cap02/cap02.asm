// =============================================
// CAP02 — Istruzioni fondamentali / Fundamentals
// Comandi: CMP, BEQ, BNE, BCC, BCS, INC, DEC, ADC, SBC
// Difficulty: Beginner
// =============================================
:BasicUpstart2(start)

start:
    // Inizializza contatore
    lda #0
    sta counter

mainLoop:
    // Incrementa contatore
    inc counter
    lda counter

    // Se contatore == 16, resetta
    cmp #16
    bne !noReset+
    lda #0
    sta counter
!noReset:

    // Visualizza contatore sul bordo (effetto "barra")
    sta $D020

    // Ritardo ~1/10 secondo
    jsr delay

    jmp mainLoop

// ----------------------------------
// DELAY — Ritardo con loop annidati
// A, X, Y vengono salvati
// ----------------------------------
delay:
    pha
    txa
    pha
    tya
    pha

    ldy #10
outer:
    ldx #255
inner:
    dex
    bne inner
    dey
    bne outer

    pla
    tay
    pla
    tax
    pla
    rts

counter: .byte 0
