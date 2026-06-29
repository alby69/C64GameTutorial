# Chapter 15 — Audio Engine and SFX Management

## Objectives

By the end of this chapter you will know:

- Structure a modular audio system
- Use an SFX request queue
- Separate sound effects across different channels
- Integrate audio into the raster interrupt
- Create a simple music player

---

## 15.1 Audio architecture for games

For a professional game, audio must be separated from logic:

```
┌─────────────────────────────────┐
│ GAME LOGIC                      │
│  "set SFX_REQUEST = 1"          │
└──────────┬──────────────────────┘
           │ (non-blocking)
           v
┌─────────────────────────────────┐
│ AUDIO ENGINE (called every       │
│ frame in raster IRQ)            │
│  "reads SFX_REQUEST,             │
│   writes to SID"                │
└─────────────────────────────────┘
           │
           v
┌─────────────────────────────────┐
│ SID HARDWARE                    │
│  (plays by itself)              │
└─────────────────────────────────┘
```

### Channel separation

```
Channel 1 → background music
Channel 2 → sound effects (shots, explosions)
Channel 3 → additional effects (bonus, power-ups)
```

---

## 15.2 SFX request system

Instead of writing directly to the SID, the game sets a request:

```asm
; Request variables
SFX_REQUEST  = $30   ; 0 = none, 1 = shot, 2 = explosion, 3 = bonus
SFX_ACTIVE   = $31   ; 0 = inactive, 1 = playing
SFX_TIMER    = $32   ; counter for effect duration

; Request from game (e.g. when you shoot)
FIRE_GUN
    LDA #1
    STA SFX_REQUEST      ; request "shot" sound
    ... bullet handling ...
    RTS
```

### Audio engine

```asm
UPDATE_AUDIO
    LDA SFX_ACTIVE
    BNE PLAYING_SFX

    ; No sound playing, we can start a request
    LDA SFX_REQUEST
    BEQ AUDIO_DONE

    ; Start the requested effect
    CMP #1
    BEQ START_SHOT
    CMP #2
    BEQ START_EXPLOSION
    CMP #3
    BEQ START_BONUS

AUDIO_DONE
    RTS

PLAYING_SFX
    DEC SFX_TIMER
    BNE AUDIO_DONE

    ; Timer expired: turn off sound
    LDA #0
    STA SFX_ACTIVE
    STA SFX_REQUEST

    ; Turn off channel 2
    LDA #$10
    STA $D414       ; CTRL voice 2, gate OFF

    RTS
```

---

## 15.3 Starting effects

```asm
START_SHOT
    LDA #$FF
    STA $D410       ; FREQ_LO voice 2
    LDA #$20
    STA $D411       ; FREQ_HI voice 2
    LDA #$11        ; square + gate
    STA $D414       ; CTRL voice 2

    LDA #8
    STA SFX_TIMER   ; 8 frame duration
    LDA #1
    STA SFX_ACTIVE
    LDA #0
    STA SFX_REQUEST
    RTS

START_EXPLOSION
    LDA #$10
    STA $D410
    LDA #$05
    STA $D411
    LDA #$81        ; noise + gate
    STA $D414

    LDA #20
    STA SFX_TIMER
    LDA #1
    STA SFX_ACTIVE
    LDA #0
    STA SFX_REQUEST
    RTS

START_BONUS
    LDA #$40
    STA $D410
    LDA #$30
    STA $D411
    LDA #$21        ; triangle + gate
    STA $D414

    LDA #15
    STA SFX_TIMER
    LDA #1
    STA SFX_ACTIVE
    LDA #0
    STA SFX_REQUEST
    RTS
```

---

## 15.4 Integration with Raster IRQ

Audio must run inside the raster interrupt to be stable:

```asm
GAME_IRQ
    PHA
    TXA
    PHA
    TYA
    PHA

    JSR READ_INPUT
    JSR UPDATE_LOGIC
    JSR UPDATE_SPRITES
    JSR UPDATE_AUDIO      ; called every frame!
    JSR UPDATE_MUSIC      ; if there's music

    PLA
    TAY
    PLA
    TAX
    PLA

    LDA $D019
    STA $D019
    JMP $EA31
```

---

## 15.5 Simple music player (sequential data)

A minimal player that reads notes from a table:

```asm
; Music data: triplets (freq_lo, freq_hi, duration)
; 0 = end

MUSIC_DATA
    .byte $40, $10, 8     ; note 1
    .byte $80, $20, 8     ; note 2
    .byte $00, $30, 8     ; note 3
    .byte $40, $10, 4     ; note 4 (shorter)
    .byte $00, $00, 0     ; end

MUSIC_PTR = $40    ; low pointer
MUSIC_PTR_H = $41  ; high pointer
MUSIC_TICK = $42   ; note duration counter

INIT_MUSIC
    LDA #<MUSIC_DATA
    STA MUSIC_PTR
    LDA #>MUSIC_DATA
    STA MUSIC_PTR_H
    LDA #0
    STA MUSIC_TICK
    RTS
```

### Player

```asm
UPDATE_MUSIC
    DEC MUSIC_TICK
    BNE MUSIC_DONE

    ; Read next note
    LDY #0
    LDA (MUSIC_PTR),Y    ; FREQ_LO
    BEQ MUSIC_END        ; 0 = end

    STA $D400            ; voice 1, FREQ_LO

    INY
    LDA (MUSIC_PTR),Y    ; FREQ_HI
    STA $D401

    INY
    LDA (MUSIC_PTR),Y    ; duration
    STA MUSIC_TICK

    ; Gate ON
    LDA #$11
    STA $D404

    ; Advance pointer
    CLC
    LDA MUSIC_PTR
    ADC #3
    STA MUSIC_PTR
    LDA MUSIC_PTR_H
    ADC #0
    STA MUSIC_PTR_H

MUSIC_DONE
    RTS

MUSIC_END
    ; Turn off gate
    LDA #$10
    STA $D404
    ; Restart
    JSR INIT_MUSIC
    RTS
```

---

## 15.6 Volume and mix management

```asm
SET_VOLUME
    LDA #$0F        ; max volume for all channels
    STA $D418
    RTS

MUTE_ALL
    LDA #$00
    STA $D418
    RTS

; Per-channel volume doesn't exist physically,
; but we can attenuate using ADSR:
SET_ADSR
    LDA #$09        ; Attack = 0, Decay = 9
    STA $D405       ; AD voice 1
    LDA #$F0        ; Sustain = F, Release = 0
    STA $D406       ; SR voice 1
    RTS
```

---

## 15.7 Audio command queue (advanced)

For more control, a circular command queue:

```asm
; Audio queue (16 commands)
AUDIO_QUEUE = $C0
QUEUE_HEAD = $50
QUEUE_TAIL = $51

; Command: .byte (channel, freq_lo, freq_hi, waveform, duration)

PUSH_AUDIO
    LDX QUEUE_TAIL
    STA AUDIO_QUEUE,X     ; channel
    INX
    TXA
    AND #$0F
    STA QUEUE_TAIL
    RTS

PROCESS_AUDIO_QUEUE
    LDX QUEUE_HEAD
    CPX QUEUE_TAIL
    BEQ AQ_DONE

    LDA AUDIO_QUEUE,X     ; first byte = channel
    ; ... process command ...
    INX
    TXA
    AND #$0F
    STA QUEUE_HEAD

AQ_DONE
    RTS
```

---

## Exercises

### Exercise 1
Create the SFX_REQUEST system: shot on channel 2, explosion on channel 3.

### Exercise 2
Integrate UPDATE_AUDIO into the 50 Hz raster interrupt.

### Exercise 3
Create a 4-note musical sequence that loops.

### Exercise 4
Use ADSR to create a "rain" sound with noise and a long attack.

### Exercise 5
Implement an 8-command audio queue for handling simultaneous sounds.

---

## Summary

You have learned:

- Audio architecture: Game Logic → Audio Engine → SID
- Separate channels: music on 1, SFX on 2, effects on 3
- Non-blocking request system (SFX_REQUEST)
- Audio integration in the raster interrupt
- Music player with sequential data
- ADSR for sound shaping
- Audio command queue

## References

- [Chapter 14 — SID audio basics](14-sid-audio-basics.md) — SID fundamentals
- [Chapter 8 — Game loop](08-synchronized-game-loop.md) — audio integration in the loop
- [Solutions](../soluzioni/cap15-audio-engine.asm) — exercise solutions
