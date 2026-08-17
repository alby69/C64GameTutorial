// Converted to Kick Assembler syntax
.segmentdef Ex1 [start=$c000]
.segmentdef Ex2 [start=$c000]
.segmentdef Ex3 [start=$c000]
.segmentdef Ex4 [start=$c000]
.segmentdef Ex5 [start=$c000]

// --- Shared Constants ---
.const VIC_MEMORY_CONTROL = $D018
.const SCREEN_RAM = $0400
.const CHARSET_RAM = $2000

// =============================================
// SOLUZIONI Capitolo 33 — Custom Charset
// --- METADATA ---
// chapter: 33
// title: Custom Charset e Tilemap
// difficulty: advanced
// --- END METADATA ---
// =============================================

// --- ESERCIZIO 1: Punta a custom charset $2000 e riempi con tile 0 ---
.segment Ex1
.namespace Ex1 {
    start:
        lda #$18            // Screen $0400, Charset $2000
        sta VIC_MEMORY_CONTROL

        ldx #0
        lda #0
    fill_loop:
        sta SCREEN_RAM,x
        sta SCREEN_RAM+$100,x
        sta SCREEN_RAM+$200,x
        sta SCREEN_RAM+$2E8,x
        inx
        bne fill_loop
        rts
}

// --- ESERCIZIO 2: Disegna mappa 10x10 con 4 tile ---
.segment Ex2
.namespace Ex2 {
    start:
        lda #$18
        sta VIC_MEMORY_CONTROL

        ldy #0
    row_loop:
        ldx #0
    col_loop:
        txa
        and #3              // alterna tra tile 0, 1, 2, 3
        sta SCREEN_RAM,x
        inx
        cpx #10
        bne col_loop
        iny
        cpy #10
        bne row_loop
        rts
}

// --- ESERCIZIO 3: Animazione tile acqua in $2000 ---
.segment Ex3
.namespace Ex3 {
    start:
        lda CHARSET_RAM
        rol
        sta CHARSET_RAM     // ruota byte per effetto scorrimento acqua
        rts
}

// --- ESERCIZIO 4: Caricamento charset custom e stringa ---
.segment Ex4
.namespace Ex4 {
    start:
        lda #$18
        sta VIC_MEMORY_CONTROL
        ldx #0
    msg_loop:
        lda msg,x
        beq done
        sta SCREEN_RAM,x
        inx
        jmp msg_loop
    done:
        rts

    msg: .text "TITLE SCREEN"
         .byte $00
}

// --- ESERCIZIO 5: Switch tra due charset ($2000 e $3800) ---
.segment Ex5
.namespace Ex5 {
    start:
        lda state
        eor #1
        sta state
        beq set_day

    set_night:
        lda #$1E            // Charset $3800
        sta VIC_MEMORY_CONTROL
        rts

    set_day:
        lda #$18            // Charset $2000
        sta VIC_MEMORY_CONTROL
        rts

    state: .byte 0
}
