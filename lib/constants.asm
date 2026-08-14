#importonce
// =============================================
// CONSTANTS — Indirizzi hardware C64
// =============================================
.const VIC_BORDER     = $D020
.const VIC_BG         = $D021
.const VIC_CTRL1      = $D011
.const VIC_RASTER     = $D012
.const VIC_IRQ_STAT   = $D019
.const VIC_IRQ_EN     = $D01A
.const VIC_SPR_ENA    = $D015
.const VIC_SPR_X      = $D000
.const VIC_SPR_Y      = $D001
.const VIC_SPR_COL    = $D027
.const CIA1_DDRA      = $DC02
.const CIA1_DDRB      = $DC03
.const CIA1_PRB       = $DC01
.const SID_FREQ1      = $D400
.const SID_CTRL1      = $D404
.const SID_AD1        = $D405
.const SID_SUR1       = $D406
.const SID_VOL        = $D418
.const SCREEN_RAM     = $0400
.const COLOR_RAM      = $D800
.const KERNAL_IRQ     = $EA31
.const KERNAL_SCAN    = $FF9F
