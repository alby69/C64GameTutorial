; =============================================
; KERNEL — IRQ chain, scheduler, frame
; =============================================

* = $0800

; ---- Init ----
KERNEL_INIT
    SEI
    LDA #$7F
    STA $DC0D
    LDA #<KERNEL_IRQ
    STA $0314
    LDA #>KERNEL_IRQ
    STA $0315
    LDA #250
    STA VIC_RAST
    LDA VIC_CTRL1
    AND #$7F
    STA VIC_CTRL1
    LDA #1
    STA VIC_IRQ_EN
    CLI
    RTS

; ---- Main loop (idle, everything runs in IRQ) ----
KERNEL_MAIN
    JMP KERNEL_MAIN

; ---- Main IRQ handler ----
KERNEL_IRQ
    PHA
    TXA
    PHA
    TYA
    PHA

    INC FRAME_CNT

    LDA GAME_STATE
    CMP #0
    BEQ KIRQ_TITLE
    CMP #1
    BEQ KIRQ_PLAY
    JMP KIRQ_GAMEOVER

KIRQ_TITLE
    JSR TITLE_UPDATE
    JMP KIRQ_END

KIRQ_PLAY
    JSR RUN_SCHEDULER
    JSR ENGINE_AUDIO_UPDATE
    JMP KIRQ_END

KIRQ_GAMEOVER
    JSR GAMEOVER_UPDATE
    JMP KIRQ_END

KIRQ_END
    PLA
    TAY
    PLA
    TAX
    PLA
    LDA VIC_IRQ_STAT
    STA VIC_IRQ_STAT
    JMP $EA31

; ---- 3-phase scheduler ----
RUN_SCHEDULER
    LDA SCHED_PHASE
    BEQ SCH_INPUT
    CMP #1
    BEQ SCH_LOGIC
    JMP SCH_RENDER

SCH_INPUT
    JSR ENGINE_INPUT
    JSR GAME_PLAYER_UPDATE
    INC SCHED_PHASE
    RTS

SCH_LOGIC
    JSR GAME_ENEMIES_UPDATE
    JSR GAME_BULLETS_UPDATE
    JSR ENGINE_COLLISION
    INC SCHED_PHASE
    RTS

SCH_RENDER
    JSR GAME_RENDER
    LDA #0
    STA SCHED_PHASE
    RTS
