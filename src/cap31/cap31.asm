// =============================================
// CAP31 — ECS in 6502 / ECS in 6502
// Difficulty: Expert
// =============================================
.const MAX_ENTITIES = 32
.const COMP_POS   = %00000001
.const COMP_VEL   = %00000010
.const COMP_SPR   = %00000100
.const COMP_COL   = %00001000

:BasicUpstart2(start)

start:
    jsr updateSystems
    rts

// Struct of Arrays
* = $2000
entityMask:  .fill MAX_ENTITIES, 0
entityPosX:  .fill MAX_ENTITIES, 0
entityPosY:  .fill MAX_ENTITIES, 0
entityVelX:  .fill MAX_ENTITIES, 0
entityVelY:  .fill MAX_ENTITIES, 0
entitySpr:   .fill MAX_ENTITIES, 0
entityCol:   .fill MAX_ENTITIES, 0

updateSystems:
    // Sistema Movimento: solo entità con POS+VEL
    ldx #0
!loop:
    lda entityMask, x
    and #(COMP_POS | COMP_VEL)
    cmp #(COMP_POS | COMP_VEL)
    bne !next+

    lda entityPosX, x
    clc
    adc entityVelX, x
    sta entityPosX, x

    lda entityPosY, x
    clc
    adc entityVelY, x
    sta entityPosY, x

!next:
    inx
    cpx #MAX_ENTITIES
    bcc !loop-
    rts
