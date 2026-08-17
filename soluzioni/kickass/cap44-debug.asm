// Converted to Kick Assembler syntax
.segmentdef Ex1 [start=$c000]
.segmentdef Ex2 [start=$c000]
.segmentdef Ex3 [start=$c000]
.segmentdef Ex4 [start=$c000]
.segmentdef Ex5 [start=$c000]

// --- Shared Constants ---
.const BORDER = $D020

.macro ProfileStart(color) {
    lda #color
    sta BORDER
}

.macro ProfileEnd(baseColor) {
    lda #baseColor
    sta BORDER
}

// =============================================
// SOLUZIONI Capitolo 44 — Debug e Profiling
// --- METADATA ---
// chapter: 44
// title: Debug e Profiling Real-Hardware
// difficulty: master
// --- END METADATA ---
// =============================================

// --- ESERCIZIO 1: Profiling Macros ---
.segment Ex1
.namespace Ex1 {
    start:
        :ProfileStart(2)    // Bordo rosso durante il lavoro
        jsr heavy_routine
        :ProfileEnd(0)      // Torna a nero
        rts

    heavy_routine:
        nop; nop; nop
        rts
}

// --- ESERCIZIO 2: Sort Comparison Profiling ---
.segment Ex2
.namespace Ex2 {
    profile_sort:
        :ProfileStart(3)    // Ciano per Insertion Sort
        jsr heavy_sort
        :ProfileEnd(0)
        rts

    heavy_sort:
        ldx #0
    !:  inx
        cpx #100
        bne !-
        rts
}

// --- ESERCIZIO 3: CPU Usage Bar ---
.segment Ex3
.namespace Ex3 {
    draw_usage_bar:
        lda $D012           // Raster line
        sec
        sbc #50             // Start raster
        sta $0400           // Mostra barra
        rts
}

// --- ESERCIZIO 4: VICE Breakpoint Stub ---
.segment Ex4
.namespace Ex4 {
    debug_breakpoint:
        // Punti di controllo per monitor VICE (break su $C050)
        nop
        rts
}

// --- ESERCIZIO 5: BCD Register Inspector ---
.segment Ex5
.namespace Ex5 {
    inspect_registers:
        pha
        lsr; lsr; lsr; lsr
        ora #$30
        sta $0400           // Hi nibble ASCII
        pla
        and #$0F
        ora #$30
        sta $0401           // Lo nibble ASCII
        rts
}
