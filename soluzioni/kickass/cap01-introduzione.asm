// Converted to Kick Assembler syntax
.segmentdef Ex1 [start=$c000]
.segmentdef Ex2 [start=$c000]
.segmentdef Ex3 [start=$c000]
.segmentdef Ex4 [start=$c000]
.segmentdef Ex5 [start=$c000]

// --- Shared Constants ---

// =============================================
// SOLUZIONI Capitolo 1 — Introduzione
// --- METADATA ---
// chapter: 1
// title: Introduzione al 6502 e TMP
// instructions: [LDA, STA, JMP, RTS]
// difficulty: beginner
// --- END METADATA ---
// =============================================
//
// Mappa esercizi:
//   1: bordo giallo, sfondo blu
//   2: bordo verde, ciclo infinito
//   3: label GAMELOOP invece di LOOP
//   4: bordo nero, sfondo bianco
//   5: bordo blu chiaro, ciclo infinito FINISH
//
// =============================================

// --- ESERCIZIO 1: bordo giallo, sfondo blu ---
.segment Ex1
.namespace Ex1 {
    // *=$C000
        lda #7      // giallo
        sta $D020   // bordo
        lda #6      // blu
        sta $D021   // sfondo
        rts

}

// --- ESERCIZIO 2: bordo verde, ciclo infinito ---
.segment Ex2
.namespace Ex2 {
    // *=$C000
        lda #5      // verde
        sta $D020   // bordo
    LOOP:

        jmp LOOP    // programma resta in esecuzione

}

// --- ESERCIZIO 3: label GAMELOOP invece di LOOP ---
.segment Ex3
.namespace Ex3 {
    // *=$C000
        lda #5
        sta $D020
    GAMELOOP:

        jmp GAMELOOP

}

// --- ESERCIZIO 4: bordo nero, sfondo bianco ---
.segment Ex4
.namespace Ex4 {
    // *=$C000
        lda #0      // nero
        sta $D020   // bordo
        lda #1      // bianco
        sta $D021   // sfondo
        rts

}

// --- ESERCIZIO 5: bordo blu chiaro, ciclo infinito FINISH ---
.segment Ex5
.namespace Ex5 {
    // *=$C000
        lda #14     // blu chiaro
        sta $D020   // bordo
    FINISH:

        jmp FINISH
}
