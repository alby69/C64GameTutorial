; =============================================
; SOLUZIONI Capitolo 16 — Sprite Multiplexing
; =============================================
;
; Mappa esercizi:
;   1: 2 zone (0-120, 121-240), 4 sprite per zona
;   2: 16 nemici logici, 8 per zona
;   3: 3 zone, 8 nemici cad (24 totali)
;   4: assegnazione dinamica (nemici piu vicini alla zona)
;   5: misura tempo multiplexing con barra debug ($D020)
;
; =============================================
; --- ESERCIZIO 1: 2 zone (0-120, 121-240), 4 sprite per zona ---
ZONE1_END = 120
ZONE2_END = 240
IRQ_VECTOR = $0314

*=$8000
    SEI
    LDA #$7F
    STA $DC0D

    LDA #<IRQ_BOTTOM
    STA IRQ_VECTOR
    LDA #>IRQ_BOTTOM
    STA IRQ_VECTOR+1

    LDA #ZONE1_END
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

; IRQ fondo schermo: prepara zona 1
IRQ_BOTTOM
    PHA
    TXA
    PHA
    TYA
    PHA

    ; Assegna sprite 0-3 a zona 1, sprite 4-7 a zona 2
    LDA #$0F
    STA $D015            ; tutti off in zona 1
    ; Mettere logica...

    PLA
    TAY
    PLA
    TAX
    PLA

    LDA #<IRQ_TOP
    STA IRQ_VECTOR
    LDA #>IRQ_TOP
    STA IRQ_VECTOR+1
    LDA #ZONE2_END
    STA $D012

    LDA $D019
    STA $D019
    JMP $EA31

IRQ_TOP
    PHA
    TXA
    PHA
    TYA
    PHA

    ; Prepara zona 2

    PLA
    TAY
    PLA
    TAX
    PLA

    LDA #<IRQ_BOTTOM
    STA IRQ_VECTOR
    LDA #>IRQ_BOTTOM
    STA IRQ_VECTOR+1
    LDA #ZONE1_END
    STA $D012

    LDA $D019
    STA $D019
    JMP $EA31

; --- ESERCIZIO 2: 16 nemici logici, 8 per zona ---
; Array nemici
ENEMY_X     = $100    ; 16 byte
ENEMY_Y     = $110
ENEMY_ACT   = $120
LOGICAL_CNT = 16
HW_SPRITES  = 8

*=$9000
    ; Inizializza 16 nemici
    LDX #0
INIT_E2
    TXA
    ASL
    ASL
    ASL
    CLC
    ADC #20
    STA ENEMY_X,X
    TXA
    ASL
    ASL
    CLC
    ADC #30
    STA ENEMY_Y,X
    LDA #1
    STA ENEMY_ACT,X
    INX
    CPX #LOGICAL_CNT
    BNE INIT_E2
    JMP MAIN2

MULTIPLEX_2ZONES
    ; Zona 1 (Y < 120): assegna primi 8
    ; Zona 2 (Y >= 120): assegna secondi 8
    LDX #0
    LDY #0
M2_Z1
    LDA ENEMY_ACT,X
    BEQ M2_NEXT1

    LDA ENEMY_Y,X
    CMP #ZONE1_END
    BCS M2_NEXT1

    ; Assegna a sprite HW Y
    LDA ENEMY_X,X
    STA $D000,Y
    LDA ENEMY_Y,X
    STA $D001,Y
    TYA
    LSR
    TAX
    LDA #1
    STA $D015,X
    INY
    INY
    CPY #HW_SPRITES*2
    BEQ M2_Z2

M2_NEXT1
    INX
    CPX #LOGICAL_CNT
    BNE M2_Z1

    ; Zona 2 (Y >= 120)
M2_Z2
    LDY #0
M2_Z2_LOOP
    LDA ENEMY_ACT,X
    BEQ M2_NEXT2

    LDA ENEMY_Y,X
    CMP #ZONE1_END
    BCC M2_NEXT2

    ; Assegna a sprite HW Y (offset 0-7)
    LDA ENEMY_X,X
    STA $D000,Y
    LDA ENEMY_Y,X
    STA $D001,Y
    LDA #1
    STA $D015,Y
    INY
    INY
    CPY #HW_SPRITES*2
    BEQ M2_DONE

M2_NEXT2
    INX
    CPX #LOGICAL_CNT
    BNE M2_Z2_LOOP

M2_DONE
    RTS

; --- ESERCIZIO 3: 3 zone, 8 nemici cad (24 totali) ---
LOGICAL_CNT3 = 24
ZONE_SIZE    = 80   ; 0-79, 80-159, 160-239
*=$A000
    ; ...setup 24 nemici...

MULTIPLEX_3ZONES
    LDX #0
    LDY #0

ZONE1
    LDA ENEMY_ACT,X
    BEQ Z1_NEXT
    LDA ENEMY_Y,X
    CMP #ZONE_SIZE
    BCS Z1_NEXT
    LDA ENEMY_X,X
    STA $D000,Y
    LDA ENEMY_Y,X
    STA $D001,Y
    LDA #1
    STA $D015,Y
    INY
    INY
    CPY #8
    BEQ Z2_START
Z1_NEXT
    INX
    CPX #LOGICAL_CNT3
    BNE ZONE1

Z2_START
    LDY #0
ZONE2
    LDA ENEMY_ACT,X
    BEQ Z2_NEXT
    LDA ENEMY_Y,X
    CMP #ZONE_SIZE*2
    BCS Z2_NEXT
    LDA ENEMY_Y,X
    CMP #ZONE_SIZE
    BCC Z2_NEXT
    LDA ENEMY_X,X
    STA $D000,Y
    LDA ENEMY_Y,X
    STA $D001,Y
    LDA #1
    STA $D015,Y
    INY
    INY
    CPY #8
    BEQ Z3_START
Z2_NEXT
    INX
    CPX #LOGICAL_CNT3
    BNE ZONE2

Z3_START
    LDY #0
ZONE3
    LDA ENEMY_ACT,X
    BEQ Z3_NEXT
    LDA ENEMY_Y,X
    CMP #ZONE_SIZE*2
    BCC Z3_NEXT
    LDA ENEMY_X,X
    STA $D000,Y
    LDA ENEMY_Y,X
    STA $D001,Y
    LDA #1
    STA $D015,Y
    INY
    INY
    CPY #8
    BEQ M3_DONE
Z3_NEXT
    INX
    CPX #LOGICAL_CNT3
    BNE ZONE3

M3_DONE
    RTS

; --- ESERCIZIO 4: assegnazione dinamica (nemici piu vicini alla zona) ---
; Invece di dividere per indice, dividi per Y
DYNAMIC_MUX
    ; Trova i nemici con Y piu vicino alla zona corrente
    ; Ordina per Y, assegna 8 alla volta
    LDX #0
    LDY #0
    STY $02        ; zone counter
DM_ZONE
    LDX #0
    LDY #0
DM_SCAN
    LDA ENEMY_ACT,X
    BEQ DM_SKIP

    LDA ENEMY_Y,X
    SEC
    SBC $02         ; distanza da questa zona
    BCS DM_POS
    EOR #$FF
    CLC
    ADC #1
DM_POS
    CMP #ZONE_SIZE
    BCS DM_SKIP

    ; Assegna a sprite Y
    LDA ENEMY_X,X
    STA $D000,Y
    LDA ENEMY_Y,X
    STA $D001,Y
    LDA #1
    STA $D015,Y
    INY
    INY
    CPY #8
    BEQ DM_NEXT_ZONE

DM_SKIP
    INX
    CPX #LOGICAL_CNT3
    BNE DM_SCAN

DM_NEXT_ZONE
    LDA $02
    CLC
    ADC #ZONE_SIZE
    STA $02
    CMP #240
    BCC DM_ZONE
    RTS

; --- ESERCIZIO 5: misura tempo multiplexing con barra debug ($D020) ---
*=$C000
    SEI
    LDA #$7F
    STA $DC0D
    LDA #<IRQ_DEBUG
    STA $0314
    LDA #>IRQ_DEBUG
    STA $0315
    LDA #200
    STA $D012
    LDA $D011
    AND #$7F
    STA $D011
    LDA #1
    STA $D01A
    CLI
    JMP MAIN5

MAIN5
    JMP MAIN5

IRQ_DEBUG
    PHA
    TXA
    PHA
    TYA
    PHA

    LDA #2
    STA $D020         ; barra rossa = inizio multiplex

    JSR MULTIPLEX_3ZONES

    LDA #0
    STA $D020         ; barra nera = fine

    PLA
    TAY
    PLA
    TAX
    PLA

    LDA $D019
    STA $D019
    JMP $EA31
