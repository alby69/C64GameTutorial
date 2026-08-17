// Converted to Kick Assembler syntax
.segmentdef Ex1 [start=$c000]
.segmentdef Ex2 [start=$c000]
.segmentdef Ex3 [start=$c000]
.segmentdef Ex4 [start=$c000]
.segmentdef Ex5 [start=$c000]

// --- Shared Constants ---

// =============================================
// SOLUZIONI Capitolo 22 — Debugging con VICE
// --- METADATA ---
// chapter: 22
// title: Debugging VICE
// difficulty: intermediate
// --- END METADATA ---
// =============================================
//
// Mappa esercizi:
//   1: breakpoint a $C000, ispezione con r/m/d
//   2: watchpoint su $D020 con loop INC $D020
//   3: raster IRQ senza $D01A — debug del bug
//   4: misura cicli CPU con raster timing
//   5: stack overflow con chiamate ricorsive
//
// =============================================

// --- ESERCIZIO 1: breakpoint + ispezione ---
.segment Ex1
.namespace Ex1 {
    // Carica in VICE, imposta "b $C000", poi "g".
    // Usa "r" per vedere i registri, "m $C000" per memoria,
    // "d $C000" per disassemblare.
    // *= $C000
        lda #$41
        sta $0400
        lda #$42
        sta $0401
        lda #$43
        sta $0402
        rts

}

// --- ESERCIZIO 2: watchpoint su $D020 ---
.segment Ex2
.namespace Ex2 {
    // *= $C000
    LOOP2:

        inc $D020
        ldx #0
    DELAY2:

        nop
        nop
        inx
        bne DELAY2
        jmp LOOP2

    // In VICE: "ws $D020" poi "g".
    // Il monitor si ferma a ogni modifica di $D020.

}

// --- ESERCIZIO 3: raster IRQ senza $D01A ---
.segment Ex3
.namespace Ex3 {
    // Codice dal capitolo 7, ma MANCA LDA #1 / STA $D01A
    // L'IRQ non parte mai perche VIC-II non genera interrupt.
    // *= $C000
        sei
        lda #$7F
        sta $DC0D
        lda #<IRQ3
        sta $0314
        lda #>IRQ3
        sta $0315
        lda #100
        sta $D012
        lda $D011
        and #$7F
        sta $D011
        // BUG: manca LDA #1 / STA $D01A
        cli

    LOOP3:

        jmp LOOP3

    IRQ3:

        inc $D020
        lda $D019
        sta $D019
        rti

    // In VICE: "b IRQ3" — non si fermera mai.
    // Aggiungi "LDA #1 : STA $D01A" dopo $D011 setup e riprova.

}

// --- ESERCIZIO 4: misura cicli CPU con raster ---
.segment Ex4
.namespace Ex4 {
    // *= $C000
        // Versione lenta: LDA/STA
        lda #2
        sta $D020           // bordo rosso — inizio misura

        ldx #99
    SLOW_LOOP:

        lda #$41
        sta $0400,X
        dex
        bpl SLOW_LOOP

        lda #0
        sta $D020           // bordo nero — fine misura

        // Versione veloce: LDX/STX
        lda #2
        sta $D020           // bordo rosso

        ldx #99
    FAST_LOOP:

        txa
        sta $0400,X         // X contiene gia il valore
        dex
        bpl FAST_LOOP

        lda #0
        sta $D020           // bordo nero

        rts

    // In VICE: la barra rossa a destra mostra i cicli consumati.
    // La versione LDX/STX ha barra piu stretta.

}

// --- ESERCIZIO 5: stack overflow ---
.segment Ex5
.namespace Ex5 {
    // *= $C000
        jsr RECURSE
        rts

    RECURSE:

        jsr RECURSE
        rts

    // In VICE: "b $0100" non basta. Meglio:
    //   m $0100 $01FF   — osserva lo stack riempirsi
    //   r               — SP scende sotto $80
    // Dopo pochi frame il programma crashera.
    // Sintomo: RTS salta a indirizzi casuali.
}
