// Converted to Kick Assembler syntax
.segmentdef Ex1 [start=$c000]
.segmentdef Ex2 [start=$c000]
.segmentdef Ex3 [start=$c000]
.segmentdef Ex4 [start=$c000]
.segmentdef Ex5 [start=$c000]

// --- Shared Constants ---
.const VIC_CTRL1 = $D011
.const VIC_MEM = $D018
.const RASTER = $D012

// =============================================
// SOLUZIONI Capitolo 40 — FLI/FLD e Tecniche Demo-Scene
// --- METADATA ---
// chapter: 40
// title: FLI/FLD e Tecniche Demo-Scene
// difficulty: master
// --- END METADATA ---
// =============================================

// --- ESERCIZIO 1: FLD Vertical Push ---
.segment Ex1
.namespace Ex1 {
    fld_push:
        ldx #10
    !:  lda RASTER
    wait:
        cmp RASTER
        beq wait
        lda VIC_CTRL1
        clc
        adc #1
        and #7
        ora #$10
        sta VIC_CTRL1
        dex
        bne !-
        rts
}

// --- ESERCIZIO 2: FLI Core ($D018 per raster line) ---
.segment Ex2
.namespace Ex2 {
    fli_loop:
        ldx #0
    !:  lda fli_table,x
        sta VIC_MEM
        inx
        cpx #8
        bne !-
        rts

    fli_table: .byte $18, $1A, $1C, $1E, $18, $1A, $1C, $1E
}

// --- ESERCIZIO 3: Static FLI Picture Viewer Setup ---
.segment Ex3
.namespace Ex3 {
    init_fli:
        lda #$3B            // Bitmap mode + Multicolor
        sta VIC_CTRL1
        lda #$18
        sta VIC_MEM
        rts
}

// --- ESERCIZIO 4: FLD + Raster Bar Wave ---
.segment Ex4
.namespace Ex4 {
    wave_effect:
        jsr Ex1.fld_push
        inc $D020
        dec $D020
        rts
}

// --- ESERCIZIO 5: FLD Pause Screen ---
.segment Ex5
.namespace Ex5 {
    pause_screen:
        lda is_paused
        beq done
        jsr Ex1.fld_push
    done:
        rts

    is_paused: .byte 1
}
