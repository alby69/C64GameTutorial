# Capitolo 25 — Caricatore Turbo

## Obiettivi

Al termine di questo capitolo saprai:

- Comprendere il formato GCR del disco 1541
- Leggere byte direttamente dalla seriale ($DD00)
- Implementare un IRQ loader per caricare durante il raster
- Usare il parallel cable per trasferimento veloce
- Integrare un fast loader nel gioco

---

## 25.1 Perché un Caricatore Turbo?

Il LOAD KERNAL (`$FFD5`) è lento perche usa il protocollo seriale
standard a circa 400 byte/sec. Un caricatore turbo puo arrivare a
2-4 KB/sec leggendo i dati grezzi dal disco (GCR).

```
KERNAL LOAD:  ~400 byte/sec
Fast loader:  ~2000-4000 byte/sec (5-10x piu veloce)
```

---

## 25.2 La Seriale del C64 ($DD00)

Il C64 comunica con il drive 1541 via CIA2, porta seriale a `$DD00`.

```asm
; Leggere lo stato della seriale
SERIAL_PORT = $DD00

; Bit della seriale:
;   bit 0-1: bank VIC-II
;   bit 2:   ATN out
;   bit 3:   CLK out
;   bit 4:   DATA out
;   bit 5:   CLK in
;   bit 6:   DATA in
;   bit 7:   —
```

Per leggere un bit dal drive:

```asm
; Leggi DATA line
LDA $DD00
AND #$40          ; bit 6 = DATA in
BNE BIT_HIGH
```

---

## 25.3 Formato GCR

Il 1541 memorizza i dati in formato GCR (Group Code Recording):
ogni 4 bit di dati diventano 5 bit GCR.

```
Nibble dati → GCR
0000 → 01010
0001 → 01011
0010 → 10010
0011 → 10011
0100 → 01110
0101 → 01111
0110 → 10110
0111 → 10111
1000 → 01001
1001 → 11001
1010 → 11010
1011 → 11011
1100 → 01101
1101 → 11101
1110 → 11110
1111 → 11111
```

Tabella GCR per decodifica (256 byte):

```asm
GCR_DECODE
    .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .byte $FF,     ; 00100000
    .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .byte $FF, $08 ; 00101000 = 1000
    .byte $FF, $09 ; 00101001 = 1001
    .byte $FF, $0A ; 00101010 = 1010
    .byte $FF, $0B ; 00101011 = 1011
    ; ... (tabella completa: indice = GCR byte, valore = nibble dati)
```

---

## 25.4 IRQ Loader

Un IRQ loader carica dati durante i frame, senza bloccare il gioco:

```asm
; IRQ loader — carica un byte ogni frame
IRQ_LOADER
    ; Stato 0: cerca sync mark
    LDA LOAD_STATE
    CMP #0
    BEQ IL_SYNC
    CMP #1
    BEQ IL_BYTE
    RTS

IL_SYNC
    ; Cerca sincronia (bits 1)
    LDA $DD00
    AND #$40
    BNE IL_SYNC
    INC LOAD_STATE
    RTS

IL_BYTE
    ; Leggi 8 bit GCR
    LDX #8
IL_BIT
    LDA $DD00
    AND #$40
    BEQ IL_ZERO
    ; Bit = 1
    ROL TEMP
    SEC
    JMP IL_NEXT
IL_ZERO
    ; Bit = 0
    ROL TEMP
    CLC
IL_NEXT
    DEX
    BNE IL_BIT

    ; Decodifica GCR e salva in buffer
    LDY LD_PTR
    LDA TEMP
    STA GCR_BUF,Y
    INY
    STY LD_PTR
    LDA #0
    STA LOAD_STATE

    ; Se buffer pieno, esci
    CPY #$FF
    BEQ IL_DONE
    RTS

IL_DONE
    LDA #$FF
    STA LOAD_DONE
    RTS

LOAD_STATE
    .byte 0
LD_PTR
    .byte 0
LOAD_DONE
    .byte 0
GCR_BUF
    .byte 0
```

---

## 25.5 Parallel Cable

Il cavo parallelo (o cavo X1541) collega le linee dati del drive
direttamente alla porta utente del C64 ($A000-$A003),
permettendo trasferimenti a 8 bit alla volta.

```asm
; Lettura con parallel cable
PARALLEL_READ
    ; La porta utente ha i dati alle linee PA0-PA7
    LDA $A001          ; User port data lines
    ; Ora A contiene un byte intero (8 bit)
    RTS
```

Il parallel cable richiede hardware aggiuntivo ma puo arrivare
a 8-10 KB/sec.

---

## 25.6 Fast Loader Integrato nel Gioco

Nel ciclo di gioco, si possono caricare livelli in background
durante il game loop:

```asm
FAST_LOAD_TICK
    LDA LOAD_DONE
    BNE FLT_DONE

    JSR IRQ_LOADER

    ; Aggiorna barra di progresso
    LDX LD_BYTE_COUNT
    LDA #$A0
    STA SCREEN_RAM+40*23,X
    LDA #5
    STA COLOR_RAM+40*23,X

FLT_DONE
    RTS
```

---

## 25.7 Confronto Prestazioni

```
Metodo                           Velocita
──────────────────────────────────────────
LOAD KERNAL ($FFD5)              ~400 byte/s
IRQ loader (GCR)                   ~1200 byte/s
Fast loader GCR ottimizzato        ~2500 byte/s
Parallel cable                     ~8000 byte/s
```

---

## Esercizi

### Esercizio 1
Scrivi una subroutine che legge un byte dalla seriale ($DD00) usando
il bit DATA in (bit 6). Non serve ancora decodifica GCR.

### Esercizio 2
Implementa la tabella di decodifica GCR e usala per convertire
un byte GCR letto dalla seriale in un nibble (4 bit).

### Esercizio 3
Costruisci un IRQ loader che carica un byte per frame in background,
senza bloccare il game loop. Usa un buffer circolare.

### Esercizio 4
Integra il fast loader nel gioco: durante la schermata titolo o
tra un livello e l'altro, mostra una barra di progresso.

### Esercizio 5
Confronta la velocita del LOAD KERNAL con il tuo fast loader:
quanto tempo impiega ciascuno per caricare 8 KB?

---

## Riferimenti

- [Capitolo 21 — Caricatore Personalizzato](21-caricatore-personalizzato.md) — basi KERNAL LOAD/SAVE
- [$DD00 — CIA2](appendice-a-tabelle.md) — porta seriale
- [Soluzioni](../soluzioni/cap25-turbo-loader.asm) — soluzioni degli esercizi
