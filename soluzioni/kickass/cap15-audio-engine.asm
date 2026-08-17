// Converted to Kick Assembler syntax
.segmentdef Ex1 [start=$c000]
.segmentdef Ex2 [start=$c000]
.segmentdef Ex3 [start=$c000]
.segmentdef Ex4 [start=$c000]
.segmentdef Ex5 [start=$c000]

// --- Shared Constants ---
.const PLAY_SFX = Ex1.PLAY_SFX
.const WAIT3 = Ex5.WAIT3
.const WAIT4 = WAIT3
.const SFX_REQ = $40     // 0=nessuno, 1=sparo, 2=esplosione, 3=bonus
.const SFX_CHANNEL = $41    // canale SID da usare
.const CHAN2_CTRL = $D414
.const CHAN2_FREQ = $D410
.const CHAN2_ADSR = $D415
.const CHAN2_SUR = $D416
.const CHAN3_CTRL = $D424
.const CHAN3_FREQ = $D420
.const CHAN3_ADSR = $D425
.const CHAN3_SUR = $D426
.const NOTE_INDEX = $50
.const NOTE_TIMER = $51
.const AUDIO_QUEUE = $60     // 8 byte: ogni byte = comando
.const QUEUE_HEAD = $70
.const QUEUE_TAIL = $71

// =============================================
// SOLUZIONI Capitolo 15 — Audio Engine
// --- METADATA ---
// chapter: 15
// title: Audio Engine
// difficulty: advanced
// --- END METADATA ---
// =============================================
//
// Mappa esercizi:
//   1: sistema SFX_REQUEST canale 2/3
//   2: UPDATE_AUDIO nel raster IRQ 50 Hz
//   3: sequenza musicale 4 note in loop
//   4: ADSR pioggia noise + attack lungo
//   5: coda audio 8 comandi
//
// =============================================

// --- ESERCIZIO 1: sistema SFX_REQUEST canale 2/3 ---
.segment Ex1
.namespace Ex1 {

    // *=$C000
        lda #15
        sta $D418

    PLAY_SFX:

        lda SFX_REQ
        beq PS_END

        // Determina canale
        lda SFX_CHANNEL
        cmp #2
        beq PS_CH2
        jmp PS_CH3

    PS_CH2:

        lda SFX_REQ
        cmp #1
        beq PS2_SHOOT
        cmp #2
        beq PS2_EXPLODE
        jmp PS2_BONUS

    PS2_SHOOT:

        lda #$00
        sta $D410
        lda #$20
        sta $D411
        lda #$00
        sta CHAN2_ADSR
        lda #$08
        sta CHAN2_SUR
        lda #$81
        sta CHAN2_CTRL
        jmp PS_END

    PS2_EXPLODE:

        lda #$00
        sta $D410
        lda #$10
        sta $D411
        lda #$88
        sta CHAN2_ADSR
        lda #$0F
        sta CHAN2_SUR
        lda #$81
        sta CHAN2_CTRL
        jmp PS_END

    PS2_BONUS:

        // triangle su canale 2
        lda #$40
        sta $D410
        lda #$02
        sta $D411
        lda #$09
        sta CHAN2_ADSR
        lda #$0F
        sta CHAN2_SUR
        lda #$21
        sta CHAN2_CTRL

    PS_CH3:

        jmp PS_END

    PS_END:

        lda #0
        sta SFX_REQ
        rts

}

// --- ESERCIZIO 2: UPDATE_AUDIO nel raster IRQ 50 Hz ---
.segment Ex2
.namespace Ex2 {
    // *=$9000
        sei
        lda #$7F
        sta $DC0D
        lda #<IRQ_AUDIO
        sta $0314
        lda #>IRQ_AUDIO
        sta $0315
        lda #200
        sta $D012
        lda $D011
        and #$7F
        sta $D011
        lda #1
        sta $D01A
        cli

        lda #15
        sta $D418

    MAIN2:

        jmp MAIN2

    IRQ_AUDIO:

        pha
        txa
        pha
        tya
        pha

        jsr PLAY_SFX       // chiamata ogni frame

        // Gestisci durata suoni
        jsr SFX_TIMER

        pla
        tay
        pla
        tax
        pla

        lda $D019
        sta $D019
        jmp $EA31

    SFX_TIMER:

        lda SFX_REQ
        bne ST_END

        // Se nessun suono, spegni canali
        lda #$80
        sta CHAN2_CTRL
        sta CHAN3_CTRL

    ST_END:

        rts

}

// --- ESERCIZIO 3: sequenza musicale 4 note in loop ---
.segment Ex3
.namespace Ex3 {
    // *=$A000
        lda #15
        sta $D418
        lda #0
        sta NOTE_INDEX
        lda #20
        sta NOTE_TIMER

    LOOP3:

        dec NOTE_TIMER
        bpl LOOP3

        lda #20
        sta NOTE_TIMER

        ldx NOTE_INDEX
        lda NOTES,X
        sta $D400
        lda NOTES+1,X
        sta $D401
        lda #$11
        sta $D404

        inx
        inx
        cpx #8
        bne NI_OK
        ldx #0
    NI_OK:

        stx NOTE_INDEX

        jsr WAIT3
        jmp LOOP3

    NOTES:

        .byte $C0, $04    // nota 1 (DO ~520 Hz)
        .byte $00, $06    // nota 2 (RE ~580 Hz)
        .byte $40, $05    // nota 3 (MI ~650 Hz)
        .byte $80, $07    // nota 4 (SOL ~780 Hz)

}

// --- ESERCIZIO 4: ADSR "pioggia" noise + attack lungo ---
.segment Ex4
.namespace Ex4 {
    // *=$B000
        lda #15
        sta $D418

        // Pioggia: noise, attack lungo, decay lento
        lda #$00
        sta $D400
        lda #$30
        sta $D401

        lda #$FA         // attack=15 (lungo), decay=10
        sta $D405

        lda #$00
        sta $D406        // sustain 0, release 0

        lda #$81         // noise + gate
        sta $D404

    LOOP4:

        // Modula frequenza per variare
        lda $D012
        sta $D400
        jsr WAIT4
        jmp LOOP4

}

// --- ESERCIZIO 5: coda audio 8 comandi ---
.segment Ex5
.namespace Ex5 {

    // *=$C000
        lda #0
        sta QUEUE_HEAD
        sta QUEUE_TAIL

    ADD_TO_QUEUE:

        // A = comando da aggiungere
        ldx QUEUE_TAIL
        sta AUDIO_QUEUE,X
        inx
        txa
        and #7
        sta QUEUE_TAIL
        rts

    PROCESS_QUEUE:

        lda QUEUE_HEAD
        cmp QUEUE_TAIL
        beq PQ_END        // coda vuota

        ldx QUEUE_HEAD
        lda AUDIO_QUEUE,X

        // Processa comando
        cmp #1
        beq Q_SHOOT
        cmp #2
        beq Q_EXPLODE
        cmp #3
        beq Q_BONUS
        jmp PQ_NEXT

    Q_SHOOT:

        lda #1
        sta SFX_REQ
        lda #2           // canale 2
        sta SFX_CHANNEL
        jmp PQ_NEXT

    Q_EXPLODE:

        lda #2
        sta SFX_REQ
        lda #3           // canale 3
        sta SFX_CHANNEL
        jmp PQ_NEXT

    Q_BONUS:

        lda #3
        sta SFX_REQ
        lda #2           // canale 2
        sta SFX_CHANNEL

    PQ_NEXT:

        ldx QUEUE_HEAD
        inx
        txa
        and #7
        sta QUEUE_HEAD

    PQ_END:

        rts

    WAIT3:

        lda $D012
        cmp #$F8
        bne WAIT3
        rts
}
