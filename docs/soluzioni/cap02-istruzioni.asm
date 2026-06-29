; =============================================
; SOLUZIONI Capitolo 2 — Istruzioni Fondamentali
; =============================================
;
; Mappa esercizi:
;   1: bordo incrementa 0→15 poi fermo
;   2: contatore in Zero Page
;   3: delay ~1 secondo (3 cicli annidati)
;   4: sfondo lampeggia blu/nero ogni secondo
;   5: rainbow effetto (bordo cicla con delay)
;
; =============================================

; --- ESERCIZIO 1: bordo incrementa 0→15 poi fermo ---
*=$8000
    LDA #0
LOOP
    STA $D020
    INC            ; non serve A, INC $D020
    INC $D020      ; incrementa registro bordo
    LDA $D020
    CMP #15
    BEQ DONE
    JMP LOOP
DONE
    JMP DONE

; Versione piu pulita:
*=$8000
    LDA #0
LOOP2
    STA $D020
    INC $D020
    LDA $D020
    CMP #16        ; fermati a 16 (0-15)
    BNE LOOP2
HALT
    JMP HALT

; --- ESERCIZIO 2: contatore in Zero Page ---
COUNTER = $02     ; variabile in Zero Page
*=$8000
    LDA #0
    STA COUNTER
LOOP3
    LDA COUNTER
    STA $D020
    INC COUNTER
    LDA COUNTER
    CMP #16
    BNE LOOP3
DONE3
    JMP DONE3

; --- ESERCIZIO 3: delay ~1 secondo (3 cicli annidati) ---
*=$8000
DELAY
    LDX #$FF       ; ciclo esterno
OUTER
    LDY #$FF       ; ciclo medio
MID
    NOP
    NOP
    NOP
    NOP
    NOP
    DEY
    BNE MID
    DEX
    BNE OUTER
    RTS

; --- ESERCIZIO 5: rainbow effetto (bordo cicla con delay) ---
*=$8000
    LDA #0
LOOP5
    STA $D020
    JSR DELAY5
    INC $D020
    JMP LOOP5
DELAY5
    LDX #$20
D15
    LDY #$FF
D25
    DEY
    BNE D25
    DEX
    BNE D15
    RTS

; --- ESERCIZIO 4: sfondo lampeggia blu/nero ogni secondo ---
*=$8000
MAIN
    LDA #6         ; blu
    STA $D021
    JSR DELAY
    LDA #0         ; nero
    STA $D021
    JSR DELAY
    JMP MAIN

DELAY
    LDX #$FF
OUTER2
    LDY #$FF
MID2
    NOP
    DEY
    BNE MID2
    DEX
    BNE OUTER2
    RTS
