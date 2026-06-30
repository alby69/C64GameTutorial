# C64 Game Tutorial — Manuale di Programmazione Arcade

[![Validate](https://github.com/anomalyco/C64GameTutorial/actions/workflows/validate.yml/badge.svg)](https://github.com/anomalyco/C64GameTutorial/actions/workflows/validate.yml)
[![Licence](https://img.shields.io/badge/licence-CC--BY--4.0-blue)](LICENCE)

Manuale completo in italiano per creare videogiochi arcade su Commodore 64 usando Turbo Macro Pro e assembly 6502.

Dal primo sprite al boss finale, dal raster interrupt al SID, dall'architettura 3-layer all'Arcade OS.

## Contenuti

```
md/                     Manuale originale italiano (27 capitoli + 7 appendici + indice)
en/                     Traduzione inglese (completa — 27 capitoli)
soluzioni/              Soluzioni degli esercizi (.asm)
game/                   Template gioco completo (multi-file, .include)
tools/                  Script di supporto (validate, size-report, vice-test)
manuali/                PDF di riferimento (C64 Programmer's Guide, Mapping the C64, ecc.)
ROADMAP.md              Miglioramenti proposti per il progetto
```

### Parti del manuale

| Parte | Capitoli | Argomento |
|---|---|---|
| 1 | 01-03 | Fondamenti di 6502 e Turbo Macro Pro |
| 2 | 04-06 | Grafica e sprite (VIC-II) |
| 3 | 07-08 | Raster interrupt e sincronismo |
| 4 | 09-13 | Gameplay (joystick, collisioni, pool, wave, stati) |
| 5 | 14-15 | Audio SID |
| 6 | 16-18 | Tecniche avanzate (multiplex, parallax, boss) |
| 7 | 19-21 | Architettura professionale (kernel 3-layer, Arcade OS, custom loader) |
| 8 | 22-24 | Strumenti e rifiniture (debugging VICE, titolo/high score, scrolling) |
| 9 | 25-27 | Hardware avanzato (turbo loader, REU, music tracker) |

### Appendici

| File | Contenuto |
|---|---|
| A | Tabelle (colori, registri VIC-II/SID/CIA, istruzioni 6502) |
| B | Glossario |
| C | Schemi rapidi: CPU e memoria |
| D | Schemi rapidi: video e sprite |
| E | Schemi rapidi: architettura di gioco |
| F | Schemi rapidi: audio e hardware |
| G | Risorse esterne: libri, siti e tutorial |
| TMP | Guida rapida a Turbo Macro Pro |

### Statistiche

- **~12700 righe** di manuale (IT)
- **36 file** in `md/` (27 capitoli + 8 appendici + indice)
- **28 soluzioni assembly** + template gioco (13 file)
- **~11200 righe** traduzione inglese (27 capitoli tradotti)
- **32/32 ROADMAP completati**

## Come iniziare (Quick Start)

1.  **Leggi il manuale:** Inizia da `md/01-introduzione-c64-tmp.md` o visita il [sito web](https://anomalyco.github.io/C64GameTutorial/).
2.  **Prerequisiti:** Installa `tmpx` (cross-assembler) e `VICE` (emulatore).
3.  **Assembla un esempio:**
    ```bash
    tmpx -o cap01.prg soluzioni/cap01-introduzione.asm
    ```
4.  **Esegui:** Trascina `cap01.prg` su VICE o usa `x64sc cap01.prg`.

Ogni capitolo include esercizi con soluzioni in `soluzioni/`.

## Dipendenze di sistema

Per compilare ed eseguire gli esempi e generare il manuale sono necessari:

- **TMPx:** Cross-assembler 6502 ([Download](https://style64.org/release/tmpx-v1.1.0-style)).
- **VICE:** Emulatore Commodore 64 (raccomandato `x64sc`).
- **Make:** Per automatizzare i task (`all`, `validate`, `stats`).
- **Pandoc & XeLaTeX:** (Opzionale) Per generare il PDF (`make pdf`).
- **Python 3 & Pillow:** Per gli script in `tools/` (es. `png2sprite.py`).

## Riferimenti

- Turbo Macro Pro: <https://style64.org>
- TMPx cross-assembler: <https://style64.org/release/tmpx-v1.1.0-style>
- C64 OS Programmer's Guide: <https://c64os.com/c64os/programmersguide/devenvironment>
- C64 Programmer's Reference Guide (PDF in `manuali/`)
- CSDb (Commodore Scene Database): <https://csdb.dk>
- Lemon64 Forum: <https://www.lemon64.com/forum/>

## Licenza

Questo progetto è distribuito con le seguenti licenze:

- **Manuale (testo e immagini):** [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/deed.it) — citare l'autore originale (@alby69).
- **Codice sorgente (.asm):** [Licenza MIT](https://opensource.org/licenses/MIT).
