// Converted to Kick Assembler syntax
.segmentdef Ex1 [start=$c000]
.segmentdef Ex2 [start=$c000]
.segmentdef Ex3 [start=$c000]
.segmentdef Ex4 [start=$c000]
.segmentdef Ex5 [start=$c000]

// --- Shared Constants ---
.const WAIT = Ex5.WAIT
.const MOVE_GROUP = Ex1.MOVE_GROUP
.const WAIT2 = WAIT
.const WAIT3 = WAIT
.const WAIT4 = WAIT
.const WAIT5 = WAIT
.const MOVE_GROUP3 = MOVE_GROUP
.const FRAME_CNT = $07
.const ENEMY_X = $10
.const ENEMY_Y = $11
.const ENEMY_DIR = $12      // 0=dx, 1=sx
.const ENEMY_SPEED = $13
.const ENEMY_COUNT = $14
.const SPAWN_TIMER = $15
.const WAVE_NUM = $20
.const SPEED = $21
.const E_BULLET_X = $30
.const E_BULLET_Y = $31
.const E_BULLET_ACT = $32
.const E_SHOOT_TIMER = $33
.const PATTERN = $40     // 0=lineare, 1=zigzag, 2=casuale

// =============================================
// SOLUZIONI Capitolo 12 — Wave System e AI
// --- METADATA ---
// chapter: 12
// title: Wave System e AI
// difficulty: advanced
// --- END METADATA ---
// =============================================
//
// Mappa esercizi:
//   1: 4 nemici si muovono insieme, rimbalzo bordo
//   2: spawn progressivo ogni 30 frame
//   3: ogni wave aumenta velocita di 1
//   4: nemico spara ogni 40 frame
//   5: 3 pattern di movimento, uno per wave
//
// =============================================

// --- ESERCIZIO 1: 4 nemici si muovono insieme, rimbalzo bordo ---
.segment Ex1
.namespace Ex1 {

    // *=$C000
        lda #%00011111      // player + 4 nemici
        sta $D015
        lda #1
        sta $D027
        lda #2
        sta $D028
        sta $D029
        sta $D02A
        sta $D02B
        lda #128
        sta $07F8
        sta $07F9
        sta $07FA
        sta $07FB
        sta $07FC

        // Posizioni iniziali
        lda #160
        sta $D000           // player
        lda #200
        sta $D001

        lda #40
        sta ENEMY_X
        lda #60
        sta ENEMY_Y
        lda #0
        sta ENEMY_DIR
        lda #1
        sta ENEMY_SPEED

    LOOP1:

        jsr MOVE_GROUP
        jsr UPDATE_ENEMY_POS
        jsr WAIT
        jmp LOOP1

    MOVE_GROUP:

        lda ENEMY_DIR
        beq MG_RIGHT

    MG_LEFT:

        lda ENEMY_X
        sec
        sbc ENEMY_SPEED
        sta ENEMY_X
        cmp #10
        bcs MG_DONE
        lda #0
        sta ENEMY_DIR
        lda ENEMY_Y
        clc
        adc #10            // scendono
        sta ENEMY_Y
        jmp MG_DONE

    MG_RIGHT:

        lda ENEMY_X
        clc
        adc ENEMY_SPEED
        sta ENEMY_X
        cmp #250
        bcc MG_DONE
        lda #1
        sta ENEMY_DIR
        lda ENEMY_Y
        clc
        adc #10
        sta ENEMY_Y

    MG_DONE:

        rts

    UPDATE_ENEMY_POS:

        lda ENEMY_X
        sta $D002
        clc
        adc #30
        sta $D004
        clc
        adc #30
        sta $D006
        clc
        adc #30
        sta $D008

        lda ENEMY_Y
        sta $D003
        sta $D005
        sta $D007
        sta $D009
        rts

}

// --- ESERCIZIO 2: spawn progressivo ogni 30 frame ---
.segment Ex2
.namespace Ex2 {
    // *=$A000
        lda #0
        sta ENEMY_COUNT
        sta SPAWN_TIMER

        // setup sprite...

    LOOP2:

        jsr SPAWN_PROGRESSIVE
        jsr WAIT2
        jmp LOOP2

    SPAWN_PROGRESSIVE:

        lda ENEMY_COUNT
        cmp #8
        beq SP_DONE

        dec SPAWN_TIMER
        bpl SP_DONE

        lda #30
        sta SPAWN_TIMER

        // Attiva nuovo nemico
        ldx ENEMY_COUNT
        lda #1
        sta $D015,X        // abilita sprite
        lda #60
        sta $D000,X        // X = 60 + offset random
        lda #30
        sta $D001,X        // Y dall'alto
        lda #2
        sta $D027,X        // colore

        inc ENEMY_COUNT

    SP_DONE:

        rts

}

// --- ESERCIZIO 3: ogni wave aumenta velocita di 1 ---
.segment Ex3
.namespace Ex3 {
    // *=$B000
        lda #1
        sta SPEED
        sta WAVE_NUM

    LOOP3:

        jsr CHECK_WAVE_END
        jsr MOVE_GROUP3
        jsr WAIT3
        jmp LOOP3

    CHECK_WAVE_END:

        // Se tutti i nemici morti, nuova wave
        lda ENEMY_COUNT
        bne CWE_END

        inc WAVE_NUM
        inc SPEED         // velocita +1

        // Respawn nemici
        lda #4
        sta ENEMY_COUNT
        jsr RESET_ENEMIES

    CWE_END:

        rts

    RESET_ENEMIES:

        ldx #0
    RE_LOOP:

        lda #1
        sta $D015,X
        inx
        cpx ENEMY_COUNT
        bne RE_LOOP
        rts

}

// --- ESERCIZIO 4: nemico spara ogni 40 frame ---
.segment Ex4
.namespace Ex4 {
    // *=$C000
        lda #0
        sta E_BULLET_ACT
        lda #40
        sta E_SHOOT_TIMER

    LOOP4:

        jsr ENEMY_SHOOT
        jsr UPDATE_E_BULLET
        jsr WAIT4
        jmp LOOP4

    ENEMY_SHOOT:

        dec E_SHOOT_TIMER
        bpl ES_END

        lda #40
        sta E_SHOOT_TIMER

        lda E_BULLET_ACT
        bne ES_END

        lda #1
        sta E_BULLET_ACT
        lda #100
        sta E_BULLET_X    // X del nemico
        lda #80
        sta E_BULLET_Y    // Y del nemico

    ES_END:

        rts

    UPDATE_E_BULLET:

        lda E_BULLET_ACT
        beq UEB_END

        inc E_BULLET_Y    // cade verso il basso
        lda E_BULLET_Y
        cmp #230
        bcc UEB_END

        lda #0
        sta E_BULLET_ACT

    UEB_END:

        rts

}

// --- ESERCIZIO 5: 3 pattern di movimento, uno per wave ---
.segment Ex5
.namespace Ex5 {
    // *=$D000
        lda #0
        sta PATTERN

    LOOP5:

        lda PATTERN
        cmp #0
        beq MOVE_LINEAR
        cmp #1
        beq MOVE_ZIGZAG
        jmp MOVE_RANDOM

    MOVE_LINEAR:

        jsr MOVE_GROUP
        jmp DONE5

    MOVE_ZIGZAG:

        jsr ZIGZAG_MOVE
        jmp DONE5

    MOVE_RANDOM:

        jsr RANDOM_MOVE

    DONE5:

        jsr WAIT5
        jmp LOOP5

    ZIGZAG_MOVE:

        lda ENEMY_DIR
        beq ZZ_RIGHT

    ZZ_LEFT:

        dec ENEMY_X
        lda ENEMY_X
        cmp #20
        bcs ZZ_ALT_Y
        lda #0
        sta ENEMY_DIR
        jmp ZZ_ALT_Y

    ZZ_RIGHT:

        inc ENEMY_X
        lda ENEMY_X
        cmp #240
        bcc ZZ_ALT_Y
        lda #1
        sta ENEMY_DIR

    ZZ_ALT_Y:

        lda FRAME_CNT
        and #15
        bne ZZ_END
        inc ENEMY_Y        // zigzag: ogni 16 frame scende

    ZZ_END:

        rts

    RANDOM_MOVE:

        lda $D012
        and #3
        beq RM_UP
        cmp #1
        beq RM_DOWN
        cmp #2
        beq RM_LEFT
        // destra
        inc ENEMY_X
        jmp RM_DONE
    RM_UP:

        dec ENEMY_Y
        jmp RM_DONE
    RM_DOWN:

        inc ENEMY_Y
        jmp RM_DONE
    RM_LEFT:

        dec ENEMY_X

    RM_DONE:

        // clamp bordi
        lda ENEMY_X
        cmp #10
        bcs RM_C1
        lda #10
        sta ENEMY_X
    RM_C1:

        cmp #250
        bcc RM_C2
        lda #250
        sta ENEMY_X
    RM_C2:

        lda ENEMY_Y
        cmp #30
        bcs RM_C3
        lda #30
        sta ENEMY_Y
    RM_C3:

        cmp #200
        bcc RM_END
        lda #200
        sta ENEMY_Y
    RM_END:

        rts

    // --- Helper per compilazione standalone ---
    WAIT:

        lda $D012
        cmp #$F8
        bne WAIT
        rts
}
