; =============================================
; SPRITE — Sprite multiplexing & rendering
; =============================================

* = $0E00

; Map entity slots to HW sprite registers
SPRITE_RENDER
    ; Enable all 8 sprites
    LDA #%11111111
    STA VIC_SPRITE_EN

    ; Set sprite pointers
    LDX #0
SR_LOOP
    LDA ENTITY_ACTIVE,X
    BNE SR_SET_PTR
    ; Inactive: hide sprite
    LDA VIC_SPRITE_EN
    AND SPRITE_BITMASK,X
    STA VIC_SPRITE_EN
    JMP SR_SKIP

SR_SET_PTR
    LDA ENTITY_TYPE,X
    ASL
    TAY
    LDA SPRITE_MAP,Y
    STA TEMP
    ; Write to sprite pointer register
    TXA
    CLC
    ADC #VIC_SPRITE_PTR
    STA PTR_LO
    LDA #0
    STA PTR_HI
    LDA TEMP
    LDY #0
    STA (PTR_LO),Y

    ; Set X position
    LDA ENTITY_X,X
    STA VIC_SPRITE_X,X

    ; Set Y position
    LDA ENTITY_Y,X
    STA VIC_SPRITE_Y,X

    ; Set color based on type
    LDA ENTITY_TYPE,X
    TAY
    LDA SPRITE_COLORS,Y
    STA VIC_SPRITE_COL,X

    ; MSB-X handling for sprites past 255
    LDA #0
    CPX #0
    BEQ SR_NO_MSB
    LDA ENTITY_X,X
    CMP #128
    BCC SR_NO_MSB
    LDA VIC_SPRITE_MSB
    ORA SPRITE_BITMASK,X
    STA VIC_SPRITE_MSB
    JMP SR_SKIP

SR_NO_MSB
    LDA VIC_SPRITE_MSB
    AND SPRITE_NOT_BITMASK,X
    STA VIC_SPRITE_MSB

SR_SKIP
    INX
    CPX #MAX_ENTITIES
    BNE SR_LOOP

    ; Render player bullet separate
    LDA PB_ACTIVE
    BEQ SR_PB_OFF
    LDA #SPR_PTR_BULLET
    STA VIC_SPRITE_PTR+1
    LDA PB_X
    STA VIC_SPRITE_X+1
    LDA PB_Y
    STA VIC_SPRITE_Y+1
    LDA #1
    STA VIC_SPRITE_COL+1
    LDA VIC_SPRITE_EN
    ORA #%00000010
    STA VIC_SPRITE_EN
    JMP SR_PB_DONE

SR_PB_OFF
    LDA VIC_SPRITE_EN
    AND #%11111101
    STA VIC_SPRITE_EN

SR_PB_DONE
    RTS

; Bitmasks for sprite enable/MSB
SPRITE_BITMASK
.byte %00000001,%00000010,%00000100,%00001000
.byte %00010000,%00100000,%01000000,%10000000

SPRITE_NOT_BITMASK
.byte %11111110,%11111101,%11111011,%11110111
.byte %11101111,%11011111,%10111111,%01111111

; Map entity type to sprite pointer
SPRITE_MAP
.byte SPR_PTR_PLAYER  ; T_PLAYER
.byte SPR_PTR_BULLET  ; T_BULLET
.byte SPR_PTR_ENEMY   ; T_ENEMY
.byte SPR_PTR_BOSS    ; T_BOSS
.byte SPR_PTR_EXPLODE1 ; T_EXPLOSION

; Colors per entity type
SPRITE_COLORS
.byte 1   ; player: white
.byte 7   ; bullet: yellow
.byte 5   ; enemy: green
.byte 2   ; boss: red
.byte 10  ; explosion: light red
