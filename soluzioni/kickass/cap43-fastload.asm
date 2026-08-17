// Converted to Kick Assembler syntax
.segmentdef Ex1 [start=$c000]
.segmentdef Ex2 [start=$c000]
.segmentdef Ex3 [start=$c000]
.segmentdef Ex4 [start=$c000]
.segmentdef Ex5 [start=$c000]

// --- Shared Constants ---
.const SCREEN_RAM = $0400

// =============================================
// SOLUZIONI Capitolo 43 — Compressione e Fast Loader IRQ
// --- METADATA ---
// chapter: 43
// title: Compressione e Fast Loader IRQ
// difficulty: master
// --- END METADATA ---
// =============================================

// --- ESERCIZIO 1: RLE Decruncher ---
.segment Ex1
.namespace Ex1 {
    decrunch_rle:
        ldx #0
        ldy #0
    loop:
        lda compressed_data,x
        cmp #$FF            // Termina
        beq done
        sta count
        inx
        lda compressed_data,x
        inx
    write_loop:
        sta SCREEN_RAM,y
        iny
        dec count
        bne write_loop
        jmp loop
    done:
        rts

    count: .byte 0
    compressed_data: .byte 5, 65, 10, 66, $FF  // 5 'A', 10 'B'
}

// --- ESERCIZIO 2: Exomizer Mem2Mem Decruncher Stub ---
.segment Ex2
.namespace Ex2 {
    exomizer_decrunch:
        // Exomizer 6502 decruncher entry point
        rts
}

// --- ESERCIZIO 3: IRQ Serial Fast Loader ---
.segment Ex3
.namespace Ex3 {
    irq_loader:
        // Legge 1 byte dal serial bus durante VBLANK
        lda $DD00
        and #$C0
        rts
}

// --- ESERCIZIO 4: Double Buffering Level Map ---
.segment Ex4
.namespace Ex4 {
    swap_buffers:
        lda active_buf
        eor #1
        sta active_buf
        rts

    active_buf: .byte 0
}

// --- ESERCIZIO 5: Background Music Streaming ---
.segment Ex5
.namespace Ex5 {
    stream_chunk:
        jsr Ex3.irq_loader
        sta stream_buffer,x
        inx
        rts

    stream_buffer: .fill 64, 0
}
