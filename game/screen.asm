#importonce
// =============================================
// SCREEN — HUD, text, screen utilities
// =============================================

* = $1100

// Clear screen (fill with space)
SCREEN_CLEAR:

    ldx #0
    lda #$20
SCL_LOOP:

    sta SCREEN_RAM,X
    sta SCREEN_RAM+250,X
    sta SCREEN_RAM+500,X
    sta SCREEN_RAM+750,X
    inx
    cpx #250
    bne SCL_LOOP
    rts

// Clear color RAM (set to white)
SCREEN_CLEAR_COLOR:

    ldx #0
    lda #1
SCC_LOOP:

    sta COLOR_RAM,X
    sta COLOR_RAM+250,X
    sta COLOR_RAM+500,X
    sta COLOR_RAM+750,X
    inx
    cpx #250
    bne SCC_LOOP
    rts

// Print string at (X = screen offset, Y = color)
// String pointed by PTR_LO/PTR_HI, terminated by $FF
SCREEN_PRINT:

    sty TEMP2
    ldy #0
SPL_LOOP:

    lda (PTR_LO),Y
    cmp #$FF
    beq SPL_DONE
    sta SCREEN_RAM,X
    lda TEMP2
    sta COLOR_RAM,X
    inx
    iny
    jmp SPL_LOOP
SPL_DONE:

    rts

// Draw HUD (score, lives, wave)
HUD_DRAW:

    // Score label
    ldx #1
    ldy #1
    lda #<STR_SCORE
    sta PTR_LO
    lda #>STR_SCORE
    sta PTR_HI
    jsr SCREEN_PRINT

    // Score digits
    lda SCORE_HI
    jsr HUD_PRINT_HEX
    lda SCORE_LO
    jsr HUD_PRINT_HEX

    // Lives
    ldx #25
    ldy #1
    lda #<STR_LIVES
    sta PTR_LO
    lda #>STR_LIVES
    sta PTR_HI
    jsr SCREEN_PRINT

    lda PLAYER_LIVES
    clc
    adc #$30
    sta SCREEN_RAM+27

    // Wave
    ldx #33
    ldy #1
    lda #<STR_WAVE
    sta PTR_LO
    lda #>STR_WAVE
    sta PTR_HI
    jsr SCREEN_PRINT

    lda WAVE_NUM
    clc
    adc #$30
    sta SCREEN_RAM+37

    // Top border line
    lda #$40
    sta SCREEN_RAM+39
    sta SCREEN_RAM+38
    sta SCREEN_RAM+0

    rts

HUD_PRINT_HEX:

    pha
    lsr
    lsr
    lsr
    lsr
    clc
    adc #$30
    cmp #$3A
    bcc HPH_OK
    adc #6
HPH_OK:

    sta SCREEN_RAM,X
    inx
    pla
    and #$0F
    clc
    adc #$30
    cmp #$3A
    bcc HPH_OK2
    adc #6
HPH_OK2:

    sta SCREEN_RAM,X
    inx
    rts

STR_SCORE:

.text "SCORE:"
.byte $FF

STR_LIVES:

.text "LIVES:"
.byte $FF

STR_WAVE:

.text "WAVE:"
.byte $FF

STR_TITLE:

.text "  SPACE COMMANDER"
.byte $FF

STR_START:

.text "PRESS FIRE TO START"
.byte $FF

STR_GAMEOVER:

.text "    GAME OVER"
.byte $FF

STR_RESTART:

.text "PRESS FIRE TO RESTART"
.byte $FF

STR_WAVE_LABEL:

.text "WAVE "
.byte $FF
