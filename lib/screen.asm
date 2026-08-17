// =============================================
// SCREEN — Helper per la gestione schermo
// =============================================
#import "constants.asm"

clearScreen: {
    lda #32           // Spazio
    ldx #0
!loop:
    sta SCREEN_RAM, x
    sta SCREEN_RAM+$0100, x
    sta SCREEN_RAM+$0200, x
    sta SCREEN_RAM+$0300, x
    inx
    bne !loop-
    rts
}
