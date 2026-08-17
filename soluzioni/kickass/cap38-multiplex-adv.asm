// Converted to Kick Assembler syntax
.segmentdef Ex1 [start=$c000]
.segmentdef Ex2 [start=$c000]
.segmentdef Ex3 [start=$c000]
.segmentdef Ex4 [start=$c000]
.segmentdef Ex5 [start=$c000]

// --- Shared Constants ---
.const MAX_VSPRITES = 16
.const VIC_SPRITE_Y = $D001
.const BORDER = $D020

// =============================================
// SOLUZIONI Capitolo 38 — Sprite Multiplexing Avanzato
// --- METADATA ---
// chapter: 38
// title: Sprite Multiplexing Avanzato
// difficulty: master
// --- END METADATA ---
// =============================================

// --- ESERCIZIO 1: Insertion Sort 6502 per Y-coords ---
.segment Ex1
.namespace Ex1 {
    insertion_sort:
        ldx #1
    outer_loop:
        lda spr_y,x
        sta temp_y
        lda spr_id,x
        sta temp_id
        stx ptr
    inner_loop:
        ldy ptr
        dey
        bmi place
        lda spr_y,y
        cmp temp_y
        bcc place
        // Shift right
        sta spr_y+1,y
        lda spr_id,y
        sta spr_id+1,y
        dec ptr
        jmp inner_loop
    place:
        ldy ptr
        lda temp_y
        sta spr_y+1,y
        lda temp_id
        sta spr_id+1,y
        inx
        cpx #MAX_VSPRITES
        bne outer_loop
        rts

    spr_y: .fill MAX_VSPRITES, 200 - i * 10
    spr_id: .fill MAX_VSPRITES, i
    temp_y: .byte 0
    temp_id: .byte 0
    ptr: .byte 0
}

// --- ESERCIZIO 2: Persistent HW Slot Binding ---
.segment Ex2
.namespace Ex2 {
    bind_slots:
        ldx #0
    !:  lda hw_slot,x
        sta last_hw_slot,x
        inx
        cpx #8
        bne !-
        rts

    hw_slot: .fill 8, i
    last_hw_slot: .fill 8, 0
}

// --- ESERCIZIO 3: 3-Zone Raster Multiplexing ---
.segment Ex3
.namespace Ex3 {
    zone1_irq:
        lda #50
        sta $D012
        rts
    zone2_irq:
        lda #120
        sta $D012
        rts
    zone3_irq:
        lda #190
        sta $D012
        rts
}

// --- ESERCIZIO 4: MSB Management across 32 VSprites ---
.segment Ex4
.namespace Ex4 {
    update_msb:
        lda #0
        sta msb_temp
        ldx #0
    !:  lda vspr_x_hi,x
        beq !next+
        sec
        rol msb_temp
        jmp !+
    !next:
        clc
        rol msb_temp
    !:  inx
        cpx #8
        bne !--
        lda msb_temp
        sta $D010
        rts

    vspr_x_hi: .fill 8, i & 1
    msb_temp: .byte 0
}

// --- ESERCIZIO 5: Cycle Profiling with $D020 ---
.segment Ex5
.namespace Ex5 {
    profile_sort:
        inc BORDER
        jsr Ex1.insertion_sort
        dec BORDER
        rts
}
