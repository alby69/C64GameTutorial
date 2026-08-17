// Converted to Kick Assembler syntax
.segmentdef Ex1 [start=$c000]
.segmentdef Ex2 [start=$c000]
.segmentdef Ex3 [start=$c000]
.segmentdef Ex4 [start=$c000]
.segmentdef Ex5 [start=$c000]

// --- Shared Constants ---
.const SAVE_HS = Ex3.SAVE_HS
.const SCORE_HI = Ex4.SCORE_HI
.const SCORE_LO = Ex4.SCORE_LO
.const HS_DATA = Ex3.HS_DATA
.const PRINT_HEX = Ex5.PRINT_HEX
.const LOAD_HS = Ex3.LOAD_HS

// =============================================
// SOLUZIONI Capitolo 23 — Schermate Titolo e High Score
// --- METADATA ---
// chapter: 23
// title: Titolo e High Score
// difficulty: intermediate
// --- END METADATA ---
// =============================================
//
// Mappa esercizi:
//   1: schermata titolo "SHOOTER 64" centrata
//   2: sprite animato con cambio colore ogni 8 frame
//   3: salva/carica high score su disco (KERNAL)
//   4: game over con punteggio + high score
//   5: ciclo completo titolo → gioco → game over → titolo
//
// =============================================

// --- ESERCIZIO 1: schermata titolo "SHOOTER 64" ---
.segment Ex1
.namespace Ex1 {
    // *= $C000
        lda #0
        sta $D021           // sfondo nero
        lda #$0B
        sta $D020           // bordo grigio

        ldx #0
    LOOP1:

        lda TITLE1,X
        beq DONE1
        sta $0400+40*10+12,X
        lda #7
        sta $D800+40*10+12,X
        inx
        jmp LOOP1
    DONE1:

        rts

    TITLE1:

        .text "SHOOTER 64"
        .byte 0

}

// --- ESERCIZIO 2: sprite animato che cambia colore ---
.segment Ex2
.namespace Ex2 {
    // *= $C000
        lda #0
        sta $D021
        lda #$0B
        sta $D020

        lda #1
        sta $D015           // sprite 0 on
        lda #160
        sta $D000           // X
        lda #100
        sta $D001           // Y
        lda #1
        sta $D027           // colore iniziale

        sei
        lda #<IRQ2
        sta $0314
        lda #>IRQ2
        sta $0315
        lda #0
        sta $D012
        lda #1
        sta $D01A
        cli

        jmp MAIN2

    IRQ2:

        lda FRAME2
        and #7
        tax
        lda RAINBOW2,X
        sta $D027
        inc FRAME2
        lda $D019
        sta $D019
        jmp $EA31

    FRAME2:

        .byte 0

    RAINBOW2:

        .byte 2,4,7,5,3,1,13,6

    MAIN2:

        // Attendi FIRE per uscire
        lda $DC01
        and #$10
        bne MAIN2
        sei
        lda #0
        sta $D01A
        cli
        rts

}

// --- ESERCIZIO 3: salva/carica high score su disco ---
.segment Ex3
.namespace Ex3 {
    // *= $C000
        jsr LOAD_HS
        jsr SAVE_HS
        rts

    // Salva high score (3 byte)
    SAVE_HS:

        lda #2
        ldx #<FNAME3
        ldy #>FNAME3
        jsr $FFBD
        lda #1
        ldx #8
        ldy #1
        jsr $FFBA
        lda #<HS_DATA
        ldx #>HS_DATA
        ldy #$C0
        jsr $FFD8
        rts

    // Carica high score (3 byte)
    LOAD_HS:

        lda #2
        ldx #<FNAME3
        ldy #>FNAME3
        jsr $FFBD
        lda #1
        ldx #8
        ldy #0
        jsr $FFBA
        lda #0
        ldx #<HS_DATA
        ldy #>HS_DATA
        jsr $FFD5
        bcc LOAD_OK
        // File non esiste — init a zero
        lda #0
        sta HS_DATA
        sta HS_DATA+1
        sta HS_DATA+2
    LOAD_OK:

        rts

    FNAME3:

        .text "HI"

    HS_DATA:

        .byte 0,0,0

}

// --- ESERCIZIO 4: game over + high score ---
.segment Ex4
.namespace Ex4 {
    // *= $C000
        jsr LOAD_HS

        // Simula punteggio per test
        lda #12
        sta SCORE_LO
        lda #3
        sta SCORE_HI

        // Stampa "GAME OVER"
        ldx #0
    GO4_LOOP:

        lda GOV_TEXT4,X
        beq GO4_SCORE
        sta $0400+40*8+14,X
        inx
        jmp GO4_LOOP

    GO4_SCORE:

        // Stampa punteggio
        lda SCORE_HI
        jsr PRINT_HEX
        lda SCORE_LO
        jsr PRINT_HEX

        // Stampa "HIGH: "
        ldx #0
    GO4_HS:

        lda HS_TEXT4,X
        beq GO4_CHECK
        sta $0400+40*10+12,X
        inx
        jmp GO4_HS

    GO4_CHECK:

        lda SCORE_HI
        cmp HS_DATA+1
        bcc GO4_WAIT
        lda SCORE_LO
        cmp HS_DATA
        bcc GO4_WAIT
        // Nuovo record!
        lda SCORE_LO
        sta HS_DATA
        lda SCORE_HI
        sta HS_DATA+1
        jsr SAVE_HS

        // Stampa "NUOVO RECORD!"
        ldx #0
    GO4_NR:

        lda NR_TEXT4,X
        beq GO4_WAIT
        sta $0400+40*12+12,X
        inx
        jmp GO4_NR

    GO4_WAIT:

        lda $DC01
        and #$10
        bne GO4_WAIT
        rts

    GOV_TEXT4:

        .text "GAME OVER"
        .byte 0
    HS_TEXT4:

        .text "HIGH: "
        .byte 0
    NR_TEXT4:

        .text "NUOVO RECORD!"
        .byte 0
    SCORE_LO:

        .byte 0
    SCORE_HI:

        .byte 0

}

// --- ESERCIZIO 5: ciclo completo ---
.segment Ex5
.namespace Ex5 {
    // Nota: questo esercizio richiede integrazione in un progetto
    // piu grande. Qui mostriamo la macchina a stati.
    // *= $C000
        sei
        lda #0
        sta $D01A
        cli

        jsr LOAD_HS

    STATE_LOOP:

        // Sezione GAME_OVER salta direttamente
        lda STATE
        cmp #2
        beq GAME_OVER5

        // Sezione TITOLO
        jsr TITLE5
        jsr WAIT_FIRE

        // Sezione GIOCO (simulata)
        lda #1
        sta STATE

        lda #0
        sta SCORE_LO
        lda #0
        sta SCORE_HI

        jsr GAME5

    GAME_OVER5:

        // Sezione GAME OVER
        lda SCORE_HI
        cmp HS_DATA+1
        bcc G5_WAIT
        lda SCORE_LO
        cmp HS_DATA
        bcc G5_WAIT
        lda SCORE_LO
        sta HS_DATA
        lda SCORE_HI
        sta HS_DATA+1
        jsr SAVE_HS
        lda #2
        sta NR_FLAG

    G5_WAIT:

        jsr SHOW_GOVER5
        jsr WAIT_FIRE

        // Torna al titolo
        lda #0
        sta STATE
        lda #0
        sta NR_FLAG
        jmp STATE_LOOP

    // Sottoroutine

    TITLE5:

        lda #0
        sta $D021
        lda #$0B
        sta $D020
        ldx #0
    T5_L:

        lda TIT5_T,X
        beq T5_D
        sta $0400+40*10+12,X
        lda #7
        sta $D800+40*10+12,X
        inx
        jmp T5_L
    T5_D:

        rts

    GAME5:

        // Simula partita breve con punteggio
        lda #10
        sta SCORE_LO
        lda #5
        sta SCORE_HI
        rts

    SHOW_GOVER5:

        ldx #0
    SG_L:

        lda GOV5_T,X
        beq SG_S
        sta $0400+40*8+14,X
        inx
        jmp SG_L
    SG_S:

        lda SCORE_HI
        jsr PRINT_HEX
        lda SCORE_LO
        jsr PRINT_HEX
        lda NR_FLAG
        cmp #2
        bne SG_E
        ldx #0
    SG_NR:

        lda NR5_T,X
        beq SG_E
        sta $0400+40*12+12,X
        inx
        jmp SG_NR
    SG_E:

        rts

    WAIT_FIRE:

        lda $DC01
        and #$10
        bne WAIT_FIRE
        rts

    STATE:

        .byte 0
    NR_FLAG:

        .byte 0

    TIT5_T:

        .text "SHOOTER 64"
        .byte 0
    GOV5_T:

        .text "GAME OVER"
        .byte 0
    NR5_T:

        .text "NUOVO RECORD!"
        .byte 0

    // Utility: stampa A come esadecimale
    PRINT_HEX:

        pha
        lsr
        lsr
        lsr
        lsr
        tax
        lda HEX_CHARS,X
        jsr $FFD2
        pla
        and #$0F
        tax
        lda HEX_CHARS,X
        jsr $FFD2
        lda #$20
        jsr $FFD2
        rts

    HEX_CHARS:

        .text "0123456789ABCDEF"
}
