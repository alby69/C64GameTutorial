// Converted to Kick Assembler syntax
.segmentdef Ex1 [start=$c000]
.segmentdef Ex2 [start=$c000]
.segmentdef Ex3 [start=$c000]
.segmentdef Ex4 [start=$c000]
.segmentdef Ex5 [start=$c000]

// --- Shared Constants ---
.const FIND_EMPTY_SLOT = Ex4.FIND_EMPTY_SLOT
.const KERNEL_IRQ = Ex1.KERNEL_IRQ
.const KERNEL_IRQ5 = Ex5.KERNEL_IRQ5
.const RUN_SCHEDULER = Ex3.RUN_SCHEDULER
.const FRAME_CNT = $02
.const GAME_STATE = $03
.const SCORE = $04
.const PLAYER_LIVES = $06
.const BULLET_ACTIVE = $10
.const READ_INPUT = STUB_RTS
.const UPDATE_LOGIC = STUB_RTS
.const RENDER_SPRITES = STUB_RTS
.const MOVE_PLAYER_X = STUB_RTS
.const UPDATE_AUDIO = STUB_RTS
.const MENU_UPDATE = STUB_RTS
.const PLAYER_UPDATE = STUB_RTS
.const ENEMY_UPDATE = STUB_RTS
.const CHECK_WAVE = STUB_RTS
.const GAMEOVER_UPDATE = STUB_RTS
.const TASK_INPUT = 0
.const TASK_LOGIC = 1
.const TASK_RENDER = 2
.const TASK_COUNT = 3
.const SCHEDULER_PHASE = $60
.const SCHEDULER_FRAME = $61
.const MAX_ENTITIES = 16
.const ENTITY_X = $80     // 16 byte
.const ENTITY_Y = $90
.const ENTITY_TYPE = $A0
.const ENTITY_HP = $B0
.const ENTITY_ACTIVE = $C0
.const ENTITY_FLAGS = $D0

// =============================================
// SOLUZIONI Capitolo 19 — Kernel Engine
// --- METADATA ---
// chapter: 19
// title: Kernel Engine
// difficulty: advanced
// --- END METADATA ---
// =============================================
//
// Mappa esercizi:
//   1: separa in 3 file (kernel, engine, game)
//   2: jump table per INIT, UPDATE, RENDER
//   3: RUN_SCHEDULER con 3 task
//   4: dati entita in array
//   5: ristruttura gioco esistente in 3 strati
//
// =============================================
// Equates per compatibilità standalone


STUB_RTS:

    rts

// --- ESERCIZIO 1: separa in 3 file ---
.segment Ex1
.namespace Ex1 {
    //
    // kernel.asm — interrupt, timing, scheduler
    // engine.asm — entita, pool, collisioni
    // game.asm — logica specifica (player, nemici, boss)
    //
    // Per unire: `INCLUDE "kernel.asm"` etc.
    //
    // kernel.asm:
    // * = $C000
        // Setup IRQ
        sei
        lda #$7F
        sta $DC0D
        lda #<KERNEL_IRQ5
        sta $0314
        lda #>KERNEL_IRQ5
        sta $0315
        lda #200
        sta $D012
        lda $D011
        and #$7F
        sta $D011
        lda #1
        sta $D01A
        cli

        jsr GAME_INIT

    KERNEL_MAIN:

        jmp KERNEL_MAIN

    KERNEL_IRQ:

        pha
        txa
        pha
        tya
        pha

        jsr ENGINE_UPDATE
        jsr GAME_UPDATE

        pla
        tay
        pla
        tax
        pla

        lda $D019
        sta $D019
        jmp $EA31

    // engine.asm
    ENGINE_UPDATE:

        // Gestione entita, collisioni, pool
        rts

    // game.asm
    GAME_INIT:

        rts

    GAME_UPDATE:

        rts

}

// --- ESERCIZIO 2: jump table per INIT, UPDATE, RENDER ---
.segment Ex2
.namespace Ex2 {
    JUMP_TABLE:

    INIT_MOD:

        .word MODULE_INIT
    UPDATE_MOD:

        .word MODULE_UPDATE
    RENDER_MOD:

        .word MODULE_RENDER
    DRAW_MOD:

        .word MODULE_DRAW

    // *=$A000
    MODULE_INIT:

        rts

    MODULE_UPDATE:

        rts

    MODULE_RENDER:

        rts

    MODULE_DRAW:

        rts

    // Chiamata tramite jump table:
    CALL_INIT:

        lda INIT_MOD+1
        pha
        lda INIT_MOD
        pha
        rts

    CALL_UPDATE:

        lda UPDATE_MOD+1
        pha
        lda UPDATE_MOD
        pha
        rts

}

// --- ESERCIZIO 3: RUN_SCHEDULER con 3 task ---
.segment Ex3
.namespace Ex3 {


    // *=$B000
        lda #0
        sta SCHEDULER_PHASE
        sta SCHEDULER_FRAME

    RUN_SCHEDULER:

        lda SCHEDULER_PHASE

        cmp #TASK_INPUT
        bne RS_LOGIC
        jsr READ_INPUT
        lda #TASK_LOGIC
        sta SCHEDULER_PHASE
        rts

    RS_LOGIC:

        cmp #TASK_LOGIC
        bne RS_RENDER
        jsr UPDATE_LOGIC
        lda #TASK_RENDER
        sta SCHEDULER_PHASE
        rts

    RS_RENDER:

        cmp #TASK_RENDER
        bne RS_DONE
        jsr RENDER_SPRITES
        lda #TASK_INPUT
        sta SCHEDULER_PHASE
        inc SCHEDULER_FRAME

    RS_DONE:

        rts

    // Chiamato dal raster interrupt
    KERNEL_IRQ2:

        pha
        txa
        pha
        tya
        pha

        jsr RUN_SCHEDULER

        pla
        tay
        pla
        tax
        pla

        lda $D019
        sta $D019
        jmp $EA31

}

// --- ESERCIZIO 4: dati entita in array ---
.segment Ex4
.namespace Ex4 {

    // Array in Zero Page

    // *=$C000
        ldx #0
    INIT_ENTITIES:

        lda #0
        sta ENTITY_ACTIVE,X
        inx
        cpx #MAX_ENTITIES
        bne INIT_ENTITIES
        rts

    // Trova entita inattiva
    FIND_EMPTY_SLOT:

        ldx #0
    FES_LOOP:

        lda ENTITY_ACTIVE,X
        beq FES_FOUND
        inx
        cpx #MAX_ENTITIES
        bne FES_LOOP
        ldx #$FF       // nessuno slot
    FES_FOUND:

        rts

    // Aggiorna tutte le entita attive
    UPDATE_ENTITIES:

        ldx #0
    UE_LOOP:

        lda ENTITY_ACTIVE,X
        beq UE_SKIP

        // Muovi
        lda ENTITY_TYPE,X
        cmp #0
        beq UE_PLAYER
        cmp #1
        beq UE_ENEMY
        jmp UE_SKIP

    UE_PLAYER:

        jsr MOVE_PLAYER_X
        jmp UE_SKIP

    UE_ENEMY:

        // Movimento nemico
        dec ENTITY_Y,X

    UE_SKIP:

        inx
        cpx #MAX_ENTITIES
        bne UE_LOOP
        rts

}

// --- ESERCIZIO 5: ristruttura gioco esistente in 3 strati ---
.segment Ex5
.namespace Ex5 {
    //
    // LAYER 1 — KERNEL (kernel.asm)
    //   - Raster interrupt
    //   - Scheduler (INPUT → LOGIC → RENDER)
    //   - Frame counter
    //   - Audio engine
    //
    // LAYER 2 — ENGINE (engine.asm)
    //   - Entity system (array X/Y/ACTIVE/TYPE)
    //   - Bullet pool
    //   - Collision detection
    //   - Sprite multiplexing
    //   - Particle/explosion system
    //
    // LAYER 3 — GAME (game.asm)
    //   - Player logic
    //   - Enemy waves
    //   - Boss system
    //   - Score/state machine
    //   - Game-specific rendering
    //
    // Schema flusso (raster IRQ ogni 50 Hz):
    //
    //   ┌─────────────────────────────────┐
    //   │  KERNEL_IRQ                     │
    //   │   ├─ RUN_SCHEDULER              │
    //   │   │   ├─ READ_INPUT (giocatore) │
    //   │   │   ├─ UPDATE_LOGIC (entita)  │
    //   │   │   └─ RENDER_SPRITES (video) │
    //   │   ├─ UPDATE_AUDIO               │
    //   │   └─ FRAME_CNT++                │
    //   └─────────────────────────────────┘
    //
    // Esempio di ristrutturazione:

    // kernel.asm
    // *=$C000
        sei
        lda #$7F
        sta $DC0D
        lda #<KERNEL_IRQ
        sta $0314
        lda #>KERNEL_IRQ
        sta $0315
        lda #200
        sta $D012
        lda $D011
        and #$7F
        sta $D011
        lda #1
        sta $D01A
        cli

        jsr ENGINE_INIT
        jsr GAME_INIT5

    KERNEL_MAIN5:

        jmp KERNEL_MAIN5

    KERNEL_IRQ5:

        pha
        txa
        pha
        tya
        pha

        inc FRAME_CNT

        jsr RUN_SCHEDULER
        jsr UPDATE_AUDIO

        pla
        tay
        pla
        tax
        pla

        lda $D019
        sta $D019
        jmp $EA31

    // engine.asm
    ENGINE_INIT:

        // Azzera pool, entita, etc.
        lda #0
        ldx #0
    EI_LOOP:

        sta ENTITY_ACTIVE,X
        sta BULLET_ACTIVE,X
        inx
        cpx #MAX_ENTITIES
        bne EI_LOOP
        rts

    ENGINE_SPAWN:

        // A = tipo
        jsr FIND_EMPTY_SLOT
        txa
        bmi ES_FAIL
        // Inizializza slot X con tipo A
        rts
    ES_FAIL:

        rts

    ENGINE_COLLISION:

        // Controlla collisioni tra player e nemici
        rts

    // game.asm
    GAME_INIT5:

        lda #0
        sta GAME_STATE
        sta SCORE
        lda #3
        sta PLAYER_LIVES
        rts

    GAME_UPDATE5:

        lda GAME_STATE
        cmp #0
        beq GM_MENU
        cmp #1
        beq GM_PLAY
        jmp GM_GAMEOVER

    GM_MENU:

        jsr MENU_UPDATE
        rts

    GM_PLAY:

        jsr PLAYER_UPDATE
        jsr ENEMY_UPDATE
        jsr ENGINE_COLLISION
        jsr CHECK_WAVE
        rts

    GM_GAMEOVER:

        jsr GAMEOVER_UPDATE
        rts
}
