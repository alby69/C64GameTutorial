# Appendice B — Glossario

## A

**A (Accumulator)** — Il registro principale del 6502. La maggior parte delle operazioni aritmetiche e logiche usano A.

**ADC** — Add with Carry. Somma un valore ad A tenendo conto del Carry.

**Addressing mode** — Modalita con cui un'istruzione specifica il dato da usare (immediato, assoluto, indicizzato, etc.).

**Arcade OS** — Concetto di kernel che tratta il gioco come un processo schedulato, con il raster interrupt come clock principale.

**ASCII** — American Standard Code for Information Interchange. Non usato direttamente sul C64, che usa PETSCII.

## B

**BCC** — Branch if Carry Clear. Salta se il flag Carry = 0.

**BCS** — Branch if Carry Set. Salta se il flag Carry = 1.

**BEQ** — Branch if EQual. Salta se il flag Zero = 1 (risultato = 0).

**BMI** — Branch if Minus. Salta se il flag Negative = 1.

**BNE** — Branch if Not Equal. Salta se il flag Zero = 0.

**Bounding box** — Rettangolo immaginario intorno a uno sprite usato per rilevare collisioni.

**BPL** — Branch if PLus. Salta se il flag Negative = 0.

**Branch** — Salto condizionato. Salta a un'altra parte del codice solo se una condizione e vera.

**Byte** — 8 bit. Unita base di memoria. Puo rappresentare valori da 0 a 255 ($00-$FF).

## C

**C64** — Commodore 64. Home computer a 8 bit del 1982 con CPU 6510 a ~1 MHz e 64 KB di RAM.

**Carry** — Flag della CPU usato nelle operazioni aritmetiche e nei confronti.

**Character** — Lettera, numero o simbolo visualizzabile a schermo. Sul C64 usa codifica PETSCII.

**CIA** — Complex Interface Adapter. Chip che gestisce joystick, timer e I/O.

**CLC** — Clear Carry. Imposta il flag Carry a 0.

**CLI** — Clear Interrupt. Riabilita gli interrupt dopo un SEI.

**CMP** — CoMPare. Confronta A con un valore, impostando i flag senza modificare A.

**Collision detection** — Rilevamento di quando due sprite o oggetti si toccano.

**CPX** — Compare X. Confronta X con un valore.

**CPY** — Compare Y. Confronta Y con un valore.

**CPU** — Central Processing Unit. Il processore.

**Cycle** — Ciclo di clock della CPU. Il 6510 a 1 MHz esegue circa 1 milione di cicli al secondo.

## D

**DEC** — DECrement. Diminuisce di 1 il valore in memoria.

**DEX** — DEcrement X. X = X - 1.

**DEY** — DEcrement Y. Y = Y - 1.

**Directive** — Istruzione per l'assembler (es. `*=$C000`, `.byte`), non per la CPU.

## E

**Edge detection** — Tecnica per rilevare il momento esatto in cui un tasto viene premuto (non se e tenuto premuto).

**Entity** — Oggetto logico nel gioco (player, nemico, proiettile) con posizione, stato e tipo.

**EOR** — Exclusive OR. Operazione logica XOR.

## F

**Flag** — Bit speciale della CPU che indica una condizione (Zero, Carry, Negative, Interrupt, etc.).

**Flicker** — Sfarfallio visibile quando uno sprite viene aggiornato nel momento sbagliato del raster.

**Frame** — Un'immagine completa sullo schermo. PAL = 50 frame/sec, NTSC = 60 frame/sec.

**Frame counter** — Variabile che si incrementa ogni frame per temporizzare eventi di gioco.

## G

**Gate** — Bit 0 del registro controllo SID. 1 = nota attiva, 0 = nota spenta.

## H

**HUD** — Heads-Up Display. Informazioni a schermo (punteggio, vite, barra vita).

**HW** — Hardware. Componenti fisici del computer.

## I

**INC** — INCrement. Aumenta di 1 il valore in memoria.

**Indexed addressing** — Modalita di indirizzamento in cui l'indirizzo effettivo e la somma di un indirizzo base + registro X o Y.

**INX** — INcrement X. X = X + 1.

**INY** — INcrement Y. Y = Y + 1.

**IRQ** — Interrupt ReQuest. Segnale che ferma temporaneamente la CPU per eseguire una routine speciale.

**ISR** — Interrupt Service Routine. La routine eseguita quando arriva un interrupt.

## J

**JMP** — JuMP. Salto incondizionato a un indirizzo.

**JSR** — Jump to SubRoutine. Salta a una sottoroutine, salvando l'indirizzo di ritorno sullo stack.

**Joystick** — Controller di gioco. Sul C64 si legge via CIA alle porte `$DC00` e `$DC01`.

## K

**KERNAL** — Il sistema operativo del C64 in ROM. Gestisce I/O, schermo, tastiera, etc.

**Kernel engine** — Parte fissa del codice che gestisce timing, interrupt e servizi di base.

## L

**Label** — Etichetta simbolica che rappresenta un indirizzo di memoria (es. `START`, `LOOP`).

**LDA** — LoaD Accumulator. Carica un valore nel registro A.

**LDX** — LoaD X. Carica un valore nel registro X.

**LDY** — LoaD Y. Carica un valore nel registro Y.

## M

**Memory map** — Mappa di come e organizzata la memoria del C64.

**MSB** — Most Significant Bit. Il bit piu significativo (bit 7 di un byte).

**Multiplexing** — Tecnica per mostrare piu di 8 sprite riutilizzando gli sprite HW in diverse zone dello schermo.

## N

**Negative** — Flag della CPU. Viene impostato quando il risultato di un'operazione ha bit 7 = 1.

**Noise** — Forma d'onda del SID che produce rumore bianco. Usata per esplosioni e effetti.

## O

**ORG** — Directive dell'assembler che specifica l'indirizzo in cui generare il codice (`*=$C000`).

## P

**PAL** — Phase Alternating Line. Standard video europeo: 50 frame/sec, 312 raster line.

**Parallax** — Illusione di profondita ottenuta muovendo strati dello schermo a velocita diverse.

**PETSCII** — Codice caratteri del Commodore. Diverso dall'ASCII standard.

**PHA** — PusH Accumulator. Salva A sullo stack.

**PHP** — PusH Processor status. Salva i flag sullo stack.

**PLA** — PulL Accumulator. Recupera A dallo stack.

**PLP** — PulL Processor status. Recupera i flag dallo stack.

**Pointer** — Indirizzo 2 byte (low/high) che punta a una locazione di memoria.

**Pool** — Array statico di oggetti riutilizzabili (es. pool di proiettili).

**Pseudo-AI** — Comportamento simulato che sembra intelligente ma segue regole deterministiche.

## R

**RAM** — Random Access Memory. Memoria di lavoro leggibile e scrivibile.

**Raster** — Il fascio elettronico che disegna lo schermo una riga alla volta.

**Raster interrupt** — Interrupt generato dal VIC-II quando il raster raggiunge una riga specifica.

**Raster line** — Una singola riga orizzontale dello schermo.

**Raster split** — Tecnica di dividere lo schermo in zone con registri VIC-II diversi.

**ROM** — Read Only Memory. Memoria di sola lettura (contiene BASIC e KERNAL).

**RTI** — ReTurn from Interrupt. Termina una routine di interrupt.

**RTS** — ReTurn from Subroutine. Termina una sottoroutine e torna al chiamante.

## S

**SBC** — SuBtract with Carry. Sottrae un valore da A tenendo conto del Carry.

**Screen RAM** — Area di memoria `$0400`-$07E7` che contiene i caratteri visualizzati.

**SEI** — SEt Interrupt. Disabilita temporaneamente gli interrupt.

**SID** — Sound Interface Device. Chip audio del C64 a 3 voci.

**Sprite** — Immagine indipendente 24x21 pixel che il VIC-II disegna senza ridisegnare lo schermo.

**Sprite pointer** — Byte in `$07F8`-$07FF` che indica l'indirizzo dei dati dello sprite (indirizzo/64).

**Square wave** — Forma d'onda del SID. Suono pieno, usata per melodie e effetti.

**Stack** — Area di memoria `$0100`-$01FF` per salvare indirizzi di ritorno e dati temporanei.

**STA** — STore Accumulator. Scrive il contenuto di A in memoria.

**State machine** — Modello di comportamento con stati ben definiti e transizioni.

**SW** — Software. Programmi e codice.

## T

**TAX** — Transfer A to X. Copia A in X.

**TAY** — Transfer A to Y. Copia A in Y.

**TMP** — Turbo Macro Pro. Assembler per C64 con editor integrato.

**Triangle** — Forma d'onda del SID. Suono piu dolce, usata per effetti.

**TXA** — Transfer X to A. Copia X in A.

**TYA** — Transfer Y to A. Copia Y in A.

## V

**VIC-II** — Video Interface Controller. Chip grafico del C64 che gestisce sprite, schermo, raster, etc.

## W

**Wave** — Ondata di nemici nel gioco. Sistema che gestisce spawn e progressione.

**Waveform** — Forma d'onda del SID (square, triangle, sawtooth, noise).

## X

**X** — Registro indice del 6502. Usato come contatore o offset.

## Y

**Y** — Secondo registro indice del 6502.

## Z

**Zero flag** — Flag della CPU. Si attiva quando il risultato di un'operazione e 0.

**Zero Page** — Primi 256 byte di memoria (`$0000`-$00FF`). Accesso piu veloce.

---

## Simboli

`$` — Prefisso per numeri esadecimali in TMP (es. `$FF` = 255).

`#` — Prefisso per valori immediati (es. `LDA #$10`).

`%` — Prefisso per numeri binari (es. `%00000001`).

`*=` — Direttiva ORG in TMP (es. `*=$C000`).
