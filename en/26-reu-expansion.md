# Chapter 26 — REU (RAM Expansion Unit)

## Objectives

By the end of this chapter you will know:

- What the REU 1700/1750/1764 is
- Use the DMA controller to copy data rapidly
- Expand C64 memory beyond 64 KB
- Implement bank swapping for huge levels
- Use REU for persistent data storage

---

## 26.1 What is the REU?

The RAM Expansion Unit (REU) adds RAM to the C64 via the cartridge port.
Three versions exist:

```
Model     | RAM    | Notes
─────────────────────────────────
1700      | 128 KB | First version
1750      | 512 KB | Most common
1764      | 256 KB | For C64C
```

The REU appears at address range `$DF00-$DF0F` and uses
DMA (Direct Memory Access) to transfer blocks between
the REU and main RAM without CPU involvement.

---

## 26.2 REU Registers ($DF00-$DF0F)

| Address | Name | Description |
|---------|------|-------------|
| `$DF00` | `COMMAND` | Command (bit 7=start, bit 6=dir, bit 4=FF00 mode, bit 0=3: autoload) |
| `$DF01` | `STATUS` | Status (bit 7=end block, bit 6=fault, bit 1=handshake, bit 0=BSY) |
| `$DF02` | `REU_ADDR_L` | REU address low |
| `$DF03` | `REU_ADDR_H` | REU address high |
| `$DF04` | `REU_ADDR_B` | REU bank (256 KB blocks) |
| `$DF05` | `C64_ADDR_L` | C64 address low |
| `$DF06` | `C64_ADDR_H` | C64 address high |
| `$DF07` | `C64_ADDR_B` | C64 bank (64 KB blocks) |
| `$DF08` | `LENGTH_L` | Transfer length low |
| `$DF09` | `LENGTH_H` | Transfer length high |
| `$DF0A` | `IRQ_MASK` | Interrupt mask |
| `$DF0B` | `CONTROL` | Control (bit 6=FF00, bit 4=Int, bit 3=dep, bit 2=IE) |

---

## 26.3 Copying Data Between REU and C64

### C64 → REU (save)

```asm
; Save 256 bytes from $C000 to REU address $000000
*= $C000

    ; REU address = $000000
    LDA #0
    STA $DF02          ; REU_ADDR_L
    STA $DF03          ; REU_ADDR_H
    STA $DF04          ; REU_ADDR_B

    ; C64 address = $C000
    LDA #$00
    STA $DF05          ; C64_ADDR_L
    LDA #$C0
    STA $DF06          ; C64_ADDR_H
    LDA #0
    STA $DF07          ; C64_ADDR_B

    ; Length = 256 bytes ($00 = 256)
    LDA #0
    STA $DF08          ; LENGTH_L
    STA $DF09          ; LENGTH_H

    ; Command: write C64 → REU
    ; bit 7=1 (start), bit 6=0 (C64→REU, not FF00)
    LDA #%10000000
    STA $DF00          ; COMMAND

    RTS
```

### REU → C64 (load)

```asm
; Load 256 bytes from REU ($000000) to $C000
*= $C000

    LDA #0
    STA $DF02
    STA $DF03
    STA $DF04
    STA $DF07
    LDA #$00
    STA $DF05
    LDA #$C0
    STA $DF06
    LDA #0
    STA $DF08
    STA $DF09

    ; Command: bit 7=1 (start), bit 6=1 (REU→C64)
    LDA #%11000000
    STA $DF00

    RTS
```

---

## 26.4 Waiting for DMA

DMA takes time. Wait for completion:

```asm
; Wait for DMA completion
WAIT_DMA
    LDA $DF01          ; STATUS register
    AND #%00000001     ; bit 0 = busy
    BNE WAIT_DMA       ; busy → wait
    RTS
```

---

## 26.5 Bank Swapping for Levels

With a 512 KB REU you can hold 8 levels of 64 KB:

```
Level 1 → REU $000000-$00FFFF
Level 2 → REU $010000-$01FFFF
...
Level 8 → REU $070000-$07FFFF
```

```asm
; Load level N from REU
; Input: A = level number (0-7)
LOAD_LEVEL
    STA TEMP
    ASL
    ROL
    STA $DF04          ; REU_ADDR_B = level * $10000 >> 16

    LDA #0
    STA $DF02
    STA $DF03
    STA $DF05
    STA $DF06
    STA $DF07
    STA $DF08
    STA $DF09

    ; Start DMA REU→C64
    LDA #%11000000
    STA $DF00

    JSR WAIT_DMA
    RTS

TEMP
    .byte 0
```

---

## 26.6 Using REU for Data Storage

Instead of saving to disk, REU can hold data between sessions
(if the REU remains powered).

```asm
; Save game state to REU
SAVE_GAME_STATE
    LDA #0
    STA $DF02
    STA $DF03
    STA $DF04

    LDA #<GAME_VARS
    STA $DF05
    LDA #>GAME_VARS
    STA $DF06

    LDA #64
    STA $DF08
    LDA #0
    STA $DF09

    LDA #%10000000     ; C64 → REU
    STA $DF00
    JSR WAIT_DMA
    RTS
```

---

## 26.7 Limitations

- Requires REU hardware (not common)
- C64C with REU 1764 needs an upgraded power supply
- Not all games support REU
- REU 1700 has only 128 KB (2 banks of 64 KB)

---

## Exercises

### Exercise 1
Write a routine that copies 256 bytes from $C000 to REU address $000000.

### Exercise 2
Write the inverse routine: load 512 bytes from REU ($001000) to $A000.

### Exercise 3
Implement WAIT_DMA and use it to copy data synchronously.

### Exercise 4
Create a 4-level system in REU: when the player advances to the next
level, load it from REU instead of disk.

### Exercise 5
Use REU to save the complete game state (score, level, player position)
and reload it after a reset (REU retains data).

---

## References

- [Chapter 21 — Custom Loader](21-custom-loader.md) — disk load vs REU
- [$DF00-$DF0F — REU registers](appendix-a-reference-tables.md) — register map
- [Solutions](../soluzioni/cap26-reu-expansion.asm) — exercise solutions
