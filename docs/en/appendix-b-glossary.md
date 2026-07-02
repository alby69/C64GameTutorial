# Appendix B — Glossary

## A

**A (Accumulator)** — The main register of the 6502. Most arithmetic and logic operations use A.

**ADC** — Add with Carry. Adds a value to A taking the Carry flag into account.

**Addressing mode** — The way an instruction specifies the data to use (immediate, absolute, indexed, etc.).

**Arcade OS** — A kernel concept that treats the game as a scheduled process, with the raster interrupt as the main clock.

**ASCII** — American Standard Code for Information Interchange. Not used directly on the C64, which uses PETSCII.

## B

**BCC** — Branch if Carry Clear. Branches if the Carry flag = 0.

**BCS** — Branch if Carry Set. Branches if the Carry flag = 1.

**BEQ** — Branch if EQual. Branches if the Zero flag = 1 (result = 0).

**BMI** — Branch if Minus. Branches if the Negative flag = 1.

**BNE** — Branch if Not Equal. Branches if the Zero flag = 0.

**Bounding box** — An imaginary rectangle around a sprite used to detect collisions.

**BPL** — Branch if PLus. Branches if the Negative flag = 0.

**Branch** — Conditional jump. Jumps to another part of the code only if a condition is true.

**Byte** — 8 bits. Basic unit of memory. Can represent values from 0 to 255 ($00-$FF).

## C

**C64** — Commodore 64. 8-bit home computer from 1982 with a 6510 CPU at ~1 MHz and 64 KB of RAM.

**Carry** — CPU flag used in arithmetic operations and comparisons.

**Character** — Displayable letter, number, or symbol on screen. The C64 uses PETSCII encoding.

**CIA** — Complex Interface Adapter. Chip that handles joystick, timers, and I/O.

**CLC** — Clear Carry. Sets the Carry flag to 0.

**CLI** — Clear Interrupt. Re-enables interrupts after a SEI.

**CMP** — CoMPare. Compares A with a value, setting flags without modifying A.

**Collision detection** — Detecting when two sprites or objects touch each other.

**CPX** — Compare X. Compares X with a value.

**CPY** — Compare Y. Compares Y with a value.

**CPU** — Central Processing Unit. The processor.

**Cycle** — CPU clock cycle. The 6510 at 1 MHz executes about 1 million cycles per second.

## D

**DEC** — DECrement. Decreases the value in memory by 1.

**DEX** — DEcrement X. X = X - 1.

**DEY** — DEcrement Y. Y = Y - 1.

**Directive** — An instruction for the assembler (e.g. `*=$C000`, `.byte`), not for the CPU.

## E

**Edge detection** — A technique for detecting the exact moment a key is pressed (not whether it is held down).

**Entity** — A logical object in the game (player, enemy, projectile) with position, state, and type.

**EOR** — Exclusive OR. XOR logic operation.

## F

**Flag** — A special CPU bit that indicates a condition (Zero, Carry, Negative, Interrupt, etc.).

**Flicker** — Visible flickering when a sprite is updated at the wrong raster moment.

**Frame** — A complete image on screen. PAL = 50 frames/sec, NTSC = 60 frames/sec.

**Frame counter** — A variable incremented every frame to time game events.

## G

**Gate** — Bit 0 of the SID control register. 1 = note on, 0 = note off.

## H

**HUD** — Heads-Up Display. On-screen information (score, lives, health bar).

**HW** — Hardware. Physical computer components.

## I

**INC** — INCrement. Increases the value in memory by 1.

**Indexed addressing** — An addressing mode where the effective address is the sum of a base address + X or Y register.

**INX** — INcrement X. X = X + 1.

**INY** — INcrement Y. Y = Y + 1.

**IRQ** — Interrupt ReQuest. A signal that temporarily stops the CPU to execute a special routine.

**ISR** — Interrupt Service Routine. The routine executed when an interrupt arrives.

## J

**JMP** — JuMP. Unconditional jump to an address.

**JSR** — Jump to SubRoutine. Jumps to a subroutine, saving the return address on the stack.

**Joystick** — Game controller. On the C64 it is read via CIA at ports `$DC00` and `$DC01`.

## K

**KERNAL** — The C64 operating system in ROM. Manages I/O, screen, keyboard, etc.

**Kernel engine** — The fixed part of the code that handles timing, interrupts, and basic services.

## L

**Label** — A symbolic name representing a memory address (e.g. `START`, `LOOP`).

**LDA** — LoaD Accumulator. Loads a value into register A.

**LDX** — LoaD X. Loads a value into register X.

**LDY** — LoaD Y. Loads a value into register Y.

## M

**Memory map** — A map of how the C64 memory is organized.

**MSB** — Most Significant Bit. The highest bit (bit 7 of a byte).

**Multiplexing** — A technique to display more than 8 sprites by reusing HW sprites across different screen zones.

## N

**Negative** — CPU flag. Set when the result of an operation has bit 7 = 1.

**Noise** — SID waveform that produces white noise. Used for explosions and effects.

## O

**ORG** — Assembler directive that specifies the address to generate code at (`*=$C000`).

## P

**PAL** — Phase Alternating Line. European video standard: 50 frames/sec, 312 raster lines.

**Parallax** — Depth illusion achieved by moving screen layers at different speeds.

**PETSCII** — Commodore character code. Different from standard ASCII.

**PHA** — PusH Accumulator. Saves A onto the stack.

**PHP** — PusH Processor status. Saves the flags onto the stack.

**PLA** — PulL Accumulator. Recovers A from the stack.

**PLP** — PulL Processor status. Recovers the flags from the stack.

**Pointer** — A 2-byte address (low/high) pointing to a memory location.

**Pool** — A static array of reusable objects (e.g. bullet pool).

**Pseudo-AI** — A simulated behavior that appears intelligent but follows deterministic rules.

## R

**RAM** — Random Access Memory. Readable and writable working memory.

**Raster** — The electron beam that draws the screen one line at a time.

**Raster interrupt** — An interrupt generated by the VIC-II when the raster reaches a specific line.

**Raster line** — A single horizontal line on the screen.

**Raster split** — A technique for dividing the screen into zones with different VIC-II register values.

**ROM** — Read Only Memory. Read-only memory (contains BASIC and KERNAL).

**RTI** — ReTurn from Interrupt. Ends an interrupt routine.

**RTS** — ReTurn from Subroutine. Ends a subroutine and returns to the caller.

## S

**SBC** — SuBtract with Carry. Subtracts a value from A taking the Carry flag into account.

**Screen RAM** — Memory area `$0400`-`$07E7` containing the displayed characters.

**SEI** — SEt Interrupt. Temporarily disables interrupts.

**SID** — Sound Interface Device. The C64 3-voice audio chip.

**Sprite** — An independent 24x21 pixel image that the VIC-II draws without redrawing the screen.

**Sprite pointer** — A byte in `$07F8`-`$07FF` indicating the address of sprite data (address/64).

**Square wave** — SID waveform. Full sound, used for melodies and effects.

**Stack** — Memory area `$0100`-`$01FF` for storing return addresses and temporary data.

**STA** — STore Accumulator. Writes the contents of A to memory.

**State machine** — A behavior model with well-defined states and transitions.

**SW** — Software. Programs and code.

## T

**TAX** — Transfer A to X. Copies A to X.

**TAY** — Transfer A to Y. Copies A to Y.

**TMP** — Turbo Macro Pro. C64 assembler with built-in editor.

**Triangle** — SID waveform. Softer sound, used for effects.

**TXA** — Transfer X to A. Copies X to A.

**TYA** — Transfer Y to A. Copies Y to A.

## V

**VIC-II** — Video Interface Controller. The C64 graphics chip handling sprites, screen, raster, etc.

## W

**Wave** — Enemy wave in the game. A system managing spawn and progression.

**Waveform** — SID waveform (square, triangle, sawtooth, noise).

## X

**X** — 6502 index register. Used as a counter or offset.

## Y

**Y** — Second 6502 index register.

## Z

**Zero flag** — CPU flag. Activated when the result of an operation is 0.

**Zero Page** — The first 256 bytes of memory (`$0000`-`$00FF`). Faster access.

---

## Symbols

`$` — Prefix for hexadecimal numbers in TMP (e.g. `$FF` = 255).

`#` — Prefix for immediate values (e.g. `LDA #$10`).

`%` — Prefix for binary numbers (e.g. `%00000001`).

`*=` — ORG directive in TMP (e.g. `*=$C000`).
