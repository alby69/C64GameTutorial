// Converted to Kick Assembler syntax
.segmentdef Ex1 [start=$c000]
.segmentdef Ex2 [start=$c000]
.segmentdef Ex3 [start=$c000]
.segmentdef Ex4 [start=$c000]
.segmentdef Ex5 [start=$c000]

// --- Shared Constants ---

// =============================================
// SOLUZIONI Capitolo 21 — Caricatore Personalizzato
// --- METADATA ---
// chapter: 21
// title: Custom Loader
// difficulty: advanced
// --- END METADATA ---
// =============================================
//
// Mappa esercizi:
//   1: caricatore KERNAL per GIOCO.PRG
//   2: caricatore KERNAL + effetto raster bar
//   3: schermata caricamento con barra progresso
//   4: boot loader in 3 fasi
//   5: lettura byte via seriale ($DD00)
//
// =============================================

// --- ESERCIZIO 1: caricatore KERNAL per GIOCO.PRG ---
.segment Ex1
.namespace Ex1 {
    // *= $C000
        lda #9
        ldx #<FNAME1
        ldy #>FNAME1
        jsr $FFBD          // SETNAM
        lda #1
        ldx #8
        ldy #1
        jsr $FFBA          // SETLFS
        lda #0
        ldx #0
        ldy #0
        jsr $FFD5          // LOAD
        jmp $C000          // esegui

    FNAME1:

        .text "GIOCO.PRG"

}

// --- ESERCIZIO 2: caricatore KERNAL + raster bar ---
.segment Ex2
.namespace Ex2 {
    // *= $C000
        sei
        lda #<IRQ2
        sta $0314
        lda #>IRQ2
        sta $0315
        lda #100
        sta $D012
        lda $D011
        and #$7F
        sta $D011
        lda #1
        sta $D01A
        cli

        lda #9
        ldx #<FNAME2
        ldy #>FNAME2
        jsr $FFBD
        lda #1
        ldx #8
        ldy #1
        jsr $FFBA
        lda #0
        ldx #0
        ldy #0
        jsr $FFD5

        sei
        lda #0
        sta $D01A
        cli

        jmp $C000

    IRQ2:

        inc $D020
        lda $D019
        sta $D019
        jmp $EA31

    FNAME2:

        .text "GIOCO.PRG"

}

// --- ESERCIZIO 3: schermata caricamento + barra progresso ---
.segment Ex3
.namespace Ex3 {
    // *= $C000
        jsr SETUP

        lda #9
        ldx #<FNAME3
        ldy #>FNAME3
        jsr $FFBD
        lda #1
        ldx #8
        ldy #1
        jsr $FFBA

        sei
        lda #<IRQ3
        sta $0314
        lda #>IRQ3
        sta $0315
        lda #50
        sta $D012
        lda #1
        sta $D01A
        cli

        lda #0
        ldx #0
        ldy #0
        jsr $FFD5

        sei
        lda #0
        sta $D01A
        cli
        jmp $C000

    SETUP:

        ldx #0
    MSG:

        lda LOADMSG,X
        sta $0400+40*12+5,X
        inx
        cpx #20
        bne MSG
        rts

    IRQ3:

        inc $D020
        lda BARPOS
        tax
        lda #$A0
        sta $0400+40*14,X
        lda #5
        sta $D800+40*14,X
        inc BARPOS
        lda BARPOS
        cmp #40
        bne NO_RESET
        lda #0
        sta BARPOS
    NO_RESET:

        lda $D019
        sta $D019
        jmp $EA31

    BARPOS:

        .byte 0

    LOADMSG:

        .text "CARICAMENTO IN CORSO..."

    FNAME3:

        .text "GIOCO.PRG"

}

// --- ESERCIZIO 4: boot loader in 3 fasi ---
.segment Ex4
.namespace Ex4 {
    // Prima fase — si carica con LOAD"*",8,1
    // *= $0801
        lda #13
        ldx #<FNAME4A
        ldy #>FNAME4A
        jsr $FFBD
        lda #1
        ldx #8
        ldy #1
        jsr $FFBA
        lda #0
        ldx #0
        ldy #0
        jsr $FFD5
        jmp $C000

    FNAME4A:

        .text "LOADER.PRG"

    // Seconda fase (LOADER.PRG) — caricatore con effetti
    // *= $C000
        jsr SETUP4
        sei
        lda #<IRQ4
        sta $0314
        lda #>IRQ4
        sta $0315
        lda #50
        sta $D012
        lda #1
        sta $D01A
        cli

        lda #9
        ldx #<FNAME4B
        ldy #>FNAME4B
        jsr $FFBD
        lda #1
        ldx #8
        ldy #1
        jsr $FFBA
        lda #0
        ldx #0
        ldy #0
        jsr $FFD5

        sei
        lda #0
        sta $D01A
        cli
        jmp $C000

    SETUP4:

        ldx #0
    MSG4:

        lda LOADMSG4,X
        sta $0400+40*12+5,X
        inx
        cpx #20
        bne MSG4
        rts

    IRQ4:

        inc $D020
        lda $D019
        sta $D019
        jmp $EA31

    LOADMSG4:

        .text "CARICAMENTO GIOCO..."

    FNAME4B:

        .text "GIOCO.PRG"

    // Terza fase (GIOCO.PRG) — il gioco vero e proprio
    // *= $C000
        // ... codice del gioco ...
        rts

}

// --- ESERCIZIO 5: lettura byte via seriale ($DD00) ---
.segment Ex5
.namespace Ex5 {
    // Legge un byte dal drive usando la porta seriale direttamente
    // *= $C000
        jsr READ_BYTE
        sta $0400         // mostra il byte letto a schermo
        rts

    READ_BYTE:

        lda #$00
        sta TEMP
        ldx #8            // 8 bit da leggere
    BIT_LOOP:

        lda $DD00
        and #$10          // DATA line sul bit 4
        beq BIT_ZERO
        // Bit = 1
        lda TEMP
        lsr               // sposta a destra
        ora #$80          // setta bit 7
        sta TEMP
        jmp NEXT
    BIT_ZERO:

        // Bit = 0
        lda TEMP
        lsr               // sposta a destra
        sta TEMP
    NEXT:

        // Clock pulse — attende che il drive prepari il prossimo bit
        ldy #$20
    WAIT:

        dey
        bne WAIT
        dex
        bne BIT_LOOP
        lda TEMP
        rts

    TEMP:

        .byte 0
}
