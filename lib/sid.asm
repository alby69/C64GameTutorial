// =============================================
// SID — Utility audio base
// =============================================
#import "constants.asm"

sidReset: {
    lda #0
    ldx #0
!loop:
    sta $D400, x
    inx
    cpx #25
    bcc !loop-
    rts
}
