// Converted to Kick Assembler syntax
.segmentdef Ex1 [start=$c000]
.segmentdef Ex2 [start=$c000]
.segmentdef Ex3 [start=$c000]
.segmentdef Ex4 [start=$c000]
.segmentdef Ex5 [start=$c000]

// --- Shared Constants ---
.const COUNTER = $02     // variabile in Zero Page

// =============================================
// SOLUZIONI Capitolo 2 — Istruzioni Fondamentali
// --- METADATA ---
// chapter: 2
// title: Istruzioni Fondamentali
// instructions: [LDA, STA, INC, DEC, CMP, BEQ, BNE, JMP, JSR, RTS]
// difficulty: beginner
// --- END METADATA ---
// =============================================
//
// Mappa esercizi:
//   1: bordo incrementa 0→15 poi fermo
//   2: contatore in Zero Page
//   3: delay ~1 secondo (3 cicli annidati)
//   4: sfondo lampeggia blu/nero ogni secondo
//   5: rainbow effetto (bordo cicla con delay)
//
// =============================================

// --- ESERCIZIO 1: bordo incrementa 0→15 poi fermo ---
.segment Ex1
.namespace Ex1 {
    // *=$C000
        lda #0
    LOOP:

        sta $D020
        // non serve A, INC $D020
        inc $D020      // incrementa registro bordo
        lda $D020
        cmp #15
        beq DONE
        jmp LOOP
    DONE:

        jmp DONE

    // Versione piu pulita:
    // *=$C000
        lda #0
    LOOP2:

        sta $D020
        inc $D020
        lda $D020
        cmp #16        // fermati a 16 (0-15)
        bne LOOP2
    HALT:

        jmp HALT

}

// --- ESERCIZIO 2: contatore in Zero Page ---
.segment Ex2
.namespace Ex2 {
    // *=$C000
        lda #0
        sta COUNTER
    LOOP3:

        lda COUNTER
        sta $D020
        inc COUNTER
        lda COUNTER
        cmp #16
        bne LOOP3
    DONE3:

        jmp DONE3

}

// --- ESERCIZIO 3: delay ~1 secondo (3 cicli annidati) ---
.segment Ex3
.namespace Ex3 {
    // *=$C000
    DELAY:

        ldx #$FF       // ciclo esterno
    OUTER:

        ldy #$FF       // ciclo medio
    MID:

        nop
        nop
        nop
        nop
        nop
        dey
        bne MID
        dex
        bne OUTER
        rts

}

// --- ESERCIZIO 5: rainbow effetto (bordo cicla con delay) ---
.segment Ex4
.namespace Ex4 {
    // *=$C000
        lda #0
    LOOP5:

        sta $D020
        jsr DELAY5
        inc $D020
        jmp LOOP5
    DELAY5:

        ldx #$20
    D15:

        ldy #$FF
    D25:

        dey
        bne D25
        dex
        bne D15
        rts

}

// --- ESERCIZIO 4: sfondo lampeggia blu/nero ogni secondo ---
.segment Ex5
.namespace Ex5 {
    // *=$C000
    MAIN:

        lda #6         // blu
        sta $D021
        jsr DELAY_EX4
        lda #0         // nero
        sta $D021
        jsr DELAY_EX4
        jmp MAIN

    DELAY_EX4:

        ldx #$FF
    OUTER2:

        ldy #$FF
    MID2:

        nop
        dey
        bne MID2
        dex
        bne OUTER2
        rts
}
