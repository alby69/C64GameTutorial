// =============================================
// CAP10 — Entity Pool / Entity Pool System
// Difficulty: Intermediate
// =============================================
.const MAX_ENTITIES = 8
.const ENTITY_SIZE = 4    // x, y, type, state

:BasicUpstart2(start)

start:
    jsr initEntities
    jsr spawnEnemy
    jsr spawnEnemy

gameLoop:
    jsr updateEntities
    jsr renderEntities
    jsr delay
    jmp gameLoop

// ----------------------------------
// initEntities — Azzera tutto il pool
// ----------------------------------
initEntities:
    ldx #0
    lda #0
!loop:
    sta entityPool, x
    inx
    cpx #MAX_ENTITIES * ENTITY_SIZE
    bne !loop-
    rts

// ----------------------------------
// spawnEnemy — Trova slot libero e riempie
// ----------------------------------
spawnEnemy:
    ldx #0
!findLoop:
    lda entityState, x
    beq !found+
    txa
    clc
    adc #ENTITY_SIZE
    tax
    cpx #MAX_ENTITIES * ENTITY_SIZE
    bcc !findLoop-
    rts             // Pool pieno
!found:
    // type = 1 (nemico)
    lda #1
    sta entityType, x
    // x = random
    lda #$50
    sta entityX, x
    // y = random
    lda #$30
    sta entityY, x
    // state = 1 (attivo)
    lda #1
    sta entityState, x
    rts

// ----------------------------------
// updateEntities — Muovi nemici verso il basso
// ----------------------------------
updateEntities:
    ldx #0
!loop:
    lda entityState, x
    beq !next+

    lda entityType, x
    cmp #1
    bne !next+

    // Nemico scende
    inc entityY, x

    // Se esce dallo schermo, disattiva
    lda entityY, x
    cmp #230
    bcc !next+
    lda #0
    sta entityState, x

!next:
    txa
    clc
    adc #ENTITY_SIZE
    tax
    cpx #MAX_ENTITIES * ENTITY_SIZE
    bcc !loop-
    rts

// ----------------------------------
// renderEntities — Sincronizza sprite hardware
// ----------------------------------
renderEntities:
    ldx #0
    ldy #0          // Indice sprite hardware (0-7)
!loop:
    lda entityState, x
    beq !next+

    // Sprite Y
    lda entityY, x
    sta $D001, y
    // Sprite X
    lda entityX, x
    sta $D000, y

    // Colore
    lda #2
    sta $D027, y

    // Puntatore (tutti usano blocco 13)
    lda #13
    sta $07F8, y

    iny
    cpy #8
    beq !done+

!next:
    txa
    clc
    adc #ENTITY_SIZE
    tax
    cpx #MAX_ENTITIES * ENTITY_SIZE
    bcc !loop-
!done:
    // Attiva solo gli sprite usati
    lda spriteMask, y
    sta $D015
    rts

spriteMask:
    .byte %00000000, %00000001, %00000011, %00000111
    .byte %00001111, %00011111, %00111111, %01111111, %11111111

// Pool di entità (8 entità × 4 byte)
* = $2000
entityPool:
entityX:     .fill MAX_ENTITIES, 0
entityY:     .fill MAX_ENTITIES, 0
entityType:  .fill MAX_ENTITIES, 0
entityState: .fill MAX_ENTITIES, 0

delay:
    ldx #100
!loop:
    ldy #100
!inner:
    dey
    bne !inner-
    dex
    bne !loop-
    rts
