# Soluzioni degli Esercizi

Questa directory contiene le soluzioni agli esercizi dei capitoli del manuale `md/`.

## Come usare le soluzioni

Ogni file `.asm` corrisponde a un capitolo e contiene le soluzioni di tutti gli esercizi,
separate da commenti `; --- ESERCIZIO N: ... ---`.

### Su C64 nativo

```
LOAD"TMP",8,1
SYS 8*4096
←l (load source)
? NOMEFILE (es. CAP01-INTRODUZIONE)
←5 (assemble to disk)
? NOMEFILE
←1 (exit BASIC)
LOAD"NOMEFILE",8,1
SYS indirizzo (di solito $8000 = 32768)
```

### Su emulatore (VICE)

```
tmpx -o cap01-introduzione.prg soluzioni/cap01-introduzione.asm
x64 cap01-introduzione.prg
```

## Tabella esercizi

| Capitolo | File soluzione | Esercizi | Argomento |
|---|---|---|---|
| 01 | `cap01-introduzione.asm` | 5 | Introduzione, LDA/STA, bordo/sfondo |
| 02 | `cap02-istruzioni.asm` | 5 | Istruzioni fondamentali, loop, delay |
| 03 | `cap03-indirizzamento.asm` | 5 | Indirizzamento, tabelle, stack |
| 04 | `cap04-memoria-video.asm` | 5 | Screen RAM, Color RAM, caratteri |
| 05 | `cap05-sprite.asm` | 5 | Sprite hardware, pointer, dati |
| 06 | `cap06-movimento-sprite.asm` | 5 | Movimento, MSB, multicolore, animazione |
| 07 | `cap07-raster.asm` | 5 | Raster IRQ, cambio colore |
| 08 | `cap08-game-loop.asm` | 5 | Game loop 50 Hz, frame counter |
| 09 | `cap09-joystick.asm` | 5 | Joystick, edge detection, movimento |
| 10 | `cap10-collisioni.asm` | 5 | Bounding box, collision detection |
| 11 | `cap11-proiettili.asm` | 5 | Pool proiettili, cooldown |
| 12 | `cap12-wave-ai.asm` | 5 | Wave system, AI nemici |
| 13 | `cap13-punteggio-stati.asm` | 5 | Punteggio, state machine MENU/PLAY/GAMEOVER |
| 14 | `cap14-audio-base.asm` | 5 | SID base, waveform, ADSR |
| 15 | `cap15-audio-engine.asm` | 5 | Audio engine, coda SFX |
| 16 | `cap16-multiplexing.asm` | 5 | Sprite multiplexing, zone |
| 17 | `cap17-parallax-raster-split.asm` | 5 | Raster split, parallax, scroll |
| 18 | `cap18-boss.asm` | 5 | Boss multi-fase, pattern |
| 19 | `cap19-kernel-engine.asm` | 5 | Kernel 3-layer, scheduler, entity system |
| 20 | `cap20-arcade-os.asm` | 5 | Arcade OS, interrupt chaining, demo pratiche |
| — | `game/main.asm` (multi-file) | — | **Gioco completo**: Space Commander (vertical shooter) |

## Indirizzi di assemblaggio

Tutti i file si assemblano a `$8000` salvo diversa indicazione nel capitolo.

## Dimensioni Codice

Le righe si riferiscono al file `.asm` (commenti inclusi). I byte `.prg` sono disponibili dopo `make all`.

| Cap | File | Origine | Righe | Esercizi |
|-----|------|---------|------:|---------:|
| 1 | `cap01-introduzione.asm` | $8000 | 54 | 5 |
| 2 | `cap02-istruzioni.asm` | $8000 | 113 | 5 |
| 3 | `cap03-indirizzamento.asm` | $8000 | 80 | 5 |
| 4 | `cap04-memoria-video.asm` | $8000 | 107 | 5 |
| 5 | `cap05-sprite.asm` | $8000 | 144 | 5 |
| 6 | `cap06-movimento-sprite.asm` | $8000 | 200 | 5 |
| 7 | `cap07-raster.asm` | $8000 | 235 | 5 |
| 8 | `cap08-game-loop.asm` | $8000 | 175 | 5 |
| 9 | `cap09-joystick.asm` | $8000 | 279 | 5 |
| 10 | `cap10-collisioni.asm` | $8000 | 464 | 5 |
| 11 | `cap11-proiettili.asm` | $8000 | 395 | 5 |
| 12 | `cap12-wave-ai.asm` | $8000 | 350 | 5 |
| 13 | `cap13-punteggio-stati.asm` | $8000 | 308 | 5 |
| 14 | `cap14-audio-base.asm` | $8000 | 217 | 5 |
| 15 | `cap15-audio-engine.asm` | $8000 | 284 | 5 |
| 16 | `cap16-multiplexing.asm` | $8000 | 373 | 5 |
| 17 | `cap17-parallax-raster-split.asm` | $8000 | 312 | 5 |
| 18 | `cap18-boss.asm` | $8000 | 350 | 5 |
| 19 | `cap19-kernel-engine.asm` | $A000 | 381 | 5 |
| 20 | `cap20-arcade-os.asm` (concettuale) | N/A | 462 | 5 |
| 21 | `cap21-caricatore.asm` | $C000 | 269 | 5 |
| 22 | `cap22-debugging.asm` | $C000 | 119 | 5 |
| 23 | `cap23-titolo-highscore.asm` | $C000 | 369 | 5 |
| 24 | `cap24-scrolling.asm` | $C000 | 316 | 5 |
| — | `game/` (13 file) | — | 1838 | — |
| **Totale** | | | **6356** | **120** |

Generato con `tools/size-report.sh`.

## Nota

Le soluzioni sono scritte in sintassi Turbo Macro Pro.
Per TMPx (cross-assembler): `tmpx -o output.prg sorgente.asm`
