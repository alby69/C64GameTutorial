// Converted to Kick Assembler syntax
.segmentdef Ex1 [start=$c000]
.segmentdef Ex2 [start=$c000]
.segmentdef Ex3 [start=$c000]
.segmentdef Ex4 [start=$c000]
.segmentdef Ex5 [start=$c000]

// --- Shared Constants ---
.const BORDER = $D020

// =============================================
// SOLUZIONI Capitolo 35 — Self-Modifying Code (SMC)
// --- METADATA ---
// chapter: 35
// title: Self-Modifying Code
// difficulty: master
// --- END METADATA ---
// =============================================

// --- ESERCIZIO 1: Contatore SMC su operando immediato ---
.segment Ex1
.namespace Ex1 {
    start:
        inc smc_lda+1       // incrementa l'operando dell'istruzione lda #0
    smc_lda:
        lda #0
        sta BORDER
        rts
}

// --- ESERCIZIO 2: Elimina puntatore indiretto via SMC ---
.segment Ex2
.namespace Ex2 {
    set_pointer:
        sta smc_read+1      // low byte
        sty smc_read+2      // high byte
        rts

    smc_read:
        lda $1000           // operand sovrascritto da set_pointer
        sta $0400
        rts
}

// --- ESERCIZIO 3: Jump Table dinamica ---
.segment Ex3
.namespace Ex3 {
    set_target:
        sta smc_jmp+1       // low byte
        sty smc_jmp+2       // high byte
        rts

    smc_jmp:
        jmp $0000           // target modificato a runtime
}

// --- ESERCIZIO 4: Byte-eating con bit $2C ---
.segment Ex4
.namespace Ex4 {
    start:
        lda #1
        .byte $2C           // bit $xxxx -> consuma i 2 byte successivi (lda #2)
        lda #2
        sta BORDER
        rts
}

// --- ESERCIZIO 5: State Machine via SMC ---
.segment Ex5
.namespace Ex5 {
    set_state:
        sta smc_jsr+1
        sty smc_jsr+2
        rts

    update:
    smc_jsr:
        jsr state_title
        rts

    state_title:
        inc BORDER
        rts

    state_game:
        dec BORDER
        rts
}
