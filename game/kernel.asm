#importonce
// =============================================
// KERNEL — IRQ chain, scheduler, frame
// --- METADATA ---
// module: kernel
// features: [IRQ, Scheduler, Phase Management]
// memory_address: $0800
// --- END METADATA ---
// =============================================

* = $0900

// ---- Init ----
KERNEL_INIT:

    sei
    lda #$7F
    sta $DC0D
    lda #<KERNEL_IRQ
    sta $0314
    lda #>KERNEL_IRQ
    sta $0315
    lda #250
    sta VIC_RAST
    lda VIC_CTRL1
    and #$7F
    sta VIC_CTRL1
    lda #1
    sta VIC_IRQ_EN
    cli
    rts

// ---- Main loop (idle, everything runs in IRQ) ----
KERNEL_MAIN:

    jmp KERNEL_MAIN

// ---- Main IRQ handler ----
KERNEL_IRQ:

    pha
    txa
    pha
    tya
    pha

    inc FRAME_CNT

    lda GAME_STATE
    cmp #0
    beq KIRQ_TITLE
    cmp #1
    beq KIRQ_PLAY
    jmp KIRQ_GAMEOVER

KIRQ_TITLE:

    jsr TITLE_UPDATE
    jmp KIRQ_END

KIRQ_PLAY:

    jsr RUN_SCHEDULER
    jsr ENGINE_AUDIO_UPDATE
    jmp KIRQ_END

KIRQ_GAMEOVER:

    jsr GAMEOVER_UPDATE
    jmp KIRQ_END

KIRQ_END:

    pla
    tay
    pla
    tax
    pla
    lda VIC_IRQ_STAT
    sta VIC_IRQ_STAT
    jmp $EA31

// ---- 3-phase scheduler ----
RUN_SCHEDULER:

    lda SCHED_PHASE
    beq SCH_INPUT
    cmp #1
    beq SCH_LOGIC
    jmp SCH_RENDER

SCH_INPUT:

    jsr ENGINE_INPUT
    jsr GAME_PLAYER_UPDATE
    inc SCHED_PHASE
    rts

SCH_LOGIC:

    jsr GAME_ENEMIES_UPDATE
    jsr GAME_BULLETS_UPDATE
    jsr ENGINE_COLLISION
    inc SCHED_PHASE
    rts

SCH_RENDER:

    jsr GAME_RENDER
    lda #0
    sta SCHED_PHASE
    rts
