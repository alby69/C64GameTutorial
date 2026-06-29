# Capitolo 22 — Debugging con VICE

## Obiettivi

Al termine di questo capitolo saprai:

- Usare il monitor assembly di VICE
- Impostare breakpoint e watchpoint
- Eseguire passo-passo il codice
- Ispezionare memoria, registri e stack
- Analizzare il raster per problemi di timing
- Debuggare i bug tipici del C64

---

## 22.1 Perche VICE?

VICE e l'emulatore C64 piu diffuso. Include un **monitor assembly**
che permette di ispezionare e controllare l'esecuzione in tempo reale.

```
VICE monitor:      Alt+H (Windows/Linux), Cmd+H (macOS)
Monitore raw:      Alt+H, poi `monitor` o direttamente `x64sc -moncommands`
```

### Avviare il monitor

Da VICE in esecuzione:

1. Premi **Alt+H** (o **Cmd+H** su macOS)
2. Si apre una finestra di terminale con il prompt `(C64:1)`
3. Da qui puoi inserire comandi

Oppure avviare VICE con monitor gia aperto:

```bash
x64sc -moncommands script.txt game.prg
```

---

## 22.2 Comandi fondamentali

### Ispezionare la CPU

```
(C64:1) r              — mostra registri (A, X, Y, SP, PC, SR)
(C64:1) r $D012        — mostra solo il registro $D012
(C64:1) x              — esegui un passo (step over)
(C64:1) z              — esegui un passo (step into)
(C64:1) g              — continua l'esecuzione (go)
```

### Ispezionare la memoria

```
(C64:1) m $C000        — mostra memoria da $C000
(C64:1) m $D000 $D010  — mostra intervallo $D000-$D010
(C64:1) d $C000        — disassembla da $C000
(C64:1) d $C000 $C010  — disassembla intervallo
```

### Breakpoint

```
(C64:1) b $C010        — fermati quando PC = $C010
(C64:1) bl $C010       — breakpoint con lo stesso indirizzo
(C64:1) b $C010 $C020  — fermati quando PC e tra $C010 e $C020
(C64:1) bc             — cancella tutti i breakpoint
(C64:1) bc 1           — cancella breakpoint 1
(C64:1) bl             — lista breakpoint attivi
```

### Watchpoint (lettura/scrittura memoria)

```
(C64:1) w $D012        — fermati quando $D012 cambia
(C64:1) w $0400 $07FF  — fermati su accessi a screen RAM
(C64:1) wl $D020       — watchpoint in lettura
(C64:1) ws $D020       — watchpoint in scrittura
```

---

## 22.3 Esempio pratico: debug raster

Uno dei bug piu comuni: il raster interrupt non parte al raster giusto.

```asm
; Programma con bug: IRQ non parte
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

### Debug passo-passo

1. Carica il programma in VICE
2. Apri il monitor (Alt+H)
3. Imposta breakpoint a `MY_IRQ`: `b $C01B` (supponendo l'indirizzo corretto)
4. Digita `g` per continuare
5. Quando il breakpoint scatta, controlla:
   - `r` — il raster coincide? Il registro $D012 dovrebbe essere 100
   - Se l'IRQ non scatta mai, probabilmente `$D01A` non e stato impostato

### Bug comune: dimenticare $D01A

```asm
; BUG: manca LDA #1 / STA $D01A
; L'IRQ non verra mai generato!
```

Soluzione: aggiungere `LDA #1 : STA $D01A` dopo il setup.

---

## 22.4 Debug della memoria video

Problema: un carattere non appare sullo schermo.

```
(C64:1) m $0400        — mostra screen RAM
(C64:1) m $D800        — mostra color RAM
(C64:1) m $07F8 $07FF  — mostra sprite pointer
(C64:1) m $2000 $2020  — mostra dati sprite (se a $2000)
```

### Esempio: sprite invisibile

Se uno sprite non appare:

1. Controlla `$D015` (enable sprite): `m $D015`
2. Controlla `$D010` (MSB X): `m $D010`
3. Controlla `$D000-$D00F` (posizioni): `m $D000 $D00F`
4. Controlla `$07F8` (pointer): `m $07F8`
5. Verifica che i dati ci siano: calcola pointer * 64 e guarda li

```
Sprite pointer = valore in $07F8
Indirizzo dati = pointer * 64
Esempio: $07F8 = $80 → dati a $80 * 64 = $2000
```

---

## 22.5 Debug delle collisioni

Le collisioni VIC-II hanno registri di stato:

```
$D01E — collisioni sprite-sprite
$D01F — collisioni sprite-sfondo
```

Per debuggare:

```
(C64:1) b $C010         — breakpoint dopo la lettura di $D01E
(C64:1) g               — continua
— quando scatta:
(C64:1) r               — guarda A (dovrebbe avere il risultato)
(C64:1) m $D01E         — leggi il registro collisioni
```

---

## 22.6 Analisi dei tempi (raster)

Il raster permette di misurare il tempo CPU speso:

```asm
; Debug raster: accendi bordo all'inizio, spegni alla fine
DEBUG_START
    LDA #2
    STA $D020           ; bordo rosso all'inizio

    ; ... codice da misurare ...

    LDA #0
    STA $D020           ; bordo nero alla fine
```

In VICE, guarda la barra colorata a destra dello schermo:
- Se e larga, il codice consuma molti cicli
- Se supera la zona visibile, hai superato il frame (50 Hz)

---

## 22.7 Debug dello stack

Problema: crash con `RTS` che va da qualche parte in mezzo al codice.

```
(C64:1) m $0100 $01FF  — mostra stack
(C64:1) r              — guarda SP (stack pointer)
```

Lo stack e a $0100-$01FF. Se SP e sceso sotto $80, probabilmente ci sono
troppi PHA senza PLA.

### Esempio: stack overflow

```asm
; BUG: chiamate ricorsive senza controllo
BUG_RECURSE
    JSR BUG_RECURSE     ; ogni chiamata consuma 2 byte di stack
    RTS
```

Questo riempie lo stack in pochi secondi. Sintomo: `RTS` salta in mezzo
al nulla.

Debug:
```
(C64:1) b $0100         — breakpoint su stack basso (raro)
— meglio:
(C64:1) bl $0100 $01FF
```

---

## 22.8 Comandi avanzati

### Disassemblaggio con dump

```
(C64:1) d $C000 $C020  — disassembla 32 byte
(C64:1) a $C000        — assembla a $C000 (modalita inserimento)
LDA #$01               — inserisci istruzioni
STA $D020
JMP $C000
.                      — punto per uscire
```

### I/O e salvataggio

```
(C64:1) l "dump.bin" $C000 $C010  — salva memoria su file
(C64:1) s "programma" 8            — salva su disco reale/immagine
```

### Trojan horse (modifica a caldo)

```
(C64:1) a $C000
NOP                    — sostituisci JSR con NOP per saltare una chiamata
NOP
NOP
.
— oppure modifica direttamente:
(C64:1) m $C000
:C000 20 0D C0  → EA EA EA   (sostituisci JSR $C00D con NOP)
```

---

## Riepilogo — Comandi VICE

| Comando | Azione |
|---|---|
| `r` | Mostra registri CPU |
| `m $addr` | Mostra memoria |
| `d $addr` | Disassembla |
| `b $addr` | Breakpoint su esecuzione |
| `w $addr` | Watchpoint su accesso |
| `wl $addr` | Watchpoint in lettura |
| `ws $addr` | Watchpoint in scrittura |
| `g` | Continua esecuzione |
| `x` | Step over |
| `z` | Step into |
| `bc` | Cancella breakpoint |
| `bl` | Lista breakpoint |
| `l "file" $start $end` | Salva memoria su file |

---

## Esercizi

### Esercizio 1
Carica un programma in VICE, imposta un breakpoint a $C000 e usa `r`, `m`, `d` per ispezionare stato CPU e memoria.

### Esercizio 2
Scrivi un programmino che accende il bordo con `INC $D020` in un loop.
Imposta un watchpoint su $D020 e osserva quando viene modificato.

### Esercizio 3
Prendi il codice del capitolo 7 (raster IRQ) e intentionalmente togli `LDA #1 : STA $D01A`. Usa VICE per scoprire perche l'IRQ non parte.

### Esercizio 4
Usa il debug raster per misurare quanti cicli CPU consuma un loop che scrive 100 byte in screen RAM. Confronta con un loop ottimizzato (con `LDX`/`STX` invece di `LDA`/`STA`).

### Esercizio 5
Simula uno stack overflow con chiamate ricorsive e usa il monitor VICE per osservare lo stack riempirsi ($0100-$01FF).

---

## Riferimenti

- [VICE Manual](https://vice-emu.sourceforge.io/vice_15.html) — sezione monitor
- [Capitolo 7 — Raster Interrupt](07-raster-interrupt.md) — setup IRQ da debuggare
- [Capitolo 4 — Memoria Video](04-memoria-video-e-caratteri.md) — screen RAM per debug visivo
- [Soluzioni](../soluzioni/cap22-debugging.asm) — esempi di debug
