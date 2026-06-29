# Capitolo 12 — Wave System e AI dei Nemici

## Obiettivi

Al termine di questo capitolo saprai:

- Creare ondate (wave) di nemici
- Muovere gruppi di nemici insieme
- Implementare cambi di direzione
- Gestire la difficolta crescente
- Usare tabelle per definire i pattern

---

## 12.1 Architettura delle ondate

In un arcade i nemici non compaiono tutti insieme. Arrivano a **onde** (wave).

```
Wave 0: 4 nemici lenti, schema lineare
Wave 1: 6 nemici, velocita media
Wave 2: 8 nemici, veloci, con cambio direzione
...     difficolta crescente
```

### Struttura dati

```asm
WAVE_INDEX      = $20    ; numero wave corrente (0,1,2...)
WAVE_STATE      = $21    ; 0=spawn, 1=combattimento, 2=completata
WAVE_TIMER      = $22    ; timer per spawn progressivo
ENEMIES_LEFT    = $23    ; nemici ancora vivi in questa wave
ENEMY_DIR       = $24    ; 0=sinistra, 1=destra
ENEMY_SPEED     = $25    ; velocita movimento
```

---

## 12.2 Tabelle nemici

```asm
; Massimo 16 nemici per wave
ENEMY_X      = $80     ; 16 byte
ENEMY_Y      = $90     ; 16 byte
ENEMY_ALIVE  = $A0     ; 16 byte (0=morto, 1=vivo)
ENEMY_TYPE   = $B0     ; 16 byte (tipo nemico)

MAX_ENEMIES  = 16
```

---

## 12.3 Spawn progressivo dei nemici

Ogni wave fa apparire i nemici uno alla volta:

```asm
UPDATE_WAVE
    LDA WAVE_STATE
    CMP #0
    BEQ DO_SPAWN
    CMP #1
    BEQ DO_BATTLE
    CMP #2
    BEQ DO_NEXT_WAVE
    RTS

DO_SPAWN
    DEC WAVE_TIMER
    BNE SPAWN_DONE

    LDA #20             ; 20 frame tra uno spawn e l'altro
    STA WAVE_TIMER

    JSR SPAWN_ENEMY

    LDA ENEMIES_LEFT
    CLC
    ADC #1
    STA ENEMIES_LEFT

    CMP #16             ; max nemici raggiunto?
    BNE SPAWN_DONE

    LDA #1
    STA WAVE_STATE      ; passiamo a combattimento

SPAWN_DONE
    RTS
```

### Routine di spawn

```asm
SPAWN_ENEMY
    ; Trova primo slot libero
    LDX #0
SE_LOOP
    LDA ENEMY_ALIVE,X
    BEQ SE_FOUND
    INX
    CPX #MAX_ENEMIES
    BNE SE_LOOP
    RTS                    ; nessuno slot

SE_FOUND
    LDA #1
    STA ENEMY_ALIVE,X

    ; Posiziona usando tabella predefinita
    LDA SPAWN_X_TAB,X
    STA ENEMY_X,X

    LDA SPAWN_Y_TAB,X
    STA ENEMY_Y,X

    ; Tipo nemico in base alla wave
    LDA WAVE_INDEX
    AND #3
    STA ENEMY_TYPE,X

    RTS

; Tabelle di spawn
SPAWN_X_TAB
    .byte 30, 70, 110, 150, 190, 30, 70, 110
    .byte 150, 190, 30, 70, 110, 150, 190, 210

SPAWN_Y_TAB
    .byte 40, 40, 40, 40, 40, 60, 60, 60
    .byte 60, 60, 80, 80, 80, 80, 80, 80
```

---

## 12.4 Movimento collettivo (Space Invaders style)

I nemici si muovono tutti insieme, come in formazione:

```asm
MOVE_ENEMIES
    LDX #0
ME_LOOP
    LDA ENEMY_ALIVE,X
    BEQ ME_NEXT

    LDA ENEMY_DIR
    BEQ MOVE_LEFT

MOVE_RIGHT
    LDA ENEMY_X,X
    CLC
    ADC ENEMY_SPEED
    STA ENEMY_X,X
    JMP ME_NEXT

MOVE_LEFT
    LDA ENEMY_X,X
    SEC
    SBC ENEMY_SPEED
    STA ENEMY_X,X

ME_NEXT
    INX
    CPX #MAX_ENEMIES
    BNE ME_LOOP
    RTS
```

---

## 12.5 Cambio direzione e discesa

Quando il gruppo tocca il bordo, cambia direzione e scende:

```asm
CHECK_EDGES
    LDX #0
CE_LOOP
    LDA ENEMY_ALIVE,X
    BEQ CE_NEXT

    ; Controlla bordo sinistro
    LDA ENEMY_X,X
    CMP #5
    BCC FLIP_DIR

    ; Controlla bordo destro
    CMP #250
    BCS FLIP_DIR

    JMP CE_NEXT

FLIP_DIR
    LDA ENEMY_DIR
    EOR #1              ; inverte direzione
    STA ENEMY_DIR

    JSR MOVE_DOWN       ; tutti giu di qualche pixel

    JMP CE_DONE

CE_NEXT
    INX
    CPX #MAX_ENEMIES
    BNE CE_LOOP

CE_DONE
    RTS

MOVE_DOWN
    LDX #0
MD_LOOP
    LDA ENEMY_ALIVE,X
    BEQ MD_NEXT

    LDA ENEMY_Y,X
    CLC
    ADC #4              ; scende di 4 pixel
    STA ENEMY_Y,X

MD_NEXT
    INX
    CPX #MAX_ENEMIES
    BNE MD_LOOP
    RTS
```

---

## 12.6 Wave completata

Quando tutti i nemici sono morti:

```asm
CHECK_WAVE_CLEAR
    LDX #0
    LDA #0
CWC_LOOP
    CLC
    ADC ENEMY_ALIVE,X
    INX
    CPX #MAX_ENEMIES
    BNE CWC_LOOP

    CMP #0
    BNE CWC_DONE       ; ancora nemici vivi

    ; Wave completata!
    LDA #2
    STA WAVE_STATE

    JSR PREPARE_NEXT_WAVE

CWC_DONE
    RTS

PREPARE_NEXT_WAVE
    INC WAVE_INDEX

    ; Aumenta difficolta
    LDA ENEMY_SPEED
    CLC
    ADC #1
    STA ENEMY_SPEED

    ; Riduci timer di spawn
    LDA WAVE_TIMER
    CMP #5
    BCC SPEED_OK
    SEC
    SBC #2
    STA WAVE_TIMER
SPEED_OK

    ; Reset stato
    LDA #0
    STA WAVE_STATE
    STA ENEMIES_LEFT

    RTS
```

---

## 12.7 Render nemici su sprite hardware

```asm
RENDER_ENEMIES
    LDX #0              ; indice nemico
    LDY #0              ; indice sprite HW (offset)

RE_LOOP
    LDA ENEMY_ALIVE,X
    BEQ RE_NEXT

    TXA
    PHA                 ; salva X

    ; Assegna posizione a sprite hardware
    LDA ENEMY_X,X
    STA $D002,Y         ; sprite 1 + offset

    LDA ENEMY_Y,X
    STA $D003,Y

    ; Colore in base al tipo
    LDA ENEMY_TYPE,X
    TAX
    LDA ENEMY_COLORS,X
    STA $D028,Y

    ; Abilita sprite
    TYA
    LSR
    TAX
    LDA SPRITE_EN_MASK,X
    ORA $D015
    STA $D015

    ; Pointer sprite in base al tipo
    LDA ENEMY_TYPE,X
    CLC
    ADC #193            ; pointer per frame 0
    STA $07F9,Y

    PLA
    TAX

    INY
    INY                 ; prossimo sprite HW

RE_NEXT
    INX
    CPX #MAX_ENEMIES
    BNE RE_LOOP
    RTS

SPRITE_EN_MASK
    .byte %00000010     ; sprite 1
    .byte %00000100     ; sprite 2
    .byte %00001000     ; sprite 3

ENEMY_COLORS
    .byte 2, 5, 7, 4    ; rosso, verde, giallo, viola
```

---

## 12.8 Pattern di movimento alternativi

Oltre al movimento lineare, possiamo usare tabelle di pattern:

```asm
; Tabella dei pattern di movimento
; Ogni wave usa un pattern diverso

PATTERN_TABLE
    .word PATTERN_LINEAR     ; wave 0
    .word PATTERN_ZIGZAG     ; wave 1
    .word PATTERN_SINE       ; wave 2

PATTERN_LINEAR
    ; movimento lineare: gia implementato
    RTS

PATTERN_ZIGZAG
    ; Ogni nemico si muove in modo diverso
    LDX #0
PZ_LOOP
    LDA ENEMY_ALIVE,X
    BEQ PZ_NEXT

    LDA ENEMY_X,X
    CLC
    ADC ENEMY_SPEED
    STA ENEMY_X,X

    ; Alterna su/giu
    TXA
    AND #1
    BEQ PZ_UP
    INC ENEMY_Y,X
    JMP PZ_NEXT
PZ_UP
    DEC ENEMY_Y,X

PZ_NEXT
    INX
    CPX #MAX_ENEMIES
    BNE PZ_LOOP
    RTS

PATTERN_SINE
    ; Movimento sinusoidale approssimato
    LDX #0
PS_LOOP
    LDA ENEMY_ALIVE,X
    BEQ PS_NEXT

    LDA ENEMY_X,X
    CLC
    ADC ENEMY_SPEED
    STA ENEMY_X,X

    ; Oscillazione Y basata su frame
    TXA
    CLC
    ADC FRAME_CNT
    AND #15
    SEC
    SBC #7
    CLC
    ADC ENEMY_Y,X
    STA ENEMY_Y,X

PS_NEXT
    INX
    CPX #MAX_ENEMIES
    BNE PS_LOOP
    RTS
```

---

## 12.9 AI nemico: tiro casuale

Un nemico ogni tanto spara:

```asm
ENEMY_SHOOT
    ; Ogni 30 frame, 1 nemico vivo spara
    LDA FRAME_CNT
    AND #31              ; ogni 32 frame
    BNE ES_DONE

    ; Scegli un nemico vivo a caso
    LDX #0
ES_FIND
    LDA ENEMY_ALIVE,X
    BNE ES_SHOOT
    INX
    CPX #MAX_ENEMIES
    BNE ES_FIND
    RTS

ES_SHOOT
    ; Crea proiettile nemico alla sua posizione
    JSR FIRE_ENEMY_BULLET

ES_DONE
    RTS
```

---

## Esercizi

### Esercizio 1
Crea 4 nemici che si muovono insieme da sinistra a destra. Quando toccano il bordo, scendono e invertono.

### Esercizio 2
Implementa lo spawn progressivo: un nemico appare ogni 30 frame.

### Esercizio 3
Ogni wave successiva aumenta la velocita dei nemici di 1.

### Esercizio 4
Aggiungi un nemico che spara ogni 40 frame.

### Esercizio 5
Crea 3 pattern di movimento diversi (lineare, zigzag, casuale) e assegnane uno per wave.

---

## Riepilogo

Hai imparato:

- Gestire ondate (wave) con stati SPAWN, BATTLE, CLEAR
- Pool di nemici con array statici
- Movimento collettivo con cambio direzione ai bordi
- Discesa graduale stile Space Invaders
- Tabella di spawn per posizionamento
- Difficolta crescente (velocita, timer)
- Pattern di movimento alternativi (zigzag, sine)
- Tiro casuale dei nemici
