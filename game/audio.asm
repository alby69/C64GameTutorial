#importonce
// =============================================
// AUDIO — SID engine + SFX
// =============================================

* = $1000

// Init SID
ENGINE_AUDIO_INIT:

    lda #$0F
    sta SID_VOL
    lda #0
    sta SID_V1_CTRL
    sta SID_V2_CTRL
    sta SID_V3_CTRL
    sta SFX_PTR
    rts

// Called each frame from IRQ
ENGINE_AUDIO_UPDATE:

    lda SFX_TIMER
    beq AU_DONE
    dec SFX_TIMER
    bne AU_DONE
    // Timer expired, silence voice
    lda #0
    sta SID_V1_CTRL
AU_DONE:

    rts

// Shoot sound effect
SFX_SHOOT:

    lda #$80
    sta SID_V1_FREQ_LO
    lda #$20
    sta SID_V1_FREQ_HI
    lda #$09
    sta SID_V1_AD
    lda #$0F
    sta SID_V1_SR
    lda #$11
    sta SID_V1_CTRL
    lda #8
    sta SFX_TIMER
    rts

// Hit sound
SFX_HIT:

    lda #$40
    sta SID_V1_FREQ_LO
    lda #$10
    sta SID_V1_FREQ_HI
    lda #$05
    sta SID_V1_AD
    lda #$0A
    sta SID_V1_SR
    lda #$81
    sta SID_V1_CTRL
    lda #4
    sta SFX_TIMER
    rts

// Explosion sound
SFX_EXPLOSION:

    lda #$FF
    sta SID_V1_FREQ_LO
    lda #$30
    sta SID_V1_FREQ_HI
    lda #$0F
    sta SID_V1_AD
    lda #$F0
    sta SID_V1_SR
    lda #$41
    sta SID_V1_CTRL
    lda #15
    sta SFX_TIMER
    rts

// Player die sound
SFX_DIE:

    lda #$80
    sta SID_V2_FREQ_LO
    lda #$05
    sta SID_V2_FREQ_HI
    lda #$0E
    sta SID_V2_AD
    lda #$FF
    sta SID_V2_SR
    lda #$81
    sta SID_V2_CTRL
    rts
