; =============================================
; MAIN — Punto d'ingresso: memory map + include chain
; =============================================
;
; Assemblare con:
;   tmpx -o game.prg game/main.asm
;
; Gioco completo: Space Commander
; Unisce tutti i concetti del tutorial C64:
;   - Kernel engine (IRQ, scheduler, frame)
;   - Sprite multiplexing
;   - Entity system
;   - Collision detection
;   - Wave system + AI nemici
;   - Boss fight
;   - State machine (TITLE/PLAY/GAMEOVER)
;   - Audio SID
;   - HUD con punteggio/vite/wave
;
; =============================================

; ---- Include centralizzato dei file sorgente ----
; L'ordine segue la memory map, dal basso verso l'alto

; Costanti e zero page (nessuna memoria occupata)
.include "config.asm"

; Sprite data + tabelle ($2000-$3FFF, $6000-$6FFF)
.include "data.asm"

; Kernel: IRQ, scheduler ($0800-$0BFF)
.include "kernel.asm"

; Engine layer ($0C00-$12FF)
.include "input.asm"
.include "entity.asm"
.include "sprite.asm"
.include "collision.asm"
.include "audio.asm"
.include "screen.asm"

; Game layer ($4000-$5FFF)
.include "player.asm"
.include "enemies.asm"
.include "states.asm"

; =============================================
; BOOT — Entry point after LOAD"GAME",8,1
; =============================================
; Il programma si carica a $0800 (il kernel)
; e parte da qui dopo SYS 2048

START
    JSR KERNEL_INIT
    JSR GAME_INIT
    JMP KERNEL_MAIN
