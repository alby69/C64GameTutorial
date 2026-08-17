// =============================================
// CAP32 — Compressione + Fast Loader / Compression + Fast Loader
// Difficulty: Expert
// =============================================
// Presupposto: dati compressi con Exomizer, decompresore a $F800

:BasicUpstart2(start)

start:
    // Avvia decompressione
    lda #<$4000     // Sorgente compresso
    sta $FB
    lda #>$4000
    sta $FC
    lda #<$2000     // Destinazione
    sta $FD
    lda #>$2000
    sta $FE
    jsr $F800       // Entry decompresore

    // Ora i dati sono a $2000
    rts

// Fast Loader IRQ: carica 1 blocco per frame
irqLoader:
    pha

    lda loadActive
    beq !done+

    jsr loadNextBlock
    bcc !done+
    lda #0
    sta loadActive    // Caricamento completato

!done:
    lda $D019
    sta $D019
    pla
    rti

loadNextBlock:
    rts

loadActive: .byte 0
