# Appendice TMP — Guida Rapida a Turbo Macro Pro

> **Riferimenti online:**
> - C64 OS Programmer's Guide (sezione TMP): <https://c64os.com/c64os/programmersguide/devenvironment>
> - TMPx documentation (sintassi completa): <https://turbo.style64.org/docs/turbo-macro-pro-tmpx-syntax>
> - TMP Editor commands: <https://turbo.style64.org/docs/turbo-macro-pro-editor>
> - Download TMP nativo: <https://style64.org/release/turbo-macro-pro-sep06-style>
> - Download TMPx cross: <https://style64.org/release/tmpx-v1.1.0-style>

---

## 1. Panoramica

Turbo Macro Pro (TMP) e un assembler 6502 che gira nativamente su C64/C128.
TMPx e la versione cross-assembler (Windows, Mac, Linux), compatibile al 100% con la sintassi TMP.

**Concetto chiave:** TMP non e un linguaggio — e solo un assembler. Il vero linguaggio e il 6502 assembly.
TMP traduce le istruzioni mnemoniche in opcode macchina, gestisce etichette, macro, e pseudo-op.

---

## 2. Installazione

### Su C64 nativo

Scaricare `turbo-macro-pro-sep06-style.d64` dal sito Style, trasferirlo su disco (o emulatore).
Caricare con:

```
LOAD"TMP",8,1
SYS 8*4096
```

Il binario si carica a `$8000`, parte con `SYS 8*4096`.

### Cross-assembler TMPx (PC/Mac/Linux)

Scaricare `tmpx-v1.1.0-style` per il proprio sistema.

```
tmpx -o mio_programma.prg sorgente.asm
```

Flag utili: `-D SIMBOLO` per definire un simbolo da riga di comando, `-l listato.txt` per produrre un file di listing.

---

## 3. Sintassi di Base

### Costanti numeriche

| Prefisso | Base | Esempio | Decimale |
|----------|------|---------|----------|
| `$` | Esadecimale | `$D020` | 53280 |
| `%` | Binario | `%10001000` | 136 |
| nessuno | Decimale | `53280` | 53280 |
| `'x'` | Carattere ASCII | `'A'` | 65 |

### Etichette (Label)

```asm
; Definizione di etichetta
       *= $C000        ; Program Counter (dove assembliamo)
NOME   = $D020         ; Etichetta = valore costante

; Etichetta di indirizzo (definita implicitamente)
loop   inc $D020       ; 'loop' assume il valore del PC corrente
       jmp loop

; Operatori su etichette
       LDA #<NOME      ; Low byte: $20
       LDA #>NOME      ; High byte: $D0
       LDA #!NOME      ; Forza 2 byte anche se valore < 256
```

### Espressioni aritmetiche

Operatori binari (NON hanno precedenza — valutati da sinistra a destra):

| Op | Operazione | Esempio | Risultato |
|----|-----------|---------|-----------|
| `+` | Addizione | `$20 + 4` | `$24` |
| `-` | Sottrazione | `15 - 3` | `12` |
| `*` | Moltiplicazione | `2 * $10` | `$20` |
| `/` | Divisione | `192 / $40` | `3` |
| `&` | AND bit a bit | `$FF & $F0` | `$F0` |
| `.` | OR bit a bit | `$F0 . $0F` | `$FF` |
| `:` | XOR bit a bit | `$FF : $0F` | `$F0` |

Usare le parentesi per forzare precedenza: `2 * ($10 + 1) = $22`

### PETSCII tramite bastext

TMP assembla da file ASCII ma puo generare codice PETSCII:

```asm
.text "CIAO"              ; Conversione automatica ASCII→PETSCII
.text "{pound}"           ; Simbolo pounds: PETSCII 92
.text "{white}"           ; Colore bianco: PETSCII 5
.text "{127}"             ; Carattere grafico: PETSCII 127
.text "{$20}"             ; Spazio: PETSCII 32
.text "{063}"             ; Punto interrogativo: PETSCII 63
```

### Commenti

```asm
        lda #$01   ; Questo e' un commento (qualsiasi dopo ';')
```

---

## 4. Pseudo-Operazioni (Pseudo-Ops)

### Dati

```asm
.byte 25,"a",$CC          ; → $19 $41 $CC
.word $FCE2               ; → $E2 $FC (low/hi)
.rta $FCE2               ; → $E1 $FC (decrementato di 1, per stack)

.text "hello"             ; → stringa convertita in PETSCII
.null "hello"             ; → come .text + byte nullo $00 in coda
.shift "hello"            ; → come .text ma l'ultimo byte ha bit 7 = 1
.screen "hello"           ; → stringa in screencode (character ROM)

.repeat 8,$FF             ; → 8 byte $FF
.repeat 3,$FCE2           ; → $E2 $FC $E2 $FC $E2 $FC (3 word)
.repeat 2,"a","b","c"     ; → $41 $42 $43 $41 $42 $43
```

### Inclusione file

```asm
.include "kernel.s"       ; Include e assembla un file sorgente
.binary "dati.dat"        ; Include byte binari cosi' come sono
.binary "music.prg",2     ; Salta i primi 2 byte (load address)
```

### Variabili

```asm
cnt .var $0100            ; cnt = 256
    lda #cnt              ; lda #$00
cnt .var cnt+1            ; cnt ridichiarata: ora 257
    lda #cnt              ; lda #$01

; Uso tipico: contatori per .repeat o .goto
```

### Salto incondizionato in assemblaggio

```asm
cnt .var $0100
loop .lbl                 ; Marca il target per .goto
     nop
cnt  .var cnt-1
     .ifne cnt            ; se cnt != 0
     .goto loop           ; torna a 'loop'
     .endif
; Assembla $100 NOP consecutivi!
```

### Assemblaggio condizionale

```asm
NTSC = 1

     .if NTSC             ; se diverso da zero
     lda #$01
     .endif

     .ifeq NTSC-1         ; se uguale a zero (NTSC-1 == 0)
     lda #$02
     .endif

     .ifpl VALORE         ; se positivo ($0000-$7FFF)
     .ifmi VALORE         ; se negativo ($8000-$FFFF)

     .ifdef DEBUG         ; se il simbolo e' definito
     .ifndef DEBUG        ; se il simbolo NON e' definito
```

### Blocchi (scope locale)

```asm
tmp = $02                ; tmp globale = $02

sub  .block
tmp = $FF                ; tmp locale al blocco
     adc tmp             ; adc $FF !!!
     rts
     .bend

     lda tmp             ; lda $02 (globale) di nuovo
```

### Offset di assemblaggio (codice posizionato vs eseguito altrove)

```asm
     * = $2000
start bit base0          ; bit $2009
     bit base            ; bit $C000
     jmp *               ; jmp $2006
base0 * = $C000
base .offs base0-*
     lda #>start         ; lda #$20
     jmp *               ; jmp $8002
```

### Varie

```asm
.eor $FF        ; Tutto il codice dopo sara' XORato con $FF
.end            ; Termina l'assemblaggio qui
```

---

## 5. Macro

### Definizione

```asm
; Macro con parametri numerici (\1, \2, ...)
poke .macro            ; \1 = indirizzo, \2 = valore
     lda #\2
     sta \1
     .endm

; Macro con parametri testuali (@1, @2, ...)
error .macro
     lda #<txt
     ldy #>txt
     jsr $AB1E         ; Stampa stringa
     jmp fine
txt  .null "@1"        ; Testo passato come argomento
fine .endm

; Uso: .segment invece di .block se NON vuoi scope locale
tab  .segment
cnt  .var cnt-1
     .byte cnt
     .endm
```

### Chiamata

```asm
     #poke $D020,0        ; → lda #0 / sta $D020
     #error "File non trovato!"
```

### Ricorsione nelle macro

```asm
cnt  .var 0
tab  .segment
cnt  .var cnt+1
     .if cnt < 64
     #tab               ; Chiamata ricorsiva
     .endif
     .byte cnt
cnt  .var cnt-1
     .endm

     #tab               ; Genera tabella 0..64
```

---

## 6. Comandi dell'Editor TMP (su C64)

Tutti i comandi partono premendo il tasto **←** (freccia sinistra, accanto a `1`).

### Comandi principali

| Tasto | Comando | Cosa fa |
|-------|---------|---------|
| `1` | Exit BASIC | Torna al BASIC (`SYS 8*4096` per rientrare) |
| `2` | Paste separator | Inserisce una riga separatore |
| `3` | Assemble | Assembla in memoria |
| `4` | Print listing | Salva listing di assemblaggio |
| `5` | Assemble to disk | Assembla e salva `.prg` su disco |
| `6` | Make data | Converte un'area di memoria in `.byte` |
| `7` | Set tab return | Imposta il tab per il rientro |
| `8` | Set tab source | Imposta il tab per il codice |
| `a` | PETSCII mode | Inserimento letterale PETSCII |
| `b` | Block submenu | Operazioni su blocchi (copia/sposta/elimina) |
| `c` | Cold start | Reset completo di TMP |
| `d` | Increment device | Cambia device (8→9→10...) |
| `f` | Find string | Cerca testo |
| `g` | Goto mark | Vai a un segnalibro (0-9, s, e) |
| `h` | Find next | Trova successivo |
| `i` | Find label | Cerca etichetta per nome |
| `k` | Define F-keys | Ridefinisce F3-F6 |
| `l` | Load source | Carica un file sorgente |
| `m` | Set mark | Imposta segnalibro |
| `n` | Goto line | Vai a numero di riga |
| `p` | Preferences | Colori, stile separatore |
| `r` | Replace string | Cerca e sostituisci |
| `s` | Save source | Salva .prg del sorgente |
| `t` | Replace one | Sostituisce una occorrenza |
| `u` | List labels | Esporta tabella etichette |
| `y` | Replace all | Sostituisce tutto |
| `z` | Undo | Annulla modifica sulla riga corrente |
| `*` | View directory | Elenca il disco |
| `@` | Disk command | Comando DOS al drive |
| `!` | View SEQ | Visualizza file sequenziale |

### Comandi aggiuntivi senza tasto comando

| Tasto | Cosa fa |
|-------|---------|
| F1 | Su di 20 righe |
| F2 | All'inizio del sorgente |
| F7 | Giu di 20 righe |
| F8 | Alla fine del sorgente |
| F3 | Su di 200 righe (default) |
| F4 | Assembla ed esegui (default) |
| F5 | Giu di 200 righe (default) |
| F6 | Menu RAM (default) |
| INST | Toggle inserimento caratteri |
| DEL | Cancella riga corrente |

---

## 7. Flusso di Lavoro Tipico

### Su C64 nativo

```
1. LOAD"TMP",8,1         ; Carica TMP
2. SYS 8*4096            ; Avvia TMP
3. ←5                    ; Assemble to disk
   ? NOME                ; Da' un nome al .prg
4. ←l                    ; Load source (se vuoi ricaricare)
5. ←s                    ; Salva sorgente TMP
6. ←1                    ; Esci a BASIC
7. LOAD"NOME",8,1        ; Carica il .prg generato
8. SYS 49152             ; Esegui (o l'indirizzo giusto)
```

### Con TMPx (cross-assembler)

```bash
# Assembla
tmpx -o gioco.prg sorgente.asm

# Con listing
tmpx -o gioco.prg -l listato.txt sorgente.asm

# Con simbolo definito
tmpx -D NTSC -o gioco_ntsc.prg sorgente.asm
```

---

## 8. Errori Comuni

### Phase error

Succede quando la lunghezza del codice cambia tra passata 1 e passata 2 dell'assemblatore.
Causa tipica: etichetta usata prima di essere definita, e il valore richiede 1 byte ma l'assemblatore aveva assunto 2 byte.

```asm
; ERRORE: phase error
     lda etichetta   ; TMP assume 2 byte
     rts
etichetta = $02      ; In realta' 1 byte!

; CORRETTO:
     lda !etichetta  ; ! forza 2 byte esplicitamente
     rts
etichetta = $02
```

### Doppia definizione

Un'etichetta non puo essere definita due volte nello stesso scope.
Usare `.var` per variabili riassegnabili o `.block` per scope locali.

### Overflow .repeat

Il numero massimo di byte generabili con `.repeat` e limitato dalla memoria.

---

## 9. Suggerimenti per l'Uso

1. **Metti il nome del file nella prima riga** — TMP non ricorda il nome del file
2. **Salva spesso con `←s@:nomefile`** — Il `@:` forza la sovrascrittura
3. **Usa `.block` per subroutine riutilizzabili** — Evita conflitti di etichette
4. **Usa `.include` per suddividere il codice** — Tabelle, costanti, macro in file separati
5. **Usa `←u` dopo l'assemblaggio** — Per vedere a che indirizzo sono finite le etichette
6. **Per il cross-dev, preferisci TMPx** — Piu veloce, lista errori chiara, IDE indipendente

---

## 10. Confronto: TMP Nativo vs TMPx

| Caratteristica | TMP nativo (C64) | TMPx (PC/Mac/Linux) |
|---|---|---|
| Velocita | ~1 MHz | Istantaneo |
| Editor integrato | Si | No (usa il tuo editor) |
| Macro | Si | Si (stessa sintassi) |
| .include / .binary | Si | Si |
| Assemblaggio condizionale | Si | Si |
| Debug | Limite hardware | Listing testuale |
| Adatto per | Progetti piccoli/medi | Qualsiasi dimensione |
| Produzione .prg | Si, via `←5` | Si, via `-o file.prg` |
