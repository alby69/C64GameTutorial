// Converted to Kick Assembler syntax
.segmentdef Ex1 [start=$c000]
.segmentdef Ex2 [start=$c000]
.segmentdef Ex3 [start=$c000]
.segmentdef Ex4 [start=$c000]
.segmentdef Ex5 [start=$c000]

// --- Shared Constants ---
.const SPRITE_X = $D000
.const SPRITE_Y = $D001
.const SPR_COL = $D027
.const FRAME = $02
.const COUNT = $03

// =============================================
// SOLUZIONI Capitolo 6 — Movimento Sprite
// --- METADATA ---
// chapter: 6
// title: Movimento Sprite
// difficulty: intermediate
// --- END METADATA ---
// =============================================
//
// Mappa esercizi:
//   1: sprite sinistra→destra, rimbalzo X=50↔250
//   2: movimento diagonale
//   3: cambio colore a ogni rimbalzo
//   4: animazione 4 frame alieno ogni 8 iterazioni
//   5: 3 sprite allineati in formazione
//
// =============================================
// --- ESERCIZIO 1: sprite sinistra→destra, rimbalzo X=50↔250 ---
.segment Ex1
.namespace Ex1 {
    // *=$C000
        lda #%00000001
        sta $D015
        lda #1
        sta $D027
        lda #128
        sta $07F8
        lda #50
        sta SPRITE_X
        lda #100
        sta SPRITE_Y

    LOOP:

        inc SPRITE_X
        lda SPRITE_X
        cmp #250
        bcc LOOP
        lda #50
        sta SPRITE_X
        jmp LOOP

}

// --- ESERCIZIO 2: movimento diagonale ---
.segment Ex2
.namespace Ex2 {
    // *=$9000
        lda #%00000001
        sta $D015
        lda #1
        sta $D027
        lda #128
        sta $07F8
        lda #50
        sta $D000
        lda #50
        sta $D001

    LOOP2:

        inc $D000
        inc $D001
        lda $D000
        cmp #250
        bcc LOOP2
        lda #50
        sta $D000
        lda #50
        sta $D001
        jmp LOOP2

}

// --- ESERCIZIO 3: cambio colore a ogni rimbalzo ---
.segment Ex3
.namespace Ex3 {
    // *=$A000
        lda #%00000001
        sta $D015
        lda #128
        sta $07F8
        lda #50
        sta $D000
        lda #100
        sta $D001
        lda #1
        sta SPR_COL

    LOOP3:

        inc $D000
        lda $D000
        cmp #250
        bne LOOP3
        inc SPR_COL
        lda SPR_COL
        and #$0F
        sta SPR_COL
        lda #50
        sta $D000
        jmp LOOP3

}

// --- ESERCIZIO 4: animazione 4 frame alieno ogni 8 iterazioni ---
.segment Ex4
.namespace Ex4 {
    // *=$B000
        lda #%00000001
        sta $D015
        lda #7
        sta $D027
        lda #192
        sta $07F8
        lda #160
        sta $D000
        lda #100
        sta $D001
        lda #0
        sta FRAME
        sta COUNT

    LOOP4:

        inc COUNT
        lda COUNT
        and #7
        bne NO_ANIM

        inc FRAME
        lda FRAME
        and #3
        clc
        adc #192
        sta $07F8

    NO_ANIM:

        jmp LOOP4

    // Dati animazione a $C000-$C0FF
    // *=$C000
        // frame 0 (ali su)
        .byte %00000000, %00111100, %00000000
        .byte %00000001, %11111111, %10000000
        .byte %00000011, %11111111, %11000000
        .byte %00000111, %10011001, %11100000
        .byte %00001111, %11111111, %11110000
        .byte %00011111, %11111111, %11111000
        .byte %00111111, %11111111, %11111100
        .byte %00011111, %11111111, %11111000
        .byte %00001111, %11111111, %11110000
        .byte %00000111, %11111111, %11100000
        .byte %00000011, %11111111, %11000000
        .byte %00000001, %11111111, %10000000
        .byte %00000000, %01111110, %00000000
        .byte %00000000, %00111100, %00000000
        .byte %00000000, %00011000, %00000000
        .byte %00000000, %00011000, %00000000
        .byte %00000000, %00011000, %00000000
        .byte %00000000, %00011000, %00000000
        .byte %00000000, %00011000, %00000000
        .byte %00000000, %00011000, %00000000
        .byte %00000000, %00011000, %00000000
        // frame 1-3: versioni modificate (stessa struttura)
    // *=$C100
        .byte %00000000, %00111100, %00000000
        .byte %00000001, %11111111, %10000000
        .byte %00000011, %11111111, %11000000
        .byte %00000111, %10011001, %11100000
        .byte %00001111, %11111111, %11110000
        .byte %00011111, %11111111, %11111000
        .byte %00111111, %11111111, %11111100
        .byte %00011111, %11111111, %11111000
        .byte %00001111, %11111111, %11110000
        .byte %00000111, %11111111, %11100000
        .byte %00000011, %11111111, %11000000
        .byte %00000001, %11111111, %10000000
        .byte %00000000, %01111110, %00000000
        .byte %00000000, %10111101, %00000000
        .byte %00000001, %10011001, %10000000
        .byte %00000000, %10011001, %00000000
        .byte %00000000, %01011010, %00000000
        .byte %00000000, %00111100, %00000000
        .byte %00000000, %00011000, %00000000
        .byte %00000000, %00011000, %00000000
        .byte %00000000, %00011000, %00000000

}

// --- ESERCIZIO 5: 3 sprite allineati in formazione ---
.segment Ex5
.namespace Ex5 {
    // *=$D000
        lda #%00000111
        sta $D015
        lda #1
        sta $D027
        sta $D028
        sta $D029
        lda #128
        sta $07F8
        sta $07F9
        sta $07FA

        lda #60
        sta $D001     // Y sprite 0
        sta $D003     // Y sprite 1
        sta $D005     // Y sprite 2

        lda #60
        sta $D000
        lda #120
        sta $D002
        lda #180
        sta $D004

    LOOP5:

        inc $D001
        inc $D003
        inc $D005
        jmp LOOP5
}
