// =============================================
// CAP12 — State Machine / State Machine
// Difficulty: Intermediate
// =============================================
.const STATE_TITLE    = 0
.const STATE_PLAY     = 1
.const STATE_GAMEOVER = 2

:BasicUpstart2(start)

start:
    lda #STATE_TITLE
    sta gameState

mainLoop:
    lda gameState
    asl
    tax
    lda stateTable, x
    sta jumpPtr
    lda stateTable+1, x
    sta jumpPtr+1
    jmp (jumpPtr)

// ----------------------------------
// Jump Table
// ----------------------------------
stateTable:
    .word stateTitle
    .word statePlay
    .word stateGameOver

// ----------------------------------
// stateTitle
// ----------------------------------
stateTitle:
    jsr drawTitle
    jsr readJoystick
    lda joyState
    and #%00010000    // Fire
    beq !stay+
    lda #STATE_PLAY
    sta gameState
    jsr initPlay
!stay:
    jmp mainLoop

// ----------------------------------
// statePlay
// ----------------------------------
statePlay:
    jsr updatePlay
    jsr checkGameOver
    jmp mainLoop

// ----------------------------------
// stateGameOver
// ----------------------------------
stateGameOver:
    jsr drawGameOver
    jsr readJoystick
    lda joyState
    and #%00010000
    beq !stay+
    lda #STATE_TITLE
    sta gameState
!stay:
    jmp mainLoop

gameState: .byte 0
jumpPtr:   .word 0
joyState:  .byte 0

// ----------------------------------
// Stubs
// ----------------------------------
drawTitle:
    rts

readJoystick:
    lda #0
    sta joyState
    rts

initPlay:
    rts

updatePlay:
    rts

checkGameOver:
    rts

drawGameOver:
    rts
