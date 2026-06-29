# Chapter 21 — Custom Loader

> **Objective:** Replace BASIC's `LOAD"*",8,1` with an assembly-written loader,
> adding visual effects during loading and direct drive control.

---

## 21.1 Why a custom loader?

So far we have loaded programs with:

```
LOAD"NAME",8,1
SYS 32768
```

This works, but has limitations:

- **Black screen** during loading
- **No feedback** for the user
- **Standard speed** (about 400 bytes/s)
- **Depends on KERNAL** — no drive control

A custom loader solves all this:
- Progress bars or raster bars during load
- Visual effects (animated border color)
- Possible transfer speedup
- Total process control

---

## 21.2 The KERNAL Load

The KERNAL loading routine is `SETNAM` + `SETLFS` + `LOAD`.

```asm
; Load a file with the KERNAL
*= $C000

    ; File name
    LDA #6             ; name length
    LDX #<FILENAME     ; low address
    LDY #>FILENAME     ; high address
    JSR $FFBD          ; SETNAM

    ; Device parameters
    LDA #1             ; logical file number
    LDX #8             ; device number (8 = drive)
    LDY #1             ; command (0=load, 1=verify, >0=load)
    JSR $FFBA          ; SETLFS

    ; Load
    LDA #0             ; 0 = load (not verify)
    LDX #<LOAD_ADDR    ; alternative address (0 = from file)
    LDY #>LOAD_ADDR
    JSR $FFD5          ; LOAD
    ; A = last byte loaded (for direct load)

    ; Execute loaded program
    JMP $C000

FILENAME
    .text "MYGAME"
```

### LOAD parameters ($FFD5)

| Register | Meaning |
|---|---|
| A | 0 = load, 1 = verify |
| X | Low byte of alternative address |
| Y | High byte of alternative address |
| (XY=0) | Use the address saved in the .prg file |

---

## 21.3 Raster Effect During Loading

The problem is that `JSR $FFD5` blocks the CPU until the load finishes.
We cannot execute code during the transfer... **unless we use
an IRQ interrupt that keeps running**.

```asm
; Loader with raster bar in background
; IRQ keeps working during KERNAL LOAD

*= $C000

    ; Setup IRQ for raster bar
    SEI
    LDA #<MY_IRQ
    STA $0314
    LDA #>MY_IRQ
    STA $0315
    LDA #100
    STA $D012
    LDA #1
    STA $D01A
    CLI

    ; Call KERNAL LOAD (IRQ keeps running)
    LDA #6
    LDX #<FNAME
    LDY #>FNAME
    JSR $FFBD
    LDA #1
    LDX #8
    LDY #1
    JSR $FFBA
    LDA #0
    LDX #0
    LDY #0
    JSR $FFD5          ; Load — IRQ active during!

    ; Load finished, disable IRQ
    SEI
    LDA #$7F
    STA $DC0D
    LDA #0
    STA $D01A
    CLI

    ; Jump to loaded game
    JMP $C000

MY_IRQ
    INC $D020          ; Change border color
    LDA $D019
    STA $D019          ; ACK
    RTI

FNAME
    .text "MYGAME"
```

**Note:** Not all drive systems support IRQ during KERNAL LOAD
(JiffyDOS does, stock 1541 sometimes does not). Test on real hardware.

---

## 21.4 Sector-by-Sector Loading

For total control, we must talk directly to the drive via serial.
We use KERNAL routines for IEC communication:

```asm
; Read a sector from disk
*= $C000

    ; Open command channel to drive
    LDA #0
    LDX #8
    LDY #15            ; channel 15 = command
    JSR $FFBA          ; SETLFS
    LDA #$1F
    LDX #<CMD
    LDY #>CMD
    JSR $FFBD          ; SETNAM
    JSR $FFC0          ; OPEN
    ; Now we can send commands to the drive

    ; Open read channel
    LDA #2
    LDX #8
    LDY #2             ; channel 2
    JSR $FFBA
    LDA #0             ; no name
    JSR $FFBD
    JSR $FFC0          ; OPEN channel 2

    ; Read 254 bytes from channel
    LDX #2             ; channel 2
    JSR $FFC6          ; CHKIN
    LDY #0
READ_LOOP
    JSR $FFE4          ; CHRIN (reads a byte)
    STA $C000,Y
    INY
    CPY #254
    BNE READ_LOOP

    JSR $FFCC          ; CLRCHN
    RTS

CMD
    .null "UI"         ; command: drive reset
```

---

## 21.5 Turbo Loader — Basic Concept

A turbo loader speeds up transfer by modifying the serial protocol:

```
Standard KERNAL speed:   ~400 bytes/s
Turbo loader speed:     ~2000-4000 bytes/s
```

The trick: instead of using KERNAL routines (`$FFE4`), write directly
to CIA ports for serial communication, reducing wait cycles.

```asm
; Fast byte read from drive (schematic)
; NOTE: simplified code — a real turbo loader requires
;       synchronization with the drive which must be
;       programmed itself (often with a second loader on the drive)

FAST_READ
    ; Clock line low -> drive sends data
    LDA $DD00         ; serial port
    AND #$10          ; mask DATA line
    BEQ BIT_ZERO
    ; Here bit = 1
    ROL TEMP
    JMP NEXT_BIT
BIT_ZERO
    ; Here bit = 0
    ROR TEMP
NEXT_BIT
    ; ... repeat for 8 bits ...
    LDA TEMP
    RTS
```

---

## 21.6 Loader with Visual Feedback

A "classy" loader shows something on screen while loading:

```asm
; Loader with progress bar
*= $C000

    ; Prepare loading screen
    JSR SETUP_SCREEN

    ; Open file
    LDA #6
    LDX #<FNAME
    LDY #>FNAME
    JSR $FFBD
    LDA #1
    LDX #8
    LDY #1
    JSR $FFBA

    ; Load (with IRQ setup for the effect)
    SEI
    LDA #<LOAD_IRQ
    STA $0314
    LDA #>LOAD_IRQ
    STA $0315
    LDA #50
    STA $D012
    LDA #1
    STA $D01A
    CLI

    LDA #0
    LDX #0
    LDY #0
    JSR $FFD5

    ; Cleanup
    SEI
    LDA #$7F
    STA $DC0D
    LDA #0
    STA $D01A
    CLI

    JMP $C000

LOAD_IRQ
    ; Progress bar: expand a colored rectangle
    INC $D020
    LDA FRAME
    CLC
    ADC #40
    STA FRAME
    ; Color one more cell each IRQ
    LDX FRAME
    LDA #1
    STA $D800,X
    LDA $D019
    STA $D019
    RTI

FRAME
    .byte 0

FNAME
    .text "MYGAME"

SETUP_SCREEN
    ; Write "LOADING..."
    LDX #0
LOOP
    LDA LOADMSG,X
    STA $0400+40*12+5,X
    LDA #1
    STA $D800+40*12+5,X
    INX
    CPX #20
    BNE LOOP
    ; Draw progress bar border
    LDX #0
BAR
    LDA #102
    STA $0400+40*14,X
    LDA #5
    STA $D800+40*14,X
    INX
    CPX #40
    BNE BAR
    RTS

LOADMSG
    .text "LOADING..."
```

---

## 21.7 Complete Game Structure with Loader

```
 Disk:
 ┌─────────────────────────────────────┐
 │  BOOT LOADER (1 block)              │
 │  Loads and launches the MAIN LOADER │
 │  with effects                       │
 ├─────────────────────────────────────┤
 │  MAIN LOADER (10-20 blocks)         │
 │  - Loading screen                   │
 │  - Raster/bar effects               │
 │  - Loads the GAME                   │
 ├─────────────────────────────────────┤
 │  GAME (100-200 blocks)              │
 │  - Code                             │
 │  - Sprite data                      │
 │  - Maps                             │
 │  - SID music                        │
 └─────────────────────────────────────┘
```

### Boot Code (first load)

```asm
; Boot loader — loads with LOAD"*",8,1
; then loads the real loader
*= $801

    ; Print message
    LDX #0
MSG
    LDA TEXT,X
    BEQ SKIP
    JSR $FFD2
    INX
    JMP MSG
SKIP
    ; Load the main loader
    LDA #10            ; name length
    LDX #<FNAME
    LDY #>FNAME
    JSR $FFBD
    LDA #1
    LDX #8
    LDY #1
    JSR $FFBA
    LDA #0
    LDX #0
    LDY #0
    JSR $FFD5          ; load "LOADER.PRG"

    ; Jump to loader
    JMP $C000

TEXT
    .byte 147          ; CLR/HOME
    .text "LOADING..."
    .byte 13,0

FNAME
    .text "LOADER.PRG"
```

---

## 21.8 Summary — Loader Checklist

- [ ] Decide whether to use KERNAL LOAD (simple) or direct serial (complex)
- [ ] Prepare loading screen with message
- [ ] Add visual effect (raster bar, animated border, progress bar)
- [ ] Keep IRQ active during loading
- [ ] When done, disable IRQ and jump to game
- [ ] For large games: multi-load structure (boot -> loader -> game)
- [ ] Test on real hardware (not just emulator)
- [ ] Verify drive compatibility (1541, 1571, 1581, SD2IEC)

---

## Exercises

### Exercise 1
Write a KERNAL loader that loads a file called "GAME.PRG" and executes it.

### Exercise 2
Add a raster bar effect to the loader from exercise 1 (border color cycling during load).

### Exercise 3
Create a loading screen with "LOADING..." and a progress bar made of `$A0` characters.

### Exercise 4
Structure a game into 3 separate files: boot loader, loader with effects, and actual game. Write the boot code that loads the loader.

### Exercise 5
Write a program that uses the serial port ($DD00) to read ONE byte from the drive, without using KERNAL routines (just to explore direct control).

---

## References

- [Chapter 7 — Raster Interrupt](07-raster-interrupt.md) — for effects during loading
- [Chapter 13 — Game States](13-score-game-states.md) — MENU/PLAY structure with loader
- [Appendix A — Tables](appendix-a-reference-tables.md) — KERNAL jump table ($FFD5, $FFBD, etc.)
- [Appendix TMP — Turbo Macro Pro](appendix-turbo-macro-pro.md) — to assemble the loader
- Commodore 64 Programmer's Reference Guide — chapter on IEC serial
