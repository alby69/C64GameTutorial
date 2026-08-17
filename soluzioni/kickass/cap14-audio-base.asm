// Converted to Kick Assembler syntax
.segmentdef Ex1 [start=$c000]
.segmentdef Ex2 [start=$c000]
.segmentdef Ex3 [start=$c000]
.segmentdef Ex4 [start=$c000]
.segmentdef Ex5 [start=$c000]

// --- Shared Constants ---
.const SID_FREQ_LO = $D400
.const SID_FREQ_HI = $D401
.const SID_CTRL = $D404
.const SID_ADSR = $D405
.const SID_SUR = $D406
.const SID_VOL = $D418
.const JOYPORT = $DC01

// =============================================
// SOLUZIONI Capitolo 14 — Audio SID Base
// --- METADATA ---
// chapter: 14
// title: Audio SID Base
// difficulty: intermediate
// --- END METADATA ---
// =============================================
//
// Mappa esercizi:
//   1: beep 1 secondo square wave
//   2: suono laser al fuoco
//   3: esplosione con noise 0.5 secondi
//   4: sweep frequenza basso→alto 0.5 sec
//   5: 3 suoni diversi: sparo, esplosione, bonus
//
// =============================================

// --- ESERCIZIO 1: beep 1 secondo square wave ---
.segment Ex1
.namespace Ex1 {
    // *=$C000
        lda #$F0
        sta SID_FREQ_LO    // frequenza ~260 Hz
        lda #$03
        sta SID_FREQ_HI

        lda #$09
        sta SID_ADSR       // attack=0, decay=9 (breve)

        lda #$01
        sta SID_SUR        // sustain=0, release=1

        lda #15
        sta SID_VOL        // volume massimo

        lda #$11           // square wave + gate
        sta SID_CTRL

        jsr DELAY1         // 1 secondo

        lda #$10           // gate off
        sta SID_CTRL

        rts

    DELAY1:

        ldx #$FF
    D1O:

        ldy #$FF
    D1M:

        nop
        dey
        bne D1M
        dex
        bne D1O
        rts

}

// --- ESERCIZIO 2: suono laser al fuoco ---
.segment Ex2
.namespace Ex2 {
    // *=$9000
        lda #15
        sta SID_VOL

    LOOP2:

        lda JOYPORT
        and #16
        bne LOOP2

        // Laser - frequenza alta breve
        lda #$00
        sta SID_FREQ_LO
        lda #$10
        sta SID_FREQ_HI    // frequenza alta (~4096 Hz)

        lda #$00
        sta SID_ADSR       // attack 0, decay 0

        lda #$0F
        sta SID_SUR        // sustain 0, release F (lungo)

        lda #$81           // noise + gate
        sta SID_CTRL

        ldx #$30           // breve pausa
    D2:

        dex
        bne D2

        lda #$80           // gate off
        sta SID_CTRL

        jmp LOOP2

}

// --- ESERCIZIO 3: esplosione con noise 0.5 secondi ---
.segment Ex3
.namespace Ex3 {
    // *=$A000
        lda #15
        sta SID_VOL

    BANG:

        lda #$00
        sta SID_FREQ_LO
        lda #$20
        sta SID_FREQ_HI

        lda #$08
        sta SID_ADSR       // attack=0, decay=8

        lda #$0F
        sta SID_SUR        // sustain 0, release 15

        lda #$81           // noise + gate
        sta SID_CTRL

        // Mantieni per 0.5 secondi
        ldx #$80
    D3O:

        ldy #$FF
    D3M:

        dey
        bne D3M
        dex
        bne D3O

        lda #$80           // gate off
        sta SID_CTRL

        rts

}

// --- ESERCIZIO 4: sweep frequenza basso→alto 0.5 sec ---
.segment Ex4
.namespace Ex4 {
    // *=$B000
        lda #15
        sta SID_VOL

        lda #$00
        sta SID_ADSR

        lda #$0F
        sta SID_SUR

        lda #$11           // square + gate
        sta SID_CTRL

        ldx #0
    SWEEP:

        txa
        sta SID_FREQ_LO
        lda #$01
        sta SID_FREQ_HI

        ldy #$10
    SW_DELAY:

        dey
        bne SW_DELAY

        inx
        cpx #$FF
        bne SWEEP

        lda #$10
        sta SID_CTRL
        rts

}

// --- ESERCIZIO 5: 3 suoni diversi: sparo, esplosione, bonus ---
.segment Ex5
.namespace Ex5 {
    // *=$C000

    // Suono SPARO (canale 1)
    SOUND_SHOOT:

        lda #$00
        sta $D400
        lda #$20
        sta $D401
        lda #$00
        sta $D405
        lda #$08
        sta $D406
        lda #$81
        sta $D404
        ldx #$20
    SS_D:

        dex
        bne SS_D
        lda #$80
        sta $D404
        rts

    // Suono ESPLOSIONE (canale 2)
    SOUND_EXPLODE:

        lda #$00
        sta $D410
        lda #$10
        sta $D411
        lda #$88
        sta $D415
        lda #$0F
        sta $D416
        lda #$81
        sta $D414
        ldx #$FF
    SE_D:

        dex
        bne SE_D
        lda #$80
        sta $D414
        rts

    // Suono BONUS (canale 3)
    SOUND_BONUS:

        lda #$40
        sta $D420
        lda #$02
        sta $D421
        lda #$09
        sta $D425
        lda #$0F
        sta $D426
        lda #$21           // triangle + gate
        sta $D424
        ldx #$40
    SB_D:

        dex
        bne SB_D
        lda #$20
        sta $D424
        rts
}
