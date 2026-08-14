// =============================================
// CAP14 — SID Base / Basic SID
// Difficulty: Beginner-Intermediate
// =============================================
:BasicUpstart2(start)

start:
    jsr sidInit
    jsr playBeep

!loop:
    jmp !loop-

sidInit:
    lda #0
    sta $D415    // Filtro cutoff low
    sta $D416    // Filtro cutoff high
    sta $D417    // Resonance / voice input
    sta $D418    // Volume e filtro
    lda #15
    sta $D418    // Volume max, nessun filtro
    rts

playBeep:
    // Frequenza ~440Hz (voce 1)
    lda #$11
    sta $D400
    lda #$09
    sta $D401

    // ADSR: Attack=0, Decay=5, Sustain=10, Release=2
    lda #$05
    sta $D405
    lda #$A2
    sta $D406

    // Control: Gate + Sawtooth
    lda #%00100001
    sta $D404

    // Attendi un po'
    ldx #100
!wait:
    ldy #255
!inner:
    dey
    bne !inner-
    dex
    bne !wait-

    // Rilascia nota (togli Gate)
    lda #%00100000
    sta $D404
    rts
