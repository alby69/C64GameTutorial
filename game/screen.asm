; =============================================
; SCREEN — HUD, text, screen utilities
; =============================================

* = $1100

; Clear screen (fill with space)
SCREEN_CLEAR
    LDX #0
    LDA #$20
SCL_LOOP
    STA SCREEN_RAM,X
    STA SCREEN_RAM+250,X
    STA SCREEN_RAM+500,X
    STA SCREEN_RAM+750,X
    INX
    CPX #250
    BNE SCL_LOOP
    RTS

; Clear color RAM (set to white)
SCREEN_CLEAR_COLOR
    LDX #0
    LDA #1
SCC_LOOP
    STA COLOR_RAM,X
    STA COLOR_RAM+250,X
    STA COLOR_RAM+500,X
    STA COLOR_RAM+750,X
    INX
    CPX #250
    BNE SCC_LOOP
    RTS

; Print string at (X = screen offset, Y = color)
; String pointed by PTR_LO/PTR_HI, terminated by $FF
SCREEN_PRINT
    STY TEMP2
    LDY #0
SPL_LOOP
    LDA (PTR_LO),Y
    CMP #$FF
    BEQ SPL_DONE
    STA SCREEN_RAM,X
    LDA TEMP2
    STA COLOR_RAM,X
    INX
    INY
    JMP SPL_LOOP
SPL_DONE
    RTS

; Draw HUD (score, lives, wave)
HUD_DRAW
    ; Score label
    LDX #1
    LDY #1
    LDA #<STR_SCORE
    STA PTR_LO
    LDA #>STR_SCORE
    STA PTR_HI
    JSR SCREEN_PRINT

    ; Score digits
    LDA SCORE_HI
    JSR HUD_PRINT_HEX
    LDA SCORE_LO
    JSR HUD_PRINT_HEX

    ; Lives
    LDX #25
    LDY #1
    LDA #<STR_LIVES
    STA PTR_LO
    LDA #>STR_LIVES
    STA PTR_HI
    JSR SCREEN_PRINT

    LDA PLAYER_LIVES
    CLC
    ADC #$30
    STA SCREEN_RAM+27

    ; Wave
    LDX #33
    LDY #1
    LDA #<STR_WAVE
    STA PTR_LO
    LDA #>STR_WAVE
    STA PTR_HI
    JSR SCREEN_PRINT

    LDA WAVE_NUM
    CLC
    ADC #$30
    STA SCREEN_RAM+37

    ; Top border line
    LDA #$40
    STA SCREEN_RAM+39
    STA SCREEN_RAM+38
    STA SCREEN_RAM+0

    RTS

HUD_PRINT_HEX
    PHA
    LSR
    LSR
    LSR
    LSR
    CLC
    ADC #$30
    CMP #$3A
    BCC HPH_OK
    ADC #6
HPH_OK
    STA SCREEN_RAM,X
    INX
    PLA
    AND #$0F
    CLC
    ADC #$30
    CMP #$3A
    BCC HPH_OK2
    ADC #6
HPH_OK2
    STA SCREEN_RAM,X
    INX
    RTS

STR_SCORE
.byte "SCORE:",$FF

STR_LIVES
.byte "LIVES:",$FF

STR_WAVE
.byte "WAVE:",$FF

STR_TITLE
.byte "  SPACE COMMANDER",$FF

STR_START
.byte "PRESS FIRE TO START",$FF

STR_GAMEOVER
.byte "    GAME OVER",$FF

STR_RESTART
.byte "PRESS FIRE TO RESTART",$FF

STR_WAVE_LABEL
.byte "WAVE ",$FF
