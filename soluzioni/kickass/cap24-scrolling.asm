// Converted to Kick Assembler syntax
.segmentdef Ex1 [start=$c000]
.segmentdef Ex2 [start=$c000]
.segmentdef Ex3 [start=$c000]
.segmentdef Ex4 [start=$c000]
.segmentdef Ex5 [start=$c000]

// --- Shared Constants ---

// =============================================
// SOLUZIONI Capitolo 24 — Scrolling su C64
// --- METADATA ---
// chapter: 24
// title: Scrolling
// difficulty: advanced
// --- END METADATA ---
// =============================================
//
// Mappa esercizi:
//   1: scroll fine orizzontale con $D016
//   2: scroll fine + grossolano
//   3: raster split con HUD fisso + area scrollabile
//   4: scrolling verticale continuo
//   5: parallax a 2 layer con raster split
//
// =============================================

// --- ESERCIZIO 1: scroll fine orizzontale ($D016) ---
.segment Ex1
.namespace Ex1 {
    // *= $C000
        lda #1
        sta $D021
        lda #$0B
        sta $D020

        // Scrivi una riga di caratteri
        ldx #0
    FILL1:

        lda #$41
        sta $0400+40*12,X
        inx
        cpx #40
        bne FILL1

    SCROLL1:

        lda SCROLL_X1
        sta $D016

        inc SCROLL_X1
        lda SCROLL_X1
        and #7
        sta SCROLL_X1

        ldx #0
    DELAY1:

        nop
        nop
        inx
        bne DELAY1

        jmp SCROLL1

    SCROLL_X1:

        .byte 0

}

// --- ESERCIZIO 2: scroll fine + grossolano ---
.segment Ex2
.namespace Ex2 {
    // *= $C000
        lda #1
        sta $D021
        lda #$0B
        sta $D020

        // Scrivi riga di caratteri vari
        ldx #0
    FILL2:

        txa
        clc
        adc #$41
        sta $0400+40*12,X
        inx
        cpx #80
        bne FILL2

        // Scorri da 0 a 7 e poi shift
    SCROLL2:

        // Fine scroll
        lda SCROLL_F2
        sta $D016

        inc SCROLL_F2
        lda SCROLL_F2
        and #7
        sta SCROLL_F2
        bne NO_COARSE

        // Coarse scroll — shift screen RAM a sinistra
        ldx #1
    CS_LOOP:

        lda $0400+40*12,X
        sta $0400+40*12-1,X
        inx
        cpx #40
        bne CS_LOOP

        // Inserisci nuovo carattere a destra
        lda COARSE_X2
        clc
        adc #$41
        sta $0400+40*12+39
        inc COARSE_X2

    NO_COARSE:

        ldx #0
    DELAY2:

        nop
        nop
        inx
        bne DELAY2
        jmp SCROLL2

    SCROLL_F2:

        .byte 0
    COARSE_X2:

        .byte 0

}

// --- ESERCIZIO 3: raster split con HUD fisso ---
.segment Ex3
.namespace Ex3 {
    // *= $C000
        sei
        lda #<IRQ3
        sta $0314
        lda #>IRQ3
        sta $0315
        lda #40
        sta $D012
        lda $D011
        and #$7F
        sta $D011
        lda #1
        sta $D01A
        cli

        // HUD fisso — 40 colonne
        lda #%11001000
        sta $D016

        // Scrivi HUD
        ldx #0
    HUD3:

        lda #$48            // "H"
        sta $0400,X
        inx
        cpx #40
        bne HUD3

        // Scrivi area scrollabile
        ldx #0
    SC3_FILL:

        lda #$41
        sta $0400+40*5,X
        inx
        cpx #40
        bne SC3_FILL

    MAIN3:

        inc SCROLL3
        lda SCROLL3
        and #7
        sta SCROLL3
        jmp MAIN3

    IRQ3:

        lda SCROLL3
        ora #%11001000
        sta $D016

        lda $D019
        sta $D019
        jmp $EA31

    SCROLL3:

        .byte 0

}

// --- ESERCIZIO 4: scrolling verticale continuo ---
.segment Ex4
.namespace Ex4 {
    // *= $C000
        lda #1
        sta $D021
        lda #$0B
        sta $D020

        // Riempi colonna centrale
        ldx #0
    FILL4:

        lda #$41
        sta $0400+40*0+19,X
        inx
        cpx #25
        bne FILL4

        // Riempi altra colonna offset
        ldx #0
    FILL4B:

        lda #$42
        sta $0400+40*0+20,X
        inx
        cpx #25
        bne FILL4B

    SCROLL4:

        // Fine scroll verticale
        lda #$1B
        ora SCROLL_Y4
        sta $D011

        inc SCROLL_Y4
        lda SCROLL_Y4
        and #7
        sta SCROLL_Y4
        bne NO_CV

        // Coarse vertical — shift su
        ldx #240
    CV_LOOP:

        lda $0400+40,X
        sta $0400,X
        lda $0400+40+240,X
        sta $0400+240,X
        lda $0400+40+480,X
        sta $0400+480,X
        lda $0400+40+720,X
        sta $0400+720,X
        dex
        bne CV_LOOP

        // Nuova ultima riga
        ldx #0
    CV_NEW:

        lda #$20
        sta $0400+40*24,X
        inx
        cpx #40
        bne CV_NEW

    NO_CV:

        ldx #0
    DELAY4:

        nop
        inx
        bne DELAY4
        jmp SCROLL4

    SCROLL_Y4:

        .byte 0

}

// --- ESERCIZIO 5: parallax a 2 layer ---
.segment Ex5
.namespace Ex5 {
    // Cielo (scroll lento) + Terreno (scroll veloce)
    // *= $C000
        sei
        lda #<IRQ5_SKY
        sta $0314
        lda #>IRQ5_SKY
        sta $0315
        lda #0
        sta $D012
        lda #1
        sta $D01A
        cli

        // Scrivi cieli (righe 0-15) e terreno (righe 16-24)
        // Cieli (righe 0-15) — 640 bytes (512 + 128)
        ldx #0
    SKY_FILL1:

        lda #$53            // "S"
        sta $0400,X
        sta $0500,X
        lda #1
        sta $D800,X
        sta $D900,X
        inx
        bne SKY_FILL1

        ldx #128
    SKY_FILL2:

        lda #$53            // "S"
        sta $0600-1,X
        lda #1
        sta $DA00-1,X
        dex
        bne SKY_FILL2

        // Terreno (righe 16-24) — 360 bytes (128 + 232)
        ldx #128
    GROUND_LOOP1:

        lda #$47            // "G"
        sta $0680-1,X
        lda #5
        sta $DA80-1,X
        dex
        bne GROUND_LOOP1

        ldx #232
    GROUND_LOOP2:

        lda #$47            // "G"
        sta $0700-1,X
        lda #5
        sta $DB00-1,X
        dex
        bne GROUND_LOOP2

    MAIN5:

        inc SKY_SCROLL5
        lda SKY_SCROLL5
        and #7
        sta SKY_SCROLL5

        inc GROUND_SCROLL5
        inc GROUND_SCROLL5
        lda GROUND_SCROLL5
        and #7
        sta GROUND_SCROLL5
        jmp MAIN5

    IRQ5_SKY:

        lda SKY_SCROLL5
        ora #%11001000
        sta $D016

        lda #<IRQ5_GROUND
        sta $0314
        lda #>IRQ5_GROUND
        sta $0315
        lda #16*8
        sta $D012

        lda $D019
        sta $D019
        jmp $EA31

    IRQ5_GROUND:

        lda GROUND_SCROLL5
        ora #%11001000
        sta $D016

        lda #<IRQ5_SKY
        sta $0314
        lda #>IRQ5_SKY
        sta $0315
        lda #0
        sta $D012

        lda $D019
        sta $D019
        jmp $EA31

    SKY_SCROLL5:

        .byte 0
    GROUND_SCROLL5:

        .byte 0
}
