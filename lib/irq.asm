// =============================================
// IRQ — Gestione interrupt raster
// =============================================
#import "constants.asm"

// Inizializza IRQ raster alla linea specificata in A
irqInit: {
    sta irqLine
    sei
    lda #$7F
    sta $DC0D          // Disabilita interrupt CIA
    sta $DD0D
    lda $DC0D          // Ack CIA
    lda $DD0D

    lda #<irqHandler
    sta $0314
    lda #>irqHandler
    sta $0315

    lda irqLine
    sta VIC_RASTER
    lda VIC_CTRL1
    and #$7F
    sta VIC_CTRL1
    lda #$01
    sta VIC_IRQ_EN
    cli
    rts

irqLine: .byte 0
}

irqHandler: {
    pha
    txa
    pha
    tya
    pha

    inc frameCounter

    jsr irqCallback    // Punta alla routine utente

    lda VIC_IRQ_STAT
    sta VIC_IRQ_STAT
    pla
    tay
    pla
    tax
    pla
    rti

frameCounter: .byte 0
irqCallback:  .word $0000  // Da impostare dall'utente
}
