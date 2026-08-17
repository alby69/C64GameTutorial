// =============================================
// CAP07 — Raster IRQ / Raster Interrupt
// Difficulty: Intermediate
// =============================================
:BasicUpstart2(start)

start:
    sei

    // Disabilita interrupt CIA
    lda #$7F
    sta $DC0D
    sta $DD0D
    lda $DC0D
    lda $DD0D

    // Imposta IRQ vector
    lda #<irqTop
    sta $0314
    lda #>irqTop
    sta $0315

    // Linea raster 100
    lda #100
    sta $D012
    lda $D011
    and #$7F
    sta $D011

    // Abilita interrupt raster
    lda #$01
    sta $D01A

    cli

!loop:
    jmp !loop-

// ----------------------------------
// irqTop — Scatta a linea 100
// ----------------------------------
irqTop:
    pha
    txa
    pha
    tya
    pha

    // Cambia bordo in rosso
    lda #2
    sta $D020

    // Prepara prossimo IRQ a linea 200
    lda #200
    sta $D012
    lda #<irqBottom
    sta $0314
    lda #>irqBottom
    sta $0315

    // Ack VIC
    lda $D019
    sta $D019

    pla
    tay
    pla
    tax
    pla
    rti

// ----------------------------------
// irqBottom — Scatta a linea 200
// ----------------------------------
irqBottom:
    pha
    txa
    pha
    tya
    pha

    // Cambia bordo in blu
    lda #6
    sta $D020

    // Prepara prossimo IRQ a linea 100
    lda #100
    sta $D012
    lda #<irqTop
    sta $0314
    lda #>irqTop
    sta $0315

    // Ack VIC
    lda $D019
    sta $D019

    pla
    tay
    pla
    tax
    pla
    rti
