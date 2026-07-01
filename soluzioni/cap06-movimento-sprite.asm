; =============================================
; SOLUZIONI Capitolo 6 — Movimento Sprite
; =============================================
;
; Mappa esercizi:
;   1: sprite sinistra→destra, rimbalzo X=50↔250
;   2: movimento diagonale
;   3: cambio colore a ogni rimbalzo
;   4: animazione 4 frame alieno ogni 8 iterazioni
;   5: 3 sprite allineati in formazione
;
; =============================================
; --- ESERCIZIO 1: sprite sinistra→destra, rimbalzo X=50↔250 ---
SPRITE_X = $D000
SPRITE_Y = $D001
*=$C000
    LDA #%00000001
    STA $D015
    LDA #1
    STA $D027
    LDA #128
    STA $07F8
    LDA #50
    STA SPRITE_X
    LDA #100
    STA SPRITE_Y

LOOP
    INC SPRITE_X
    LDA SPRITE_X
    CMP #250
    BCC LOOP
    LDA #50
    STA SPRITE_X
    JMP LOOP

; --- ESERCIZIO 2: movimento diagonale ---
*=$9000
    LDA #%00000001
    STA $D015
    LDA #1
    STA $D027
    LDA #128
    STA $07F8
    LDA #50
    STA $D000
    LDA #50
    STA $D001

LOOP2
    INC $D000
    INC $D001
    LDA $D000
    CMP #250
    BCC LOOP2
    LDA #50
    STA $D000
    LDA #50
    STA $D001
    JMP LOOP2

; --- ESERCIZIO 3: cambio colore a ogni rimbalzo ---
SPR_COL = $D027
*=$A000
    LDA #%00000001
    STA $D015
    LDA #128
    STA $07F8
    LDA #50
    STA $D000
    LDA #100
    STA $D001
    LDA #1
    STA SPR_COL

LOOP3
    INC $D000
    LDA $D000
    CMP #250
    BNE LOOP3
    INC SPR_COL
    LDA SPR_COL
    AND #$0F
    STA SPR_COL
    LDA #50
    STA $D000
    JMP LOOP3

; --- ESERCIZIO 4: animazione 4 frame alieno ogni 8 iterazioni ---
FRAME = $02
COUNT = $03
*=$B000
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
    STA COUNT

LOOP4
    INC COUNT
    LDA COUNT
    AND #7
    BNE NO_ANIM

    INC FRAME
    LDA FRAME
    AND #3
    CLC
    ADC #192
    STA $07F8

NO_ANIM
    JMP LOOP4

; Dati animazione a $C000-$C0FF
*=$C000
    ; frame 0 (ali su)
    .byte %00000000, %00111100, %00000000
    .byte %00000001, %11111111, %10000000
    .byte %00000011, %11111111, %11000000
    .byte %00000111, %10011001, %11100000
    .byte %00001111, %11111111, %11110000
    .byte %00011111, %11111111, %11111000
    .byte %00111111, %11111111, %11111100
    .byte %00011111, %11111111, %11111000
    .byte %00001111, %11111111, %11110000
    .byte %00000111, %11111111, %11100000
    .byte %00000011, %11111111, %11000000
    .byte %00000001, %11111111, %10000000
    .byte %00000000, %01111110, %00000000
    .byte %00000000, %00111100, %00000000
    .byte %00000000, %00011000, %00000000
    .byte %00000000, %00011000, %00000000
    .byte %00000000, %00011000, %00000000
    .byte %00000000, %00011000, %00000000
    .byte %00000000, %00011000, %00000000
    .byte %00000000, %00011000, %00000000
    .byte %00000000, %00011000, %00000000
    ; frame 1-3: versioni modificate (stessa struttura)
*=$C100
    .byte %00000000, %00111100, %00000000
    .byte %00000001, %11111111, %10000000
    .byte %00000011, %11111111, %11000000
    .byte %00000111, %10011001, %11100000
    .byte %00001111, %11111111, %11110000
    .byte %00011111, %11111111, %11111000
    .byte %00111111, %11111111, %11111100
    .byte %00011111, %11111111, %11111000
    .byte %00001111, %11111111, %11110000
    .byte %00000111, %11111111, %11100000
    .byte %00000011, %11111111, %11000000
    .byte %00000001, %11111111, %10000000
    .byte %00000000, %01111110, %00000000
    .byte %00000000, %10111101, %00000000
    .byte %00000001, %10011001, %10000000
    .byte %00000000, %10011001, %00000000
    .byte %00000000, %01011010, %00000000
    .byte %00000000, %00111100, %00000000
    .byte %00000000, %00011000, %00000000
    .byte %00000000, %00011000, %00000000
    .byte %00000000, %00011000, %00000000

; --- ESERCIZIO 5: 3 sprite allineati in formazione ---
*=$D000
    LDA #%00000111
    STA $D015
    LDA #1
    STA $D027
    STA $D028
    STA $D029
    LDA #128
    STA $07F8
    STA $07F9
    STA $07FA

    LDA #60
    STA $D001     ; Y sprite 0
    STA $D003     ; Y sprite 1
    STA $D005     ; Y sprite 2

    LDA #60
    STA $D000
    LDA #120
    STA $D002
    LDA #180
    STA $D004

LOOP5
    INC $D001
    INC $D003
    INC $D005
    JMP LOOP5
