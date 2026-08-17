// =============================================
// CAP29 — Memory Overlay / Memory Overlay
// Difficulty: Expert
// =============================================
:BasicUpstart2(start)

start:
    // Carica livello 2 sovrascrivendo il loader
    lda #'2'
    ldx #<filename
    ldy #>filename
    jsr $FFBD
    lda #1
    ldx #8
    ldy #1
    jsr $FFBA
    lda #0
    ldx #<$0800    // Sovrascrive loader
    ldy #>$0800
    jsr $FFD5
    jmp $0800      // Salta al nuovo codice

filename:
    .text "LEVEL2"
    .byte 0
