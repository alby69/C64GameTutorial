# Capitolo 21 — Caricatore Personalizzato

> **Obiettivo:** Sostituire il `LOAD"*",8,1` di BASIC con un caricatore scritto in assembly,
> aggiungendo effetti visivi durante il caricamento e controllo diretto del drive.

---

## 21.1 Perche un caricatore personalizzato?

Finora abbiamo caricato i programmi con:

```
LOAD"NOME",8,1
SYS 49152
```

Questo funziona, ma ha limiti:

- **Schermo nero** durante il caricamento
- **Nessun feedback** per l'utente
- **Velocita standard** (circa 400 byte/s)
- **Dipende dal KERNAL** — non abbiamo controllo sul drive

Un caricatore personalizzato risolve tutto questo:
- Barre di progresso o raster bar durante il load
- Effetti grafici (bordo che cambia colore)
- Possibile accelerazione del trasferimento
- Controllo totale del processo

---

## 21.2 Il KERNAL Load

La routine di caricamento del KERNAL si chiama `SETNAM` + `SETLFS` + `LOAD`.

```asm
; Carica un file con il KERNAL
*= $C000

    ; Nome del file
    LDA #6             ; lunghezza nome
    LDX #<FILENAME     ; indirizzo basso
    LDY #>FILENAME     ; indirizzo alto
    JSR $FFBD          ; SETNAM

    ; Parametri dispositivo
    LDA #1             ; numero file logico
    LDX #8             ; device number (8 = drive)
    LDY #1             ; comando (0=load, 1=verify, >0=load)
    JSR $FFBA          ; SETLFS

    ; Carica
    LDA #0             ; 0 = caricamento (non verify)
    LDX #<LOAD_ADDR    ; indirizzo alternativo (0 = dal file)
    LDY #>LOAD_ADDR
    JSR $FFD5          ; LOAD
    ; A = ultimo byte caricato (se caricamento diretto)

    ; Esegui il programma caricato
    JMP $C000

FILENAME
    .text "MIOGIOCO"
```

### Parametri LOAD ($FFD5)

| Registro | Significato |
|---|---|
| A | 0 = caricamento, 1 = verify |
| X | Low byte indirizzo alternativo |
| Y | High byte indirizzo alternativo |
| (XY=0) | Usa l'indirizzo salvato nel file .prg |

---

## 21.3 Effetto Raster Durante il Caricamento

Il problema e che `JSR $FFD5` blocca la CPU finche il caricamento non finisce.
Non possiamo eseguire codice durante il trasferimento... **a meno che non usiamo
un interrupt IRQ che continua a funzionare**.

```asm
; Caricatore con raster bar sullo sfondo
; L'IRQ continua a funzionare durante il LOAD KERNAL

*= $C000

    ; Setup IRQ per raster bar
    SEI
    LDA #<MY_IRQ
    STA $0314
    LDA #>MY_IRQ
    STA $0315
    LDA #100
    STA $D012
    LDA #1
    STA $D01A
    CLI

    ; Chiama LOAD KERNAL (l'IRQ continua a correre)
    LDA #6
    LDX #<FNAME
    LDY #>FNAME
    JSR $FFBD
    LDA #1
    LDX #8
    LDY #1
    JSR $FFBA
    LDA #0
    LDX #0
    LDY #0
    JSR $FFD5          ; Carica — IRQ attivo durante!

    ; Caricamento finito, disabilita IRQ
    SEI
    LDA #$7F
    STA $DC0D
    LDA #0
    STA $D01A
    CLI

    ; Salta al gioco caricato
    JMP $C000

MY_IRQ
    INC $D020          ; Cambia colore bordo
    LDA $D019
    STA $D019          ; ACK
    RTI

FNAME
    .text "MIOGIOCO"
```

**Nota:** Non tutti i sistemi di drive supportano IRQ durante il LOAD KERNAL
(JiffyDOS si, stock 1541 a volte no). Su hardware reale, testare.

---

## 21.4 Caricamento Settore per Settore

Per il controllo totale, dobbiamo parlare direttamente al drive via seriale.
Usiamo le routine del KERNAL per la comunicazione IEC:

```asm
; Legge un settore dal disco
*= $C000

    ; Apre canale di comando al drive
    LDA #0
    LDX #8
    LDY #15            ; canale 15 = comando
    JSR $FFBA          ; SETLFS
    LDA #$1F
    LDX #<CMD
    LDY #>CMD
    JSR $FFBD          ; SETNAM
    JSR $FFC0          ; OPEN
    ; Ora possiamo inviare comandi al drive

    ; Apre canale di lettura
    LDA #2
    LDX #8
    LDY #2             ; canale 2
    JSR $FFBA
    LDA #0             ; nessun nome
    JSR $FFBD
    JSR $FFC0          ; OPEN canale 2

    ; Legge 254 byte dal canale
    LDX #2             ; canale 2
    JSR $FFC6          ; CHKIN
    LDY #0
READ_LOOP
    JSR $FFE4          ; CHRIN (legge un byte)
    STA $C000,Y
    INY
    CPY #254
    BNE READ_LOOP

    JSR $FFCC          ; CLRCHN
    RTS

CMD
    .null "UI"         ; comando: reset drive
```

---

## 21.5 Turbo Loader — Concetto Base

Un turbo loader accelera il trasferimento modificando il protocollo seriale:

```
Velocita standard KERNAL:   ~400 byte/s
Velocita turbo loader:     ~2000-4000 byte/s
```

Il trucco: invece di usare le routine KERNAL (`$FFE4`), si scrive direttamente
sulle porte CIA per la comunicazione seriale, riducendo i cicli di attesa.

```asm
; Lettura veloce di un byte dal drive (schema)
; NOTA: codice semplificato — un turbo loader reale richiede
;       sincronizzazione con il drive che deve essere programmato
;       a sua volta (spesso con un secondo caricatore sul drive)

FAST_READ
    ; Clock line bassa → drive invia dati
    LDA $DD00         ; porta seriale
    AND #$10          ; maschera DATA line
    BEQ BIT_ZERO
    ; Qui abbiamo un bit = 1
    ROL TEMP
    JMP NEXT_BIT
BIT_ZERO
    ; Qui abbiamo un bit = 0
    ROR TEMP
NEXT_BIT
    ; ... ripetere per 8 bit ...
    LDA TEMP
    RTS
```

---

## 21.6 Loader con Feedback Visivo

Un caricatore "elegante" mostra qualcosa a schermo mentre carica:

```asm
; Caricatore con barra di progresso
*= $C000

    ; Prepara schermata di caricamento
    JSR SETUP_SCREEN

    ; Apre file
    LDA #6
    LDX #<FNAME
    LDY #>FNAME
    JSR $FFBD
    LDA #1
    LDX #8
    LDY #1
    JSR $FFBA

    ; Carica (con setup IRQ attivo per l'effetto)
    SEI
    LDA #<LOAD_IRQ
    STA $0314
    LDA #>LOAD_IRQ
    STA $0315
    LDA #50
    STA $D012
    LDA #1
    STA $D01A
    CLI

    LDA #0
    LDX #0
    LDY #0
    JSR $FFD5

    ; Pulizia
    SEI
    LDA #$7F
    STA $DC0D
    LDA #0
    STA $D01A
    CLI

    JMP $C000

LOAD_IRQ
    ; Barra caricamento: espande un rettangolo colore
    INC $D020
    LDA FRAME
    CLC
    ADC #40
    STA FRAME
    ; Colora una cella in piu ad ogni IRQ
    LDX FRAME
    LDA #1
    STA $D800,X
    LDA $D019
    STA $D019
    RTI

FRAME
    .byte 0

FNAME
    .text "MIOGIOCO"

SETUP_SCREEN
    ; Scrivi "CARICAMENTO IN CORSO..."
    LDX #0
LOOP
    LDA LOADMSG,X
    STA $0400+40*12+5,X
    LDA #1
    STA $D800+40*12+5,X
    INX
    CPX #20
    BNE LOOP
    ; Disegna bordo barra
    LDX #0
BAR
    LDA #102
    STA $0400+40*14,X
    LDA #5
    STA $D800+40*14,X
    INX
    CPX #40
    BNE BAR
    RTS

LOADMSG
    .text "CARICAMENTO IN CORSO..."
```

---

## 21.7 Struttura Completa di un Gioco con Loader

```
 Disco:
 ┌─────────────────────────────────────┐
 │  BOOT LOADER (1 blocco)             │
 │  Carica e lancia il LOADER PRINCI-  │
 │  PALE con effetti                   │
 ├─────────────────────────────────────┤
 │  LOADER PRINCIPALE (10-20 blocchi)  │
 │  - Schermata di caricamento         │
 │  - Effetti raster / barra           │
 │  - Carica il GIOCO                  │
 ├─────────────────────────────────────┤
 │  GIOCO (100-200 blocchi)            │
 │  - Codice                           │
 │  - Dati sprite                      │
 │  - Mappe                            │
 │  - Musica SID                       │
 └─────────────────────────────────────┘
```

### Codice Boot (primo caricamento)

```asm
; Boot loader — si carica con LOAD"*",8,1
; e carica il vero loader
*= $801

    ; Stampa messaggio
    LDX #0
MSG
    LDA TEXT,X
    BEQ SKIP
    JSR $FFD2
    INX
    JMP MSG
SKIP
    ; Carica il loader principale
    LDA #14            ; lunghezza nome
    LDX #<FNAME
    LDY #>FNAME
    JSR $FFBD
    LDA #1
    LDX #8
    LDY #1
    JSR $FFBA
    LDA #0
    LDX #0
    LDY #0
    JSR $FFD5          ; carica "LOADER.PRG"

    ; Salta al loader
    JMP $C000

TEXT
    .byte 147          ; CLR/HOME
    .text "AVVIO CARICAMENTO..."
    .byte 13,0

FNAME
    .text "LOADER.PRG"
```

---

## 21.8 Riepilogo — Checklist Loader

- [ ] Decidi se usare LOAD KERNAL (semplice) o seriale diretto (complesso)
- [ ] Prepara schermata di caricamento con messaggio
- [ ] Aggiungi effetto visivo (raster bar, bordo animato, barra progresso)
- [ ] Mantieni IRQ attivo durante il caricamento
- [ ] Alla fine, disabilita IRQ e salta al gioco
- [ ] Per giochi grandi: struttura multi-caricamento (boot → loader → gioco)
- [ ] Test su hardware reale (non solo emulatore)
- [ ] Verifica compatibilita drive (1541, 1571, 1581, SD2IEC)

---

## Esercizi

### Esercizio 1
Scrivi un caricatore KERNAL che carichi un file chiamato "GIOCO.PRG" e lo esegua.

### Esercizio 2
Aggiungi un effetto raster bar al caricatore dell'esercizio 1 (bordo che cambia colore durante il caricamento).

### Esercizio 3
Crea una schermata di caricamento con "CARICAMENTO IN CORSO..." e una barra di progresso fatta di caratteri `$A0`.

### Esercizio 4
Struttura un gioco in 3 file separati: boot loader, loader con effetti, e gioco vero e proprio. Scrivi il codice per il boot che carica il loader.

### Esercizio 5
Scrivi un programma che usi il canale seriale ($DD00) per leggere UN byte dal drive, senza usare le routine KERNAL (solo per esplorare il controllo diretto).

---

## Riferimenti

- [Capitolo 7 — Raster Interrupt](07-raster-interrupt.md) — per gli effetti durante il caricamento
- [Capitolo 13 — Stati gioco](13-punteggio-e-stati-gioco.md) — struttura MENU/PLAY con loader
- [Appendice A — Tabelle](appendice-a-tabelle.md) — KERNAL jump table ($FFD5, $FFBD, etc.)
- [Appendice TMP — Turbo Macro Pro](appendice-turbo-macro-pro.md) — per assemblare il loader
- Commodore 64 Programmer's Reference Guide — capitolo sulla seriale IEC
