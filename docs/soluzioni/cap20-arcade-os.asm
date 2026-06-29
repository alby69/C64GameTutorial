; =============================================
; SOLUZIONI Capitolo 20 — Arcade OS e Oltre
; =============================================
;
; NOTA: Gli esercizi di questo capitolo sono
; concettuali. Le soluzioni qui sotto sono
; dimostrazioni pratiche in assembly dei
; concetti discussi.
;
; Mappa esercizi:
;   1: interrupt chaining (catena IRQ a 3 stadi)
;   2: sprite virtualization (32 sprite -> 8 HW)
;   3: self-modifying code
;   4: architettura 3-layer (kernel/engine/game)
;   5: scheletro gioco completo (checklist)
;
; =============================================

; --- ESERCIZIO 1: interrupt chaining ---
;
; Catena di 3 IRQ che si passano il controllo:
;   IRQ_CHAIN_0 -> game logic (raster 0-79)
;   IRQ_CHAIN_1 -> sprite zone A (raster 80-149)
;   IRQ_CHAIN_2 -> sprite zone B + audio (raster 150-249)
;
; Ogni handler installa il prossimo prima di uscire.

* = $C000

    ; Setup catena IRQ
    SEI
    LDA #<IRQ_CHAIN_0
    STA $0314
    LDA #>IRQ_CHAIN_0
    STA $0315
    LDA #0
    STA $D012          ; parte da raster 0
    LDA #1
    STA $D01A
    CLI
    JMP MAIN_IDLE

; --- Primo stadio: game logic ---
IRQ_CHAIN_0
    PHA
    JSR GAME_LOGIC

    ; Installa prossimo handler per sprite zone A
    LDA #<IRQ_CHAIN_1
    STA $0314
    LDA #>IRQ_CHAIN_1
    STA $0315
    LDA #80
    STA $D012

    PLA
    LDA $D019
    STA $D019
    JMP $EA31

; --- Secondo stadio: sprite zone A ---
IRQ_CHAIN_1
    PHA
    JSR SPRITE_ZONE_A

    LDA #<IRQ_CHAIN_2
    STA $0314
    LDA #>IRQ_CHAIN_2
    STA $0315
    LDA #150
    STA $D012

    PLA
    LDA $D019
    STA $D019
    JMP $EA31

; --- Terzo stadio: sprite zone B + audio ---
IRQ_CHAIN_2
    PHA
    JSR SPRITE_ZONE_B
    JSR AUDIO_UPDATE

    ; Torna al primo stadio per il prossimo frame
    LDA #<IRQ_CHAIN_0
    STA $0314
    LDA #>IRQ_CHAIN_0
    STA $0315
    LDA #0
    STA $D012

    PLA
    LDA $D019
    STA $D019
    JMP $EA31

MAIN_IDLE
    JMP MAIN_IDLE

; Placeholder per le routine chiamate
GAME_LOGIC
    RTS
SPRITE_ZONE_A
    RTS
SPRITE_ZONE_B
    RTS
AUDIO_UPDATE
    RTS

; =============================================

; --- ESERCIZIO 2: sprite virtualization ---
;
; Pool di 32 sprite virtuali mappati sugli 8
; sprite hardware via multiplexing.
; Il componente Sprite Virtualization Layer
; (parte del kernel) ordina per Y e assegna
; agli slot HW, aggiornando nei raster interrupt.

VSPRITE_X       = $0300
VSPRITE_Y       = $0320
VSPRITE_TYPE    = $0340
VSPRITE_ACTIVE  = $0360
MAX_VSPRITE     = 32

; Mappa gli sprite virtuali sugli 8 slot HW
RESOLVE_VSPRITES
    ; Per ogni frame, seleziona i primi 8 sprite
    ; virtuali attivi (ordinati per Y) e li assegna
    ; agli slot hardware VIC-II ($D000-$D00F)
    LDX #0
    LDY #0
RV_LOOP
    LDA VSPRITE_ACTIVE,X
    BEQ RV_SKIP

    ; Assegna slot HW
    LDA VSPRITE_X,X
    STA $D000,Y
    LDA VSPRITE_Y,X
    STA $D001,Y

    INY
    INY
    CPY #16            ; 8 sprite * 2 registri
    BEQ RV_DONE

RV_SKIP
    INX
    CPX #MAX_VSPRITE
    BNE RV_LOOP

RV_DONE
    ; Aggiorna registro enable ($D015)
    ; (in realta il multiplexing completo richiede
    ;  raster interrupt per riusare gli slot HW)
    RTS

; =============================================

; --- ESERCIZIO 3: self-modifying code ---
;
; Il codice che modifica se stesso a runtime.
; Utile per salti dinamici senza confronti.
; Rischi: difficile da debuggare, non funziona
; su ROM, pericoloso su C64 (codice in RAM).

GAME_STATE = $02   ; 0=menu, 1=play, 2=gameover

SMC_UPDATE
    ; Modifica l'istruzione JMP al volo
    ; in base allo stato di gioco
    LDA GAME_STATE
    ASL
    TAX
    LDA SMC_TABLE,X
    STA SMC_TARGET
    LDA SMC_TABLE+1,X
    STA SMC_TARGET+1

    ; Il JMP punta alla routine giusta
SMC_TARGET
    JMP $0000          ; sovrascritto a runtime
    RTS

SMC_TABLE
    .word MENU_UPDATE
    .word PLAY_UPDATE
    .word GAMEOVER_UPDATE

MENU_UPDATE
    ; Gestione menu
    RTS

PLAY_UPDATE
    ; Gestione partita
    RTS

GAMEOVER_UPDATE
    ; Gestione game over
    RTS

; =============================================

; --- ESERCIZIO 4: architettura 3-layer ---
;
; Kernel (fisso) -> Engine (riutilizzabile) -> Game (specifico)
;
; Flusso chiamata:
;   1. IRQ -> KERNEL_IRQ (kernel layer)
;   2. KERNEL_IRQ -> RUN_SCHEDULER -> ENGINE_INPUT, ENGINE_SPRITES...
;   3. ENGINE_INPUT -> aggiorna JOY_STATE (engine layer)
;   4. ENGINE_SPRITES -> aggiorna sprite HW (engine layer)
;   5. KERNEL_IRQ -> GAME_UPDATE (game layer via jump table)
;   6. GAME_UPDATE -> logica specifica del gioco

; Jump table per il modulo gioco
GAME_INIT_PTR   = $C000
GAME_UPDATE_PTR = $C003
GAME_RENDER_PTR = $C006

; Kernel layer (fisso)
KERNEL_INIT
    SEI
    JSR ENGINE_INIT
    JSR GAME_INIT
    CLI
    RTS

KERNEL_LOOP
    JMP KERNEL_LOOP

KERNEL_IRQ
    PHA
    TXA
    PHA
    TYA
    PHA

    ; Engine layer
    JSR ENGINE_INPUT
    JSR ENGINE_SPRITES
    JSR ENGINE_SOUND

    ; Game layer via jump table
    JSR GAME_UPDATE_PTR

    PLA
    TAY
    PLA
    TAX
    PLA
    LDA $D019
    STA $D019
    JMP $EA31

; Engine layer (riutilizzabile)
ENGINE_INIT
    LDA #0
    STA JOY_STATE
    STA JOY_OLD
    RTS

ENGINE_INPUT
    LDA $DC01
    EOR #$FF
    AND #%00011111
    STA JOY_STATE

    TAX
    EOR JOY_OLD
    AND JOY_STATE
    STA JOY_EDGE
    STX JOY_OLD
    RTS

ENGINE_SPRITES
    ; Gestione sprite multiplexing
    RTS

ENGINE_SOUND
    ; Gestione audio SID
    RTS

JOY_STATE = $10
JOY_OLD   = $11
JOY_EDGE  = $12

; =============================================

; --- ESERCIZIO 5: scheletro gioco completo ---
;
; Applicazione della checklist finale a un
; ipotetico "Space Invaders" minimal:
;   - Genere: shooter fisso
;   - Risoluzione: standard 40x25
;   - Sprite: 2 (player + proiettile)
;   - Audio: SFX base (sparo, esplosione)
;   - Controllo: joystick port 2

MINIMAL_GAME

INIT_GAME
    ; Setup VIC-II
    LDA #$1B
    STA $D011
    LDA #$08          ; schermo nero
    STA $D021

    ; Setup sprite player
    LDA #%00000001
    STA $D015          ; enable sprite 0
    LDA #1
    STA $D027          ; colore bianco
    LDA #160
    STA $D000          ; X centrale
    LDA #200
    STA $D001          ; Y fondo schermo

    ; Setup punteggio
    LDA #0
    STA SCORE
    STA SCORE+1

    ; Setup audio
    LDA #$0F
    STA $D418          ; volume max
    RTS

SCORE = $14
SCORE+1 = $15

MAIN_GAME_LOOP
    JSR READ_JOYSTICK
    JSR UPDATE_PLAYER
    JSR UPDATE_BULLET
    JSR CHECK_COLLISIONS
    JSR UPDATE_SCORE
    JSR RENDER
    JMP MAIN_GAME_LOOP

READ_JOYSTICK
    LDA $DC01
    EOR #$FF
    STA JOY
    RTS

JOY = $16

UPDATE_PLAYER
    LDA JOY
    AND #4             ; sinistra
    BEQ UP_RIGHT
    DEC $D000
UP_RIGHT
    LDA JOY
    AND #8             ; destra
    BEQ UP_FIRE
    INC $D000
UP_FIRE
    LDA JOY
    AND #16            ; fuoco
    BEQ UP_DONE
    JSR FIRE_BULLET
UP_DONE
    RTS

FIRE_BULLET
    LDA BULLET_ACTIVE
    BNE FB_DONE        ; gia attivo
    LDA #1
    STA BULLET_ACTIVE
    LDA $D000
    STA BULLET_X
    LDA $D001
    SEC
    SBC #20
    STA BULLET_Y
    ; Suono sparo
    LDA #$0F
    STA $D406
    LDA #$81
    STA $D404
FB_DONE
    RTS

BULLET_ACTIVE = $17
BULLET_X = $18
BULLET_Y = $19

UPDATE_BULLET
    LDA BULLET_ACTIVE
    BEQ UB_DONE
    DEC BULLET_Y
    LDA BULLET_Y
    CMP #30
    BCS UB_RENDER
    LDA #0
    STA BULLET_ACTIVE
UB_RENDER
    LDA BULLET_X
    STA $D002
    LDA BULLET_Y
    STA $D003
UB_DONE
    RTS

CHECK_COLLISIONS
    ; Controllo collisione sprite 0-1
    LDA $D01E
    AND #%00000011
    CMP #%00000011
    BNE CC_DONE
    ; Collisione! Reset proiettile
    LDA #0
    STA BULLET_ACTIVE
    LDA #1
    STA $D021          ; flash bianco
    JSR EXPLODE_SOUND
CC_DONE
    RTS

UPDATE_SCORE
    LDA $D021
    CMP #1
    BNE US_DONE
    ; Aspetta che il flash finisca
    DEC FLASH_TIMER
    BPL US_DONE
    LDA #0
    STA $D021
    INC SCORE
US_DONE
    RTS

FLASH_TIMER = $1A

EXPLODE_SOUND
    LDA #$FF
    STA $D40E
    LDA #$41
    STA $D404
    LDA #10
    STA FLASH_TIMER
    RTS

RENDER
    ; Mostra punteggio in alto a sinistra
    LDA SCORE
    CLC
    ADC #$30           ; converti in ASCII
    STA $0400
    RTS

; Raster bar di debug per il tempo CPU
DEBUG_RASTER
    LDA $D012
    CMP #100
    BCS DR_END
    INC $D020
DR_END
    RTS
