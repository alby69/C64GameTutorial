// Converted to Kick Assembler syntax
.segmentdef Ex1 [start=$c000]
.segmentdef Ex2 [start=$c000]
.segmentdef Ex3 [start=$c000]
.segmentdef Ex4 [start=$c000]
.segmentdef Ex5 [start=$c000]

// --- Shared Constants ---
.const WAIT = Ex1.WAIT
.const UPDATE_BULLETS = Ex1.UPDATE_BULLETS
.const READ_JOY1 = Ex1.READ_JOY1
.const BULLET_X = $10     // 2 byte (X0, X1)
.const BULLET_Y = $12
.const BULLET_ACT = $14
.const JOYPORT = $DC01
.const COOLDOWN = $06
.const ENEMY_HP = $20
.const ENEMY_B_X = $22
.const ENEMY_B_Y = $23
.const ENEMY_B_ACT = $24
.const ENEMY_TIMER = $25
.const POWERUP_X = $30
.const POWERUP_Y = $31
.const POWERUP_ACT = $32
.const BULLET_MAX = $33   // 2 o 6
.const READ_JOY2 = READ_JOY1
.const UPDATE_BULLETS2 = UPDATE_BULLETS
.const UPDATE_BULLETS3 = UPDATE_BULLETS
.const WAIT2 = WAIT
.const WAIT3 = WAIT
.const WAIT4 = WAIT
.const WAIT5 = WAIT
.const FRAME_CNT = $07

// =============================================
// SOLUZIONI Capitolo 11 — Sistema Proiettili
// --- METADATA ---
// chapter: 11
// title: Sistema Proiettili
// difficulty: intermediate
// --- END METADATA ---
// =============================================
//
// Mappa esercizi:
//   1: pool 2 proiettili, fuoco per sparare
//   2: cooldown 10 frame tra uno sparo e l'altro
//   3: proiettile colpisce nemico fisso
//   4: nemico spara proiettile ogni 30 frame
//   5: power-up — raccogli per 6 proiettili
//
// =============================================
// --- ESERCIZIO 1: pool 2 proiettili, fuoco per sparare ---
.segment Ex1
.namespace Ex1 {

    // *=$C000
        lda #%00000111
        sta $D015
        lda #1
        sta $D027       // player
        lda #7
        sta $D028       // proiettile 0
        sta $D029       // proiettile 1
        lda #128
        sta $07F8
        lda #192
        sta $07F9
        sta $07FA

        lda #160
        sta $D000       // player X
        lda #200
        sta $D001       // player Y

        lda #0
        sta BULLET_ACT
        sta BULLET_ACT+1

    LOOP1:

        jsr READ_JOY1
        jsr SPAWN_BULLET
        jsr UPDATE_BULLETS
        jsr WAIT
        jmp LOOP1

    READ_JOY1:

        lda JOYPORT
        and #1
        bne RJ1_D
        dec $D001
    RJ1_D:

        lda JOYPORT
        and #2
        bne RJ1_L
        inc $D001
    RJ1_L:

        lda JOYPORT
        and #4
        bne RJ1_R
        dec $D000
    RJ1_R:

        lda JOYPORT
        and #8
        bne RJ1_X
        inc $D000
    RJ1_X:

        rts

    SPAWN_BULLET:

        lda JOYPORT
        and #16
        bne SB_END

        // Trova slot inattivo
        lda BULLET_ACT
        beq SB_SLOT0
        lda BULLET_ACT+1
        beq SB_SLOT1
        jmp SB_END

    SB_SLOT0:

        lda #1
        sta BULLET_ACT
        lda $D000
        sta BULLET_X
        lda $D001
        sec
        sbc #10
        sta BULLET_Y
        jmp SB_END

    SB_SLOT1:

        lda #1
        sta BULLET_ACT+1
        lda $D000
        sta BULLET_X+1
        lda $D001
        sec
        sbc #10
        sta BULLET_Y+1

    SB_END:

        rts

    UPDATE_BULLETS:

        // Bull 0
        lda BULLET_ACT
        beq UB_1
        dec BULLET_Y
        lda BULLET_Y
        cmp #30
        bcs UB_R0
        lda #0
        sta BULLET_ACT
    UB_R0:

        lda BULLET_X
        sta $D002
        lda BULLET_Y
        sta $D003

    UB_1:

        lda BULLET_ACT+1
        beq UB_END
        dec BULLET_Y+1
        lda BULLET_Y+1
        cmp #30
        bcs UB_R1
        lda #0
        sta BULLET_ACT+1
    UB_R1:

        lda BULLET_X+1
        sta $D004
        lda BULLET_Y+1
        sta $D005

    UB_END:

        rts

    WAIT:

        lda $D012
        cmp #$F8
        bne WAIT
        rts

}

// --- ESERCIZIO 2: cooldown 10 frame tra uno sparo e l'altro ---
.segment Ex2
.namespace Ex2 {
    // *=$9000
        // ...stesso setup...

        lda #0
        sta COOLDOWN

    LOOP2:

        jsr READ_JOY2
        jsr SPAWN_BULLET2
        jsr UPDATE_BULLETS2

        lda COOLDOWN
        beq CD_END
        dec COOLDOWN
    CD_END:

        jsr WAIT2
        jmp LOOP2

    SPAWN_BULLET2:

        lda COOLDOWN
        bne SB2_END
        lda JOYPORT
        and #16
        bne SB2_END

        lda BULLET_ACT
        beq SB2_S0
        lda BULLET_ACT+1
        beq SB2_S1
        jmp SB2_END

    SB2_S0:

        lda #1
        sta BULLET_ACT
        lda $D000
        sta BULLET_X
        lda $D001
        sec
        sbc #10
        sta BULLET_Y
        lda #10
        sta COOLDOWN
        jmp SB2_END

    SB2_S1:

        lda #1
        sta BULLET_ACT+1
        lda $D000
        sta BULLET_X+1
        lda $D001
        sec
        sbc #10
        sta BULLET_Y+1
        lda #10
        sta COOLDOWN

    SB2_END:

        rts

}

// --- ESERCIZIO 3: proiettile colpisce nemico fisso ---
.segment Ex3
.namespace Ex3 {
    // *=$A000
        // ...setup + pool 2 proiettili...

        lda #1
        sta ENEMY_HP
        lda #100
        sta $D002       // X nemico
        lda #80
        sta $D003       // Y nemico
        lda #%00001111
        sta $D015

    LOOP3:

        jsr UPDATE_BULLETS3
        jsr CHECK_HIT
        jsr WAIT3
        jmp LOOP3

    CHECK_HIT:

        lda ENEMY_HP
        beq CH_END

        ldx #0
    CH_LOOP:

        lda BULLET_ACT,X
        beq CH_NEXT

        lda BULLET_X,X
        sec
        sbc #100
        bcs CH_P
        eor #$FF
        clc
        adc #1
    CH_P:

        cmp #24
        bcs CH_NEXT

        lda BULLET_Y,X
        sec
        sbc #80
        bcs CH_P2
        eor #$FF
        clc
        adc #1
    CH_P2:

        cmp #21
        bcs CH_NEXT

        // Colpito!
        lda #0
        sta BULLET_ACT,X
        sta ENEMY_HP
        lda $D015
        and #%11111011
        sta $D015       // nascondi nemico

    CH_NEXT:

        inx
        cpx #2
        bne CH_LOOP

    CH_END:

        rts

}

// --- ESERCIZIO 4: nemico spara proiettile ogni 30 frame ---
.segment Ex4
.namespace Ex4 {
    // *=$B000
        lda #%00001111
        sta $D015
        // ...
        lda #0
        sta ENEMY_B_ACT
        lda #30
        sta ENEMY_TIMER

    LOOP4:

        jsr UPDATE_ENEMY_BULLET
        jsr WAIT4
        jmp LOOP4

    UPDATE_ENEMY_BULLET:

        lda ENEMY_B_ACT
        beq UEB_SPAWN

        inc ENEMY_B_Y   // cade verso il basso
        lda ENEMY_B_Y
        cmp #230
        bcc UEB_R
        lda #0
        sta ENEMY_B_ACT
    UEB_R:

        rts

    UEB_SPAWN:

        dec ENEMY_TIMER
        bne UEB_END

        lda #1
        sta ENEMY_B_ACT
        lda #100
        sta ENEMY_B_X
        lda #80
        sta ENEMY_B_Y
        lda #30
        sta ENEMY_TIMER

    UEB_END:

        rts

}

// --- ESERCIZIO 5: power-up — raccogli per 6 proiettili ---
.segment Ex5
.namespace Ex5 {
    // *=$C000
        lda #0
        sta POWERUP_ACT
        lda #2
        sta BULLET_MAX

    LOOP5:

        jsr CHECK_POWERUP
        jsr SPAWN_POWERUP
        jsr WAIT5
        jmp LOOP5

    SPAWN_POWERUP:

        lda POWERUP_ACT
        bne SP_END

        // Ogni 100 frame spawna power-up
        lda FRAME_CNT
        and #$7F        // ogni 128 frame
        bne SP_END
        bne SP_END
        lda #1
        sta POWERUP_ACT
        lda #180
        sta POWERUP_X
        lda #50
        sta POWERUP_Y
    SP_END:

        rts

    CHECK_POWERUP:

        lda POWERUP_ACT
        beq CP_END

        // Player raccoglie?
        lda $D000
        sec
        sbc POWERUP_X
        bcs CP_P
        eor #$FF
        clc
        adc #1
    CP_P:

        cmp #24
        bcs CP_END

        lda $D001
        sec
        sbc POWERUP_Y
        bcs CP_P2
        eor #$FF
        clc
        adc #1
    CP_P2:

        cmp #21
        bcs CP_END

        // Raccogli!
        lda #0
        sta POWERUP_ACT
        lda #6
        sta BULLET_MAX
        lda #7         // effetto visivo
        sta $D020

    CP_END:

        rts

    // --- Aliases per compatibilità e compilazione standalone ---
}
