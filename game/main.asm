:BasicUpstart2(START)
// =============================================
// MAIN — Punto d'ingresso: memory map + include chain
// --- METADATA ---
// project: Space Commander
// type: Main Entry Point
// structure: Modular (include)
// description: Full game template combining all tutorial concepts
// --- END METADATA ---
// =============================================
//
// Assemblare con:
//   java -jar tools/KickAss.jar -o build/game.prg game/main.asm
//   oppure: make game-kickass
//
// Gioco completo: Space Commander
// Unisce tutti i concetti del tutorial C64:
//   - Kernel engine (IRQ, scheduler, frame)
//   - Sprite multiplexing
//   - Entity system
//   - Collision detection
//   - Wave system + AI nemici
//   - Boss fight
//   - State machine (TITLE/PLAY/GAMEOVER)
//   - Audio SID
//   - HUD con punteggio/vite/wave
//
// =============================================

// ---- Include centralizzato dei file sorgente ----
// L'ordine segue la memory map, dal basso verso l'alto

// Costanti e zero page (nessuna memoria occupata)
#import "config.asm"

// Sprite data + tabelle ($2000-$3FFF, $6000-$6FFF)
#import "data.asm"

// Kernel: IRQ, scheduler ($0800-$0BFF)
#import "kernel.asm"

// Engine layer ($0C00-$12FF)
#import "input.asm"
#import "entity.asm"
#import "sprite.asm"
#import "collision.asm"
#import "audio.asm"
#import "screen.asm"

// Scroll + high score ($1300-$14FF)
#import "scroll.asm"
#import "highscore.asm"

// Game layer ($4000-$5FFF)
#import "player.asm"
#import "enemies.asm"
#import "states.asm"

// =============================================
// BOOT — Entry point after LOAD"GAME",8,1
// =============================================
// Il programma si carica a $0800 (il kernel)
// e parte da qui dopo SYS 2048

START:

    jsr KERNEL_INIT
    jsr GAME_INIT
    jmp KERNEL_MAIN
