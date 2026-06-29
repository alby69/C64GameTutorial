; =============================================
; SOLUZIONI Capitolo 1 — Introduzione
; =============================================

; --- ESERCIZIO 1: bordo giallo, sfondo blu ---
*=$8000
    LDA #7      ; giallo
    STA $D020   ; bordo
    LDA #6      ; blu
    STA $D021   ; sfondo
    RTS

; --- ESERCIZIO 2: bordo verde, ciclo infinito ---
*=$8000
    LDA #5      ; verde
    STA $D020   ; bordo
LOOP
    JMP LOOP    ; programma resta in esecuzione

; --- ESERCIZIO 3: label GAMELOOP invece di LOOP ---
*=$8000
    LDA #5
    STA $D020
GAMELOOP
    JMP GAMELOOP
