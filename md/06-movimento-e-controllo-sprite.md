# Capitolo 6 — Movimento e Controllo degli Sprite

## Obiettivi

Al termine di questo capitolo saprai:

- Muovere uno sprite con variabili e cicli
- Gestire la coordinata X oltre 255
- Usare espansione e multicolore
- Cambiare frame di animazione
- Organizzare i dati sprite per il gioco

---

## 6.1 Muovere uno sprite con variabili

Usiamo una variabile in Zero Page per la posizione:

```asm
SPRITE_X = $02
SPRITE_Y = $03

*=$8000

START
    LDA #%00000001
    STA $D015       ; abilita sprite 0

    LDA #1
    STA $D027       ; colore bianco

    LDA #192
    STA $07F8       ; pointer

    LDA #50
    STA SPRITE_X    ; X iniziale
    STA SPRITE_Y    ; Y iniziale

    STA $D000       ; aggiorna VIC
    STA $D001

MAINLOOP
    INC SPRITE_X    ; X++
    LDA SPRITE_X
    STA $D000       ; aggiorna VIC

    JSR DELAY
    JMP MAINLOOP

DELAY
    LDX #$20
D1
    LDY #$FF
D2
    DEY
    BNE D2
    DEX
    BNE D1
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

## 6.2 Muovere con bordi (rimbalzo)

Aggiungiamo il controllo dei bordi:

```asm
SPRITE_X   = $02
DIRECTION  = $03   ; 0 = destra, 1 = sinistra

*=$8000

START
    LDA #%00000001
    STA $D015
    LDA #1
    STA $D027
    LDA #192
    STA $07F8

    LDA #50
    STA SPRITE_X
    STA $D000

    LDA #100
    STA $D001

    LDA #0         ; direzione iniziale: destra
    STA DIRECTION

MAINLOOP
    LDA DIRECTION
    BEQ MOVE_RIGHT

MOVE_LEFT
    DEC SPRITE_X
    LDA SPRITE_X
    CMP #10
    BCS CHECK_RIGHT
    LDA #0          ; inverti
    STA DIRECTION
    JMP UPDATE_X

MOVE_RIGHT
    INC SPRITE_X
    LDA SPRITE_X
    CMP #240
    BCC UPDATE_X
    LDA #1          ; inverti
    STA DIRECTION

UPDATE_X
    LDA SPRITE_X
    STA $D000

    JSR DELAY
    JMP MAINLOOP

DELAY
    LDX #$20
D1
    LDY #$FF
D2
    DEY
    BNE D2
    DEX
    BNE D1
    RTS
```

---

## 6.3 Gestire X oltre 255 (MSB)

Lo schermo e largo 320 pixel ma X e solo 8 bit (0-255). Per valori > 255 serve il bit MSB in `$D010`.

```
$D010 bit 0 = MSB per sprite 0 (1 = parte destra dello schermo)
```

```asm
SPRITE_X = $02
SPRITE_X_MSB = $03   ; 0 o 1 per la parte destra

    ; Prima di aggiornare, controlliamo
    LDA SPRITE_X
    CMP #255
    BCC NO_MSB

    ; X > 255: attiva MSB e sottrai 256
    LDA #%00000001
    STA $D010
    LDA SPRITE_X
    SEC
    SBC #256
    STA $D000
    JMP DONE

NO_MSB
    LDA #%11111110
    AND $D010       ; spegne MSB sprite 0
    STA $D010
    LDA SPRITE_X
    STA $D000

DONE
```

### Versione completa: sprite che attraversa tutto lo schermo

```asm
SPRITE_X = $02

*=$8000

START
    LDA #%00000001
    STA $D015
    LDA #1
    STA $D027
    LDA #192
    STA $07F8

    LDA #0
    STA SPRITE_X
    STA $D000
    LDA #100
    STA $D001

MAINLOOP
    INC SPRITE_X

    ; Controllo MSB
    LDA SPRITE_X
    CMP #100        ; oltre 100 gestiamo MSB per test
    BCS SET_MSB

    LDA #%11111110
    AND $D010
    STA $D010
    LDA SPRITE_X
    STA $D000
    JMP CONTINUE

SET_MSB
    LDA #%00000001
    STA $D010
    LDA SPRITE_X
    SEC
    SBC #100
    STA $D000

CONTINUE
    JSR DELAY
    JMP MAINLOOP

DELAY
    LDX #$10
D1
    LDY #$FF
D2
    DEY
    BNE D2
    DEX
    BNE D1
    RTS
```

---

## 6.4 Espansione sprite

### Espansione orizzontale (`$D01D`)

```asm
LDA #%00000001    ; espandi sprite 0 in orizzontale
STA $D01D
```

### Espansione verticale (`$D017`)

```asm
LDA #%00000001    ; espandi sprite 0 in verticale
STA $D017
```

### Espansione entrambi

```asm
LDA #%00000001
STA $D01D
STA $D017         ; sprite 0 grande il doppio!
```

---

## 6.5 Sprite multicolore

Attiva la modalita multicolore per uno sprite:

```asm
LDA #%00000001    ; sprite 0 multicolore
STA $D01C
```

In multicolore ogni coppia di bit definisce un colore:

```
Bit coppia   Colore
──────────────────────
00           Trasparente
01           Colore sprite ($D027)
10           Colore comune 1 ($D025)
11           Colore comune 2 ($D026)
```

### Setup multicolore

```asm
    LDA #%00000001
    STA $D01C       ; sprite 0 multicolore

    LDA #5
    STA $D025       ; colore comune 1 (verde)

    LDA #7
    STA $D026       ; colore comune 2 (giallo)

    LDA #2
    STA $D027       ; colore sprite 0 (rosso)
```

---

## 6.6 Animazione: cambiare frame

Possiamo cambiare i dati dello sprite modificando il pointer:

```asm
; Sprite 0: due frame di animazione
; Frame 0 a $3000 (pointer 192)
; Frame 1 a $3040 (pointer 193)

FRAME = $02

START
    LDA #%00000001
    STA $D015
    LDA #1
    STA $D027
    LDA #100
    STA $D000
    LDA #100
    STA $D001

    LDA #0
    STA FRAME

MAINLOOP
    LDA FRAME
    CLC
    ADC #192        ; pointer base + frame
    STA $07F8

    INC FRAME
    LDA FRAME
    AND #1          ; alterna 0/1
    STA FRAME

    JSR DELAY
    JMP MAINLOOP

*=$3000
; Frame 0: nave normale
FRAME0
    .byte 0,60,0
    .byte 0,126,0
    .byte 255,255,255
    ; ... (21 righe)

*=$3040
; Frame 1: nave con fiamme
FRAME1
    .byte 0,60,0
    .byte 0,126,0
    .byte 255,255,255
    ; ... (21 righe, diverse)
```

---

## 6.7 Organizzazione professionale dei dati sprite

Nei giochi reali si organizza cosi:

```
$3000 - $3FFF   Dati sprite
  │
  ├─ $3000   Sprite 0, frame 0  (64 byte)
  ├─ $3040   Sprite 0, frame 1  (64 byte)
  ├─ $3080   Sprite 0, frame 2  (64 byte)
  ├─ $30C0   Sprite 1, frame 0  (64 byte)
  ├─ $3100   Sprite 1, frame 1  (64 byte)
  └─ ...
```

Ogni sprite frame occupa esattamente 64 byte ($40).

```
Pointer per sprite 0 frame 2:  $3080 / 64 = 194
Pointer per sprite 1 frame 0:  $30C0 / 64 = 195
```

---

## Esercizi

### Esercizio 1
Muovi uno sprite da sinistra a destra. Quando arriva a X=250, torna a X=50.

### Esercizio 2
Aggiungi il movimento anche sull'asse Y: lo sprite deve muoversi in diagonale.

### Esercizio 3
Crea uno sprite che cambi colore ogni volta che tocca il bordo.

### Esercizio 4
Realizza un'animazione a 4 frame per un alieno che sbatte le ali. Cambia frame ogni 8 iterazioni del loop.

### Esercizio 5
Crea 3 sprite allineati orizzontalmente che si muovono insieme come una formazione.

---

## Riepilogo

Hai imparato:

- Muovere sprite con variabili
- Gestire il rimbalzo ai bordi
- Usare `$D010` per X oltre 255 pixel
- Espandere sprite in orizzontale e verticale
- Usare la modalita multicolore
- Animare sprite cambiando pointer
- Organizzare frame sprite in memoria
