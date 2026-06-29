; =============================================
; COLLISION — Bounding box collision detection
; =============================================

* = $0F00

ENGINE_COLLISION
    ; Check player bullet vs enemies
    LDA PB_ACTIVE
    BEQ EC_ENEMY_BULLETS
    JSR CHECK_PB_VS_ENEMIES

EC_ENEMY_BULLETS
    ; Check enemy bullets vs player
    JSR CHECK_EB_VS_PLAYER

EC_DONE
    RTS

; Player bullet vs all enemies
CHECK_PB_VS_ENEMIES
    LDX #0
CPVE_LOOP
    LDA ENTITY_ACTIVE,X
    BEQ CPVE_SKIP
    LDA ENTITY_TYPE,X
    CMP #T_ENEMY
    BEQ CPVE_TEST
    CMP #T_BOSS
    BEQ CPVE_TEST
    JMP CPVE_SKIP

CPVE_TEST
    ; Bounding box check
    LDA PB_X
    CLC
    ADC #4
    STA TEMP
    LDA ENTITY_X,X
    SEC
    SBC #8
    CMP TEMP
    BCS CPVE_SKIP
    LDA ENTITY_X,X
    CLC
    ADC #12
    CMP PB_X
    BCC CPVE_SKIP

    LDA PB_Y
    CMP ENTITY_Y,X
    BCC CPVE_SKIP
    LDA ENTITY_Y,X
    CLC
    ADC #16
    CMP PB_Y
    BCC CPVE_SKIP

    ; Hit! Deactivate bullet
    LDA #0
    STA PB_ACTIVE

    ; Damage enemy
    DEC ENTITY_HP,X
    LDA ENTITY_HP,X
    BNE CPVE_HIT

    ; Enemy destroyed
    LDA #0
    STA ENTITY_ACTIVE,X
    DEC ENEMIES_LEFT
    JSR ADD_SCORE
    JSR SFX_EXPLOSION
    JMP CPVE_SKIP

CPVE_HIT
    JSR SFX_HIT

CPVE_SKIP
    INX
    CPX #MAX_ENTITIES
    BNE CPVE_LOOP
    RTS

; Enemy bullets vs player
CHECK_EB_VS_PLAYER
    LDA PLAYER_LIVES
    BEQ CEV_DONE
    LDA ENTITY_FLAGS
    AND #1
    BNE CEV_DONE        ; invincible

    LDX #0
CEV_LOOP
    LDA EB_ACTIVE,X
    BEQ CEV_SKIP

    ; Bounding box
    LDA EB_X,X
    CLC
    ADC #4
    STA TEMP
    LDA ENTITY_X
    SEC
    SBC #8
    CMP TEMP
    BCS CEV_SKIP
    LDA ENTITY_X
    CLC
    ADC #12
    CMP EB_X,X
    BCC CEV_SKIP

    LDA EB_Y,X
    CMP ENTITY_Y
    BCS CEV_SKIP
    LDA ENTITY_Y
    SEC
    SBC #10
    CMP EB_Y,X
    BCS CEV_SKIP

    ; Player hit!
    LDA #0
    STA EB_ACTIVE,X
    JSR PLAYER_HIT

CEV_SKIP
    INX
    CPX #MAX_EB
    BNE CEV_LOOP

CEV_DONE
    RTS

ADD_SCORE
    CLC
    LDA SCORE_LO
    ADC #10
    STA SCORE_LO
    LDA SCORE_HI
    ADC #0
    STA SCORE_HI
    RTS
