; =============================================
; ENEMIES — Wave system, AI, boss
; =============================================

* = $5000

GAME_ENEMIES_INIT
    LDA #1
    STA WAVE_NUM
    STA ENEMIES_PER_WAVE
    LDA #60
    STA WAVE_DELAY
    LDA #0
    STA BOSS_ACTIVE
    RTS

GAME_ENEMIES_UPDATE
    LDA BOSS_ACTIVE
    BNE GEU_BOSS

    ; Check if wave complete
    LDA ENEMIES_LEFT
    BNE GEU_MOVE

    ; Wave complete: start next wave
    DEC WAVE_DELAY
    BNE GEU_DONE
    JSR WAVE_START

GEU_MOVE
    JSR ENEMY_MOVE
    JSR ENEMY_SHOOT
    JMP GEU_DONE

GEU_BOSS
    JSR BOSS_UPDATE

GEU_DONE
    RTS

WAVE_START
    LDA #60
    STA WAVE_DELAY
    INC WAVE_NUM
    LDA WAVE_NUM
    CMP #9
    BNE WS_NORMAL
    JMP WS_BOSS

WS_NORMAL
    ; Get wave config
    SEC
    SBC #1
    ASL
    ASL
    ASL
    ASL
    TAX
    LDA WAVE_DATA,X
    STA ENEMIES_PER_WAVE
    STA ENEMIES_LEFT
    LDA WAVE_DATA+1,X
    STA WAVE_ENEMY_TYPE
    LDA WAVE_DATA+2,X
    STA ENEMY_SHOOT_INTERVAL

    ; Spawn enemies in formation
    LDA #0
    STA ENEMY_TIMER_LO
    LDA #60
    STA ENEMY_TIMER_HI
    LDA #1
    STA ENEMY_DIR

    LDX #2
    LDY #0
WS_SPAWN
    LDA #1
    STA ENTITY_ACTIVE,X
    LDA #T_ENEMY
    STA ENTITY_TYPE,X
    LDA WAVE_ENEMY_TYPE
    STA ENTITY_FLAGS,X
    LDA FORMATION_X,Y
    STA ENTITY_X,X
    LDA FORMATION_Y,Y
    STA ENTITY_Y,X
    LDA WAVE_ENEMY_TYPE
    ASL
    TAY
    LDA ENEMY_DATA+1,Y
    STA ENTITY_HP,X

    LDA #10
    STA ENTITY_TIMER,X

    INX
    INY
    CPY ENEMIES_PER_WAVE
    BNE WS_SPAWN
    RTS

WS_BOSS
    ; Boss wave
    LDA #1
    STA BOSS_ACTIVE
    LDA #1
    STA ENEMIES_LEFT
    LDA #BOSS_HP
    STA BOSS_CURRENT_HP

    ; Spawn boss in entity slot 2
    LDA #1
    STA ENTITY_ACTIVE+2
    LDA #T_BOSS
    STA ENTITY_TYPE+2
    LDA #160
    STA ENTITY_X+2
    LDA #60
    STA ENTITY_Y+2
    LDA #BOSS_HP
    STA ENTITY_HP+2
    LDA #0
    STA ENTITY_TIMER+2
    LDA #1
    STA BOSS_DIR
    RTS

; Formation positions (max 14)
FORMATION_X
.byte 40,80,120,160,200,240,280,40,80,120,160,200,240,280
FORMATION_Y
.byte 40,40,40,40,40,40,40,70,70,70,70,70,70,70

; Move all enemies
ENEMY_MOVE
    DEC ENEMY_TIMER_LO
    LDA ENEMY_TIMER_LO
    CMP #$FF
    BNE EM_CONT
    DEC ENEMY_TIMER_HI
EM_CONT
    LDA ENEMY_TIMER_HI
    AND #$0F
    BNE EM_MOVE

    LDX #2
EM_LOOP
    LDA ENTITY_ACTIVE,X
    BEQ EM_SKIP
    LDA ENTITY_TYPE,X
    CMP #T_ENEMY
    BNE EM_SKIP

    ; Move in formation (side to side + slight descend)
    LDA ENEMY_DIR
    BEQ EM_LEFT
    INC ENTITY_X,X
    JMP EM_CHK
EM_LEFT
    DEC ENTITY_X,X
EM_CHK
    ; Update animation frame
    LDA ENTITY_TIMER,X
    BEQ EM_NEXT
    DEC ENTITY_TIMER,X
EM_NEXT
EM_SKIP
    INX
    CPX #MAX_ENTITIES
    BNE EM_LOOP

    ; Change direction at edges
    LDA ENTITY_X+1
    CMP #300
    BCS EM_FLIP
    LDA ENTITY_X+2
    CMP #20
    BCC EM_FLIP
    JMP EM_MOVE

EM_FLIP
    LDA ENEMY_DIR
    EOR #1
    STA ENEMY_DIR

    ; Descend formation
    LDX #2
EM_DESCEND
    LDA ENTITY_ACTIVE,X
    BEQ EM_DSKIP
    LDA ENTITY_TYPE,X
    CMP #T_ENEMY
    BNE EM_DSKIP
    INC ENTITY_Y,X
EM_DSKIP
    INX
    CPX #MAX_ENTITIES
    BNE EM_DESCEND

EM_MOVE
    RTS

; Enemy shooting
ENEMY_SHOOT
    DEC ENEMY_SHOOT_INTERVAL
    BPL ES_DONE
    LDA #30
    STA ENEMY_SHOOT_INTERVAL

    ; Find a random active enemy to shoot
    JSR RANDOM
    AND #7
    TAX
    LDA ENTITY_ACTIVE,X
    BEQ ES_DONE
    LDA ENTITY_TYPE,X
    CMP #T_ENEMY
    BNE ES_DONE

    ; Find free bullet slot
    LDY #0
ES_BSLOT
    LDA EB_ACTIVE,Y
    BEQ ES_FIRE
    INY
    CPY #MAX_EB
    BNE ES_BSLOT
    RTS

ES_FIRE
    LDA #1
    STA EB_ACTIVE,Y
    LDA ENTITY_X,X
    STA EB_X,Y
    LDA ENTITY_Y,X
    CLC
    ADC #16
    STA EB_Y,Y
ES_DONE
    RTS

; Boss update
BOSS_UPDATE
    LDX #2
    LDA ENTITY_ACTIVE+2
    BEQ BU_DEAD

    ; Movement: side to side
    LDA BOSS_DIR
    BEQ BU_LEFT
    INC ENTITY_X+2
    LDA ENTITY_X+2
    CMP #280
    BCC BU_SHOOT
    LDA #0
    STA BOSS_DIR
    JMP BU_SHOOT
BU_LEFT
    DEC ENTITY_X+2
    LDA ENTITY_X+2
    CMP #40
    BCS BU_SHOOT
    LDA #1
    STA BOSS_DIR

BU_SHOOT
    ; Boss shoots every N frames
    LDA ENTITY_TIMER+2
    BNE BU_DEC
    LDA #BOSS_SHOOT_INTERVAL
    STA ENTITY_TIMER+2

    ; Fire 2 bullets
    LDY #0
BU_BSLOT
    LDA EB_ACTIVE,Y
    BEQ BU_FIRE
    INY
    CPY #MAX_EB
    BNE BU_BSLOT
    JMP BU_DEC

BU_FIRE
    LDA #1
    STA EB_ACTIVE,Y
    LDA ENTITY_X+2
    STA EB_X,Y
    LDA ENTITY_Y+2
    CLC
    ADC #20
    STA EB_Y,Y

    ; Shoot second if free slot
    INY
    CPY #MAX_EB
    BEQ BU_DEC
    LDA EB_ACTIVE,Y
    BNE BU_DEC
    LDA #1
    STA EB_ACTIVE,Y
    LDA ENTITY_X+2
    CLC
    ADC #20
    STA EB_X,Y
    LDA ENTITY_Y+2
    CLC
    ADC #20
    STA EB_Y,Y
    JMP BU_DEC

BU_DEC
    DEC ENTITY_TIMER+2

BU_DEAD
    RTS

; Simple random generator
RANDOM
    LDA RAND_SEED
    BEQ RAND_INIT
    ASL
    BCC RAND_OUT
    EOR #$1D
RAND_OUT
    STA RAND_SEED
    RTS
RAND_INIT
    LDA $D012
    STA RAND_SEED
    JMP RANDOM
