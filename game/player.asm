#importonce
// =============================================
// PLAYER — Player ship logic
// =============================================

* = $4000

GAME_PLAYER_INIT:

    lda #1
    sta ENTITY_ACTIVE
    lda #T_PLAYER
    sta ENTITY_TYPE
    lda #160
    sta ENTITY_X
    sta PLAYER_RESPAWN_X
    lda #PLAYER_Y_POS
    sta ENTITY_Y
    lda #MAX_LIVES
    sta PLAYER_LIVES
    lda #0
    sta ENTITY_FLAGS
    sta SHOT_COOLDOWN
    rts

GAME_PLAYER_UPDATE:

    lda PLAYER_LIVES
    beq GPU_DEAD
    lda ENTITY_FLAGS
    and #1
    beq GPU_NORMAL

    // Invincible: decrement timer
    dec ENTITY_TIMER
    lda ENTITY_TIMER
    bmi GPU_INV_END
    // Flash: show/hide every 4 frames
    lda ENTITY_TIMER
    lsr
    lsr
    and #1
    beq GPU_INV_HIDE
    lda VIC_SPRITE_EN
    ora #%00000001
    sta VIC_SPRITE_EN
    jmp GPU_NORMAL

GPU_INV_HIDE:

    lda VIC_SPRITE_EN
    and #%11111110
    sta VIC_SPRITE_EN
    jmp GPU_NORMAL

GPU_INV_END:

    lda #0
    sta ENTITY_FLAGS
    lda VIC_SPRITE_EN
    ora #%00000001
    sta VIC_SPRITE_EN

GPU_NORMAL:

    // Movement
    lda JOY_STATE
    and #%00000100
    beq GPU_RIGHT
    lda ENTITY_X
    cmp #PLAYER_MIN_X
    bcc GPU_RIGHT
    dec ENTITY_X

GPU_RIGHT:

    lda JOY_STATE
    and #%00001000
    beq GPU_FIRE
    lda ENTITY_X
    cmp #PLAYER_MAX_X
    bcs GPU_FIRE
    inc ENTITY_X

GPU_FIRE:

    lda JOY_STATE
    and #%00010000
    beq GPU_DONE
    lda SHOT_COOLDOWN
    bne GPU_DONE
    jsr PLAYER_FIRE

GPU_DONE:

    lda SHOT_COOLDOWN
    beq GPU_SKIP_CD
    dec SHOT_COOLDOWN
GPU_SKIP_CD:

    rts

GPU_DEAD:

    rts

PLAYER_FIRE:

    lda PB_ACTIVE
    bne PF_DONE
    lda #1
    sta PB_ACTIVE
    lda ENTITY_X
    sta PB_X
    lda ENTITY_Y
    sec
    sbc #20
    sta PB_Y
    jsr SFX_SHOOT
    lda #8
    sta SHOT_COOLDOWN
PF_DONE:

    rts

PLAYER_HIT:

    dec PLAYER_LIVES
    lda PLAYER_LIVES
    beq PH_DIED
    // Start invincibility
    lda #1
    sta ENTITY_FLAGS
    lda #INVINCIBLE_TICKS
    sta ENTITY_TIMER
    jsr SFX_DIE
    rts

PH_DIED:

    lda #0
    sta ENTITY_ACTIVE
    jsr SFX_DIE
    jsr GAME_OVER_SETUP
    lda #2
    sta GAME_STATE
    rts

// Bullet update
GAME_BULLETS_UPDATE:

    // Player bullet
    lda PB_ACTIVE
    beq GBU_EB
    lda PB_Y
    sec
    sbc #BULLET_SPEED
    sta PB_Y
    cmp #10
    bcs GBU_EB
    lda #0
    sta PB_ACTIVE

GBU_EB:

    // Enemy bullets
    ldx #0
GBU_LOOP:

    lda EB_ACTIVE,X
    beq GBU_SKIP
    lda EB_Y,X
    clc
    adc #2
    sta EB_Y,X
    cmp #250
    bcc GBU_SKIP
    lda #0
    sta EB_ACTIVE,X
GBU_SKIP:

    inx
    cpx #MAX_EB
    bne GBU_LOOP
    rts
