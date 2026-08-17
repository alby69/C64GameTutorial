// Converted to Kick Assembler syntax
.segmentdef Ex1 [start=$c000]
.segmentdef Ex2 [start=$c000]
.segmentdef Ex3 [start=$c000]
.segmentdef Ex4 [start=$c000]
.segmentdef Ex5 [start=$c000]

// --- Shared Constants ---
.const MULTIPLEX_3ZONES = Ex3.MULTIPLEX_3ZONES
.const ZONE1_END = 120
.const ZONE2_END = 240
.const IRQ_VECTOR = $0314
.const ENEMY_X = $100    // 16 byte
.const ENEMY_Y = $110
.const ENEMY_ACT = $120
.const LOGICAL_CNT = 16
.const HW_SPRITES = 8
.const LOGICAL_CNT3 = 24
.const ZONE_SIZE = 80   // 0-79, 80-159, 160-239

// =============================================
// SOLUZIONI Capitolo 16 — Sprite Multiplexing
// --- METADATA ---
// chapter: 16
// title: Sprite Multiplexing
// difficulty: advanced
// --- END METADATA ---
// =============================================
//
// Mappa esercizi:
//   1: 2 zone (0-120, 121-240), 4 sprite per zona
//   2: 16 nemici logici, 8 per zona
//   3: 3 zone, 8 nemici cad (24 totali)
//   4: assegnazione dinamica (nemici piu vicini alla zona)
//   5: misura tempo multiplexing con barra debug ($D020)
//
// =============================================
// --- ESERCIZIO 1: 2 zone (0-120, 121-240), 4 sprite per zona ---
.segment Ex1
.namespace Ex1 {

    // *=$C000
        sei
        lda #$7F
        sta $DC0D

        lda #<IRQ_BOTTOM
        sta IRQ_VECTOR
        lda #>IRQ_BOTTOM
        sta IRQ_VECTOR+1

        lda #ZONE1_END
        sta $D012
        lda $D011
        and #$7F
        sta $D011
        lda #1
        sta $D01A
        cli
        jmp MAIN

    MAIN:

        jmp MAIN

    // IRQ fondo schermo: prepara zona 1
    IRQ_BOTTOM:

        pha
        txa
        pha
        tya
        pha

        // Assegna sprite 0-3 a zona 1, sprite 4-7 a zona 2
        lda #$0F
        sta $D015            // tutti off in zona 1
        // Mettere logica...

        pla
        tay
        pla
        tax
        pla

        lda #<IRQ_TOP
        sta IRQ_VECTOR
        lda #>IRQ_TOP
        sta IRQ_VECTOR+1
        lda #ZONE2_END
        sta $D012

        lda $D019
        sta $D019
        jmp $EA31

    IRQ_TOP:

        pha
        txa
        pha
        tya
        pha

        // Prepara zona 2

        pla
        tay
        pla
        tax
        pla

        lda #<IRQ_BOTTOM
        sta IRQ_VECTOR
        lda #>IRQ_BOTTOM
        sta IRQ_VECTOR+1
        lda #ZONE1_END
        sta $D012

        lda $D019
        sta $D019
        jmp $EA31

}

// --- ESERCIZIO 2: 16 nemici logici, 8 per zona ---
.segment Ex2
.namespace Ex2 {
    // Array nemici

    // *=$9000
        // Inizializza 16 nemici
        ldx #0
    INIT_E2:

        txa
        asl
        asl
        asl
        clc
        adc #20
        sta ENEMY_X,X
        txa
        asl
        asl
        clc
        adc #30
        sta ENEMY_Y,X
        lda #1
        sta ENEMY_ACT,X
        inx
        cpx #LOGICAL_CNT
        bne INIT_E2
        jmp MAIN2

    MAIN2:

        jmp MAIN2

    MULTIPLEX_2ZONES:

        // Zona 1 (Y < 120): assegna primi 8
        // Zona 2 (Y >= 120): assegna secondi 8
        ldx #0
        ldy #0
    M2_Z1:

        lda ENEMY_ACT,X
        beq M2_NEXT1

        lda ENEMY_Y,X
        cmp #ZONE1_END
        bcs M2_NEXT1

        // Assegna a sprite HW Y
        lda ENEMY_X,X
        sta $D000,Y
        lda ENEMY_Y,X
        sta $D001,Y
        tya
        lsr
        tax
        lda #1
        sta $D015,X
        iny
        iny
        cpy #HW_SPRITES*2
        beq M2_Z2

    M2_NEXT1:

        inx
        cpx #LOGICAL_CNT
        bne M2_Z1

        // Zona 2 (Y >= 120)
    M2_Z2:

        ldy #0
    M2_Z2_LOOP:

        lda ENEMY_ACT,X
        beq M2_NEXT2

        lda ENEMY_Y,X
        cmp #ZONE1_END
        bcc M2_NEXT2

        // Assegna a sprite HW Y (offset 0-7)
        lda ENEMY_X,X
        sta $D000,Y
        lda ENEMY_Y,X
        sta $D001,Y
        lda #1
        sta $D015,Y
        iny
        iny
        cpy #HW_SPRITES*2
        beq M2_DONE

    M2_NEXT2:

        inx
        cpx #LOGICAL_CNT
        bne M2_Z2_LOOP

    M2_DONE:

        rts

}

// --- ESERCIZIO 3: 3 zone, 8 nemici cad (24 totali) ---
.segment Ex3
.namespace Ex3 {
    // *=$A000
        // ...setup 24 nemici...

    MULTIPLEX_3ZONES:

        ldx #0
        ldy #0

    ZONE1:

        lda ENEMY_ACT,X
        beq Z1_NEXT
        lda ENEMY_Y,X
        cmp #ZONE_SIZE
        bcs Z1_NEXT
        lda ENEMY_X,X
        sta $D000,Y
        lda ENEMY_Y,X
        sta $D001,Y
        lda #1
        sta $D015,Y
        iny
        iny
        cpy #8
        beq Z2_START
    Z1_NEXT:

        inx
        cpx #LOGICAL_CNT3
        bne ZONE1

    Z2_START:

        ldy #0
    ZONE2:

        lda ENEMY_ACT,X
        beq Z2_NEXT
        lda ENEMY_Y,X
        cmp #ZONE_SIZE*2
        bcs Z2_NEXT
        lda ENEMY_Y,X
        cmp #ZONE_SIZE
        bcc Z2_NEXT
        lda ENEMY_X,X
        sta $D000,Y
        lda ENEMY_Y,X
        sta $D001,Y
        lda #1
        sta $D015,Y
        iny
        iny
        cpy #8
        beq Z3_START
    Z2_NEXT:

        inx
        cpx #LOGICAL_CNT3
        bne ZONE2

    Z3_START:

        ldy #0
    ZONE3:

        lda ENEMY_ACT,X
        beq Z3_NEXT
        lda ENEMY_Y,X
        cmp #ZONE_SIZE*2
        bcc Z3_NEXT
        lda ENEMY_X,X
        sta $D000,Y
        lda ENEMY_Y,X
        sta $D001,Y
        lda #1
        sta $D015,Y
        iny
        iny
        cpy #8
        beq M3_DONE
    Z3_NEXT:

        inx
        cpx #LOGICAL_CNT3
        bne ZONE3

    M3_DONE:

        rts

}

// --- ESERCIZIO 4: assegnazione dinamica (nemici piu vicini alla zona) ---
.segment Ex4
.namespace Ex4 {
    // Invece di dividere per indice, dividi per Y
    DYNAMIC_MUX:

        // Trova i nemici con Y piu vicino alla zona corrente
        // Ordina per Y, assegna 8 alla volta
        ldx #0
        ldy #0
        sty $02        // zone counter
    DM_ZONE:

        ldx #0
        ldy #0
    DM_SCAN:

        lda ENEMY_ACT,X
        beq DM_SKIP

        lda ENEMY_Y,X
        sec
        sbc $02         // distanza da questa zona
        bcs DM_POS
        eor #$FF
        clc
        adc #1
    DM_POS:

        cmp #ZONE_SIZE
        bcs DM_SKIP

        // Assegna a sprite Y
        lda ENEMY_X,X
        sta $D000,Y
        lda ENEMY_Y,X
        sta $D001,Y
        lda #1
        sta $D015,Y
        iny
        iny
        cpy #8
        beq DM_NEXT_ZONE

    DM_SKIP:

        inx
        cpx #LOGICAL_CNT3
        bne DM_SCAN

    DM_NEXT_ZONE:

        lda $02
        clc
        adc #ZONE_SIZE
        sta $02
        cmp #240
        bcc DM_ZONE
        rts

}

// --- ESERCIZIO 5: misura tempo multiplexing con barra debug ($D020) ---
.segment Ex5
.namespace Ex5 {
    // *=$C000
        sei
        lda #$7F
        sta $DC0D
        lda #<IRQ_DEBUG
        sta $0314
        lda #>IRQ_DEBUG
        sta $0315
        lda #200
        sta $D012
        lda $D011
        and #$7F
        sta $D011
        lda #1
        sta $D01A
        cli
        jmp MAIN5

    MAIN5:

        jmp MAIN5

    IRQ_DEBUG:

        pha
        txa
        pha
        tya
        pha

        lda #2
        sta $D020         // barra rossa = inizio multiplex

        jsr MULTIPLEX_3ZONES

        lda #0
        sta $D020         // barra nera = fine

        pla
        tay
        pla
        tax
        pla

        lda $D019
        sta $D019
        jmp $EA31
}
