; ─────────────────────────────────────────────────────
; Soluzioni esercizi Capitolo 25 — Turbo Loader
; ─────────────────────────────────────────────────────

; ─────────────────────────────────────────────────────
; Esercizio 1 — Lettura byte dal serial bus ($DD00)
; ─────────────────────────────────────────────────────
; Legge 8 bit dal serial bus (bit DATA in = bit 6)
; Output: A = byte letto (MSB first)

SERIAL_PORT = $DD00

READ_SERIAL_BYTE
    LDX #8
RSB_LOOP
    LDA SERIAL_PORT
    AND #$40          ; bit 6 = DATA in
    BEQ RSB_ZERO
    ; Bit = 1
    ROL TEMP_BYTE
    SEC
    JMP RSB_NEXT
RSB_ZERO
    ; Bit = 0
    ROL TEMP_BYTE
    CLC
RSB_NEXT
    DEX
    BNE RSB_LOOP
    LDA TEMP_BYTE
    RTS

TEMP_BYTE
    .byte 0

; ─────────────────────────────────────────────────────
; Esercizio 2 — Tabella decodifica GCR
; ─────────────────────────────────────────────────────
; Input: A = byte GCR (5 bit)
; Output: A = nibble (4 bit)

GCR_DECODE_TABLE
    ; Indice: byte GCR, valore: nibble
    ; 256 voci, $FF = invalido
    .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .byte $FF, $08     ; $28 = 1000
    .byte $FF, $09     ; $29 = 1001
    .byte $FF, $0A     ; $2A = 1010
    .byte $FF, $0B     ; $2B = 1011
    .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .byte $FF, $0C     ; $34 = 1100
    .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .byte $FF, $0F     ; $3C = 1111
    .byte $FF, $0D     ; $3D = 1101
    .byte $FF, $0E     ; $3E = 1110
    .byte $0F, $0F     ; $3F ???

GCR_DECODE
    TAX
    LDA GCR_DECODE_TABLE,X
    RTS

; ─────────────────────────────────────────────────────
; Esercizio 3 — Caricatore IRQ (byte per frame)
; ─────────────────────────────────────────────────────
; Usato in raster IRQ: chiamare IRQ_LOADER_TICK ogni frame
; Usa buffer circolare di 256 byte

IRQ_LOADER_TICK
    LDA LOAD_STATE
    CMP #0
    BEQ ILT_SYNC
    CMP #1
    BEQ ILT_BYTE
    RTS

ILT_SYNC
    ; Cerca sync mark (sequenza di bit=1)
    LDA SERIAL_PORT
    AND #$40
    BNE ILT_SYNC
    ; Sync trovata
    LDA #1
    STA LOAD_STATE
    RTS

ILT_BYTE
    ; Legge 8 bit
    LDX #8
ILT_BIT
    LDA SERIAL_PORT
    AND #$40
    BEQ ILT_ZERO
    ; Bit = 1
    ROL GCR_BUF
    SEC
    JMP ILT_NEXT
ILT_ZERO
    ; Bit = 0
    ROL GCR_BUF
    CLC
ILT_NEXT
    DEX
    BNE ILT_BIT

    ; Decodifica GCR
    LDA GCR_BUF
    JSR GCR_DECODE

    ; Salva in buffer circolare
    LDX WRITE_IDX
    STA CIRC_BUF,X
    INX
    STX WRITE_IDX

    LDA #0
    STA LOAD_STATE
    RTS

LOAD_STATE
    .byte 0
GCR_BUF
    .byte 0
WRITE_IDX
    .byte 0
CIRC_BUF = * + 1

; ─────────────────────────────────────────────────────
; Esercizio 4 — Barra di progresso
; ─────────────────────────────────────────────────────
; Durante caricamento, mostra barra nella riga 23

UPDATE_PROGRESS
    LDX LD_BYTE_COUNT
    LDA #$A0          ; carattere blocco
    STA SCREEN_RAM+40*23,X
    LDA COLOR_CYAN
    STA COLOR_RAM+40*23,X
    INC LD_BYTE_COUNT
    RTS

SCREEN_RAM = $0400
COLOR_RAM  = $D800
COLOR_CYAN = 3
LD_BYTE_COUNT
    .byte 0
