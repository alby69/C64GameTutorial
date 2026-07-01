; =============================================
; SOLUZIONI Capitolo 15 — Audio Engine
; =============================================
;
; Mappa esercizi:
;   1: sistema SFX_REQUEST canale 2/3
;   2: UPDATE_AUDIO nel raster IRQ 50 Hz
;   3: sequenza musicale 4 note in loop
;   4: ADSR pioggia noise + attack lungo
;   5: coda audio 8 comandi
;
; =============================================
; --- ESERCIZIO 1: sistema SFX_REQUEST canale 2/3 ---
SFX_REQ    = $40     ; 0=nessuno, 1=sparo, 2=esplosione, 3=bonus
SFX_CHANNEL = $41    ; canale SID da usare
CHAN2_CTRL = $D414
CHAN2_FREQ = $D410
CHAN2_ADSR = $D415
CHAN2_SUR  = $D416
CHAN3_CTRL = $D424
CHAN3_FREQ = $D420
CHAN3_ADSR = $D425
CHAN3_SUR  = $D426

*=$C000
    LDA #15
    STA $D418

PLAY_SFX
    LDA SFX_REQ
    BEQ PS_END

    ; Determina canale
    LDA SFX_CHANNEL
    CMP #2
    BEQ PS_CH2
    JMP PS_CH3

PS_CH2
    LDA SFX_REQ
    CMP #1
    BEQ PS2_SHOOT
    CMP #2
    BEQ PS2_EXPLODE
    JMP PS2_BONUS

PS2_SHOOT
    LDA #$00
    STA $D410
    LDA #$20
    STA $D411
    LDA #$00
    STA CHAN2_ADSR
    LDA #$08
    STA CHAN2_SUR
    LDA #$81
    STA CHAN2_CTRL
    JMP PS_END

PS2_EXPLODE
    LDA #$00
    STA $D410
    LDA #$10
    STA $D411
    LDA #$88
    STA CHAN2_ADSR
    LDA #$0F
    STA CHAN2_SUR
    LDA #$81
    STA CHAN2_CTRL
    JMP PS_END

PS2_BONUS
    ; triangle su canale 2
    LDA #$40
    STA $D410
    LDA #$02
    STA $D411
    LDA #$09
    STA CHAN2_ADSR
    LDA #$0F
    STA CHAN2_SUR
    LDA #$21
    STA CHAN2_CTRL

PS_END
    LDA #0
    STA SFX_REQ
    RTS

; --- ESERCIZIO 2: UPDATE_AUDIO nel raster IRQ 50 Hz ---
*=$9000
    SEI
    LDA #$7F
    STA $DC0D
    LDA #<IRQ_AUDIO
    STA $0314
    LDA #>IRQ_AUDIO
    STA $0315
    LDA #200
    STA $D012
    LDA $D011
    AND #$7F
    STA $D011
    LDA #1
    STA $D01A
    CLI

    LDA #15
    STA $D418

MAIN2
    JMP MAIN2

IRQ_AUDIO
    PHA
    TXA
    PHA
    TYA
    PHA

    JSR PLAY_SFX       ; chiamata ogni frame

    ; Gestisci durata suoni
    JSR SFX_TIMER

    PLA
    TAY
    PLA
    TAX
    PLA

    LDA $D019
    STA $D019
    JMP $EA31

SFX_TIMER
    LDA SFX_REQ
    BNE ST_END

    ; Se nessun suono, spegni canali
    LDA #$80
    STA CHAN2_CTRL
    STA CHAN3_CTRL

ST_END
    RTS

; --- ESERCIZIO 3: sequenza musicale 4 note in loop ---
NOTE_INDEX = $50
NOTE_TIMER = $51
*=$A000
    LDA #15
    STA $D418
    LDA #0
    STA NOTE_INDEX
    LDA #20
    STA NOTE_TIMER

LOOP3
    DEC NOTE_TIMER
    BPL LOOP3

    LDA #20
    STA NOTE_TIMER

    LDX NOTE_INDEX
    LDA NOTES,X
    STA $D400
    LDA NOTES+1,X
    STA $D401
    LDA #$11
    STA $D404

    INX
    INX
    CPX #8
    BNE NI_OK
    LDX #0
NI_OK
    STX NOTE_INDEX

    JSR WAIT3
    JMP LOOP3

NOTES
    .byte $C0, $04    ; nota 1 (DO ~520 Hz)
    .byte $00, $06    ; nota 2 (RE ~580 Hz)
    .byte $40, $05    ; nota 3 (MI ~650 Hz)
    .byte $80, $07    ; nota 4 (SOL ~780 Hz)

; --- ESERCIZIO 4: ADSR "pioggia" noise + attack lungo ---
*=$B000
    LDA #15
    STA $D418

    ; Pioggia: noise, attack lungo, decay lento
    LDA #$00
    STA $D400
    LDA #$30
    STA $D401

    LDA #$FA         ; attack=15 (lungo), decay=10
    STA $D405

    LDA #$00
    STA $D406        ; sustain 0, release 0

    LDA #$81         ; noise + gate
    STA $D404

LOOP4
    ; Modula frequenza per variare
    LDA $D012
    STA $D400
    JSR WAIT4
    JMP LOOP4

; --- ESERCIZIO 5: coda audio 8 comandi ---
AUDIO_QUEUE = $60     ; 8 byte: ogni byte = comando
QUEUE_HEAD  = $70
QUEUE_TAIL  = $71

*=$C000
    LDA #0
    STA QUEUE_HEAD
    STA QUEUE_TAIL

ADD_TO_QUEUE
    ; A = comando da aggiungere
    LDX QUEUE_TAIL
    STA AUDIO_QUEUE,X
    INX
    TXA
    AND #7
    STA QUEUE_TAIL
    RTS

PROCESS_QUEUE
    LDA QUEUE_HEAD
    CMP QUEUE_TAIL
    BEQ PQ_END        ; coda vuota

    LDX QUEUE_HEAD
    LDA AUDIO_QUEUE,X

    ; Processa comando
    CMP #1
    BEQ Q_SHOOT
    CMP #2
    BEQ Q_EXPLODE
    CMP #3
    BEQ Q_BONUS
    JMP PQ_NEXT

Q_SHOOT
    LDA #1
    STA SFX_REQ
    LDA #2           ; canale 2
    STA SFX_CHANNEL
    JMP PQ_NEXT

Q_EXPLODE
    LDA #2
    STA SFX_REQ
    LDA #3           ; canale 3
    STA SFX_CHANNEL
    JMP PQ_NEXT

Q_BONUS
    LDA #3
    STA SFX_REQ
    LDA #2           ; canale 2
    STA SFX_CHANNEL

PQ_NEXT
    LDX QUEUE_HEAD
    INX
    TXA
    AND #7
    STA QUEUE_HEAD

PQ_END
    RTS
