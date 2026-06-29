; =============================================
; HIGHSCORE — Save/load high score from disk
; =============================================
; Uses KERNAL routines SETNAM ($FFBD),
; SETLFS ($FFBA), LOAD ($FFD5), SAVE ($FFD8).
;
; High score stored on disk as file "HI"
; with 3 bytes (MSB, byte1, LSB).
;
; Include AFTER screen.asm in the chain.
; =============================================

* = $1400

; Load high score from disk (call at boot/title)
HS_LOAD
    LDA #2
    LDX #<HS_FILENAME
    LDY #>HS_FILENAME
    JSR $FFBD          ; SETNAM

    LDA #1
    LDX #8
    LDY #0
    JSR $FFBA          ; SETLFS (0 = load)

    LDA #0
    LDX #<HS_DATA
    LDY #>HS_DATA
    JSR $FFD5          ; LOAD

    BCC HSL_OK
    ; File not found — init to zero
    LDA #0
    STA HS_DATA
    STA HS_DATA+1
    STA HS_DATA+2

HSL_OK
    RTS

; Save high score to disk (call on new record)
HS_SAVE
    ; Scratch existing file first (to avoid SAVE error)
    LDA #2
    LDX #<HS_FILENAME
    LDY #>HS_FILENAME
    JSR $FFBD

    LDA #1
    LDX #8
    LDY #$0F           ; channel 15 (command channel)
    JSR $FFBA
    LDA #<HS_SCRATCH_CMD
    LDX #>HS_SCRATCH_CMD
    LDY #$00
    JSR $FFBD
    JSR $FFC0          ; OPEN
    JSR $FFC3          ; CLOSE

    ; Now save
    LDA #2
    LDX #<HS_FILENAME
    LDY #>HS_FILENAME
    JSR $FFBD

    LDA #1
    LDX #8
    LDY #1             ; 1 = save
    JSR $FFBA

    LDA #<HS_DATA
    LDX #>HS_DATA
    LDY #$C0
    JSR $FFD8          ; SAVE

    RTS

; Compare current score vs high score, save if better
; Call when game over
HS_CHECK
    LDA SCORE_HI
    CMP HS_DATA+1
    BCC HSC_OLD
    BEQ HSC_CHECK_LO
    BCS HSC_NEW

HSC_CHECK_LO
    LDA SCORE_LO
    CMP HS_DATA
    BCC HSC_OLD

HSC_NEW
    ; New record!
    LDA SCORE_LO
    STA HS_DATA
    LDA SCORE_HI
    STA HS_DATA+1
    LDA #0
    STA HS_DATA+2

    JSR HS_SAVE

    ; Set flag for display
    LDA #1
    STA HS_NEW_FLAG
    RTS

HSC_OLD
    LDA #0
    STA HS_NEW_FLAG
    RTS

; Print high score on screen at position X (screen offset)
HS_PRINT
    ; "HI: "
    LDY #1
    LDA #<HS_LABEL
    STA PTR_LO
    LDA #>HS_LABEL
    STA PTR_HI
    JSR SCREEN_PRINT

    ; Score digits
    LDA HS_DATA+1
    JSR HUD_PRINT_HEX
    LDA HS_DATA
    JSR HUD_PRINT_HEX
    RTS

; Data
HS_LABEL
    .byte "HI:",$FF

HS_FILENAME
    .text "HI"

HS_SCRATCH_CMD
    .text "S0:HI"

; ---- Variables ----
HS_DATA
    .byte 0, 0, 0      ; 3-byte high score (LO, HI, unused)

HS_NEW_FLAG
    .byte 0            ; 1 = new record this game
