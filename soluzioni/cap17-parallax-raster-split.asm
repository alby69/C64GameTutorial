; =============================================
; SOLUZIONI Capitolo 17 — Parallax e Raster Split
; =============================================

; --- ESERCIZIO 1: schermo diviso in 3 zone, 3 colori ---
*=$8000
    SEI
    LDA #$7F
    STA $DC0D

    LDA #<IRQ_Z1
    STA $0314
    LDA #>IRQ_Z1
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

IRQ_Z1
    LDA #6          ; blu (cielo)
    STA $D021
    STA $D020

    LDA #100
    STA $D012
    LDA #<IRQ_Z2
    STA $0314
    LDA #>IRQ_Z2
    STA $0315

    LDA $D019
    STA $D019
    JMP $EA31

IRQ_Z2
    LDA #5          ; verde (erba)
    STA $D021
    LDA #2          ; bordo rosso
    STA $D020

    LDA #180
    STA $D012
    LDA #<IRQ_Z3
    STA $0314
    LDA #>IRQ_Z3
    STA $0315

    LDA $D019
    STA $D019
    JMP $EA31

IRQ_Z3
    LDA #0          ; nero (sotterraneo)
    STA $D021
    LDA #3          ; bordo ciano
    STA $D020

    LDA #50
    STA $D012
    LDA #<IRQ_Z1
    STA $0314
    LDA #>IRQ_Z1
    STA $0315

    LDA $D019
    STA $D019
    JMP $EA31

; --- ESERCIZIO 2: HUD fisso in alto, area gioco sotto ---
*=$9000
    SEI
    LDA #$7F
    STA $DC0D
    LDA #<IRQ_HUD
    STA $0314
    LDA #>IRQ_HUD
    STA $0315
    LDA #40
    STA $D012
    LDA $D011
    AND #$7F
    STA $D011
    LDA #1
    STA $D01A
    CLI

    ; Scrivi HUD
    LDA #32
    LDX #0
HUD_CLR
    STA $0400,X
    INX
    CPX #40
    BNE HUD_CLR

    LDA #19         ; 'S'
    STA $0400+2
    LDA #3          ; 'C'
    STA $0400+3
    LDA #15         ; 'O'
    STA $0400+4
    LDA #18         ; 'R'
    STA $0400+5
    LDA #5          ; 'E'
    STA $0400+6
    LDA #0
    STA $0400+8     ; punteggio
    STA $0400+9
    STA $0400+10

    JMP MAIN2

MAIN2
    JMP MAIN2

IRQ_HUD
    LDA #0          ; nero per HUD
    STA $D021
    LDA #1          ; bordo bianco
    STA $D020

    LDA #41
    STA $D012
    LDA #<IRQ_GAME
    STA $0314
    LDA #>IRQ_GAME
    STA $0315

    LDA $D019
    STA $D019
    JMP $EA31

IRQ_GAME
    LDA #6          ; blu per area gioco
    STA $D021
    LDA #0
    STA $D020

    LDA #40
    STA $D012
    LDA #<IRQ_HUD
    STA $0314
    LDA #>IRQ_HUD
    STA $0315

    LDA $D019
    STA $D019
    JMP $EA31

; --- ESERCIZIO 3: scrolling fine $D016 ogni frame, azzera a 7 ---
SCROLL_X = $D016
*=$A000
    LDA #0
    STA $02          ; scroll counter

LOOP3
    JSR UPDATE_SCROLL
    JSR WAIT3
    JMP LOOP3

UPDATE_SCROLL
    LDA $02
    INC $02
    AND #7
    EOR #7
    STA SCROLL_X
    RTS

WAIT3
    LDA $D012
    CMP #$F8
    BNE WAIT3
    RTS

; --- ESERCIZIO 4: finto parallax — cambio sfondo ogni 8 frame ---
SKY_COLORS = $60
*=$B000
    LDA #6
    STA $60         ; blu
    LDA #3
    STA $61         ; ciano
    LDA #7
    STA $62         ; giallo
    LDA #4
    STA $63         ; viola

    LDA #0
    STA $02         ; frame counter
    STA $03         ; sky index

LOOP4
    JSR UPDATE_SKY
    JSR WAIT4
    JMP LOOP4

UPDATE_SKY
    INC $02
    LDA $02
    AND #7
    BNE US_END

    INC $03
    LDA $03
    AND #3
    TAX
    LDA SKY_COLORS,X
    STA $D021

US_END
    RTS

; --- ESERCIZIO 5: sprite dietro lo sfondo con $D01B ---
*=$C000
    SEI
    LDA #$7F
    STA $DC0D
    LDA #<IRQ_PRIO
    STA $0314
    LDA #>IRQ_PRIO
    STA $0315
    LDA #150
    STA $D012
    LDA $D011
    AND #$7F
    STA $D011
    LDA #1
    STA $D01A
    CLI

    ; Setup sprite
    LDA #%00000011
    STA $D015

    LDA #1
    STA $D027       ; sprite 0 bianco
    LDA #2
    STA $D028       ; sprite 1 rosso

    LDA #128
    STA $07F8
    STA $07F9

    LDA #100
    STA $D000
    STA $D002
    LDA #100
    STA $D001       ; sprite 0
    LDA #120
    STA $D003       ; sprite 1 (sotto)

    ; Elemento di sfondo
    LDA #1
    STA $0400+10    ; 'A' a schermo
    LDA #5
    STA $D800+10    ; colore verde

    JMP MAIN5

MAIN5
    JMP MAIN5

IRQ_PRIO
    ; Nella zona HUD: sprite 0 dietro
    LDA $D01B
    AND #%11111110
    STA $D01B       ; sprite 0 = priorita sfondo

    LDA #180
    STA $D012
    LDA #<IRQ_PRIO2
    STA $0314
    LDA #>IRQ_PRIO2
    STA $0315

    LDA $D019
    STA $D019
    JMP $EA31

IRQ_PRIO2
    ; Nella zona gioco: sprite 0 davanti
    LDA $D01B
    ORA #%00000001
    STA $D01B       ; sprite 0 = priorita sprite

    LDA #150
    STA $D012
    LDA #<IRQ_PRIO
    STA $0314
    LDA #>IRQ_PRIO
    STA $0315

    LDA $D019
    STA $D019
    JMP $EA31
