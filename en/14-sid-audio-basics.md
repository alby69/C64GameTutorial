# Chapter 14 — SID Audio: First Sounds

## Objectives

By the end of this chapter you will know:

- How the C64's SID chip works
- Set frequency, volume, and waveform
- Create a simple "beep"
- Generate basic sound effects (shot, explosion)
- Avoid blocking the game during playback

---

## 14.1 The SID chip

The SID (Sound Interface Device) is mapped to registers `$D400`-`$D41C`. It has 3 independent voices.

```
$D400 ┌──────────────────────┐
       │ Voice 1              │
$D40F │                      │
      ├──────────────────────┤
$D410 │ Voice 2              │
$D41F │                      │
      ├──────────────────────┤
$D420 │ Voice 3              │
$D42F │                      │
      ├──────────────────────┤
$D418 │ Global volume         │
      └──────────────────────┘
```

### Voice 1 registers

| Address | Name | Purpose |
|---|---|---|
| `$D400` | FREQ_LO | Low frequency (0-255) |
| `$D401` | FREQ_HI | High frequency (0-255) |
| `$D404` | CTRL | Gate, waveform, test |
| `$D405` | AD | Attack/Decay |
| `$D406` | SR | Sustain/Release |
| `$D418` | VOL | Global volume (0-15) |

### Waveforms (`$D404` register)

```
Bit: 7  6  5  4  3  2  1  0
     -  -  N  T  S  R  G  -
         |  |  |  |  |
         |  |  |  |  +── Gate (1=note active)
         |  |  |  +───── Ring modulation
         |  |  +──────── Sync
         |  +─────────── Triangle
         +────────────── Noise

Common values:
$11 = Square wave + Gate ON
$21 = Triangle + Gate ON
$81 = Noise + Gate ON
$10 = Square only (Gate OFF)
```

---

## 14.2 First sound

The simplest program to hear something:

```asm
*=$C000

START
    LDA #$20        ; frequency
    STA $D400       ; FREQ_LO
    LDA #$10
    STA $D401       ; FREQ_HI

    LDA #$11        ; square wave + gate ON
    STA $D404       ; CTRL

    LDA #$0F        ; max volume
    STA $D418       ; VOL

LOOP
    JMP LOOP        ; continuous sound
```

---

## 14.3 Turning off sound

To turn off a note, clear the GATE bit (bit 0):

```asm
; Turn on
LDA #$11
STA $D404

; ... time ...

; Turn off
LDA #$10           ; waveform only, GATE = 0
STA $D404
```

---

## 14.4 Single beep

```asm
PLAY_BEEP
    LDA #$30
    STA $D400
    LDA #$15
    STA $D401
    LDA #$11
    STA $D404       ; turn on

    JSR DELAY

    LDA #$10
    STA $D404       ; turn off
    RTS

DELAY
    LDX #$30
D1
    LDY #$FF
D2
    DEY
    BNE D2
    DEX
    BNE D1
    RTS
```

---

## 14.5 Laser shot effect

```asm
LASER_SOUND
    LDA #$80
    STA $D400
    LDA #$30
    STA $D401
    LDA #$11
    STA $D404       ; turn on square

    JSR SHORT_DELAY

    LDA #$10
    STA $D404       ; turn off
    RTS

SHORT_DELAY
    LDX #$08
SD1
    LDY #$FF
SD2
    DEY
    BNE SD2
    DEX
    BNE SD1
    RTS
```

---

## 14.6 Explosion effect (noise)

```asm
EXPLOSION_SOUND
    ; Low frequency
    LDA #$10
    STA $D400
    LDA #$05
    STA $D401

    ; Noise wave + gate
    LDA #$81
    STA $D404

    JSR LONG_DELAY

    LDA #$80
    STA $D404       ; turn off gate
    RTS

LONG_DELAY
    LDX #$60
LD1
    LDY #$FF
LD2
    DEY
    BNE LD2
    DEX
    BNE LD1
    RTS
```

---

## 14.7 Sweep sound (variable frequency)

A more dynamic effect: change frequency during playback:

```asm
SWEEP_SOUND
    LDX #$FF
SW_LOOP
    STX $D400       ; variable frequency
    LDA #$11
    STA $D404       ; gate ON

    LDY #$10
SW_DELAY
    DEY
    BNE SW_DELAY

    DEX
    BNE SW_LOOP

    LDA #$10
    STA $D404       ; turn off
    RTS
```

---

## 14.8 Non-blocking sound

In the game, we must NOT block the loop waiting for sound to finish. The SID works in hardware.

### Correct method

```asm
; Activate sound and return immediately to the game
PLAY_SHOT
    LDA #$FF
    STA $D400
    LDA #$10
    STA $D401
    LDA #$11
    STA $D404       ; turn on

    ; Don't wait! Return immediately
    RTS

; Somewhere else in the game, turn off when needed
STOP_SHOT
    LDA #$10
    STA $D404
    RTS
```

---

## 14.9 SID initialization

Before using the SID, reset the state:

```asm
INIT_SID
    LDA #0
    STA $D400       ; FREQ_LO
    STA $D401       ; FREQ_HI
    STA $D404       ; CTRL (gate OFF)
    STA $D405       ; AD
    STA $D406       ; SR
    LDA #$0F
    STA $D418       ; max volume
    RTS
```

---

## 14.10 Frequency table

`FREQ_HI` values for approximate frequencies:

```
$D401   Effect
──────────────────
$02     Very low (rumble)
$08     Low
$10     Medium-low
$20     Medium
$30     Medium-high
$40     High
$80     Very high
$FF     Extremely high
```

### FREQ_LO + FREQ_HI combination

```
Frequency = (FREQ_HI × 256 + FREQ_LO) × (clock / 16777216)

Typical game values:
  Shot:    $D400 = $FF, $D401 = $20
  Jump:    $D400 = $00, $D401 = $40
  Hit:     $D400 = $10, $D401 = $08
  Bonus:   $D400 = $80, $D401 = $30
```

---

## Exercises

### Exercise 1
Make a 1-second beep using square wave.

### Exercise 2
Create a short "laser" sound and connect it to the fire button.

### Exercise 3
Create an "explosion" sound with noise wave lasting about 0.5 seconds.

### Exercise 4
Implement a frequency sweep: from low to high in 0.5 seconds.

### Exercise 5
Create three different sounds (shot, explosion, bonus) and call them at different moments in the game.

---

## Summary

You have learned:

- The SID base registers ($D400-$D404, $D418)
- Waveforms: square ($11), triangle ($21), noise ($81)
- The GATE bit to turn notes on/off
- Creating sounds: beep, shot, explosion, sweep
- Not blocking the game loop with audio delays
- Properly initializing the SID

## References

- [Chapter 15 — Audio engine](15-audio-engine-sfx.md) — professional audio system
- [Chapter 11 — Bullet system](11-bullet-system.md) — sounds for shots/explosions
- [Solutions](../soluzioni/cap14-audio-base.asm) — exercise solutions
