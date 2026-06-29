# Capitolo 19 — Kernel Engine Riutilizzabile

## Obiettivi

Al termine di questo capitolo saprai:

- Progettare un kernel engine separato dalla logica
- Usare una struttura a 3 strati
- Organizzare la memoria in modo professionale
- Creare un sistema di aggiornamento entita
- Gestire il ciclo di vita del gioco

---

## 19.1 Perche un Kernel Engine?

Finora abbiamo scritto codice "monolitico": tutto insieme. Per giochi piu complessi serve separare:

```
┌─────────────────────────────────────┐
│ MODULO GIOCO (logica specifica)     │
│ - regole del gioco                  │
│ - AI nemici                         │
│ - punteggio                         │
├─────────────────────────────────────┤
│ SERVIZI ENGINE (riutilizzabili)      │
│ - sprite system                     │
│ - collisioni                        │
│ - input                             │
│ - audio                             │
├─────────────────────────────────────┤
│ KERNEL CORE (fisso)                 │
│ - raster sync                       │
│ - frame control                     │
│ - interrupt handler                 │
└─────────────────────────────────────┘
```

Vantaggi:

- Scrivi una volta, usi per tutti i giochi
- Meno bug (codice testato)
- Separazione dei compiti
- Piu facile mantenere

---

## 19.2 Struttura a 3 strati

### Kernel Core (fisso, non cambia mai)

```asm
; kernel.asm
*=$0800

KERNEL_INIT
    SEI
    JSR SETUP_IRQ
    JSR SETUP_VIC
    CLI
    RTS

KERNEL_MAIN
    JMP KERNEL_MAIN      ; tutto gira nell'IRQ

KERNEL_IRQ
    PHA
    TXA
    PHA
    TYA
    PHA

    INC FRAME_COUNTER

    JSR ENGINE_INPUT
    JSR ENGINE_SPRITES
    JSR ENGINE_SOUND

    JSR GAME_UPDATE       ; chiama il modulo gioco!

    PLA
    TAY
    PLA
    TAX
    PLA
    LDA $D019
    STA $D019
    JMP $EA31

FRAME_COUNTER = $02
```

### Servizi Engine (riutilizzabili)

```asm
; engine_input.asm
ENGINE_INPUT
    LDA $DC01
    EOR #$FF
    AND #%00011111
    STA JOY_STATE

    ; Edge detection
    TAX
    EOR JOY_OLD
    AND JOY_STATE
    STA JOY_EDGE
    STX JOY_OLD
    RTS

JOY_STATE = $10
JOY_OLD   = $11
JOY_EDGE  = $12
```

```asm
; engine_sprites.asm
ENGINE_SPRITES
    ; ... update multiplexing ...
    ; ... colori ...
    ; ... pointer ...
    RTS
```

### Modulo Gioco (specifico)

```asm
; game_logic.asm
GAME_UPDATE
    JSR GAME_READ_INPUT
    JSR GAME_UPDATE_PLAYER
    JSR GAME_UPDATE_ENEMIES
    JSR GAME_CHECK_COLLISIONS
    JSR GAME_RENDER
    RTS
```

---

## 19.3 Jump Table per il modulo gioco

Il kernel chiama il modulo tramite una tabella di puntatori:

```asm
; Il modulo gioco definisce queste label:
GAME_INIT     = $C000
GAME_UPDATE   = $C003
GAME_RENDER   = $C006
GAME_RESET    = $C009

; Il kernel salta attraverso la tabella
KERNEL_CALL_GAME
    JSR (GAME_PTR)       ; salta alla routine corrente
    RTS

GAME_PTR = $20   ; puntatore a 2 byte
```

---

## 19.4 Organizzazione della memoria

Layout professionale per un gioco C64:

```
$0002-$00FF   Variabili Zero Page (veloci)
$0100-$01FF   Stack
$0200-$03FF   Variabili engine + stato gioco
$0400-$07E7   Screen RAM (video)
$0800-$1FFF   Kernel engine (fisso)
$2000-$3FFF   Dati sprite e animazioni
$4000-$7FFF   Modulo gioco (logica)
$8000-$9FFF   Dati livelli, tabelle
$C000-$CFFF   Jump table + dispatcher
$D000-$DFFF   VIC-II / SID / CIA (hardware)
```

### Definizione delle zone

```asm
; kernel.asm — header con definizioni

; ---- Zero Page ----
FRAME_CNT  = $02
JOY_STATE  = $03
GAME_STATE = $04
PLAYER_X   = $05
PLAYER_Y   = $06
SCORE_LO   = $07
SCORE_HI   = $08
TEMP       = $09

; ---- Variabili estese ($0200+) ----
ENEMY_X    = $0200
ENEMY_Y    = $0210
ENEMY_ALIVE = $0220
BULLET_X   = $0230
BULLET_Y   = $0240
BULLET_ACTIVE = $0250

; ---- Dati sprite ----
SPRITE_PTR_BASE = $2000
SPRITE_DATA_0   = $2000   ; frame 0
SPRITE_DATA_1   = $2040   ; frame 1
SPRITE_DATA_2   = $2080   ; frame 2
```

---

## 19.5 Entity System semplice

Una entita ha dati raggruppati per "componente":

```asm
; Entity 0: player
; Entity 1-8: nemici
; Entity 9-12: proiettili

ENTITY_X       = $40     ; 16 byte (X di ogni entita)
ENTITY_Y       = $50     ; 16 byte
ENTITY_TYPE    = $60     ; 16 byte (0=player,1=bullet,2=enemy)
ENTITY_ACTIVE  = $70     ; 16 byte
ENTITY_SPRITE  = $80     ; 16 byte (frame sprite)
ENTITY_HP      = $90     ; 16 byte

MAX_ENTITIES = 16

; Inizializzazione entita
INIT_ENTITIES
    LDX #0
    LDA #0
IE_LOOP
    STA ENTITY_ACTIVE,X
    INX
    CPX #MAX_ENTITIES
    BNE IE_LOOP

    ; Entity 0 = player
    LDA #1
    STA ENTITY_ACTIVE
    LDA #0
    STA ENTITY_TYPE
    LDA #160
    STA ENTITY_X
    LDA #180
    STA ENTITY_Y
    RTS
```

---

## 19.6 Update di tutte le entita

```asm
UPDATE_ALL_ENTITIES
    LDX #0
UAE_LOOP
    LDA ENTITY_ACTIVE,X
    BEQ UAE_NEXT

    LDA ENTITY_TYPE,X
    CMP #0
    BEQ UAE_PLAYER
    CMP #1
    BEQ UAE_BULLET
    CMP #2
    BEQ UAE_ENEMY

UAE_PLAYER
    JSR UPDATE_PLAYER_ENTITY
    JMP UAE_NEXT

UAE_BULLET
    JSR UPDATE_BULLET_ENTITY
    JMP UAE_NEXT

UAE_ENEMY
    JSR UPDATE_ENEMY_ENTITY

UAE_NEXT
    INX
    CPX #MAX_ENTITIES
    BNE UAE_LOOP
    RTS
```

### Movimento entita player

```asm
UPDATE_PLAYER_ENTITY
    ; Usa JOY_STATE per muovere l'entita 0
    LDA JOY_STATE
    AND #%00000001          ; SU
    BEQ UPE_DOWN
    DEC ENTITY_Y
UPE_DOWN
    LDA JOY_STATE
    AND #%00000010
    BEQ UPE_LEFT
    INC ENTITY_Y
UPE_LEFT
    LDA JOY_STATE
    AND #%00000100
    BEQ UPE_RIGHT
    DEC ENTITY_X
UPE_RIGHT
    LDA JOY_STATE
    AND #%00001000
    BEQ UPE_DONE
    INC ENTITY_X
UPE_DONE
    RTS
```

---

## 19.7 Scheduler cooperativo

Per gestire piu compiti senza sovrapposizioni:

```asm
; Tabella dei task eseguiti ogni frame
TASK_TABLE
    .word TASK_INPUT       ; task 0
    .word TASK_PHYSICS     ; task 1
    .word TASK_AI          ; task 2
    .word TASK_RENDER      ; task 3
    .word TASK_AUDIO       ; task 4

NUM_TASKS = 5

RUN_SCHEDULER
    LDX #0
RS_LOOP
    LDA TASK_TABLE,X       ; low byte puntatore
    STA TEMP
    LDA TASK_TABLE+1,X     ; high byte
    STA TEMP+1

    JSR CALL_TASK          ; JMP (TEMP)

    INX
    INX
    CPX #NUM_TASKS*2
    BNE RS_LOOP
    RTS

CALL_TASK
    JMP (TEMP)

TEMP = $20    ; 2 byte
```

---

## 19.8 Flusso completo del kernel

```asm
; kernel.asm — completo

*=$0800

; ---- INIZIALIZZAZIONE ----
START
    SEI
    JSR KERNEL_SETUP
    JSR ENGINE_INIT
    JSR GAME_INIT          ; chiama il modulo gioco
    CLI

    JMP MAIN_LOOP

KERNEL_SETUP
    LDA #$7F
    STA $DC0D
    LDA #<KERNEL_IRQ
    STA $0314
    LDA #>KERNEL_IRQ
    STA $0315
    LDA #250
    STA $D012
    LDA $D011
    AND #$7F
    STA $D011
    LDA #1
    STA $D01A
    RTS

MAIN_LOOP
    JMP MAIN_LOOP

; ---- IRQ PRINCIPALE ----
KERNEL_IRQ
    PHA
    TXA
    PHA
    TYA
    PHA

    INC FRAME_CNT
    JSR RUN_SCHEDULER

    PLA
    TAY
    PLA
    TAX
    PLA
    LDA $D019
    STA $D019
    JMP $EA31

; ---- ENGINE SERVICES ----
ENGINE_INIT
    JSR ENGINE_INPUT_INIT
    JSR ENGINE_SPRITE_INIT
    JSR ENGINE_AUDIO_INIT
    RTS

ENGINE_INPUT_INIT
    LDA #0
    STA JOY_STATE
    STA JOY_OLD
    RTS

ENGINE_SPRITE_INIT
    LDA #%00000001
    STA $D015
    LDA #1
    STA $D027
    RTS

ENGINE_AUDIO_INIT
    LDA #$0F
    STA $D418
    RTS
```

---

## Esercizi

### Esercizio 1
Separa il tuo progetto in 3 file: `kernel.asm`, `engine.asm`, `game.asm`.

### Esercizio 2
Crea una jump table per INIT, UPDATE, RENDER del modulo gioco.

### Esercizio 3
Implementa RUN_SCHEDULER con 3 task: INPUT, LOGIC, RENDER.

### Esercizio 4
Organizza tutti i dati delle entita in array (ENTITY_X, ENTITY_Y, ENTITY_ACTIVE).

### Esercizio 5
Ristruttura il tuo gioco precedente per usare l'architettura a 3 strati.

---

## Riepilogo

Hai imparato:

- Architettura a 3 strati (Kernel, Engine, Game)
- Jump table per chiamare moduli
- Organizzazione professionale della memoria
- Entity system con array di componenti
- Scheduler cooperativo per task
- Inizializzazione separata per ogni strato
- Separazione tra logica di gioco e servizi engine

## Riferimenti

- [Capitolo 8 — Game loop](08-game-loop-sincronizzato.md) — struttura base che il kernel sostituisce
- [Capitolo 16 — Sprite multiplexing](16-sprite-multiplexing.md) — componente del layer Engine
- [Capitolo 20 — Arcade OS](20-arcade-os-e-oltre.md) — evoluzione del kernel
- [Soluzioni](../soluzioni/cap19-kernel-engine.asm) — soluzioni degli esercizi
