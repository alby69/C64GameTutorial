// =============================================
// CAP13 — HUD e Punteggio / HUD and Score
// Difficulty: Intermediate
// =============================================
:BasicUpstart2(start)

start:
    jsr clearScreen
    jsr drawHud

    // Test: aggiungi 125 punti
    lda #125
    jsr addScore
    jsr updateScoreDisplay

!loop:
    jmp !loop-

// ----------------------------------
// drawHud — Disegna testo fisso
// ----------------------------------
drawHud:
    ldx #0
!loop:
    lda hudText, x
    beq !done+
    sta $0400, x
    lda #1      // Bianco
    sta $D800, x
    inx
    jmp !loop-
!done:
    rts

// ----------------------------------
// addScore — Somma A al punteggio BCD
// ----------------------------------
addScore:
    sed         // Decimal mode
    clc
    adc scoreLow
    sta scoreLow
    lda scoreMid
    adc #0
    sta scoreMid
    lda scoreHigh
    adc #0
    sta scoreHigh
    cld         // Clear decimal
    rts

// ----------------------------------
// updateScoreDisplay — Scrive 6 cifre a $0400+6
// ----------------------------------
updateScoreDisplay:
    lda scoreHigh
    jsr byteToDigits
    sta $0406
    stx $0407

    lda scoreMid
    jsr byteToDigits
    sta $0408
    stx $0409

    lda scoreLow
    jsr byteToDigits
    sta $040A
    stx $040B

    // Colora cifre
    ldx #5
    lda #5      // Verde
!loop:
    sta $D806, x
    dex
    bpl !loop-
    rts

// ----------------------------------
// byteToDigits — Converte A in 2 cifre PETSCII
// A = high nibble, X = low nibble
// ----------------------------------
byteToDigits:
    pha
    lsr
    lsr
    lsr
    lsr
    clc
    adc #48     // '0' in PETSCII
    tay
    pla
    and #$0F
    clc
    adc #48
    tax
    tya
    rts

clearScreen:
    lda #32
    ldx #0
!loop:
    sta $0400, x
    sta $0500, x
    sta $0600, x
    sta $0700, x
    inx
    bne !loop-
    rts

hudText:
    .text "SCORE:      LIVES:3"
    .byte 0

scoreLow:  .byte 0
scoreMid:  .byte 0
scoreHigh: .byte 0
