; =============================================
; SCROLL — Parallax scrolling starfield
; =============================================
; Adds a 2-layer scrolling starfield behind gameplay:
;   - Layer 1: slow stars (scroll every 4 frames)
;   - Layer 2: fast stars (scroll every 2 frames)
; Uses $D016 fine scroll + screen RAM shift.
;
; Include AFTER screen.asm in the chain.
; =============================================

* = $1300

; Init scroll system
SCROLL_INIT
    LDA #0
    STA SCROLL_FINE_X
    STA SCROLL_COARSE_X
    STA SCROLL_TICK
    RTS

; Update both scroll layers (call from PLAY phase)
SCROLL_UPDATE
    INC SCROLL_TICK

    ; Layer 1: slow scroll every 4 frames
    LDA SCROLL_TICK
    AND #3
    BNE SU_LAYER2

    JSR SCROLL_STARS_SLOW

SU_LAYER2
    ; Layer 2: fast scroll every 2 frames
    LDA SCROLL_TICK
    AND #1
    BNE SU_APPLY

    JSR SCROLL_STARS_FAST

SU_APPLY
    ; Fine scroll
    INC SCROLL_FINE_X
    LDA SCROLL_FINE_X
    AND #7
    STA SCROLL_FINE_X
    BNE SU_DONE

    ; Coarse shift every 8 pixels
    INC SCROLL_COARSE_X
    LDA SCROLL_COARSE_X
    AND #$1F
    STA SCROLL_COARSE_X

SU_DONE
    ; Apply fine scroll to VIC
    LDA SCROLL_FINE_X
    ORA #%11001000
    STA VIC_CTRL2
    RTS

; Shift slow star layer (bottom rows)
SCROLL_STARS_SLOW
    LDX #0
SSS_LOOP
    LDA SCREEN_RAM+40*20+1,X
    STA SCREEN_RAM+40*20,X
    LDA COLOR_RAM+40*20+1,X
    STA COLOR_RAM+40*20,X
    INX
    CPX #39
    BNE SSS_LOOP

    ; New star on right edge (random-ish)
    LDA SCROLL_COARSE_X
    AND #3
    TAY
    LDA STAR_CHARS,Y
    STA SCREEN_RAM+40*20+39

    LDA #$0B
    STA COLOR_RAM+40*20+39
    RTS

; Shift fast star layer (middle rows)
SCROLL_STARS_FAST
    LDX #0
SSF_LOOP
    LDA SCREEN_RAM+40*15+1,X
    STA SCREEN_RAM+40*15,X
    LDA COLOR_RAM+40*15+1,X
    STA COLOR_RAM+40*15,X
    INX
    CPX #39
    BNE SSF_LOOP

    LDA SCROLL_COARSE_X
    AND #1
    TAY
    LDA STAR_CHARS+4,Y
    STA SCREEN_RAM+40*15+39
    LDA #1
    STA COLOR_RAM+40*15+39
    RTS

; Draw initial starfield
SCROLL_DRAW_STARS
    LDX #0
SDS_LOOP
    ; Slow layer
    TXA
    AND #7
    TAY
    LDA STAR_CHARS,Y
    STA SCREEN_RAM+40*20,X

    TXA
    AND #$1F
    CMP #$10
    ROL
    AND #1
    TAY
    LDA STAR_CHARS+4,Y
    STA SCREEN_RAM+40*15,X

    INX
    CPX #40
    BNE SDS_LOOP
    RTS

; Star characters (PETSCII dots and small shapes)
STAR_CHARS
    .byte $20, $2E, $20, $2A    ; layer 1: space, dot, space, star
    .byte $2E, $2A               ; layer 2: dot, star

; ---- Zero-page variables (defined in config.asm) ----
; SCROLL_FINE_X, SCROLL_COARSE_X, SCROLL_TICK
