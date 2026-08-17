// =============================================
// CAP06 — Charset custom e tiles / Custom Charset & Tiles
// Difficulty: Intermediate
// =============================================
:BasicUpstart2(start)

// ----------------------------------
// COSTANTI / CONSTANTS
// ----------------------------------
.const SCREEN_RAM = $0400
.const COLOR_RAM  = $D800
.const CHARSET_ADR = $2000
.const VIC_MEM     = $D018

start:
    // Disabilita interrupt
    sei

    // Imposta VIC: Screen $0400, Charset $2000
    lda #%00100010    // Screen: %0001 ($0400), Charset: %0010 ($2000)
    sta VIC_MEM

    // Copia charset custom
    jsr copyCharset

    // Disegna mappa
    jsr drawMap

    // Colora
    jsr colorMap

    cli

    // Loop infinito
!loop:
    jmp !loop-

// ----------------------------------
// copyCharset — Copia 2KB di charset
// ----------------------------------
copyCharset:
    ldx #0
!loop:
    lda charsetData, x
    sta CHARSET_ADR, x
    lda charsetData+$0100, x
    sta CHARSET_ADR+$0100, x
    lda charsetData+$0200, x
    sta CHARSET_ADR+$0200, x
    lda charsetData+$0300, x
    sta CHARSET_ADR+$0300, x
    lda charsetData+$0400, x
    sta CHARSET_ADR+$0400, x
    lda charsetData+$0500, x
    sta CHARSET_ADR+$0500, x
    lda charsetData+$0600, x
    sta CHARSET_ADR+$0600, x
    lda charsetData+$0700, x
    sta CHARSET_ADR+$0700, x
    inx
    bne !loop-
    rts

// ----------------------------------
// drawMap — Disegna 40×25 tile
// ----------------------------------
drawMap:
    ldx #0
!loop:
    lda mapData, x
    sta SCREEN_RAM, x
    lda mapData+$0100, x
    sta SCREEN_RAM+$0100, x
    lda mapData+$0200, x
    sta SCREEN_RAM+$0200, x
    inx
    cpx #250    // 40*25 = 1000, gestiamo 250×4
    bne !loop-

    ldx #0
!loop2:
    lda mapData+$0300, x
    sta SCREEN_RAM+$0300, x
    inx
    cpx #250
    bne !loop2-
    rts

// ----------------------------------
// colorMap — Colora tutto di verde
// ----------------------------------
colorMap:
    lda #5      // Verde
    ldx #0
!loop:
    sta COLOR_RAM, x
    sta COLOR_RAM+$0100, x
    sta COLOR_RAM+$0200, x
    sta COLOR_RAM+$0300, x
    inx
    bne !loop-
    rts

// ----------------------------------
// Dati: 4 tile (vuoto, muro, erba, acqua)
// ----------------------------------
* = $3000
charsetData:
    // Tile 0: Vuoto (spazio)
    .fill 8, 0
    // Tile 1: Muro (pieno)
    .fill 8, $FF
    // Tile 2: Erba (pattern)
    .byte %10101010
    .byte %01010101
    .byte %10101010
    .byte %01010101
    .byte %10101010
    .byte %01010101
    .byte %10101010
    .byte %01010101
    // Tile 3: Acqua
    .byte %00111100
    .byte %01111110
    .byte %11111111
    .byte %11111111
    .byte %11111111
    .byte %11111111
    .byte %01111110
    .byte %00111100
    // Riempi fino a 2KB
    .fill 2040-32, 0

// Mappa 40×25 (1000 byte)
* = $3800
mapData:
    .fill 40, 1        // Bordo superiore
    .byte 1
    .fill 38, 2        // Erba
    .byte 1
    .byte 1
    .fill 10, 2
    .fill 18, 3        // Acqua
    .fill 10, 2
    .byte 1
    .byte 1
    .fill 38, 2
    .byte 1
    .fill 40, 1        // Bordo inferiore
    // Riempi la mappa rimanente per raggiungere i 1000 byte
    .fill 1000 - 162, 2
