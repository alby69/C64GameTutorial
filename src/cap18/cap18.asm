// =============================================
// CAP18 — Boss Fight / Boss Fight
// Difficulty: Advanced
// =============================================
:BasicUpstart2(start)

start:
    jsr initBoss

gameLoop:
    jsr updateBoss
    jsr renderBoss
    jsr checkBossDefeat
    jmp gameLoop

initBoss:
    lda #100
    sta bossX
    lda #50
    sta bossY
    lda #50
    sta bossHP
    lda #0
    sta bossPhase
    rts

updateBoss:
    // Movimento a "8" o sinusoidale
    inc bossTimer
    lda bossTimer
    and #$3F
    tax
    lda sineTable, x
    clc
    adc #100
    sta bossX

    // Spara ogni 60 frame
    lda bossTimer
    cmp #60
    bne !noShoot+
    jsr bossShoot
    lda #0
    sta bossTimer
!noShoot:
    rts

renderBoss:
    // Boss usa sprite 0-3 (4 sprite = 48×42 pixel)
    lda bossX
    sta $D000
    sta $D002
    clc
    adc #24
    sta $D004
    sta $D006

    lda bossY
    sta $D001
    sta $D005
    clc
    adc #21
    sta $D003
    sta $D007

    lda #%00001111
    sta $D015
    rts

checkBossDefeat:
    lda bossHP
    bne !alive+
    // Boss sconfitto -> vittoria
    inc $D020
!alive:
    rts

bossShoot:
    // Spawn proiettile nemico
    rts

bossX:     .byte 0
bossY:     .byte 0
bossHP:    .byte 0
bossPhase: .byte 0
bossTimer: .byte 0

sineTable:
    .byte 0, 3, 6, 9, 12, 15, 18, 20, 22, 24
    .byte 25, 24, 22, 20, 18, 15, 12, 9, 6, 3
    .byte 0, 253, 250, 247, 244, 241, 238, 236, 234, 232
    .byte 231, 232, 234, 236, 238, 241, 244, 247, 250, 253
    .byte 0, 3, 6, 9, 12, 15, 18, 20, 22, 24
    .byte 25, 24, 22, 20, 18, 15, 12, 9, 6, 3
