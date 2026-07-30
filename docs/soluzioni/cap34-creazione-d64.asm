; ─────────────────────────────────────────────────────
; Soluzioni esercizi Capitolo 34 — Creazione Immagini Disco .D64
; --- METADATA ---
; chapter: 34
; title: Creazione Immagini Disco D64
; difficulty: advanced
; --- END METADATA ---
; ─────────────────────────────────────────────────────
;
; Esempio pratico: struttura di un gioco multi-file
; che viene caricato da un disco D64.
;
; Il disco contiene:
;   BOOT.PRG   — loader (carica gli altri file)
;   GAME.PRG   — codice gioco
;   SPRITES.PRG — dati sprite
;   MUSIC.PRG  — player musicale
;   HIGH.SEQ   — highscore predefinito
;
; Per assemblare con TMPx:
;   tmpx -o boot.prg boot.asm
;   tmpx -o game.prg game.asm
;   tmpx -o sprites.prg sprites.asm
;   tmpx -o music.prg music.asm
;
; Poi creare il disco:
;   python tools/create_d64.py -o game.d64 \
;       --name "SPACE WARS" \
;       --type PRG,PRG,PRG,PRG,SEQ \
;       boot.prg game.prg sprites.prg music.prg high.seq
;
; ─────────────────────────────────────────────────────

; =============================================
; BOOT.PRG — Loader principale
; Carica gli altri file dal disco
; =============================================

* = $0801

    ; Righe BASIC: SYS 2064
    .byte $0C, $08      ; puntatore prossima riga
    .byte $0A, $00      ; numero riga 10
    .byte $9E           ; SYS
    .text " 2064"       ; indirizzo
    .byte $00           ; fine riga
    .byte $00, $00      ; fine BASIC

; --- Punto di ingresso: $0810 (2064) ---
* = $0810

BOOT_START
    JSR $E544           ; CLS — pulisci schermo

    ; Mostra messaggio di caricamento
    LDX #0
BOOT_MSG
    LDA MSG_LOADING,X
    BEQ BOOT_LOADED
    JSR $FFD2           ; CHROUT
    INX
    JMP BOOT_MSG

BOOT_LOADED
    ; --- Carica GAME.PRG ---
    LDX #<NAME_GAME
    LDY #>NAME_GAME
    LDA #NAME_GAME_LEN
    JSR LOAD_FILE
    BCS BOOT_ERR

    ; --- Carica SPRITES.PRG ---
    LDX #<NAME_SPRITES
    LDY #>NAME_SPRITES
    LDA #NAME_SPRITES_LEN
    JSR LOAD_FILE
    BCS BOOT_ERR

    ; --- Carica MUSIC.PRG ---
    LDX #<NAME_MUSIC
    LDY #>NAME_MUSIC
    LDA #NAME_MUSIC_LEN
    JSR LOAD_FILE
    BCS BOOT_ERR

    ; Tutti i file caricati — salta al gioco
    JSR $E544           ; CLS
    JMP GAME_START      ; entry point in game.prg

BOOT_ERR
    ; Mostra errore di caricamento
    LDX #0
ERR_LOOP
    LDA MSG_ERROR,X
    BEQ ERR_DONE
    JSR $FFD2
    INX
    JMP ERR_LOOP
ERR_DONE
    RTS

; --- Routine di caricamento disco ---
; Input: X/Y = puntatore nome, A = lunghezza nome
LOAD_FILE
    PHA                 ; salva lunghezza
    JSR $FFBD           ; SETNAM (A=len, X/Y=nome)
    PLA
    LDA #1              ; unita disco
    LDX $BA             ; ultimo device usato
    LDY #1              ; 1 = load
    JSR $FFD5           ; LOAD
    RTS

; --- Nomi file su disco ---
NAME_GAME
    .text "GAME"
NAME_GAME_LEN = * - NAME_GAME

NAME_SPRITES
    .text "SPRITES"
NAME_SPRITES_LEN = * - NAME_SPRITES

NAME_MUSIC
    .text "MUSIC"
NAME_MUSIC_LEN = * - NAME_MUSIC

; --- Messaggi ---
MSG_LOADING
    .byte $0D
    .text "LOADING GAME..."
    .byte $0D, $00

MSG_ERROR
    .byte $0D
    .text "LOAD ERROR!"
    .byte $0D
    .text "CHECK DISK."
    .byte $0D, $00


; =============================================
; GAME.PRG — Codice principale del gioco
; Si aspetta di essere caricato a $4000
; =============================================

* = $4000

GAME_START
    JSR GAME_INIT
    JSR MUSIC_INIT

; --- Game loop principale ---
GAME_MAIN
    JSR READ_JOY        ; leggi joystick
    JSR UPDATE_PLAYER   ; muovi giocatore
    JSR UPDATE_BULLETS  ; aggiorna proiettili
    JSR UPDATE_ENEMIES  ; muovi nemici
    JSR CHECK_HITS      ; collisioni
    JSR UPDATE_SCORE    ; aggiorna punteggio
    JSR DRAW_HUD        ; disegna interfaccia
    JSR MUSIC_PLAY      ; avanza musica

    ; Sincronizzazione raster
    LDA #$D0
WAIT_RASTER
    CMP $D012
    BNE WAIT_RASTER

    ; Controlla game over
    LDA GAME_OVER_FLAG
    BNE DO_GAME_OVER

    JMP GAME_MAIN

; --- Game over ---
DO_GAME_OVER
    JSR MUSIC_STOP
    JSR SHOW_GAME_OVER_SCREEN
    JSR SAVE_HIGHSCORE
    ; Riavvia dopo 3 secondi
    LDX #150
WAIT_DELAY
    JSR WAIT_FRAME
    DEX
    BNE WAIT_DELAY
    JMP GAME_START

; --- Inizializzazione ---
GAME_INIT
    SEI
    LDA #$35            ; bank out ROM
    STA $01
    LDA #$00
    STA $D020           ; bordo nero
    STA $D021           ; sfondo nero
    ; Setup sprite
    LDA #$FF
    STA $D015           ; abilita tutti gli sprite
    ; Azzera stato
    LDA #0
    STA GAME_OVER_FLAG
    STA SCORE
    STA SCORE+1
    STA SCORE+2
    CLI
    RTS

; --- Lettura joystick ---
READ_JOY
    LDA $DC00           ; porta joystick 2
    AND #$1F            ; maschera bit
    STA JOY_STATE
    RTS

; --- Attesa frame ---
WAIT_FRAME
    LDA #$D0
WF_LOOP
    CMP $D012
    BEQ WF_LOOP
    RTS

; --- Variabili ---
GAME_OVER_FLAG
    .byte 0

SCORE
    .byte 0, 0, 0       ; 3 byte BCD

JOY_STATE
    .byte 0

; --- Stub routines (da implementare) ---
UPDATE_PLAYER
    ; Logica movimento giocatore
    RTS

UPDATE_BULLETS
    ; Aggiorna posizioni proiettili
    RTS

UPDATE_ENEMIES
    ; Logica nemici
    RTS

CHECK_HITS
    ; Collisioni sprite-sprite
    ; Se colpito → GAME_OVER_FLAG = 1
    RTS

UPDATE_SCORE
    ; Incrementa punteggio BCD
    RTS

DRAW_HUD
    ; Disegna punteggio, vite, livello
    RTS

SHOW_GAME_OVER_SCREEN
    ; Mostra "GAME OVER"
    LDX #0
GOS_LOOP
    LDA MSG_GAMEOVER,X
    BEQ GOS_DONE
    STA $0400,X
    LDA #1              ; colore bianco
    STA $D800,X
    INX
    JMP GOS_LOOP
GOS_DONE
    RTS

MSG_GAMEOVER
    .text "G A M E   O V E R"
    .byte $00

SAVE_HIGHSCORE
    ; Salva highscore su disco (file HIGH.SEQ)
    ; TODO: apri file, scrivi SCORE
    RTS


; =============================================
; SPRITES.PRG — Dati sprite
; Caricato a $2000 (esempio)
; =============================================

* = $2000

; Sprite giocatore (63 byte)
SPRITE_PLAYER
    .byte $00, $00, $00
    .byte $18, $3C, $7E
    .byte $3C, $7E, $FF
    .byte $7E, $FF, $FF
    .byte $FF, $FF, $FF
    .byte $7E, $FF, $7E
    .byte $3C, $7E, $3C
    .byte $18, $3C, $18
    .byte $00, $18, $00
    .byte $00, $00, $00
    .byte $00, $00, $00
    .byte $00, $00, $00
    .byte $00, $00, $00
    .byte $00, $00, $00
    .byte $00, $00, $00
    .byte $00, $00, $00
    .byte $00, $00, $00
    .byte $00, $00, $00
    .byte $00, $00, $00
    .byte $00, $00, $00
    .byte $00, $00, $00
    .byte $00

; Sprite nemico
SPRITE_ENEMY
    .byte $00, $00, $00
    .byte $FF, $FF, $FF
    .byte $7E, $FF, $7E
    .byte $3C, $7E, $3C
    .byte $18, $3C, $18
    .byte $3C, $66, $3C
    .byte $66, $C3, $66
    .byte $C3, $81, $C3
    .byte $00, $81, $00
    .byte $00, $00, $00
    .byte $00, $00, $00
    .byte $00, $00, $00
    .byte $00, $00, $00
    .byte $00, $00, $00
    .byte $00, $00, $00
    .byte $00, $00, $00
    .byte $00, $00, $00
    .byte $00, $00, $00
    .byte $00, $00, $00
    .byte $00, $00, $00
    .byte $00, $00, $00
    .byte $00

; Sprite proiettile
SPRITE_BULLET
    .byte $00, $18, $00
    .byte $00, $3C, $00
    .byte $00, $7E, $00
    .byte $00, $3C, $00
    .byte $00, $18, $00
    .byte $00, $00, $00
    ; padding a 64 byte (bit 7 dell'ultimo byte = mc flag)
    .byte $00, $00, $00
    .byte $00, $00, $00
    .byte $00, $00, $00
    .byte $00, $00, $00
    .byte $00, $00, $00
    .byte $00, $00, $00
    .byte $00, $00, $00
    .byte $00, $00, $00
    .byte $00, $00, $00
    .byte $00, $00, $00
    .byte $00, $00, $00
    .byte $00, $00, $00
    .byte $00

; --- Indirizzi sprite in memoria ---
SPRITE_ADDR_PLAYER = $2000
SPRITE_ADDR_ENEMY  = $2040
SPRITE_ADDR_BULLET = $2080


; =============================================
; MUSIC.PRG — Player musicale minimale
; Player a tabella, usa voce 1 del SID
; =============================================

* = $C000

; --- Registri SID ---
SID_V1_FREQ_LO = $D400
SID_V1_FREQ_HI = $D401
SID_V1_CTRL    = $D404
SID_V1_AD      = $D405
SID_V1_SR      = $D406
SID_VOL        = $D418

; --- Inizializzazione musica ---
MUSIC_INIT
    LDA #$0F
    STA SID_VOL        ; volume massimo
    LDA #$09
    STA SID_V1_CTRL    ; square + gate ON
    LDA #$41
    STA SID_V1_AD      ; attack 4, decay 1
    LDA #$A0
    STA SID_V1_SR      ; sustain A, release 0
    LDA #0
    STA MUSIC_PTR      ; resetta puntatore
    STA MUSIC_TICK
    RTS

; --- Play: chiamare ogni frame (50 Hz) ---
MUSIC_PLAY
    ; Gestione timer nota
    DEC MUSIC_TICK
    BNE MP_DONE

    ; Carica prossima nota
    LDX MUSIC_PTR
    LDA FREQ_TABLE,X
    BNE MP_PLAY_NOTE

    ; Fine tabella — loop
    LDA #0
    STA MUSIC_PTR
    JMP MUSIC_PLAY

MP_PLAY_NOTE
    ; Frequenza bassa
    STA SID_V1_FREQ_LO
    LDA FREQ_TABLE+1,X
    STA SID_V1_FREQ_HI

    ; Durata nota
    LDA FREQ_TABLE+2,X
    STA MUSIC_TICK

    ; Gate re-strike
    LDA #$00
    STA SID_V1_CTRL
    LDA #$09
    STA SID_V1_CTRL

    ; Avanza puntatore (3 byte per entry)
    TXA
    CLC
    ADC #3
    STA MUSIC_PTR

MP_DONE
    RTS

; --- Ferma musica ---
MUSIC_STOP
    LDA #$00
    STA SID_V1_CTRL
    STA SID_V2_CTRL
    STA SID_V3_CTRL
    RTS

; --- Tabella frequenze ---
; Formato: freq_lo, freq_hi, durata_frames
FREQ_TABLE
    ; Do4
    .byte $17, $08, 15
    ; Re4
    .byte $28, $09, 15
    ; Mi4
    .byte $38, $0A, 15
    ; Fa4
    .byte $47, $0A, 15
    ; Sol4
    .byte $5A, $0B, 15
    ; La4
    .byte $6D, $0C, 15
    ; Si4
    .byte $7F, $0D, 15
    ; Do5
    .byte $17, $10, 15
    ; Fine (0 = loop)
    .byte $00, $00, 00

; --- Variabili ---
MUSIC_PTR
    .byte 0
MUSIC_TICK
    .byte 0

; Registri aggiuntivi (per mixer SFX)
SID_V2_FREQ_LO = $D407
SID_V2_FREQ_HI = $D408
SID_V2_CTRL    = $D40B
SID_V3_FREQ_LO = $D40E
SID_V3_FREQ_HI = $D40F
SID_V3_CTRL    = $D412


; =============================================
; Script di build (non codice, solo riferimento)
; =============================================
;
; Per costruire il disco completo:
;
; 1. Assembla ogni file con TMPx:
;    tmpx -o boot.prg boot.asm
;    tmpx -o game.prg game.asm
;    tmpx -o sprites.prg sprites.asm
;    tmpx -o music.prg music.asm
;
; 2. Crea highscore di default:
;    echo -ne "\x00\x08" > high.seq
;    echo -ne "000000" >> high.seq
;
; 3. Crea il disco D64:
;    python tools/create_d64.py \
;        -o game.d64 \
;        --name "SPACE WARS" \
;        --type PRG,PRG,PRG,PRG,SEQ \
;        boot.prg game.prg sprites.prg music.prg high.seq
;
; 4. Oppure usa c1541 di VICE:
;    c1541 -format "SPACE WARS,A" game.d64
;    c1541 game.d64 -write boot.prg BOOT
;    c1541 game.d64 -write game.prg GAME
;    c1541 game.d64 -write sprites.prg SPRITES
;    c1541 game.d64 -write music.prg MUSIC
;    c1541 game.d64 -write high.seq HIGHSCORE,p
;
; 5. Testa in VICE:
;    x64sc -8 game.d64
;    LOAD "*",8,1
;    RUN
;
; =============================================
