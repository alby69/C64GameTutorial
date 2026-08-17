#importonce
// =============================================
// INPUT — Lettura Joystick Port 2
// =============================================
// Uso: JSR readJoystick
// Output: A = bitmask (bit 0=up,1=down,2=left,3=right,4=fire)
//         X = direzione orizzontale (-1,0,1)
//         Y = direzione verticale (-1,0,1)
// =============================================
#import "constants.asm"

readJoystick: {
    lda CIA1_PRB          // Legge porta 2
    eor #$FF              // Inverte logica (1 = premuto)
    sta joyState

    // Direzione orizzontale
    ldx #0
    lda joyState
    and #%00000100        // Left
    beq !checkRight+
    ldx #$FF              // -1
    jmp !doneH+
!checkRight:
    lda joyState
    and #%00001000        // Right
    beq !doneH+
    ldx #$01              // +1
!doneH:
    stx joyDirX

    // Direzione verticale
    ldy #0
    lda joyState
    and #%00000001        // Up
    beq !checkDown+
    ldy #$FF              // -1
    jmp !doneV+
!checkDown:
    lda joyState
    and #%00000010        // Down
    beq !doneV+
    ldy #$01              // +1
!doneV:
    sty joyDirY

    rts
}

joyState:  .byte 0
joyDirX:   .byte 0
joyDirY:   .byte 0
