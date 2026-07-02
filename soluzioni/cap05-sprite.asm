; =============================================
; SOLUZIONI Capitolo 5 — Sprite Hardware
; =============================================
;
; Mappa esercizi:
;   1: astronave al centro (X=160, Y=100)
;   2: due sprite, bianco sinistra, rosso destra
;   3: alieno disegnato su carta poi convertito
;   4: sprite 0 a $3100 (calcolo pointer)
;   5: sprite con colore che cambia ogni frame
;
; =============================================

; --- ESERCIZIO 1: astronave al centro (X=160, Y=100) ---
*=$C000
    ; Abilita sprite 0
    LDA #%00000001
    STA $D015

    ; Colore bianco
    LDA #1
    STA $D027

    ; Posizione centrata
    LDA #160
    STA $D000        ; X
    LDA #100
    STA $D001        ; Y

    ; Sprite pointer a $2000 (pointer = $2000/64 = $80 = 128)
    LDA #128
    STA $07F8
    RTS

; Dati sprite a $2000 (astronave 24x21)
*=$2000
    .byte %00000000, %00011000, %00000000
    .byte %00000000, %00111100, %00000000
    .byte %00000000, %00111100, %00000000
    .byte %00000000, %01111110, %00000000
    .byte %00000000, %11111111, %00000000
    .byte %00000001, %11111111, %10000000
    .byte %00000011, %11111111, %11000000
    .byte %00000111, %11111111, %11100000
    .byte %00001111, %11111111, %11110000
    .byte %00011111, %11111111, %11111000
    .byte %00111111, %11111111, %11111100
    .byte %00011111, %11111111, %11111000
    .byte %00001111, %11111111, %11110000
    .byte %00000111, %11111111, %11100000
    .byte %00000011, %11111111, %11000000
    .byte %00000001, %11111111, %10000000
    .byte %00000000, %11111111, %00000000
    .byte %00000000, %01111110, %00000000
    .byte %00000000, %01011010, %00000000
    .byte %00000000, %00111100, %00000000
    .byte %00000000, %00011000, %00000000

; --- ESERCIZIO 2: due sprite, bianco sinistra, rosso destra ---
*=$9000
    ; Abilita sprite 0 e 1
    LDA #%00000011
    STA $D015

    ; Colori
    LDA #1         ; bianco
    STA $D027      ; sprite 0
    LDA #2         ; rosso
    STA $D028      ; sprite 1

    ; Posizioni
    LDA #50
    STA $D000      ; sprite 0 X
    LDA #100
    STA $D001      ; sprite 0 Y
    LDA #250
    STA $D002      ; sprite 1 X
    LDA #100
    STA $D003      ; sprite 1 Y

    ; Pointer (stessa astronave per entrambi)
    LDA #128
    STA $07F8
    STA $07F9
    RTS

; --- ESERCIZIO 3: alieno disegnato su carta poi convertito ---
; Esempio alieno 24x21 (semplice)
*=$A000
    .byte %00000000, %00111100, %00000000
    .byte %00000000, %01111110, %00000000
    .byte %00000001, %11111111, %10000000
    .byte %00000001, %11111111, %10000000
    .byte %00000011, %11111111, %11000000
    .byte %00000111, %10011001, %11100000
    .byte %00000111, %11111111, %11100000
    .byte %00001111, %11111111, %11110000
    .byte %00001111, %11111111, %11110000
    .byte %00011111, %01111110, %11111000
    .byte %00011111, %10111101, %11111000
    .byte %00111111, %11111111, %11111100
    .byte %00111111, %11111111, %11111100
    .byte %00111100, %00000000, %00111100
    .byte %00111100, %00000000, %00111100
    .byte %00011000, %00000000, %00011000
    .byte %00011000, %01000010, %00011000
    .byte %00000000, %01100110, %00000000
    .byte %00000000, %00111100, %00000000
    .byte %00000000, %00011000, %00000000
    .byte %00000000, %00011000, %00000000

; --- ESERCIZIO 4: sprite 0 a $3100 pointer ---
; pointer = $3100 / 64 = $3100 / $40 = $C4 = 196
*=$C000
    LDA #%00000001
    STA $D015
    LDA #196       ; $C4
    STA $07F8      ; punta a $3100
    LDA #1
    STA $D027
    LDA #160
    STA $D000
    LDA #100
    STA $D001
    RTS

; --- ESERCIZIO 5: sprite con colore che cambia ogni frame ---
*=$C000
    LDA #%00000001
    STA $D015
    LDA #128
    STA $07F8
    LDA #160
    STA $D000
    LDA #100
    STA $D001
    LDA #0
LOOP5
    STA $D027
    INC $D027
    LDA $D027
    CMP #16
    BNE LOOP5
    JMP LOOP5
