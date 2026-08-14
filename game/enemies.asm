#importonce
// =============================================
// ENEMIES — Wave system, AI, boss
// =============================================

* = $5000

GAME_ENEMIES_INIT:

    lda #1
    sta WAVE_NUM
    sta ENEMIES_PER_WAVE
    lda #60
    sta WAVE_DELAY
    lda #0
    sta BOSS_ACTIVE
    rts

GAME_ENEMIES_UPDATE:

    lda BOSS_ACTIVE
    bne GEU_BOSS

    // Check if wave complete
    lda ENEMIES_LEFT
    bne GEU_MOVE

    // Wave complete: start next wave
    dec WAVE_DELAY
    bne GEU_DONE
    jsr WAVE_START

GEU_MOVE:

    jsr ENEMY_MOVE
    jsr ENEMY_SHOOT
    jmp GEU_DONE

GEU_BOSS:

    jsr BOSS_UPDATE

GEU_DONE:

    rts

WAVE_START:

    lda #60
    sta WAVE_DELAY
    inc WAVE_NUM
    lda WAVE_NUM
    cmp #9
    bne WS_NORMAL
    jmp WS_BOSS

WS_NORMAL:

    // Get wave config
    sec
    sbc #1
    asl
    asl
    asl
    asl
    tax
    lda WAVE_DATA,X
    sta ENEMIES_PER_WAVE
    sta ENEMIES_LEFT
    lda WAVE_DATA+1,X
    sta WAVE_ENEMY_TYPE
    lda WAVE_DATA+2,X
    sta ENEMY_SHOOT_INTERVAL

    // Spawn enemies in formation
    lda #0
    sta ENEMY_TIMER_LO
    lda #60
    sta ENEMY_TIMER_HI
    lda #1
    sta ENEMY_DIR

    ldx #2
    ldy #0
WS_SPAWN:

    lda #1
    sta ENTITY_ACTIVE,X
    lda #T_ENEMY
    sta ENTITY_TYPE,X
    lda WAVE_ENEMY_TYPE
    sta ENTITY_FLAGS,X
    lda FORMATION_X,Y
    sta ENTITY_X,X
    lda FORMATION_Y,Y
    sta ENTITY_Y,X
    lda WAVE_ENEMY_TYPE
    asl
    tay
    lda ENEMY_DATA+1,Y
    sta ENTITY_HP,X

    lda #10
    sta ENTITY_TIMER,X

    inx
    iny
    cpy ENEMIES_PER_WAVE
    bne WS_SPAWN
    rts

WS_BOSS:

    // Boss wave
    lda #1
    sta BOSS_ACTIVE
    lda #1
    sta ENEMIES_LEFT
    lda #BOSS_HP
    sta BOSS_CURRENT_HP

    // Spawn boss in entity slot 2
    lda #1
    sta ENTITY_ACTIVE+2
    lda #T_BOSS
    sta ENTITY_TYPE+2
    lda #160
    sta ENTITY_X+2
    lda #60
    sta ENTITY_Y+2
    lda #BOSS_HP
    sta ENTITY_HP+2
    lda #0
    sta ENTITY_TIMER+2
    lda #1
    sta BOSS_DIR
    rts

// Formation positions (max 14)
FORMATION_X:

.byte 40,80,120,160,200,240,280,40,80,120,160,200,240,280
FORMATION_Y:

.byte 40,40,40,40,40,40,40,70,70,70,70,70,70,70

// Move all enemies
ENEMY_MOVE:

    dec ENEMY_TIMER_LO
    lda ENEMY_TIMER_LO
    cmp #$FF
    bne EM_CONT
    dec ENEMY_TIMER_HI
EM_CONT:

    lda ENEMY_TIMER_HI
    and #$0F
    bne EM_MOVE

    ldx #2
EM_LOOP:

    lda ENTITY_ACTIVE,X
    beq EM_SKIP
    lda ENTITY_TYPE,X
    cmp #T_ENEMY
    bne EM_SKIP

    // Move in formation (side to side + slight descend)
    lda ENEMY_DIR
    beq EM_LEFT
    inc ENTITY_X,X
    jmp EM_CHK
EM_LEFT:

    dec ENTITY_X,X
EM_CHK:

    // Update animation frame
    lda ENTITY_TIMER,X
    beq EM_NEXT
    dec ENTITY_TIMER,X
EM_NEXT:

EM_SKIP:

    inx
    cpx #MAX_ENTITIES
    bne EM_LOOP

    // Change direction at edges
    lda ENTITY_X+1
    cmp #300
    bcs EM_FLIP
    lda ENTITY_X+2
    cmp #20
    bcc EM_FLIP
    jmp EM_MOVE

EM_FLIP:

    lda ENEMY_DIR
    eor #1
    sta ENEMY_DIR

    // Descend formation
    ldx #2
EM_DESCEND:

    lda ENTITY_ACTIVE,X
    beq EM_DSKIP
    lda ENTITY_TYPE,X
    cmp #T_ENEMY
    bne EM_DSKIP
    inc ENTITY_Y,X
EM_DSKIP:

    inx
    cpx #MAX_ENTITIES
    bne EM_DESCEND

EM_MOVE:

    rts

// Enemy shooting
ENEMY_SHOOT:

    dec ENEMY_SHOOT_INTERVAL
    bpl ES_DONE
    lda #30
    sta ENEMY_SHOOT_INTERVAL

    // Find a random active enemy to shoot
    jsr RANDOM
    and #7
    tax
    lda ENTITY_ACTIVE,X
    beq ES_DONE
    lda ENTITY_TYPE,X
    cmp #T_ENEMY
    bne ES_DONE

    // Find free bullet slot
    ldy #0
ES_BSLOT:

    lda EB_ACTIVE,Y
    beq ES_FIRE
    iny
    cpy #MAX_EB
    bne ES_BSLOT
    rts

ES_FIRE:

    lda #1
    sta EB_ACTIVE,Y
    lda ENTITY_X,X
    sta EB_X,Y
    lda ENTITY_Y,X
    clc
    adc #16
    sta EB_Y,Y
ES_DONE:

    rts

// Boss update
BOSS_UPDATE:

    ldx #2
    lda ENTITY_ACTIVE+2
    beq BU_DEAD

    // Movement: side to side
    lda BOSS_DIR
    beq BU_LEFT
    inc ENTITY_X+2
    lda ENTITY_X+2
    cmp #280
    bcc BU_SHOOT
    lda #0
    sta BOSS_DIR
    jmp BU_SHOOT
BU_LEFT:

    dec ENTITY_X+2
    lda ENTITY_X+2
    cmp #40
    bcs BU_SHOOT
    lda #1
    sta BOSS_DIR

BU_SHOOT:

    // Boss shoots every N frames
    lda ENTITY_TIMER+2
    bne BU_DEC
    lda #BOSS_SHOOT_INTERVAL
    sta ENTITY_TIMER+2

    // Fire 2 bullets
    ldy #0
BU_BSLOT:

    lda EB_ACTIVE,Y
    beq BU_FIRE
    iny
    cpy #MAX_EB
    bne BU_BSLOT
    jmp BU_DEC

BU_FIRE:

    lda #1
    sta EB_ACTIVE,Y
    lda ENTITY_X+2
    sta EB_X,Y
    lda ENTITY_Y+2
    clc
    adc #20
    sta EB_Y,Y

    // Shoot second if free slot
    iny
    cpy #MAX_EB
    beq BU_DEC
    lda EB_ACTIVE,Y
    bne BU_DEC
    lda #1
    sta EB_ACTIVE,Y
    lda ENTITY_X+2
    clc
    adc #20
    sta EB_X,Y
    lda ENTITY_Y+2
    clc
    adc #20
    sta EB_Y,Y
    jmp BU_DEC

BU_DEC:

    dec ENTITY_TIMER+2

BU_DEAD:

    rts

// Simple random generator
RANDOM:

    lda RAND_SEED
    beq RAND_INIT
    asl
    bcc RAND_OUT
    eor #$1D
RAND_OUT:

    sta RAND_SEED
    rts
RAND_INIT:

    lda $D012
    sta RAND_SEED
    jmp RANDOM
