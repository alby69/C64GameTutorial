// =============================================
// CAP24 — Scrolling / Scrolling
// Difficulty: Tools & Polish
// =============================================
:BasicUpstart2(start)

start:
    jsr initScroll

scrollLoop:
    jsr doScroll
    jsr delay
    jmp scrollLoop

initScroll:
    lda #0
    sta scrollX
    sta scrollY
    rts

doScroll:
    // Scroll orizzontale fine
    inc scrollX
    lda scrollX
    and #$07
    sta $D016

    // Ogni 8 pixel, scroll grossolano
    lda scrollX
    and #$07
    bne !done+
    jsr scrollScreenLeft
!done:
    rts

scrollScreenLeft:
    // Sposta ogni riga a sinistra di 1 carattere
    ldx #0
!rowLoop:
    ldy #0
!charLoop:
    lda $0401, y
    sta $0400, y
    iny
    cpy #39
    bcc !charLoop-

    // Nuovo carattere a destra (dalla mappa)
    lda #2
    sta $0427

    // Prossima riga
    lda $D016
    clc
    adc #40
    sta $D016
    inx
    cpx #25
    bcc !rowLoop-
    rts

scrollX: .byte 0
scrollY: .byte 0

delay:
    ldx #100
!loop:
    ldy #100
!inner:
    dey
    bne !inner-
    dex
    bne !loop-
    rts
