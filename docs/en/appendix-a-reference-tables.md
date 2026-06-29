# Appendix A — Reference Tables

## C64 Color Table

| Value | Color | Hexadecimal |
|---|---|---|
| 0 | Black | `$00` |
| 1 | White | `$01` |
| 2 | Red | `$02` |
| 3 | Cyan | `$03` |
| 4 | Purple | `$04` |
| 5 | Green | `$05` |
| 6 | Blue | `$06` |
| 7 | Yellow | `$07` |
| 8 | Orange | `$08` |
| 9 | Brown | `$09` |
| 10 | Light red | `$0A` |
| 11 | Dark gray | `$0B` |
| 12 | Medium gray | `$0C` |
| 13 | Light green | `$0D` |
| 14 | Light blue | `$0E` |
| 15 | Light gray | `$0F` |

---

## C64 Memory Map

| Address | Size | Description |
|---|---|---|
| `$0000`-`$00FF` | 256 bytes | Zero Page (fast RAM) |
| `$0100`-`$01FF` | 256 bytes | Stack |
| `$0200`-`$03FF` | 512 bytes | System/variable area |
| `$0400`-`$07E7` | 1000 bytes | Screen RAM (text display) |
| `$07F8`-`$07FF` | 8 bytes | Sprite pointers |
| `$0800`-`$9FFF` | — | Free RAM |
| `$A000`-`$BFFF` | — | BASIC ROM |
| `$C000`-`$CFFF` | — | RAM |
| `$D000`-`$DFFF` | — | VIC-II / SID / CIA |
| `$E000`-`$FFFF` | — | KERNAL ROM |

---

## VIC-II Registers (video)

### Main addresses

| Register | Address | Description |
|---|---|---|
| `SPRITE_X` | `$D000`-`$D00F` | X/Y coordinates sprites 0-7 |
| `SPRITE_MSB_X` | `$D010` | Bits 0-7: MSB X for sprites 0-7 |
| `VIC_CTRL1` | `$D011` | Bits 4-5: scroll Y, Bit 7: raster MSB |
| `RASTER` | `$D012` | Current/compare raster line |
| `VIC_CTRL2` | `$D016` | Bits 0-2: scroll X, Bit 3: 38/40 columns |
| `SPRITE_ENABLE` | `$D015` | Sprite enable (1 bit per sprite) |
| `SPRITE_EXPAND_Y` | `$D017` | Vertical expansion |
| `SPRITE_EXPAND_X` | `$D01D` | Horizontal expansion |
| `SPRITE_MULTICOLOR` | `$D01C` | Multicolor mode |
| `SPRITE_BG_PRIO` | `$D01B` | Sprite/background priority |
| `SPRITE_COL_0` | `$D025` | Common multicolor 0 |
| `SPRITE_COL_1` | `$D026` | Common multicolor 1 |
| `SPRITE_COLOR` | `$D027`-`$D02E` | Sprite colors 0-7 |
| `BORDER_COLOR` | `$D020` | Border color |
| `BG_COLOR` | `$D021` | Background color |
| `BG_COLOR_1` | `$D022` | Background color 1 |
| `BG_COLOR_2` | `$D023` | Background color 2 |
| `BG_COLOR_3` | `$D024` | Background color 3 |
| `IRQ_ENABLE` | `$D01A` | Interrupt enable |
| `IRQ_STATUS` | `$D019` | Interrupt status (acknowledge) |
| `SPRITE_COLL` | `$D01E` | Sprite-sprite collisions |
| `SPRITE_BG_COLL` | `$D01F` | Sprite-background collisions |
| `COLOR_RAM` | `$D800`-`$DBE7` | Character colors |

### Sprite pointers ($07F8-$07FF)

| Address | Sprite | Pointer formula |
|---|---|---|
| `$07F8` | Sprite 0 | Pointer = data_address / 64 |
| `$07F9` | Sprite 1 | — |
| `$07FA` | Sprite 2 | — |
| `$07FB` | Sprite 3 | — |
| `$07FC` | Sprite 4 | — |
| `$07FD` | Sprite 5 | — |
| `$07FE` | Sprite 6 | — |
| `$07FF` | Sprite 7 | — |

---

## SID Registers (audio)

| Address | Voice | Description |
|---|---|---|
| `$D400` | 1 | Frequency low |
| `$D401` | 1 | Frequency high |
| `$D404` | 1 | Control (gate, waveform) |
| `$D405` | 1 | Attack/Decay |
| `$D406` | 1 | Sustain/Release |
| `$D410` | 2 | Frequency low |
| `$D411` | 2 | Frequency high |
| `$D414` | 2 | Control |
| `$D415` | 2 | Attack/Decay |
| `$D416` | 2 | Sustain/Release |
| `$D420` | 3 | Frequency low |
| `$D421` | 3 | Frequency high |
| `$D424` | 3 | Control |
| `$D425` | 3 | Attack/Decay |
| `$D426` | 3 | Sustain/Release |
| `$D418` | Global | Volume (0-15) |

### Waveforms (control register)

| Value | Waveform | Description |
|---|---|---|
| `$10` | Square | Waveform only (gate OFF) |
| `$11` | Square | Square wave + gate ON |
| `$20` | Triangle | Triangle only (gate OFF) |
| `$21` | Triangle | Triangle + gate ON |
| `$40` | Sawtooth | Sawtooth only |
| `$41` | Sawtooth | Sawtooth + gate ON |
| `$80` | Noise | Noise only |
| `$81` | Noise | Noise + gate ON |

---

## CIA Registers (joystick)

| Address | Description |
|---|---|
| `$DC00` | Joystick port 2 |
| `$DC01` | Joystick port 1 |
| `$DC0D` | CIA Interrupt Control |

### Joystick port 1 bits ($DC01)

| Bit | Direction | Active |
|---|---|---|
| 0 | Up | 0 |
| 1 | Down | 0 |
| 2 | Left | 0 |
| 3 | Right | 0 |
| 4 | Button | 0 |
| 5-7 | Unused | 1 |

---

## Essential 6502 Instructions

### Data transfer

| Instruction | Description |
|---|---|
| `LDA #val` | Load immediate into A |
| `LDA addr` | Load from address into A |
| `LDX #val` | Load immediate into X |
| `LDY #val` | Load immediate into Y |
| `STA addr` | Store A to address |
| `STX addr` | Store X to address |
| `STY addr` | Store Y to address |

### Arithmetic

| Instruction | Description |
|---|---|
| `ADC #val` | A = A + val + Carry |
| `SBC #val` | A = A - val - (1-Carry) |
| `INC addr` | addr = addr + 1 |
| `DEC addr` | addr = addr - 1 |
| `INX` | X = X + 1 |
| `DEX` | X = X - 1 |
| `INY` | Y = Y + 1 |
| `DEY` | Y = Y - 1 |

### Logic

| Instruction | Description |
|---|---|
| `AND #val` | A = A AND val |
| `ORA #val` | A = A OR val |
| `EOR #val` | A = A XOR val |
| `ASL` | Shift left |
| `LSR` | Shift right |

### Compare and branches

| Instruction | Description |
|---|---|
| `CMP #val` | Compare A with val |
| `CPX #val` | Compare X with val |
| `CPY #val` | Compare Y with val |
| `BEQ label` | Branch if equal (Z=1) |
| `BNE label` | Branch if not equal (Z=0) |
| `BCC label` | Branch if Carry=0 |
| `BCS label` | Branch if Carry=1 |
| `BMI label` | Branch if negative (N=1) |
| `BPL label` | Branch if positive (N=0) |

### Stack and jumps

| Instruction | Description |
|---|---|
| `JMP label` | Unconditional jump |
| `JSR label` | Jump to subroutine |
| `RTS` | Return from subroutine |
| `RTI` | Return from interrupt |
| `PHA` | Push A onto stack |
| `PLA` | Pull A from stack |
| `TXA` | Copy X to A |
| `TYA` | Copy Y to A |
| `TAX` | Copy A to X |
| `TAY` | Copy A to Y |

### Flags

| Instruction | Description |
|---|---|
| `SEC` | Set Carry = 1 |
| `CLC` | Clear Carry = 0 |
| `SEI` | Set Interrupt disable |
| `CLI` | Clear Interrupt disable |
| `SED` | Set Decimal mode |
| `CLD` | Clear Decimal mode |

---

## Common PETSCII Codes (uppercase letters)

| Character | Code |
|---|---|
| A | 1 |
| B | 2 |
| C | 3 |
| D | 4 |
| E | 5 |
| F | 6 |
| G | 7 |
| H | 8 |
| I | 9 |
| J | 10 |
| K | 11 |
| L | 12 |
| M | 13 |
| N | 14 |
| O | 15 |
| P | 16 |
| Q | 17 |
| R | 18 |
| S | 19 |
| T | 20 |
| U | 21 |
| V | 22 |
| W | 23 |
| X | 24 |
| Y | 25 |
| Z | 26 |
| Space | 32 |
| 0-9 | 48-57 |

---

## Powers of 2

| Power | Value | Hexadecimal |
|---|---|---|
| 2^0 | 1 | `$01` |
| 2^1 | 2 | `$02` |
| 2^2 | 4 | `$04` |
| 2^3 | 8 | `$08` |
| 2^4 | 16 | `$10` |
| 2^5 | 32 | `$20` |
| 2^6 | 64 | `$40` |
| 2^7 | 128 | `$80` |
| 2^8 | 256 | `$100` |
| 2^9 | 512 | `$200` |
| 2^10 | 1024 | `$400` |
| 2^11 | 2048 | `$800` |
| 2^12 | 4096 | `$1000` |

---

## Sprite Bit Masks

```asm
; Masks for enabling/disabling sprites
SPRITE_0  = %00000001
SPRITE_1  = %00000010
SPRITE_2  = %00000100
SPRITE_3  = %00001000
SPRITE_4  = %00010000
SPRITE_5  = %00100000
SPRITE_6  = %01000000
SPRITE_7  = %10000000

; Masks for $D010 (MSB X)
MSB_SPRITE_0 = %00000001
MSB_SPRITE_1 = %00000010
; ... same pattern ...
```

---

## Useful Numbers

| Value | Decimal | Hexadecimal |
|---|---|---|
| Screen RAM start | 1024 | `$0400` |
| Screen RAM end | 2023 | `$07E7` |
| Color RAM start | 55296 | `$D800` |
| Color RAM end | 56295 | `$DBE7` |
| Sprite data size | 63 bytes | `$3F` |
| Max raster PAL | 311 | `$0137` |
| Max raster NTSC | 262 | `$0106` |
| Characters per row | 40 | `$28` |
| Screen rows | 25 | `$19` |
