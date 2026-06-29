# Appendix G — External Resources

If your goal is to become truly proficient in C64 game development in 6510 Assembly, we recommend studying resources in this order: Reference Guide → Butterfield → Codebase64 → Disassembled ROMs → Modern Demo Scene.

## Recommended Resources

| Category | Subcategory | Resource | Link |
|----------|-------------|----------|------|
| **Fundamental Manuals** | Official manual | Commodore 64 Programmer's Reference Guide | [Programmer's Reference Guide](https://www.commodore.ca/commodore-manuals/commodore-64-programmers-reference-guide/) |
| **Fundamental Manuals** | Wiki version | C64-Wiki PRG | [C64-Wiki PRG](https://www.c64-wiki.com/wiki/Commodore_64_Programmer%27s_Reference_Guide) |
| **Assembly Books** | Beginners | Jim Butterfield - Machine Language for the Commodore 64 | [Machine Language for the Commodore 64 PDF](http://www.1000bit.it/support/manuali/commodore/c64/ML_for_the_C64_and_Other_Commodore_Computers.pdf) |
| **Assembly Books** | Intermediate | Assembly Language Programming with the Commodore 64 | [Archive.org Edition](https://archive.org/details/Assembly_Language_Programming_With_the_Commodore_64_1984_Brady_Communications_Company) |
| **6502 Reference** | 6502 CPU | Obelisk 6502 Reference | [6502 Reference Guide](http://www.obelisk.me.uk/6502/) |
| **6502 Reference** | Opcodes | Masswerk 6502 Instruction Set | [6502 Instruction Set](https://www.masswerk.at/6502/6502_instruction_set.html) |
| **Advanced Techniques** | Optimizations | Codebase64 | [Codebase64](https://codebase64.org/) |
| **Advanced Techniques** | Technical Articles | C64-Wiki Assembler | [Assembler Overview](https://www.c64-wiki.com/wiki/Assembler) |
| **Hardware** | VIC-II | VIC-II Documentation | [VIC-II Reference](https://www.c64-wiki.com/wiki/VIC-II) |
| **Hardware** | SID | SID Documentation | [SID Reference](https://www.c64-wiki.com/wiki/SID) |
| **Hardware** | CIA 6526 | CIA Documentation | [CIA Reference](https://www.c64-wiki.com/wiki/CIA) |
| **Hardware** | KERNAL | KERNAL Documentation | [KERNAL Reference](https://www.c64-wiki.com/wiki/KERNAL) |
| **Hardware** | Memory Map | Memory Map | [Memory Map Reference](https://www.c64-wiki.com/wiki/Memory_Map) |
| **Hardware** | Zero Page | Zero Page | [Zero Page Reference](https://www.c64-wiki.com/wiki/Zero_Page) |
| **IRQ and Raster** | Raster Interrupt | Raster Interrupts | [Raster Interrupts](https://www.c64-wiki.com/wiki/Raster_interrupt) |
| **IRQ and Raster** | VIC Timing | VIC-II Timing FAQ | [VIC Timing FAQ](https://codebase64.org/doku.php?id=base:vicii_timing) |
| **Sprite System** | Multiplexing | Sprite Multiplexing | [Sprite Multiplexing](https://codebase64.org/doku.php?id=base:sprite_multiplexing) |
| **Sprite System** | Collision | Sprite Collision | [Sprite Collision Detection](https://codebase64.org/doku.php?id=base:sprite_collision_detection) |
| **Scrolling** | Smooth Scroll | Smooth Scrolling | [Smooth Scrolling](https://codebase64.org/doku.php?id=base:smooth_scrolling) |
| **Scrolling** | Parallax | Scrolling Techniques | [Scrolling Collection](https://codebase64.org/doku.php?id=base:scrolling) |
| **Audio** | SID Programming | SID Techniques | [SID Programming](https://codebase64.org/doku.php?id=base:sid_programming) |
| **Audio** | SID Docs | SID Manual | [SID Documentation Collection](https://www.c64-wiki.com/wiki/SID) |
| **Demo Scene** | Demo Coding | C64 Demo Coding | [Codebase64 Demo Section](https://codebase64.org/doku.php?id=base:start) |
| **Reverse Engineering** | ROM Source | C64 ROM Disassembly | [C64 ROM Disassembly](https://github.com/mist64/c64rom) |
| **Reverse Engineering** | KERNAL Source | KERNAL Source Study | [C64 KERNAL Source](https://github.com/mist64/c64rom/tree/master/kernal) |
| **Modern Assemblers** | Cross Assembler | KickAssembler | [KickAssembler](https://theweb.dk/KickAssembler/Main.html) |
| **Modern Assemblers** | IDE | C64Studio | [C64Studio](https://www.georg-rottensteiner.de/c64studio/) |
| **C64 Native Assembler** | Native Assembler | Turbo Macro Pro | [Turbo Macro Pro](https://github.com/Style64/Turbo-Macro-Pro) |
| **Emulation** | Emulator + Debugger | VICE | [VICE Emulator](https://vice-emu.sourceforge.io/) |
| **Video Tutorials** | YouTube | 8-Bit Show and Tell | [8-Bit Show and Tell](https://www.youtube.com/@8BitShowAndTell) |
| **Video Tutorials** | Game Development | Retro Game Dev | [Retro Game Dev](https://retrogamedev.com/) |
| **Video Tutorials** | Complete Course | C64 Assembly Tutorial Playlist | [Assembly Tutorial Playlist](https://www.youtube.com/playlist?list=PLU1o_YShTPgoA7_nZ0PutqaPDsitA5RvV) |
| **Community** | Technical Forum | Lemon64 Programming | [Lemon64 Forums](https://www.lemon64.com/forum/) |
| **Community** | Demo Scene Forum | CSDB | [CSDb](https://csdb.dk/) |
| **Community** | General Wiki | C64-Wiki | [C64-Wiki](https://www.c64-wiki.com/) |

## Recommended Study Path

1.  **Phase 1:** Read the "Basic to Machine Language" chapter of the *Programmer's Reference Guide*.
2.  **Phase 2:** Study Jim Butterfield's book thoroughly.
3.  **Phase 3:** Deepen core concepts:
    - Addressing modes
    - Stack management
    - Interrupts (IRQ/NMI)
    - Zero Page usage
4.  **Phase 4:** Move to *Codebase64* for advanced techniques:
    - Raster IRQs
    - Sprite multiplexing
    - Smooth scrolling
    - Double buffering
5.  **Phase 5:** Analyze source code of modern games and demos.
6.  **Phase 6:** Study disassembled KERNAL and BASIC ROMs.
