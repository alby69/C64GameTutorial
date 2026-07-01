; =============================================
; SOLUZIONI Capitolo 1 — Introduzione
; =============================================
;
; Mappa esercizi:
;   1: bordo giallo, sfondo blu
;   2: bordo verde, ciclo infinito
;   3: label GAMELOOP invece di LOOP
;   4: bordo cicla attraverso tutti i colori 0-15
;   5: struttura MAIN/UPDATE con JSR/RTS
;
; =============================================

; --- ESERCIZIO 1: bordo giallo, sfondo blu ---
*=$C000
    LDA #7      ; giallo
    STA $D020   ; bordo
    LDA #6      ; blu
    STA $D021   ; sfondo
    RTS

; --- ESERCIZIO 2: bordo verde, ciclo infinito ---
*=$C000
    LDA #5      ; verde
    STA $D020   ; bordo
LOOP
    JMP LOOP    ; programma resta in esecuzione

; --- ESERCIZIO 3: label GAMELOOP invece di LOOP ---
*=$C000
    LDA #5
    STA $D020
GAMELOOP
    JMP GAMELOOP

; --- ESERCIZIO 4: bordo cicla attraverso tutti i colori 0-15 ---
*=$C000
    LDA #0
LOOP4
    STA $D020
    INC
    INC $D020
    CMP #16
    BNE LOOP4
    JMP LOOP4

; --- ESERCIZIO 5: struttura MAIN/UPDATE con JSR/RTS ---
*=$C000
MAIN
    JSR UPDATE
    JMP MAIN
UPDATE
    INC $D020
    RTS
