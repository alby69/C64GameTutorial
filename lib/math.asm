// =============================================
// MATH — Routine matematiche base
// =============================================

// Ritorna un valore pseudo-random in A
randomByte: {
    lda seed
    asl
    eor seed
    sta seed
    rts
seed: .byte $4F
}
