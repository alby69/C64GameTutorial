// =============================================
// CAP08 — Stable Raster / Stable Raster
// Difficulty: Advanced
// =============================================
:BasicUpstart2(start)

start:
    sei
    lda #$35        // Bank out KERNAL and BASIC
    sta $01

    lda #$7F
    sta $DC0D
    sta $DD0D
    lda $DC0D
    lda $DD0D

    lda #<irqFirst
    sta $FFFE
    lda #>irqFirst
    sta $FFFF

    lda #$1B
    sta $D011
    lda #$01
    sta $D01A

    lda #50
    sta $D012

    cli

!loop:
    jmp !loop-

// ----------------------------------
// irqFirst — Stabilizza con double-IRQ
// ----------------------------------
irqFirst:
    pha
    txa
    pha

    lda #<irqStable
    sta $FFFE
    lda #>irqStable
    sta $FFFF

    inc $D012
    lda $D012
    cmp $D012
    beq !skip+
!skip:

    tsx
    inx
    inx
    txs

    lda #<irqStable
    sta $0101
    lda #>irqStable
    sta $0102

    lda $D019
    sta $D019

    pla
    tax
    pla
    rti

// ----------------------------------
// irqStable — Eseguito con timing perfetto
// ----------------------------------
irqStable:
    pha
    txa
    pha
    tya
    pha

    // Ora puoi fare effetti critici (es. cambio bordo senza jitter)
    inc $D020
    dec $D020

    // Ripristina vector
    lda #<irqFirst
    sta $FFFE
    lda #>irqFirst
    sta $FFFF
    lda #50
    sta $D012

    lda $D019
    sta $D019

    pla
    tay
    pla
    tax
    pla
    rti
