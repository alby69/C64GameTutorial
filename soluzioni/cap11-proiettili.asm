; =============================================
; SOLUZIONI Capitolo 11 — Sistema Proiettili
; =============================================

; --- ESERCIZIO 1: pool 2 proiettili, fuoco per sparare ---
BULLET_X    = $10     ; 2 byte (X0, X1)
BULLET_Y    = $12
BULLET_ACT  = $14
JOYPORT     = $DC01

*=$8000
    LDA #%00000111
    STA $D015
    LDA #1
    STA $D027       ; player
    LDA #7
    STA $D028       ; proiettile 0
    STA $D029       ; proiettile 1
    LDA #128
    STA $07F8
    LDA #192
    STA $07F9
    STA $07FA

    LDA #160
    STA $D000       ; player X
    LDA #200
    STA $D001       ; player Y

    LDA #0
    STA BULLET_ACT
    STA BULLET_ACT+1

LOOP1
    JSR READ_JOY1
    JSR SPAWN_BULLET
    JSR UPDATE_BULLETS
    JSR WAIT
    JMP LOOP1

READ_JOY1
    LDA JOYPORT
    AND #1
    BNE RJ1_D
    DEC $D001
RJ1_D
    LDA JOYPORT
    AND #2
    BNE RJ1_L
    INC $D001
RJ1_L
    LDA JOYPORT
    AND #4
    BNE RJ1_R
    DEC $D000
RJ1_R
    LDA JOYPORT
    AND #8
    BNE RJ1_X
    INC $D000
RJ1_X
    RTS

SPAWN_BULLET
    LDA JOYPORT
    AND #16
    BNE SB_END

    ; Trova slot inattivo
    LDA BULLET_ACT
    BEQ SB_SLOT0
    LDA BULLET_ACT+1
    BEQ SB_SLOT1
    JMP SB_END

SB_SLOT0
    LDA #1
    STA BULLET_ACT
    LDA $D000
    STA BULLET_X
    LDA $D001
    SEC
    SBC #10
    STA BULLET_Y
    JMP SB_END

SB_SLOT1
    LDA #1
    STA BULLET_ACT+1
    LDA $D000
    STA BULLET_X+1
    LDA $D001
    SEC
    SBC #10
    STA BULLET_Y+1

SB_END
    RTS

UPDATE_BULLETS
    ; Bull 0
    LDA BULLET_ACT
    BEQ UB_1
    DEC BULLET_Y
    LDA BULLET_Y
    CMP #30
    BCS UB_R0
    LDA #0
    STA BULLET_ACT
UB_R0
    LDA BULLET_X
    STA $D002
    LDA BULLET_Y
    STA $D003

UB_1
    LDA BULLET_ACT+1
    BEQ UB_END
    DEC BULLET_Y+1
    LDA BULLET_Y+1
    CMP #30
    BCS UB_R1
    LDA #0
    STA BULLET_ACT+1
UB_R1
    LDA BULLET_X+1
    STA $D004
    LDA BULLET_Y+1
    STA $D005

UB_END
    RTS

WAIT
    LDA $D012
    CMP #$F8
    BNE WAIT
    RTS

; --- ESERCIZIO 2: cooldown 10 frame tra uno sparo e l'altro ---
COOLDOWN = $06
*=$9000
    ; ...stesso setup...

    LDA #0
    STA COOLDOWN

LOOP2
    JSR READ_JOY2
    JSR SPAWN_BULLET2
    JSR UPDATE_BULLETS2

    LDA COOLDOWN
    BEQ CD_END
    DEC COOLDOWN
CD_END
    JSR WAIT2
    JMP LOOP2

SPAWN_BULLET2
    LDA COOLDOWN
    BNE SB2_END
    LDA JOYPORT
    AND #16
    BNE SB2_END

    LDA BULLET_ACT
    BEQ SB2_S0
    LDA BULLET_ACT+1
    BEQ SB2_S1
    JMP SB2_END

SB2_S0
    LDA #1
    STA BULLET_ACT
    LDA $D000
    STA BULLET_X
    LDA $D001
    SEC
    SBC #10
    STA BULLET_Y
    LDA #10
    STA COOLDOWN
    JMP SB2_END

SB2_S1
    LDA #1
    STA BULLET_ACT+1
    LDA $D000
    STA BULLET_X+1
    LDA $D001
    SEC
    SBC #10
    STA BULLET_Y+1
    LDA #10
    STA COOLDOWN

SB2_END
    RTS

; --- ESERCIZIO 3: proiettile colpisce nemico fisso ---
ENEMY_HP = $20
*=$A000
    ; ...setup + pool 2 proiettili...

    LDA #1
    STA ENEMY_HP
    LDA #100
    STA $D002       ; X nemico
    LDA #80
    STA $D003       ; Y nemico
    LDA #%00001111
    STA $D015

LOOP3
    JSR UPDATE_BULLETS3
    JSR CHECK_HIT
    JSR WAIT3
    JMP LOOP3

CHECK_HIT
    LDA ENEMY_HP
    BEQ CH_END

    LDX #0
CH_LOOP
    LDA BULLET_ACT,X
    BEQ CH_NEXT

    LDA BULLET_X,X
    SEC
    SBC #100
    BCS CH_P
    EOR #$FF
    CLC
    ADC #1
CH_P
    CMP #24
    BCS CH_NEXT

    LDA BULLET_Y,X
    SEC
    SBC #80
    BCS CH_P2
    EOR #$FF
    CLC
    ADC #1
CH_P2
    CMP #21
    BCS CH_NEXT

    ; Colpito!
    LDA #0
    STA BULLET_ACT,X
    STA ENEMY_HP
    LDA $D015
    AND #%11111011
    STA $D015       ; nascondi nemico

CH_NEXT
    INX
    CPX #2
    BNE CH_LOOP

CH_END
    RTS

; --- ESERCIZIO 4: nemico spara proiettile ogni 30 frame ---
ENEMY_B_X  = $22
ENEMY_B_Y  = $23
ENEMY_B_ACT = $24
ENEMY_TIMER = $25
*=$B000
    LDA #%00001111
    STA $D015
    ; ...
    LDA #0
    STA ENEMY_B_ACT
    LDA #30
    STA ENEMY_TIMER

LOOP4
    JSR UPDATE_ENEMY_BULLET
    JSR WAIT4
    JMP LOOP4

UPDATE_ENEMY_BULLET
    LDA ENEMY_B_ACT
    BEQ UEB_SPAWN

    INC ENEMY_B_Y   ; cade verso il basso
    LDA ENEMY_B_Y
    CMP #230
    BCC UEB_R
    LDA #0
    STA ENEMY_B_ACT
UEB_R
    RTS

UEB_SPAWN
    DEC ENEMY_TIMER
    BNE UEB_END

    LDA #1
    STA ENEMY_B_ACT
    LDA #100
    STA ENEMY_B_X
    LDA #80
    STA ENEMY_B_Y
    LDA #30
    STA ENEMY_TIMER

UEB_END
    RTS

; --- ESERCIZIO 5: power-up — raccogli per 6 proiettili ---
POWERUP_X    = $30
POWERUP_Y    = $31
POWERUP_ACT  = $32
BULLET_MAX   = $33   ; 2 o 6
*=$C000
    LDA #0
    STA POWERUP_ACT
    LDA #2
    STA BULLET_MAX

LOOP5
    JSR CHECK_POWERUP
    JSR SPAWN_POWERUP
    JSR WAIT5
    JMP LOOP5

SPAWN_POWERUP
    LDA POWERUP_ACT
    BNE SP_END

    ; Ogni 100 frame spawna power-up
    LDA FRAME_CNT
    AND #$7F        ; ogni 128 frame
    BNE SP_END
    BNE SP_END
    LDA #1
    STA POWERUP_ACT
    LDA #180
    STA POWERUP_X
    LDA #50
    STA POWERUP_Y
SP_END
    RTS

CHECK_POWERUP
    LDA POWERUP_ACT
    BEQ CP_END

    ; Player raccoglie?
    LDA $D000
    SEC
    SBC POWERUP_X
    BCS CP_P
    EOR #$FF
    CLC
    ADC #1
CP_P
    CMP #24
    BCS CP_END

    LDA $D001
    SEC
    SBC POWERUP_Y
    BCS CP_P2
    EOR #$FF
    CLC
    ADC #1
CP_P2
    CMP #21
    BCS CP_END

    ; Raccogli!
    LDA #0
    STA POWERUP_ACT
    LDA #6
    STA BULLET_MAX
    LDA #7         ; effetto visivo
    STA $D020

CP_END
    RTS
