; =============================================
; SOLUZIONI Capitolo 1 — Introduzione
; =============================================
;
; Mappa esercizi:
;   1: bordo giallo, sfondo blu
;   2: bordo verde, ciclo infinito
;   3: label GAMELOOP invece di LOOP
;   4: bordo nero, sfondo bianco
;   5: bordo blu chiaro, ciclo infinito FINISH
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

; --- ESERCIZIO 4: bordo nero, sfondo bianco ---
*=$C000
    LDA #0      ; nero
    STA $D020   ; bordo
    LDA #1      ; bianco
    STA $D021   ; sfondo
    RTS

; --- ESERCIZIO 5: bordo blu chiaro, ciclo infinito FINISH ---
*=$C000
    LDA #14     ; blu chiaro
    STA $D020   ; bordo
FINISH
    JMP FINISH
