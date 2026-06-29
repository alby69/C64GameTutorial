# Appendice A — Tabelle di Riferimento

## Tabella colori C64

| Valore | Colore | Esadecimale |
|---|---|---|
| 0 | Nero | `$00` |
| 1 | Bianco | `$01` |
| 2 | Rosso | `$02` |
| 3 | Ciano | `$03` |
| 4 | Viola | `$04` |
| 5 | Verde | `$05` |
| 6 | Blu | `$06` |
| 7 | Giallo | `$07` |
| 8 | Arancione | `$08` |
| 9 | Marrone | `$09` |
| 10 | Rosa chiaro | `$0A` |
| 11 | Grigio scuro | `$0B` |
| 12 | Grigio medio | `$0C` |
| 13 | Verde chiaro | `$0D` |
| 14 | Blu chiaro | `$0E` |
| 15 | Grigio chiaro | `$0F` |

---

## Mappa memoria C64

| Indirizzo | Dimensione | Descrizione |
|---|---|---|
| `$0000`-`$00FF` | 256 byte | Zero Page (RAM veloce) |
| `$0100`-`$01FF` | 256 byte | Stack |
| `$0200`-`$03FF` | 512 byte | Area sistema/variabili |
| `$0400`-`$07E7` | 1000 byte | Screen RAM (schermo testo) |
| `$07F8`-`$07FF` | 8 byte | Sprite pointer |
| `$0800`-`$9FFF` | — | RAM libera |
| `$A000`-`$BFFF` | — | BASIC ROM |
| `$C000`-`$CFFF` | — | RAM |
| `$D000`-`$DFFF` | — | VIC-II / SID / CIA |
| `$E000`-`$FFFF` | — | KERNAL ROM |

---

## Registri VIC-II (video)

### Indirizzi principali

| Registro | Indirizzo | Descrizione |
|---|---|---|
| `SPRITE_X` | `$D000`-`$D00F` | Coordinate X/Y sprite 0-7 |
| `SPRITE_MSB_X` | `$D010` | Bit 0-7: MSB X per sprite 0-7 |
| `VIC_CTRL1` | `$D011` | Bit 4-5: scroll Y, Bit 7: MSB raster |
| `RASTER` | `$D012` | Raster line corrente/confronto |
| `VIC_CTRL2` | `$D016` | Bit 0-2: scroll X, Bit 3: 38/40 colonne |
| `SPRITE_ENABLE` | `$D015` | Abilitazione sprite (1 bit per sprite) |
| `SPRITE_EXPAND_Y` | `$D017` | Espansione verticale |
| `SPRITE_EXPAND_X` | `$D01D` | Espansione orizzontale |
| `SPRITE_MULTICOLOR` | `$D01C` | Modalita multicolore |
| `SPRITE_BG_PRIO` | `$D01B` | Priorita sprite/sfondo |
| `SPRITE_COL_0` | `$D025` | Colore comune multicolore 0 |
| `SPRITE_COL_1` | `$D026` | Colore comune multicolore 1 |
| `SPRITE_COLOR` | `$D027`-`$D02E` | Colori sprite 0-7 |
| `BORDER_COLOR` | `$D020` | Colore bordo |
| `BG_COLOR` | `$D021` | Colore sfondo |
| `BG_COLOR_1` | `$D022` | Colore sfondo 1 |
| `BG_COLOR_2` | `$D023` | Colore sfondo 2 |
| `BG_COLOR_3` | `$D024` | Colore sfondo 3 |
| `IRQ_ENABLE` | `$D01A` | Abilitazione interrupt |
| `IRQ_STATUS` | `$D019` | Stato interrupt (acknowledge) |
| `SPRITE_COLL` | `$D01E` | Collisioni sprite-sprite |
| `SPRITE_BG_COLL` | `$D01F` | Collisioni sprite-sfondo |
| `COLOR_RAM` | `$D800`-`$DBE7` | Colori caratteri |

### Sprite pointer ($07F8-$07FF)

| Indirizzo | Sprite | Formula pointer |
|---|---|---|
| `$07F8` | Sprite 0 | Pointer = indirizzo_dati / 64 |
| `$07F9` | Sprite 1 | — |
| `$07FA` | Sprite 2 | — |
| `$07FB` | Sprite 3 | — |
| `$07FC` | Sprite 4 | — |
| `$07FD` | Sprite 5 | — |
| `$07FE` | Sprite 6 | — |
| `$07FF` | Sprite 7 | — |

---

## Registri SID (audio)

| Indirizzo | Voce | Descrizione |
|---|---|---|
| `$D400` | 1 | Frequenza low |
| `$D401` | 1 | Frequenza high |
| `$D404` | 1 | Controllo (gate, waveform) |
| `$D405` | 1 | Attack/Decay |
| `$D406` | 1 | Sustain/Release |
| `$D410` | 2 | Frequenza low |
| `$D411` | 2 | Frequenza high |
| `$D414` | 2 | Controllo |
| `$D415` | 2 | Attack/Decay |
| `$D416` | 2 | Sustain/Release |
| `$D420` | 3 | Frequenza low |
| `$D421` | 3 | Frequenza high |
| `$D424` | 3 | Controllo |
| `$D425` | 3 | Attack/Decay |
| `$D426` | 3 | Sustain/Release |
| `$D418` | Globale | Volume (0-15) |

### Forme d'onda (registro controllo)

| Valore | Waveform | Descrizione |
|---|---|---|
| `$10` | Square | Solo waveform (gate OFF) |
| `$11` | Square | Square wave + gate ON |
| `$20` | Triangle | Solo triangle (gate OFF) |
| `$21` | Triangle | Triangle + gate ON |
| `$40` | Sawtooth | Solo sawtooth |
| `$41` | Sawtooth | Sawtooth + gate ON |
| `$80` | Noise | Solo noise |
| `$81` | Noise | Noise + gate ON |

---

## Registri CIA (joystick)

| Indirizzo | Descrizione |
|---|---|
| `$DC00` | Porta joystick 2 |
| `$DC01` | Porta joystick 1 |
| `$DC0D` | CIA Interrupt Control |

### Bit joystick porta 1 ($DC01)

| Bit | Direzione | Attivo |
|---|---|---|
| 0 | Su | 0 |
| 1 | Giu | 0 |
| 2 | Sinistra | 0 |
| 3 | Destra | 0 |
| 4 | Pulsante | 0 |
| 5-7 | Non usati | 1 |

---

## Istruzioni 6502 essenziali

### Trasferimento dati

| Istruzione | Descrizione |
|---|---|
| `LDA #val` | Carica immediato in A |
| `LDA addr` | Carica da indirizzo in A |
| `LDX #val` | Carica immediato in X |
| `LDY #val` | Carica immediato in Y |
| `STA addr` | Scrivi A in indirizzo |
| `STX addr` | Scrivi X in indirizzo |
| `STY addr` | Scrivi Y in indirizzo |

### Aritmetiche

| Istruzione | Descrizione |
|---|---|
| `ADC #val` | A = A + val + Carry |
| `SBC #val` | A = A - val - (1-Carry) |
| `INC addr` | addr = addr + 1 |
| `DEC addr` | addr = addr - 1 |
| `INX` | X = X + 1 |
| `DEX` | X = X - 1 |
| `INY` | Y = Y + 1 |
| `DEY` | Y = Y - 1 |

### Logiche

| Istruzione | Descrizione |
|---|---|
| `AND #val` | A = A AND val |
| `ORA #val` | A = A OR val |
| `EOR #val` | A = A XOR val |
| `ASL` | Shift a sinistra |
| `LSR` | Shift a destra |

### Confronto e salti

| Istruzione | Descrizione |
|---|---|
| `CMP #val` | Confronta A con val |
| `CPX #val` | Confronta X con val |
| `CPY #val` | Confronta Y con val |
| `BEQ label` | Salta se uguale (Z=1) |
| `BNE label` | Salta se diverso (Z=0) |
| `BCC label` | Salta se Carry=0 |
| `BCS label` | Salta se Carry=1 |
| `BMI label` | Salta se negativo (N=1) |
| `BPL label` | Salta se positivo (N=0) |

### Stack e salti

| Istruzione | Descrizione |
|---|---|
| `JMP label` | Salto incondizionato |
| `JSR label` | Salta a sottoroutine |
| `RTS` | Ritorno da sottoroutine |
| `RTI` | Ritorno da interrupt |
| `PHA` | Push A sullo stack |
| `PLA` | Pull A dallo stack |
| `TXA` | Copia X in A |
| `TYA` | Copia Y in A |
| `TAX` | Copia A in X |
| `TAY` | Copia A in Y |

### Flags

| Istruzione | Descrizione |
|---|---|
| `SEC` | Set Carry = 1 |
| `CLC` | Clear Carry = 0 |
| `SEI` | Set Interrupt disable |
| `CLI` | Clear Interrupt disable |
| `SED` | Set Decimal mode |
| `CLD` | Clear Decimal mode |

---

## Codici PETSCII comuni (lettere maiuscole)

| Carattere | Codice |
|---|---|
| A | 1 |
| B | 2 |
| C | 3 |
| D | 4 |
| E | 5 |
| F | 6 |
| G | 7 |
| H | 8 |
| I | 9 |
| J | 10 |
| K | 11 |
| L | 12 |
| M | 13 |
| N | 14 |
| O | 15 |
| P | 16 |
| Q | 17 |
| R | 18 |
| S | 19 |
| T | 20 |
| U | 21 |
| V | 22 |
| W | 23 |
| X | 24 |
| Y | 25 |
| Z | 26 |
| Spazio | 32 |
| 0-9 | 48-57 |

---

## Tabella potenze di 2

| Potenza | Valore | Esadecimale |
|---|---|---|
| 2^0 | 1 | `$01` |
| 2^1 | 2 | `$02` |
| 2^2 | 4 | `$04` |
| 2^3 | 8 | `$08` |
| 2^4 | 16 | `$10` |
| 2^5 | 32 | `$20` |
| 2^6 | 64 | `$40` |
| 2^7 | 128 | `$80` |
| 2^8 | 256 | `$100` |
| 2^9 | 512 | `$200` |
| 2^10 | 1024 | `$400` |
| 2^11 | 2048 | `$800` |
| 2^12 | 4096 | `$1000` |

---

## Mascherine bit per sprite

```asm
; Maschere per abilitare/disabilitare sprite
SPRITE_0  = %00000001
SPRITE_1  = %00000010
SPRITE_2  = %00000100
SPRITE_3  = %00001000
SPRITE_4  = %00010000
SPRITE_5  = %00100000
SPRITE_6  = %01000000
SPRITE_7  = %10000000

; Maschere per $D010 (MSB X)
MSB_SPRITE_0 = %00000001
MSB_SPRITE_1 = %00000010
; ... stesso schema ...
```

---

## Numeri utili

| Valore | Decimale | Esadecimale |
|---|---|---|
| Inizio screen RAM | 1024 | `$0400` |
| Fine screen RAM | 2023 | `$07E7` |
| Color RAM start | 55296 | `$D800` |
| Color RAM end | 56295 | `$DBE7` |
| Sprite dimension | 63 byte | `$3F` |
| Max raster PAL | 311 | `$0137` |
| Max raster NTSC | 262 | `$0106` |
| Caratteri per riga | 40 | `$28` |
| Righe schermo | 25 | `$19` |
