#importonce
// =============================================
// SPRITES — Gestione base sprite hardware
// =============================================
#import "constants.asm"

// Attiva sprite n (0-7). A = numero sprite
spriteEnable: {
    tax
    lda VIC_SPR_ENA
    ora bitmask, x
    sta VIC_SPR_ENA
    rts
bitmask: .byte %00000001, %00000010, %00000100, %00001000, %00010000, %00100000, %01000000, %10000000
}

// Disattiva sprite n. A = numero sprite
spriteDisable: {
    tax
    lda VIC_SPR_ENA
    and bitmask, x
    sta VIC_SPR_ENA
    rts
bitmask: .byte $FE, $FD, $FB, $F7, $EF, $DF, $BF, $7F
}

// Imposta posizione sprite. A=num, X=xpos, Y=ypos
spriteSetPos: {
    sta zp_tmp
    asl
    asl                    // A = sprite * 4 (indice tabella)
    // ... (implementazione completa nei capitoli)
    rts
}

// Imposta puntatore sprite. A=num, X=block (0-255)
spriteSetPtr: {
    sta zp_tmp
    lda #$07
    sec
    sbc zp_tmp
    asl
    asl
    asl
    asl
    asl
    asl
    sta zp_ptr
    lda #$CB
    sta zp_ptr+1
    txa
    ldy #0
    sta (zp_ptr), y
    rts
}

zp_tmp: .byte 0
zp_ptr: .word 0
