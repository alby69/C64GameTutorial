; =============================================
; SOLUZIONI Capitolo 18 — Boss System
; =============================================
;
; Mappa esercizi:
;   1: boss 3 fasi: intro + pattern A + morte
;   2: boss si muove dx/sx, spara ogni 30 frame
;   3: fase enrage quando HP < 50%
;   4: animazione morte flash + colore
;   5: boss adatta difficolta in base ai colpi player
;
; =============================================

; --- ESERCIZIO 1: boss 3 fasi: intro + pattern A + morte ---
*=$8000
    LDA #%00000001
    STA $D015
    LDA #7
    STA $D027
    LDA #128
    STA $07F8
    LDA #160
    STA BOSS_X
    LDA #0
    STA BOSS_Y
    LDA #0
    STA BOSS_STATE
    LDA #100
    STA BOSS_HP
    LDA #0
    STA BOSS_DIR

LOOP1
    JSR UPDATE_BOSS1
    JSR RENDER_BOSS1
    JSR WAIT
    JMP LOOP1

UPDATE_BOSS1
    LDA BOSS_STATE
    CMP #0
    BEQ B_INTRO
    CMP #1
    BEQ B_ATTACK
    CMP #2
    BEQ B_DIE

B_INTRO
    LDA BOSS_Y
    CMP #60
    BCS B_I_DONE
    INC BOSS_Y
    RTS

B_I_DONE
    LDA #1
    STA BOSS_STATE
    LDA #0
    STA BOSS_TIMER
    RTS

B_ATTACK
    DEC BOSS_TIMER
    BPL B_A_MOVE
    LDA #20
    STA BOSS_TIMER
    JSR BOSS_SHOOT

B_A_MOVE
    LDA BOSS_DIR
    BEQ B_A_LEFT
    INC BOSS_X
    LDA BOSS_X
    CMP #240
    BCC B_A_END
    LDA #0
    STA BOSS_DIR
    JMP B_A_END

B_A_LEFT
    DEC BOSS_X
    LDA BOSS_X
    CMP #20
    BCS B_A_END
    LDA #1
    STA BOSS_DIR

B_A_END
    LDA BOSS_HP
    BNE B_A_RTS
    LDA #2
    STA BOSS_STATE

B_A_RTS
    RTS

B_DIE
    JSR DEATH_ANIM
    RTS

BOSS_SHOOT
    ; Trova proiettile inattivo
    LDX #0
BS_LOOP
    LDA $10,X
    BEQ BS_FOUND
    INX
    CPX #4
    BNE BS_LOOP
    RTS

BS_FOUND
    LDA #1
    STA $10,X
    LDA BOSS_X
    STA $12,X
    LDA BOSS_Y
    CLC
    ADC #16
    STA $14,X
    RTS

RENDER_BOSS1
    LDA BOSS_X
    STA $D000
    LDA BOSS_Y
    STA $D001
    RTS

DEATH_ANIM
    INC $D020
    LDA FRAME_CNT
    AND #3
    TAX
    LDA DEATH_COLORS,X
    STA $D027
    DEC BOSS_HP
    LDA BOSS_HP
    BEQ B_DEAD
    RTS

B_DEAD
    LDA #0
    STA $D015
    RTS

DEATH_COLORS
    .byte 2, 1, 2, 0

; --- ESERCIZIO 2: boss si muove dx/sx, spara ogni 30 frame ---
*=$9000
    ; Stesso setup base...

LOOP2
    JSR MOVE_BOSS2
    JSR SHOOT_TIMER2
    JSR WAIT2
    JMP LOOP2

MOVE_BOSS2
    LDA BOSS_DIR
    BEQ MB_LEFT

    INC BOSS_X
    LDA BOSS_X
    CMP #240
    BCC MB_END
    LDA #0
    STA BOSS_DIR
    JMP MB_END

MB_LEFT
    DEC BOSS_X
    LDA BOSS_X
    CMP #20
    BCS MB_END
    LDA #1
    STA BOSS_DIR

MB_END
    RTS

SHOOT_TIMER2
    DEC BOSS_TIMER
    BPL ST_END
    LDA #30
    STA BOSS_TIMER
    JSR BOSS_SHOOT

ST_END
    RTS

; --- ESERCIZIO 3: fase enrage quando HP < 50% ---
*=$A000
    ; Stesso setup...

LOOP3
    JSR CHECK_PHASE
    JSR UPDATE_BOSS3
    JSR WAIT3
    JMP LOOP3

CHECK_PHASE
    LDA BOSS_HP
    CMP #50          ; < 50% ?
    BCS CP_END

    LDA BOSS_STATE
    CMP #3           ; gia enrage?
    BEQ CP_END

    LDA #3
    STA BOSS_STATE
    LDA #5
    STA BOSS_TIMER   ; spara ogni 5 frame!

CP_END
    RTS

UPDATE_BOSS3
    LDA BOSS_STATE
    CMP #1
    BEQ B3_NORMAL
    CMP #3
    BEQ B3_ENRAGE
    JMP B3_END

B3_NORMAL
    ; movimento normale
    JSR MOVE_BOSS2
    DEC BOSS_TIMER
    BPL B3_END
    LDA #30
    STA BOSS_TIMER
    JSR BOSS_SHOOT
    JMP B3_END

B3_ENRAGE
    ; movimento + veloce
    LDA BOSS_DIR
    BEQ B3E_LEFT
    INC BOSS_X
    INC BOSS_X        ; 2 pixel!
    LDA BOSS_X
    CMP #240
    BCC B3E_DEC
    LDA #0
    STA BOSS_DIR
    JMP B3E_DEC

B3E_LEFT
    DEC BOSS_X
    DEC BOSS_X
    LDA BOSS_X
    CMP #20
    BCS B3E_DEC
    LDA #1
    STA BOSS_DIR

B3E_DEC
    DEC BOSS_TIMER
    BPL B3_END
    LDA #5
    STA BOSS_TIMER
    JSR BOSS_SHOOT
    JSR BOSS_SHOOT    ; 2 proiettili!

B3_END
    RTS

; --- ESERCIZIO 4: animazione morte flash + colore ---
*=$B000
    ; ...

DEATH_ANIM4
    ; Flash bordo
    INC $D020

    ; Cambia colore sprite
    LDA FRAME_CNT
    AND #7
    TAX
    LDA FLASH_COLORS,X
    STA $D027

    ; Effetto esplosione
    JSR EXPLOSION_SOUND

    DEC BOSS_HP
    LDA BOSS_HP
    BNE DA_END

    LDA #0
    STA $D015       ; nascondi sprite

DA_END
    RTS

FLASH_COLORS
    .byte 2, 1, 2, 1, 2, 0, 2, 1

EXPLOSION_SOUND
    LDA #$00
    STA $D400
    LDA #$20
    STA $D401
    LDA #$81
    STA $D404
    RTS

; --- ESERCIZIO 5: boss adatta difficolta in base ai colpi player ---
PLAYER_HITS   = $58
PLAYER_MISSES = $59
*=$C000
    LDA #0
    STA PLAYER_HITS
    STA PLAYER_MISSES

LOOP5
    JSR ADAPT_BOSS
    JSR UPDATE_BOSS3
    JSR WAIT5
    JMP LOOP5

ADAPT_BOSS
    LDA PLAYER_HITS
    SEC
    SBC PLAYER_MISSES
    BMI PB_BAD

    ; Player bravo: accelera
    LDA BOSS_TIMER
    CMP #5
    BCC ADAPT_DONE
    SEC
    SBC #2
    STA BOSS_TIMER
    RTS

PB_BAD
    ; Player in difficolta: rallenta
    LDA BOSS_TIMER
    CMP #30
    BCS ADAPT_DONE
    CLC
    ADC #2
    STA BOSS_TIMER

ADAPT_DONE
    RTS
