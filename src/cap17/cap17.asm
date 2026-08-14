// =============================================
// CAP17 — Parallax Scrolling / Parallax Scrolling
// Difficulty: Advanced
// =============================================
:BasicUpstart2(start)

start:
    jsr initScroll
    jsr initIrq

!loop:
    jmp !loop-

initScroll:
    // Imposta VIC per usare 2 charset alternati
    lda #%00100010
    sta $D018
    rts

initIrq:
    sei
    lda #$7F
    sta $DC0D
    lda #<irqParallax
    sta $0314
    lda #>irqParallax
    sta $0315
    lda #50
    sta $D012
    lda #$01
    sta $D01A
    cli
    rts

// IRQ ogni 8 linee raster per cambiare charset
irqParallax:
    pha

    inc parallaxLine
    lda parallaxLine
    and #$07
    tax

    // Scegli charset in base al layer
    lda charsetTable, x
    sta $D018

    // Prossima linea
    lda $D012
    clc
    adc #8
    sta $D012

    lda $D019
    sta $D019

    pla
    rti

charsetTable:
    .byte %00100010, %00100110, %00100010, %00100110
    .byte %00100010, %00100110, %00100010, %00100110

parallaxLine: .byte 0
