#importonce
// =============================================
// HIGHSCORE — Save/load high score from disk
// =============================================
// Uses KERNAL routines SETNAM ($FFBD),
// SETLFS ($FFBA), LOAD ($FFD5), SAVE ($FFD8).
//
// High score stored on disk as file "HI"
// with 3 bytes (MSB, byte1, LSB).
//
// Include AFTER screen.asm in the chain.
// =============================================

* = $1400

// Load high score from disk (call at boot/title)
HS_LOAD:

    lda #2
    ldx #<HS_FILENAME
    ldy #>HS_FILENAME
    jsr $FFBD          // SETNAM

    lda #1
    ldx #8
    ldy #0
    jsr $FFBA          // SETLFS (0 = load)

    lda #0
    ldx #<HS_DATA
    ldy #>HS_DATA
    jsr $FFD5          // LOAD

    bcc HSL_OK
    // File not found — init to zero
    lda #0
    sta HS_DATA
    sta HS_DATA+1
    sta HS_DATA+2

HSL_OK:

    rts

// Save high score to disk (call on new record)
HS_SAVE:

    // Scratch existing file first (to avoid SAVE error)
    lda #2
    ldx #<HS_FILENAME
    ldy #>HS_FILENAME
    jsr $FFBD

    lda #1
    ldx #8
    ldy #$0F           // channel 15 (command channel)
    jsr $FFBA
    lda #<HS_SCRATCH_CMD
    ldx #>HS_SCRATCH_CMD
    ldy #$00
    jsr $FFBD
    jsr $FFC0          // OPEN
    jsr $FFC3          // CLOSE

    // Now save
    lda #2
    ldx #<HS_FILENAME
    ldy #>HS_FILENAME
    jsr $FFBD

    lda #1
    ldx #8
    ldy #1             // 1 = save
    jsr $FFBA

    lda #<HS_DATA
    ldx #>HS_DATA
    ldy #$C0
    jsr $FFD8          // SAVE

    rts

// Compare current score vs high score, save if better
// Call when game over
HS_CHECK:

    lda SCORE_HI
    cmp HS_DATA+1
    bcc HSC_OLD
    beq HSC_CHECK_LO
    bcs HSC_NEW

HSC_CHECK_LO:

    lda SCORE_LO
    cmp HS_DATA
    bcc HSC_OLD

HSC_NEW:

    // New record!
    lda SCORE_LO
    sta HS_DATA
    lda SCORE_HI
    sta HS_DATA+1
    lda #0
    sta HS_DATA+2

    jsr HS_SAVE

    // Set flag for display
    lda #1
    sta HS_NEW_FLAG
    rts

HSC_OLD:

    lda #0
    sta HS_NEW_FLAG
    rts

// Print high score on screen at position X (screen offset)
HS_PRINT:

    // "HI: "
    ldy #1
    lda #<HS_LABEL
    sta PTR_LO
    lda #>HS_LABEL
    sta PTR_HI
    jsr SCREEN_PRINT

    // Score digits
    lda HS_DATA+1
    jsr HUD_PRINT_HEX
    lda HS_DATA
    jsr HUD_PRINT_HEX
    rts

// Data
HS_LABEL:

    .text "HI:"
    .byte $FF

HS_FILENAME:

    .text "HI"

HS_SCRATCH_CMD:

    .text "S0:HI"

// ---- Variables ----
HS_DATA:

    .byte 0, 0, 0      // 3-byte high score (LO, HI, unused)

HS_NEW_FLAG:

    .byte 0            // 1 = new record this game
