; =============================================
; ENTITY — Entity pool system
; =============================================

* = $0D00

; Initialize all entities to inactive
ENTITY_INIT
    LDX #0
    LDA #0
EI_LOOP
    STA ENTITY_ACTIVE,X
    STA ENTITY_HP,X
    STA ENTITY_TIMER,X
    STA ENTITY_FLAGS,X
    INX
    CPX #MAX_ENTITIES
    BNE EI_LOOP

    ; Clear bullet pools
    LDA #0
    STA PB_ACTIVE
    STA EB_COUNT
    LDX #0
EBI_LOOP
    STA EB_ACTIVE,X
    INX
    CPX #MAX_EB
    BNE EBI_LOOP

    LDA #0
    STA BOSS_ACTIVE
    RTS

; Find first inactive entity slot
; Returns: X = slot index, or $FF if full
ENTITY_FIND_SLOT
    LDX #0
EFS_LOOP
    LDA ENTITY_ACTIVE,X
    BEQ EFS_FOUND
    INX
    CPX #MAX_ENTITIES
    BNE EFS_LOOP
    LDX #$FF
EFS_FOUND
    RTS

; Spawn an entity
; A = type, X = slot (from ENTITY_FIND_SLOT)
; Y = X position (caller sets up params before)
ENTITY_SPAWN
    CPX #$FF
    BEQ ESW_DONE
    LDA #1
    STA ENTITY_ACTIVE,X
    LDA TEMP
    STA ENTITY_TYPE,X
    LDA TEMP2
    STA ENTITY_X,X
    LDA TEMP2+1
    STA ENTITY_Y,X
    LDA TEMP2+2
    STA ENTITY_HP,X
ESW_DONE
    RTS

; Update all entities (call appropriate handlers)
ENTITY_UPDATE_ALL
    LDX #0
EUA_LOOP
    LDA ENTITY_ACTIVE,X
    BEQ EUA_NEXT

    LDA ENTITY_TYPE,X
    CMP #T_EXPLOSION
    BEQ EUA_EXPLOSION
    CMP #T_BULLET
    BEQ EUA_BULLET
    JMP EUA_NEXT

EUA_EXPLOSION
    JSR ENTITY_UPDATE_EXPLOSION
    JMP EUA_NEXT

EUA_BULLET
    JSR ENTITY_UPDATE_BULLET

EUA_NEXT
    INX
    CPX #MAX_ENTITIES
    BNE EUA_LOOP
    RTS

; Update explosion entity
ENTITY_UPDATE_EXPLOSION
    DEC ENTITY_TIMER,X
    LDA ENTITY_TIMER,X
    BMI EE_KILL
    LDA ENTITY_TIMER,X
    LSR
    LSR
    CLC
    ADC #SPR_PTR_EXPLODE1
    STA TEMP
    ; Update sprite pointer for this slot
    TXA
    CLC
    ADC #VIC_SPRITE_PTR
    STA PTR_LO
    LDA #0
    STA PTR_HI
    LDA TEMP
    LDY #0
    STA (PTR_LO),Y
    RTS

EE_KILL
    LDA #0
    STA ENTITY_ACTIVE,X
    RTS

; Update bullet entity (enemy bullets)
ENTITY_UPDATE_BULLET
    LDA ENTITY_Y,X
    CLC
    ADC #2
    STA ENTITY_Y,X
    CMP #250
    BCC EUB_ALIVE
    LDA #0
    STA ENTITY_ACTIVE,X
EUB_ALIVE
    RTS
