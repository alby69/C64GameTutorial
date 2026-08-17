// Converted to Kick Assembler syntax
.segmentdef Ex1 [start=$c000]
.segmentdef Ex2 [start=$c000]
.segmentdef Ex3 [start=$c000]
.segmentdef Ex4 [start=$c000]
.segmentdef Ex5 [start=$c000]

// --- Shared Constants ---
.const JOYPORT = $DC01
.const PLAYER_X = $D000
.const PLAYER_Y = $D001
.const ENEMY_X = $D002
.const ENEMY_Y = $D003
.const ENEMY1_ACTIVE = $10
.const ENEMY2_ACTIVE = $11
.const ENEMY3_ACTIVE = $12
.const INVINCIBLE = $20
.const INV_TIMER = $21

// =============================================
// SOLUZIONI Capitolo 10 — Collisioni
// --- METADATA ---
// chapter: 10
// title: Collisioni Software
// difficulty: intermediate
// --- END METADATA ---
// =============================================
//
// Mappa esercizi:
//   1: player + nemico fisso, collisione cambia colore
//   2: collisione distrugge nemico, sparisce
//   3: 3 nemici, collisione singola su ciascuno
//   4: segnapunti collisioni (variabile che si incrementa)
//   5: gestione multi-hit (nemico resiste a 3 colpi)
//
// =============================================

// --- ESERCIZIO 1: player + nemico fisso, collisione cambia colore ---
.segment Ex1
.namespace Ex1 {
    // *=$C000
        lda #%00000011
        sta $D015
        lda #1
        sta $D027           // player bianco
        lda #2
        sta $D028           // nemico rosso
        lda #128
        sta $07F8
        sta $07F9

        lda #160
        sta PLAYER_X
        sta ENEMY_X
        lda #100
        sta PLAYER_Y
        lda #80
        sta ENEMY_Y

    LOOP1:

        jsr READ_JOY
        jsr CHECK_COL1
        jsr WAIT
        jmp LOOP1

    READ_JOY:

        lda JOYPORT
        and #1
        bne RJ_DOWN
        dec PLAYER_Y
    RJ_DOWN:

        lda JOYPORT
        and #2
        bne RJ_LEFT
        inc PLAYER_Y
    RJ_LEFT:

        lda JOYPORT
        and #4
        bne RJ_RIGHT
        dec PLAYER_X
    RJ_RIGHT:

        lda JOYPORT
        and #8
        bne RJ_DONE
        inc PLAYER_X
    RJ_DONE:

        rts

    CHECK_COL1:

        lda PLAYER_X
        sec
        sbc ENEMY_X
        bcs CC1_POS
        eor #$FF
        clc
        adc #1
    CC1_POS:

        cmp #24
        bcs CC1_END

        lda PLAYER_Y
        sec
        sbc ENEMY_Y
        bcs CC1_POS2
        eor #$FF
        clc
        adc #1
    CC1_POS2:

        cmp #21
        bcs CC1_END

        // Collisione!
        lda $D020
        eor #$0F
        sta $D020

    CC1_END:

        rts

    WAIT:

        lda $D012
        cmp #$F8
        bne WAIT
        rts

}

// --- ESERCIZIO 2: registro $D01E collisione sprite 0 e 1 ---
.segment Ex2
.namespace Ex2 {
    // *=$9000
        lda #%00000011
        sta $D015
        lda #1
        sta $D027
        lda #2
        sta $D028
        lda #128
        sta $07F8
        sta $07F9
        lda #140
        sta PLAYER_X
        sta ENEMY_X
        lda #100
        sta PLAYER_Y
        lda #100
        sta ENEMY_Y

    LOOP2:

        lda $D01E          // collisioni sprite-sprite
        and #%00000001     // sprite 0 ha collisione?
        beq NO_COL2

        lda #2
        sta $D020          // bordo rosso

    NO_COL2:

        jsr WAIT2
        jmp LOOP2

    WAIT2:

        lda $D012
        cmp #$F8
        bne WAIT2
        rts

}

// --- ESERCIZIO 3: 3 nemici fissi, player li disattiva al contatto ---
.segment Ex3
.namespace Ex3 {
    // *=$A000
        lda #%00001111      // 4 sprite (player + 3 nemici)
        sta $D015
        lda #1
        sta $D027
        lda #2
        sta $D028
        sta $D029
        sta $D02A
        lda #128
        sta $07F8
        sta $07F9
        sta $07FA
        sta $07FB

        // Player
        lda #160
        sta $D000
        lda #150
        sta $D001

        // Nemici
        lda #60
        sta $D002           // X enemy 0
        lda #60
        sta $D004           // X enemy 1
        lda #220
        sta $D006           // X enemy 2
        lda #80
        sta $D003           // Y enemy 0
        sta $D005           // Y enemy 1
        sta $D007           // Y enemy 2

        lda #1
        sta ENEMY1_ACTIVE
        sta ENEMY2_ACTIVE
        sta ENEMY3_ACTIVE

    LOOP3:

        jsr READ_JOY3
        jsr CHECK_COL3
        jsr UPDATE_SPR3
        jsr WAIT3
        jmp LOOP3

    READ_JOY3:

        lda JOYPORT
        and #1
        bne RJ3_DN
        dec $D001
    RJ3_DN:

        lda JOYPORT
        and #2
        bne RJ3_LF
        inc $D001
    RJ3_LF:

        lda JOYPORT
        and #4
        bne RJ3_RT
        dec $D000
    RJ3_RT:

        lda JOYPORT
        and #8
        bne RJ3_DN2
        inc $D000
    RJ3_DN2:

        rts

    CHECK_COL3:

        // Nemico 1
        lda ENEMY1_ACTIVE
        beq CC3_EN2
        jsr CHECK_ENEMY
        cmp #1
        bne CC3_EN2
        lda #0
        sta ENEMY1_ACTIVE

    CC3_EN2:

        lda ENEMY2_ACTIVE
        beq CC3_EN3
        lda $D004
        sta $02
        lda $D005
        sta $03
        jsr CHECK_ENEMY2
        cmp #1
        bne CC3_EN3
        lda #0
        sta ENEMY2_ACTIVE

    CC3_EN3:

        lda ENEMY3_ACTIVE
        beq CC3_END
        lda $D006
        sta $02
        lda $D007
        sta $03
        jsr CHECK_ENEMY2
        cmp #1
        bne CC3_END
        lda #0
        sta ENEMY3_ACTIVE

    CC3_END:

        rts

    CHECK_ENEMY:

        // Usa $D002, $D003 per enemy 0
        lda $D000
        sec
        sbc $D002
        bcs CE_POS
        eor #$FF
        clc
        adc #1
    CE_POS:

        cmp #24
        bcs CE_NOHIT
        lda $D001
        sec
        sbc $D003
        bcs CE_POS2
        eor #$FF
        clc
        adc #1
    CE_POS2:

        cmp #21
        bcs CE_NOHIT
        lda #1
        rts
    CE_NOHIT:

        lda #0
        rts

    CHECK_ENEMY2:

        lda $D000
        sec
        sbc $02
        bcs CE2_P
        eor #$FF
        clc
        adc #1
    CE2_P:

        cmp #24
        bcs CE2_N
        lda $D001
        sec
        sbc $03
        bcs CE2_P2
        eor #$FF
        clc
        adc #1
    CE2_P2:

        cmp #21
        bcs CE2_N
        lda #1
        rts
    CE2_N:

        lda #0
        rts

    UPDATE_SPR3:

        lda ENEMY1_ACTIVE
        bne US3_E1
        lda $D015
        and #%11111110
        sta $D015
        jmp US3_E2
    US3_E1:

        lda $D015
        ora #%00000010
        sta $D015
    US3_E2:

        lda ENEMY2_ACTIVE
        bne US3_E3
        lda $D015
        and #%11111101
        sta $D015
        jmp US3_E4
    US3_E3:

        lda $D015
        ora #%00000100
        sta $D015
    // Continua per nemico 3...
    US3_E4:

        rts

    WAIT3:

        lda $D012
        cmp #$F8
        bne WAIT3
        rts

}

// --- ESERCIZIO 4: vittoria quando tutti nemici morti ---
.segment Ex4
.namespace Ex4 {
    // (continua da esercizio 3)
    // *=$A000
        // ...stesso setup di es.3...

    // Aggiungi dopo UPDATE_SPR3:
    CHECK_VICTORY:

        lda ENEMY1_ACTIVE
        ora ENEMY2_ACTIVE
        ora ENEMY3_ACTIVE
        bne CV_END

        // Tutti morti: mostra VITTORIA
        lda #22        // 'V'
        sta $0400+(10*40+15)
        lda #9         // 'I'
        sta $0401+(10*40+15)
        lda #20        // 'T'
        sta $0402+(10*40+15)
        lda #20        // 'T'
        sta $0403+(10*40+15)
        lda #15        // 'O'
        sta $0404+(10*40+15)
        lda #18        // 'R'
        sta $0405+(10*40+15)
        lda #9         // 'I'
        sta $0406+(10*40+15)
        lda #1         // 'A'
        sta $0407+(10*40+15)

    CV_END:

        rts

}

// --- ESERCIZIO 5: invincibilita 60 frame post-collisione ---
.segment Ex5
.namespace Ex5 {
    // *=$B000
        lda #%00000011
        sta $D015
        lda #1
        sta $D027
        lda #2
        sta $D028
        lda #128
        sta $07F8
        sta $07F9
        lda #160
        sta $D000
        sta $D002
        lda #100
        sta $D001
        lda #80
        sta $D003
        lda #0
        sta INVINCIBLE

    LOOP5:

        jsr READ_JOY5
        jsr CHECK_COL5
        jsr UPDATE_INV
        jsr WAIT5
        jmp LOOP5

    READ_JOY5:

        // ...stessa lettura joystick di prima...
        rts

    CHECK_COL5:

        lda INVINCIBLE
        bne CC5_END

        // Controllo collisione player-nemico
        lda $D000
        sec
        sbc $D002
        bcs CC5_P
        eor #$FF
        clc
        adc #1
    CC5_P:

        cmp #24
        bcs CC5_END

        lda $D001
        sec
        sbc $D003
        bcs CC5_P2
        eor #$FF
        clc
        adc #1
    CC5_P2:

        cmp #21
        bcs CC5_END

        // Collisione!
        lda #1
        sta INVINCIBLE
        lda #60
        sta INV_TIMER
        dec $D020         // segnale visivo

    CC5_END:

        rts

    UPDATE_INV:

        lda INVINCIBLE
        beq UI_END
        dec INV_TIMER
        bne UI_END

        lda #0
        sta INVINCIBLE

        // Flash visivo durante invincibilita
        lda $D001
        eor #$01
        sta $D001

    UI_END:

        rts

    WAIT5:

        lda $D012
        cmp #$F8
        bne WAIT5
        rts
}
