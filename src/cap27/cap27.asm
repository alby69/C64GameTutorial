// =============================================
// CAP27 — Music Tracker Integration
// Difficulty: Expert
// =============================================
// Nota: richiede file .sid esportato da GoatTracker
// e player routine (es. $1000-$1FFF)

:BasicUpstart2(start)

start:
    // Inizializza player
    lda #0
    jsr $1000       // Init music

    // Setup IRQ
    sei
    lda #<musicIrq
    sta $0314
    lda #>musicIrq
    sta $0315
    cli

!loop:
    jmp !loop-

musicIrq:
    pha
    jsr $1003       // Play music
    lda $D019
    sta $D019
    pla
    rti
