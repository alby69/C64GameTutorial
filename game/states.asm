; =============================================
; STATES — State machine: TITLE, PLAY, GAMEOVER
; =============================================

* = $5800

; Game-wide init (called once)
GAME_INIT
    JSR SCREEN_CLEAR
    JSR SCREEN_CLEAR_COLOR
    JSR ENGINE_AUDIO_INIT
    JSR ENTITY_INIT
    JSR GAME_PLAYER_INIT
    JSR GAME_ENEMIES_INIT

    LDA #0
    STA GAME_STATE
    STA SCORE_LO
    STA SCORE_HI

    ; Set background
    LDA #0
    STA VIC_COL_BK
    LDA #$0E
    STA VIC_COL_BORDER

    ; Title screen
    JSR TITLE_INIT
    RTS

; ---- TITLE state ----
TITLE_INIT
    LDA #$0B
    STA VIC_COL_BORDER
    LDA #$06
    STA VIC_COL_BK

    ; Center title text on row 10
    LDX #40*10+8
    LDY #7
    LDA #<STR_TITLE
    STA PTR_LO
    LDA #>STR_TITLE
    STA PTR_HI
    JSR SCREEN_PRINT

    LDA #0
    STA TITLE_BLINK
    RTS

TITLE_UPDATE
    ; Blink "PRESS FIRE" every 30 frames
    INC TITLE_BLINK
    LDA TITLE_BLINK
    CMP #30
    BNE TU_FIRE_CHECK

    LDA #0
    STA TITLE_BLINK
    ; Toggle visibility
    LDA VIC_COL_BORDER
    EOR #$0F
    STA VIC_COL_BORDER

    ; Toggle press fire text
    LDA VIC_COL_BK
    CMP #$06
    BEQ TU_SHOW
    LDA #$06
    STA VIC_COL_BK
    JMP TU_FIRE_CHECK
TU_SHOW
    LDA #$0A
    STA VIC_COL_BK

TU_FIRE_CHECK
    JSR FIRE_PRESSED
    BEQ TU_DONE

    ; Start game
    LDA #1
    STA GAME_STATE
    JSR GAME_START
    RTS

TU_DONE
    RTS

; ---- PLAY state ----
GAME_START
    JSR SCREEN_CLEAR
    JSR SCREEN_CLEAR_COLOR
    JSR ENTITY_INIT
    JSR GAME_PLAYER_INIT
    JSR GAME_ENEMIES_INIT

    LDA #0
    STA SCORE_LO
    STA SCORE_HI
    LDA #$0B
    STA VIC_COL_BORDER
    LDA #0
    STA VIC_COL_BK

    ; Start first wave
    JSR WAVE_START
    RTS

GAME_RENDER
    JSR SPRITE_RENDER
    JSR HUD_DRAW
    RTS

; ---- GAMEOVER state ----
GAMEOVER_UPDATE
    LDA VIC_COL_BORDER
    CMP #2
    BNE GOV_FLASH
    LDA #0
    STA VIC_COL_BORDER
    JMP GOV_INPUT
GOV_FLASH
    INC VIC_COL_BORDER

GOV_INPUT
    JSR FIRE_PRESSED
    BEQ GOV_DONE
    JMP GAME_INIT

GOV_DONE
    RTS

; Game over setup (called from player.asm when lives = 0)
GAME_OVER_SETUP
    JSR SCREEN_CLEAR
    JSR SCREEN_CLEAR_COLOR

    ; Print GAME OVER
    LDX #40*10+12
    LDY #2
    LDA #<STR_GAMEOVER
    STA PTR_LO
    LDA #>STR_GAMEOVER
    STA PTR_HI
    JSR SCREEN_PRINT

    ; Print final score
    LDX #40*12+10
    LDY #5
    LDA #<STR_SCORE
    STA PTR_LO
    LDA #>STR_SCORE
    STA PTR_HI
    JSR SCREEN_PRINT

    LDA SCORE_HI
    JSR HUD_PRINT_HEX
    LDA SCORE_LO
    JSR HUD_PRINT_HEX

    ; Print restart
    LDX #40*16+8
    LDY #1
    LDA #<STR_RESTART
    STA PTR_LO
    LDA #>STR_RESTART
    STA PTR_HI
    JSR SCREEN_PRINT

    LDA #$0B
    STA VIC_COL_BORDER
    LDA #0
    STA VIC_COL_BK
    RTS
