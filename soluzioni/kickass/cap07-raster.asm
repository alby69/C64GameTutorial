// Converted to Kick Assembler syntax
.segmentdef Ex1 [start=$c000]
.segmentdef Ex2 [start=$c000]
.segmentdef Ex3 [start=$c000]
.segmentdef Ex4 [start=$c000]
.segmentdef Ex5 [start=$c000]

// --- Shared Constants ---

// =============================================
// SOLUZIONI Capitolo 7 — Raster Interrupt
// --- METADATA ---
// chapter: 7
// title: Raster Interrupt
// difficulty: intermediate
// --- END METADATA ---
// =============================================
//
// Mappa esercizi:
//   1: raster IRQ riga 50, bordo rosso
//   2: due IRQ — riga 50 (rosso), riga 150 (blu)
//   3: raster bar 4 righe consecutive
//   4: flash sfondo blu/nero ogni frame via raster
//   5: carattere lampeggiante via raster
//
// =============================================
// --- ESERCIZIO 1: raster IRQ riga 50, bordo rosso ---
.segment Ex1
.namespace Ex1 {
    // *=$C000
        sei
        lda #$7F
        sta $DC0D

        lda #<IRQ1
        sta $0314
        lda #>IRQ1
        sta $0315

        lda #50
        sta $D012
        lda $D011
        and #$7F
        sta $D011
        lda #1
        sta $D01A
        cli
        jmp MAIN

    MAIN:

        jmp MAIN

    IRQ1:

        lda #2
        sta $D020
        lda $D019
        sta $D019
        jmp $EA31

}

// --- ESERCIZIO 2: due IRQ — riga 50 (rosso), riga 150 (blu) ---
.segment Ex2
.namespace Ex2 {
    // *=$9000
        sei
        lda #$7F
        sta $DC0D

        lda #<IRQ_A
        sta $0314
        lda #>IRQ_A
        sta $0315

        lda #50
        sta $D012
        lda $D011
        and #$7F
        sta $D011
        lda #1
        sta $D01A
        cli
        jmp MAIN2

    MAIN2:

        jmp MAIN2

    IRQ_A:

        lda #2         // rosso
        sta $D020

        lda #150
        sta $D012
        lda #<IRQ_B
        sta $0314
        lda #>IRQ_B
        sta $0315

        lda $D019
        sta $D019
        jmp $EA31

    IRQ_B:

        lda #6         // blu
        sta $D020

        lda #50
        sta $D012
        lda #<IRQ_A
        sta $0314
        lda #>IRQ_A
        sta $0315

        lda $D019
        sta $D019
        jmp $EA31

}

// --- ESERCIZIO 3: raster bar 4 righe consecutive ---
.segment Ex3
.namespace Ex3 {
    // *=$A000
        sei
        lda #$7F
        sta $DC0D

        lda #<IRQ_1
        sta $0314
        lda #>IRQ_1
        sta $0315

        lda #50
        sta $D012
        lda $D011
        and #$7F
        sta $D011
        lda #1
        sta $D01A
        cli
        jmp MAIN3

    MAIN3:

        jmp MAIN3

    IRQ_1:

        lda #2
        sta $D020
        lda #51
        sta $D012
        lda #<IRQ_2
        sta $0314
        lda #>IRQ_2
        sta $0315
        lda $D019
        sta $D019
        jmp $EA31

    IRQ_2:

        lda #7
        sta $D020
        lda #52
        sta $D012
        lda #<IRQ_3
        sta $0314
        lda #>IRQ_3
        sta $0315
        lda $D019
        sta $D019
        jmp $EA31

    IRQ_3:

        lda #5
        sta $D020
        lda #53
        sta $D012
        lda #<IRQ_4
        sta $0314
        lda #>IRQ_4
        sta $0315
        lda $D019
        sta $D019
        jmp $EA31

    IRQ_4:

        lda #4
        sta $D020
        lda #50
        sta $D012
        lda #<IRQ_1
        sta $0314
        lda #>IRQ_1
        sta $0315
        lda $D019
        sta $D019
        jmp $EA31

}

// --- ESERCIZIO 4: flash sfondo blu/nero ogni frame via raster ---
.segment Ex4
.namespace Ex4 {
    // *=$B000
        sei
        lda #$7F
        sta $DC0D
        lda #<FLASH_IRQ
        sta $0314
        lda #>FLASH_IRQ
        sta $0315
        lda #200
        sta $D012
        lda $D011
        and #$7F
        sta $D011
        lda #1
        sta $D01A
        cli
        jmp MAIN4

    MAIN4:

        jmp MAIN4

    FLASH_IRQ:

        lda $D021
        eor #6         // alterna blu/nero
        sta $D021
        lda $D019
        sta $D019
        jmp $EA31

}

// --- ESERCIZIO 5: carattere lampeggiante via raster ---
.segment Ex5
.namespace Ex5 {
    // *=$C000
        sei
        lda #$7F
        sta $DC0D
        lda #<CHAR_IRQ
        sta $0314
        lda #>CHAR_IRQ
        sta $0315
        lda #100
        sta $D012
        lda $D011
        and #$7F
        sta $D011
        lda #1
        sta $D01A
        cli

        lda #1         // 'A' in prima posizione
        sta $0400
        jmp MAIN5

    MAIN5:

        jmp MAIN5

    CHAR_IRQ:

        lda $D800
        eor #$0F       // alterna colore del carattere
        sta $D800
        lda $D019
        sta $D019
        jmp $EA31
}
