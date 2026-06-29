# Capitolo 18 — Boss Fight Multi-Fase

## Obiettivi

Al termine di questo capitolo saprai:

- Progettare un boss con fasi multiple
- Implementare pattern di attacco
- Gestire la transizione tra le fasi
- Simulare un comportamento "intelligente"
- Creare la sequenza di morte

---

## 18.1 Architettura del Boss

Un boss arcade non e un nemico normale. E una **macchina a stati** con fasi multiple:

```
FASE 0: Intro  — il boss appare, animazione di ingresso
FASE 1: Attacco base — pattern semplice
FASE 2: Attacco avanzato — pattern piu veloce
FASE 3: Enrage — velocita massima, pattern casuale
FASE 4: Morte — animazione di distruzione
```

### Struttura dati

```asm
BOSS_HP     = $50    ; punti vita (0-255)
BOSS_STATE  = $51    ; fase corrente (0-4)
BOSS_TIMER  = $52    ; timer per pattern
BOSS_X      = $53    ; posizione X
BOSS_Y      = $54    ; posizione Y
BOSS_DIR    = $55    ; direzione movimento
BOSS_SEED   = $56    ; seed per "casualita"

BOSS_ACTIVE = $57    ; 0 = inattivo, 1 = attivo
```

---

## 18.2 Macchina a stati del boss

```asm
UPDATE_BOSS
    LDA BOSS_ACTIVE
    BEQ BOSS_DONE

    LDA BOSS_STATE
    CMP #0
    BEQ BOSS_INTRO
    CMP #1
    BEQ BOSS_PATTERN_A
    CMP #2
    BEQ BOSS_PATTERN_B
    CMP #3
    BEQ BOSS_ENRAGE
    CMP #4
    BEQ BOSS_DEATH

BOSS_DONE
    RTS

; ----------------------------------
; INTRO: il boss appare
; ----------------------------------
BOSS_INTRO
    LDA BOSS_Y
    CMP #60
    BCS INTRO_DONE

    INC BOSS_Y         ; scende in campo
    RTS

INTRO_DONE
    LDA #1
    STA BOSS_STATE     ; passa a pattern A
    LDA #0
    STA BOSS_TIMER
    RTS

; ----------------------------------
; PATTERN A: movimento lineare
; ----------------------------------
BOSS_PATTERN_A
    DEC BOSS_TIMER
    BPL PA_MOVE
    LDA #20
    STA BOSS_TIMER

    ; Sparo ogni 20 frame
    JSR BOSS_SHOOT

PA_MOVE
    JSR BOSS_MOVE
    RTS

; ----------------------------------
; PATTERN B: movimento + spari frequenti
; ----------------------------------
BOSS_PATTERN_B
    DEC BOSS_TIMER
    BPL PB_MOVE
    LDA #10
    STA BOSS_TIMER

    ; Sparo ogni 10 frame
    JSR BOSS_SHOOT
    JSR BOSS_SHOOT     ; due proiettili

PB_MOVE
    JSR BOSS_MOVE_FAST
    RTS

; ----------------------------------
; ENRAGE: velocita massima
; ----------------------------------
BOSS_ENRAGE
    DEC BOSS_TIMER
    BPL PE_MOVE
    LDA #5
    STA BOSS_TIMER

    ; Sparo ogni 5 frame
    JSR BOSS_SHOOT
    JSR BOSS_SHOOT
    JSR BOSS_SHOOT     ; raffica!

PE_MOVE
    JSR BOSS_MOVE_RANDOM
    RTS

; ----------------------------------
; MORTE
; ----------------------------------
BOSS_DEATH
    JSR DEATH_ANIMATION

    DEC BOSS_HP
    LDA BOSS_HP
    BEQ BOSS_DEAD

    RTS

BOSS_DEAD
    LDA #0
    STA BOSS_ACTIVE
    JSR SPAWN_EXPLOSION
    JSR ADD_SCORE_BOSS
    RTS
```

---

## 18.3 Pattern di movimento

```asm
BOSS_MOVE
    ; Movimento sinistra-destra
    LDA BOSS_DIR
    BEQ BM_LEFT

BM_RIGHT
    INC BOSS_X
    LDA BOSS_X
    CMP #240
    BCC BM_DONE
    LDA #0
    STA BOSS_DIR
    JMP BM_DONE

BM_LEFT
    DEC BOSS_X
    LDA BOSS_X
    CMP #20
    BCS BM_DONE
    LDA #1
    STA BOSS_DIR

BM_DONE
    RTS

BOSS_MOVE_FAST
    ; Come BOSS_MOVE ma piu veloce
    LDA BOSS_DIR
    BEQ BMF_LEFT

BMF_RIGHT
    INC BOSS_X
    INC BOSS_X          ; 2 pixel per frame!
    LDA BOSS_X
    CMP #240
    BCC BMF_DONE
    LDA #0
    STA BOSS_DIR
    JMP BMF_DONE

BMF_LEFT
    DEC BOSS_X
    DEC BOSS_X
    LDA BOSS_X
    CMP #20
    BCS BMF_DONE
    LDA #1
    STA BOSS_DIR

BMF_DONE
    RTS

BOSS_MOVE_RANDOM
    ; Movimento erratico
    LDA BOSS_SEED
    EOR $D012           ; usa raster per random
    STA BOSS_SEED

    AND #3
    BEQ BM_R_UP
    CMP #1
    BEQ BM_R_DOWN
    CMP #2
    BEQ BM_R_LEFT
    JMP BM_R_RIGHT

BM_R_UP
    DEC BOSS_Y
    JMP BM_R_DONE
BM_R_DOWN
    INC BOSS_Y
    JMP BM_R_DONE
BM_R_LEFT
    DEC BOSS_X
    JMP BM_R_DONE
BM_R_RIGHT
    INC BOSS_X

BM_R_DONE
    ; Tieni dentro i bordi
    LDA BOSS_X
    CMP #10
    BCS CHK_R_MAX
    LDA #10
    STA BOSS_X
CHK_R_MAX
    CMP #250
    BCC CHK_R_Y
    LDA #250
    STA BOSS_X
CHK_R_Y
    LDA BOSS_Y
    CMP #40
    BCS CHK_R_Y2
    LDA #40
    STA BOSS_Y
CHK_R_Y2
    CMP #200
    BCC BM_R_END
    LDA #200
    STA BOSS_Y
BM_R_END
    RTS
```

---

## 18.4 Transizione tra fasi

Il cambio fase avviene in base agli HP persi:

```asm
CHECK_BOSS_PHASE
    LDA BOSS_HP
    CMP #120
    BCS PHASE_DONE      ; HP > 120: fase attuale

    CMP #80
    BCS PHASE_B         ; HP 80-120: fase B

    CMP #40
    BCS PHASE_ENRAGE    ; HP 40-80: enrage

    ; HP < 40: morte imminente
    LDA BOSS_STATE
    CMP #4
    BEQ PHASE_DONE
    LDA #4
    STA BOSS_STATE
    RTS

PHASE_B
    LDA BOSS_STATE
    CMP #2
    BEQ PHASE_DONE
    CMP #3
    BEQ PHASE_DONE
    CMP #4
    BEQ PHASE_DONE
    LDA #2
    STA BOSS_STATE
    RTS

PHASE_ENRAGE
    LDA BOSS_STATE
    CMP #3
    BEQ PHASE_DONE
    CMP #4
    BEQ PHASE_DONE
    LDA #3
    STA BOSS_STATE
    LDA #1
    STA BOSS_TIMER

PHASE_DONE
    RTS
```

---

## 18.5 Il boss spara

```asm
BOSS_SHOOT
    ; Cerca un proiettile nel pool nemico
    LDX #0
BS_LOOP
    LDA ENEMY_BULLET_ACTIVE,X
    BEQ BS_FOUND
    INX
    CPX #4
    BNE BS_LOOP
    RTS                     ; nessuno slot

BS_FOUND
    LDA #1
    STA ENEMY_BULLET_ACTIVE,X

    LDA BOSS_X
    CLC
    ADC #12
    STA ENEMY_BULLET_X,X

    LDA BOSS_Y
    CLC
    ADC #16
    STA ENEMY_BULLET_Y,X

    RTS
```

---

## 18.6 Animazione di morte

```asm
DEATH_ANIMATION
    INC $D020               ; flash bordo

    ; Alterna colore sprite
    LDA FRAME_CNT
    AND #3
    TAX
    LDA DEATH_COLORS,X
    STA $D027               ; colore sprite boss

    ; Effetto sonoro
    JSR EXPLOSION_SOUND

    RTS

DEATH_COLORS
    .byte 2, 1, 2, 0        ; rosso, bianco, rosso, nero
```

---

## 18.7 "Pseudo-AI" del boss

Simuliamo intelligenza adattiva basata sul comportamento del giocatore:

```asm
; Tracker del giocatore
PLAYER_HITS   = $58    ; quante volte il player ha colpito
PLAYER_MISSES = $59    ; quante volte il player ha mancato

; Il boss "impara":
ADAPT_BOSS
    LDA PLAYER_HITS
    SEC
    SBC PLAYER_MISSES
    BMI PLAYER_BAD      ; player sta perdendo

    ; Player sta andando bene: aumenta difficolta!
    LDA BOSS_TIMER
    CMP #5
    BCC ADAPT_DONE
    SBC #2
    STA BOSS_TIMER
    RTS

PLAYER_BAD
    ; Player in difficolta: rallenta un po
    LDA BOSS_TIMER
    CMP #30
    BCS ADAPT_DONE
    CLC
    ADC #2
    STA BOSS_TIMER

ADAPT_DONE
    RTS
```

---

## 18.8 Render del boss

```asm
RENDER_BOSS
    LDA BOSS_ACTIVE
    BEQ RB_DONE

    ; Usa sprite 0 per il boss
    LDA BOSS_X
    STA $D000
    LDA BOSS_Y
    STA $D001

    ; Colore alternato per fase
    LDA BOSS_STATE
    TAX
    LDA BOSS_COLORS,X
    STA $D027

    ; Abilita sprite 0
    LDA $D015
    ORA #%00000001
    STA $D015

RB_DONE
    RTS

BOSS_COLORS
    .byte 7, 2, 4, 1, 0    ; giallo, rosso, viola, bianco, nero
```

---

## 18.9 Attivazione del boss

```asm
; Attiva il boss quando una condizione e vera (es. wave 5)
ACTIVATE_BOSS
    LDA WAVE_INDEX
    CMP #5
    BNE AB_DONE

    LDA BOSS_ACTIVE
    BNE AB_DONE             ; gia attivo

    LDA #1
    STA BOSS_ACTIVE
    STA BOSS_DIR

    LDA #200
    STA BOSS_HP

    LDA #0
    STA BOSS_STATE          ; intro

    LDA #160
    STA BOSS_X
    LDA #0
    STA BOSS_Y              ; parte dall'alto

AB_DONE
    RTS
```

---

## Esercizi

### Esercizio 1
Crea un boss con 3 fasi: intro + pattern A + morte.

### Esercizio 2
Il boss si muove da sinistra a destra e spara un proiettile ogni 30 frame.

### Esercizio 3
Quando il boss perde meta HP, passa alla fase enrage (piu veloce, spara 2 proiettili).

### Esercizio 4
Implementa l'animazione di morte: flash del bordo e colore che cambia.

### Esercizio 5
Il boss adatta la difficolta: se il player colpisce molto, il boss accelera.

---

## Riepilogo

Hai imparato:

- Boss come macchina a stati a fasi multiple
- Pattern di movimento (lineare, veloce, casuale)
- Sparo del boss in pool proiettili
- Transizione tra fasi basata su HP
- Animazione di morte con flash
- Pseudo-AI adattiva
- Attivazione del boss a onda specifica

## Riferimenti

- [Capitolo 10 — Collisioni](10-collisioni-software.md) — rilevare colpi sul boss
- [Capitolo 12 — Wave system](12-wave-system-e-ai-nemici.md) — gestione ondate pre-boss
- [Capitolo 16 — Sprite multiplexing](16-sprite-multiplexing.md) — sprite extra per il boss
- [Soluzioni](../soluzioni/cap18-boss.asm) — soluzioni degli esercizi
