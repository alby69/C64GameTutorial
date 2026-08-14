// =============================================
// CAP09 — Collisioni / Collisions
// Difficulty: Intermediate
// =============================================
#import "../../lib/input.asm"

:BasicUpstart2(start)

start:
    jsr initSprites

gameLoop:
    jsr readJoystick
    jsr movePlayer
    jsr checkCollisions
    jsr delay
    jmp gameLoop

initSprites:
    // Sprite 0 = Player (rosso)
    lda #13
    sta $07F8
    lda #2
    sta $D027
    lda #100
    sta $D000
    lda #100
    sta $D001

    // Sprite 1 = Nemico (blu)
    lda #14
    sta $07F9
    lda #6
    sta $D028
    lda #150
    sta $D002
    lda #100
    sta $D003

    lda #%00000011
    sta $D015
    rts

movePlayer:
    lda joyDirX
    beq !skipX+
    bmi !left+
    inc $D000
    jmp !skipX+
!left:
    dec $D000
!skipX:
    lda joyDirY
    beq !skipY+
    bmi !up+
    inc $D001
    jmp !skipY+
!up:
    dec $D001
!skipY:
    rts

checkCollisions:
    lda $D01E       // Sprite-sprite collision
    and #%00000011  // Bit 0 e 1
    cmp #%00000011
    bne !noHit+

    // Collisione! Lampeggia bordo
    lda #10
    sta $D020
    jsr delay
    lda #0
    sta $D020

!noHit:
    rts

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

// Dati sprite (blocco 13 e 14)
* = $0340
spritePlayer:
    .fill 64, $FF   // Quadrato pieno (semplificato)
* = $0380
spriteEnemy:
    .fill 64, $AA   // Pattern diverso
