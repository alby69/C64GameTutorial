#importonce
// =============================================
// SPRITE — Sprite multiplexing & rendering
// =============================================

* = $0E00

// Map entity slots to HW sprite registers
SPRITE_RENDER:

    // Enable all 8 sprites
    lda #%11111111
    sta VIC_SPRITE_EN

    // Set sprite pointers
    ldx #0
SR_LOOP:

    lda ENTITY_ACTIVE,X
    bne SR_SET_PTR
    // Inactive: hide sprite
    lda VIC_SPRITE_EN
    and SPRITE_BITMASK,X
    sta VIC_SPRITE_EN
    jmp SR_SKIP

SR_SET_PTR:

    lda ENTITY_TYPE,X
    asl
    tay
    lda SPRITE_MAP,Y
    sta TEMP
    // Write to sprite pointer register
    txa
    clc
    adc #VIC_SPRITE_PTR
    sta PTR_LO
    lda #0
    sta PTR_HI
    lda TEMP
    ldy #0
    sta (PTR_LO),Y

    // Set X position
    lda ENTITY_X,X
    sta VIC_SPRITE_X,X

    // Set Y position
    lda ENTITY_Y,X
    sta VIC_SPRITE_Y,X

    // Set color based on type
    lda ENTITY_TYPE,X
    tay
    lda SPRITE_COLORS,Y
    sta VIC_SPRITE_COL,X

    // MSB-X handling for sprites past 255
    lda #0
    cpx #0
    beq SR_NO_MSB
    lda ENTITY_X,X
    cmp #128
    bcc SR_NO_MSB
    lda VIC_SPRITE_MSB
    ora SPRITE_BITMASK,X
    sta VIC_SPRITE_MSB
    jmp SR_SKIP

SR_NO_MSB:

    lda VIC_SPRITE_MSB
    and SPRITE_NOT_BITMASK,X
    sta VIC_SPRITE_MSB

SR_SKIP:

    inx
    cpx #MAX_ENTITIES
    bne SR_LOOP

    // Render player bullet separate
    lda PB_ACTIVE
    beq SR_PB_OFF
    lda #SPR_PTR_BULLET
    sta VIC_SPRITE_PTR+1
    lda PB_X
    sta VIC_SPRITE_X+1
    lda PB_Y
    sta VIC_SPRITE_Y+1
    lda #1
    sta VIC_SPRITE_COL+1
    lda VIC_SPRITE_EN
    ora #%00000010
    sta VIC_SPRITE_EN
    jmp SR_PB_DONE

SR_PB_OFF:

    lda VIC_SPRITE_EN
    and #%11111101
    sta VIC_SPRITE_EN

SR_PB_DONE:

    rts

// Bitmasks for sprite enable/MSB
SPRITE_BITMASK:

.byte %00000001,%00000010,%00000100,%00001000
.byte %00010000,%00100000,%01000000,%10000000

SPRITE_NOT_BITMASK:

.byte %11111110,%11111101,%11111011,%11110111
.byte %11101111,%11011111,%10111111,%01111111

// Map entity type to sprite pointer
SPRITE_MAP:

.byte SPR_PTR_PLAYER  // T_PLAYER
.byte SPR_PTR_BULLET  // T_BULLET
.byte SPR_PTR_ENEMY   // T_ENEMY
.byte SPR_PTR_BOSS    // T_BOSS
.byte SPR_PTR_EXPLODE1 // T_EXPLOSION

// Colors per entity type
SPRITE_COLORS:

.byte 1   // player: white
.byte 7   // bullet: yellow
.byte 5   // enemy: green
.byte 2   // boss: red
.byte 10  // explosion: light red
