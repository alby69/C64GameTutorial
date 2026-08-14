#importonce
// =============================================
// STATES — State machine: TITLE, PLAY, GAMEOVER
// =============================================

* = $5800

// Game-wide init (called once)
GAME_INIT:

    jsr SCREEN_CLEAR
    jsr SCREEN_CLEAR_COLOR
    jsr ENGINE_AUDIO_INIT
    jsr ENTITY_INIT
    jsr GAME_PLAYER_INIT
    jsr GAME_ENEMIES_INIT
    jsr SCROLL_INIT
    jsr HS_LOAD

    lda #0
    sta GAME_STATE
    sta SCORE_LO
    sta SCORE_HI

    // Set background
    lda #0
    sta VIC_COL_BK
    lda #$0E
    sta VIC_COL_BORDER

    // Title screen
    jsr TITLE_INIT
    rts

// ---- TITLE state ----
TITLE_INIT:

    lda #$0B
    sta VIC_COL_BORDER
    lda #$06
    sta VIC_COL_BK

    // Center title text on row 10
    ldx #40*8+8
    ldy #7
    lda #<STR_TITLE
    sta PTR_LO
    lda #>STR_TITLE
    sta PTR_HI
    jsr SCREEN_PRINT

    // "PRESS FIRE TO START"
    ldx #40*12+8
    ldy #1
    lda #<STR_START
    sta PTR_LO
    lda #>STR_START
    sta PTR_HI
    jsr SCREEN_PRINT

    // Show high score on title
    ldx #40*16+8
    jsr HS_PRINT

    lda #0
    sta TITLE_BLINK
    sta HS_NEW_FLAG
    rts

TITLE_UPDATE:

    // Blink every 30 frames
    inc TITLE_BLINK
    lda TITLE_BLINK
    cmp #30
    bne TU_FIRE_CHECK

    lda #0
    sta TITLE_BLINK

    // Toggle "PRESS FIRE" visibility
    ldx #40*12+8
    ldy #1
    lda TITLE_VISIBLE
    eor #1
    sta TITLE_VISIBLE
    beq TU_HIDE
    lda #<STR_START
    sta PTR_LO
    lda #>STR_START
    sta PTR_HI
    jsr SCREEN_PRINT
    jmp TU_FIRE_CHECK
TU_HIDE:

    ldy #10
    lda #<STR_BLANK
    sta PTR_LO
    lda #>STR_BLANK
    sta PTR_HI
    jsr SCREEN_PRINT

TU_FIRE_CHECK:

    jsr FIRE_PRESSED
    beq TU_DONE

    // Start game
    lda #1
    sta GAME_STATE
    jsr GAME_START
    rts

TU_DONE:

    rts

STR_BLANK:

    .text "                "
    .byte $FF

// ---- PLAY state ----
GAME_START:

    jsr SCREEN_CLEAR
    jsr SCREEN_CLEAR_COLOR
    jsr ENTITY_INIT
    jsr GAME_PLAYER_INIT
    jsr GAME_ENEMIES_INIT
    jsr SCROLL_INIT

    lda #0
    sta SCORE_LO
    sta SCORE_HI
    lda #$0B
    sta VIC_COL_BORDER
    lda #0
    sta VIC_COL_BK

    // Draw initial starfield
    jsr SCROLL_DRAW_STARS

    // Start first wave
    jsr WAVE_START
    rts

GAME_RENDER:

    jsr SPRITE_RENDER
    jsr SCROLL_UPDATE
    jsr HUD_DRAW
    rts

// ---- GAMEOVER state ----
GAMEOVER_UPDATE:

    lda VIC_COL_BORDER
    cmp #2
    bne GOV_FLASH
    lda #0
    sta VIC_COL_BORDER
    jmp GOV_INPUT
GOV_FLASH:

    inc VIC_COL_BORDER

GOV_INPUT:

    jsr FIRE_PRESSED
    beq GOV_DONE
    jmp GAME_INIT

GOV_DONE:

    rts

// Game over setup (called from player.asm when lives = 0)
GAME_OVER_SETUP:

    jsr SCREEN_CLEAR
    jsr SCREEN_CLEAR_COLOR

    // Check/save high score first
    jsr HS_CHECK

    // Print GAME OVER
    ldx #40*8+12
    ldy #2
    lda #<STR_GAMEOVER
    sta PTR_LO
    lda #>STR_GAMEOVER
    sta PTR_HI
    jsr SCREEN_PRINT

    // Print final score
    ldx #40*10+8
    ldy #5
    lda #<STR_SCORE
    sta PTR_LO
    lda #>STR_SCORE
    sta PTR_HI
    jsr SCREEN_PRINT

    lda SCORE_HI
    jsr HUD_PRINT_HEX
    lda SCORE_LO
    jsr HUD_PRINT_HEX

    // Print high score
    ldx #40*12+8
    jsr HS_PRINT

    // Show new record message if applicable
    lda HS_NEW_FLAG
    beq GOVS_RESTART

    ldx #40*14+10
    ldy #7
    lda #<STR_NEWREC
    sta PTR_LO
    lda #>STR_NEWREC
    sta PTR_HI
    jsr SCREEN_PRINT

GOVS_RESTART:

    // Print restart
    ldx #40*18+8
    ldy #1
    lda #<STR_RESTART
    sta PTR_LO
    lda #>STR_RESTART
    sta PTR_HI
    jsr SCREEN_PRINT

    lda #$0B
    sta VIC_COL_BORDER
    lda #0
    sta VIC_COL_BK
    rts

STR_NEWREC:

    .text "NEW RECORD!"
    .byte $FF
