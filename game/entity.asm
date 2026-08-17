#importonce
// =============================================
// ENTITY — Entity pool system
// =============================================

* = $0D00

// Initialize all entities to inactive
ENTITY_INIT:

    ldx #0
    lda #0
EI_LOOP:

    sta ENTITY_ACTIVE,X
    sta ENTITY_HP,X
    sta ENTITY_TIMER,X
    sta ENTITY_FLAGS,X
    inx
    cpx #MAX_ENTITIES
    bne EI_LOOP

    // Clear bullet pools
    lda #0
    sta PB_ACTIVE
    sta EB_COUNT
    ldx #0
EBI_LOOP:

    sta EB_ACTIVE,X
    inx
    cpx #MAX_EB
    bne EBI_LOOP

    lda #0
    sta BOSS_ACTIVE
    rts

// Find first inactive entity slot
// Returns: X = slot index, or $FF if full
ENTITY_FIND_SLOT:

    ldx #0
EFS_LOOP:

    lda ENTITY_ACTIVE,X
    beq EFS_FOUND
    inx
    cpx #MAX_ENTITIES
    bne EFS_LOOP
    ldx #$FF
EFS_FOUND:

    rts

// Spawn an entity
// A = type, X = slot (from ENTITY_FIND_SLOT)
// Y = X position (caller sets up params before)
ENTITY_SPAWN:

    cpx #$FF
    beq ESW_DONE
    lda #1
    sta ENTITY_ACTIVE,X
    lda TEMP
    sta ENTITY_TYPE,X
    lda TEMP2
    sta ENTITY_X,X
    lda TEMP2+1
    sta ENTITY_Y,X
    lda TEMP2+2
    sta ENTITY_HP,X
ESW_DONE:

    rts

// Update all entities (call appropriate handlers)
ENTITY_UPDATE_ALL:

    ldx #0
EUA_LOOP:

    lda ENTITY_ACTIVE,X
    beq EUA_NEXT

    lda ENTITY_TYPE,X
    cmp #T_EXPLOSION
    beq EUA_EXPLOSION
    cmp #T_BULLET
    beq EUA_BULLET
    jmp EUA_NEXT

EUA_EXPLOSION:

    jsr ENTITY_UPDATE_EXPLOSION
    jmp EUA_NEXT

EUA_BULLET:

    jsr ENTITY_UPDATE_BULLET

EUA_NEXT:

    inx
    cpx #MAX_ENTITIES
    bne EUA_LOOP
    rts

// Update explosion entity
ENTITY_UPDATE_EXPLOSION:

    dec ENTITY_TIMER,X
    lda ENTITY_TIMER,X
    bmi EE_KILL
    lda ENTITY_TIMER,X
    lsr
    lsr
    clc
    adc #SPR_PTR_EXPLODE1
    sta TEMP
    // Update sprite pointer for this slot
    txa
    clc
    adc #VIC_SPRITE_PTR
    sta PTR_LO
    lda #0
    sta PTR_HI
    lda TEMP
    ldy #0
    sta (PTR_LO),Y
    rts

EE_KILL:

    lda #0
    sta ENTITY_ACTIVE,X
    rts

// Update bullet entity (enemy bullets)
ENTITY_UPDATE_BULLET:

    lda ENTITY_Y,X
    clc
    adc #2
    sta ENTITY_Y,X
    cmp #250
    bcc EUB_ALIVE
    lda #0
    sta ENTITY_ACTIVE,X
EUB_ALIVE:

    rts
