// Converted to Kick Assembler syntax
.segmentdef Ex1 [start=$c000]
.segmentdef Ex2 [start=$c000]
.segmentdef Ex3 [start=$c000]
.segmentdef Ex4 [start=$c000]
.segmentdef Ex5 [start=$c000]

// --- Shared Constants ---
.const WAIT3 = Ex3.WAIT3
.const WAIT4 = WAIT3
.const SCROLL_X = $D016
.const SKY_COLORS = $60

// =============================================
// SOLUZIONI Capitolo 17 — Parallax e Raster Split
// --- METADATA ---
// chapter: 17
// title: Parallax e Raster Split
// difficulty: advanced
// --- END METADATA ---
// =============================================
//
// Mappa esercizi:
//   1: schermo diviso in 3 zone, 3 colori
//   2: HUD fisso in alto, area gioco sotto
//   3: scrolling fine $D016 ogni frame, azzera a 7
//   4: finto parallax — cambio sfondo ogni 8 frame
//   5: sprite dietro lo sfondo con $D01B
//
// =============================================

// --- ESERCIZIO 1: schermo diviso in 3 zone, 3 colori ---
.segment Ex1
.namespace Ex1 {
    // *=$C000
        sei
        lda #$7F
        sta $DC0D

        lda #<IRQ_Z1
        sta $0314
        lda #>IRQ_Z1
        sta $0315

        lda #50
        sta $D012
        lda $D011
        and #$7F
        sta $D011
        lda #1
        sta $D01A
        cli
        jmp MAIN

    MAIN:

        jmp MAIN

    IRQ_Z1:

        lda #6          // blu (cielo)
        sta $D021
        sta $D020

        lda #100
        sta $D012
        lda #<IRQ_Z2
        sta $0314
        lda #>IRQ_Z2
        sta $0315

        lda $D019
        sta $D019
        jmp $EA31

    IRQ_Z2:

        lda #5          // verde (erba)
        sta $D021
        lda #2          // bordo rosso
        sta $D020

        lda #180
        sta $D012
        lda #<IRQ_Z3
        sta $0314
        lda #>IRQ_Z3
        sta $0315

        lda $D019
        sta $D019
        jmp $EA31

    IRQ_Z3:

        lda #0          // nero (sotterraneo)
        sta $D021
        lda #3          // bordo ciano
        sta $D020

        lda #50
        sta $D012
        lda #<IRQ_Z1
        sta $0314
        lda #>IRQ_Z1
        sta $0315

        lda $D019
        sta $D019
        jmp $EA31

}

// --- ESERCIZIO 2: HUD fisso in alto, area gioco sotto ---
.segment Ex2
.namespace Ex2 {
    // *=$9000
        sei
        lda #$7F
        sta $DC0D
        lda #<IRQ_HUD
        sta $0314
        lda #>IRQ_HUD
        sta $0315
        lda #40
        sta $D012
        lda $D011
        and #$7F
        sta $D011
        lda #1
        sta $D01A
        cli

        // Scrivi HUD
        lda #32
        ldx #0
    HUD_CLR:

        sta $0400,X
        inx
        cpx #40
        bne HUD_CLR

        lda #19         // 'S'
        sta $0400+2
        lda #3          // 'C'
        sta $0400+3
        lda #15         // 'O'
        sta $0400+4
        lda #18         // 'R'
        sta $0400+5
        lda #5          // 'E'
        sta $0400+6
        lda #0
        sta $0400+8     // punteggio
        sta $0400+9
        sta $0400+10

        jmp MAIN2

    MAIN2:

        jmp MAIN2

    IRQ_HUD:

        lda #0          // nero per HUD
        sta $D021
        lda #1          // bordo bianco
        sta $D020

        lda #41
        sta $D012
        lda #<IRQ_GAME
        sta $0314
        lda #>IRQ_GAME
        sta $0315

        lda $D019
        sta $D019
        jmp $EA31

    IRQ_GAME:

        lda #6          // blu per area gioco
        sta $D021
        lda #0
        sta $D020

        lda #40
        sta $D012
        lda #<IRQ_HUD
        sta $0314
        lda #>IRQ_HUD
        sta $0315

        lda $D019
        sta $D019
        jmp $EA31

}

// --- ESERCIZIO 3: scrolling fine $D016 ogni frame, azzera a 7 ---
.segment Ex3
.namespace Ex3 {
    // *=$A000
        lda #0
        sta $02          // scroll counter

    LOOP3:

        jsr UPDATE_SCROLL
        jsr WAIT3
        jmp LOOP3

    UPDATE_SCROLL:

        lda $02
        inc $02
        and #7
        eor #7
        sta SCROLL_X
        rts

    WAIT3:

        lda $D012
        cmp #$F8
        bne WAIT3
        rts

}

// --- ESERCIZIO 4: finto parallax — cambio sfondo ogni 8 frame ---
.segment Ex4
.namespace Ex4 {
    // *=$B000
        lda #6
        sta $60         // blu
        lda #3
        sta $61         // ciano
        lda #7
        sta $62         // giallo
        lda #4
        sta $63         // viola

        lda #0
        sta $02         // frame counter
        sta $03         // sky index

    LOOP4:

        jsr UPDATE_SKY
        jsr WAIT4
        jmp LOOP4

    UPDATE_SKY:

        inc $02
        lda $02
        and #7
        bne US_END

        inc $03
        lda $03
        and #3
        tax
        lda SKY_COLORS,X
        sta $D021

    US_END:

        rts

}

// --- ESERCIZIO 5: sprite dietro lo sfondo con $D01B ---
.segment Ex5
.namespace Ex5 {
    // *=$C000
        sei
        lda #$7F
        sta $DC0D
        lda #<IRQ_PRIO
        sta $0314
        lda #>IRQ_PRIO
        sta $0315
        lda #150
        sta $D012
        lda $D011
        and #$7F
        sta $D011
        lda #1
        sta $D01A
        cli

        // Setup sprite
        lda #%00000011
        sta $D015

        lda #1
        sta $D027       // sprite 0 bianco
        lda #2
        sta $D028       // sprite 1 rosso

        lda #128
        sta $07F8
        sta $07F9

        lda #100
        sta $D000
        sta $D002
        lda #100
        sta $D001       // sprite 0
        lda #120
        sta $D003       // sprite 1 (sotto)

        // Elemento di sfondo
        lda #1
        sta $0400+10    // 'A' a schermo
        lda #5
        sta $D800+10    // colore verde

        jmp MAIN5

    MAIN5:

        jmp MAIN5

    IRQ_PRIO:

        // Nella zona HUD: sprite 0 dietro
        lda $D01B
        and #%11111110
        sta $D01B       // sprite 0 = priorita sfondo

        lda #180
        sta $D012
        lda #<IRQ_PRIO2
        sta $0314
        lda #>IRQ_PRIO2
        sta $0315

        lda $D019
        sta $D019
        jmp $EA31

    IRQ_PRIO2:

        // Nella zona gioco: sprite 0 davanti
        lda $D01B
        ora #%00000001
        sta $D01B       // sprite 0 = priorita sprite

        lda #150
        sta $D012
        lda #<IRQ_PRIO
        sta $0314
        lda #>IRQ_PRIO
        sta $0315

        lda $D019
        sta $D019
        jmp $EA31
}
