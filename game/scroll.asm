#importonce
// =============================================
// SCROLL — Parallax scrolling starfield
// =============================================
// Adds a 2-layer scrolling starfield behind gameplay:
//   - Layer 1: slow stars (scroll every 4 frames)
//   - Layer 2: fast stars (scroll every 2 frames)
// Uses $D016 fine scroll + screen RAM shift.
//
// Include AFTER screen.asm in the chain.
// =============================================

* = $1300

// Init scroll system
SCROLL_INIT:

    lda #0
    sta SCROLL_FINE_X
    sta SCROLL_COARSE_X
    sta SCROLL_TICK
    rts

// Update both scroll layers (call from PLAY phase)
SCROLL_UPDATE:

    inc SCROLL_TICK

    // Layer 1: slow scroll every 4 frames
    lda SCROLL_TICK
    and #3
    bne SU_LAYER2

    jsr SCROLL_STARS_SLOW

SU_LAYER2:

    // Layer 2: fast scroll every 2 frames
    lda SCROLL_TICK
    and #1
    bne SU_APPLY

    jsr SCROLL_STARS_FAST

SU_APPLY:

    // Fine scroll
    inc SCROLL_FINE_X
    lda SCROLL_FINE_X
    and #7
    sta SCROLL_FINE_X
    bne SU_DONE

    // Coarse shift every 8 pixels
    inc SCROLL_COARSE_X
    lda SCROLL_COARSE_X
    and #$1F
    sta SCROLL_COARSE_X

SU_DONE:

    // Apply fine scroll to VIC
    lda SCROLL_FINE_X
    ora #%11001000
    sta VIC_CTRL2
    rts

// Shift slow star layer (bottom rows)
SCROLL_STARS_SLOW:

    ldx #0
SSS_LOOP:

    lda SCREEN_RAM+40*20+1,X
    sta SCREEN_RAM+40*20,X
    lda COLOR_RAM+40*20+1,X
    sta COLOR_RAM+40*20,X
    inx
    cpx #39
    bne SSS_LOOP

    // New star on right edge (random-ish)
    lda SCROLL_COARSE_X
    and #3
    tay
    lda STAR_CHARS,Y
    sta SCREEN_RAM+40*20+39

    lda #$0B
    sta COLOR_RAM+40*20+39
    rts

// Shift fast star layer (middle rows)
SCROLL_STARS_FAST:

    ldx #0
SSF_LOOP:

    lda SCREEN_RAM+40*15+1,X
    sta SCREEN_RAM+40*15,X
    lda COLOR_RAM+40*15+1,X
    sta COLOR_RAM+40*15,X
    inx
    cpx #39
    bne SSF_LOOP

    lda SCROLL_COARSE_X
    and #1
    tay
    lda STAR_CHARS+4,Y
    sta SCREEN_RAM+40*15+39
    lda #1
    sta COLOR_RAM+40*15+39
    rts

// Draw initial starfield
SCROLL_DRAW_STARS:

    ldx #0
SDS_LOOP:

    // Slow layer
    txa
    and #7
    tay
    lda STAR_CHARS,Y
    sta SCREEN_RAM+40*20,X

    txa
    and #$1F
    cmp #$10
    rol
    and #1
    tay
    lda STAR_CHARS+4,Y
    sta SCREEN_RAM+40*15,X

    inx
    cpx #40
    bne SDS_LOOP
    rts

// Star characters (PETSCII dots and small shapes)
STAR_CHARS:

    .byte $20, $2E, $20, $2A    // layer 1: space, dot, space, star
    .byte $2E, $2A               // layer 2: dot, star

// ---- Zero-page variables (defined in config.asm) ----
// SCROLL_FINE_X, SCROLL_COARSE_X, SCROLL_TICK
