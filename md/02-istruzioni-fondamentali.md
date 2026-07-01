# Capitolo 2 — Istruzioni Fondamentali del 6502

> **Comandi introdotti:** `LDX`, `LDY`, `STX`, `STY`, `TAX`, `TAY`, `TXA`, `TYA`, `INX`, `DEX`, `INY`, `DEY`, `INC`, `DEC`, `ADC`, `SBC`, `CLC`, `SEC`, `CMP`, `CPX`, `CPY`, `BEQ`, `BNE`, `BCC`, `BCS`, `BMI`, `BPL`, `AND`, `ORA`, `EOR`, `NOP`.

## Obiettivi

Al termine di questo capitolo saprai:

- Usare le modalita di indirizzamento del 6502
- Dichiarare variabili in Zero Page
- Usare `INX`, `DEX`, `INC`, `DEC`
- Operazioni matematiche `ADC` e `SBC`
- Operazioni logiche `AND`, `ORA`, `EOR`
- Confrontare valori con `CMP`, `CPX`, `CPY`
- Salti condizionati con `BEQ`, `BNE`, `BCC`, `BCS`
- Creare contatori e cicli

---

## 2.1 Come vede la memoria il 6502

Il 6510 (compatibile 6502) indirizza 64 KB. Ogni indirizzo contiene un byte (0-255).

```
$00 = 0        $0A = 10
$10 = 16       $20 = 32
$FF = 255
```

### Notazione esadecimale e binaria

In TMP:
- Il simbolo `$` indica un valore **esadecimale** (base 16).
- Il simbolo `%` indica un valore **binario** (base 2).
- Nessun simbolo indica un valore **decimale**.

```asm
LDA #$10       ; esadecimale ($10 = 16)
LDA #%00010000 ; binario (%00010000 = 16)
LDA #16        ; decimale (16)
```

> **Consiglio:** Usa la notazione binaria (`%`) quando lavori con i registri che controllano i singoli bit, come l'abilitazione degli sprite o le maschere di interrupt. E molto piu intuitivo!

| Decimale | Esadecimale |
|---|---|
| 0 | `$00` |
| 1 | `$01` |
| 10 | `$0A` |
| 16 | `$10` |
| 32 | `$20` |
| 100 | `$64` |
| 255 | `$FF` |

---

## 2.2 Modalita di indirizzamento

Il 6502 ha diverse modalita per leggere/scrivere dati.

### Immediato (`#`)

Il valore e nella stessa istruzione:

```asm
LDA #10     ; A = 10 (carica il NUMERO 10)
```

> **Attenzione:** Dimenticare il simbolo `#` e l'errore piu comune. `LDA 10` (senza `#`) cerchera di leggere il valore contenuto all'indirizzo 10 della memoria!

### Assoluto

L'indirizzo del dato segue l'istruzione:

```asm
LDA $D020   ; A = valore letto da $D020
STA $D020   ; scrive A in $D020
```

### Zero Page

Come assoluto, ma l'indirizzo e nei primi 256 byte (usa meno cicli CPU):

```asm
LDA $02     ; A = valore letto da $0002
STA $02     ; scrive A in $0002
```

> **Vantaggio:** Le istruzioni in Zero Page sono piu veloci e occupano meno byte.

### Indicizzato con X/Y

```asm
LDA $0400,X ; A = valore a ($0400 + X)
STA $D800,Y ; scrive A a ($D800 + Y)
```

---

## 2.3 Variabili in Zero Page

Possiamo dare nomi simbolici agli indirizzi:

```asm
; Definizioni inizio programma
XPOS    = $02
YPOS    = $03
TEMP    = $04

; Uso nel codice
    LDA #100
    STA XPOS    ; equivalente a STA $02

    LDA #50
    STA YPOS    ; equivalente a STA $03
```

---

## 2.4 Incrementare e decrementare

### `INX` / `INY` — Incrementa X o Y

```asm
LDX #0
INX         ; X = 1
INX         ; X = 2
```

### `DEX` / `DEY` — Decrementa X o Y

```asm
LDX #10
DEX         ; X = 9
DEX         ; X = 8
```

### `INC` / `DEC` — Incrementa/Decrementa in memoria

```asm
INC $D020   ; colore bordo +1
DEC $D021   ; colore sfondo -1
```

---

## 2.5 Matematica: ADC e SBC

### `ADC` — Addizione con Carry
Sempre usare `CLC` (Clear Carry) prima di una somma se non vuoi aggiungere il carry precedente.
```asm
CLC
LDA #10
ADC #5      ; A = 15
```

### `SBC` — Sottrazione con Carry
Sempre usare `SEC` (Set Carry) prima di una sottrazione.
```asm
SEC
LDA #20
SBC #5      ; A = 15
```

---

## 2.6 Confronti e salti condizionati

### `CMP`, `CPX`, `CPY` — Confronti

Queste istruzioni sottraggono il valore dal registro **senza modificarlo**, ma impostando i flag della CPU (Zero e Carry).

```asm
LDA #10
CMP #10     ; A == 10? Si → Zero flag = 1
CMP #5      ; A >= 5?  Si → Carry flag = 1
```

### `BEQ` — Branch if EQual

Salta se il confronto precedente ha dato uguaglianza:

```asm
LDA #10
CMP #10
BEQ UGUALE  ; salta a UGUALE perche A == 10
```

### `BNE` — Branch if Not Equal

Salta se il confronto NON ha dato uguaglianza:

```asm
LDA #5
CMP #10
BNE DIVERSO ; salta perche A != 10
```

### Tabella dei salti condizionati

| Istruzione | Salta se... |
|---|---|
| `BEQ` | A == valore (Zero = 1) |
| `BNE` | Registro != valore (Zero = 0) |
| `BCC` | Registro < valore (Carry = 0) |
| `BCS` | Registro >= valore (Carry = 1) |
| `BMI` | Risultato negativo (Negative = 1) |
| `BPL` | Risultato positivo (Negative = 0) |

---

## 2.7 Primo contatore

```asm
*=$C000

START
    LDX #0      ; X = 0 (inizializza contatore)

LOOP
    STX $D020   ; copia X nel bordo (cambia colore!)
    INX         ; X = X + 1
    JMP LOOP    ; ripeti
```

Il bordo andra da nero a bianco a rosso... fino al colore 255 poi ricomincia.

---

## 2.8 Ciclo con confronto

Facciamo un ciclo che conta da 0 a 10:

```asm
*=$C000

START
    LDX #0      ; contatore = 0

LOOP
    STX $D020   ; mostra il contatore sul bordo
    INX         ; contatore++
    CPX #10     ; abbiamo raggiunto 10?
    BNE LOOP    ; se no, continua

FINE
    JMP FINE    ; ciclo infinito (fine)
```

---

## 2.9 Operazioni Bitwise

### `AND`
Usata per "mascherare" dei bit.
```asm
LDA #%11001100
AND #%11110000  ; A = %11000000
```

### `ORA`
Usata per impostare dei bit.
```asm
LDA #%11000000
ORA #%00001111  ; A = %11001111
```

### `EOR`
Usata per invertire (flip) dei bit.
```asm
LDA #%11111111
EOR #%11110000  ; A = %00001111
```

---

## 2.10 Delay software (ritardo)

Per rallentare il programma e renderlo visibile:

```asm
DELAY
    LDX #$FF    ; carica 255
D1
    LDY #$FF    ; carica 255
D2
    DEY
    BNE D2      ; ciclo interno: 255 iterazioni
    DEX
    BNE D1      ; ciclo esterno: 255 iterazioni
    RTS
```

Questo ciclo produce circa 255 × 255 = ~65000 iterazioni.

### Uso del delay:

```asm
*=$C000

START
    LDA #2
    STA $D020

LOOP
    INC $D020   ; cambia colore
    JSR DELAY   ; aspetta
    JMP LOOP

DELAY
    LDX #$FF
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

> **💡 ESEMPIO SVOLTO — Rainbow effetto**  
> Questo esempio combina tutto quello che hai imparato finora. Non e un esercizio,
> ma un riferimento da studiare prima di affrontare gli esercizi qui sotto.
> (Nota: `JSR` e `RTS` verranno spiegati ufficialmente nel Capitolo 3, ma qui servono
> per tenere il codice pulito).

```asm
*=$C000

START
    LDA #0
    STA $D020   ; bordo nero

LOOP
    INC $D020   ; cambia colore
    JSR DELAY
    JMP LOOP

DELAY
    LDX #$20    ; ridotto per velocita media
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

## Esercizi

### Esercizio 1
Scrivi un programma che incrementi il bordo da 0 a 15 e poi si fermi (ciclo infinito alla fine).

### Esercizio 2
Scrivi un programma che tenga il contatore in Zero Page (es. `COUNTER = $02`) invece che in X.

### Esercizio 3
Crea un delay di circa 1 secondo (suggerimento: 3 cicli annidati).

### Esercizio 4
Fai lampeggiare lo sfondo tra blu e nero ogni secondo circa.

### Esercizio 5
Realizza l'effetto rainbow: il bordo deve scorrere attraverso tutti i colori in un ciclo infinito, usando un delay per rallentare il cambiamento (vedi "Esempio svolto" nella sezione 2.10).

---

## Riepilogo

Hai imparato:

- Modalita di indirizzamento (immediato, assoluto, Zero Page, indicizzato)
- Variabili in Zero Page
- `INX`, `DEX`, `INC`, `DEC`
- `CMP`, `BEQ`, `BNE`
- Creare contatori e cicli
- Delay software
- Strutturare il programma con sottoroutine (`JSR`)

## Riferimenti

- [Capitolo 1 — Introduzione](01-introduzione-c64-tmp.md) — prime istruzioni, memoria C64
- [Capitolo 3 — Indirizzamento e cicli](03-indirizzamento-cicli-ritardi.md) — modalita di indirizzamento avanzate
- [Soluzioni](../soluzioni/cap02-istruzioni.asm) — soluzioni degli esercizi
