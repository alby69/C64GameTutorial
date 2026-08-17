// Converted to Kick Assembler syntax
.segmentdef Ex1 [start=$c000]
.segmentdef Ex2 [start=$c000]
.segmentdef Ex3 [start=$c000]
.segmentdef Ex4 [start=$c000]
.segmentdef Ex5 [start=$c000]

// --- Shared Constants ---
.const RASTER_LINE = $D012
.const BORDER = $D020

// =============================================
// SOLUZIONI Capitolo 39 — Stable Raster & Timing di Ciclo
// --- METADATA ---
// chapter: 39
// title: Stable Raster & Timing di Ciclo
// difficulty: master
// --- END METADATA ---
// =============================================

// --- ESERCIZIO 1: Double IRQ Jitter Elimination ---
.segment Ex1
.namespace Ex1 {
    irq1:
        // Primo IRQ: imposta il secondo IRQ sulla linea successiva
        lda #<irq2
        sta $0314
        lda #>irq2
        sta $0315
        inc RASTER_LINE
        lsr $D019
        cli
        // NOP slide per consumare l'incertezza
        nop; nop; nop; nop; nop
        rts

    irq2:
        // Secondo IRQ: arriva a ciclo esatto
        inc BORDER
        dec BORDER
        lsr $D019
        rts
}

// --- ESERCIZIO 2: Cycle exact CMP $D012 sync ---
.segment Ex2
.namespace Ex2 {
    sync_cycle:
        lda RASTER_LINE
    !:  cmp RASTER_LINE
        beq !-              // attende transizione linea
        // Ora sincronizzato al ciclo 0-1 della linea
        rts
}

// --- ESERCIZIO 3: Stable Raster Bar ---
.segment Ex3
.namespace Ex3 {
    stable_bar:
        jsr Ex2.sync_cycle
        lda #2
        sta BORDER          // Rosso al ciclo esatto
        nop; nop; nop; nop
        lda #0
        sta BORDER          // Nero
        rts
}

// --- ESERCIZIO 4: Bad Line Cycle Budget Calculation ---
.segment Ex4
.namespace Ex4 {
    bad_line_check:
        lda RASTER_LINE
        and #7
        cmp #3              // Linea % 8 == 3 -> Bad Line!
        beq is_bad_line
        rts
    is_bad_line:
        // 23 cicli CPU anziché 63
        rts
}

// --- ESERCIZIO 5: Open Upper/Lower Border ---
.segment Ex5
.namespace Ex5 {
    open_border:
        lda #249
    !:  cmp RASTER_LINE
        bne !-
        lda $D011
        and #$F7            // Disabilita bit 3 (24-line mode)
        sta $D011
        rts
}
