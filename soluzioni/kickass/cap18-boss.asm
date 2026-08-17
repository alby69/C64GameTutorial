// Converted to Kick Assembler syntax
.segmentdef Ex1 [start=$c000]
.segmentdef Ex2 [start=$c000]
.segmentdef Ex3 [start=$c000]
.segmentdef Ex4 [start=$c000]
.segmentdef Ex5 [start=$c000]

// --- Shared Constants ---
.const UPDATE_BOSS3 = Ex3.UPDATE_BOSS3
.const MOVE_BOSS2 = Ex2.MOVE_BOSS2
.const WAIT = Ex5.WAIT
.const BOSS_SHOOT = Ex1.BOSS_SHOOT
.const BOSS_X = $10
.const BOSS_Y = $11
.const BOSS_STATE = $12
.const BOSS_HP = $13
.const BOSS_DIR = $14
.const BOSS_TIMER = $15
.const FRAME_CNT = $07
.const WAIT2 = WAIT
.const WAIT3 = WAIT
.const WAIT5 = WAIT
.const PLAYER_HITS = $58
.const PLAYER_MISSES = $59

// =============================================
// SOLUZIONI Capitolo 18 — Boss System
// --- METADATA ---
// chapter: 18
// title: Boss System
// difficulty: advanced
// --- END METADATA ---
// =============================================
//
// Mappa esercizi:
//   1: boss 3 fasi: intro + pattern A + morte
//   2: boss si muove dx/sx, spara ogni 30 frame
//   3: fase enrage quando HP < 50%
//   4: animazione morte flash + colore
//   5: boss adatta difficolta in base ai colpi player
//
// =============================================

// --- ESERCIZIO 1: boss 3 fasi: intro + pattern A + morte ---
.segment Ex1
.namespace Ex1 {
    // *=$C000
        lda #%00000001
        sta $D015
        lda #7
        sta $D027
        lda #128
        sta $07F8
        lda #160
        sta BOSS_X
        lda #0
        sta BOSS_Y
        lda #0
        sta BOSS_STATE
        lda #100
        sta BOSS_HP
        lda #0
        sta BOSS_DIR

    LOOP1:

        jsr UPDATE_BOSS1
        jsr RENDER_BOSS1
        jsr WAIT
        jmp LOOP1

    UPDATE_BOSS1:

        lda BOSS_STATE
        cmp #0
        beq B_INTRO
        cmp #1
        beq B_ATTACK
        cmp #2
        beq B_DIE

    B_INTRO:

        lda BOSS_Y
        cmp #60
        bcs B_I_DONE
        inc BOSS_Y
        rts

    B_I_DONE:

        lda #1
        sta BOSS_STATE
        lda #0
        sta BOSS_TIMER
        rts

    B_ATTACK:

        dec BOSS_TIMER
        bpl B_A_MOVE
        lda #20
        sta BOSS_TIMER
        jsr BOSS_SHOOT

    B_A_MOVE:

        lda BOSS_DIR
        beq B_A_LEFT
        inc BOSS_X
        lda BOSS_X
        cmp #240
        bcc B_A_END
        lda #0
        sta BOSS_DIR
        jmp B_A_END

    B_A_LEFT:

        dec BOSS_X
        lda BOSS_X
        cmp #20
        bcs B_A_END
        lda #1
        sta BOSS_DIR

    B_A_END:

        lda BOSS_HP
        bne B_A_RTS
        lda #2
        sta BOSS_STATE

    B_A_RTS:

        rts

    B_DIE:

        jsr DEATH_ANIM
        rts

    BOSS_SHOOT:

        // Trova proiettile inattivo
        ldx #0
    BS_LOOP:

        lda $10,X
        beq BS_FOUND
        inx
        cpx #4
        bne BS_LOOP
        rts

    BS_FOUND:

        lda #1
        sta $10,X
        lda BOSS_X
        sta $12,X
        lda BOSS_Y
        clc
        adc #16
        sta $14,X
        rts

    RENDER_BOSS1:

        lda BOSS_X
        sta $D000
        lda BOSS_Y
        sta $D001
        rts

    DEATH_ANIM:

        inc $D020
        lda FRAME_CNT
        and #3
        tax
        lda DEATH_COLORS,X
        sta $D027
        dec BOSS_HP
        lda BOSS_HP
        beq B_DEAD
        rts

    B_DEAD:

        lda #0
        sta $D015
        rts

    DEATH_COLORS:

        .byte 2, 1, 2, 0

}

// --- ESERCIZIO 2: boss si muove dx/sx, spara ogni 30 frame ---
.segment Ex2
.namespace Ex2 {
    // *=$9000
        // Stesso setup base...

    LOOP2:

        jsr MOVE_BOSS2
        jsr SHOOT_TIMER2
        jsr WAIT2
        jmp LOOP2

    MOVE_BOSS2:

        lda BOSS_DIR
        beq MB_LEFT

        inc BOSS_X
        lda BOSS_X
        cmp #240
        bcc MB_END
        lda #0
        sta BOSS_DIR
        jmp MB_END

    MB_LEFT:

        dec BOSS_X
        lda BOSS_X
        cmp #20
        bcs MB_END
        lda #1
        sta BOSS_DIR

    MB_END:

        rts

    SHOOT_TIMER2:

        dec BOSS_TIMER
        bpl ST_END
        lda #30
        sta BOSS_TIMER
        jsr BOSS_SHOOT

    ST_END:

        rts

}

// --- ESERCIZIO 3: fase enrage quando HP < 50% ---
.segment Ex3
.namespace Ex3 {
    // *=$A000
        // Stesso setup...

    LOOP3:

        jsr CHECK_PHASE
        jsr UPDATE_BOSS3
        jsr WAIT3
        jmp LOOP3

    CHECK_PHASE:

        lda BOSS_HP
        cmp #50          // < 50% ?
        bcs CP_END

        lda BOSS_STATE
        cmp #3           // gia enrage?
        beq CP_END

        lda #3
        sta BOSS_STATE
        lda #5
        sta BOSS_TIMER   // spara ogni 5 frame!

    CP_END:

        rts

    UPDATE_BOSS3:

        lda BOSS_STATE
        cmp #1
        beq B3_NORMAL
        cmp #3
        beq B3_ENRAGE
        jmp B3_END

    B3_NORMAL:

        // movimento normale
        jsr MOVE_BOSS2
        dec BOSS_TIMER
        bpl B3_END
        lda #30
        sta BOSS_TIMER
        jsr BOSS_SHOOT
        jmp B3_END

    B3_ENRAGE:

        // movimento + veloce
        lda BOSS_DIR
        beq B3E_LEFT
        inc BOSS_X
        inc BOSS_X        // 2 pixel!
        lda BOSS_X
        cmp #240
        bcc B3E_DEC
        lda #0
        sta BOSS_DIR
        jmp B3E_DEC

    B3E_LEFT:

        dec BOSS_X
        dec BOSS_X
        lda BOSS_X
        cmp #20
        bcs B3E_DEC
        lda #1
        sta BOSS_DIR

    B3E_DEC:

        dec BOSS_TIMER
        bpl B3_END
        lda #5
        sta BOSS_TIMER
        jsr BOSS_SHOOT
        jsr BOSS_SHOOT    // 2 proiettili!

    B3_END:

        rts

}

// --- ESERCIZIO 4: animazione morte flash + colore ---
.segment Ex4
.namespace Ex4 {
    // *=$B000
        // ...

    DEATH_ANIM4:

        // Flash bordo
        inc $D020

        // Cambia colore sprite
        lda FRAME_CNT
        and #7
        tax
        lda FLASH_COLORS,X
        sta $D027

        // Effetto esplosione
        jsr EXPLOSION_SOUND

        dec BOSS_HP
        lda BOSS_HP
        bne DA_END

        lda #0
        sta $D015       // nascondi sprite

    DA_END:

        rts

    FLASH_COLORS:

        .byte 2, 1, 2, 1, 2, 0, 2, 1

    EXPLOSION_SOUND:

        lda #$00
        sta $D400
        lda #$20
        sta $D401
        lda #$81
        sta $D404
        rts

}

// --- ESERCIZIO 5: boss adatta difficolta in base ai colpi player ---
.segment Ex5
.namespace Ex5 {
    // *=$C000
        lda #0
        sta PLAYER_HITS
        sta PLAYER_MISSES

    LOOP5:

        jsr ADAPT_BOSS
        jsr UPDATE_BOSS3
        jsr WAIT5
        jmp LOOP5

    ADAPT_BOSS:

        lda PLAYER_HITS
        sec
        sbc PLAYER_MISSES
        bmi PB_BAD

        // Player bravo: accelera
        lda BOSS_TIMER
        cmp #5
        bcc ADAPT_DONE
        sec
        sbc #2
        sta BOSS_TIMER
        rts

    PB_BAD:

        // Player in difficolta: rallenta
        lda BOSS_TIMER
        cmp #30
        bcs ADAPT_DONE
        clc
        adc #2
        sta BOSS_TIMER

    ADAPT_DONE:

        rts

    // --- Helper per compilazione standalone ---
    WAIT:

        lda $D012
        cmp #$F8
        bne WAIT
        rts
}
