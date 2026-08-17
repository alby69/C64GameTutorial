// Converted to Kick Assembler syntax
.segmentdef Ex1 [start=$c000]
.segmentdef Ex2 [start=$c000]
.segmentdef Ex3 [start=$c000]
.segmentdef Ex4 [start=$c000]
.segmentdef Ex5 [start=$c000]

// --- Shared Constants ---
.const BORDER = $D020
.const BG = $D021
.const SCREEN = $0400
.const COLOR = $D800

// =============================================
// SOLUZIONI Capitolo 4 — Memoria Video
// --- METADATA ---
// chapter: 4
// title: Memoria Video
// difficulty: beginner
// --- END METADATA ---
// =============================================
//
// Mappa esercizi:
//   1: nome centrato riga 10
//   2: effetto matrix (caratteri cadono)
//   3: schermata titolo
//   4: numero 42 in alto a destra
//   5: scrolling marquee (testo scorrevole)
//
// =============================================

// --- ESERCIZIO 1: nome centrato riga 10 ---
.segment Ex1
.namespace Ex1 {
    // Riga 10 = inizio a $0400 + 10*40 = $0400 + 400 = $0590
    // "MARCO" = 5 lettere, colonna = (40-5)/2 = 17.5 → 17
    // *=$C000
        lda #13        // 'M'
        sta $05A1      // $0590 + 17
        lda #1         // 'A'
        sta $05A2
        lda #18        // 'R'
        sta $05A3
        lda #3         // 'C'
        sta $05A4
        lda #15        // 'O'
        sta $05A5
        rts

}

// --- ESERCIZIO 2: effetto matrix (caratteri cadono) ---
.segment Ex2
.namespace Ex2 {
    // *=$C000
        ldx #0
    LOOPM:

        lda #81        // carattere casuale '@'
        sta $0400,X
        txa
        and #$0F
        sta $D800,X
        inx
        cpx #40
        bne LOOPM      // prima riga riempita

        ldx #0
    FALL:

        jsr SHIFT_DOWN
        inx
        cpx #24
        bne FALL
        jmp $8000      // restart

    SHIFT_DOWN:

        ldx #240
    LOOP_S:

        lda $0400+720-1,X
        sta $0400+760-1,X
        lda $0400+480-1,X
        sta $0400+520-1,X
        lda $0400+240-1,X
        sta $0400+280-1,X
        lda $0400-1,X
        sta $0400+40-1,X
        dex
        bne LOOP_S
        rts

}

// --- ESERCIZIO 3: schermata titolo ---
.segment Ex3
.namespace Ex3 {

    // *=$C000
        // Bordo decorato
        lda #0
        sta BORDER
        sta BG

        // Testo centrato "GIOCO ARCADE"
        // Riga 10, colonna 12 (5+12=17 lettere)
        ldx #0
    TITLE:

        lda MSG,X
        sta $0590+12,X
        lda #1         // colore bianco
        sta $D990+12,X
        inx
        cpx #13        // lunghezza messaggio
        bne TITLE
        rts

    MSG: .byte 7,9,15,3,15,0,1,18,3,1,4,5,0    // "GIOCO ARCADE" in PETSCII

}

// --- ESERCIZIO 4: numero 42 in alto a destra ---
.segment Ex4
.namespace Ex4 {
    // Colonna 37-38 (40-3 = 37 per 2 cifre)
    // *=$C000
        lda #52        // '4' = PETSCII 52
        sta $0425      // $0400 + 37
        lda #50        // '2' = PETSCII 50
        sta $0426      // $0400 + 38
        rts

}

// --- ESERCIZIO 5: scrolling marquee (testo scorrevole) ---
.segment Ex5
.namespace Ex5 {
    // Scrive "CIAO" che si sposta a destra ogni frame
    // *=$C000
        ldx #0
    LOOP5:

        lda MSG5,X
        sta $0400,X
        inx
        cpx #4
        bne LOOP5
        rts
    MSG5: .byte 3,9,1,15    // "CIAO" in PETSCII
}
