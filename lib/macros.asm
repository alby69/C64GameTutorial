// =============================================
// MACROS — Utility comuni
// =============================================

// Attende un dato valore di raster
.macro waitRaster(line) {
    lda #line
-   cmp $D012
    bne -
}

// Attende il prossimo frame (raster 255 -> 0)
.macro waitFrame() {
-   lda $D012
    cmp #255
    bne -
-   lda $D012
    cmp #0
    bne -
}

// Imposta colore bordo e sfondo
.macro setColors(border, bg) {
    lda #border
    sta VIC_BORDER
    lda #bg
    sta VIC_BG
}
