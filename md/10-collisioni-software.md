# Capitolo 10 — Collisioni Software tra Sprite

## Obiettivi

Al termine di questo capitolo saprai:

- Rilevare collisioni via software
- Usare il bounding box per il confronto
- Sfruttare il registro collisioni hardware del VIC-II
- Gestire la reazione a una collisione
- Ottimizzare il controllo su piu entita

---

## 10.1 Perche serve il collision detection

In un gioco arcade, servono collisioni per:

```
Proiettile → Nemico  = danno/nemico distrutto
Giocatore → Nemico  = game over / danno
Giocatore → PowerUp = bonus
Nemico    → Nemico  = rimbalzo (opzionale)
```

Sul C64 ci sono due modi per rilevare collisioni:

1. **Hardware** (VIC-II) — `$D01E` e `$D01F`
2. **Software** (CPU) — confronto coordinate

Useremo entrambi, combinando velocita e precisione.

---

## 10.2 Collision Detection Software (bounding box)

Metodo piu flessibile: confrontiamo le coordinate di due sprite.

```
Sprite A:       Sprite B:
┌────────┐      ┌────────┐
│   XX   │      │    YY  │
│   XX   │      │   YY   │
└────────┘      └────────┘

Collisione se:
  |A.x - B.x| < 16  (larghezza sprite)
  |A.y - B.y| < 16  (altezza sprite)
```

### Implementazione base

```asm
; Confronta posizione di due sprite
; A_X, A_Y = primo sprite
; B_X, B_Y = secondo sprite
; Ritorna: A = 1 se collisione, 0 altrimenti

CHECK_COLLISION
    ; Differenza X
    LDA A_X
    SEC
    SBC B_X
    BPL POS_X
    EOR #$FF        ; valore assoluto
    CLC
    ADC #1
POS_X
    CMP #16         ; collisione se < 16 pixel
    BCS NO_HIT

    ; Differenza Y
    LDA A_Y
    SEC
    SBC B_Y
    BPL POS_Y
    EOR #$FF
    CLC
    ADC #1
POS_Y
    CMP #16
    BCS NO_HIT

    ; COLLISIONE!
    LDA #1
    RTS

NO_HIT
    LDA #0
    RTS

A_X = $02
A_Y = $03
B_X = $04
B_Y = $05
```

---

## 10.3 Versione ottimizzata

```asm
; Ingresso: X = indice entita 1, Y = indice entita 2
; Uscita: C = 1 se collisione

CHECK_COL
    LDA SPRITE_X,X
    SEC
    SBC SPRITE_X,Y
    BCS COL_X_OK
    EOR #$FF
    ADC #1
COL_X_OK
    CMP #16
    BCS COL_END

    LDA SPRITE_Y,X
    SEC
    SBC SPRITE_Y,Y
    BCS COL_Y_OK
    EOR #$FF
    ADC #1
COL_Y_OK
    CMP #16
    BCS COL_END

    SEC             ; collisione! C = 1
    RTS

COL_END
    CLC             ; nessuna collisione
    RTS

SPRITE_X = $40     ; tabella X
SPRITE_Y = $50     ; tabella Y
```

---

## 10.4 Collision Detection Hardware (VIC-II)

Il VIC-II ha registri che rilevano automaticamente le collisioni:

```
$D01E = Sprite-Sprite collision register
$D01F = Sprite-Background collision register
```

Ogni bit rappresenta uno sprite (0-7).

```asm
; Leggi collisioni sprite-sprite
LDA $D01E
STA COLL_MASK

; IMPORTANTE: resetta il registro
LDA $D01E
STA $D01E       ; si, scrivere lo stesso valore resetta
```

### Esempio di uso

```asm
CHECK_HW_COLLISION
    LDA $D01E
    BEQ NO_COL      ; nessun bit = nessuna collisione

    ; Salva e resetta
    STA $D01E       ; acknowledge

    ; Analizza quali sprite collidono
    ; Bit 0 = sprite 0 (player)
    ; Bit 1 = sprite 1 (proiettile)
    ; Bit 2 = sprite 2 (nemico)

    ; Esempio: player + proiettile + nemico
    TAX
    AND #%00000111  ; sprite 0,1,2 coinvolti?
    CMP #%00000111  ; tutti e tre?
    BEQ HIT_COMPLETE

    RTS

NO_COL
    RTS

HIT_COMPLETE
    ; ...gestisci hit...
    RTS
```

---

## 10.5 Sistema ibrido (hardware + software)

Il metodo migliore: usa l'hardware per rilevare VELOCEMENTE se c'e collisione, poi il software per capire CHI ha colpito CHI.

```asm
CHECK_ALL_COLLISIONS
    LDA $D01E
    BEQ DONE_COL
    STA $D01E          ; acknowledge

    ; Salva maschera collisione
    STA COLL_MASK

    ; Ora filtra software: chi ha colpito chi?
    ; Confronta le coordinate per determinare la coppia

    ; Proiettile (sprite 1) contro nemici (sprite 2-7)
    LDX #1             ; proiettile
    LDY #2             ; primo nemico
COL_LOOP
    JSR CHECK_COL      ; collisione software
    BCC NEXT_ENEMY

    ; Hit! Proiettile X ha colpito nemico Y
    JSR HANDLE_HIT

NEXT_ENEMY
    INY
    CPY #8
    BNE COL_LOOP

DONE_COL
    RTS
```

---

## 10.6 Gestire una collisione

Quando avviene una collisione, bisogna decidere cosa fare:

```asm
HANDLE_HIT
    ; Disattiva nemico
    LDA #0
    STA ENEMY_ALIVE,Y

    ; Disattiva proiettile
    STA BULLET_ACTIVE,X

    ; Incrementa punteggio
    LDA SCORE
    CLC
    ADC #10
    STA SCORE

    ; Effetto sonoro
    JSR PLAY_HIT_SOUND

    RTS

ENEMY_ALIVE = $60     ; tabella stato nemici
BULLET_ACTIVE = $70   ; tabella stato proiettili
SCORE       = $08     ; punteggio
```

---

## 10.7 Collisione player-nemico

```asm
CHECK_PLAYER_COL
    LDX #2             ; primo nemico
COL_PL_LOOP
    LDA ENEMY_ALIVE,X
    BEQ SKIP_PL        ; nemico morto, salta

    ; Confronta con player (sprite 0)
    JSR CHECK_COL_PLAYER
    BCC SKIP_PL

    ; Collisione player-nemico!
    JSR GAME_OVER

SKIP_PL
    INX
    CPX #8
    BNE COL_PL_LOOP
    RTS

CHECK_COL_PLAYER
    ; Confronta PLAYER_X/Y con ENEMY_X/Y
    LDA PLAYER_X
    SEC
    SBC ENEMY_X,X
    BPL PX_OK
    EOR #$FF
    ADC #1
PX_OK
    CMP #20            ; hitbox leggermente piu larga
    BCS NO_PL_COL

    LDA PLAYER_Y
    SEC
    SBC ENEMY_Y,X
    BPL PY_OK
    EOR #$FF
    ADC #1
PY_OK
    CMP #20
    BCS NO_PL_COL

    SEC
    RTS

NO_PL_COL
    CLC
    RTS
```

---

## 10.8 Organizzare i dati per le collisioni

```asm
; ----------------------------------
; STRUTTURA ENTITA
; ----------------------------------
; Ogni entita ha:
;   - X, Y (posizione)
;   - Active (0 = morto, 1 = vivo)
;   - Type (0 = player, 1 = bullet, 2 = enemy)

ENEMY_X     = $80     ; 8 byte
ENEMY_Y     = $88     ; 8 byte
ENEMY_ACTIVE = $90    ; 8 byte
ENEMY_TYPE  = $98     ; 8 byte

BULLET_X    = $60     ; 4 byte
BULLET_Y    = $64     ; 4 byte
BULLET_ACTIVE = $68   ; 4 byte

PLAYER_X    = $02
PLAYER_Y    = $03
PLAYER_ALIVE = $04
```

---

## Esercizi

### Esercizio 1
Crea due sprite: uno controllato dal joystick e uno fisso. Rileva quando si toccano e cambia colore.

### Esercizio 2
Implementa il registro `$D01E` per rilevare una collisione tra sprite 0 e sprite 1.

### Esercizio 3
Crea 3 nemici fissi. Muovi il player con il joystick. Quando tocchi un nemico, disattivalo (imposta `ENEMY_ACTIVE = 0`).

### Esercizio 4
Estendi l'esercizio 3: quando tutti i nemici sono morti, mostra "VITTORIA!" a schermo.

### Esercizio 5
Implementa un sistema di invincibilita post-collisione: dopo essere stato colpito, il player non puo essere danneggiato per 60 frame.

---

## Riepilogo

Hai imparato:

- Collision detection con bounding box (valore assoluto)
- Il registro hardware `$D01E` (sprite-sprite)
- Sistema ibrido: hardware per velocita + software per precisione
- Gestire hit: disattivazione, punteggio, suono
- Organizzare i dati delle entita per collisioni
- Hitbox differenziate (player vs proiettile)

## Riferimenti

- [Capitolo 11 — Sistema proiettili](11-sistema-proiettili.md) — collisioni proiettile-nemico
- [Capitolo 18 — Boss system](18-boss-system.md) — collisioni con boss multi-fase
- [Soluzioni](../soluzioni/cap10-collisioni.asm) — soluzioni degli esercizi
