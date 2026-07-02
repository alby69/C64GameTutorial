; =============================================
; SOLUZIONI Capitolo 21 — Caricatore Personalizzato
; =============================================
;
; Mappa esercizi:
;   1: caricatore KERNAL per GIOCO.PRG
;   2: caricatore KERNAL + effetto raster bar
;   3: schermata caricamento con barra progresso
;   4: boot loader in 3 fasi
;   5: lettura byte via seriale ($DD00)
;
; =============================================

; --- ESERCIZIO 1: caricatore KERNAL per GIOCO.PRG ---
*= $C000
    LDA #9
    LDX #<FNAME1
    LDY #>FNAME1
    JSR $FFBD          ; SETNAM
    LDA #1
    LDX #8
    LDY #1
    JSR $FFBA          ; SETLFS
    LDA #0
    LDX #0
    LDY #0
    JSR $FFD5          ; LOAD
    JMP $C000          ; esegui

FNAME1
    .text "GIOCO.PRG"

; --- ESERCIZIO 2: caricatore KERNAL + raster bar ---
*= $C000
    SEI
    LDA #<IRQ2
    STA $0314
    LDA #>IRQ2
    STA $0315
    LDA #100
    STA $D012
    LDA $D011
    AND #$7F
    STA $D011
    LDA #1
    STA $D01A
    CLI

    LDA #9
    LDX #<FNAME2
    LDY #>FNAME2
    JSR $FFBD
    LDA #1
    LDX #8
    LDY #1
    JSR $FFBA
    LDA #0
    LDX #0
    LDY #0
    JSR $FFD5

    SEI
    LDA #0
    STA $D01A
    CLI

    JMP $C000

IRQ2
    INC $D020
    LDA $D019
    STA $D019
    JMP $EA31

FNAME2
    .text "GIOCO.PRG"

; --- ESERCIZIO 3: schermata caricamento + barra progresso ---
*= $C000
    JSR SETUP

    LDA #9
    LDX #<FNAME3
    LDY #>FNAME3
    JSR $FFBD
    LDA #1
    LDX #8
    LDY #1
    JSR $FFBA

    SEI
    LDA #<IRQ3
    STA $0314
    LDA #>IRQ3
    STA $0315
    LDA #50
    STA $D012
    LDA #1
    STA $D01A
    CLI

    LDA #0
    LDX #0
    LDY #0
    JSR $FFD5

    SEI
    LDA #0
    STA $D01A
    CLI
    JMP $C000

SETUP
    LDX #0
MSG
    LDA LOADMSG,X
    STA $0400+40*12+5,X
    INX
    CPX #20
    BNE MSG
    RTS

IRQ3
    INC $D020
    LDA BARPOS
    TAX
    LDA #$A0
    STA $0400+40*14,X
    LDA #5
    STA $D800+40*14,X
    INC BARPOS
    LDA BARPOS
    CMP #40
    BNE NO_RESET
    LDA #0
    STA BARPOS
NO_RESET
    LDA $D019
    STA $D019
    JMP $EA31

BARPOS
    .byte 0

LOADMSG
    .text "CARICAMENTO IN CORSO..."

FNAME3
    .text "GIOCO.PRG"

; --- ESERCIZIO 4: boot loader in 3 fasi ---
; Prima fase — si carica con LOAD"*",8,1
*= $0801
    LDA #13
    LDX #<FNAME4A
    LDY #>FNAME4A
    JSR $FFBD
    LDA #1
    LDX #8
    LDY #1
    JSR $FFBA
    LDA #0
    LDX #0
    LDY #0
    JSR $FFD5
    JMP $C000

FNAME4A
    .text "LOADER.PRG"

; Seconda fase (LOADER.PRG) — caricatore con effetti
*= $C000
    JSR SETUP4
    SEI
    LDA #<IRQ4
    STA $0314
    LDA #>IRQ4
    STA $0315
    LDA #50
    STA $D012
    LDA #1
    STA $D01A
    CLI

    LDA #9
    LDX #<FNAME4B
    LDY #>FNAME4B
    JSR $FFBD
    LDA #1
    LDX #8
    LDY #1
    JSR $FFBA
    LDA #0
    LDX #0
    LDY #0
    JSR $FFD5

    SEI
    LDA #0
    STA $D01A
    CLI
    JMP $C000

SETUP4
    LDX #0
MSG4
    LDA LOADMSG4,X
    STA $0400+40*12+5,X
    INX
    CPX #20
    BNE MSG4
    RTS

IRQ4
    INC $D020
    LDA $D019
    STA $D019
    JMP $EA31

LOADMSG4
    .text "CARICAMENTO GIOCO..."

FNAME4B
    .text "GIOCO.PRG"

; Terza fase (GIOCO.PRG) — il gioco vero e proprio
*= $C000
    ; ... codice del gioco ...
    RTS

; --- ESERCIZIO 5: lettura byte via seriale ($DD00) ---
; Legge un byte dal drive usando la porta seriale direttamente
*= $C000
    JSR READ_BYTE
    STA $0400         ; mostra il byte letto a schermo
    RTS

READ_BYTE
    LDA #$00
    STA TEMP
    LDX #8            ; 8 bit da leggere
BIT_LOOP
    LDA $DD00
    AND #$10          ; DATA line sul bit 4
    BEQ BIT_ZERO
    ; Bit = 1
    LDA TEMP
    LSR               ; sposta a destra
    ORA #$80          ; setta bit 7
    STA TEMP
    JMP NEXT
BIT_ZERO
    ; Bit = 0
    LDA TEMP
    LSR               ; sposta a destra
    STA TEMP
NEXT
    ; Clock pulse — attende che il drive prepari il prossimo bit
    LDY #$20
WAIT
    DEY
    BNE WAIT
    DEX
    BNE BIT_LOOP
    LDA TEMP
    RTS

TEMP
    .byte 0
