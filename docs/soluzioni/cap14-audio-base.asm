; =============================================
; SOLUZIONI Capitolo 14 — Audio SID Base
; =============================================
;
; Mappa esercizi:
;   1: beep 1 secondo square wave
;   2: suono laser al fuoco
;   3: esplosione con noise 0.5 secondi
;   4: sweep frequenza basso→alto 0.5 sec
;   5: 3 suoni diversi: sparo, esplosione, bonus
;
; =============================================
; --- ESERCIZIO 1: beep 1 secondo square wave ---
*=$8000
    LDA #$F0
    STA SID_FREQ_LO    ; frequenza ~260 Hz
    LDA #$03
    STA SID_FREQ_HI

    LDA #$09
    STA SID_ADSR       ; attack=0, decay=9 (breve)

    LDA #$01
    STA SID_SUR        ; sustain=0, release=1

    LDA #15
    STA SID_VOL        ; volume massimo

    LDA #$11           ; square wave + gate
    STA SID_CTRL

    JSR DELAY1         ; 1 secondo

    LDA #$10           ; gate off
    STA SID_CTRL

    RTS

DELAY1
    LDX #$FF
D1O
    LDY #$FF
D1M
    NOP
    DEY
    BNE D1M
    DEX
    BNE D1O
    RTS

; --- ESERCIZIO 2: suono laser al fuoco ---
JOYPORT = $DC01
*=$9000
    LDA #15
    STA SID_VOL

LOOP2
    LDA JOYPORT
    AND #16
    BNE LOOP2

    ; Laser - frequenza alta breve
    LDA #$00
    STA SID_FREQ_LO
    LDA #$10
    STA SID_FREQ_HI    ; frequenza alta (~4096 Hz)

    LDA #$00
    STA SID_ADSR       ; attack 0, decay 0

    LDA #$0F
    STA SID_SUR        ; sustain 0, release F (lungo)

    LDA #$81           ; noise + gate
    STA SID_CTRL

    LDX #$30           ; breve pausa
D2
    DEX
    BNE D2

    LDA #$80           ; gate off
    STA SID_CTRL

    JMP LOOP2

; --- ESERCIZIO 3: esplosione con noise 0.5 secondi ---
*=$A000
    LDA #15
    STA SID_VOL

BANG
    LDA #$00
    STA SID_FREQ_LO
    LDA #$20
    STA SID_FREQ_HI

    LDA #$08
    STA SID_ADSR       ; attack=0, decay=8

    LDA #$0F
    STA SID_SUR        ; sustain 0, release 15

    LDA #$81           ; noise + gate
    STA SID_CTRL

    ; Mantieni per 0.5 secondi
    LDX #$80
D3O
    LDY #$FF
D3M
    DEY
    BNE D3M
    DEX
    BNE D3O

    LDA #$80           ; gate off
    STA SID_CTRL

    RTS

; --- ESERCIZIO 4: sweep frequenza basso→alto 0.5 sec ---
*=$B000
    LDA #15
    STA SID_VOL

    LDA #$00
    STA SID_ADSR

    LDA #$0F
    STA SID_SUR

    LDA #$11           ; square + gate
    STA SID_CTRL

    LDX #0
SWEEP
    TXA
    STA SID_FREQ_LO
    LDA #$01
    STA SID_FREQ_HI

    LDY #$10
SW_DELAY
    DEY
    BNE SW_DELAY

    INX
    CPX #$FF
    BNE SWEEP

    LDA #$10
    STA SID_CTRL
    RTS

; --- ESERCIZIO 5: 3 suoni diversi: sparo, esplosione, bonus ---
*=$C000

; Suono SPARO (canale 1)
SOUND_SHOOT
    LDA #$00
    STA $D400
    LDA #$20
    STA $D401
    LDA #$00
    STA $D405
    LDA #$08
    STA $D406
    LDA #$81
    STA $D404
    LDX #$20
SS_D
    DEX
    BNE SS_D
    LDA #$80
    STA $D404
    RTS

; Suono ESPLOSIONE (canale 2)
SOUND_EXPLODE
    LDA #$00
    STA $D410
    LDA #$10
    STA $D411
    LDA #$88
    STA $D415
    LDA #$0F
    STA $D416
    LDA #$81
    STA $D414
    LDX #$FF
SE_D
    DEX
    BNE SE_D
    LDA #$80
    STA $D414
    RTS

; Suono BONUS (canale 3)
SOUND_BONUS
    LDA #$40
    STA $D420
    LDA #$02
    STA $D421
    LDA #$09
    STA $D425
    LDA #$0F
    STA $D426
    LDA #$21           ; triangle + gate
    STA $D424
    LDX #$40
SB_D
    DEX
    BNE SB_D
    LDA #$20
    STA $D424
    RTS
