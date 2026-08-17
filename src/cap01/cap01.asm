// =============================================
// CAP01 — Primo programma / First program
// Comandi: LDA, STA, JMP, RTS
// Difficulty: Beginner
// =============================================

// Genera un header BASIC che lancia il codice con SYS
:BasicUpstart2(start)

start:
    // Cambia colore bordo a rosso (2)
    lda #2
    sta $D020

    // Cambia colore sfondo a nero (0)
    lda #0
    sta $D021

    // Ciclo infinito (tipico dei giochi)
loop:
    jmp loop
