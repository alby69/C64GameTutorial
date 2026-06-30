# Appendice F — Schemi Rapidi: Audio e Hardware Avanzato

## SID 6581 — Registri Principali

```
 Voce 0:         Voce 1:          Voce 2:
 $D400 = Freq lo $D407 = Freq lo $D40E = Freq lo
 $D401 = Freq hi $D408 = Freq hi $D40F = Freq hi
 $D402 = Ctrl    $D409 = Ctrl    $D410 = Ctrl
 $D403 = AD      $D40A = AD      $D411 = AD
 $D404 = SR      $D40B = SR      $D412 = SR

 $D405 ┌──────────────────────────────────┐
       │  PULSE WIDTH LO (Voce 0)         │
 $D406 ├──────────────────────────────────┤
       │  PULSE WIDTH HI (Voce 0)         │
 ├─────┴──────────────────────────────────┤
       $D413/$D414 = stesso per Voce 2    │
 ├────────────────────────────────────────┤
       $D415 = Cutoff Filter LO           │
       $D416 = Cutoff Filter HI / RES     │
       $D417 = Control Filter / Conn      │
 ──────┴──────────────────────────────────┘

 $D418 ┌──────────────────────────────────┐
       │  VOLUME & FILTER                 │
       │  bit: 4-7 = filtro selezionato  │
       │       0-3 = volume (0-15)        │
       └──────────────────────────────────┘
```

### Control Register ($D402/$D409/$D410)

```
 Bit:  7     6     5    4    3    2    1    0
       NOISE SQUARE PULSE TRI  SAW  TEST RING SYNC GATE
       │     │     │    │    │    │    │    │    │
       │     │     │    │    │    │    │    │    └─ Gate (1=attacca)
       │     │     │    │    │    │    │    └────── Sync
       │     │     │    │    │    │    └───────────── Ring Mod
       │     │     │    │    │    └────────────────── Test
       │     │     │    │    └─────────────────────── Sawtooth
       │     │     │    └──────────────────────────── Triangle
       │     │     └───────────────────────────────── Pulse
       │     └─────────────────────────────────────── Square
       └───────────────────────────────────────────── Noise

 Per attivare: imposta GATE=1 (bit 0 = 1)
 Per disattivare: GATE=0
 Seleziona forma d'onda: imposta UNO dei bit 4-7
```

### Registro ADSR (Attack/Decay e Sustain/Release)

```
 $D403 / $D40A / $D411 — Attack/Decay:
   bit: 7-4 = Attack rate (0-15)
        3-0 = Decay rate  (0-15)

 $D404 / $D40B / $D412 — Sustain/Release:
   bit: 7-4 = Sustain level (0-15)
        3-0 = Release rate  (0-15)

 Valori tipici:
        Attack  Decay  Sustain  Release
 Pistola:   $0A    $09    $00     $09
 Esplosione:$0F    $08    $00     $0F
 Sparo:     $05    $05    $00     $0F
 Powerup:   $09    $06    $0F     $08
 Nave:      $08    $06    $08     $08
```

### Inviluppo ADSR — Grafico

```
 GATE=1                    GATE=0
   │                         │
   │ ATTACCO   DECADIMENTO   │ RILASCIO
   ▲                        ▲
   │                       /│
   │     ┌─── SUSTAIN ────┐ │
   │    ┌┘                └┐│
   │   ┌┘                  └┘
   │  ┌┘
   │ ┌┘
   │┌┘
   ┌┴──────────────────────────────► tempo
   │
   attacco: sale (veloce/lento)
   decadimento: scende fino a sustain
   sustain: tiene finche' gate resta 1
   rilascio: cala dopo gate=0
```

---

## Forme d'Onda SID

```
 SAWTOOTH (dente di sega):

   ████░░░░████░░░░████░░░░████

 TRIANGLE (triangolare):

   ▓▓▓▓░░░░░░░░▓▓▓▓░░░░░░░░▓▓▓▓

 PULSE (onda quadra):

   ████████░░░░░░████████░░░░░░

 NOISE (rumore):

   ▓░▓▓░▓░▓▓░▓░░▓░▓░░▓░▓▓░▓░░▓
```

---

## Audio Engine — Pipeline

```
                    ┌───────────────────┐
                    │  TABELLA SUONI    │
                    │ ┌─────┬─────┬───┐│
                    │ │indice│ptr   │dur││
                    │ ├─────┼─────┼───┤│
                    │ │  0  │suono0│30 ││
                    │ │  1  │suono1│15 ││
                    │ │  2  │suono2│20 ││
                    │ └─────┴─────┴───┘│
                    └────────┬──────────┘
                             │
 ┌───────────────────────────┴──────────────────────────┐
 │                 AUDIO ENGINE                          │
 │                                                       │
 │  1. PlayRequest(suono_idx, voce, priorita)            │
 │     → cerca slot libero o rimpiazza priorita bassa    │
 │                                                       │
 │  2. UpdateAudio() - chiamato ogni frame:              │
 │     per ogni voce attiva:                             │
 │       if durata > 0 → decrementa contatore            │
 │       if scaduta → disattiva (GATE=0)                 │
 │       if nuova nota → scrive su SID:                  │
 │         - Freq HI/LO                                  │
 │         - Control (GATE=1 + forma d'onda)             │
 │         - ADSR                                        │
 │                                                       │
 │  3. Mixing (se piu suoni sulla stessa voce):          │
 │     → priorita decide quale suono parte               │
 └───────────────────────────────────────────────────────┘
```

---

## Parallasse a 3 Strati

```
             DIREZIONE SCROLL NEMICI ⬅ (v = 2 px/frame)
             DIREZIONE SCROLL STELLE ⬅ (v = 1 px/frame)
             DIREZIONE SCROLL SFONDO ⬅ (v = 0.5 px/frame)

 ┌──────────────────────────────────────────────────────┐
 │  STRATO 0 (Sfondo lontano) — 0.5 px/frame           │
 │  ═══╗ ═══╗ ═══╗    Montagne, nuvole, pianeti       │
 │     ║    ║    ║                                     │
 ├──────────────────────────────────────────────────────┤
 │  STRATO 1 (Stelle/parallasse medio) — 1 px/frame    │
 │   *     *     *    *    *      Stelle medie          │
 │      *    *      *      *                            │
 ├──────────────────────────────────────────────────────┤
 │  STRATO 2 (Nemici/elementi foreground) — 2 px/frame │
 │   @@        @@         @@   Nemici in movimento      │
 │       @@         @@                                  │
 ├──────────────────────────────────────────────────────┤
 │  STRATO 3 (Giocatore/HUD) — fisso sullo schermo     │
 │  ┌────┐ HUD ┌────┐                  Sempre visibile │
 │  │ G  │     │ G  │                                  │
 │  └────┘     └────┘                                  │
 └──────────────────────────────────────────────────────┘
```

---

## Cicli CPU per Operazione Tipica

| Operazione | Cicli CPU | Note |
|---|---|---|
| LDA immediato | 2 | |
| LDA zero page | 3 | |
| LDA assoluto | 4 | |
| STA assoluto | 4 | |
| Somma 16 bit | ~15-25 | Piu istruzioni |
| JSR/RTS | 6+6 | Call+return |
| Moltiplicazione software | ~30-80 | Dimensione variabile |
| COPY byte (1000 byte) | ~8000 | Senza ottimizzazione |
| Scroll char (1000 byte) | ~10000 | Shift + refresh |
| Multiplex sprite (8 sprite) | ~100-200 | Solo coordinate |
| ISR raster (minima) | ~25-40 | Overhead setup/ack |
| Legge joystick | ~10-15 | |

### Budget Frame (50 Hz = 20ms = ~20000 cicli)

```
 VBLANK (~11000 cicli):
   ├─ 500  Input (joystick)
   ├─ 2000 Logica nemici (aggiorna 20 entita)
   ├─ 1000 Collisioni (confronti box)
   ├─ 1000 Aggiornamento sprite (pool→coordinate)
   ├─ 500  Audio (gestione voci)
   └─ 6000 Liberi (si puo' fare di piu)

 RASTER VISIBILE (~9000 cicli):
   ├─ 200  IRQ HUD (set colore/bordo)
   ├─ 200  IRQ Zona gioco (zone split)
   ├─ 200  IRQ Zona inf. (set colore/barra)
   └─ 8400 Liberi (BASSA priorita / idle)
```

---

## CIA Interrupt Control

```
 $DC0D ┌──────────────────────────────────────┐
       │  CIA1 INTERRUPT CONTROL AND STATUS    │
       │                                       │
       │  Scrivere:                            │
       │    bit 0 = TA (timer A)               │
       │    bit 1 = TB (timer B)               │
       │    bit 2 = TOD (time of day)          │
       │    bit 3 = SDR (serial)               │
       │    bit 4 = FLAG (busflgs)             │
       │                                       │
       │  Leggere: bit 7 = IRQ pendente        │
       │           bit 0-4 = sorgente          │
       └──────────────────────────────────────┘

 $DC0E ┌──────────────────────────────────────┐
       │  CIA1 CONTROL REGISTER A              │
       │                                       │
       │  bit 0: start/stop timer              │
       │  bit 1: PB-on timer                   │
       │  bit 2: output mode                   │
       │  bit 3: one-shot/continuous           │
       │  bit 4: force load                    │
       │  bit 5: input mode (CNT)              │
       │  bit 6: serial (SDR)                  │
       │  bit 7: timer A toggle output         │
       └──────────────────────────────────────┘

 VIC-II Interrupt ($D01A):
   bit 0: IRQ al raster (riga specificata)
   bit 1: IRQ a fine schermo (VBLANK)
   bit 2: IRQ su collisione sprite-sprite
   bit 3: IRQ su collisione sprite-sfondo
   bit 7: IRQ su penna luminosa

 VIC-II Interrupt Status ($D019):
   stessi bit → 1 = accaduto
   Scrivere $D019 per ACK (azzerare con 1 sui bit da pulire)
```
