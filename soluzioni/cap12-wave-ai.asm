; =============================================
; SOLUZIONI Capitolo 12 — Wave System e AI
; =============================================
;
; Mappa esercizi:
;   1: 4 nemici si muovono insieme, rimbalzo bordo
;   2: spawn progressivo ogni 30 frame
;   3: ogni wave aumenta velocita di 1
;   4: nemico spara ogni 40 frame
;   5: 3 pattern di movimento, uno per wave
;
; =============================================
; --- ESERCIZIO 1: 4 nemici si muovono insieme, rimbalzo bordo ---
ENEMY_X     = $10
ENEMY_Y     = $11
ENEMY_DIR   = $12      ; 0=dx, 1=sx
ENEMY_SPEED = $13

*=$C000
    LDA #%00011111      ; player + 4 nemici
    STA $D015
    LDA #1
    STA $D027
    LDA #2
    STA $D028
    STA $D029
    STA $D02A
    STA $D02B
    LDA #128
    STA $07F8
    STA $07F9
    STA $07FA
    STA $07FB
    STA $07FC

    ; Posizioni iniziali
    LDA #160
    STA $D000           ; player
    LDA #200
    STA $D001

    LDA #40
    STA ENEMY_X
    LDA #60
    STA ENEMY_Y
    LDA #0
    STA ENEMY_DIR
    LDA #1
    STA ENEMY_SPEED

LOOP1
    JSR MOVE_GROUP
    JSR UPDATE_ENEMY_POS
    JSR WAIT
    JMP LOOP1

MOVE_GROUP
    LDA ENEMY_DIR
    BEQ MG_RIGHT

MG_LEFT
    LDA ENEMY_X
    SEC
    SBC ENEMY_SPEED
    STA ENEMY_X
    CMP #10
    BCS MG_DONE
    LDA #0
    STA ENEMY_DIR
    LDA ENEMY_Y
    CLC
    ADC #10            ; scendono
    STA ENEMY_Y
    JMP MG_DONE

MG_RIGHT
    LDA ENEMY_X
    CLC
    ADC ENEMY_SPEED
    STA ENEMY_X
    CMP #250
    BCC MG_DONE
    LDA #1
    STA ENEMY_DIR
    LDA ENEMY_Y
    CLC
    ADC #10
    STA ENEMY_Y

MG_DONE
    RTS

UPDATE_ENEMY_POS
    LDA ENEMY_X
    STA $D002
    CLC
    ADC #30
    STA $D004
    CLC
    ADC #30
    STA $D006
    CLC
    ADC #30
    STA $D008

    LDA ENEMY_Y
    STA $D003
    STA $D005
    STA $D007
    STA $D009
    RTS

; --- ESERCIZIO 2: spawn progressivo ogni 30 frame ---
ENEMY_COUNT = $14
SPAWN_TIMER = $15
*=$A000
    LDA #0
    STA ENEMY_COUNT
    STA SPAWN_TIMER

    ; setup sprite...

LOOP2
    JSR SPAWN_PROGRESSIVE
    JSR WAIT2
    JMP LOOP2

SPAWN_PROGRESSIVE
    LDA ENEMY_COUNT
    CMP #8
    BEQ SP_DONE

    DEC SPAWN_TIMER
    BPL SP_DONE

    LDA #30
    STA SPAWN_TIMER

    ; Attiva nuovo nemico
    LDX ENEMY_COUNT
    LDA #1
    STA $D015,X        ; abilita sprite
    LDA #60
    STA $D000,X        ; X = 60 + offset random
    LDA #30
    STA $D001,X        ; Y dall'alto
    LDA #2
    STA $D027,X        ; colore

    INC ENEMY_COUNT

SP_DONE
    RTS

; --- ESERCIZIO 3: ogni wave aumenta velocita di 1 ---
WAVE_NUM  = $20
SPEED     = $21
*=$B000
    LDA #1
    STA SPEED
    STA WAVE_NUM

LOOP3
    JSR CHECK_WAVE_END
    JSR MOVE_GROUP3
    JSR WAIT3
    JMP LOOP3

CHECK_WAVE_END
    ; Se tutti i nemici morti, nuova wave
    LDA ENEMY_COUNT
    BNE CWE_END

    INC WAVE_NUM
    INC SPEED         ; velocita +1

    ; Respawn nemici
    LDA #4
    STA ENEMY_COUNT
    JSR RESET_ENEMIES

CWE_END
    RTS

RESET_ENEMIES
    LDX #0
RE_LOOP
    LDA #1
    STA $D015,X
    INX
    CPX ENEMY_COUNT
    BNE RE_LOOP
    RTS

; --- ESERCIZIO 4: nemico spara ogni 40 frame ---
E_BULLET_X  = $30
E_BULLET_Y  = $31
E_BULLET_ACT = $32
E_SHOOT_TIMER = $33
*=$C000
    LDA #0
    STA E_BULLET_ACT
    LDA #40
    STA E_SHOOT_TIMER

LOOP4
    JSR ENEMY_SHOOT
    JSR UPDATE_E_BULLET
    JSR WAIT4
    JMP LOOP4

ENEMY_SHOOT
    DEC E_SHOOT_TIMER
    BPL ES_END

    LDA #40
    STA E_SHOOT_TIMER

    LDA E_BULLET_ACT
    BNE ES_END

    LDA #1
    STA E_BULLET_ACT
    LDA #100
    STA E_BULLET_X    ; X del nemico
    LDA #80
    STA E_BULLET_Y    ; Y del nemico

ES_END
    RTS

UPDATE_E_BULLET
    LDA E_BULLET_ACT
    BEQ UEB_END

    INC E_BULLET_Y    ; cade verso il basso
    LDA E_BULLET_Y
    CMP #230
    BCC UEB_END

    LDA #0
    STA E_BULLET_ACT

UEB_END
    RTS

; --- ESERCIZIO 5: 3 pattern di movimento, uno per wave ---
PATTERN = $40     ; 0=lineare, 1=zigzag, 2=casuale
*=$D000
    LDA #0
    STA PATTERN

LOOP5
    LDA PATTERN
    CMP #0
    BEQ MOVE_LINEAR
    CMP #1
    BEQ MOVE_ZIGZAG
    JMP MOVE_RANDOM

MOVE_LINEAR
    JSR MOVE_GROUP
    JMP DONE5

MOVE_ZIGZAG
    JSR ZIGZAG_MOVE
    JMP DONE5

MOVE_RANDOM
    JSR RANDOM_MOVE

DONE5
    JSR WAIT5
    JMP LOOP5

ZIGZAG_MOVE
    LDA ENEMY_DIR
    BEQ ZZ_RIGHT

ZZ_LEFT
    DEC ENEMY_X
    LDA ENEMY_X
    CMP #20
    BCS ZZ_ALT_Y
    LDA #0
    STA ENEMY_DIR
    JMP ZZ_ALT_Y

ZZ_RIGHT
    INC ENEMY_X
    LDA ENEMY_X
    CMP #240
    BCC ZZ_ALT_Y
    LDA #1
    STA ENEMY_DIR

ZZ_ALT_Y
    LDA FRAME_CNT
    AND #15
    BNE ZZ_END
    INC ENEMY_Y        ; zigzag: ogni 16 frame scende

ZZ_END
    RTS

RANDOM_MOVE
    LDA $D012
    AND #3
    BEQ RM_UP
    CMP #1
    BEQ RM_DOWN
    CMP #2
    BEQ RM_LEFT
    ; destra
    INC ENEMY_X
    JMP RM_DONE
RM_UP
    DEC ENEMY_Y
    JMP RM_DONE
RM_DOWN
    INC ENEMY_Y
    JMP RM_DONE
RM_LEFT
    DEC ENEMY_X

RM_DONE
    ; clamp bordi
    LDA ENEMY_X
    CMP #10
    BCS RM_C1
    LDA #10
    STA ENEMY_X
RM_C1
    CMP #250
    BCC RM_C2
    LDA #250
    STA ENEMY_X
RM_C2
    LDA ENEMY_Y
    CMP #30
    BCS RM_C3
    LDA #30
    STA ENEMY_Y
RM_C3
    CMP #200
    BCC RM_END
    LDA #200
    STA ENEMY_Y
RM_END
    RTS
