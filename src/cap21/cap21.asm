// =============================================
// LOADER — Caricatore multi-parte / Multi-part Loader
// Difficulty: Professional
// =============================================
* = $0801

// BASIC stub: 10 SYS 2064
.byte $0C, $08, $0A, $00, $9E, $20, $32, $30, $36, $34, $00, $00, $00

* = $0810
start:
    // Carica parte 2 (engine) a $2000
    lda #'E'
    ldx #<filenameEngine
    ldy #>filenameEngine
    jsr $FFBD       // SETNAM
    lda #1
    ldx #8
    ldy #1
    jsr $FFBA       // SETLFS
    lda #0
    ldx #<$2000
    ldy #>$2000
    jsr $FFD5       // LOAD

    // Carica parte 3 (game) a $4000
    lda #'G'
    ldx #<filenameGame
    ldy #>filenameGame
    jsr $FFBD
    lda #1
    ldx #8
    ldy #1
    jsr $FFBA
    lda #0
    ldx #<$4000
    ldy #>$4000
    jsr $FFD5

    // Salta al gioco
    jmp $4000

filenameEngine:
    .text "ENGINE"
    .byte 0

filenameGame:
    .text "GAME"
    .byte 0
