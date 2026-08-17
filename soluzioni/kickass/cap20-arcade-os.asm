// Converted to Kick Assembler syntax
.segmentdef Ex1 [start=$c000]
.segmentdef Ex2 [start=$c000]
.segmentdef Ex3 [start=$c000]
.segmentdef Ex4 [start=$c000]
.segmentdef Ex5 [start=$c000]

// --- Shared Constants ---
.const GAME_INIT = Ex5.GAME_INIT
.const VSPRITE_X = $0300
.const VSPRITE_Y = $0320
.const VSPRITE_TYPE = $0340
.const VSPRITE_ACTIVE = $0360
.const MAX_VSPRITE = 32
.const GAME_STATE = $02
.const GAME_INIT_PTR = $C000
.const GAME_UPDATE_PTR = $C003
.const GAME_RENDER_PTR = $C006
.const JOY_STATE = $10
.const JOY_OLD = $11
.const JOY_EDGE = $12
.const SCORE = $14
.const JOY = $16
.const BULLET_ACTIVE = $17
.const BULLET_X = $18
.const BULLET_Y = $19
.const FLASH_TIMER = $1A

// =============================================
// SOLUZIONI Capitolo 20 — Arcade OS e Oltre
// --- METADATA ---
// chapter: 20
// title: Arcade OS
// difficulty: master
// --- END METADATA ---
// =============================================

//
// NOTA: Gli esercizi di questo capitolo sono
// concettuali. Le soluzioni qui sotto sono
// dimostrazioni pratiche in assembly dei
// concetti discussi.
//
// Mappa esercizi:
//   1: interrupt chaining (catena IRQ a 3 stadi)
//   2: sprite virtualization (32 sprite -> 8 HW)
//   3: self-modifying code
//   4: architettura 3-layer (kernel/engine/game)
//   5: scheletro gioco completo (checklist)
//
// =============================================

// --- ESERCIZIO 1: interrupt chaining ---
.segment Ex1
.namespace Ex1 {
    //
    // Catena di 3 IRQ che si passano il controllo:
    //   IRQ_CHAIN_0 -> game logic (raster 0-79)
    //   IRQ_CHAIN_1 -> sprite zone A (raster 80-149)
    //   IRQ_CHAIN_2 -> sprite zone B + audio (raster 150-249)
    //
    // Ogni handler installa il prossimo prima di uscire.

    // * = $C000

        // Setup catena IRQ
        sei
        lda #<IRQ_CHAIN_0
        sta $0314
        lda #>IRQ_CHAIN_0
        sta $0315
        lda #0
        sta $D012          // parte da raster 0
        lda #1
        sta $D01A
        cli
        jmp MAIN_IDLE

    // --- Primo stadio: game logic ---
    IRQ_CHAIN_0:

        pha
        jsr GAME_LOGIC

        // Installa prossimo handler per sprite zone A
        lda #<IRQ_CHAIN_1
        sta $0314
        lda #>IRQ_CHAIN_1
        sta $0315
        lda #80
        sta $D012

        pla
        lda $D019
        sta $D019
        jmp $EA31

    // --- Secondo stadio: sprite zone A ---
    IRQ_CHAIN_1:

        pha
        jsr SPRITE_ZONE_A

        lda #<IRQ_CHAIN_2
        sta $0314
        lda #>IRQ_CHAIN_2
        sta $0315
        lda #150
        sta $D012

        pla
        lda $D019
        sta $D019
        jmp $EA31

    // --- Terzo stadio: sprite zone B + audio ---
    IRQ_CHAIN_2:

        pha
        jsr SPRITE_ZONE_B
        jsr AUDIO_UPDATE

        // Torna al primo stadio per il prossimo frame
        lda #<IRQ_CHAIN_0
        sta $0314
        lda #>IRQ_CHAIN_0
        sta $0315
        lda #0
        sta $D012

        pla
        lda $D019
        sta $D019
        jmp $EA31

    MAIN_IDLE:

        jmp MAIN_IDLE

    // Placeholder per le routine chiamate
    GAME_LOGIC:

        rts
    SPRITE_ZONE_A:

        rts
    SPRITE_ZONE_B:

        rts
    AUDIO_UPDATE:

        rts

    // =============================================

}

// --- ESERCIZIO 2: sprite virtualization ---
.segment Ex2
.namespace Ex2 {
    //
    // Pool di 32 sprite virtuali mappati sugli 8
    // sprite hardware via multiplexing.
    // Il componente Sprite Virtualization Layer
    // (parte del kernel) ordina per Y e assegna
    // agli slot HW, aggiornando nei raster interrupt.


    // Mappa gli sprite virtuali sugli 8 slot HW
    RESOLVE_VSPRITES:

        // Per ogni frame, seleziona i primi 8 sprite
        // virtuali attivi (ordinati per Y) e li assegna
        // agli slot hardware VIC-II ($D000-$D00F)
        ldx #0
        ldy #0
    RV_LOOP:

        lda VSPRITE_ACTIVE,X
        beq RV_SKIP

        // Assegna slot HW
        lda VSPRITE_X,X
        sta $D000,Y
        lda VSPRITE_Y,X
        sta $D001,Y

        iny
        iny
        cpy #16            // 8 sprite * 2 registri
        beq RV_DONE

    RV_SKIP:

        inx
        cpx #MAX_VSPRITE
        bne RV_LOOP

    RV_DONE:

        // Aggiorna registro enable ($D015)
        // (in realta il multiplexing completo richiede
        //  raster interrupt per riusare gli slot HW)
        rts

    // =============================================

}

// --- ESERCIZIO 3: self-modifying code ---
.segment Ex3
.namespace Ex3 {
    //
    // Il codice che modifica se stesso a runtime.
    // Utile per salti dinamici senza confronti.
    // Rischi: difficile da debuggare, non funziona
    // su ROM, pericoloso su C64 (codice in RAM).


    SMC_UPDATE:

        // Modifica l'istruzione JMP al volo
        // in base allo stato di gioco
        lda GAME_STATE
        asl
        tax
        lda SMC_TABLE,X
        sta SMC_TARGET
        lda SMC_TABLE+1,X
        sta SMC_TARGET+1

        // Il JMP punta alla routine giusta
    SMC_TARGET:

        jmp $0000          // sovrascritto a runtime
        rts

    SMC_TABLE:

        .word MENU_UPDATE
        .word PLAY_UPDATE
        .word GAMEOVER_UPDATE

    MENU_UPDATE:

        // Gestione menu
        rts

    PLAY_UPDATE:

        // Gestione partita
        rts

    GAMEOVER_UPDATE:

        // Gestione game over
        rts

    // =============================================

}

// --- ESERCIZIO 4: architettura 3-layer ---
.segment Ex4
.namespace Ex4 {
    //
    // Kernel (fisso) -> Engine (riutilizzabile) -> Game (specifico)
    //
    // Flusso chiamata:
    //   1. IRQ -> KERNEL_IRQ (kernel layer)
    //   2. KERNEL_IRQ -> RUN_SCHEDULER -> ENGINE_INPUT, ENGINE_SPRITES...
    //   3. ENGINE_INPUT -> aggiorna JOY_STATE (engine layer)
    //   4. ENGINE_SPRITES -> aggiorna sprite HW (engine layer)
    //   5. KERNEL_IRQ -> GAME_UPDATE (game layer via jump table)
    //   6. GAME_UPDATE -> logica specifica del gioco

    // Jump table per il modulo gioco

    // Kernel layer (fisso)
    KERNEL_INIT:

        sei
        jsr ENGINE_INIT
        jsr GAME_INIT
        cli
        rts

    KERNEL_LOOP:

        jmp KERNEL_LOOP

    KERNEL_IRQ:

        pha
        txa
        pha
        tya
        pha

        // Engine layer
        jsr ENGINE_INPUT
        jsr ENGINE_SPRITES
        jsr ENGINE_SOUND

        // Game layer via jump table
        jsr GAME_UPDATE_PTR

        pla
        tay
        pla
        tax
        pla
        lda $D019
        sta $D019
        jmp $EA31

    // Engine layer (riutilizzabile)
    ENGINE_INIT:

        lda #0
        sta JOY_STATE
        sta JOY_OLD
        rts

    ENGINE_INPUT:

        lda $DC01
        eor #$FF
        and #%00011111
        sta JOY_STATE

        tax
        eor JOY_OLD
        and JOY_STATE
        sta JOY_EDGE
        stx JOY_OLD
        rts

    ENGINE_SPRITES:

        // Gestione sprite multiplexing
        rts

    ENGINE_SOUND:

        // Gestione audio SID
        rts


    // =============================================

}

// --- ESERCIZIO 5: scheletro gioco completo ---
.segment Ex5
.namespace Ex5 {
    //
    // Applicazione della checklist finale a un
    // ipotetico "Space Invaders" minimal:
    //   - Genere: shooter fisso
    //   - Risoluzione: standard 40x25
    //   - Sprite: 2 (player + proiettile)
    //   - Audio: SFX base (sparo, esplosione)
    //   - Controllo: joystick port 2

    MINIMAL_GAME:


    INIT_GAME:

        // Setup VIC-II
        lda #$1B
        sta $D011
        lda #$08          // schermo nero
        sta $D021

        // Setup sprite player
        lda #%00000001
        sta $D015          // enable sprite 0
        lda #1
        sta $D027          // colore bianco
        lda #160
        sta $D000          // X centrale
        lda #200
        sta $D001          // Y fondo schermo

        // Setup punteggio
        lda #0
        sta SCORE
        sta SCORE+1

        // Setup audio
        lda #$0F
        sta $D418          // volume max
        rts


    MAIN_GAME_LOOP:

        jsr READ_JOYSTICK
        jsr UPDATE_PLAYER
        jsr UPDATE_BULLET
        jsr CHECK_COLLISIONS
        jsr UPDATE_SCORE
        jsr RENDER
        jmp MAIN_GAME_LOOP

    READ_JOYSTICK:

        lda $DC01
        eor #$FF
        sta JOY
        rts


    UPDATE_PLAYER:

        lda JOY
        and #4             // sinistra
        beq UP_RIGHT
        dec $D000
    UP_RIGHT:

        lda JOY
        and #8             // destra
        beq UP_FIRE
        inc $D000
    UP_FIRE:

        lda JOY
        and #16            // fuoco
        beq UP_DONE
        jsr FIRE_BULLET
    UP_DONE:

        rts

    FIRE_BULLET:

        lda BULLET_ACTIVE
        bne FB_DONE        // gia attivo
        lda #1
        sta BULLET_ACTIVE
        lda $D000
        sta BULLET_X
        lda $D001
        sec
        sbc #20
        sta BULLET_Y
        // Suono sparo
        lda #$0F
        sta $D406
        lda #$81
        sta $D404
    FB_DONE:

        rts


    UPDATE_BULLET:

        lda BULLET_ACTIVE
        beq UB_DONE
        dec BULLET_Y
        lda BULLET_Y
        cmp #30
        bcs UB_RENDER
        lda #0
        sta BULLET_ACTIVE
    UB_RENDER:

        lda BULLET_X
        sta $D002
        lda BULLET_Y
        sta $D003
    UB_DONE:

        rts

    CHECK_COLLISIONS:

        // Controllo collisione sprite 0-1
        lda $D01E
        and #%00000011
        cmp #%00000011
        bne CC_DONE
        // Collisione! Reset proiettile
        lda #0
        sta BULLET_ACTIVE
        lda #1
        sta $D021          // flash bianco
        jsr EXPLODE_SOUND
    CC_DONE:

        rts

    UPDATE_SCORE:

        lda $D021
        cmp #1
        bne US_DONE
        // Aspetta che il flash finisca
        dec FLASH_TIMER
        bpl US_DONE
        lda #0
        sta $D021
        inc SCORE
    US_DONE:

        rts


    EXPLODE_SOUND:

        lda #$FF
        sta $D40E
        lda #$41
        sta $D404
        lda #10
        sta FLASH_TIMER
        rts

    RENDER:

        // Mostra punteggio in alto a sinistra
        lda SCORE
        clc
        adc #$30           // converti in ASCII
        sta $0400
        rts

    // Raster bar di debug per il tempo CPU
    DEBUG_RASTER:

        lda $D012
        cmp #100
        bcs DR_END
        inc $D020
    DR_END:

        rts

    GAME_INIT:

        rts
}
