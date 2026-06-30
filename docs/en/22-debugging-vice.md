# Chapter 22 — Debugging with VICE

## Objectives

By the end of this chapter you will know:

- Use the VICE assembly monitor
- Set breakpoints and watchpoints
- Step through code execution
- Inspect memory, registers, and stack
- Analyze raster timing for CPU bottlenecks
- Debug common C64 bugs

---

## 22.1 Why VICE?

VICE is the most popular C64 emulator. It includes a built-in **assembly monitor**
for inspecting and controlling execution in real time.

```
VICE monitor:      Alt+H (Windows/Linux), Cmd+H (macOS)
Monitor only:      Alt+H, or `x64sc -moncommands script.txt`
```

### Opening the monitor

From a running VICE instance:

1. Press **Alt+H** (or **Cmd+H** on macOS)
2. A terminal window opens with the prompt `(C64:1)`
3. Type commands at the prompt

Or start VICE with the monitor open:

```bash
x64sc -moncommands script.txt game.prg
```

---

## 22.2 Basic Commands

### Inspect the CPU

```
(C64:1) r              — show registers (A, X, Y, SP, PC, SR)
(C64:1) r $D012        — show only register $D012
(C64:1) x              — step over
(C64:1) z              — step into
(C64:1) g              — continue execution (go)
```

### Inspect memory

```
(C64:1) m $C000        — show memory from $C000
(C64:1) m $D000 $D010  — show range $D000-$D010
(C64:1) d $C000        — disassemble from $C000
(C64:1) d $C000 $C010  — disassemble range
```

### Breakpoints

```
(C64:1) b $C010        — stop when PC = $C010
(C64:1) bl $C010       — same breakpoint
(C64:1) b $C010 $C020  — stop when PC is in range
(C64:1) bc             — clear all breakpoints
(C64:1) bl             — list active breakpoints
```

### Watchpoints (memory read/write)

```
(C64:1) w $D012        — stop when $D012 changes
(C64:1) w $0400 $07FF  — stop on screen RAM access
(C64:1) wl $D020       — watchpoint on read
(C64:1) ws $D020       — watchpoint on write
```

---

## 22.3 Practical Example: Raster Debug

One of the most common bugs: the raster interrupt fires at the wrong line.

```asm
; Buggy program: IRQ never fires
*= $C000
    SEI
    LDA #$7F
    STA $DC0D
    LDA #<MY_IRQ
    STA $0314
    LDA #>MY_IRQ
    STA $0315
    LDA #100
    STA $D012
    LDA $D011
    AND #$7F
    STA $D011
    CLI

    LDA #$00
    STA $D020
    JMP LOOP

LOOP
    JMP LOOP

MY_IRQ
    INC $D020
    LDA $D019
    STA $D019
    RTI
```

### Step-by-step debug

1. Load the program in VICE
2. Open the monitor (Alt+H)
3. Set a breakpoint at `MY_IRQ`: `b $C01B` (adjust address)
4. Type `g` to continue
5. When the breakpoint triggers, check:
   - `r` — is the raster line correct? Register $D012 should be 100
   - If IRQ never fires, `$D01A` was probably not set

### Common bug: missing $D01A

```asm
; BUG: missing LDA #1 / STA $D01A
; The IRQ will never fire!
```

Fix: add `LDA #1 : STA $D01A` after setup.

---

## 22.4 Video Memory Debug

Problem: a character does not appear on screen.

```
(C64:1) m $0400        — show screen RAM
(C64:1) m $D800        — show color RAM
(C64:1) m $07F8 $07FF  — show sprite pointers
(C64:1) m $2000 $2020  — show sprite data (if at $2000)
```

### Example: invisible sprite

If a sprite does not appear:

1. Check `$D015` (sprite enable): `m $D015`
2. Check `$D010` (MSB X): `m $D010`
3. Check `$D000-$D00F` (positions): `m $D000 $D00F`
4. Check `$07F8` (pointer): `m $07F8`
5. Verify the data is there: calculate pointer * 64 and look

```
Sprite pointer = value in $07F8
Data address = pointer * 64
Example: $07F8 = $80 → data at $80 * 64 = $2000
```

---

## 22.5 Collision Debug

VIC-II has status registers for collisions:

```
$D01E — sprite-sprite collisions
$D01F — sprite-background collisions
```

To debug:

```
(C64:1) b $C010         — break after reading $D01E
(C64:1) g               — continue
— on hit:
(C64:1) r               — check A (should contain result)
(C64:1) m $D01E         — read collision register
```

---

## 22.6 Timing Analysis (Raster)

Use the border color to measure CPU time:

```asm
; Raster debug: turn border on at start, off at end
DEBUG_START
    LDA #2
    STA $D020           ; red border at start

    ; ... code to measure ...

    LDA #0
    STA $D020           ; black border at end
```

In VICE, look at the colored bar on the right side of the screen:
- If it is wide, the code consumes many cycles
- If it extends past the visible area, you have exceeded the frame (50 Hz)

---

## 22.7 Stack Debug

Problem: crash with `RTS` jumping into the middle of nowhere.

```
(C64:1) m $0100 $01FF  — show stack
(C64:1) r              — check SP (stack pointer)
```

The stack is at $0100-$01FF. If SP is below $80, you probably have
too many PHA without PLA.

### Example: stack overflow

```asm
; BUG: recursive calls without guard
BUG_RECURSE
    JSR BUG_RECURSE     ; each call uses 2 bytes of stack
    RTS
```

This fills the stack in seconds. Symptom: `RTS` jumps to random addresses.

Debug:
```
(C64:1) b $0100         — breakpoint on low stack (rare)
— better:
(C64:1) bl $0100 $01FF  — breakpoint on stack range
```

---

## 22.8 Advanced Commands

### Disassembly with inline assembly

```
(C64:1) d $C000 $C020  — disassemble 32 bytes
(C64:1) a $C000        — assemble at $C000 (entry mode)
LDA #$01               — type instructions
STA $D020
JMP $C000
.                      — dot to exit
```

### I/O and save

```
(C64:1) l "dump.bin" $C000 $C010  — save memory to file
(C64:1) s "program" 8              — save to real/attached disk
```

### Hot patching

```
(C64:1) a $C000
NOP                    — replace JSR with NOP to skip a call
NOP
NOP
.
— or memory edit:
(C64:1) m $C000
:C000 20 0D C0  → EA EA EA   (replace JSR $C00D with NOPs)
```

---

## Summary — VICE Commands

| Command | Action |
|---|---|
| `r` | Show CPU registers |
| `m $addr` | Show memory |
| `d $addr` | Disassemble |
| `b $addr` | Breakpoint on execution |
| `w $addr` | Watchpoint on access |
| `wl $addr` | Watchpoint on read |
| `ws $addr` | Watchpoint on write |
| `g` | Continue execution |
| `x` | Step over |
| `z` | Step into |
| `bc` | Clear breakpoints |
| `bl` | List breakpoints |
| `l "file" $start $end` | Save memory to file |

---

## Exercises

### Exercise 1
Load a program in VICE, set a breakpoint at $C000 and use `r`, `m`, `d` to inspect CPU state and memory.

### Exercise 2
Write a small program that flashes the border with `INC $D020` in a loop.
Set a watchpoint on $D020 and observe when it changes.

### Exercise 3
Take the code from chapter 7 (raster IRQ) and intentionally remove `LDA #1 : STA $D01A`. Use VICE to discover why the IRQ does not fire.

### Exercise 4
Use border raster timing to measure how many CPU cycles a loop that writes 100 bytes to screen RAM consumes. Compare with an optimized loop (using `LDX`/`STX` instead of `LDA`/`STA`).

### Exercise 5
Simulate a stack overflow with recursive calls and use the VICE monitor to observe the stack filling up ($0100-$01FF).

---

## References

- [VICE Monitor Manual](https://vice-emu.sourceforge.io/vice_15.html)
- [Chapter 7 — Raster Interrupt](07-raster-interrupt.md) — IRQ setup for debugging
- [Chapter 4 — Video Memory](04-video-memory-characters.md) — screen RAM for visual debug
- [Solutions](../soluzioni/cap22-debugging.asm) — debug examples
