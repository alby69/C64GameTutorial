; =============================================
; SOLUZIONI Capitolo 7 — Raster Interrupt
; =============================================
;
; Mappa esercizi:
;   1: raster IRQ riga 50, bordo rosso
;   2: due IRQ — riga 50 (rosso), riga 150 (blu)
;   3: raster bar 4 righe consecutive
;   4: flash sfondo blu/nero ogni frame via raster
;   5: carattere lampeggiante via raster
;
; =============================================
; --- ESERCIZIO 1: raster IRQ riga 50, bordo rosso ---
*=$C000
    SEI
    LDA #$7F
    STA $DC0D

    LDA #<IRQ1
    STA $0314
    LDA #>IRQ1
    STA $0315

    LDA #50
    STA $D012
    LDA $D011
    AND #$7F
    STA $D011
    LDA #1
    STA $D01A
    CLI
    JMP MAIN

MAIN
    JMP MAIN

IRQ1
    LDA #2
    STA $D020
    LDA $D019
    STA $D019
    JMP $EA31

; --- ESERCIZIO 2: due IRQ — riga 50 (rosso), riga 150 (blu) ---
*=$9000
    SEI
    LDA #$7F
    STA $DC0D

    LDA #<IRQ_A
    STA $0314
    LDA #>IRQ_A
    STA $0315

    LDA #50
    STA $D012
    LDA $D011
    AND #$7F
    STA $D011
    LDA #1
    STA $D01A
    CLI
    JMP MAIN2

MAIN2
    JMP MAIN2

IRQ_A
    LDA #2         ; rosso
    STA $D020

    LDA #150
    STA $D012
    LDA #<IRQ_B
    STA $0314
    LDA #>IRQ_B
    STA $0315

    LDA $D019
    STA $D019
    JMP $EA31

IRQ_B
    LDA #6         ; blu
    STA $D020

    LDA #50
    STA $D012
    LDA #<IRQ_A
    STA $0314
    LDA #>IRQ_A
    STA $0315

    LDA $D019
    STA $D019
    JMP $EA31

; --- ESERCIZIO 3: raster bar 4 righe consecutive ---
*=$A000
    SEI
    LDA #$7F
    STA $DC0D

    LDA #<IRQ_1
    STA $0314
    LDA #>IRQ_1
    STA $0315

    LDA #50
    STA $D012
    LDA $D011
    AND #$7F
    STA $D011
    LDA #1
    STA $D01A
    CLI
    JMP MAIN3

MAIN3
    JMP MAIN3

IRQ_1
    LDA #2
    STA $D020
    LDA #51
    STA $D012
    LDA #<IRQ_2
    STA $0314
    LDA #>IRQ_2
    STA $0315
    LDA $D019
    STA $D019
    JMP $EA31

IRQ_2
    LDA #7
    STA $D020
    LDA #52
    STA $D012
    LDA #<IRQ_3
    STA $0314
    LDA #>IRQ_3
    STA $0315
    LDA $D019
    STA $D019
    JMP $EA31

IRQ_3
    LDA #5
    STA $D020
    LDA #53
    STA $D012
    LDA #<IRQ_4
    STA $0314
    LDA #>IRQ_4
    STA $0315
    LDA $D019
    STA $D019
    JMP $EA31

IRQ_4
    LDA #4
    STA $D020
    LDA #50
    STA $D012
    LDA #<IRQ_1
    STA $0314
    LDA #>IRQ_1
    STA $0315
    LDA $D019
    STA $D019
    JMP $EA31

; --- ESERCIZIO 4: flash sfondo blu/nero ogni frame via raster ---
*=$B000
    SEI
    LDA #$7F
    STA $DC0D
    LDA #<FLASH_IRQ
    STA $0314
    LDA #>FLASH_IRQ
    STA $0315
    LDA #200
    STA $D012
    LDA $D011
    AND #$7F
    STA $D011
    LDA #1
    STA $D01A
    CLI
    JMP MAIN4

MAIN4
    JMP MAIN4

FLASH_IRQ
    LDA $D021
    EOR #6         ; alterna blu/nero
    STA $D021
    LDA $D019
    STA $D019
    JMP $EA31

; --- ESERCIZIO 5: carattere lampeggiante via raster ---
*=$C000
    SEI
    LDA #$7F
    STA $DC0D
    LDA #<CHAR_IRQ
    STA $0314
    LDA #>CHAR_IRQ
    STA $0315
    LDA #100
    STA $D012
    LDA $D011
    AND #$7F
    STA $D011
    LDA #1
    STA $D01A
    CLI

    LDA #1         ; 'A' in prima posizione
    STA $0400
    JMP MAIN5

MAIN5
    JMP MAIN5

CHAR_IRQ
    LDA $D800
    EOR #$0F       ; alterna colore del carattere
    STA $D800
    LDA $D019
    STA $D019
    JMP $EA31
