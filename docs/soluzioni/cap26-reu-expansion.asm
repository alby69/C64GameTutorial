; ─────────────────────────────────────────────────────
; Soluzioni esercizi Capitolo 26 — REU Expansion
; ─────────────────────────────────────────────────────

; ─────────────────────────────────────────────────────
; Esercizio 1 — Copia 256 byte da $C000 a REU $000000
; ─────────────────────────────────────────────────────

*= $C000

C64_TO_REU
    ; REU address = $000000
    LDA #0
    STA $DF02          ; REU_ADDR_L
    STA $DF03          ; REU_ADDR_H
    STA $DF04          ; REU_ADDR_B

    ; C64 address = $C000
    LDA #$00
    STA $DF05          ; C64_ADDR_L
    LDA #$C0
    STA $DF06          ; C64_ADDR_H
    LDA #0
    STA $DF07          ; C64_ADDR_B

    ; Length = 256 ($00 = 256 in L)
    LDA #0
    STA $DF08          ; LENGTH_L
    STA $DF09          ; LENGTH_H

    ; Command: C64 → REU, bit 7=1
    LDA #%10000000
    STA $DF00          ; COMMAND

    JSR WAIT_DMA
    RTS

; ─────────────────────────────────────────────────────
; Esercizio 2 — Copia 512 byte da REU $001000 a $A000
; ─────────────────────────────────────────────────────

REU_TO_C64
    ; REU address = $001000
    LDA #$00
    STA $DF02
    LDA #$10
    STA $DF03
    LDA #0
    STA $DF04

    ; C64 address = $A000
    LDA #$00
    STA $DF05
    LDA #$A0
    STA $DF06
    LDA #0
    STA $DF07

    ; Length = 512 ($0200)
    LDA #$00
    STA $DF08
    LDA #$02
    STA $DF09

    ; Command: REU → C64, bit 7=1, bit 6=1
    LDA #%11000000
    STA $DF00

    JSR WAIT_DMA
    RTS

; ─────────────────────────────────────────────────────
; Esercizio 3 — WAIT_DMA (attesa completamento DMA)
; ─────────────────────────────────────────────────────

WAIT_DMA
    LDA $DF01
    AND #%00000001     ; bit 0 = BSY
    BNE WAIT_DMA
    RTS

; ─────────────────────────────────────────────────────
; Esercizio 4 — Sistema a 4 livelli in REU
; ─────────────────────────────────────────────────────
; Ogni livello occupa 16 KB ($4000)
; Livello 0: REU $000000-$003FFF
; Livello 1: REU $004000-$007FFF
; Livello 2: REU $008000-$00BFFF
; Livello 3: REU $00C000-$00FFFF

LEVEL_SIZE = $4000

; Input: A = numero livello (0-3)
LOAD_LEVEL
    ; Calcola offset REU = A * $4000
    STA TEMP_REU

    ; REU_ADDR_L = (A * $4000) & $FF
    LDA TEMP_REU
    ASL
    ASL
    ASL
    ASL
    ASL
    ASL                 ; ×64 → bit 14 shift
    STA REU_ADDR_L      ; ma serve meglio
    ; Approccio semplice: usa tabella lookup
    LDX TEMP_REU
    LDA LEVEL_OFF_L,X
    STA $DF02
    LDA LEVEL_OFF_H,X
    STA $DF03
    LDA #0
    STA $DF04

    ; C64 address = $C000 (destinazione)
    LDA #$00
    STA $DF05
    LDA #$C0
    STA $DF06
    LDA #0
    STA $DF07

    ; Length = 16 KB
    LDA #$00
    STA $DF08
    LDA #$40
    STA $DF09

    ; DMA start
    LDA #%11000000
    STA $DF00
    JSR WAIT_DMA
    RTS

LEVEL_OFF_L
    .byte <$000000, <$004000, <$008000, <$00C000
LEVEL_OFF_H
    .byte >$000000, >$004000, >$008000, >$00C000

TEMP_REU
    .byte 0

; ─────────────────────────────────────────────────────
; Esercizio 5 — Salva/carica stato gioco in REU
; ─────────────────────────────────────────────────────

GAME_VARS = $C000     ; variabili di gioco
STATE_SIZE = 64       ; 64 byte di stato

; Salva stato in REU all'indirizzo $FF0000
SAVE_STATE
    ; REU address = $FF0000
    LDA #$00
    STA $DF02
    LDA #$00
    STA $DF03
    LDA #$FF
    STA $DF04

    ; C64 address = GAME_VARS
    LDA #<GAME_VARS
    STA $DF05
    LDA #>GAME_VARS
    STA $DF06
    LDA #0
    STA $DF07

    ; Length = 64
    LDA #64
    STA $DF08
    LDA #0
    STA $DF09

    LDA #%10000000     ; C64 → REU
    STA $DF00
    JSR WAIT_DMA
    RTS

; Carica stato da REU (per restore dopo reset)
LOAD_STATE
    LDA #$00
    STA $DF02
    STA $DF03
    LDA #$FF
    STA $DF04

    LDA #<GAME_VARS
    STA $DF05
    LDA #>GAME_VARS
    STA $DF06
    LDA #0
    STA $DF07

    LDA #64
    STA $DF08
    LDA #0
    STA $DF09

    LDA #%11000000     ; REU → C64
    STA $DF00
    JSR WAIT_DMA
    RTS
