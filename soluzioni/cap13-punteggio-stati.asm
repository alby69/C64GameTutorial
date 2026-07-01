; =============================================
; SOLUZIONI Capitolo 13 — Punteggio e Stati
; =============================================
;
; Mappa esercizi:
;   1: punteggio +10 a ogni pressione fuoco
;   2: converti e mostra punteggio 3 cifre
;   3: state machine MENU → PLAY → GAME OVER → MENU
;   4: 3 vite, game over a 0
;   5: mostra WAVE 1/2/... tra le wave
;
; =============================================
; --- ESERCIZIO 1: punteggio +10 a ogni pressione fuoco ---
SCORE      = $02     ; 2 byte
SCORE_HI   = $03
JOYPORT    = $DC01
OLD_FIRE   = $04

*=$C000
    LDA #0
    STA SCORE
    STA SCORE_HI
    LDA #1
    STA OLD_FIRE

LOOP1
    LDA JOYPORT
    AND #16
    STA $05

    CMP OLD_FIRE
    BEQ SAME1

    LDA $05
    BNE SAME1

    ; Fuoco premuto (edge)
    LDA SCORE
    CLC
    ADC #10
    STA SCORE
    LDA SCORE_HI
    ADC #0
    STA SCORE_HI

SAME1
    LDA $05
    STA OLD_FIRE

    JSR WAIT
    JMP LOOP1

WAIT
    LDA $D012
    CMP #$F8
    BNE WAIT
    RTS

; --- ESERCIZIO 2: converti e mostra punteggio 3 cifre ---
SCORE_DISPLAY = $0400+(24*40+30)  ; angolo in basso a destra
*=$9000
    LDA #0
    STA SCORE
    STA SCORE_HI

LOOP2
    JSR UPDATE_SCORE_DISPLAY
    JSR WAIT2
    JMP LOOP2

UPDATE_SCORE_DISPLAY
    ; Converte SCORE in 3 cifre decimali
    LDX #0
    STX $06          ; centinaia
    STX $07          ; decine
    STX $08          ; unita

    LDA SCORE
    LDX #0

USD_HUNDREDS
    CMP #100
    BCC USD_TENS
    SEC
    SBC #100
    INC $06
    JMP USD_HUNDREDS

USD_TENS
    CMP #10
    BCC USD_UNITS
    SEC
    SBC #10
    INC $07
    JMP USD_TENS

USD_UNITS
    STA $08

    ; Mostra a schermo
    LDA $06
    CLC
    ADC #48          ; PETSCII '0'
    STA SCORE_DISPLAY
    LDA $07
    CLC
    ADC #48
    STA SCORE_DISPLAY+1
    LDA $08
    CLC
    ADC #48
    STA SCORE_DISPLAY+2

    RTS

; --- ESERCIZIO 3: state machine MENU → PLAY → GAME OVER → MENU ---
GAME_STATE = $10     ; 0=MENU, 1=PLAY, 2=GAME OVER
*=$A000
    LDA #0
    STA GAME_STATE
    JSR SHOW_MENU

LOOP3
    LDA GAME_STATE
    CMP #0
    BEQ STATE_MENU
    CMP #1
    BEQ STATE_PLAY
    JMP STATE_GAMEOVER

STATE_MENU
    LDA JOYPORT
    AND #16
    BNE SM_END

    LDA #1
    STA GAME_STATE
    JSR INIT_PLAY
    JMP SM_END

STATE_PLAY
    JSR GAME_UPDATE
    LDA PLAYER_LIVES
    BEQ GO_TO_GAMEOVER
    JMP SP_END

GO_TO_GAMEOVER
    LDA #2
    STA GAME_STATE
    JSR SHOW_GAMEOVER
    JMP SP_END

STATE_GAMEOVER
    LDA JOYPORT
    AND #16
    BNE SG_END

    LDA #0
    STA GAME_STATE
    JSR SHOW_MENU

SP_END
SG_END
SM_END
    JSR WAIT3
    JMP LOOP3

; --- ESERCIZIO 4: 3 vite, game over a 0 ---
PLAYER_LIVES = $11
*=$B000
    LDA #3
    STA PLAYER_LIVES
    ; ...

HIT_PLAYER
    LDA INVINCIBLE
    BNE HP_END

    DEC PLAYER_LIVES
    LDA #1
    STA INVINCIBLE
    LDA #60
    STA INV_TIMER

    LDA PLAYER_LIVES
    BNE HP_END

    ; Game over
    LDA #2
    STA GAME_STATE
    JSR SHOW_GAMEOVER

HP_END
    RTS

SHOW_GAMEOVER
    LDA #7       ; 'G'
    STA $0400+(12*40+15)
    LDA #1       ; 'A'
    STA $0400+(12*40+16)
    LDA #13      ; 'M'
    STA $0400+(12*40+17)
    LDA #5       ; 'E'
    STA $0400+(12*40+18)
    LDA #32      ; spazio
    STA $0400+(12*40+19)
    LDA #15      ; 'O'
    STA $0400+(12*40+20)
    LDA #22      ; 'V'
    STA $0400+(12*40+21)
    LDA #5       ; 'E'
    STA $0400+(12*40+22)
    LDA #18      ; 'R'
    STA $0400+(12*40+23)
    RTS

SHOW_MENU
    LDA #13      ; 'M'
    STA $0400+(10*40+12)
    LDA #5       ; 'E'
    STA $0400+(10*40+13)
    LDA #14      ; 'N'
    STA $0400+(10*40+14)
    LDA #21      ; 'U'
    STA $0400+(10*40+15)
    LDA #32      ; spazio
    STA $0400+(10*40+16)
    ; "FIRE TO START"
    LDA #6       ; 'F'
    STA $0400+(12*40+12)
    LDA #9       ; 'I'
    STA $0400+(12*40+13)
    LDA #18      ; 'R'
    STA $0400+(12*40+14)
    LDA #5       ; 'E'
    STA $0400+(12*40+15)
    LDA #32
    STA $0400+(12*40+16)
    LDA #20      ; 'T'
    STA $0400+(12*40+17)
    LDA #15      ; 'O'
    STA $0400+(12*40+18)
    LDA #32
    STA $0400+(12*40+19)
    LDA #19      ; 'S'
    STA $0400+(12*40+20)
    LDA #20      ; 'T'
    STA $0400+(12*40+21)
    LDA #1       ; 'A'
    STA $0400+(12*40+22)
    LDA #18      ; 'R'
    STA $0400+(12*40+23)
    LDA #20      ; 'T'
    STA $0400+(12*40+24)
    RTS

; --- ESERCIZIO 5: mostra WAVE 1/2/... tra le wave ---
WAVE_INDEX = $20
WAVE_DISPLAY_TIMER = $21
*=$C000
    LDA #1
    STA WAVE_INDEX

LOOP5
    LDA GAME_STATE
    CMP #1
    BNE LOOP5

    ; Al cambio wave
    LDA WAVE_DISPLAY_TIMER
    BNE WD_DEC

    ; Mostra "WAVE X"
    LDA #23      ; 'W'
    STA $0400+(10*40+15)
    LDA #1       ; 'A'
    STA $0400+(10*40+16)
    LDA #22      ; 'V'
    STA $0400+(10*40+17)
    LDA #5       ; 'E'
    STA $0400+(10*40+18)
    LDA #32      ; spazio
    STA $0400+(10*40+19)

    LDA WAVE_INDEX
    CLC
    ADC #48      ; PETSCII '0'
    STA $0400+(10*40+20)

    LDA #50
    STA WAVE_DISPLAY_TIMER

    JMP WD_END

WD_DEC
    DEC WAVE_DISPLAY_TIMER

WD_END
    JSR WAIT5
    JMP LOOP5

WAIT2
WAIT3
WAIT5
    LDA $D012
    CMP #$F8
    BNE WAIT2
    RTS
