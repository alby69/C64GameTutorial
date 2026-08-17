// Converted to Kick Assembler syntax
.segmentdef Ex1 [start=$c000]
.segmentdef Ex2 [start=$c000]
.segmentdef Ex3 [start=$c000]
.segmentdef Ex4 [start=$c000]
.segmentdef Ex5 [start=$c000]

// --- Shared Constants ---

// =============================================
// SOLUZIONI Capitolo 5 — Sprite Hardware
// --- METADATA ---
// chapter: 5
// title: Sprite VIC-II
// difficulty: intermediate
// --- END METADATA ---
// =============================================
//
// Mappa esercizi:
//   1: astronave al centro (X=160, Y=100)
//   2: due sprite, bianco sinistra, rosso destra
//   3: alieno disegnato su carta poi convertito
//   4: sprite 0 a $3100 (calcolo pointer)
//   5: sprite con colore che cambia ogni frame
//
// =============================================

// --- ESERCIZIO 1: astronave al centro (X=160, Y=100) ---
.segment Ex1
.namespace Ex1 {
    // *=$C000
        // Abilita sprite 0
        lda #%00000001
        sta $D015

        // Colore bianco
        lda #1
        sta $D027

        // Posizione centrata
        lda #160
        sta $D000        // X
        lda #100
        sta $D001        // Y

        // Sprite pointer a $2000 (pointer = $2000/64 = $80 = 128)
        lda #128
        sta $07F8
        rts

    // Dati sprite a $2000 (astronave 24x21)
    // *=$2000
        .byte %00000000, %00011000, %00000000
        .byte %00000000, %00111100, %00000000
        .byte %00000000, %00111100, %00000000
        .byte %00000000, %01111110, %00000000
        .byte %00000000, %11111111, %00000000
        .byte %00000001, %11111111, %10000000
        .byte %00000011, %11111111, %11000000
        .byte %00000111, %11111111, %11100000
        .byte %00001111, %11111111, %11110000
        .byte %00011111, %11111111, %11111000
        .byte %00111111, %11111111, %11111100
        .byte %00011111, %11111111, %11111000
        .byte %00001111, %11111111, %11110000
        .byte %00000111, %11111111, %11100000
        .byte %00000011, %11111111, %11000000
        .byte %00000001, %11111111, %10000000
        .byte %00000000, %11111111, %00000000
        .byte %00000000, %01111110, %00000000
        .byte %00000000, %01011010, %00000000
        .byte %00000000, %00111100, %00000000
        .byte %00000000, %00011000, %00000000

}

// --- ESERCIZIO 2: due sprite, bianco sinistra, rosso destra ---
.segment Ex2
.namespace Ex2 {
    // *=$9000
        // Abilita sprite 0 e 1
        lda #%00000011
        sta $D015

        // Colori
        lda #1         // bianco
        sta $D027      // sprite 0
        lda #2         // rosso
        sta $D028      // sprite 1

        // Posizioni
        lda #50
        sta $D000      // sprite 0 X
        lda #100
        sta $D001      // sprite 0 Y
        lda #250
        sta $D002      // sprite 1 X
        lda #100
        sta $D003      // sprite 1 Y

        // Pointer (stessa astronave per entrambi)
        lda #128
        sta $07F8
        sta $07F9
        rts

}

// --- ESERCIZIO 3: alieno disegnato su carta poi convertito ---
.segment Ex3
.namespace Ex3 {
    // Esempio alieno 24x21 (semplice)
    // *=$A000
        .byte %00000000, %00111100, %00000000
        .byte %00000000, %01111110, %00000000
        .byte %00000001, %11111111, %10000000
        .byte %00000001, %11111111, %10000000
        .byte %00000011, %11111111, %11000000
        .byte %00000111, %10011001, %11100000
        .byte %00000111, %11111111, %11100000
        .byte %00001111, %11111111, %11110000
        .byte %00001111, %11111111, %11110000
        .byte %00011111, %01111110, %11111000
        .byte %00011111, %10111101, %11111000
        .byte %00111111, %11111111, %11111100
        .byte %00111111, %11111111, %11111100
        .byte %00111100, %00000000, %00111100
        .byte %00111100, %00000000, %00111100
        .byte %00011000, %00000000, %00011000
        .byte %00011000, %01000010, %00011000
        .byte %00000000, %01100110, %00000000
        .byte %00000000, %00111100, %00000000
        .byte %00000000, %00011000, %00000000
        .byte %00000000, %00011000, %00000000

}

// --- ESERCIZIO 4: sprite 0 a $3100 pointer ---
.segment Ex4
.namespace Ex4 {
    // pointer = $3100 / 64 = $3100 / $40 = $C4 = 196
    // *=$C000
        lda #%00000001
        sta $D015
        lda #196       // $C4
        sta $07F8      // punta a $3100
        lda #1
        sta $D027
        lda #160
        sta $D000
        lda #100
        sta $D001
        rts

}

// --- ESERCIZIO 5: sprite con colore che cambia ogni frame ---
.segment Ex5
.namespace Ex5 {
    // *=$C000
        lda #%00000001
        sta $D015
        lda #128
        sta $07F8
        lda #160
        sta $D000
        lda #100
        sta $D001
        lda #0
    LOOP5:

        sta $D027
        inc $D027
        lda $D027
        cmp #16
        bne LOOP5
        jmp LOOP5
}
