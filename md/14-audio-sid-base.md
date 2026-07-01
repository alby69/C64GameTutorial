# Capitolo 14 — Audio SID: Primi Suoni

> **Comandi introdotti:** Nessuno (registri SID).

## Obiettivi

Al termine di questo capitolo saprai:

- Come funziona il chip SID del C64
- Impostare frequenza, volume e forma d'onda
- Creare un "beep" semplice
- Generare effetti sonori di base (sparo, esplosione)
- Non bloccare il gioco durante la riproduzione

---

## 14.1 Il chip SID

Il SID (Sound Interface Device) e mappato nei registri `$D400`-`$D41C`. Ha 3 voci indipendenti.

```
$D400 ┌──────────────────────┐
       │ Voce 1               │
$D40F │                      │
      ├──────────────────────┤
$D410 │ Voce 2               │
$D41F │                      │
      ├──────────────────────┤
$D420 │ Voce 3               │
$D42F │                      │
      ├──────────────────────┤
$D418 │ Volume globale        │
      └──────────────────────┘
```

### Registri della Voce 1

| Indirizzo | Nome | Cosa fa |
|---|---|---|
| `$D400` | FREQ_LO | Frequenza bassa (0-255) |
| `$D401` | FREQ_HI | Frequenza alta (0-255) |
| `$D404` | CTRL | Gate, waveform, test |
| `$D405` | AD | Attack/Decay |
| `$D406` | SR | Sustain/Release |
| `$D418` | VOL | Volume globale (0-15) |

### Forme d'onda (registro `$D404`)

```
Bit: 7  6  5  4  3  2  1  0
     -  -  N  T  S  R  G  -
         |  |  |  |  |
         |  |  |  |  +── Gate (1=nota attiva)
         |  |  |  +───── Ring modulation
         |  |  +──────── Sync
         |  +─────────── Triangle
         +────────────── Noise

Valori comuni:
$11 = Square wave + Gate ON
$21 = Triangle + Gate ON
$81 = Noise + Gate ON
$10 = Solo Square (Gate OFF)
```

---

## 14.2 Primo suono

Il programma piu semplice per sentire qualcosa:

```asm
*=$C000

START
    LDA #$20        ; frequenza
    STA $D400       ; FREQ_LO
    LDA #$10
    STA $D401       ; FREQ_HI

    LDA #$11        ; square wave + gate ON
    STA $D404       ; CTRL

    LDA #$0F        ; volume massimo
    STA $D418       ; VOL

LOOP
    JMP LOOP        ; suono continuo
```

---

## 14.3 Spegnere il suono

Per spegnere una nota, togli il bit GATE (bit 0):

```asm
; Accendi
LDA #$11
STA $D404

; ... tempo ...

; Spegni
LDA #$10           ; solo waveform, GATE = 0
STA $D404
```

---

## 14.4 Beep singolo

```asm
PLAY_BEEP
    LDA #$30
    STA $D400
    LDA #$15
    STA $D401
    LDA #$11
    STA $D404       ; accendi

    JSR DELAY

    LDA #$10
    STA $D404       ; spegni
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

## 14.5 Effetto sparo (laser)

```asm
LASER_SOUND
    LDA #$80
    STA $D400
    LDA #$30
    STA $D401
    LDA #$11
    STA $D404       ; accendi square

    JSR SHORT_DELAY

    LDA #$10
    STA $D404       ; spegni
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

## 14.6 Effetto esplosione (rumore)

```asm
EXPLOSION_SOUND
    ; Frequenza bassa
    LDA #$10
    STA $D400
    LDA #$05
    STA $D401

    ; Noise wave + gate
    LDA #$81
    STA $D404

    JSR LONG_DELAY

    LDA #$80
    STA $D404       ; spegni gate
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

## 14.7 Suono sweep (frequenza variabile)

Un effetto piu dinamico: cambia frequenza durante la riproduzione:

```asm
SWEEP_SOUND
    LDX #$FF
SW_LOOP
    STX $D400       ; frequenza variabile
    LDA #$11
    STA $D404       ; gate ON

    LDY #$10
SW_DELAY
    DEY
    BNE SW_DELAY

    DEX
    BNE SW_LOOP

    LDA #$10
    STA $D404       ; spegni
    RTS
```

---

## 14.8 Suono non bloccante

Nel gioco, NON dobbiamo bloccare il loop per aspettare la fine del suono. Il SID lavora in hardware.

### Metodo giusto

```asm
; Attiva il suono e torna subito al gioco
PLAY_SHOT
    LDA #$FF
    STA $D400
    LDA #$10
    STA $D401
    LDA #$11
    STA $D404       ; accendi

    ; Non aspettare! Torna subito
    RTS

; In un altro punto del gioco, spegni quando serve
STOP_SHOT
    LDA #$10
    STA $D404
    RTS
```

---

## 14.9 Inizializzazione SID

Prima di usare il SID, resettiamo lo stato:

```asm
INIT_SID
    LDA #0
    STA $D400       ; FREQ_LO
    STA $D401       ; FREQ_HI
    STA $D404       ; CTRL (gate OFF)
    STA $D405       ; AD
    STA $D406       ; SR
    LDA #$0F
    STA $D418       ; volume max
    RTS
```

---

## 14.10 Tabella delle frequenze

Valori di `FREQ_HI` per frequenze approssimative:

```
$D401   Effetto
──────────────────
$02     Molto basso (rombo)
$08     Basso
$10     Medio-basso
$20     Medio
$30     Medio-alto
$40     Alto
$80     Molto alto
$FF     Acutissimo
```

### Combinazione FREQ_LO + FREQ_HI

```
Frequenza = (FREQ_HI × 256 + FREQ_LO) × (clock / 16777216)

Valori tipici per giochi:
  Sparo:   $D400 = $FF, $D401 = $20
  Salto:   $D400 = $00, $D401 = $40
  Colpo:   $D400 = $10, $D401 = $08
  Bonus:   $D400 = $80, $D401 = $30
```

---

## Esercizi

### Esercizio 1
Fai un beep di 1 secondo usando square wave.

### Esercizio 2
Crea un suono "laser" breve e collegalo al pulsante di fuoco.

### Esercizio 3
Crea un suono "esplosione" con noise wave che dura circa 0.5 secondi.

### Esercizio 4
Implementa uno sweep di frequenza: da basso ad alto in 0.5 secondi.

### Esercizio 5
Crea tre suoni diversi (sparo, esplosione, bonus) e chiamali in momenti diversi del gioco.

---

## Riepilogo

Hai imparato:

- I registri base del SID ($D400-$D404, $D418)
- Le forme d'onda: square ($11), triangle ($21), noise ($81)
- Il bit GATE per accendere/spegnere le note
- Creare suoni: beep, sparo, esplosione, sweep
- Non bloccare il game loop con delay audio
- Inizializzare correttamente il SID

## Riferimenti

- [Capitolo 15 — Audio engine](15-audio-engine-e-sfx.md) — sistema audio professionale
- [Capitolo 11 — Sistema proiettili](11-sistema-proiettili.md) — suoni per sparo/esplosione
- [Soluzioni](../soluzioni/cap14-audio-base.asm) — soluzioni degli esercizi
