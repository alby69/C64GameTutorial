// Converted to Kick Assembler syntax
.segmentdef Ex1 [start=$c000]
.segmentdef Ex2 [start=$c000]
.segmentdef Ex3 [start=$c000]
.segmentdef Ex4 [start=$c000]
.segmentdef Ex5 [start=$c000]

// --- Shared Constants ---
.const FRAME_CNT = $02
.const FRAME = $02
.const FRAME2 = $02
.const FRAME3 = $02

// =============================================
// SOLUZIONI Capitolo 8 — Game Loop Sincronizzato
// --- METADATA ---
// chapter: 8
// title: Game Loop
// difficulty: intermediate
// --- END METADATA ---
// =============================================
//
// Mappa esercizi:
//   1: frame counter sul bordo
//   2: sprite 1 pixel a destra ogni frame = 50 px/s
//   3: alterna pointer 192/193 ogni 4 frame
//   4: messaggio lampeggia ogni 25 frame
//   5: programma integrato in raster IRQ 50 Hz
//
// =============================================
// --- ESERCIZIO 1: frame counter sul bordo ---
.segment Ex1
.namespace Ex1 {
    // *=$C000
        lda #0
        sta FRAME_CNT
    LOOP1:

        inc FRAME_CNT
        lda FRAME_CNT
        sta $D020      // valore esadecimale sul bordo
        jsr WAIT
        jmp LOOP1

    WAIT:

        lda $D012
        cmp #$F8
        bne WAIT
        rts

}

// --- ESERCIZIO 2: sprite 1 pixel a destra ogni frame = 50 px/s ---
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
        lda #100
        sta $D001

    LOOP2:

        jsr WAIT2
        inc $D000
        jmp LOOP2

    WAIT2:

        lda $D012
        cmp #$F8
        bne WAIT2
        rts

}

// --- ESERCIZIO 3: alterna pointer 192/193 ogni 4 frame ---
.segment Ex3
.namespace Ex3 {
    // *=$A000
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

    LOOP3:

        jsr WAIT3
        inc FRAME
        lda FRAME
        and #4
        beq FRAME0
        lda #193
        jmp SETP

    FRAME0:

        lda #192
    SETP:

        sta $07F8
        jmp LOOP3

    WAIT3:

        lda $D012
        cmp #$F8
        bne WAIT3
        rts

}

// --- ESERCIZIO 4: messaggio lampeggia ogni 25 frame ---
.segment Ex4
.namespace Ex4 {
    // *=$B000
        lda #1         // 'A' a schermo
        sta $0400
        lda #1         // colore bianco
        sta $D800
        lda #0
        sta FRAME2

    LOOP4:

        jsr WAIT4
        inc FRAME2
        lda FRAME2
        cmp #25
        bne LOOP4

        lda $D800
        eor #$0F       // cambia colore
        sta $D800
        lda #0
        sta FRAME2
        jmp LOOP4

    WAIT4:

        lda $D012
        cmp #$F8
        bne WAIT4
        rts

}

// --- ESERCIZIO 5: programma integrato in raster IRQ 50 Hz ---
.segment Ex5
.namespace Ex5 {
    // *=$C000
        sei
        lda #$7F
        sta $DC0D
        lda #<GAME_IRQ
        sta $0314
        lda #>GAME_IRQ
        sta $0315
        lda #200
        sta $D012
        lda $D011
        and #$7F
        sta $D011
        lda #1
        sta $D01A
        cli

        lda #%00000001
        sta $D015
        lda #1
        sta $D027
        lda #128
        sta $07F8
        lda #50
        sta $D000
        lda #100
        sta $D001
        lda #0
        sta FRAME3

    MAIN:

        jmp MAIN

    GAME_IRQ:

        pha
        txa
        pha
        tya
        pha

        inc FRAME3
        inc $D000       // 1 px/frame

        pla
        tay
        pla
        tax
        pla

        lda $D019
        sta $D019
        jmp $EA31
}
