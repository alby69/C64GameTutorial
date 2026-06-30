; =============================================
; SOLUZIONI Capitolo 24 — Scrolling su C64
; =============================================
;
; Mappa esercizi:
;   1: scroll fine orizzontale con $D016
;   2: scroll fine + grossolano
;   3: raster split con HUD fisso + area scrollabile
;   4: scrolling verticale continuo
;   5: parallax a 2 layer con raster split
;
; =============================================

; --- ESERCIZIO 1: scroll fine orizzontale ($D016) ---
*= $C000
    LDA #1
    STA $D021
    LDA #$0B
    STA $D020

    ; Scrivi una riga di caratteri
    LDX #0
FILL1
    LDA #$41
    STA $0400+40*12,X
    INX
    CPX #40
    BNE FILL1

SCROLL1
    LDA SCROLL_X1
    STA $D016

    INC SCROLL_X1
    LDA SCROLL_X1
    AND #7
    STA SCROLL_X1

    LDX #0
DELAY1
    NOP
    NOP
    INX
    BNE DELAY1

    JMP SCROLL1

SCROLL_X1
    .byte 0

; --- ESERCIZIO 2: scroll fine + grossolano ---
*= $C000
    LDA #1
    STA $D021
    LDA #$0B
    STA $D020

    ; Scrivi riga di caratteri vari
    LDX #0
FILL2
    TXA
    CLC
    ADC #$41
    STA $0400+40*12,X
    INX
    CPX #80
    BNE FILL2

    ; Scorri da 0 a 7 e poi shift
SCROLL2
    ; Fine scroll
    LDA SCROLL_F2
    STA $D016

    INC SCROLL_F2
    LDA SCROLL_F2
    AND #7
    STA SCROLL_F2
    BNE NO_COARSE

    ; Coarse scroll — shift screen RAM a sinistra
    LDX #1
CS_LOOP
    LDA $0400+40*12,X
    STA $0400+40*12-1,X
    INX
    CPX #40
    BNE CS_LOOP

    ; Inserisci nuovo carattere a destra
    LDA COARSE_X2
    CLC
    ADC #$41
    STA $0400+40*12+39
    INC COARSE_X2

NO_COARSE
    LDX #0
DELAY2
    NOP
    NOP
    INX
    BNE DELAY2
    JMP SCROLL2

SCROLL_F2
    .byte 0
COARSE_X2
    .byte 0

; --- ESERCIZIO 3: raster split con HUD fisso ---
*= $C000
    SEI
    LDA #<IRQ3
    STA $0314
    LDA #>IRQ3
    STA $0315
    LDA #40
    STA $D012
    LDA $D011
    AND #$7F
    STA $D011
    LDA #1
    STA $D01A
    CLI

    ; HUD fisso — 40 colonne
    LDA #%11001000
    STA $D016

    ; Scrivi HUD
    LDX #0
HUD3
    LDA #$48            ; "H"
    STA $0400,X
    INX
    CPX #40
    BNE HUD3

    ; Scrivi area scrollabile
    LDX #0
SC3_FILL
    LDA #$41
    STA $0400+40*5,X
    INX
    CPX #40
    BNE SC3_FILL

MAIN3
    INC SCROLL3
    LDA SCROLL3
    AND #7
    STA SCROLL3
    JMP MAIN3

IRQ3
    LDA SCROLL3
    ORA #%11001000
    STA $D016

    LDA $D019
    STA $D019
    JMP $EA31

SCROLL3
    .byte 0

; --- ESERCIZIO 4: scrolling verticale continuo ---
*= $C000
    LDA #1
    STA $D021
    LDA #$0B
    STA $D020

    ; Riempi colonna centrale
    LDX #0
FILL4
    LDA #$41
    STA $0400+40*0+19,X
    INX
    CPX #25
    BNE FILL4

    ; Riempi altra colonna offset
    LDX #0
FILL4B
    LDA #$42
    STA $0400+40*0+20,X
    INX
    CPX #25
    BNE FILL4B

SCROLL4
    ; Fine scroll verticale
    LDA #$1B
    ORA SCROLL_Y4
    STA $D011

    INC SCROLL_Y4
    LDA SCROLL_Y4
    AND #7
    STA SCROLL_Y4
    BNE NO_CV

    ; Coarse vertical — shift su
    LDX #0
CV_LOOP
    LDA $0400+40,X
    STA $0400,X
    INX
    CPX #40*24
    BNE CV_LOOP

    ; Nuova ultima riga
    LDX #0
CV_NEW
    LDA #$20
    STA $0400+40*24,X
    INX
    CPX #40
    BNE CV_NEW

NO_CV
    LDX #0
DELAY4
    NOP
    INX
    BNE DELAY4
    JMP SCROLL4

SCROLL_Y4
    .byte 0

; --- ESERCIZIO 5: parallax a 2 layer ---
; Cielo (scroll lento) + Terreno (scroll veloce)
*= $C000
    SEI
    LDA #<IRQ5_SKY
    STA $0314
    LDA #>IRQ5_SKY
    STA $0315
    LDA #0
    STA $D012
    LDA #1
    STA $D01A
    CLI

    ; Scrivi cieli (righe 0-15) e terreno (righe 16-24)
    LDX #0
SKY_FILL
    LDA #$53            ; "S"
    STA $0400,X
    LDA #1
    STA $D800,X
    INX
    CPX #40*16
    BNE SKY_FILL

GROUND_FILL
    LDA #$47            ; "G"
    STA $0400+40*16,X
    LDA #5
    STA $D800+40*16,X
    INX
    CPX #40*9
    BNE GROUND_FILL

MAIN5
    INC SKY_SCROLL5
    LDA SKY_SCROLL5
    AND #7
    STA SKY_SCROLL5

    INC GROUND_SCROLL5
    INC GROUND_SCROLL5
    LDA GROUND_SCROLL5
    AND #7
    STA GROUND_SCROLL5
    JMP MAIN5

IRQ5_SKY
    LDA SKY_SCROLL5
    ORA #%11001000
    STA $D016

    LDA #<IRQ5_GROUND
    STA $0314
    LDA #>IRQ5_GROUND
    STA $0315
    LDA #16*8
    STA $D012

    LDA $D019
    STA $D019
    JMP $EA31

IRQ5_GROUND
    LDA GROUND_SCROLL5
    ORA #%11001000
    STA $D016

    LDA #<IRQ5_SKY
    STA $0314
    LDA #>IRQ5_SKY
    STA $0315
    LDA #0
    STA $D012

    LDA $D019
    STA $D019
    JMP $EA31

SKY_SCROLL5
    .byte 0
GROUND_SCROLL5
    .byte 0
