// Converted to Kick Assembler syntax
.segmentdef Ex1 [start=$c000]
.segmentdef Ex2 [start=$c000]
.segmentdef Ex3 [start=$c000]
.segmentdef Ex4 [start=$c000]
.segmentdef Ex5 [start=$c000]

// --- Shared Constants ---
.const WAIT3 = Ex5.WAIT3
.const WAIT2 = Ex5.WAIT2
.const SHOW_MENU = Ex4.SHOW_MENU
.const SHOW_GAMEOVER = Ex4.SHOW_GAMEOVER
.const GAME_UPDATE = Ex5.GAME_UPDATE
.const INIT_PLAY = Ex5.INIT_PLAY
.const INVINCIBLE = $35
.const INV_TIMER = $36
.const SCORE = $02     // 2 byte
.const SCORE_HI = $03
.const JOYPORT = $DC01
.const OLD_FIRE = $04
.const SCORE_DISPLAY = $0400+(24*40+30)  // angolo in basso a destra
.const GAME_STATE = $10     // 0=MENU, 1=PLAY, 2=GAME OVER
.const PLAYER_LIVES = $11
.const WAVE_INDEX = $20
.const WAVE_DISPLAY_TIMER = $21

// =============================================
// SOLUZIONI Capitolo 13 — Punteggio e Stati
// --- METADATA ---
// chapter: 13
// title: Punteggio e Stati
// difficulty: intermediate
// --- END METADATA ---
// =============================================
//
// Mappa esercizi:
//   1: punteggio +10 a ogni pressione fuoco
//   2: converti e mostra punteggio 3 cifre
//   3: state machine MENU → PLAY → GAME OVER → MENU
//   4: 3 vite, game over a 0
//   5: mostra WAVE 1/2/... tra le wave
//
// =============================================

// --- ESERCIZIO 1: punteggio +10 a ogni pressione fuoco ---
.segment Ex1
.namespace Ex1 {

    // *=$C000
        lda #0
        sta SCORE
        sta SCORE_HI
        lda #1
        sta OLD_FIRE

    LOOP1:

        lda JOYPORT
        and #16
        sta $05

        cmp OLD_FIRE
        beq SAME1

        lda $05
        bne SAME1

        // Fuoco premuto (edge)
        lda SCORE
        clc
        adc #10
        sta SCORE
        lda SCORE_HI
        adc #0
        sta SCORE_HI

    SAME1:

        lda $05
        sta OLD_FIRE

        jsr WAIT
        jmp LOOP1

    WAIT:

        lda $D012
        cmp #$F8
        bne WAIT
        rts

}

// --- ESERCIZIO 2: converti e mostra punteggio 3 cifre ---
.segment Ex2
.namespace Ex2 {
    // *=$9000
        lda #0
        sta SCORE
        sta SCORE_HI

    LOOP2:

        jsr UPDATE_SCORE_DISPLAY
        jsr WAIT2
        jmp LOOP2

    UPDATE_SCORE_DISPLAY:

        // Converte SCORE in 3 cifre decimali
        ldx #0
        stx $06          // centinaia
        stx $07          // decine
        stx $08          // unita

        lda SCORE
        ldx #0

    USD_HUNDREDS:

        cmp #100
        bcc USD_TENS
        sec
        sbc #100
        inc $06
        jmp USD_HUNDREDS

    USD_TENS:

        cmp #10
        bcc USD_UNITS
        sec
        sbc #10
        inc $07
        jmp USD_TENS

    USD_UNITS:

        sta $08

        // Mostra a schermo
        lda $06
        clc
        adc #48          // PETSCII '0'
        sta SCORE_DISPLAY
        lda $07
        clc
        adc #48
        sta SCORE_DISPLAY+1
        lda $08
        clc
        adc #48
        sta SCORE_DISPLAY+2

        rts

}

// --- ESERCIZIO 3: state machine MENU → PLAY → GAME OVER → MENU ---
.segment Ex3
.namespace Ex3 {
    // *=$A000
        lda #0
        sta GAME_STATE
        jsr SHOW_MENU

    LOOP3:

        lda GAME_STATE
        cmp #0
        beq STATE_MENU
        cmp #1
        beq STATE_PLAY
        jmp STATE_GAMEOVER

    STATE_MENU:

        lda JOYPORT
        and #16
        bne SM_END

        lda #1
        sta GAME_STATE
        jsr INIT_PLAY
        jmp SM_END

    STATE_PLAY:

        jsr GAME_UPDATE
        lda PLAYER_LIVES
        beq GO_TO_GAMEOVER
        jmp SP_END

    GO_TO_GAMEOVER:

        lda #2
        sta GAME_STATE
        jsr SHOW_GAMEOVER
        jmp SP_END

    STATE_GAMEOVER:

        lda JOYPORT
        and #16
        bne SG_END

        lda #0
        sta GAME_STATE
        jsr SHOW_MENU

    SP_END:

    SG_END:

    SM_END:

        jsr WAIT3
        jmp LOOP3

}

// --- ESERCIZIO 4: 3 vite, game over a 0 ---
.segment Ex4
.namespace Ex4 {
    // *=$B000
        lda #3
        sta PLAYER_LIVES
        // ...

    HIT_PLAYER:

        lda INVINCIBLE
        bne HP_END

        dec PLAYER_LIVES
        lda #1
        sta INVINCIBLE
        lda #60
        sta INV_TIMER

        lda PLAYER_LIVES
        bne HP_END

        // Game over
        lda #2
        sta GAME_STATE
        jsr SHOW_GAMEOVER

    HP_END:

        rts

    SHOW_GAMEOVER:

        lda #7       // 'G'
        sta $0400+(12*40+15)
        lda #1       // 'A'
        sta $0400+(12*40+16)
        lda #13      // 'M'
        sta $0400+(12*40+17)
        lda #5       // 'E'
        sta $0400+(12*40+18)
        lda #32      // spazio
        sta $0400+(12*40+19)
        lda #15      // 'O'
        sta $0400+(12*40+20)
        lda #22      // 'V'
        sta $0400+(12*40+21)
        lda #5       // 'E'
        sta $0400+(12*40+22)
        lda #18      // 'R'
        sta $0400+(12*40+23)
        rts

    SHOW_MENU:

        lda #13      // 'M'
        sta $0400+(10*40+12)
        lda #5       // 'E'
        sta $0400+(10*40+13)
        lda #14      // 'N'
        sta $0400+(10*40+14)
        lda #21      // 'U'
        sta $0400+(10*40+15)
        lda #32      // spazio
        sta $0400+(10*40+16)
        // "FIRE TO START"
        lda #6       // 'F'
        sta $0400+(12*40+12)
        lda #9       // 'I'
        sta $0400+(12*40+13)
        lda #18      // 'R'
        sta $0400+(12*40+14)
        lda #5       // 'E'
        sta $0400+(12*40+15)
        lda #32
        sta $0400+(12*40+16)
        lda #20      // 'T'
        sta $0400+(12*40+17)
        lda #15      // 'O'
        sta $0400+(12*40+18)
        lda #32
        sta $0400+(12*40+19)
        lda #19      // 'S'
        sta $0400+(12*40+20)
        lda #20      // 'T'
        sta $0400+(12*40+21)
        lda #1       // 'A'
        sta $0400+(12*40+22)
        lda #18      // 'R'
        sta $0400+(12*40+23)
        lda #20      // 'T'
        sta $0400+(12*40+24)
        rts

}

// --- ESERCIZIO 5: mostra WAVE 1/2/... tra le wave ---
.segment Ex5
.namespace Ex5 {
    // *=$C000
        lda #1
        sta WAVE_INDEX

    LOOP5:

        lda GAME_STATE
        cmp #1
        bne LOOP5

        // Al cambio wave
        lda WAVE_DISPLAY_TIMER
        bne WD_DEC

        // Mostra "WAVE X"
        lda #23      // 'W'
        sta $0400+(10*40+15)
        lda #1       // 'A'
        sta $0400+(10*40+16)
        lda #22      // 'V'
        sta $0400+(10*40+17)
        lda #5       // 'E'
        sta $0400+(10*40+18)
        lda #32      // spazio
        sta $0400+(10*40+19)

        lda WAVE_INDEX
        clc
        adc #48      // PETSCII '0'
        sta $0400+(10*40+20)

        lda #50
        sta WAVE_DISPLAY_TIMER

        jmp WD_END

    WD_DEC:

        dec WAVE_DISPLAY_TIMER

    WD_END:

        jsr WAIT5
        jmp LOOP5

    WAIT2:

    WAIT3:

    WAIT5:

        lda $D012
        cmp #$F8
        bne WAIT2
        rts

    INIT_PLAY:

        rts
    GAME_UPDATE:

        rts
}
