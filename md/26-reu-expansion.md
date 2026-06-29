# Capitolo 26 — REU (RAM Expansion Unit)

## Obiettivi

Al termine di questo capitolo saprai:

- Cos'e la REU 1700/1750/1764
- Usare il DMA controller per copiare dati rapidamente
- Espandere la memoria del C64 oltre 64 KB
- Implementare swap di banchi per livelli enormi
- Usare la REU per salvataggio dati persistente

---

## 26.1 Cos'e la REU?

La RAM Expansion Unit (REU) e un dispositivo che aggiunge RAM
al C64 tramite la porta cartridge. Ne esistono tre versioni:

```
Modello   | RAM    | Note
─────────────────────────────────
1700      | 128 KB | Prima versione
1750      | 512 KB | La piu comune
1764      | 256 KB | Per C64C
```

La REU appare come spazio di indirizzi `$DF00-$DF0F` e usa
il DMA (Direct Memory Access) per trasferire blocchi tra
la REU e la RAM principale senza coinvolgere la CPU.

---

## 26.2 Registri della REU ($DF00-$DF0F)

| Indirizzo | Nome | Descrizione |
|-----------|------|-------------|
| `$DF00` | `COMMAND` | Comando (bit 7=start, bit 6=dir, bit 4=FF00 mode, bit 0=3: autoload) |
| `$DF01` | `STATUS` | Stato (bit 7=end block, bit 6=fault, bit 1=handshake, bit 0=BSY) |
| `$DF02` | `REU_ADDR_L` | Indirizzo REU low |
| `$DF03` | `REU_ADDR_H` | Indirizzo REU high |
| `$DF04` | `REU_ADDR_B` | Bancone REU (256 KB blocchi) |
| `$DF05` | `C64_ADDR_L` | Indirizzo C64 low |
| `$DF06` | `C64_ADDR_H` | Indirizzo C64 high |
| `$DF07` | `C64_ADDR_B` | Bancone C64 (64 KB blocchi) |
| `$DF08` | `LENGTH_L` | Lunghezza trasferimento low |
| `$DF09` | `LENGTH_H` | Lunghezza trasferimento high |
| `$DF0A` | `IRQ_MASK` | Maschera interrupt |
| `$DF0B` | `CONTROL` | Controllo (bit 6=FF00, bit 4=Int, bit 3=dep, bit 2=IE) |

---

## 26.3 Copiare Dati tra REU e C64

### C64 → REU (salva)

```asm
; Salva 256 byte da $C000 nella REU all'indirizzo $0000
*= $C000

    ; Indirizzo REU = $000000
    LDA #0
    STA $DF02          ; REU_ADDR_L
    STA $DF03          ; REU_ADDR_H
    STA $DF04          ; REU_ADDR_B

    ; Indirizzo C64 = $C000
    LDA #$00
    STA $DF05          ; C64_ADDR_L
    LDA #$C0
    STA $DF06          ; C64_ADDR_H
    LDA #0
    STA $DF07          ; C64_ADDR_B

    ; Lunghezza = 256 byte ($00 = 256)
    LDA #0
    STA $DF08          ; LENGTH_L
    LDA #0
    STA $DF09          ; LENGTH_H

    ; Comando: scrivi C64 → REU
    ; bit 7=1 (start), bit 6=0 (C64→REU, non FF00)
    LDA #%10000000
    STA $DF00          ; COMMAND

    RTS
```

### REU → C64 (carica)

```asm
; Carica 256 byte dalla REU ($000000) a $C000
*= $C000

    ; Stessi indirizzi e lunghezza
    LDA #0
    STA $DF02
    STA $DF03
    STA $DF04
    STA $DF07
    LDA #$00
    STA $DF05
    LDA #$C0
    STA $DF06
    LDA #0
    STA $DF08
    STA $DF09

    ; Comando: bit 7=1 (start), bit 6=1 (REU→C64)
    LDA #%11000000
    STA $DF00

    RTS
```

---

## 26.4 Aspettare il DMA

Il DMA richiede tempo. Bisogna attendere che finisca:

```asm
; Attendi completamento DMA
WAIT_DMA
    LDA $DF01          ; STATUS register
    AND #%00000001     ; bit 0 = busy
    BNE WAIT_DMA       ; busy → aspetta
    RTS
```

---

## 26.5 Swap di Banchi per Livelli

Con una REU da 512 KB si possono tenere 8 livelli da 64 KB:

```
Livello 1 → REU $000000-$00FFFF
Livello 2 → REU $010000-$01FFFF
...
Livello 8 → REU $070000-$07FFFF
```

```asm
; Carica livello N dalla REU
; Input: A = numero livello (0-7)
LOAD_LEVEL
    ; Calcola indirizzo REU: livello * $10000
    STA TEMP
    ASL
    ROL
    STA $DF04          ; REU_ADDR_B = livello * $10000 >> 16

    ; C64 da $0000 a $FFFF (l'intero spazio)
    LDA #0
    STA $DF02
    STA $DF03
    STA $DF05
    STA $DF06
    STA $DF07

    ; Lunghezza = $0000 (65536 byte)
    STA $DF08
    STA $DF09

    ; Avvia DMA REU→C64
    LDA #%11000000
    STA $DF00

    JSR WAIT_DMA
    RTS

TEMP
    .byte 0
```

---

## 26.6 Usare la REU per Salvataggio Dati

Invece di salvare su disco, si puo usare la REU per tenere
dati tra sessioni (se la REU e alimentata).

```asm
; Salva stato di gioco in REU
SAVE_GAME_STATE
    ; Copia 64 byte di variabili gioco nella REU
    LDA #0
    STA $DF02
    STA $DF03
    STA $DF04

    ; Indirizzo C64 = indirizzo delle variabili di gioco
    LDA #<GAME_VARS
    STA $DF05
    LDA #>GAME_VARS
    STA $DF06

    LDA #64
    STA $DF08
    LDA #0
    STA $DF09

    LDA #%10000000     ; C64 → REU
    STA $DF00
    JSR WAIT_DMA
    RTS
```

---

## 26.7 Limitazioni

- Richiede hardware REU (non comune)
- Il C64C con REU 1764 deve avere l'alimentatore potenziato
- Non tutti i giochi supportano la REU
- La REU 1700 ha solo 128 KB (2 banchi da 64 KB)

---

## Esercizi

### Esercizio 1
Scrivi una routine che copia 256 byte da $C000 all'indirizzo $000000 della REU.

### Esercizio 2
Scrivi la routine inversa: carica 512 byte dalla REU ($001000) a $A000.

### Esercizio 3
Implementa WAIT_DMA e usala per copiare dati in modo sincrono.

### Esercizio 4
Crea un sistema di 4 livelli in REU: quando il giocatore passa al livello
successivo, carica il livello dalla REU invece che dal disco.

### Esercizio 5
Usa la REU per salvare lo stato di gioco completo (punteggio, livello,
posizione player) e ricaricarlo dopo un reset (REU retained).

---

## Riferimenti

- [Capitolo 21 — Caricatore Personalizzato](21-caricatore-personalizzato.md) — load da disco vs REU
- [$DF00-$DF0F — REU registers](appendice-a-tabelle.md) — mappa registri
- [Soluzioni](../soluzioni/cap26-reu-expansion.asm) — soluzioni degli esercizi
