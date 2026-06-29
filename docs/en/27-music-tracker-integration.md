# Chapter 27 — Music Tracker Integration

## Objectives

By the end of this chapter you will know:

- What a C64 music tracker is (GoatTracker, DefMon, SidFactory)
- Export music in `$D400` player format
- Integrate a SID player into the game
- Handle music + SFX simultaneously
- Use interrupts for music playback

---

## 27.1 Music Trackers for C64

A music tracker is a program for composing C64 SID music visually.
The most common ones:

```
GoatTracker   — MOD-like interface, exports .asm
DefMon        — Compact player, used in many demos
SidFactory    — Complete SID editor, exports player
CheeseCutter  — Modern, open source
```

### Workflow

```
1. Compose music in GoatTracker
2. Export → .asm file with player + data
3. Include in your assembly project
4. Call INIT and PLAY at 50 Hz via IRQ
```

---

## 27.2 SID Player Structure

An exported SID player typically has three entry points:

```asm
; Typical SID player structure
; (exported from GoatTracker or DefMon)

; Exported labels:
;   MUSIC_INIT     — call to initialize
;   MUSIC_PLAY     — call every frame (50 Hz)
;   MUSIC_DATA     — song data (tables)

MUSIC_INIT
    ; Initialize player
    ; Reset pointers, ADSR, volume
    ...
    RTS

MUSIC_PLAY
    ; Advance one frame
    ; Read tables, write SID registers
    ...
    RTS
```

---

## 27.3 Integration into the Game

### Initialization

```asm
; In game setup
GAME_INIT
    ...
    JSR MUSIC_INIT    ; Start music
    RTS
```

### Player via IRQ

```asm
; In raster IRQ (50 Hz)
KERNEL_IRQ
    ...
    JSR MUSIC_PLAY    ; Advance music every frame
    JSR ENGINE_AUDIO_UPDATE  ; SFX
    ...
```

---

## 27.4 Music + SFX

The SID has 3 independent voices. Typical allocation:

```
Voice 1: melody
Voice 2: accompaniment/bass
Voice 3: sound effects (SFX)
```

Management:

```asm
; Music player uses voices 1 and 2
; SFX uses voice 3

ENGINE_AUDIO_UPDATE
    ; If SFX active, don't overwrite voice 3
    LDA SFX_ACTIVE
    BEQ AU_NOSFX

    ; SFX takes over voice 3
    LDA SFX_FREQ_LO
    STA SID_V3_FREQ_LO
    LDA SFX_FREQ_HI
    STA SID_V3_FREQ_HI
    LDA #$11           ; Square + gate ON
    STA SID_V3_CTRL
    RTS

AU_NOSFX
    ; Voice 3 free — player handles it
    RTS
```

---

## 27.5 Compact Player (DefMon Style)

A minimal player can be hand-written:

```asm
; Minimal SID player — notes in a table
; Structure: one note per frame

MUSIC_TABLE
    ; Format: freq_lo, freq_hi, waveform, duration
    .byte $00, $00, $00, $00   ; rest

    .byte $F1, $0E, $11, $08   ; note 1: C5
    .byte $00, $00, $00, $04   ; rest
    .byte $5B, $11, $11, $08   ; note 2: D5
    .byte $00, $00, $00, $04   ; rest
    .byte $FF                  ; end

MUSIC_PLAY
    LDA MUSIC_DATA_PTR
    TAX
    LDA MUSIC_TABLE,X
    CMP #$FF
    BEQ MP_LOOP        ; end → loop

    ; Frequency
    LDA MUSIC_TABLE,X
    STA SID_V1_FREQ_LO
    LDA MUSIC_TABLE+1,X
    STA SID_V1_FREQ_HI

    ; Waveform + gate
    LDA MUSIC_TABLE+2,X
    STA SID_V1_CTRL

    ; Duration
    LDA MUSIC_TABLE+3,X
    STA MP_COUNTER

    ; Advance pointer
    TXA
    CLC
    ADC #4
    STA MUSIC_DATA_PTR
    RTS

MP_LOOP
    LDA #0
    STA MUSIC_DATA_PTR  ; loop to start
    RTS

MUSIC_DATA_PTR
    .byte 0
MP_COUNTER
    .byte 0
```

---

## 27.6 Volume and Mixing

To mix music and SFX without conflicts:

```asm
MIXER_FRAME
    ; Music player writes SID
    JSR MUSIC_PLAY

    ; If SFX active, overwrite only SFX voice
    LDA SFX_ACTIVE
    BEQ MX_NOFX

    ; Save player's voice 3 state
    LDA SID_V3_CTRL
    PHA

    ; Play SFX on voice 3
    JSR PLAY_SFX

    ; After SFX, restore player
    PLA
    STA SID_V3_CTRL

MX_NOFX
    RTS
```

---

## 27.7 Importing from GoatTracker

GoatTracker exports in `.asm` format:

```asm
; File exported from GoatTracker
; (example)
* = $C000

    .include "gt-player.asm"   ; Player engine

; Song data
    .include "my-song.asm"

; Entry points
INIT
    JSR GT_INIT
    RTS

PLAY
    JSR GT_PLAY
    RTS
```

---

## Exercises

### Exercise 1
Write a minimal SID player that plays a scale of notes
(square wave, voice 1) in a loop, advancing one note per frame.

### Exercise 2
Add a second accompaniment voice (triangle, voice 2)
to the player from exercise 1.

### Exercise 3
Integrate the music player into the game via IRQ: start music
on the title screen, stop it on game over.

### Exercise 4
Implement a mixer that allows music (voices 1-2) and SFX (voice 3)
to coexist without conflicts.

### Exercise 5
Export a simple melody from GoatTracker and integrate it into the
project with `.include`. Write the INIT/PLAY routines.

---

## References

- [Chapter 14 — SID Audio Basics](14-sid-audio-basics.md) — SID registers, waveforms, ADSR
- [Chapter 15 — Audio Engine and SFX](15-audio-engine-sfx.md) — SFX queue
- [GoatTracker](https://sourceforge.net/projects/goattracker2/) — C64 music tracker
- [Solutions](../soluzioni/cap27-music-tracker.asm) — exercise solutions
