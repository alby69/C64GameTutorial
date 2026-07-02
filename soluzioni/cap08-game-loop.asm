; =============================================
; SOLUZIONI Capitolo 8 — Game Loop Sincronizzato
; =============================================
;
; Mappa esercizi:
;   1: frame counter sul bordo
;   2: sprite 1 pixel a destra ogni frame = 50 px/s
;   3: alterna pointer 192/193 ogni 4 frame
;   4: messaggio lampeggia ogni 25 frame
;   5: programma integrato in raster IRQ 50 Hz
;
; =============================================
; --- ESERCIZIO 1: frame counter sul bordo ---
FRAME_CNT = $02
*=$C000
    LDA #0
    STA FRAME_CNT
LOOP1
    INC FRAME_CNT
    LDA FRAME_CNT
    STA $D020      ; valore esadecimale sul bordo
    JSR WAIT
    JMP LOOP1

WAIT
    LDA $D012
    CMP #$F8
    BNE WAIT
    RTS

; --- ESERCIZIO 2: sprite 1 pixel a destra ogni frame = 50 px/s ---
*=$9000
    LDA #%00000001
    STA $D015
    LDA #1
    STA $D027
    LDA #128
    STA $07F8
    LDA #50
    STA $D000
    LDA #100
    STA $D001

LOOP2
    JSR WAIT2
    INC $D000
    JMP LOOP2

WAIT2
    LDA $D012
    CMP #$F8
    BNE WAIT2
    RTS

; --- ESERCIZIO 3: alterna pointer 192/193 ogni 4 frame ---
FRAME = $02
*=$A000
    LDA #%00000001
    STA $D015
    LDA #7
    STA $D027
    LDA #192
    STA $07F8
    LDA #160
    STA $D000
    LDA #100
    STA $D001
    LDA #0
    STA FRAME

LOOP3
    JSR WAIT3
    INC FRAME
    LDA FRAME
    AND #4
    BEQ FRAME0
    LDA #193
    JMP SETP

FRAME0
    LDA #192
SETP
    STA $07F8
    JMP LOOP3

WAIT3
    LDA $D012
    CMP #$F8
    BNE WAIT3
    RTS

; --- ESERCIZIO 4: messaggio lampeggia ogni 25 frame ---
FRAME2 = $02
*=$B000
    LDA #1         ; 'A' a schermo
    STA $0400
    LDA #1         ; colore bianco
    STA $D800
    LDA #0
    STA FRAME2

LOOP4
    JSR WAIT4
    INC FRAME2
    LDA FRAME2
    CMP #25
    BNE LOOP4

    LDA $D800
    EOR #$0F       ; cambia colore
    STA $D800
    LDA #0
    STA FRAME2
    JMP LOOP4

WAIT4
    LDA $D012
    CMP #$F8
    BNE WAIT4
    RTS

; --- ESERCIZIO 5: programma integrato in raster IRQ 50 Hz ---
FRAME3 = $02
*=$C000
    SEI
    LDA #$7F
    STA $DC0D
    LDA #<GAME_IRQ
    STA $0314
    LDA #>GAME_IRQ
    STA $0315
    LDA #200
    STA $D012
    LDA $D011
    AND #$7F
    STA $D011
    LDA #1
    STA $D01A
    CLI

    LDA #%00000001
    STA $D015
    LDA #1
    STA $D027
    LDA #128
    STA $07F8
    LDA #50
    STA $D000
    LDA #100
    STA $D001
    LDA #0
    STA FRAME3

MAIN
    JMP MAIN

GAME_IRQ
    PHA
    TXA
    PHA
    TYA
    PHA

    INC FRAME3
    INC $D000       ; 1 px/frame

    PLA
    TAY
    PLA
    TAX
    PLA

    LDA $D019
    STA $D019
    JMP $EA31
