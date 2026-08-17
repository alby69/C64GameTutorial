// Converted to Kick Assembler syntax
.segmentdef Ex1 [start=$c000]
.segmentdef Ex2 [start=$c000]
.segmentdef Ex3 [start=$c000]
.segmentdef Ex4 [start=$c000]
.segmentdef Ex5 [start=$c000]

// --- Shared Constants ---
.const SPR_X = $D000
.const SPR_Y = $D001
.const JOYPORT = $DC00
.const SPR_COL = $D027
.const OLD_FIRE = $04
.const PORT1 = $DC01
.const PORT2 = $DC00
.const SPR0_X = $D000
.const SPR0_Y = $D001
.const SPR1_X = $D002
.const SPR1_Y = $D003

// =============================================
// SOLUZIONI Capitolo 9 — Joystick
// --- METADATA ---
// chapter: 9
// title: Joystick e Input
// difficulty: intermediate
// --- END METADATA ---
// =============================================
//
// Mappa esercizi:
//   1: muovi sprite in 4 direzioni
//   2: controllo bordi (player non esce)
//   3: fuoco cambia colore sprite
//   4: single shot (edge detection)
//   5: porta 1 e porta 2 per 2 sprite
//
// =============================================

// --- ESERCIZIO 1: muovi sprite in 4 direzioni ---
.segment Ex1
.namespace Ex1 {
    // *=$C000
        lda #%00000001
        sta $D015
        lda #1
        sta $D027
        lda #128
        sta $07F8

        lda #160
        sta SPR_X
        lda #100
        sta SPR_Y

    LOOP1:

        lda JOYPORT
        sta $02         // salva stato

        and #1          // bit 0 = su
        bne CHECK_DOWN
        dec SPR_Y

    CHECK_DOWN:

        lda $02
        and #2          // bit 1 = giu
        bne CHECK_LEFT
        inc SPR_Y

    CHECK_LEFT:

        lda $02
        and #4          // bit 2 = sinistra
        bne CHECK_RIGHT
        dec SPR_X

    CHECK_RIGHT:

        lda $02
        and #8          // bit 3 = destra
        bne DONE1
        inc SPR_X

    DONE1:

        jsr WAIT
        jmp LOOP1

    WAIT:

        lda $D012
        cmp #$F8
        bne WAIT
        rts

}

// --- ESERCIZIO 2: controllo bordi (player non esce) ---
.segment Ex2
.namespace Ex2 {
    // *=$9000
        lda #%00000001
        sta $D015
        lda #1
        sta $D027
        lda #128
        sta $07F8
        lda #160
        sta SPR_X
        lda #100
        sta SPR_Y

    LOOP2:

        lda JOYPORT
        sta $02

        and #1
        bne CD2
        lda SPR_Y
        cmp #50
        bcc CD2
        dec SPR_Y

    CD2:

        lda $02
        and #2
        bne CL2
        lda SPR_Y
        cmp #200
        bcs CL2
        inc SPR_Y

    CL2:

        lda $02
        and #4
        bne CR2
        lda SPR_X
        cmp #24
        bcc CR2
        dec SPR_X

    CR2:

        lda $02
        and #8
        bne DONE2
        lda SPR_X
        cmp #250
        bcs DONE2
        inc SPR_X

    DONE2:

        jsr WAIT2
        jmp LOOP2

    WAIT2:

        lda $D012
        cmp #$F8
        bne WAIT2
        rts

}

// --- ESERCIZIO 3: fuoco cambia colore sprite ---
.segment Ex3
.namespace Ex3 {
    // *=$A000
        lda #%00000001
        sta $D015
        lda #1
        sta SPR_COL
        lda #128
        sta $07F8
        lda #160
        sta SPR_X
        lda #100
        sta SPR_Y

    LOOP3:

        lda JOYPORT
        and #16         // bit 4 = fuoco
        bne NO_FIRE

        inc SPR_COL
        lda SPR_COL
        and #$0F
        sta SPR_COL

    NO_FIRE:

        jsr WAIT3
        jmp LOOP3

    WAIT3:

        lda $D012
        cmp #$F8
        bne WAIT3
        rts

}

// --- ESERCIZIO 4: single shot (edge detection) ---
.segment Ex4
.namespace Ex4 {
    // *=$B000
        lda #%00000001
        sta $D015
        lda #1
        sta $D027
        lda #128
        sta $07F8
        lda #1
        sta OLD_FIRE      // vecchio stato = non premuto

    LOOP4:

        lda JOYPORT
        and #16
        sta $03           // stato attuale

        cmp OLD_FIRE
        beq SAME

        // Cambiamento di stato
        lda $03
        bne RELEASED      // 1 = rilasciato

        // Premuto ora
        inc $D020

    RELEASED:

        lda $03
        sta OLD_FIRE

    SAME:

        jsr WAIT4
        jmp LOOP4

    WAIT4:

        lda $D012
        cmp #$F8
        bne WAIT4
        rts

}

// --- ESERCIZIO 5: porta 1 e porta 2 per 2 sprite ---
.segment Ex5
.namespace Ex5 {
    // *=$C000
        lda #%00000011
        sta $D015
        lda #1
        sta $D027       // sprite 0 bianco
        lda #2
        sta $D028       // sprite 1 rosso
        lda #128
        sta $07F8
        sta $07F9
        lda #100
        sta SPR0_X
        sta SPR1_X
        lda #100
        sta SPR0_Y
        sta SPR1_Y

    LOOP5:

        // Sprite 0 ← porta 1
        lda PORT1
        sta $02
        and #1
        bne P1_DOWN
        dec SPR0_Y
    P1_DOWN:

        lda $02
        and #2
        bne P1_LEFT
        inc SPR0_Y
    P1_LEFT:

        lda $02
        and #4
        bne P1_RIGHT
        dec SPR0_X
    P1_RIGHT:

        lda $02
        and #8
        bne P1_DONE
        inc SPR0_X
    P1_DONE:


        // Sprite 1 ← porta 2
        lda PORT2
        sta $03
        and #1
        bne P2_DOWN
        dec SPR1_Y
    P2_DOWN:

        lda $03
        and #2
        bne P2_LEFT
        inc SPR1_Y
    P2_LEFT:

        lda $03
        and #4
        bne P2_RIGHT
        dec SPR1_X
    P2_RIGHT:

        lda $03
        and #8
        bne P5_DONE
        inc SPR1_X

    P5_DONE:

        jsr WAIT5
        jmp LOOP5

    WAIT5:

        lda $D012
        cmp #$F8
        bne WAIT5
        rts
}
