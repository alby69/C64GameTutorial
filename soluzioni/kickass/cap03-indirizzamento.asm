// Converted to Kick Assembler syntax
.segmentdef Ex1 [start=$c000]
.segmentdef Ex2 [start=$c000]
.segmentdef Ex3 [start=$c000]
.segmentdef Ex4 [start=$c000]
.segmentdef Ex5 [start=$c000]

// --- Shared Constants ---

// =============================================
// SOLUZIONI Capitolo 3 — Indirizzamento e Cicli
// --- METADATA ---
// chapter: 3
// title: Indirizzamento e Cicli
// difficulty: beginner
// --- END METADATA ---
// =============================================
//
// Mappa esercizi:
//   1: 'A' in riga 10, col 15, colore verde
//   2: A B C D nelle prime 4 celle
//   3: prima riga con '*', ogni cella colore diverso
//   4: tabella 0-9 nelle prime 10 posizioni
//   5: messaggio 4 lettere scorre a destra ogni secondo
//
// =============================================
// --- ESERCIZIO 1: 'A' in riga 10, col 15, colore verde ---
.segment Ex1
.namespace Ex1 {
    // Formula: SCREEN_RAM + riga*40 + colonna = $0400 + 10*40 + 15
    //         = $0400 + 400 + 15 = $0400 + $190 + $F = $059F
    // *=$C000
        lda #1         // codice PETSCII 'A'
        sta $059F
        lda #5         // verde
        sta $D9DF      // Color RAM: $D800 + offset ($59F)
        rts

}

// --- ESERCIZIO 2: A B C D nelle prime 4 celle ---
.segment Ex2
.namespace Ex2 {
    // *=$C000
        lda #1         // 'A'
        sta $0400
        lda #2         // 'B'
        sta $0401
        lda #3         // 'C'
        sta $0402
        lda #4         // 'D'
        sta $0403
        rts

}

// --- ESERCIZIO 3: prima riga con '*', ogni cella colore diverso ---
.segment Ex3
.namespace Ex3 {
    // *=$C000
        ldx #0
        lda #42        // codice '*'
    LOOP:

        sta $0400,X    // screen RAM iniziando da $0400
        txa
        sta $D800,X    // Color RAM: colore = indice colonna
        inx
        cpx #40
        bne LOOP
        rts

}

// --- ESERCIZIO 4: tabella 0-9 nelle prime 10 posizioni ---
.segment Ex4
.namespace Ex4 {
    // *=$C000
        ldx #0
        lda #48        // PETSCII '0'
    LOOP4:

        sta $0400,X
        clc
        adc #1         // carattere successivo
        inx
        cpx #10
        bne LOOP4
        rts

}

// --- ESERCIZIO 5: messaggio 4 lettere scorre a destra ogni secondo ---
.segment Ex5
.namespace Ex5 {
    // *=$C000
        ldx #0
    SHIFT:

        jsr DELAY
        inx
        cpx #36        // 40-4 = posizione massima
        bne SHIFT
        ldx #0
        jmp SHIFT

    DELAY:

        ldy #$FF
    D1:  ldx #$FF
    D2:  nop
        dex
        bne D2
        dey
        bne D1
        rts
}
