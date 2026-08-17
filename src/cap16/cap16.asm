// =============================================
// CAP16 — Sprite Multiplexing / Sprite Multiplexing
// Difficulty: Advanced
// =============================================
.const MAX_SPRITES = 16

:BasicUpstart2(start)

start:
    jsr initSprites
    jsr initIrq

!loop:
    jmp !loop-

initSprites:
    rts

initIrq:
    sei
    lda #$7F
    sta $DC0D
    lda #<irqTop
    sta $0314
    lda #>irqTop
    sta $0315
    lda #50
    sta $D012
    lda #$01
    sta $D01A
    cli
    rts

// ----------------------------------
// irqTop — Primo split, sprite 0-7
// ----------------------------------
irqTop:
    pha
    txa
    pha
    tya
    pha

    jsr sortSprites
    jsr updateSprites0

    // Prossimo split a linea 180
    lda #180
    sta $D012
    lda #<irqBottom
    sta $0314
    lda #>irqBottom
    sta $0315

    lda $D019
    sta $D019

    pla
    tay
    pla
    tax
    pla
    rti

// ----------------------------------
// irqBottom — Secondo split, sprite 8-15
// ----------------------------------
irqBottom:
    pha
    txa
    pha
    tya
    pha

    jsr updateSprites8

    lda #50
    sta $D012
    lda #<irqTop
    sta $0314
    lda #>irqTop
    sta $0315

    lda $D019
    sta $D019

    pla
    tay
    pla
    tax
    pla
    rti

// ----------------------------------
// sortSprites — Bubble sort per Y
// ----------------------------------
sortSprites:
    ldx #0
!outer:
    ldy #0
!inner:
    lda spriteY, y
    cmp spriteY+1, y
    bcc !noSwap+

    // Scambia Y
    lda spriteY, y
    pha
    lda spriteY+1, y
    sta spriteY, y
    pla
    sta spriteY+1, y

    // Scambia X
    lda spriteX, y
    pha
    lda spriteX+1, y
    sta spriteX, y
    pla
    sta spriteX+1, y

!noSwap:
    iny
    cpy #MAX_SPRITES-1
    bcc !inner-

    inx
    cpx #MAX_SPRITES-1
    bcc !outer-
    rts

// ----------------------------------
// updateSprites0 — Scrive sprite 0-7
// ----------------------------------
updateSprites0:
    ldx #0
    ldy #0
!loop:
    lda spriteY, x
    sta $D001, y
    lda spriteX, x
    sta $D000, y
    iny
    iny
    inx
    cpx #8
    bcc !loop-

    lda #%11111111
    sta $D015
    rts

// ----------------------------------
// updateSprites8 — Scrive sprite 8-15 su hardware 0-7
// ----------------------------------
updateSprites8:
    ldx #8
    ldy #0
!loop:
    lda spriteY, x
    sta $D001, y
    lda spriteX, x
    sta $D000, y
    iny
    iny
    inx
    cpx #MAX_SPRITES
    bcc !loop-
    rts

* = $2000
spriteX: .fill MAX_SPRITES, 0
spriteY: .fill MAX_SPRITES, 0
