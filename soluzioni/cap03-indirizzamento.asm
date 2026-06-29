; =============================================
; SOLUZIONI Capitolo 3 — Indirizzamento e Cicli
; =============================================
;
; Mappa esercizi:
;   1: 'A' in riga 10, col 15, colore verde
;   2: A B C D nelle prime 4 celle
;   3: prima riga con '*', ogni cella colore diverso
;   4: tabella 0-9 nelle prime 10 posizioni
;   5: messaggio 4 lettere scorre a destra ogni secondo
;
; =============================================
; --- ESERCIZIO 1: 'A' in riga 10, col 15, colore verde ---
; Formula: SCREEN_RAM + riga*40 + colonna = $0400 + 10*40 + 15
;         = $0400 + 400 + 15 = $0400 + $190 + $F = $059F
*=$8000
    LDA #1         ; codice PETSCII 'A'
    STA $059F
    LDA #5         ; verde
    STA $D9DF      ; Color RAM: $D800 + offset ($59F)
    RTS

; --- ESERCIZIO 2: A B C D nelle prime 4 celle ---
*=$8000
    LDA #1         ; 'A'
    STA $0400
    LDA #2         ; 'B'
    STA $0401
    LDA #3         ; 'C'
    STA $0402
    LDA #4         ; 'D'
    STA $0403
    RTS

; --- ESERCIZIO 3: prima riga con '*', ogni cella colore diverso ---
*=$8000
    LDX #0
    LDA #42        ; codice '*'
LOOP
    STA $0400,X    ; screen RAM iniziando da $0400
    TXA
    STA $D800,X    ; Color RAM: colore = indice colonna
    INX
    CPX #40
    BNE LOOP
    RTS

; --- ESERCIZIO 4: tabella 0-9 nelle prime 10 posizioni ---
*=$8000
    LDX #0
    LDA #48        ; PETSCII '0'
LOOP4
    STA $0400,X
    CLC
    ADC #1         ; carattere successivo
    INX
    CPX #10
    BNE LOOP4
    RTS

; --- ESERCIZIO 5: messaggio 4 lettere scorre a destra ogni secondo ---
*=$8000
    LDX #0
SHIFT
    JSR DELAY
    INX
    CPX #36        ; 40-4 = posizione massima
    BNE SHIFT
    LDX #0
    JMP SHIFT

DELAY
    LDY #$FF
D1  LDX #$FF
D2  NOP
    DEX
    BNE D2
    DEY
    BNE D1
    RTS
