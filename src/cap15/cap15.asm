// =============================================
// CAP15 — Music Player / Music Player
// Difficulty: Intermediate
// =============================================
:BasicUpstart2(start)

start:
    jsr sidInit
    jsr musicInit

    // Setup IRQ per musica
    sei
    lda #$7F
    sta $DC0D
    lda #<musicIrq
    sta $0314
    lda #>musicIrq
    sta $0315
    lda #250
    sta $D012
    lda #$01
    sta $D01A
    cli

!loop:
    jmp !loop-

musicIrq:
    pha
    txa
    pha

    jsr musicUpdate

    lda $D019
    sta $D019

    pla
    tax
    pla
    rti

// ----------------------------------
// musicInit
// ----------------------------------
musicInit:
    lda #0
    sta musicIndex
    sta musicTimer
    rts

// ----------------------------------
// musicUpdate — Chiama ogni 1/50s
// ----------------------------------
musicUpdate:
    dec musicTimer
    bpl !done+

    // Leggi nota dalla tabella
    ldx musicIndex
    lda songData, x
    cmp #$FF        // Fine canzone?
    beq !restart+

    // Frequenza
    sta $D400
    inx
    lda songData, x
    sta $D401
    inx

    // Durata
    lda songData, x
    sta musicTimer
    inx

    stx musicIndex

    // Attacca nota
    lda #%01000001   // Pulse + Gate
    sta $D404
    lda #$08
    sta $D405
    lda #$80
    sta $D406

    jmp !done+

!restart:
    ldx #0
    stx musicIndex
!done:
    rts

sidInit:
    lda #15
    sta $D418
    rts

musicIndex: .byte 0
musicTimer: .byte 0

// Nota, durata (in frame)
songData:
    .word $0111, 10
    .word $0122, 10
    .word $0133, 10
    .word $0144, 20
    .word $0133, 10
    .word $0122, 10
    .word $0111, 30
    .byte $FF       // End
