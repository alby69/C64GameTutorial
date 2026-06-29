# Capitolo 11 — Sistema Proiettili

## Obiettivi

Al termine di questo capitolo saprai:

- Creare un pool di proiettili
- Sparare con il pulsante del joystick
- Aggiornare la posizione dei proiettili ogni frame
- Rilevare quando un proiettile esce dallo schermo
- Gestire il riutilizzo dei proiettili nel pool

---

## 11.1 Pool di proiettili

In un gioco arcade non si creano/distruggono oggetti dinamicamente (troppo lento). Si usa un **pool fisso**:

```asm
; Pool di 4 proiettili
BULLET_X    = $60     ; 4 byte
BULLET_Y    = $64     ; 4 byte
BULLET_ACTIVE = $68   ; 4 byte (0=inattivo, 1=attivo)

MAX_BULLETS = 4
```

### Inizializzazione

```asm
INIT_BULLETS
    LDA #0
    LDX #0
INIT_BL_LOOP
    STA BULLET_ACTIVE,X
    INX
    CPX #MAX_BULLETS
    BNE INIT_BL_LOOP
    RTS
```

---

## 11.2 Sparare un proiettile

Cerchiamo il primo slot libero nel pool:

```asm
FIRE_BULLET
    LDX #0

FIND_SLOT
    LDA BULLET_ACTIVE,X
    BEQ SLOT_FOUND     ; slot libero

    INX
    CPX #MAX_BULLETS
    BNE FIND_SLOT
    RTS                  ; nessuno slot libero

SLOT_FOUND
    LDA #1
    STA BULLET_ACTIVE,X ; attiva proiettile

    LDA PLAYER_X
    CLC
    ADC #4              ; centra il proiettile
    STA BULLET_X,X

    LDA PLAYER_Y
    SEC
    SBC #8              ; parte sopra il player
    STA BULLET_Y,X

    LDA #1
    STA BULLET_SPEED

    RTS

PLAYER_X    = $02
PLAYER_Y    = $03
BULLET_SPEED = $06
```

---

## 11.3 Aggiornamento proiettili

Ogni frame, tutti i proiettili attivi si muovono verso l'alto:

```asm
UPDATE_BULLETS
    LDX #0

BL_LOOP
    LDA BULLET_ACTIVE,X
    BEQ BL_NEXT        ; proiettile inattivo

    ; Muovi verso l'alto
    DEC BULLET_Y,X

    ; Controlla se e uscito dallo schermo
    LDA BULLET_Y,X
    CMP #5
    BCS BL_NEXT        ; ancora visibile

    ; Uscito dallo schermo: disattiva
    LDA #0
    STA BULLET_ACTIVE,X
    BNE BL_DONE        ; salto incondizionato (sempre)

BL_NEXT
BL_DONE
    INX
    CPX #MAX_BULLETS
    BNE BL_LOOP
    RTS
```

---

## 11.4 Disegnare i proiettili come sprite

Assegnamo gli sprite 4-7 ai proiettili:

```asm
RENDER_BULLETS
    LDX #0
    STX TEMP          ; indice sprite hardware

RN_LOOP
    LDA BULLET_ACTIVE,X
    BEQ RN_NEXT

    ; Assegna posizione a sprite hardware
    LDY TEMP

    LDA BULLET_X,X
    STA $D008,Y       ; X sprite 4 + offset

    LDA BULLET_Y,X
    STA $D009,Y       ; Y sprite 4 + offset

    ; Colore
    LDA #7            ; giallo
    STA $D02B,Y       ; colore sprite 4 + offset (in realta $D027+)

    ; Abilita sprite
    LDA $D015
    ORA SPRITE_MASK,Y
    STA $D015

    INC TEMP
    TYA
    CLC
    ADC #2
    TAY

RN_NEXT
    INX
    CPX #MAX_BULLETS
    BNE RN_LOOP

    ; Disabilita sprite non usati
    LDX TEMP
    CPX #4
    BEQ RN_DONE
    ; ... disabilita sprite extra ...
RN_DONE
    RTS

SPRITE_MASK
    .byte %00010000    ; sprite 4
    .byte %00100000    ; sprite 5
    .byte %01000000    ; sprite 6
    .byte %10000000    ; sprite 7

TEMP = $05
```

---

## 11.5 Sistema completo di fuoco

Integriamo con il joystick:

```asm
*=$8000

PLAYER_X    = $02
PLAYER_Y    = $03
FRAME_CNT   = $04
TEMP        = $05
FIRE_COOLDOWN = $06

; Pool proiettili
BULLET_X    = $60
BULLET_Y    = $64
BULLET_ACTIVE = $68
MAX_BULLETS = 4

START
    JSR INIT_GAME

MAINLOOP
    JSR WAIT_FRAME
    INC FRAME_CNT

    JSR READ_JOY
    JSR MOVE_PLAYER
    JSR HANDLE_FIRE
    JSR UPDATE_BULLETS
    JSR RENDER_BULLETS
    JSR UPDATE_PLAYER_SPRITE
    JMP MAINLOOP

; ----------------------------------
; GESTIONE FUOCO CON COOLDOWN
; ----------------------------------
HANDLE_FIRE
    LDA FIRE_COOLDOWN
    BEQ CHECK_FIRE
    DEC FIRE_COOLDOWN
    RTS

CHECK_FIRE
    LDA $DC01
    AND #%00010000      ; fire premuto?
    BNE NO_FIRE

    JSR FIRE_BULLET
    LDA #8
    STA FIRE_COOLDOWN   ; 8 frame di pausa
NO_FIRE
    RTS

; ----------------------------------
; SPARO
; ----------------------------------
FIRE_BULLET
    LDX #0
FS_LOOP
    LDA BULLET_ACTIVE,X
    BEQ FS_FOUND
    INX
    CPX #MAX_BULLETS
    BNE FS_LOOP
    RTS

FS_FOUND
    LDA #1
    STA BULLET_ACTIVE,X
    LDA PLAYER_X
    CLC
    ADC #4
    STA BULLET_X,X
    LDA PLAYER_Y
    STA BULLET_Y,X
    RTS

; ----------------------------------
; UPDATE PROIETTILI
; ----------------------------------
UPDATE_BULLETS
    LDX #0
UB_LOOP
    LDA BULLET_ACTIVE,X
    BEQ UB_NEXT
    DEC BULLET_Y,X
    LDA BULLET_Y,X
    CMP #5
    BCS UB_NEXT
    LDA #0
    STA BULLET_ACTIVE,X
UB_NEXT
    INX
    CPX #MAX_BULLETS
    BNE UB_LOOP
    RTS

; ----------------------------------
; RENDER
; ----------------------------------
RENDER_BULLETS
    LDX #0
    STX TEMP
RB_LOOP
    LDA BULLET_ACTIVE,X
    BEQ RB_NEXT
    LDY TEMP
    LDA BULLET_X,X
    STA $D008,Y
    LDA BULLET_Y,X
    STA $D009,Y
    LDA #7
    STA $D02B,Y
    LDA $D015
    ORA SPRTMSK,Y
    STA $D015
    INC TEMP
RB_NEXT
    INX
    CPX #MAX_BULLETS
    BNE RB_LOOP
    RTS

SPRTMSK
    .byte %00010000, %00100000, %01000000, %10000000

; ----------------------------------
; JOYSTICK
; ----------------------------------
READ_JOY
    LDA $DC01
    EOR #$FF
    AND #%00011111
    STA TEMP
    RTS

MOVE_PLAYER
    LDA TEMP
    AND #%00000001
    BEQ M_DOWN
    LDA PLAYER_Y
    CMP #30
    BCC M_DOWN
    DEC PLAYER_Y
M_DOWN
    LDA TEMP
    AND #%00000010
    BEQ M_LEFT
    LDA PLAYER_Y
    CMP #220
    BCS M_LEFT
    INC PLAYER_Y
M_LEFT
    LDA TEMP
    AND #%00000100
    BEQ M_RIGHT
    LDA PLAYER_X
    CMP #10
    BCC M_RIGHT
    DEC PLAYER_X
M_RIGHT
    LDA TEMP
    AND #%00001000
    BEQ M_DONE
    LDA PLAYER_X
    CMP #240
    BCS M_DONE
    INC PLAYER_X
M_DONE
    RTS

UPDATE_PLAYER_SPRITE
    LDA PLAYER_X
    STA $D000
    LDA PLAYER_Y
    STA $D001
    RTS

INIT_GAME
    LDA #%00000001
    STA $D015
    LDA #1
    STA $D027
    LDA #192
    STA $07F8
    LDA #160
    STA PLAYER_X
    LDA #180
    STA PLAYER_Y
    LDA #0
    STA FIRE_COOLDOWN
    STA FRAME_CNT

    ; Inizializza pool proiettili
    LDX #0
IG_BL
    STA BULLET_ACTIVE,X
    INX
    CPX #4
    BNE IG_BL
    RTS

WAIT_FRAME
    LDA $D012
    CMP #$F8
    BNE WAIT_FRAME
    RTS

*=$3000
SPRITE_DATA
    .byte 0,60,0
    .byte 0,126,0
    .byte 255,255,255
    .byte 255,255,255
    .byte 0,126,0
    .byte 0,60,0
    .byte 0,24,0
    .byte 0,24,0
    .byte 0,0,0
    .byte 0,0,0
    .byte 0,0,0
    .byte 0,0,0
    .byte 0,0,0
    .byte 0,0,0
    .byte 0,0,0
    .byte 0,0,0
    .byte 0,0,0
    .byte 0,0,0
    .byte 0,0,0
    .byte 0,0,0
    .byte 0,0,0
```

---

## 11.6 Proiettili nemici (opzionale)

Per i nemici che sparano verso il basso:

```asm
ENEMY_BULLET_X = $70
ENEMY_BULLET_Y = $74
ENEMY_BULLET_ACTIVE = $78

FIRE_ENEMY_BULLET
    LDX #0
EF_LOOP
    LDA ENEMY_BULLET_ACTIVE,X
    BEQ EF_FOUND
    INX
    CPX #2              ; 2 proiettili nemici
    BNE EF_LOOP
    RTS

EF_FOUND
    LDA #1
    STA ENEMY_BULLET_ACTIVE,X
    LDA ENEMY_X
    STA ENEMY_BULLET_X,X
    LDA ENEMY_Y
    CLC
    ADC #12
    STA ENEMY_BULLET_Y,X
    RTS

UPDATE_ENEMY_BULLETS
    LDX #0
EUB_LOOP
    LDA ENEMY_BULLET_ACTIVE,X
    BEQ EUB_NEXT
    INC ENEMY_BULLET_Y,X    ; scende verso il basso
    LDA ENEMY_BULLET_Y,X
    CMP #230
    BCC EUB_NEXT
    LDA #0
    STA ENEMY_BULLET_ACTIVE,X
EUB_NEXT
    INX
    CPX #2
    BNE EUB_LOOP
    RTS
```

---

## Esercizi

### Esercizio 1
Crea un pool di 2 proiettili. Sparali con il pulsante di fuoco.

### Esercizio 2
Aggiungi il cooldown: si puo sparare solo ogni 10 frame.

### Esercizio 3
I proiettili devono colpire un nemico fisso a schermo. Quando lo colpiscono, scompare.

### Esercizio 4
Aggiungi proiettili nemici: ogni 30 frame, un nemico spara un proiettile verso il basso.

### Esercizio 5
Crea un power-up: raccogliendo un oggetto speciale, il numero di proiettili aumenta a 6.

---

## Riepilogo

Hai imparato:

- Cos'e un pool di proiettili (array statico)
- Cercare slot liberi nel pool
- Sparare con joystick e cooldown
- Aggiornare proiettili ogni frame
- Disattivare proiettili fuori schermo
- Assegnare sprite hardware ai proiettili
- Proiettili nemici (verso il basso)
