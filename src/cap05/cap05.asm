// =============================================
// CAP05 — Movimento sprite / Sprite Movement
// Difficulty: Beginner-Intermediate
// =============================================
#import "../../lib/input.asm"
#import "../../lib/sprites.asm"

:BasicUpstart2(start)

start:
    jsr clearScreen
    jsr initSprite

gameLoop:
    jsr readJoystick

    // Aggiorna X
    lda joyDirX
    beq !skipX+
    bmi !moveLeft+

    // Move right
    inc spriteX
    jmp !skipX+
!moveLeft:
    dec spriteX
!skipX:

    // Aggiorna Y
    lda joyDirY
    beq !skipY+
    bmi !moveUp+

    // Move down
    inc spriteY
    jmp !skipY+
!moveUp:
    dec spriteY
!skipY:

    // Applica posizione hardware
    lda spriteX
    sta $D000
    lda spriteY
    sta $D001

    // Gestisci X > 255 (bit 0 di $D010)
    lda spriteX+1    // high byte
    beq !clearMSB+
    lda $D010
    ora #%00000001
    sta $D010
    jmp !doneMSB+
!clearMSB:
    lda $D010
    and #%11111110
    sta $D010
!doneMSB:

    jmp gameLoop

initSprite:
    lda #13
    sta $07F8
    lda #7
    sta $D027
    lda #%00000001
    sta $D015
    lda #100
    sta spriteX
    lda #100
    sta spriteY
    rts

clearScreen:
    lda #32
    ldx #0
!loop:
    sta $0400, x
    sta $0500, x
    sta $0600, x
    sta $0700, x
    inx
    bne !loop-
    rts

spriteX: .word 100    // Low + High byte
spriteY: .byte 100

// Dati sprite (stesso blocco 13 a $0340)
* = $0340
spriteData:
    .byte %00111111, %11111111, %11111100
    .byte %01111111, %11111111, %11111110
    .byte %11100000, %00000000, %00000111
    .byte %11000000, %00000000, %00000011
    .byte %11000000, %00000000, %00000011
    .byte %11000000, %00000000, %00000011
    .byte %11000000, %00000000, %00000011
    .byte %11000000, %00000000, %00000011
    .byte %11000111, %00000000, %11100011
    .byte %11000111, %00000000, %11100011
    .byte %11000000, %00000000, %00000011
    .byte %11000000, %00000000, %00000011
    .byte %11001111, %11111111, %11110011
    .byte %11001111, %11111111, %11110011
    .byte %11000000, %00000000, %00000011
    .byte %11000000, %00000000, %00000011
    .byte %11100000, %00000000, %00000111
    .byte %01111111, %11111111, %11111110
    .byte %00111111, %11111111, %11111100
    .byte %00000000, %00000000, %00000000
    .byte %00000000, %00000000, %00000000
