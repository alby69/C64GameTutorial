// Converted to Kick Assembler syntax
.segmentdef Ex1 [start=$c000]
.segmentdef Ex2 [start=$c000]
.segmentdef Ex3 [start=$c000]
.segmentdef Ex4 [start=$c000]
.segmentdef Ex5 [start=$c000]

// --- Shared Constants ---
.const VIC_SCROLL_X = $D016
.const VIC_SCROLL_Y = $D011
.const SCREEN_RAM = $0400
.const COLOR_RAM = $D800

// =============================================
// SOLUZIONI Capitolo 37 — Full-Screen Scrolling
// --- METADATA ---
// chapter: 37
// title: Full-Screen Scrolling
// difficulty: master
// --- END METADATA ---
// =============================================

// --- ESERCIZIO 1: Smooth 8-pixel horizontal scroll ---
.segment Ex1
.namespace Ex1 {
    start:
        lda fine_x
        sec
        sbc #1
        and #7
        sta fine_x
        ora #$08            // 40 col mode
        sta VIC_SCROLL_X
        lda fine_x
        cmp #7
        bne !+
        jsr coarse_scroll
    !:  rts

    coarse_scroll:
        ldx #0
    !:  lda SCREEN_RAM+1,x
        sta SCREEN_RAM,x
        inx
        cpx #39
        bne !-
        rts

    fine_x: .byte 7
}

// --- ESERCIZIO 2: Selective Color RAM Redraw ---
.segment Ex2
.namespace Ex2 {
    start:
        ldx #0
    loop:
        lda dirty_flag,x
        beq next
        lda color_buffer,x
        sta COLOR_RAM,x
        lda #0
        sta dirty_flag,x
    next:
        inx
        cpx #40
        bne loop
        rts

    dirty_flag: .fill 40, 1
    color_buffer: .fill 40, 5
}

// --- ESERCIZIO 3: Flexible Line Distance (FLD) ---
.segment Ex3
.namespace Ex3 {
    fld_lines:
        ldx fld_count
    fld_loop:
        lda $D012
    wait_line:
        cmp $D012
        beq wait_line
        lda $D011
        clc
        adc #1
        and #7
        ora #$10
        sta $D011
        dex
        bne fld_loop
        rts

    fld_count: .byte 8
}

// --- ESERCIZIO 4: 2-Layer Parallax Charset Switching ---
.segment Ex4
.namespace Ex4 {
    start:
        // Split 1 (Top layer)
        lda #$18
        sta $D018
        // Split 2 (Bottom layer)
        lda #$1C
        sta $D018
        rts
}

// --- ESERCIZIO 5: Hardware Scroll + Double Buffering ---
.segment Ex5
.namespace Ex5 {
    start:
        jsr Ex1.start
        jsr Ex2.start
        rts
}
