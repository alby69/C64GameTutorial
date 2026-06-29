; =============================================
; SOLUZIONI Capitolo 19 — Kernel Engine
; =============================================

; --- ESERCIZIO 1: separa in 3 file ---
;
; kernel.asm — interrupt, timing, scheduler
; engine.asm — entita, pool, collisioni
; game.asm — logica specifica (player, nemici, boss)
;
; Per unire: `INCLUDE "kernel.asm"` etc.
;
; kernel.asm:
* = $C000
    ; Setup IRQ
    SEI
    LDA #$7F
    STA $DC0D
    LDA #<KERNEL_IRQ
    STA $0314
    LDA #>KERNEL_IRQ
    STA $0315
    LDA #200
    STA $D012
    LDA $D011
    AND #$7F
    STA $D011
    LDA #1
    STA $D01A
    CLI

    JSR GAME_INIT

KERNEL_MAIN
    JMP KERNEL_MAIN

KERNEL_IRQ
    PHA
    TXA
    PHA
    TYA
    PHA

    JSR ENGINE_UPDATE
    JSR GAME_UPDATE

    PLA
    TAY
    PLA
    TAX
    PLA

    LDA $D019
    STA $D019
    JMP $EA31

; engine.asm
ENGINE_UPDATE
    ; Gestione entita, collisioni, pool
    RTS

; game.asm
GAME_INIT
    RTS

GAME_UPDATE
    RTS

; --- ESERCIZIO 2: jump table per INIT, UPDATE, RENDER ---
JUMP_TABLE
INIT_MOD
    .word MODULE_INIT
UPDATE_MOD
    .word MODULE_UPDATE
RENDER_MOD
    .word MODULE_RENDER
DRAW_MOD
    .word MODULE_DRAW

*=$A000
MODULE_INIT
    RTS

MODULE_UPDATE
    RTS

MODULE_RENDER
    RTS

MODULE_DRAW
    RTS

; Chiamata tramite jump table:
CALL_INIT
    LDA INIT_MOD+1
    PHA
    LDA INIT_MOD
    PHA
    RTS

CALL_UPDATE
    LDA UPDATE_MOD+1
    PHA
    LDA UPDATE_MOD
    PHA
    RTS

; --- ESERCIZIO 3: RUN_SCHEDULER con 3 task ---
TASK_INPUT  = 0
TASK_LOGIC  = 1
TASK_RENDER = 2
TASK_COUNT  = 3

SCHEDULER_PHASE = $60
SCHEDULER_FRAME = $61

*=$B000
    LDA #0
    STA SCHEDULER_PHASE
    STA SCHEDULER_FRAME

RUN_SCHEDULER
    LDA SCHEDULER_PHASE

    CMP #TASK_INPUT
    BNE RS_LOGIC
    JSR READ_INPUT
    LDA #TASK_LOGIC
    STA SCHEDULER_PHASE
    RTS

RS_LOGIC
    CMP #TASK_LOGIC
    BNE RS_RENDER
    JSR UPDATE_LOGIC
    LDA #TASK_RENDER
    STA SCHEDULER_PHASE
    RTS

RS_RENDER
    CMP #TASK_RENDER
    BNE RS_DONE
    JSR RENDER_SPRITES
    LDA #TASK_INPUT
    STA SCHEDULER_PHASE
    INC SCHEDULER_FRAME

RS_DONE
    RTS

; Chiamato dal raster interrupt
KERNEL_IRQ2
    PHA
    TXA
    PHA
    TYA
    PHA

    JSR RUN_SCHEDULER

    PLA
    TAY
    PLA
    TAX
    PLA

    LDA $D019
    STA $D019
    JMP $EA31

; --- ESERCIZIO 4: dati entita in array ---
MAX_ENTITIES = 16

; Array in Zero Page
ENTITY_X     = $80     ; 16 byte
ENTITY_Y     = $90
ENTITY_TYPE  = $A0
ENTITY_HP    = $B0
ENTITY_ACTIVE = $C0
ENTITY_FLAGS = $D0

*=$C000
    LDX #0
INIT_ENTITIES
    LDA #0
    STA ENTITY_ACTIVE,X
    INX
    CPX #MAX_ENTITIES
    BNE INIT_ENTITIES
    RTS

; Trova entita inattiva
FIND_EMPTY_SLOT
    LDX #0
FES_LOOP
    LDA ENTITY_ACTIVE,X
    BEQ FES_FOUND
    INX
    CPX #MAX_ENTITIES
    BNE FES_LOOP
    LDX #$FF       ; nessuno slot
FES_FOUND
    RTS

; Aggiorna tutte le entita attive
UPDATE_ENTITIES
    LDX #0
UE_LOOP
    LDA ENTITY_ACTIVE,X
    BEQ UE_SKIP

    ; Muovi
    LDA ENTITY_TYPE,X
    CMP #0
    BEQ UE_PLAYER
    CMP #1
    BEQ UE_ENEMY
    JMP UE_SKIP

UE_PLAYER
    JSR MOVE_PLAYER_X
    JMP UE_SKIP

UE_ENEMY
    ; Movimento nemico
    DEC ENTITY_Y,X

UE_SKIP
    INX
    CPX #MAX_ENTITIES
    BNE UE_LOOP
    RTS

; --- ESERCIZIO 5: ristruttura gioco esistente in 3 strati ---
;
; LAYER 1 — KERNEL (kernel.asm)
;   - Raster interrupt
;   - Scheduler (INPUT → LOGIC → RENDER)
;   - Frame counter
;   - Audio engine
;
; LAYER 2 — ENGINE (engine.asm)
;   - Entity system (array X/Y/ACTIVE/TYPE)
;   - Bullet pool
;   - Collision detection
;   - Sprite multiplexing
;   - Particle/explosion system
;
; LAYER 3 — GAME (game.asm)
;   - Player logic
;   - Enemy waves
;   - Boss system
;   - Score/state machine
;   - Game-specific rendering
;
; Schema flusso (raster IRQ ogni 50 Hz):
;
;   ┌─────────────────────────────────┐
;   │  KERNEL_IRQ                     │
;   │   ├─ RUN_SCHEDULER              │
;   │   │   ├─ READ_INPUT (giocatore) │
;   │   │   ├─ UPDATE_LOGIC (entita)  │
;   │   │   └─ RENDER_SPRITES (video) │
;   │   ├─ UPDATE_AUDIO               │
;   │   └─ FRAME_CNT++                │
;   └─────────────────────────────────┘
;
; Esempio di ristrutturazione:

; kernel.asm
*=$C000
    SEI
    LDA #$7F
    STA $DC0D
    LDA #<KERNEL_IRQ
    STA $0314
    LDA #>KERNEL_IRQ
    STA $0315
    LDA #200
    STA $D012
    LDA $D011
    AND #$7F
    STA $D011
    LDA #1
    STA $D01A
    CLI

    JSR ENGINE_INIT
    JSR GAME_INIT

KERNEL_MAIN
    JMP KERNEL_MAIN

KERNEL_IRQ
    PHA
    TXA
    PHA
    TYA
    PHA

    INC FRAME_CNT

    JSR RUN_SCHEDULER
    JSR UPDATE_AUDIO

    PLA
    TAY
    PLA
    TAX
    PLA

    LDA $D019
    STA $D019
    JMP $EA31

; engine.asm
ENGINE_INIT
    ; Azzera pool, entita, etc.
    LDA #0
    LDX #0
EI_LOOP
    STA ENTITY_ACTIVE,X
    STA BULLET_ACTIVE,X
    INX
    CPX #MAX_ENTITIES
    BNE EI_LOOP
    RTS

ENGINE_SPAWN
    ; A = tipo
    JSR FIND_EMPTY_SLOT
    TXA
    BMI ES_FAIL
    ; Inizializza slot X con tipo A
    RTS
ES_FAIL
    RTS

ENGINE_COLLISION
    ; Controlla collisioni tra player e nemici
    RTS

; game.asm
GAME_INIT
    LDA #0
    STA GAME_STATE
    STA SCORE
    LDA #3
    STA PLAYER_LIVES
    RTS

GAME_UPDATE
    LDA GAME_STATE
    CMP #0
    BEQ GM_MENU
    CMP #1
    BEQ GM_PLAY
    JMP GM_GAMEOVER

GM_MENU
    JSR MENU_UPDATE
    RTS

GM_PLAY
    JSR PLAYER_UPDATE
    JSR ENEMY_UPDATE
    JSR ENGINE_COLLISION
    JSR CHECK_WAVE
    RTS

GM_GAMEOVER
    JSR GAMEOVER_UPDATE
    RTS
