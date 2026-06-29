# Capitolo 7 — Raster Interrupt

## Obiettivi

Al termine di questo capitolo saprai:

- Cos'e il raster beam del VIC-II
- Come funzionano gli interrupt sul C64
- Installare un raster interrupt
- Cambiare colore a meta schermo
- Usare piu interrupt in cascata

---

## 7.1 Cos'e il Raster Beam

Il VIC-II disegna lo schermo una riga alla volta, dall'alto verso il basso. Il fascio elettronico (raster beam) percorre:

```
Su PAL:
  312 raster line totali
  63 cicli CPU per linea
  ~50 frame al secondo

Linee visibili: 0-311
  (prime 24 e ultime 24 sono fuori schermo)
```

```
Riga 0     → ┌──────────────────────┐
             │                      │
Riga 100   → │   Il beam e qui      │
             │                      │
Riga 199   → │                      │
             └──────────────────────┘
Riga 255   → (ritorno verticale)
```

### Registro raster corrente

```asm
$D012   ; contiene la raster line corrente (0-255)
$D011   ; bit 7 = bit alto del raster (256-311)
```

```asm
LDA $D012   ; A = riga corrente
```

---

## 7.2 Cos'e un Interrupt

Normalmente la CPU esegue un loop:

```
MAINLOOP
    JMP MAINLOOP   ; fa sempre la stessa cosa
```

Un interrupt e un segnale che "disturba" la CPU:

```
1. CPU sta eseguendo il MAINLOOP
2. Arriva un segnale di interrupt
3. CPU: salva tutto, esegue routine speciale
4. CPU: torna al MAINLOOP (dove si era fermata)
```

### Perche serve il raster interrupt?

Senza interrupt: il codice viene eseguito in modo non sincronizzato.

Con interrupt: possiamo eseguire codice ESATTAMENTE quando il raster beam raggiunge una certa riga.

```
Frame 50Hz (PAL)
│
├─ IRQ: logica gioco (sincronizzata)
├─ IRQ: musica
├─ IRQ: aggiornamento sprite
│
└─ attesa prossimo frame
```

---

## 7.3 Registri coinvolti

| Registro | Funzione |
|---|---|
| `$D012` | Raster line di confronto (0-255) |
| `$D011` | Bit 7: MSB del raster (linee 256-311) |
| `$D019` | Interrupt Control Register (acknowledge) |
| `$D01A` | Interrupt Enable Register |

### `$D019` — Interrupt Control

```
Bit 0: raster interrupt occorso (1 = si)
Bit 1: sprite-background collision
Bit 2: sprite-sprite collision
Bit 3: light pen
```

Per confermare l'IRQ:

```asm
LDA $D019
STA $D019       ; scrivere lo stesso valore lo resetta
```

Oppure:

```asm
ASL $D019       ; shift a sinistra (metodo compatto)
```

### `$D01A` — Interrupt Enable

```
Bit 0: 1 = abilita raster interrupt
Bit 1: 1 = abilita sprite-background collision IRQ
Bit 2: 1 = abilita sprite-sprite collision IRQ
```

---

## 7.4 Primo Raster Interrupt

```asm
*=$2000

START
    SEI                     ; disabilita IRQ durante il setup

    LDA #$7F
    STA $DC0D              ; disabilita CIA IRQ

    LDA #<IRQ              ; vettore IRQ low
    STA $0314
    LDA #>IRQ              ; vettore IRQ high
    STA $0315

    LDA #100               ; raster line 100
    STA $D012

    LDA $D011
    AND #$7F               ; MSB raster = 0
    STA $D011

    LDA #1                 ; abilita raster interrupt
    STA $D01A

    CLI                    ; riabilita IRQ

LOOP
    JMP LOOP               ; programma principale

; ----------------------------------
; ROUTINE IRQ
; ----------------------------------
IRQ
    INC $D020              ; cambia colore bordo (debug)

    LDA $D019
    STA $D019              ; acknowledge IRQ

    JMP $EA31              ; salta al normale handler IRQ
```

### Cosa succede

1. Alla riga 100, il VIC-II genera un interrupt
2. La CPU esegue `IRQ`: incrementa il colore del bordo
3. Conferma l'interrupt
4. Torna al sistema operativo (che poi torna al LOOP)

Vedrai una linea colorata sullo schermo alla riga 100.

---

## 7.5 Acknowledge corretto

ERRORE TIPICO che blocca il C64:

```asm
IRQ
    INC $D020
    RTI                     ; SBAGLIATO! nessun acknowledge
```

GIUSTO:

```asm
IRQ
    INC $D020
    LDA $D019
    STA $D019              ; acknowledge
    JMP $EA31              ; catena IRQ standard
```

---

## 7.6 Cambiare colore a meta schermo

```asm
*=$2000

START
    SEI
    LDA #$7F
    STA $DC0D

    LDA #<IRQ
    STA $0314
    LDA #>IRQ
    STA $0315

    LDA #120
    STA $D012

    LDA $D011
    AND #$7F
    STA $D011

    LDA #1
    STA $D01A

    CLI

LOOP
    JMP LOOP

IRQ
    LDA #2                 ; rosso
    STA $D021              ; cambia sfondo

    LDA $D019
    STA $D019

    JMP $EA31
```

Risultato: sopra la riga 120 lo sfondo e blu (valore iniziale), sotto e rosso.

---

## 7.7 Due Raster Interrupt

Per avere due cambi a meta schermo, ogni IRQ installa il successivo:

```asm
IRQ1
    LDA #6                 ; sfondo blu
    STA $D021

    ; Installa IRQ2 alla riga 150
    LDA #150
    STA $D012

    LDA #<IRQ2
    STA $0314
    LDA #>IRQ2
    STA $0315

    LDA $D019
    STA $D019

    JMP $EA31

IRQ2
    LDA #2                 ; sfondo rosso
    STA $D021

    ; Re-installa IRQ1 alla riga 50
    LDA #50
    STA $D012

    LDA #<IRQ1
    STA $0314
    LDA #>IRQ1
    STA $0315

    LDA $D019
    STA $D019

    JMP $EA31
```

Risultato:

```
riga 0-49:   sfondo nero (default)
riga 50-149: sfondo BLU
riga 150+:   sfondo ROSSO
```

---

## 7.8 Raster Bars (effetto classico)

Cambiamo il colore del bordo ogni poche righe per creare barre colorate:

```asm
; IRQ1 a riga 50
IRQ1
    LDA #2                 ; rosso
    STA $D020

    LDA #52
    STA $D012
    LDA #<IRQ2
    STA $0314
    LDA #>IRQ2
    STA $0315

    LDA $D019
    STA $D019
    JMP $EA31

; IRQ2 a riga 52
IRQ2
    LDA #7                 ; giallo
    STA $D020

    LDA #54
    STA $D012
    LDA #<IRQ3
    STA $0314
    LDA #>IRQ3
    STA $0315

    LDA $D019
    STA $D019
    JMP $EA31

; IRQ3 a riga 54
IRQ3
    LDA #1                 ; bianco
    STA $D020

    LDA #50
    STA $D012
    LDA #<IRQ1
    STA $0314
    LDA #>IRQ1
    STA $0315

    LDA $D019
    STA $D019
    JMP $EA31
```

---

## 7.9 Visualizzare il raster con la "barra di debug"

Tecnica usata nei giochi commerciali per vedere quanto tempo CPU consuma una routine:

```asm
IRQ
    ; All'inizio della routine
    LDA #2
    STA $D020              ; bordo rosso

    ; ...qui la routine da misurare...

    LDA #0
    STA $D020              ; bordo nero (fine)

    LDA $D019
    STA $D019
    JMP $EA31
```

La larghezza della banda rossa nel bordo sinistro indica il tempo impiegato.

---

## Esercizi

### Esercizio 1
Crea un raster interrupt alla riga 50 che cambi il bordo in rosso.

### Esercizio 2
Crea due IRQ: uno a riga 50 (bordo rosso), uno a riga 150 (bordo blu).

### Esercizio 3
Realizza una raster bar con 4 righe consecutive di colori diversi.

### Esercizio 4
Usa il raster interrupt per cambiare lo sfondo ogni frame da blu a nero (effetto flash).

### Esercizio 5
Fai lampeggiare un singolo carattere a schermo modificandone il colore tramite raster interrupt.

---

## Riepilogo

Hai imparato:

- Cos'e il raster beam e il registro `$D012`
- Come funzionano gli interrupt sul C64
- Installare un raster interrupt con vettore `$0314/$0315`
- L'importanza dell'acknowledge su `$D019`
- Cambiare colore a meta schermo
- Usare piu IRQ in cascata
- Raster bars e debug della CPU

## Riferimenti

- [Capitolo 8 — Game loop](08-game-loop-sincronizzato.md) — integrare IRQ nel loop principale
- [Capitolo 17 — Raster split](17-parallax-e-raster-split.md) — multiple zone raster
- [Capitolo 20 — Arcade OS](20-arcade-os-e-oltre.md) — interrupt chaining
- [Soluzioni](../soluzioni/cap07-raster.asm) — soluzioni degli esercizi
