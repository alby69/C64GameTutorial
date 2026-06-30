; =============================================
; SOLUZIONI Capitolo 10 — Collisioni
; =============================================
;
; Mappa esercizi:
;   1: player + nemico fisso, collisione cambia colore
;   2: collisione distrugge nemico, sparisce
;   3: 3 nemici, collisione singola su ciascuno
;   4: segnapunti collisioni (variabile che si incrementa)
;   5: gestione multi-hit (nemico resiste a 3 colpi)
;
; =============================================
JOYPORT = $DC01
PLAYER_X = $D000
PLAYER_Y = $D001
ENEMY_X  = $D002
ENEMY_Y  = $D003

; --- ESERCIZIO 1: player + nemico fisso, collisione cambia colore ---
*=$8000
    LDA #%00000011
    STA $D015
    LDA #1
    STA $D027           ; player bianco
    LDA #2
    STA $D028           ; nemico rosso
    LDA #128
    STA $07F8
    STA $07F9

    LDA #160
    STA PLAYER_X
    STA ENEMY_X
    LDA #100
    STA PLAYER_Y
    LDA #80
    STA ENEMY_Y

LOOP1
    JSR READ_JOY
    JSR CHECK_COL1
    JSR WAIT
    JMP LOOP1

READ_JOY
    LDA JOYPORT
    AND #1
    BNE RJ_DOWN
    DEC PLAYER_Y
RJ_DOWN
    LDA JOYPORT
    AND #2
    BNE RJ_LEFT
    INC PLAYER_Y
RJ_LEFT
    LDA JOYPORT
    AND #4
    BNE RJ_RIGHT
    DEC PLAYER_X
RJ_RIGHT
    LDA JOYPORT
    AND #8
    BNE RJ_DONE
    INC PLAYER_X
RJ_DONE
    RTS

CHECK_COL1
    LDA PLAYER_X
    SEC
    SBC ENEMY_X
    BCS CC1_POS
    EOR #$FF
    CLC
    ADC #1
CC1_POS
    CMP #24
    BCS CC1_END

    LDA PLAYER_Y
    SEC
    SBC ENEMY_Y
    BCS CC1_POS2
    EOR #$FF
    CLC
    ADC #1
CC1_POS2
    CMP #21
    BCS CC1_END

    ; Collisione!
    LDA $D020
    EOR #$0F
    STA $D020

CC1_END
    RTS

WAIT
    LDA $D012
    CMP #$F8
    BNE WAIT
    RTS

; --- ESERCIZIO 2: registro $D01E collisione sprite 0 e 1 ---
*=$9000
    LDA #%00000011
    STA $D015
    LDA #1
    STA $D027
    LDA #2
    STA $D028
    LDA #128
    STA $07F8
    STA $07F9
    LDA #140
    STA PLAYER_X
    STA ENEMY_X
    LDA #100
    STA PLAYER_Y
    LDA #100
    STA ENEMY_Y

LOOP2
    LDA $D01E          ; collisioni sprite-sprite
    AND #%00000001     ; sprite 0 ha collisione?
    BEQ NO_COL2

    LDA #2
    STA $D020          ; bordo rosso

NO_COL2
    JSR WAIT2
    JMP LOOP2

WAIT2
    LDA $D012
    CMP #$F8
    BNE WAIT2
    RTS

; --- ESERCIZIO 3: 3 nemici fissi, player li disattiva al contatto ---
ENEMY1_ACTIVE = $10
ENEMY2_ACTIVE = $11
ENEMY3_ACTIVE = $12
*=$A000
    LDA #%00001111      ; 4 sprite (player + 3 nemici)
    STA $D015
    LDA #1
    STA $D027
    LDA #2
    STA $D028
    STA $D029
    STA $D02A
    LDA #128
    STA $07F8
    STA $07F9
    STA $07FA
    STA $07FB

    ; Player
    LDA #160
    STA $D000
    LDA #150
    STA $D001

    ; Nemici
    LDA #60
    STA $D002           ; X enemy 0
    LDA #60
    STA $D004           ; X enemy 1
    LDA #220
    STA $D006           ; X enemy 2
    LDA #80
    STA $D003           ; Y enemy 0
    STA $D005           ; Y enemy 1
    STA $D007           ; Y enemy 2

    LDA #1
    STA ENEMY1_ACTIVE
    STA ENEMY2_ACTIVE
    STA ENEMY3_ACTIVE

LOOP3
    JSR READ_JOY3
    JSR CHECK_COL3
    JSR UPDATE_SPR3
    JSR WAIT3
    JMP LOOP3

READ_JOY3
    LDA JOYPORT
    AND #1
    BNE RJ3_DN
    DEC $D001
RJ3_DN
    LDA JOYPORT
    AND #2
    BNE RJ3_LF
    INC $D001
RJ3_LF
    LDA JOYPORT
    AND #4
    BNE RJ3_RT
    DEC $D000
RJ3_RT
    LDA JOYPORT
    AND #8
    BNE RJ3_DN2
    INC $D000
RJ3_DN2
    RTS

CHECK_COL3
    ; Nemico 1
    LDA ENEMY1_ACTIVE
    BEQ CC3_EN2
    JSR CHECK_ENEMY
    CMP #1
    BNE CC3_EN2
    LDA #0
    STA ENEMY1_ACTIVE

CC3_EN2
    LDA ENEMY2_ACTIVE
    BEQ CC3_EN3
    LDA $D004
    STA $02
    LDA $D005
    STA $03
    JSR CHECK_ENEMY2
    CMP #1
    BNE CC3_EN3
    LDA #0
    STA ENEMY2_ACTIVE

CC3_EN3
    LDA ENEMY3_ACTIVE
    BEQ CC3_END
    LDA $D006
    STA $02
    LDA $D007
    STA $03
    JSR CHECK_ENEMY2
    CMP #1
    BNE CC3_END
    LDA #0
    STA ENEMY3_ACTIVE

CC3_END
    RTS

CHECK_ENEMY
    ; Usa $D002, $D003 per enemy 0
    LDA $D000
    SEC
    SBC $D002
    BCS CE_POS
    EOR #$FF
    CLC
    ADC #1
CE_POS
    CMP #24
    BCS CE_NOHIT
    LDA $D001
    SEC
    SBC $D003
    BCS CE_POS2
    EOR #$FF
    CLC
    ADC #1
CE_POS2
    CMP #21
    BCS CE_NOHIT
    LDA #1
    RTS
CE_NOHIT
    LDA #0
    RTS

CHECK_ENEMY2
    LDA $D000
    SEC
    SBC $02
    BCS CE2_P
    EOR #$FF
    CLC
    ADC #1
CE2_P
    CMP #24
    BCS CE2_N
    LDA $D001
    SEC
    SBC $03
    BCS CE2_P2
    EOR #$FF
    CLC
    ADC #1
CE2_P2
    CMP #21
    BCS CE2_N
    LDA #1
    RTS
CE2_N
    LDA #0
    RTS

UPDATE_SPR3
    LDA ENEMY1_ACTIVE
    BNE US3_E1
    LDA $D015
    AND #%11111110
    STA $D015
    JMP US3_E2
US3_E1
    LDA $D015
    ORA #%00000010
    STA $D015
US3_E2
    LDA ENEMY2_ACTIVE
    BNE US3_E3
    LDA $D015
    AND #%11111101
    STA $D015
    JMP US3_E4
US3_E3
    LDA $D015
    ORA #%00000100
    STA $D015
; Continua per nemico 3...
    RTS

WAIT3
    LDA $D012
    CMP #$F8
    BNE WAIT3
    RTS

; --- ESERCIZIO 4: vittoria quando tutti nemici morti ---
; (continua da esercizio 3)
*=$A000
    ; ...stesso setup di es.3...

; Aggiungi dopo UPDATE_SPR3:
CHECK_VICTORY
    LDA ENEMY1_ACTIVE
    ORA ENEMY2_ACTIVE
    ORA ENEMY3_ACTIVE
    BNE CV_END

    ; Tutti morti: mostra VITTORIA
    LDA #22        ; 'V'
    STA $0400+(10*40+15)
    LDA #9         ; 'I'
    STA $0401+(10*40+15)
    LDA #20        ; 'T'
    STA $0402+(10*40+15)
    LDA #20        ; 'T'
    STA $0403+(10*40+15)
    LDA #15        ; 'O'
    STA $0404+(10*40+15)
    LDA #18        ; 'R'
    STA $0405+(10*40+15)
    LDA #9         ; 'I'
    STA $0406+(10*40+15)
    LDA #1         ; 'A'
    STA $0407+(10*40+15)

CV_END
    RTS

; --- ESERCIZIO 5: invincibilita 60 frame post-collisione ---
INVINCIBLE = $20
INV_TIMER  = $21
*=$B000
    LDA #%00000011
    STA $D015
    LDA #1
    STA $D027
    LDA #2
    STA $D028
    LDA #128
    STA $07F8
    STA $07F9
    LDA #160
    STA $D000
    STA $D002
    LDA #100
    STA $D001
    LDA #80
    STA $D003
    LDA #0
    STA INVINCIBLE

LOOP5
    JSR READ_JOY5
    JSR CHECK_COL5
    JSR UPDATE_INV
    JSR WAIT5
    JMP LOOP5

READ_JOY5
    ; ...stessa lettura joystick di prima...
    RTS

CHECK_COL5
    LDA INVINCIBLE
    BNE CC5_END

    ; Controllo collisione player-nemico
    LDA $D000
    SEC
    SBC $D002
    BCS CC5_P
    EOR #$FF
    CLC
    ADC #1
CC5_P
    CMP #24
    BCS CC5_END

    LDA $D001
    SEC
    SBC $D003
    BCS CC5_P2
    EOR #$FF
    CLC
    ADC #1
CC5_P2
    CMP #21
    BCS CC5_END

    ; Collisione!
    LDA #1
    STA INVINCIBLE
    LDA #60
    STA INV_TIMER
    DEC $D020         ; segnale visivo

CC5_END
    RTS

UPDATE_INV
    LDA INVINCIBLE
    BEQ UI_END
    DEC INV_TIMER
    BNE UI_END

    LDA #0
    STA INVINCIBLE

    ; Flash visivo durante invincibilita
    LDA $D001
    EOR #$01
    STA $D001

UI_END
    RTS

WAIT5
    LDA $D012
    CMP #$F8
    BNE WAIT5
    RTS
