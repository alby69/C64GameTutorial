// =============================================
// CAP23 — Titolo e High Score / Title & High Score
// Difficulty: Tools & Polish
// =============================================
:BasicUpstart2(start)

start:
    jsr drawTitle

!waitFire:
    jsr readJoystick
    lda joyState
    and #%00010000
    beq !waitFire-

    // Inizia gioco
    jsr initGame
    rts

drawTitle:
    jsr clearScreen
    ldx #0
!loop:
    lda titleText, x
    beq !done+
    sta $0400+12*40+10, x
    lda #1
    sta $D800+12*40+10, x
    inx
    jmp !loop-
!done:
    rts

titleText:
    .text "SPACE COMMANDER"
    .byte 0

joyState: .byte 0

readJoystick:
    lda #0
    sta joyState
    rts

initGame:
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
