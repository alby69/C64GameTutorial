// Converted to Kick Assembler syntax
.segmentdef Ex1 [start=$c000]

// --- Shared Constants ---
.const SERIAL_PORT = $DD00
.const SCREEN_RAM = $0400
.const COLOR_RAM = $D800
.const COLOR_CYAN = 3
.const CIRC_BUF = $3000

// ─────────────────────────────────────────────────────
// Soluzioni esercizi Capitolo 25 — Turbo Loader
// --- METADATA ---
// chapter: 25
// title: Turbo Loader
// difficulty: master
// --- END METADATA ---
// ─────────────────────────────────────────────────────


// *=$C000

// ─────────────────────────────────────────────────────
// Esercizio 1 — Lettura byte dal serial bus ($DD00)
// ─────────────────────────────────────────────────────
// Legge 8 bit dal serial bus (bit DATA in = bit 6)
// Output: A = byte letto (MSB first)

READ_SERIAL_BYTE:

    ldx #8
RSB_LOOP:

    lda SERIAL_PORT
    and #$40          // bit 6 = DATA in
    beq RSB_ZERO
    // Bit = 1
    rol TEMP_BYTE
    sec
    jmp RSB_NEXT
RSB_ZERO:

    // Bit = 0
    rol TEMP_BYTE
    clc
RSB_NEXT:

    dex
    bne RSB_LOOP
    lda TEMP_BYTE
    rts

TEMP_BYTE:

    .byte 0

// ─────────────────────────────────────────────────────
// Esercizio 2 — Tabella decodifica GCR
// ─────────────────────────────────────────────────────
// Input: A = byte GCR (5 bit)
// Output: A = nibble (4 bit)

GCR_DECODE_TABLE:

    // Indice: byte GCR, valore: nibble
    // 256 voci, $FF = invalido
    .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .byte $FF, $08     // $28 = 1000
    .byte $FF, $09     // $29 = 1001
    .byte $FF, $0A     // $2A = 1010
    .byte $FF, $0B     // $2B = 1011
    .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .byte $FF, $0C     // $34 = 1100
    .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .byte $FF, $0F     // $3C = 1111
    .byte $FF, $0D     // $3D = 1101
    .byte $FF, $0E     // $3E = 1110
    .byte $0F, $0F     // $3F ???

GCR_DECODE:

    tax
    lda GCR_DECODE_TABLE,X
    rts

// ─────────────────────────────────────────────────────
// Esercizio 3 — Caricatore IRQ (byte per frame)
// ─────────────────────────────────────────────────────
// Usato in raster IRQ: chiamare IRQ_LOADER_TICK ogni frame
// Usa buffer circolare di 256 byte

IRQ_LOADER_TICK:

    lda LOAD_STATE
    cmp #0
    beq ILT_SYNC
    cmp #1
    beq ILT_BYTE
    rts

ILT_SYNC:

    // Cerca sync mark (sequenza di bit=1)
    lda SERIAL_PORT
    and #$40
    bne ILT_SYNC
    // Sync trovata
    lda #1
    sta LOAD_STATE
    rts

ILT_BYTE:

    // Legge 8 bit
    ldx #8
ILT_BIT:

    lda SERIAL_PORT
    and #$40
    beq ILT_ZERO
    // Bit = 1
    rol GCR_BUF
    sec
    jmp ILT_NEXT
ILT_ZERO:

    // Bit = 0
    rol GCR_BUF
    clc
ILT_NEXT:

    dex
    bne ILT_BIT

    // Decodifica GCR
    lda GCR_BUF
    jsr GCR_DECODE

    // Salva in buffer circolare
    ldx WRITE_IDX
    sta CIRC_BUF,X
    inx
    stx WRITE_IDX

    lda #0
    sta LOAD_STATE
    rts

LOAD_STATE:

    .byte 0
GCR_BUF:

    .byte 0
WRITE_IDX:

    .byte 0

// ─────────────────────────────────────────────────────
// Esercizio 4 — Barra di progresso
// ─────────────────────────────────────────────────────
// Durante caricamento, mostra barra nella riga 23

UPDATE_PROGRESS:

    ldx LD_BYTE_COUNT
    lda #$A0          // carattere blocco
    sta SCREEN_RAM+40*23,X
    lda #COLOR_CYAN   // usa # per il valore immediato
    sta COLOR_RAM+40*23,X
    inc LD_BYTE_COUNT
    rts

LD_BYTE_COUNT:

    .byte 0
