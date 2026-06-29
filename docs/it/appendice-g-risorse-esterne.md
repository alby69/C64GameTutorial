# Appendice G — Risorse Esterne

Se il tuo obiettivo è diventare davvero bravo nello sviluppo di giochi C64 in Assembly 6510, ti consigliamo di studiare le risorse in questo ordine: Reference Guide → Butterfield → Codebase64 → ROM disassemblate → demo scene moderna.

## Risorse Consigliate

| Categoria | Sottocategoria | Risorsa | Link |
|-----------|----------------|---------|------|
| **Manuali fondamentali** | Manuale ufficiale | Commodore 64 Programmer's Reference Guide | [Programmer's Reference Guide](https://www.commodore.ca/commodore-manuals/commodore-64-programmers-reference-guide/) |
| **Manuali fondamentali** | Versione wiki | C64-Wiki PRG | [C64-Wiki PRG](https://www.c64-wiki.com/wiki/Commodore_64_Programmer%27s_Reference_Guide) |
| **Libri Assembly** | Principianti | Jim Butterfield - Machine Language for the Commodore 64 | [Machine Language for the Commodore 64 PDF](http://www.1000bit.it/support/manuali/commodore/c64/ML_for_the_C64_and_Other_Commodore_Computers.pdf) |
| **Libri Assembly** | Intermedio | Assembly Language Programming with the Commodore 64 | [Archive.org Edition](https://archive.org/details/Assembly_Language_Programming_With_the_Commodore_64_1984_Brady_Communications_Company) |
| **Reference 6502** | CPU 6502 | Obelisk 6502 Reference | [6502 Reference Guide](http://www.obelisk.me.uk/6502/) |
| **Reference 6502** | Opcode | Masswerk 6502 Instruction Set | [6502 Instruction Set](https://www.masswerk.at/6502/6502_instruction_set.html) |
| **Tecniche avanzate** | Ottimizzazioni | Codebase64 | [Codebase64](https://codebase64.org/) |
| **Tecniche avanzate** | Articoli tecnici | C64-Wiki Assembler | [Assembler Overview](https://www.c64-wiki.com/wiki/Assembler) |
| **Hardware** | VIC-II | VIC-II Documentation | [VIC-II Reference](https://www.c64-wiki.com/wiki/VIC-II) |
| **Hardware** | SID | SID Documentation | [SID Reference](https://www.c64-wiki.com/wiki/SID) |
| **Hardware** | CIA 6526 | CIA Documentation | [CIA Reference](https://www.c64-wiki.com/wiki/CIA) |
| **Hardware** | KERNAL | KERNAL Documentation | [KERNAL Reference](https://www.c64-wiki.com/wiki/KERNAL) |
| **Hardware** | Memory Map | Memory Map | [Memory Map Reference](https://www.c64-wiki.com/wiki/Memory_Map) |
| **Hardware** | Zero Page | Zero Page | [Zero Page Reference](https://www.c64-wiki.com/wiki/Zero_Page) |
| **IRQ e Raster** | Raster Interrupt | Raster Interrupts | [Raster Interrupts](https://www.c64-wiki.com/wiki/Raster_interrupt) |
| **IRQ e Raster** | VIC Timing | VIC-II Timing FAQ | [VIC Timing FAQ](https://codebase64.org/doku.php?id=base:vicii_timing) |
| **Sprite System** | Multiplexing | Sprite Multiplexing | [Sprite Multiplexing](https://codebase64.org/doku.php?id=base:sprite_multiplexing) |
| **Sprite System** | Collision | Sprite Collision | [Sprite Collision Detection](https://codebase64.org/doku.php?id=base:sprite_collision_detection) |
| **Scrolling** | Smooth Scroll | Smooth Scrolling | [Smooth Scrolling](https://codebase64.org/doku.php?id=base:smooth_scrolling) |
| **Scrolling** | Parallax | Scrolling Techniques | [Scrolling Collection](https://codebase64.org/doku.php?id=base:scrolling) |
| **Audio** | SID Programming | SID Techniques | [SID Programming](https://codebase64.org/doku.php?id=base:sid_programming) |
| **Audio** | SID Docs | SID Manual | [SID Documentation Collection](https://www.c64-wiki.com/wiki/SID) |
| **Demo Scene** | Demo Coding | C64 Demo Coding | [Codebase64 Demo Section](https://codebase64.org/doku.php?id=base:start) |
| **Reverse Engineering** | ROM Source | C64 ROM Disassembly | [C64 ROM Disassembly](https://github.com/mist64/c64rom) |
| **Reverse Engineering** | KERNAL Source | KERNAL Source Study | [C64 KERNAL Source](https://github.com/mist64/c64rom/tree/master/kernal) |
| **Assembler Moderni** | Cross Assembler | KickAssembler | [KickAssembler](https://theweb.dk/KickAssembler/Main.html) |
| **Assembler Moderni** | IDE | C64Studio | [C64Studio](https://www.georg-rottensteiner.de/c64studio/) |
| **Assembler Reale C64** | Native Assembler | Turbo Macro Pro | [Turbo Macro Pro](https://github.com/Style64/Turbo-Macro-Pro) |
| **Emulazione** | Emulator + Debugger | VICE | [VICE Emulator](https://vice-emu.sourceforge.io/) |
| **Video Tutorial** | YouTube | 8-Bit Show and Tell | [8-Bit Show and Tell](https://www.youtube.com/@8BitShowAndTell) |
| **Video Tutorial** | Sviluppo Giochi | Retro Game Dev | [Retro Game Dev](https://retrogamedev.com/) |
| **Video Tutorial** | Corso completo | C64 Assembly Tutorial Playlist | [Assembly Tutorial Playlist](https://www.youtube.com/playlist?list=PLU1o_YShTPgoA7_nZ0PutqaPDsitA5RvV) |
| **Community** | Forum tecnico | Lemon64 Programming | [Lemon64 Forums](https://www.lemon64.com/forum/) |
| **Community** | Forum demo scene | CSDB | [CSDb](https://csdb.dk/) |
| **Community** | Wiki generale | C64-Wiki | [C64-Wiki](https://www.c64-wiki.com/) |

## Percorso di studio consigliato

1.  **Fase 1:** Leggere il capitolo "Basic to Machine Language" del *Programmer's Reference Guide*.
2.  **Fase 2:** Studiare integralmente il libro di Jim Butterfield.
3.  **Fase 3:** Approfondire i concetti fondamentali:
    - Modalità di indirizzamento (addressing modes)
    - Gestione dello Stack
    - Interrupt (IRQ/NMI)
    - Utilizzo della Zero Page
4.  **Fase 4:** Passare a *Codebase64* per tecniche avanzate:
    - Raster IRQ
    - Sprite multiplexing
    - Smooth scrolling
    - Double buffering
5.  **Fase 5:** Analizzare codice sorgente di giochi e demo moderne.
6.  **Fase 6:** Studiare le ROM disassemblate del KERNAL e del BASIC.
