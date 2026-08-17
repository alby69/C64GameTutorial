// Converted to Kick Assembler syntax
.segmentdef Ex1 [start=$c000]
.segmentdef Ex2 [start=$c000]
.segmentdef Ex3 [start=$c000]
.segmentdef Ex4 [start=$c000]
.segmentdef Ex5 [start=$c000]

// --- Shared Constants ---
.const SETNAM = $FFBD
.const SETLFS = $FFBA
.const LOAD = $FFD5
.const SAVE = $FFD8

// =============================================
// SOLUZIONI Capitolo 34 — Creazione Immagini Disco D64
// --- METADATA ---
// chapter: 34
// title: Creazione Immagini Disco D64
// difficulty: advanced
// --- END METADATA ---
// =============================================

// --- ESERCIZIO 1: Loader KERNAL per file "GAME" ---
.segment Ex1
.namespace Ex1 {
    start:
        lda #4              // lunghezza nome "GAME"
        ldx #<filename
        ldy #>filename
        jsr SETNAM

        lda #1              // logical file #1
        ldx $BA             // drive (default 8)
        bne drive_ok
        ldx #8
    drive_ok:
        ldy #1              // 1 = usa indirizzo di carico originale
        jsr SETLFS

        lda #0              // 0 = load
        jsr LOAD
        rts

    filename: .text "GAME"
}

// --- ESERCIZIO 2: Gestione errore caricamento (Carry Set) ---
.segment Ex2
.namespace Ex2 {
    start:
        jsr Ex1.start
        bcc ok
        ldx #0
    err_loop:
        lda msg_err,x
        beq done
        jsr $FFD2
        inx
        jmp err_loop
    ok:
    done:
        rts

    msg_err: .text "LOAD ERROR"
             .byte $0D, $00
}

// --- ESERCIZIO 3: Loader sequenziale (SPRITES -> MUSIC -> GAME) ---
.segment Ex3
.namespace Ex3 {
    start:
        // Carica SPRITES
        lda #7
        ldx #<f_sprites
        ldy #>f_sprites
        jsr load_one

        // Carica MUSIC
        lda #5
        ldx #<f_music
        ldy #>f_music
        jsr load_one

        // Carica GAME
        lda #4
        ldx #<f_game
        ldy #>f_game
        jsr load_one
        rts

    load_one:
        jsr SETNAM
        lda #1
        ldx $BA
        bne !+
        ldx #8
    !:  ldy #1
        jsr SETLFS
        lda #0
        jsr LOAD
        rts

    f_sprites: .text "SPRITES"
    f_music:   .text "MUSIC"
    f_game:    .text "GAME"
}

// --- ESERCIZIO 4: Struttura BOOT per disco .D64 ---
.segment Ex4
.namespace Ex4 {
    start:
        // Genera header di avvio
        jsr $E544           // CLS
        jsr Ex3.start
        jmp $4000           // Start game
}

// --- ESERCIZIO 5: Salvataggio file High Score "HIGH.SEQ" ---
.segment Ex5
.namespace Ex5 {
    start:
        lda #8
        ldx #<fname
        ldy #>fname
        jsr SETNAM

        lda #2              // file #2
        ldx $BA
        bne !+
        ldx #8
    !:  ldy #0              // 0 = save
        jsr SETLFS

        lda #<score_data
        sta $FB
        lda #>score_data
        sta $FC

        lda #$FB
        ldx #<score_end
        ldy #>score_end
        jsr SAVE
        rts

    fname: .text "HIGH.SEQ"
    score_data: .byte $00, $01, $00, $00, $00
    score_end:
}
