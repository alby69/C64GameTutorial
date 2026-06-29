# Chapter 25 — Turbo Loader

## Objectives

By the end of this chapter you will know:

- Understand the GCR format of the 1541 disk drive
- Read bytes directly from the serial bus ($DD00)
- Implement an IRQ loader that loads during raster
- Use the parallel cable for fast transfers
- Integrate a fast loader into the game

---

## 25.1 Why a Turbo Loader?

The KERNAL LOAD (`$FFD5`) is slow because it uses the standard serial
protocol at about 400 bytes/sec. A turbo loader can reach
2-4 KB/sec by reading raw data from disk (GCR).

```
KERNAL LOAD:  ~400 bytes/sec
Fast loader:  ~2000-4000 bytes/sec (5-10x faster)
```

---

## 25.2 The C64 Serial Bus ($DD00)

The C64 communicates with the 1541 drive via CIA2, serial port at `$DD00`.

```asm
; Read serial bus status
SERIAL_PORT = $DD00

; Serial bus bits:
;   bit 0-1: VIC-II bank
;   bit 2:   ATN out
;   bit 3:   CLK out
;   bit 4:   DATA out
;   bit 5:   CLK in
;   bit 6:   DATA in
;   bit 7:   —
```

To read a bit from the drive:

```asm
; Read DATA line
LDA $DD00
AND #$40          ; bit 6 = DATA in
BNE BIT_HIGH
```

---

## 25.3 GCR Format

The 1541 stores data in GCR (Group Code Recording):
every 4 bits of data become 5 GCR bits.

```
Data nibble → GCR
0000 → 01010
0001 → 01011
0010 → 10010
0011 → 10011
0100 → 01110
0101 → 01111
0110 → 10110
0111 → 10111
1000 → 01001
1001 → 11001
1010 → 11010
1011 → 11011
1100 → 01101
1101 → 11101
1110 → 11110
1111 → 11111
```

GCR decode table (256 bytes):

```asm
GCR_DECODE
    .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .byte $FF,     ; 00100000
    .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .byte $FF, $08 ; 00101000 = 1000
    .byte $FF, $09 ; 00101001 = 1001
    .byte $FF, $0A ; 00101010 = 1010
    .byte $FF, $0B ; 00101011 = 1011
    ; ... (full table: index = GCR byte, value = data nibble)
```

---

## 25.4 IRQ Loader

An IRQ loader loads data during frames without blocking the game:

```asm
; IRQ loader — load one byte per frame
IRQ_LOADER
    ; State 0: find sync mark
    LDA LOAD_STATE
    CMP #0
    BEQ IL_SYNC
    CMP #1
    BEQ IL_BYTE
    RTS

IL_SYNC
    ; Find sync (bits 1)
    LDA $DD00
    AND #$40
    BNE IL_SYNC
    INC LOAD_STATE
    RTS

IL_BYTE
    ; Read 8 GCR bits
    LDX #8
IL_BIT
    LDA $DD00
    AND #$40
    BEQ IL_ZERO
    ; Bit = 1
    ROL TEMP
    SEC
    JMP IL_NEXT
IL_ZERO
    ; Bit = 0
    ROL TEMP
    CLC
IL_NEXT
    DEX
    BNE IL_BIT

    ; Decode GCR and save to buffer
    LDY LD_PTR
    LDA TEMP
    STA GCR_BUF,Y
    INY
    STY LD_PTR
    LDA #0
    STA LOAD_STATE

    ; If buffer full, exit
    CPY #$FF
    BEQ IL_DONE
    RTS

IL_DONE
    LDA #$FF
    STA LOAD_DONE
    RTS

LOAD_STATE
    .byte 0
LD_PTR
    .byte 0
LOAD_DONE
    .byte 0
GCR_BUF
    .byte 0
```

---

## 25.5 Parallel Cable

The parallel cable (or X1541 cable) connects the drive data lines
directly to the C64 user port ($A000-$A003),
allowing 8-bit transfers.

```asm
; Parallel cable read
PARALLEL_READ
    LDA $A001          ; User port data lines
    ; A now contains a full byte (8 bits)
    RTS
```

The parallel cable requires additional hardware but can reach
8-10 KB/sec.

---

## 25.6 Fast Loader in the Game

In the game loop, levels can be loaded in the background:

```asm
FAST_LOAD_TICK
    LDA LOAD_DONE
    BNE FLT_DONE

    JSR IRQ_LOADER

    ; Update progress bar
    LDX LD_BYTE_COUNT
    LDA #$A0
    STA SCREEN_RAM+40*23,X
    LDA #5
    STA COLOR_RAM+40*23,X

FLT_DONE
    RTS
```

---

## 25.7 Performance Comparison

```
Method                           Speed
──────────────────────────────────────────
KERNAL LOAD ($FFD5)              ~400 bytes/s
IRQ loader (GCR)                 ~1200 bytes/s
Optimized GCR fast loader        ~2500 bytes/s
Parallel cable                   ~8000 bytes/s
```

---

## Exercises

### Exercise 1
Write a subroutine that reads one byte from the serial bus ($DD00) using
the DATA in bit (bit 6). GCR decoding is not required yet.

### Exercise 2
Implement the GCR decode table and use it to convert
a GCR byte read from the serial bus into a nibble (4 bits).

### Exercise 3
Build an IRQ loader that loads one byte per frame in the background,
without blocking the game loop. Use a circular buffer.

### Exercise 4
Integrate the fast loader into the game: during the title screen or
between levels, show a progress bar.

### Exercise 5
Compare the speed of KERNAL LOAD with your fast loader:
how long does each take to load 8 KB?

---

## References

- [Chapter 21 — Custom Loader](21-custom-loader.md) — KERNAL LOAD/SAVE basics
- [$DD00 — CIA2](appendix-a-reference-tables.md) — serial port
- [Solutions](../soluzioni/cap25-turbo-loader.asm) — exercise solutions
