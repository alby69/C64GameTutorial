; =============================================
; SOLUZIONI Capitolo 9 — Joystick
; =============================================
;
; Mappa esercizi:
;   1: muovi sprite in 4 direzioni
;   2: controllo bordi (player non esce)
;   3: fuoco cambia colore sprite
;   4: single shot (edge detection)
;   5: porta 1 e porta 2 per 2 sprite
;
; =============================================
; --- ESERCIZIO 1: muovi sprite in 4 direzioni ---
*=$C000
    LDA #%00000001
    STA $D015
    LDA #1
    STA $D027
    LDA #128
    STA $07F8

    LDA #160
    STA SPR_X
    LDA #100
    STA SPR_Y

LOOP1
    LDA JOYPORT
    STA $02         ; salva stato

    AND #1          ; bit 0 = su
    BNE CHECK_DOWN
    DEC SPR_Y

CHECK_DOWN
    LDA $02
    AND #2          ; bit 1 = giu
    BNE CHECK_LEFT
    INC SPR_Y

CHECK_LEFT
    LDA $02
    AND #4          ; bit 2 = sinistra
    BNE CHECK_RIGHT
    DEC SPR_X

CHECK_RIGHT
    LDA $02
    AND #8          ; bit 3 = destra
    BNE DONE1
    INC SPR_X

DONE1
    JSR WAIT
    JMP LOOP1

WAIT
    LDA $D012
    CMP #$F8
    BNE WAIT
    RTS

; --- ESERCIZIO 2: controllo bordi (player non esce) ---
*=$9000
    LDA #%00000001
    STA $D015
    LDA #1
    STA $D027
    LDA #128
    STA $07F8
    LDA #160
    STA SPR_X
    LDA #100
    STA SPR_Y

LOOP2
    LDA JOYPORT
    STA $02

    AND #1
    BNE CD2
    LDA SPR_Y
    CMP #50
    BCC CD2
    DEC SPR_Y

CD2
    LDA $02
    AND #2
    BNE CL2
    LDA SPR_Y
    CMP #200
    BCS CL2
    INC SPR_Y

CL2
    LDA $02
    AND #4
    BNE CR2
    LDA SPR_X
    CMP #24
    BCC CR2
    DEC SPR_X

CR2
    LDA $02
    AND #8
    BNE DONE2
    LDA SPR_X
    CMP #250
    BCS DONE2
    INC SPR_X

DONE2
    JSR WAIT2
    JMP LOOP2

WAIT2
    LDA $D012
    CMP #$F8
    BNE WAIT2
    RTS

; --- ESERCIZIO 3: fuoco cambia colore sprite ---
SPR_COL = $D027
*=$A000
    LDA #%00000001
    STA $D015
    LDA #1
    STA SPR_COL
    LDA #128
    STA $07F8
    LDA #160
    STA SPR_X
    LDA #100
    STA SPR_Y

LOOP3
    LDA JOYPORT
    AND #16         ; bit 4 = fuoco
    BNE NO_FIRE

    INC SPR_COL
    LDA SPR_COL
    AND #$0F
    STA SPR_COL

NO_FIRE
    JSR WAIT3
    JMP LOOP3

WAIT3
    LDA $D012
    CMP #$F8
    BNE WAIT3
    RTS

; --- ESERCIZIO 4: single shot (edge detection) ---
OLD_FIRE = $04
*=$B000
    LDA #%00000001
    STA $D015
    LDA #1
    STA $D027
    LDA #128
    STA $07F8
    LDA #1
    STA OLD_FIRE      ; vecchio stato = non premuto

LOOP4
    LDA JOYPORT
    AND #16
    STA $03           ; stato attuale

    CMP OLD_FIRE
    BEQ SAME

    ; Cambiamento di stato
    LDA $03
    BNE RELEASED      ; 1 = rilasciato

    ; Premuto ora
    LDA $D020
    INC
    STA $D020

RELEASED
    LDA $03
    STA OLD_FIRE

SAME
    JSR WAIT4
    JMP LOOP4

WAIT4
    LDA $D012
    CMP #$F8
    BNE WAIT4
    RTS

; --- ESERCIZIO 5: porta 1 e porta 2 per 2 sprite ---
PORT1 = $DC01
PORT2 = $DC00
SPR0_X = $D000
SPR0_Y = $D001
SPR1_X = $D002
SPR1_Y = $D003
*=$C000
    LDA #%00000011
    STA $D015
    LDA #1
    STA $D027       ; sprite 0 bianco
    LDA #2
    STA $D028       ; sprite 1 rosso
    LDA #128
    STA $07F8
    STA $07F9
    LDA #100
    STA SPR0_X
    STA SPR1_X
    LDA #100
    STA SPR0_Y
    STA SPR1_Y

LOOP5
    ; Sprite 0 ← porta 1
    LDA PORT1
    STA $02
    AND #1
    BNE P1_DOWN
    DEC SPR0_Y
P1_DOWN
    LDA $02
    AND #2
    BNE P1_LEFT
    INC SPR0_Y
P1_LEFT
    LDA $02
    AND #4
    BNE P1_RIGHT
    DEC SPR0_X
P1_RIGHT
    LDA $02
    AND #8
    BNE P1_DONE
    INC SPR0_X
P1_DONE

    ; Sprite 1 ← porta 2
    LDA PORT2
    STA $03
    AND #1
    BNE P2_DOWN
    DEC SPR1_Y
P2_DOWN
    LDA $03
    AND #2
    BNE P2_LEFT
    INC SPR1_Y
P2_LEFT
    LDA $03
    AND #4
    BNE P2_RIGHT
    DEC SPR1_X
P2_RIGHT
    LDA $03
    AND #8
    BNE P5_DONE
    INC SPR1_X

P5_DONE
    JSR WAIT5
    JMP LOOP5

WAIT5
    LDA $D012
    CMP #$F8
    BNE WAIT5
    RTS
