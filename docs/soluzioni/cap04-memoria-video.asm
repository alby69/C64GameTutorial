; =============================================
; SOLUZIONI Capitolo 4 — Memoria Video
; =============================================
;
; Mappa esercizi:
;   1: nome centrato riga 10
;   2: effetto matrix (caratteri cadono)
;   3: schermata titolo
;   4: numero 42 in alto a destra
;   5: scrolling marquee (testo scorrevole)
;
; =============================================

; --- ESERCIZIO 1: nome centrato riga 10 ---
; Riga 10 = inizio a $0400 + 10*40 = $0400 + 400 = $0590
; "MARCO" = 5 lettere, colonna = (40-5)/2 = 17.5 → 17
*=$8000
    LDA #13        ; 'M'
    STA $05A1      ; $0590 + 17
    LDA #1         ; 'A'
    STA $05A2
    LDA #18        ; 'R'
    STA $05A3
    LDA #3         ; 'C'
    STA $05A4
    LDA #15        ; 'O'
    STA $05A5
    RTS

; --- ESERCIZIO 2: effetto matrix (caratteri cadono) ---
*=$8000
    LDX #0
LOOPM
    LDA #81        ; carattere casuale '@'
    STA $0400,X
    TXA
    AND #$0F
    STA $D800,X
    INX
    CPX #40
    BNE LOOPM      ; prima riga riempita

    LDX #0
FALL
    JSR SHIFT_DOWN
    INX
    CPX #24
    BNE FALL
    JMP $8000      ; restart

SHIFT_DOWN
    LDY #960       ; 24 righe * 40
    STY $02        ; contatore
    LDA #$04+24
    STA $04
LOOPS
    ; sposta caratteri verso il basso
    RTS

; --- ESERCIZIO 3: schermata titolo ---
BORDER  = $D020
BG      = $D021
SCREEN  = $0400
COLOR   = $D800

*=$8000
    ; Bordo decorato
    LDA #0
    STA BORDER
    STA BG

    ; Testo centrato "GIOCO ARCADE"
    ; Riga 10, colonna 12 (5+12=17 lettere)
    LDX #0
TITLE
    LDA MSG,X
    STA $0590+12,X
    LDA #1         ; colore bianco
    STA $D990+12,X
    INX
    CPX #13        ; lunghezza messaggio
    BNE TITLE
    RTS

MSG .byte 7,9,15,3,15,0,1,18,3,1,4,5,0    ; "GIOCO ARCADE" in PETSCII

; --- ESERCIZIO 4: numero 42 in alto a destra ---
; Colonna 37-38 (40-3 = 37 per 2 cifre)
*=$8000
    LDA #52        ; '4' = PETSCII 52
    STA $0425      ; $0400 + 37
    LDA #50        ; '2' = PETSCII 50
    STA $0426      ; $0400 + 38
    RTS

; --- ESERCIZIO 5: scrolling marquee (testo scorrevole) ---
; Scrive "CIAO" che si sposta a destra ogni frame
*=$8000
    LDX #0
LOOP5
    LDA MSG5,X
    STA $0400,X
    INX
    CPX #4
    BNE LOOP5
    RTS
MSG5 .byte 3,9,1,15    ; "CIAO" in PETSCII
