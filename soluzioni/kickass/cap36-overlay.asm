// Converted to Kick Assembler syntax
.segmentdef Ex1 [start=$c000]
.segmentdef Ex2 [start=$c000]
.segmentdef Ex3 [start=$c000]
.segmentdef Ex4 [start=$c000]
.segmentdef Ex5 [start=$c000]

// --- Shared Constants ---
.const CPU_PORT = $01

// =============================================
// SOLUZIONI Capitolo 36 — Memory Overlay & Bank Switching
// --- METADATA ---
// chapter: 36
// title: Memory Overlay & Bank Switching
// difficulty: master
// --- END METADATA ---
// =============================================

// --- ESERCIZIO 1: Bank out BASIC ROM ($01 = $36) ---
.segment Ex1
.namespace Ex1 {
    start:
        sei
        lda #$36            // BASIC off, KERNAL on, I/O on
        sta CPU_PORT
        lda #$AA
        sta $A000           // scrivi in RAM sotto la ROM BASIC
        cmp $A000
        cli
        rts
}

// --- ESERCIZIO 2: Bank out KERNAL e BASIC ($01 = $35) ---
.segment Ex2
.namespace Ex2 {
    start:
        sei
        lda #$35            // BASIC off, KERNAL off, I/O on
        sta CPU_PORT
        lda #$55
        sta $E000           // RAM sotto KERNAL
        cli
        rts
}

// --- ESERCIZIO 3: Switch temporaneo KERNAL per CHROUT ---
.segment Ex3
.namespace Ex3 {
    print_char:
        pha
        sei
        lda #$36            // KERNAL in
        sta CPU_PORT
        pla
        jsr $FFD2           // CHROUT
        sei
        lda #$35            // RAM full
        sta CPU_PORT
        cli
        rts
}

// --- ESERCIZIO 4: Memory Manager 2KB Allocator ---
.segment Ex4
.namespace Ex4 {
    alloc_2k:
        ldx free_ptr
        lda #1
        sta alloc_map,x
        inc free_ptr
        rts

    free_ptr: .byte 0
    alloc_map: .fill 16, 0
}

// --- ESERCIZIO 5: Single-load bootloader overlay ---
.segment Ex5
.namespace Ex5 {
    start:
        sei
        lda #$35
        sta CPU_PORT
        // Copia codice da $0800 a $C000
        ldx #0
    copy_loop:
        lda $0800,x
        sta $C000,x
        inx
        bne copy_loop
        cli
        jmp $C000
}
