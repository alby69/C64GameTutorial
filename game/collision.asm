#importonce
// =============================================
// COLLISION — Bounding box collision detection
// =============================================

* = $0F00

ENGINE_COLLISION:

    // Check player bullet vs enemies
    lda PB_ACTIVE
    beq EC_ENEMY_BULLETS
    jsr CHECK_PB_VS_ENEMIES

EC_ENEMY_BULLETS:

    // Check enemy bullets vs player
    jsr CHECK_EB_VS_PLAYER

EC_DONE:

    rts

// Player bullet vs all enemies
CHECK_PB_VS_ENEMIES:

    ldx #0
CPVE_LOOP:

    lda ENTITY_ACTIVE,X
    beq CPVE_SKIP
    lda ENTITY_TYPE,X
    cmp #T_ENEMY
    beq CPVE_TEST
    cmp #T_BOSS
    beq CPVE_TEST
    jmp CPVE_SKIP

CPVE_TEST:

    // Bounding box check
    lda PB_X
    clc
    adc #4
    sta TEMP
    lda ENTITY_X,X
    sec
    sbc #8
    cmp TEMP
    bcs CPVE_SKIP
    lda ENTITY_X,X
    clc
    adc #12
    cmp PB_X
    bcc CPVE_SKIP

    lda PB_Y
    cmp ENTITY_Y,X
    bcc CPVE_SKIP
    lda ENTITY_Y,X
    clc
    adc #16
    cmp PB_Y
    bcc CPVE_SKIP

    // Hit! Deactivate bullet
    lda #0
    sta PB_ACTIVE

    // Damage enemy
    dec ENTITY_HP,X
    lda ENTITY_HP,X
    bne CPVE_HIT

    // Enemy destroyed
    lda #0
    sta ENTITY_ACTIVE,X
    dec ENEMIES_LEFT
    jsr ADD_SCORE
    jsr SFX_EXPLOSION
    jmp CPVE_SKIP

CPVE_HIT:

    jsr SFX_HIT

CPVE_SKIP:

    inx
    cpx #MAX_ENTITIES
    bne CPVE_LOOP
    rts

// Enemy bullets vs player
CHECK_EB_VS_PLAYER:

    lda PLAYER_LIVES
    beq CEV_DONE
    lda ENTITY_FLAGS
    and #1
    bne CEV_DONE        // invincible

    ldx #0
CEV_LOOP:

    lda EB_ACTIVE,X
    beq CEV_SKIP

    // Bounding box
    lda EB_X,X
    clc
    adc #4
    sta TEMP
    lda ENTITY_X
    sec
    sbc #8
    cmp TEMP
    bcs CEV_SKIP
    lda ENTITY_X
    clc
    adc #12
    cmp EB_X,X
    bcc CEV_SKIP

    lda EB_Y,X
    cmp ENTITY_Y
    bcs CEV_SKIP
    lda ENTITY_Y
    sec
    sbc #10
    cmp EB_Y,X
    bcs CEV_SKIP

    // Player hit!
    lda #0
    sta EB_ACTIVE,X
    jsr PLAYER_HIT

CEV_SKIP:

    inx
    cpx #MAX_EB
    bne CEV_LOOP

CEV_DONE:

    rts

ADD_SCORE:

    clc
    lda SCORE_LO
    adc #10
    sta SCORE_LO
    lda SCORE_HI
    adc #0
    sta SCORE_HI
    rts
