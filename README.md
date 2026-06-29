# C64 Game Tutorial — Manuale di Programmazione Arcade

[![Licence](https://img.shields.io/badge/licence-CC--BY--4.0-blue)](LICENCE)

Manuale completo in italiano per creare videogiochi arcade su Commodore 64 usando Turbo Macro Pro e assembly 6502.

Dal primo sprite al boss finale, dal raster interrupt al SID, dall'architettura 3-layer all'Arcade OS.

## Contenuti

```
md/                     Manuale originale italiano (20 capitoli + 7 appendici)
en/                     Traduzione inglese (in corso)
soluzioni/              Soluzioni degli esercizi (.asm)
manuali/                PDF di riferimento (C64 Programmer's Guide, Mapping the C64, ecc.)
docs/ROADMAP.md         Miglioramenti proposti per il progetto
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
| 7 | 19-20 | Architettura professionale (kernel 3-layer, Arcade OS) |

### Appendici

| File | Contenuto |
|---|---|
| A | Tabelle (colori, registri VIC-II/SID/CIA, istruzioni 6502) |
| B | Glossario |
| C | Schemi rapidi: CPU e memoria |
| D | Schemi rapidi: video e sprite |
| E | Schemi rapidi: architettura di gioco |
| F | Schemi rapidi: audio e hardware |
| TMP | Guida rapida a Turbo Macro Pro |

### Statistiche

- **~10500 righe** di manuale
- **27 file** in `md/`
- **19 soluzioni assembly** (capitoli 1-19)
- **22 file** traduzione inglese (in attesa di traduzione)

## Come iniziare

Leggi il manuale in ordine sequenziale partendo da `md/01-introduzione-c64-tmp.md`.
Ogni capitolo include esercizi con soluzioni in `soluzioni/`.

Per assemblare il codice serve Turbo Macro Pro (nativo su C64) o TMPx (cross-assembler).
Vedi `md/appendice-turbo-macro-pro.md` per installazione e comandi.

## Riferimenti

- Turbo Macro Pro: <https://style64.org>
- TMPx cross-assembler: <https://style64.org/release/tmpx-v1.1.0-style>
- C64 OS Programmer's Guide: <https://c64os.com/c64os/programmersguide/devenvironment>
- C64 Programmer's Reference Guide (PDF in `manuali/`)

## Licenza

CC BY 4.0 — citare l'autore originale (@alby69) e linkare il repository.
