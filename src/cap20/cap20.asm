// =============================================
// ARCADE OS — Mini sistema operativo per giochi
// Difficulty: Professional
// =============================================
* = $0C00

:BasicUpstart2(osInit)

// State vectors
gameStates:
    .word stateInit
    .word stateTitle
    .word statePlay
    .word statePause
    .word stateGameOver

currentState: .byte 0

osInit:
    lda #0
    sta currentState
    rts

osUpdate:
    lda currentState
    asl
    tax
    lda gameStates, x
    sta osVector
    lda gameStates+1, x
    sta osVector+1
    jmp (osVector)

osVector: .word 0

stateInit:
    jsr kernelInit
    jsr engineInit
    lda #1
    sta currentState
    rts

stateTitle:
    jsr titleUpdate
    jsr titleRender
    rts

statePlay:
    jsr playUpdate
    jsr playRender
    rts

statePause:
    jsr pauseUpdate
    rts

stateGameOver:
    jsr gameOverUpdate
    jsr gameOverRender
    rts

// ----------------------------------
// Stubs
// ----------------------------------
kernelInit:
    rts
engineInit:
    rts
titleUpdate:
    rts
titleRender:
    rts
playUpdate:
    rts
playRender:
    rts
pauseUpdate:
    rts
gameOverUpdate:
    rts
gameOverRender:
    rts
