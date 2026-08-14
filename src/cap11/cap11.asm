// =============================================
// CAP11 — Wave System / Wave System
// Difficulty: Intermediate-Advanced
// =============================================
.const MAX_ENTITIES = 8

:BasicUpstart2(start)

start:
    jsr initGame

gameLoop:
    jsr waveUpdate
    jsr updateEntities
    jsr renderEntities
    jsr delay
    jmp gameLoop

initGame:
    lda #0
    sta waveNumber
    sta waveTimer
    lda #100
    sta waveInterval
    jsr initEntities
    rts

waveUpdate:
    dec waveTimer
    bne !checkEnd+

    // Nuova ondata
    inc waveNumber
    lda waveInterval
    sec
    sbc #5          // Ondata successiva più veloce
    cmp #20
    bcs !ok+
    lda #20         // Minimo 20 frame
!ok:
    sta waveInterval
    sta waveTimer

    // Spawn N nemici in base all'ondata
    lda waveNumber
    cmp #MAX_ENTITIES
    bcc !spawn+
    lda #MAX_ENTITIES
!spawn:
    tax
!spawnLoop:
    jsr spawnEnemy
    dex
    bne !spawnLoop-

!checkEnd:
    // Se non ci sono nemici e timer è basso, prepara prossima
    rts

// ----------------------------------
// initEntities — Azzera tutto il pool
// ----------------------------------
initEntities:
    ldx #0
    lda #0
!loop:
    sta entityX, x
    sta entityY, x
    sta entityType, x
    sta entityState, x
    inx
    cpx #MAX_ENTITIES
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
    inx
    cpx #MAX_ENTITIES
    bcc !findLoop-
    rts             // Pool pieno
!found:
    // type = 1 (nemico)
    lda #1
    sta entityType, x
    // x = random-ish
    txa
    asl
    asl
    asl
    clc
    adc #$40
    sta entityX, x
    // y = 30
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
    inx
    cpx #MAX_ENTITIES
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
    inx
    cpx #MAX_ENTITIES
    bcc !loop-
!done:
    // Attiva solo gli sprite usati
    lda spriteMask, y
    sta $D015
    rts

spriteMask:
    .byte %00000000, %00000001, %00000011, %00000111
    .byte %00001111, %00011111, %00111111, %01111111, %11111111

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

* = $2000
entityX:     .fill MAX_ENTITIES, 0
entityY:     .fill MAX_ENTITIES, 0
entityType:  .fill MAX_ENTITIES, 0
entityState: .fill MAX_ENTITIES, 0
waveNumber:  .byte 0
waveTimer:   .byte 0
waveInterval:.byte 0
