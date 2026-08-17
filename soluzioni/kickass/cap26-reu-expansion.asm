// Converted to Kick Assembler syntax
.segmentdef Ex1 [start=$c000]

// --- Shared Constants ---
.const REU_ADDR_L = $02
.const LEVEL_SIZE = $4000
.const GAME_VARS = $C000     // variabili di gioco
.const STATE_SIZE = 64       // 64 byte di stato

// ─────────────────────────────────────────────────────
// Soluzioni esercizi Capitolo 26 — REU Expansion
// --- METADATA ---
// chapter: 26
// title: REU Expansion
// difficulty: master
// --- END METADATA ---
// ─────────────────────────────────────────────────────


// ─────────────────────────────────────────────────────
// Esercizio 1 — Copia 256 byte da $C000 a REU $000000
// ─────────────────────────────────────────────────────

// *= $C000

C64_TO_REU:

    // REU address = $000000
    lda #0
    sta $DF02          // REU_ADDR_L
    sta $DF03          // REU_ADDR_H
    sta $DF04          // REU_ADDR_B

    // C64 address = $C000
    lda #$00
    sta $DF05          // C64_ADDR_L
    lda #$C0
    sta $DF06          // C64_ADDR_H
    lda #0
    sta $DF07          // C64_ADDR_B

    // Length = 256 ($00 = 256 in L)
    lda #0
    sta $DF08          // LENGTH_L
    sta $DF09          // LENGTH_H

    // Command: C64 → REU, bit 7=1
    lda #%10000000
    sta $DF00          // COMMAND

    jsr WAIT_DMA
    rts

// ─────────────────────────────────────────────────────
// Esercizio 2 — Copia 512 byte da REU $001000 a $A000
// ─────────────────────────────────────────────────────

REU_TO_C64:

    // REU address = $001000
    lda #$00
    sta $DF02
    lda #$10
    sta $DF03
    lda #0
    sta $DF04

    // C64 address = $A000
    lda #$00
    sta $DF05
    lda #$A0
    sta $DF06
    lda #0
    sta $DF07

    // Length = 512 ($0200)
    lda #$00
    sta $DF08
    lda #$02
    sta $DF09

    // Command: REU → C64, bit 7=1, bit 6=1
    lda #%11000000
    sta $DF00

    jsr WAIT_DMA
    rts

// ─────────────────────────────────────────────────────
// Esercizio 3 — WAIT_DMA (attesa completamento DMA)
// ─────────────────────────────────────────────────────

WAIT_DMA:

    lda $DF01
    and #%00000001     // bit 0 = BSY
    bne WAIT_DMA
    rts

// ─────────────────────────────────────────────────────
// Esercizio 4 — Sistema a 4 livelli in REU
// ─────────────────────────────────────────────────────
// Ogni livello occupa 16 KB ($4000)
// Livello 0: REU $000000-$003FFF
// Livello 1: REU $004000-$007FFF
// Livello 2: REU $008000-$00BFFF
// Livello 3: REU $00C000-$00FFFF


// Input: A = numero livello (0-3)
LOAD_LEVEL:

    // Calcola offset REU = A * $4000
    sta TEMP_REU

    // REU_ADDR_L = (A * $4000) & $FF
    lda TEMP_REU
    asl
    asl
    asl
    asl
    asl
    asl                 // ×64 → bit 14 shift
    sta REU_ADDR_L      // ma serve meglio
    // Approccio semplice: usa tabella lookup
    ldx TEMP_REU
    lda LEVEL_OFF_L,X
    sta $DF02
    lda LEVEL_OFF_H,X
    sta $DF03
    lda #0
    sta $DF04

    // C64 address = $C000 (destinazione)
    lda #$00
    sta $DF05
    lda #$C0
    sta $DF06
    lda #0
    sta $DF07

    // Length = 16 KB
    lda #$00
    sta $DF08
    lda #$40
    sta $DF09

    // DMA start
    lda #%11000000
    sta $DF00
    jsr WAIT_DMA
    rts

LEVEL_OFF_L:

    .byte <$000000, <$004000, <$008000, <$00C000
LEVEL_OFF_H:

    .byte >$000000, >$004000, >$008000, >$00C000

TEMP_REU:

    .byte 0

// ─────────────────────────────────────────────────────
// Esercizio 5 — Salva/carica stato gioco in REU
// ─────────────────────────────────────────────────────


// Salva stato in REU all'indirizzo $FF0000
SAVE_STATE:

    // REU address = $FF0000
    lda #$00
    sta $DF02
    lda #$00
    sta $DF03
    lda #$FF
    sta $DF04

    // C64 address = GAME_VARS
    lda #<GAME_VARS
    sta $DF05
    lda #>GAME_VARS
    sta $DF06
    lda #0
    sta $DF07

    // Length = 64
    lda #64
    sta $DF08
    lda #0
    sta $DF09

    lda #%10000000     // C64 → REU
    sta $DF00
    jsr WAIT_DMA
    rts

// Carica stato da REU (per restore dopo reset)
LOAD_STATE:

    lda #$00
    sta $DF02
    sta $DF03
    lda #$FF
    sta $DF04

    lda #<GAME_VARS
    sta $DF05
    lda #>GAME_VARS
    sta $DF06
    lda #0
    sta $DF07

    lda #64
    sta $DF08
    lda #0
    sta $DF09

    lda #%11000000     // REU → C64
    sta $DF00
    jsr WAIT_DMA
    rts
