// =============================================
// KERNEL — 3-Layer Architecture / 3-Layer Arch
// Difficulty: Professional
// =============================================
* = $0800

:BasicUpstart2(kernelInit)

kernelInit:
    sei
    lda #$35
    sta $01
    lda #$7F
    sta $DC0D
    sta $DD0D
    lda $DC0D
    lda $DD0D

    lda #<kernelIrq
    sta $FFFE
    lda #>kernelIrq
    sta $FFFF

    lda #250
    sta $D012
    lda #$01
    sta $D01A
    cli
    rts

kernelMain:
    jmp kernelMain   // Idle loop

kernelIrq:
    pha
    txa
    pha
    tya
    pha

    inc frameCount

    // Phase 0: Input
    jsr engineInput

    // Phase 1: Logic (ogni 2 frame)
    lda frameCount
    and #$01
    bne !skipLogic+
    jsr engineLogic
!skipLogic:

    // Phase 2: Render
    jsr engineRender

    // Phase 3: Audio
    jsr engineAudio

    lda $D019
    sta $D019

    pla
    tay
    pla
    tax
    pla
    rti

frameCount: .byte 0

// ----------------------------------
// Stubs
// ----------------------------------
engineInput:
    rts
engineLogic:
    rts
engineRender:
    rts
engineAudio:
    rts
