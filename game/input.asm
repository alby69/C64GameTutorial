#importonce
// =============================================
// INPUT — Joystick port 2
// =============================================

* = $0C00

ENGINE_INPUT:

    lda CIA1_PRA
    eor #$FF
    and #%00011111
    sta JOY_STATE

    tax
    eor JOY_OLD
    and JOY_STATE
    sta JOY_EDGE
    stx JOY_OLD
    rts

// Utility: test fire button pressed this frame
FIRE_PRESSED:

    lda JOY_EDGE
    and #%00010000
    rts

// Utility: test fire held
FIRE_HELD:

    lda JOY_STATE
    and #%00010000
    rts
