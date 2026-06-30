; =============================================
; SOLUZIONI Capitolo 23 — Schermate Titolo e High Score
; =============================================
;
; Mappa esercizi:
;   1: schermata titolo "SHOOTER 64" centrata
;   2: sprite animato con cambio colore ogni 8 frame
;   3: salva/carica high score su disco (KERNAL)
;   4: game over con punteggio + high score
;   5: ciclo completo titolo → gioco → game over → titolo
;
; =============================================

; --- ESERCIZIO 1: schermata titolo "SHOOTER 64" ---
*= $C000
    LDA #0
    STA $D021           ; sfondo nero
    LDA #$0B
    STA $D020           ; bordo grigio

    LDX #0
LOOP1
    LDA TITLE1,X
    BEQ DONE1
    STA $0400+40*10+12,X
    LDA #7
    STA $D800+40*10+12,X
    INX
    JMP LOOP1
DONE1
    RTS

TITLE1
    .byte "SHOOTER 64",0

; --- ESERCIZIO 2: sprite animato che cambia colore ---
*= $C000
    LDA #0
    STA $D021
    LDA #$0B
    STA $D020

    LDA #1
    STA $D015           ; sprite 0 on
    LDA #160
    STA $D000           ; X
    LDA #100
    STA $D001           ; Y
    LDA #1
    STA $D027           ; colore iniziale

    SEI
    LDA #<IRQ2
    STA $0314
    LDA #>IRQ2
    STA $0315
    LDA #0
    STA $D012
    LDA #1
    STA $D01A
    CLI

    JMP MAIN2

IRQ2
    LDA FRAME2
    AND #7
    TAX
    LDA RAINBOW2,X
    STA $D027
    INC FRAME2
    LDA $D019
    STA $D019
    JMP $EA31

FRAME2
    .byte 0

RAINBOW2
    .byte 2,4,7,5,3,1,13,6

MAIN2
    ; Attendi FIRE per uscire
    LDA $DC01
    AND #$10
    BNE MAIN2
    SEI
    LDA #0
    STA $D01A
    CLI
    RTS

; --- ESERCIZIO 3: salva/carica high score su disco ---
*= $C000
    JSR LOAD_HS
    JSR SAVE_HS
    RTS

; Salva high score (3 byte)
SAVE_HS
    LDA #2
    LDX #<FNAME3
    LDY #>FNAME3
    JSR $FFBD
    LDA #1
    LDX #8
    LDY #1
    JSR $FFBA
    LDA #<HS_DATA
    LDX #>HS_DATA
    LDY #$C0
    JSR $FFD8
    RTS

; Carica high score (3 byte)
LOAD_HS
    LDA #2
    LDX #<FNAME3
    LDY #>FNAME3
    JSR $FFBD
    LDA #1
    LDX #8
    LDY #0
    JSR $FFBA
    LDA #0
    LDX #<HS_DATA
    LDY #>HS_DATA
    JSR $FFD5
    BCC LOAD_OK
    ; File non esiste — init a zero
    LDA #0
    STA HS_DATA
    STA HS_DATA+1
    STA HS_DATA+2
LOAD_OK
    RTS

FNAME3
    .text "HI"

HS_DATA
    .byte 0,0,0

; --- ESERCIZIO 4: game over + high score ---
*= $C000
    JSR LOAD_HS

    ; Simula punteggio per test
    LDA #12
    STA SCORE_LO
    LDA #3
    STA SCORE_HI

    ; Stampa "GAME OVER"
    LDX #0
GO4_LOOP
    LDA GOV_TEXT4,X
    BEQ GO4_SCORE
    STA $0400+40*8+14,X
    INX
    JMP GO4_LOOP

GO4_SCORE
    ; Stampa punteggio
    LDA SCORE_HI
    JSR PRINT_HEX
    LDA SCORE_LO
    JSR PRINT_HEX

    ; Stampa "HIGH: "
    LDX #0
GO4_HS
    LDA HS_TEXT4,X
    BEQ GO4_CHECK
    STA $0400+40*10+12,X
    INX
    JMP GO4_HS

GO4_CHECK
    LDA SCORE_HI
    CMP HS_DATA+1
    BCC GO4_WAIT
    LDA SCORE_LO
    CMP HS_DATA
    BCC GO4_WAIT
    ; Nuovo record!
    LDA SCORE_LO
    STA HS_DATA
    LDA SCORE_HI
    STA HS_DATA+1
    JSR SAVE_HS

    ; Stampa "NUOVO RECORD!"
    LDX #0
GO4_NR
    LDA NR_TEXT4,X
    BEQ GO4_WAIT
    STA $0400+40*12+12,X
    INX
    JMP GO4_NR

GO4_WAIT
    LDA $DC01
    AND #$10
    BNE GO4_WAIT
    RTS

GOV_TEXT4
    .byte "GAME OVER",0
HS_TEXT4
    .byte "HIGH: ",0
NR_TEXT4
    .byte "NUOVO RECORD!",0
SCORE_LO
    .byte 0
SCORE_HI
    .byte 0

; --- ESERCIZIO 5: ciclo completo ---
; Nota: questo esercizio richiede integrazione in un progetto
; piu grande. Qui mostriamo la macchina a stati.
*= $C000
    SEI
    LDA #0
    STA $D01A
    CLI

    JSR LOAD_HS

STATE_LOOP
    ; Sezione GAME_OVER salta direttamente
    LDA STATE
    CMP #2
    BEQ GAME_OVER5

    ; Sezione TITOLO
    JSR TITLE5
    JSR WAIT_FIRE

    ; Sezione GIOCO (simulata)
    LDA #1
    STA STATE

    LDA #0
    STA SCORE_LO
    LDA #0
    STA SCORE_HI

    JSR GAME5

GAME_OVER5
    ; Sezione GAME OVER
    LDA SCORE_HI
    CMP HS_DATA+1
    BCC G5_WAIT
    LDA SCORE_LO
    CMP HS_DATA
    BCC G5_WAIT
    LDA SCORE_LO
    STA HS_DATA
    LDA SCORE_HI
    STA HS_DATA+1
    JSR SAVE_HS
    LDA #2
    STA NR_FLAG

G5_WAIT
    JSR SHOW_GOVER5
    JSR WAIT_FIRE

    ; Torna al titolo
    LDA #0
    STA STATE
    LDA #0
    STA NR_FLAG
    JMP STATE_LOOP

; Sottoroutine

TITLE5
    LDA #0
    STA $D021
    LDA #$0B
    STA $D020
    LDX #0
T5_L
    LDA TIT5_T,X
    BEQ T5_D
    STA $0400+40*10+12,X
    LDA #7
    STA $D800+40*10+12,X
    INX
    JMP T5_L
T5_D
    RTS

GAME5
    ; Simula partita breve con punteggio
    LDA #10
    STA SCORE_LO
    LDA #5
    STA SCORE_HI
    RTS

SHOW_GOVER5
    LDX #0
SG_L
    LDA GOV5_T,X
    BEQ SG_S
    STA $0400+40*8+14,X
    INX
    JMP SG_L
SG_S
    LDA SCORE_HI
    JSR PRINT_HEX
    LDA SCORE_LO
    JSR PRINT_HEX
    LDA NR_FLAG
    CMP #2
    BNE SG_E
    LDX #0
SG_NR
    LDA NR5_T,X
    BEQ SG_E
    STA $0400+40*12+12,X
    INX
    JMP SG_NR
SG_E
    RTS

WAIT_FIRE
    LDA $DC01
    AND #$10
    BNE WAIT_FIRE
    RTS

STATE
    .byte 0
NR_FLAG
    .byte 0

TIT5_T
    .byte "SHOOTER 64",0
GOV5_T
    .byte "GAME OVER",0
NR5_T
    .byte "NUOVO RECORD!",0

; Utility: stampa A come esadecimale
PRINT_HEX
    PHA
    LSR
    LSR
    LSR
    LSR
    TAX
    LDA HEX_CHARS,X
    JSR $FFD2
    PLA
    AND #$0F
    TAX
    LDA HEX_CHARS,X
    JSR $FFD2
    LDA #$20
    JSR $FFD2
    RTS

HEX_CHARS
    .text "0123456789ABCDEF"
