# Capitolo 16 — Sprite Multiplexing (8+ Sprite)

## Obiettivi

Al termine di questo capitolo saprai:

- Perche serve il multiplexing sprite
- Dividere lo schermo in zone raster
- Riutilizzare gli 8 sprite hardware su piu entita
- Aggiornare posizione sprite durante il raster
- Gestire 16+ nemici virtuali

---

## 16.1 Il problema degli 8 sprite

Il VIC-II ha solo 8 sprite hardware. In un gioco arcade servono piu entita:

```
8 sprite HW   →   Solo 8 nemici visibili
Ma vorremmo:      16, 24, 32 nemici!
```

### La soluzione: multiplexing

Il trucco: riutilizzare gli stessi 8 sprite in **zone verticali** diverse dello schermo.

```
Schema schermo diviso in zone:
┌──────────────────────┐
│ ZONA 0   (0-79 px)   │ ← Sprite HW 0-7 per nemici 0-7
├──────────────────────┤
│ ZONA 1   (80-159 px) │ ← Stessi Sprite HW 0-7 per nemici 8-15
├──────────────────────┤
│ ZONA 2  (160-239 px) │ ← Stessi Sprite HW 0-7 per nemici 16-23
└──────────────────────┘
```

Il VIC-II disegna una riga alla volta. Quando finisce una zona, cambiamo le coordinate degli sprite per la zona successiva. Il tutto avviene durante il raster interrupt.

---

## 16.2 Raster interrupt per multiplexing

```asm
; Setup IRQ per multiplexing

INIT_MULTIPLEX
    SEI
    LDA #$7F
    STA $DC0D

    LDA #<IRQ_ZONE0
    STA $0314
    LDA #>IRQ_ZONE0
    STA $0315

    LDA #80              ; prima zona: riga 80
    STA $D012

    LDA $D011
    AND #$7F
    STA $D011

    LDA #1
    STA $D01A

    CLI
    RTS
```

---

## 16.3 Struttura dati per 24 nemici

```asm
; 24 nemici logici (non hardware)
ENEMY_X      = $80     ; 24 byte
ENEMY_Y      = $98     ; 24 byte
ENEMY_ALIVE  = $B0     ; 24 byte
ENEMY_SPRITE = $C8     ; 24 byte (tipo/frame sprite)

MAX_LOGICAL_ENEMIES = 24
SPRITE_SLOTS = 8
```

### Suddivisione in zone

```asm
; Ogni zona gestisce un gruppo di nemici
ZONE0_START = 0     ; nemici 0-7
ZONE1_START = 8     ; nemici 8-15
ZONE2_START = 16    ; nemici 16-23

ZONE0_Y_MAX = 80
ZONE1_Y_MAX = 160
ZONE2_Y_MAX = 240
```

---

## 16.4 IRQ per ogni zona

### Zona 0 (riga 80)

```asm
IRQ_ZONE0
    PHA
    TXA
    PHA
    TYA
    PHA

    ; Aggiorna sprite per nemici 0-7
    JSR UPDATE_ZONE0

    ; Prepara prossimo IRQ alla riga 160
    LDA #160
    STA $D012

    LDA #<IRQ_ZONE1
    STA $0314
    LDA #>IRQ_ZONE1
    STA $0315

    PLA
    TAY
    PLA
    TAX
    PLA

    LDA $D019
    STA $D019
    JMP $EA31
```

### Zona 1 (riga 160)

```asm
IRQ_ZONE1
    PHA
    TXA
    PHA
    TYA
    PHA

    ; Aggiorna sprite per nemici 8-15
    JSR UPDATE_ZONE1

    ; Prepara prossimo IRQ alla riga 240
    LDA #240
    STA $D012

    LDA #<IRQ_ZONE2
    STA $0314
    LDA #>IRQ_ZONE2
    STA $0315

    PLA
    TAY
    PLA
    TAX
    PLA

    LDA $D019
    STA $D019
    JMP $EA31
```

### Zona 2 (riga 240)

```asm
IRQ_ZONE2
    PHA
    TXA
    PHA
    TYA
    PHA

    ; Aggiorna sprite per nemici 16-23
    JSR UPDATE_ZONE2

    ; Torna alla zona 0 per il prossimo frame
    LDA #80
    STA $D012

    LDA #<IRQ_ZONE0
    STA $0314
    LDA #>IRQ_ZONE0
    STA $0315

    PLA
    TAY
    PLA
    TAX
    PLA

    LDA $D019
    STA $D019
    JMP $EA31
```

---

## 16.5 Aggiornamento sprite per zona

```asm
; Aggiorna gli sprite 0-7 con i nemici della zona
; INPUT: X = indice primo nemico (0, 8, 16)

UPDATE_ZONE
    LDY #0              ; Y = offset sprite HW (0,2,4,...14)

UZ_LOOP
    LDA ENEMY_ALIVE,X
    BEQ UZ_NEXT         ; nemico morto

    LDA ENEMY_X,X
    STA $D000,Y         ; X sprite hardware

    LDA ENEMY_Y,X
    STA $D001,Y         ; Y sprite hardware

    ; Abilita sprite
    LDA SPR_HW_MASK,Y
    ORA $D015
    STA $D015

    JMP UZ_CONT

UZ_NEXT
    ; Disabilita sprite
    LDA SPR_HW_MASK,Y
    EOR #$FF
    AND $D015
    STA $D015

UZ_CONT
    INX
    INY
    INY                 ; prossimo sprite HW (Y+2)

    CPY #16             ; 8 sprite × 2 byte offset
    BNE UZ_LOOP

    RTS

; Maschere per abilitazione sprite
SPR_HW_MASK
    .byte %00000001     ; sprite 0
    .byte %00000010     ; sprite 1
    .byte %00000100     ; sprite 2
    .byte %00001000     ; sprite 3
    .byte %00010000     ; sprite 4
    .byte %00100000     ; sprite 5
    .byte %01000000     ; sprite 6
    .byte %10000000     ; sprite 7
    .byte 0,0,0,0,0,0,0,0  ; padding per INY
```

### Routine specifiche per zona

```asm
UPDATE_ZONE0
    LDX #ZONE0_START
    JSR UPDATE_ZONE
    RTS

UPDATE_ZONE1
    LDX #ZONE1_START
    JSR UPDATE_ZONE
    RTS

UPDATE_ZONE2
    LDX #ZONE2_START
    JSR UPDATE_ZONE
    RTS
```

---

## 16.6 Gestione colore e pointer per zona

```asm
UPDATE_ZONE_COLORS
    ; Assegna colore a ogni sprite slot in base al nemico
    LDY #0
    LDX #ZONE0_START
UZC_LOOP
    LDA ENEMY_ALIVE,X
    BEQ UZC_SKIP

    LDA ENEMY_TYPE,X
    TAX
    LDA ENEMY_COLORS,X
    STA $D027,Y         ; colore sprite Y

UZC_SKIP
    INY
    CPY #8
    BNE UZC_LOOP
    RTS

ENEMY_COLORS
    .byte 2, 5, 7, 4    ; rosso, verde, giallo, viola
```

---

## 16.7 Assegnazione dinamica degli slot

Per multiplexing avanzato, gli slot non sono fissi ma assegnati in base alla Y:

```asm
; Ordina i nemici per Y e assegna agli 8 slot
; (versione semplificata)

ASSIGN_SPRITE_SLOTS
    ; Trova gli 8 nemici piu vicini per Y
    ; e assegnali agli sprite hardware

    ; Resetta assegnazioni
    LDX #0
    LDA #$FF
AS_CLEAR
    STA SPRITE_SLOT,X
    INX
    CPX #8
    BNE AS_CLEAR

    ; Scansione base: assegna in ordine Y crescente
    ; (per ogni slot, cerca il nemico con Y minore non ancora assegnato)

    LDY #0              ; slot hardware (0-7)
AS_SLOT
    LDA #255
    STA BEST_Y
    LDA #$FF
    STA BEST_ENEMY

    LDX #0              ; nemico logico
AS_FIND
    LDA ENEMY_ALIVE,X
    BEQ AS_NEXT

    ; Gia assegnato?
    LDA ENEMY_SLOT,X
    CMP #$FF
    BNE AS_NEXT

    LDA ENEMY_Y,X
    CMP BEST_Y
    BCS AS_NEXT

    STA BEST_Y
    STX BEST_ENEMY

AS_NEXT
    INX
    CPX #MAX_LOGICAL_ENEMIES
    BNE AS_FIND

    LDA BEST_ENEMY
    BMI AS_DONE          ; nessun nemico trovato

    TAX
    TYA
    STA ENEMY_SLOT,X     ; assegna slot

    INY
    CPY #8
    BNE AS_SLOT

AS_DONE
    RTS

BEST_Y     = $70
BEST_ENEMY = $71
ENEMY_SLOT = $D0        ; slot assegnato a ogni nemico
```

---

## 16.8 Limitazioni e performance

```
Ogni zona:    ~40-60 cicli CPU per aggiornamento
3 zone:       120-180 cicli CPU (su 20000 disponibili)
              Molto abbordabile!

Limiti reali:
- Max 8 sprite per zona verticale
- Distanza minima tra sprite nella stessa zona: ~21 pixel
- Ogni zona consuma un raster interrupt
```

### Budget tipico

```asm
; 3 IRQ di multiplexing = 3 × ~60 cicli = 180 cicli
; Frame intero (PAL) = ~20000 cicli
; Percentuale multiplexing: ~1% del frame!
```

---

## Esercizi

### Esercizio 1
Dividi lo schermo in 2 zone (0-120 e 121-240). Mostra 4 sprite per zona.

### Esercizio 2
Crea 16 nemici logici. I primi 8 vanno nella zona alta, gli altri 8 nella zona bassa.

### Esercizio 3
Implementa 3 zone con 8 nemici ciascuna (24 totali). Muovili tutti.

### Esercizio 4
Aggiungi l'assegnazione dinamica: gli sprite HW vengono assegnati ai nemici piu vicini alla zona.

### Esercizio 5
Misura il tempo CPU consumato dal multiplexing usando la barra di debug (`$D020`).

---

## Riepilogo

Hai imparato:

- Perche serve il multiplexing (limite 8 sprite HW)
- Dividere lo schermo in zone verticali
- Usare raster interrupt multipli per aggiornare ogni zona
- Gestire 24 nemici logici con 8 sprite HW
- Assegnazione dinamica degli slot per Y
- Calcolare il budget CPU del multiplexing
