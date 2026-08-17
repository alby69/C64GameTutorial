// =============================================
// CAP30 — Full-Screen Scrolling / Full-Screen Scroll
// Difficulty: Expert
// =============================================
:BasicUpstart2(start)

start:
    sei
    lda #<irqScroll
    sta $0314
    lda #>irqScroll
    sta $0315
    cli
    rts

irqScroll:
    pha

    // Cambia bordo per misurare tempo
    inc $D020

    // Aggiorna solo le righe visibili che cambiano
    jsr updateVisibleRows

    dec $D020

    lda $D019
    sta $D019
    pla
    rti

updateVisibleRows:
    // Ottimizzazione: confronta con buffer precedente
    // e scrivi solo se diverso
    rts
