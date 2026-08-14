// =============================================
// CAP26 — REU / REU
// Difficulty: Expert
// =============================================
.const REU_STATUS = $DF00
.const REU_COMMAND = $DF01
.const REU_C64ADR = $DF02
.const REU_REUADR = $DF04
.const REU_LEN = $DF07

:BasicUpstart2(start)

start:
    // Copia 256 byte da $2000 a REU
    lda #$00
    sta REU_C64ADR
    lda #$20
    sta REU_C64ADR+1
    lda #$00
    sta REU_REUADR
    sta REU_REUADR+1
    sta REU_REUADR+2
    lda #$00
    sta REU_LEN
    lda #$01
    sta REU_LEN+1
    lda #$90        // Store C64 -> REU
    sta REU_COMMAND

    // Attendi fine
!wait:
    lda REU_STATUS
    bpl !wait-
    rts
