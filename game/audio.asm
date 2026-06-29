; =============================================
; AUDIO — SID engine + SFX
; =============================================

* = $1000

; Init SID
ENGINE_AUDIO_INIT
    LDA #$0F
    STA SID_VOL
    LDA #0
    STA SID_V1_CTRL
    STA SID_V2_CTRL
    STA SID_V3_CTRL
    STA SFX_PTR
    RTS

; Called each frame from IRQ
ENGINE_AUDIO_UPDATE
    LDA SFX_TIMER
    BEQ AU_DONE
    DEC SFX_TIMER
    BNE AU_DONE
    ; Timer expired, silence voice
    LDA #0
    STA SID_V1_CTRL
AU_DONE
    RTS

; Shoot sound effect
SFX_SHOOT
    LDA #$80
    STA SID_V1_FREQ_LO
    LDA #$20
    STA SID_V1_FREQ_HI
    LDA #$09
    STA SID_V1_AD
    LDA #$0F
    STA SID_V1_SR
    LDA #$11
    STA SID_V1_CTRL
    LDA #8
    STA SFX_TIMER
    RTS

; Hit sound
SFX_HIT
    LDA #$40
    STA SID_V1_FREQ_LO
    LDA #$10
    STA SID_V1_FREQ_HI
    LDA #$05
    STA SID_V1_AD
    LDA #$0A
    STA SID_V1_SR
    LDA #$81
    STA SID_V1_CTRL
    LDA #4
    STA SFX_TIMER
    RTS

; Explosion sound
SFX_EXPLOSION
    LDA #$FF
    STA SID_V1_FREQ_LO
    LDA #$30
    STA SID_V1_FREQ_HI
    LDA #$0F
    STA SID_V1_AD
    LDA #$F0
    STA SID_V1_SR
    LDA #$41
    STA SID_V1_CTRL
    LDA #15
    STA SFX_TIMER
    RTS

; Player die sound
SFX_DIE
    LDA #$80
    STA SID_V2_FREQ_LO
    LDA #$05
    STA SID_V2_FREQ_HI
    LDA #$0E
    STA SID_V2_AD
    LDA #$FF
    STA SID_V2_SR
    LDA #$81
    STA SID_V2_CTRL
    RTS
