// =============================================
// CAP03 — Indirizzamento e tabelle / Addressing & Tables
// Comandi: LDX, LDY, STA zp,X, LDA (zp,X), JSR, RTS, PHA, PLA
// Difficulty: Beginner-Intermediate
// =============================================
:BasicUpstart2(start)

start:
    // Inizializza schermo con colori da tabella
    ldx #0
!loop:
    lda colorTable, x    // Indirizzamento assoluto indicizzato
    sta $D800, x         // Color RAM
    sta $D900, x
    sta $DA00, x
    sta $DB00, x
    inx
    bne !loop-

    // Esempio stack: chiama subroutine che modifica A,X,Y
    lda #5
    ldx #10
    ldy #20
    jsr multiplyByTwo    // Dopo JSR, A=10, X=20, Y=40

    // Usa il risultato per il bordo
    sta $D020

    rts

// ----------------------------------
// multiplyByTwo — Raddoppia A, X, Y
// Salva tutto sullo stack
// ----------------------------------
multiplyByTwo:
    pha
    txa
    pha
    tya
    pha

    // Raddoppia A (usando shift)
    pla
    asl
    tay

    // Raddoppia X
    pla
    asl
    tax

    // Raddoppia Y (originale A)
    pla
    asl

    rts

// ----------------------------------
// Tabella colori / Color table
// ----------------------------------
colorTable:
    .byte 0, 6, 2, 4, 5, 3, 7, 1
    .byte 1, 7, 3, 5, 4, 2, 6, 0
