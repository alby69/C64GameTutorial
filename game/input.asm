; =============================================
; INPUT — Joystick port 2
; =============================================

* = $0C00

ENGINE_INPUT
    LDA CIA1_PRA
    EOR #$FF
    AND #%00011111
    STA JOY_STATE

    TAX
    EOR JOY_OLD
    AND JOY_STATE
    STA JOY_EDGE
    STX JOY_OLD
    RTS

; Utility: test fire button pressed this frame
FIRE_PRESSED
    LDA JOY_EDGE
    AND #%00010000
    RTS

; Utility: test fire held
FIRE_HELD
    LDA JOY_STATE
    AND #%00010000
    RTS
