# C64 Arcade Game Programming Manual — English Version

> **Status:** Fully translated (chapters 1-21 + appendices)
> **Original (Italian):** `../md/`

This directory contains the English translation of the C64 arcade game programming tutorial.
Each file mirrors the Italian original in `../md/`.

## Translation progress

| File | Status |
|---|---|
| Ch. 1 | `01-c64-tmp-introduction.md` | ✅ Translated |
| Ch. 2 | `02-fundamental-instructions.md` | ✅ Translated |
| Ch. 3 | `03-addressing-loops-delays.md` | ✅ Translated |
| Ch. 4 | `04-video-memory-characters.md` | ✅ Translated |
| Ch. 5 | `05-sprite-hardware-vic-ii.md` | ✅ Translated |
| Ch. 6 | `06-sprite-movement-control.md` | ✅ Translated |
| Ch. 7 | `07-raster-interrupt.md` | ✅ Translated |
| Ch. 8 | `08-synchronized-game-loop.md` | ✅ Translated |
| Ch. 9 | `09-joystick-input.md` | ✅ Translated |
| Ch. 10 | `10-software-collisions.md` | ✅ Translated |
| Ch. 11 | `11-bullet-system.md` | ✅ Translated |
| Ch. 12 | `12-wave-system-ai.md` | ✅ Translated |
| Ch. 13 | `13-score-game-states.md` | ✅ Translated |
| Ch. 14 | `14-sid-audio-basics.md` | ✅ Translated |
| Ch. 15 | `15-audio-engine-sfx.md` | ✅ Translated |
| Ch. 16 | `16-sprite-multiplexing.md` | ✅ Translated |
| Ch. 17 | `17-parallax-raster-split.md` | ✅ Translated |
| Ch. 18 | `18-boss-system.md` | ✅ Translated |
| Ch. 19 | `19-reusable-kernel-engine.md` | ✅ Translated |
| Ch. 20 | `20-arcade-os-beyond.md` | ✅ Translated |
| Ch. 21 | `21-custom-loader.md` | ✅ Translated |
| App. A | `appendix-a-reference-tables.md` | ❌ Pending |
| App. B | `appendix-b-glossary.md` | ❌ Pending |
| App. C | `appendix-c-cpu-memory.md` | ✅ Placeholder |
| App. D | `appendix-d-video-schematics.md` | ✅ Placeholder |
| App. E | `appendix-e-architecture-schematics.md` | ✅ Placeholder |
| App. F | `appendix-f-audio-schematics.md` | ✅ Placeholder |
| App. TMP | `appendix-turbo-macro-pro.md` | ✅ Placeholder |

## Structure

```
en/
├── 01-03   PART I — Foundations (6502, TMP, instructions, addressing)
├── 04-06   PART II — Graphics & Sprites
├── 07-08   PART III — Raster & Sync
├── 09-13   PART IV — Gameplay
├── 14-15   PART V — Audio
├── 16-18   PART VI — Advanced Techniques
├── 19-21   PART VII — Professional Architecture
├── A-TMP  Appendices (A-F + TMP quick ref)
```

## Part I – Foundations (1–3) ✅
CPU 6510, TMP, instructions, addressing modes, loops, first graphics.

## Part II – Graphics & Sprites (4–6)
Video memory, VIC-II sprite hardware, movement, multicolor, animation.

## Part III – Raster & Sync (7–8)
Raster interrupts, IRQ, 50 Hz game loop, frame counter.

## Part IV – Gameplay (9–13)
Joystick, collisions, bullet pool, wave system, AI, score, state machine.

## Part V – Audio (14–15)
SID chip basics, waveform, audio engine, SFX queue, music.

## Part VI – Advanced Techniques (16–18)
Sprite multiplexing (8+), raster split, parallax, boss multi-phase system.

## Part VII – Professional Architecture (19–21)
Reusable kernel engine, 3-layer architecture, Arcade OS concepts, custom loader.

## Appendices
Color/memory/register tables, 6502 reference, CPU/video/architecture/audio schemas, TMP quick reference.
