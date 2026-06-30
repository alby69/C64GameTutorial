; =============================================
; SOLUZIONI Capitolo 22 — Debugging con VICE
; =============================================
;
; Mappa esercizi:
;   1: breakpoint a $C000, ispezione con r/m/d
;   2: watchpoint su $D020 con loop INC $D020
;   3: raster IRQ senza $D01A — debug del bug
;   4: misura cicli CPU con raster timing
;   5: stack overflow con chiamate ricorsive
;
; =============================================

; --- ESERCIZIO 1: breakpoint + ispezione ---
; Carica in VICE, imposta "b $C000", poi "g".
; Usa "r" per vedere i registri, "m $C000" per memoria,
; "d $C000" per disassemblare.
*= $C000
    LDA #$41
    STA $0400
    LDA #$42
    STA $0401
    LDA #$43
    STA $0402
    RTS

; --- ESERCIZIO 2: watchpoint su $D020 ---
*= $C000
LOOP2
    INC $D020
    LDX #0
DELAY2
    NOP
    NOP
    INX
    BNE DELAY2
    JMP LOOP2

; In VICE: "ws $D020" poi "g".
; Il monitor si ferma a ogni modifica di $D020.

; --- ESERCIZIO 3: raster IRQ senza $D01A ---
; Codice dal capitolo 7, ma MANCA LDA #1 / STA $D01A
; L'IRQ non parte mai perche VIC-II non genera interrupt.
*= $C000
    SEI
    LDA #$7F
    STA $DC0D
    LDA #<IRQ3
    STA $0314
    LDA #>IRQ3
    STA $0315
    LDA #100
    STA $D012
    LDA $D011
    AND #$7F
    STA $D011
    ; BUG: manca LDA #1 / STA $D01A
    CLI

LOOP3
    JMP LOOP3

IRQ3
    INC $D020
    LDA $D019
    STA $D019
    RTI

; In VICE: "b IRQ3" — non si fermera mai.
; Aggiungi "LDA #1 : STA $D01A" dopo $D011 setup e riprova.

; --- ESERCIZIO 4: misura cicli CPU con raster ---
*= $C000
    ; Versione lenta: LDA/STA
    LDA #2
    STA $D020           ; bordo rosso — inizio misura

    LDX #99
SLOW_LOOP
    LDA #$41
    STA $0400,X
    DEX
    BPL SLOW_LOOP

    LDA #0
    STA $D020           ; bordo nero — fine misura

    ; Versione veloce: LDX/STX
    LDA #2
    STA $D020           ; bordo rosso

    LDX #99
    STX $0400,X         ; X contiene gia il valore
    DEX
    BPL $-3

    LDA #0
    STA $D020           ; bordo nero

    RTS

; In VICE: la barra rossa a destra mostra i cicli consumati.
; La versione LDX/STX ha barra piu stretta.

; --- ESERCIZIO 5: stack overflow ---
*= $C000
    JSR RECURSE
    RTS

RECURSE
    JSR RECURSE
    RTS

; In VICE: "b $0100" non basta. Meglio:
;   m $0100 $01FF   — osserva lo stack riempirsi
;   r               — SP scende sotto $80
; Dopo pochi frame il programma crashera.
; Sintomo: RTS salta a indirizzi casuali.
