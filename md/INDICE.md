# Indice Analitico

Elenco di registri, istruzioni, routine KERNAL e concetti,
con riferimento al capitolo che li introduce.

---

## VIC-II — Registri Video ($D000–$D03F)

| Registro | Nome | Capitolo |
|----------|------|----------|
| `$D000`–`$D00F` | Posizione sprite X/Y (0-7) | [5](05-sprite-hardware-vic-ii.md) |
| `$D010` | Sprite MSB X (bit 0-7) | [6](06-movimento-e-controllo-sprite.md) |
| `$D011` | Controllo verticale / scroll fine Y | [7](07-raster-interrupt.md), [24](24-scrolling.md) |
| `$D012` | Raster line compare | [7](07-raster-interrupt.md) |
| `$D015` | Sprite enable (bit 0-7) | [5](05-sprite-hardware-vic-ii.md) |
| `$D016` | Controllo orizzontale / scroll fine X | [17](17-parallax-e-raster-split.md), [24](24-scrolling.md) |
| `$D017` | Sprite double height (bit 0-7) | [5](05-sprite-hardware-vic-ii.md) |
| `$D018` | Indirizzo char set / screen RAM | [4](04-memoria-video-e-caratteri.md) |
| `$D019` | Interrupt status register | [7](07-raster-interrupt.md) |
| `$D01A` | Interrupt enable register | [7](07-raster-interrupt.md) |
| `$D01B` | Sprite background priority (bit 0-7) | [5](05-sprite-hardware-vic-ii.md) |
| `$D01C` | Sprite multicolor mode (bit 0-7) | [5](05-sprite-hardware-vic-ii.md), [6](06-movimento-e-controllo-sprite.md) |
| `$D01D` | Sprite double width (bit 0-7) | [5](05-sprite-hardware-vic-ii.md) |
| `$D01E` | Sprite-sprite collision | [10](10-collisioni-software.md) |
| `$D01F` | Sprite-background collision | [10](10-collisioni-software.md) |
| `$D020` | Border color | [1](01-introduzione-c64-tmp.md) |
| `$D021` | Background color 0 | [1](01-introduzione-c64-tmp.md) |
| `$D022`–`$D024` | Background color 1-3 / sprite multicolor | [5](05-sprite-hardware-vic-ii.md) |
| `$D025`–`$D026` | Sprite multicolor registers | [5](05-sprite-hardware-vic-ii.md) |
| `$D027`–`$D02E` | Sprite 0-7 color | [5](05-sprite-hardware-vic-ii.md) |

---

## CIA — Registri di I/O

### CIA 1 ($DC00–$DC0F)

| Registro | Nome | Capitolo |
|----------|------|----------|
| `$DC00` | Porta A — output joystick / colonna matrice | [9](09-joystick-e-input.md) |
| `$DC01` | Porta B — input joystick / riga matrice | [9](09-joystick-e-input.md) |
| `$DC0D` | CIA1 interrupt control | [7](07-raster-interrupt.md) |

### CIA 2 ($DD00–$DD0F)

| Registro | Nome | Capitolo |
|----------|------|----------|
| `$DD00` | Porta seriale / bank VIC-II bit 0-1 | [21](21-caricatore-personalizzato.md) |

---

## SID — Registri Audio ($D400–$D41C)

| Registro | Nome | Capitolo |
|----------|------|----------|
| `$D400`–`$D401` | Voice 1 frequency | [14](14-audio-sid-base.md) |
| `$D402`–`$D403` | Voice 1 pulse width | [14](14-audio-sid-base.md) |
| `$D404` | Voice 1 control (gate/test/ring/ sync/rect/tri/saw/noise) | [14](14-audio-sid-base.md) |
| `$D405`–`$D406` | Voice 1 ADSR | [14](14-audio-sid-base.md) |
| `$D407`–`$D40C` | Voice 2 (stessa struttura) | [14](14-audio-sid-base.md) |
| `$D40E`–`$D413` | Voice 3 (stessa struttura) | [14](14-audio-sid-base.md) |
| `$D414` | Filter cutoff frequency low | [14](14-audio-sid-base.md) |
| `$D415` | Filter cutoff frequency high / resonance | [14](14-audio-sid-base.md) |
| `$D416` | Filter mode (lp/bp/hp) | [14](14-audio-sid-base.md) |
| `$D417` | Volume + filter enable | [14](14-audio-sid-base.md) |
| `$D418` | Volume (0-15) | [14](14-audio-sid-base.md) |

---

## KERNAL — Routine di Sistema ($FF81–$FFF3)

| Indirizzo | Nome | Descrizione | Capitolo |
|-----------|------|-------------|----------|
| `$FF81` | `IOBASE` | Indirizzo base I/O | — |
| `$FF84` | `SCINIT` | Inizializza schermo | — |
| `$FF87` | `PLOT` | Posiziona cursore | — |
| `$FF90` | `RDTIM` | Legge clock di sistema | — |
| `$FF99` | `UDTIM` | Aggiorna clock | — |
| `$FF9C` | `RDTIM2` | Legge time (alternativa) | — |
| `$FFA2` | `STOP` | Controlla tasto STOP | — |
| `$FFA5` | `RSSTAT` | Stato RS-232 | — |
| `$FFA8` | `GETIN` | Legge carattere da tastiera | — |
| `$FFAB` | `CLRCH` | Chiude canali I/O | — |
| `$FFAE` | `CHKIN` | Apre canale input | — |
| `$FFB1` | `CHKOUT` | Apre canale output | — |
| `$FFB4` | `CLRCN` | Pulisce canale | — |
| `$FFB7` | `CHRIN` | Legge byte da canale | — |
| `$FFBA` | `SETLFS` | Imposta logical file/device/command | [21](21-caricatore-personalizzato.md) |
| `$FFBD` | `SETNAM` | Imposta nome file | [21](21-caricatore-personalizzato.md) |
| `$FFC0` | `OPEN` | Apre file | — |
| `$FFC3` | `CLOSE` | Chiude file | — |
| `$FFC6` | `CHKIN2` | Versione alternativa CHKIN | — |
| `$FFC9` | `CHKOUT2` | Versione alternativa CHKOUT | — |
| `$FFCC` | `CLRCH2` | Versione alternativa CLRCH | — |
| `$FFCF` | `BASIN` | Get byte (versione BASIC) | — |
| `$FFD2` | `BSOUT` | Output carattere (`CHROUT`) | [1](01-introduzione-c64-tmp.md) |
| `$FFD5` | `LOAD` | Carica file da disco | [21](21-caricatore-personalizzato.md), [23](23-titolo-highscore.md) |
| `$FFD8` | `SAVE` | Salva file su disco | [23](23-titolo-highscore.md) |
| `$FFDB` | `SETTIM` | Imposta clock | — |
| `$FFDE` | `MEMTOP` | Legge top memoria | — |
| `$FFE1` | `MEMBOT` | Legge bottom memoria | — |
| `$FFE7` | `SETBNK` | Imposta bank | — |
| `$FFEA` | `SETMSG` | Controllo messaggi | — |
| `$FFED` | `SETTMO` | Timeout device | — |
| `$FFF0` | `IECIN` | Input IEC | — |
| `$FFF3` | `IECOUT` | Output IEC | — |
| `$EA31` | Interrupt return con Acknowledge | Fine IRQ (ack + RTI indiretto) | [7](07-raster-interrupt.md) |

---

## 6502/6510 — Istruzioni

### Trasferimento dati

| Istruzione | Descrizione | Capitolo |
|------------|-------------|----------|
| `LDA #n` | Carica immediato in A | [1](01-introduzione-c64-tmp.md) |
| `LDA addr` | Carica da indirizzo in A | [1](01-introduzione-c64-tmp.md) |
| `LDX #n` / `LDX addr` | Carica immediato/da indirizzo in X | [2](02-istruzioni-fondamentali.md) |
| `LDY #n` / `LDY addr` | Carica immediato/da indirizzo in Y | [2](02-istruzioni-fondamentali.md) |
| `STA addr` | Salva A in memoria | [1](01-introduzione-c64-tmp.md) |
| `STX addr` | Salva X in memoria | [2](02-istruzioni-fondamentali.md) |
| `STY addr` | Salva Y in memoria | [2](02-istruzioni-fondamentali.md) |
| `TAX` | Trasferisci A → X | [2](02-istruzioni-fondamentali.md) |
| `TAY` | Trasferisci A → Y | [2](02-istruzioni-fondamentali.md) |
| `TXA` | Trasferisci X → A | [2](02-istruzioni-fondamentali.md) |
| `TYA` | Trasferisci Y → A | [2](02-istruzioni-fondamentali.md) |

### Aritmetica

| Istruzione | Descrizione | Capitolo |
|------------|-------------|----------|
| `ADC #n` | Addizione con carry | [2](02-istruzioni-fondamentali.md) |
| `SBC #n` | Sottrazione con carry | [2](02-istruzioni-fondamentali.md) |
| `INC addr` | Incrementa memoria | [2](02-istruzioni-fondamentali.md) |
| `DEC addr` | Decrementa memoria | [2](02-istruzioni-fondamentali.md) |
| `INX` / `INY` | Incrementa X / Y | [2](02-istruzioni-fondamentali.md) |
| `DEX` / `DEY` | Decrementa X / Y | [2](02-istruzioni-fondamentali.md) |

### Logiche e bit

| Istruzione | Descrizione | Capitolo |
|------------|-------------|----------|
| `AND #n` | AND logico | [2](02-istruzioni-fondamentali.md) |
| `ORA #n` | OR logico | [2](02-istruzioni-fondamentali.md) |
| `EOR #n` | XOR logico | [2](02-istruzioni-fondamentali.md) |
| `LSR A` | Logical shift right | [2](02-istruzioni-fondamentali.md) |
| `ASL A` | Arithmetic shift left | [2](02-istruzioni-fondamentali.md) |
| `ROL A` | Rotate left | [3](03-indirizzamento-cicli-ritardi.md) |
| `ROR A` | Rotate right | [3](03-indirizzamento-cicli-ritardi.md) |
| `BIT addr` | Bit test | [2](02-istruzioni-fondamentali.md) |

### Salti e salti condizionali

| Istruzione | Descrizione | Capitolo |
|------------|-------------|----------|
| `JMP addr` | Salto incondizionato | [2](02-istruzioni-fondamentali.md) |
| `JSR addr` | Salta a subroutine | [2](02-istruzioni-fondamentali.md) |
| `RTS` | Ritorno da subroutine | [2](02-istruzioni-fondamentali.md) |
| `BEQ addr` | Salta se zero (==) | [2](02-istruzioni-fondamentali.md) |
| `BNE addr` | Salta se non zero (!=) | [2](02-istruzioni-fondamentali.md) |
| `BCC addr` | Salta se carry clear (<) | [2](02-istruzioni-fondamentali.md) |
| `BCS addr` | Salta se carry set (>=) | [2](02-istruzioni-fondamentali.md) |
| `BMI addr` | Salta se negativo | [2](02-istruzioni-fondamentali.md) |
| `BPL addr` | Salta se positivo | [2](02-istruzioni-fondamentali.md) |
| `BVC addr` | Salta se overflow clear | [2](02-istruzioni-fondamentali.md) |
| `BVS addr` | Salta se overflow set | [2](02-istruzioni-fondamentali.md) |

### Comparazione

| Istruzione | Descrizione | Capitolo |
|------------|-------------|----------|
| `CMP #n` | Compara A | [2](02-istruzioni-fondamentali.md) |
| `CPX #n` | Compara X | [2](02-istruzioni-fondamentali.md) |
| `CPY #n` | Compara Y | [2](02-istruzioni-fondamentali.md) |

### Stack

| Istruzione | Descrizione | Capitolo |
|------------|-------------|----------|
| `PHA` | Push A sullo stack | [3](03-indirizzamento-cicli-ritardi.md) |
| `PLA` | Pull A dallo stack | [3](03-indirizzamento-cicli-ritardi.md) |
| `PHP` | Push status sullo stack | [3](03-indirizzamento-cicli-ritardi.md) |
| `PLP` | Pull status dallo stack | [3](03-indirizzamento-cicli-ritardi.md) |
| `TSX` | Stack pointer → X | [3](03-indirizzamento-cicli-ritardi.md) |
| `TXS` | X → stack pointer | [3](03-indirizzamento-cicli-ritardi.md) |

### Interrupt

| Istruzione | Descrizione | Capitolo |
|------------|-------------|----------|
| `SEI` | Set interrupt disable | [7](07-raster-interrupt.md) |
| `CLI` | Clear interrupt disable | [7](07-raster-interrupt.md) |
| `RTI` | Return from interrupt | [7](07-raster-interrupt.md) |

### Altre

| Istruzione | Descrizione | Capitolo |
|------------|-------------|----------|
| `NOP` | No operation | [2](02-istruzioni-fondamentali.md) |
| `BRK` | Breakpoint forzato (software) | [22](22-debugging-vice.md) |

---

## Mappa di Memoria

| Indirizzo | Dimensione | Descrizione | Capitolo |
|-----------|-----------|-------------|----------|
| `$0000`–`$00FF` | 256 byte | Zero page | [3](03-indirizzamento-cicli-ritardi.md) |
| `$0100`–`$01FF` | 256 byte | Stack hardware | [3](03-indirizzamento-cicli-ritardi.md) |
| `$0200`–`$03FF` | 512 byte | KERNAL/BASIC work area | — |
| `$0400`–`$07FF` | 1024 byte | Screen RAM (default) | [4](04-memoria-video-e-caratteri.md) |
| `$0800`–`$9FFF` | 38912 byte | BASIC / memoria programma | [1](01-introduzione-c64-tmp.md) |
| `$0801` | — | Inizio programma BASIC | [21](21-caricatore-personalizzato.md) |
| `$C000` | — | Indirizzo standard assemblaggio | [1](01-introduzione-c64-tmp.md) |
| `$A000`–`$BFFF` | 8192 byte | BASIC ROM (o RAM) | — |
| `$C000`–`$CFFF` | 4096 byte | Area programma alternativa | [6](06-movimento-e-controllo-sprite.md) |
| `$D000`–`$D3FF` | 1024 byte | VIC-II registers | [4](04-memoria-video-e-caratteri.md) |
| `$D400`–`$D41C` | 29 byte | SID (audio) | [14](14-audio-sid-base.md) |
| `$D800`–`$DBFF` | 1024 byte | Color RAM | [4](04-memoria-video-e-caratteri.md) |
| `$DC00`–`$DCFF` | 256 byte | CIA 1 | [9](09-joystick-e-input.md) |
| `$DD00`–`$DDFF` | 256 byte | CIA 2 | [21](21-caricatore-personalizzato.md) |
| `$FF80`–`$FFFF` | 128 byte | KERNAL ROM (jump table) | [21](21-caricatore-personalizzato.md) |

---

## Concetti per Capitolo

| Capitolo | Concetti principali |
|----------|-------------------|
| [1](01-introduzione-c64-tmp.md) | LDA/STA, `$D020`/`$D021`, assemblaggio a `$C000`, TMPx, `BSOUT $FFD2` |
| [2](02-istruzioni-fondamentali.md) | Istruzioni base, loop (DEX/BNE), delay (NOP), ADC/SBC, AND/ORA/EOR, CMP/CPX/CPY, INC/DEC, flag |
| [3](03-indirizzamento-cicli-ritardi.md) | Zero page, X-indexed, Y-indexed, indirect, stack (PHA/PLA/TSX/TXS), ROL/ROR |
| [4](04-memoria-video-e-caratteri.md) | Screen RAM (`$0400`), Color RAM (`$D800`), `$D018`, PETSCII, caratteri personalizzati |
| [5](05-sprite-hardware-vic-ii.md) | Sprite enable `$D015`, posizioni `$D000`–`$D00F`, pointer `$07F8`, dati sprite, colori, multicolor |
| [6](06-movimento-e-controllo-sprite.md) | Movimento sprite, MSB `$D010`, animazione, multicolor sprite, double size |
| [7](07-raster-interrupt.md) | IRQ setup (SEI/CLI), `$D012`, `$D019`, `$D01A`, `$0314/$0315`, raster bar, `JMP $EA31` |
| [8](08-game-loop-sincronizzato.md) | Frame counter, 50 Hz loop, sincronizzazione verticale |
| [9](09-joystick-e-input.md) | `$DC01`, direzioni, edge detection, debouncing |
| [10](10-collisioni-software.md) | Bounding box, `$D01E`/`$D01F`, collision detection software |
| [11](11-sistema-proiettili.md) | Pool/spawn proiettili, cooldown timer, active/inactive |
| [12](12-wave-system-e-ai-nemici.md) | Onde nemiche, pattern AI, difficolta progressiva |
| [13](13-punteggio-e-stati-gioco.md) | Punteggio BCD/esadecimale, state machine (MENU/PLAY/GAMEOVER) |
| [14](14-audio-sid-base.md) | SID, waveform (tri/saw/pulse/noise), ADSR, filter, volume `$D418` |
| [15](15-audio-engine-e-sfx.md) | Audio engine, coda SFX, music engine, priority |
| [16](16-sprite-multiplexing.md) | Multiplexing software (8+ sprite), raster split per sprite |
| [17](17-parallax-e-raster-split.md) | Raster split, scroll `$D016`, parallax due layer |
| [18](18-boss-system.md) | Boss multi-fase, pattern attack, weak point |
| [19](19-kernel-engine-riutilizzabile.md) | 3-layer (INPUT/LOGIC/RENDER), scheduler, entity system |
| [20](20-arcade-os-e-oltre.md) | Arcade OS concepts, interrupt chaining, self-modifying code, 3-layer kernel |
| [21](21-caricatore-personalizzato.md) | SETNAM `$FFBD`, SETLFS `$FFBA`, LOAD `$FFD5`, caricatore personalizzato |
| [22](22-debugging-vice.md) | VICE monitor, breakpoint `b`, watchpoint `w`, disasm `d`, step `x`/`z`, raster debug |
| [23](23-titolo-highscore.md) | Schermata titolo animata, SAVE `$FFD8`, LOAD high score, game over screen |
| [24](24-scrolling.md) | Scroll fine `$D016`/`$D011`, scroll grossolano, raster split scroll, parallax scroll, vertical scroll |

---

## Modificatori di Indirizzamento

| Sintassi | Nome | Capitolo |
|----------|------|----------|
| `#n` | Immediato | [1](01-introduzione-c64-tmp.md) |
| `$C000` | Assoluto | [3](03-indirizzamento-cicli-ritardi.md) |
| `$C000,X` | Assoluto indicizzato X | [3](03-indirizzamento-cicli-ritardi.md) |
| `$C000,Y` | Assoluto indicizzato Y | [3](03-indirizzamento-cicli-ritardi.md) |
| `$C0` | Zero page | [3](03-indirizzamento-cicli-ritardi.md) |
| `$C0,X` | Zero page indicizzato X | [3](03-indirizzamento-cicli-ritardi.md) |
| `($C000)` | Indiretto (JMP) | [3](03-indirizzamento-cicli-ritardi.md) |
| `($C0),Y` | Zero page indiretto indicizzato Y | [3](03-indirizzamento-cicli-ritardi.md) |
| `($C0,X)` | Zero page indiretto pre-indicizzato X | [3](03-indirizzamento-cicli-ritardi.md) |
| `label` | Indirizzamento relativo (branch) | [2](02-istruzioni-fondamentali.md) |

---

## VICE — Comandi del Monitor

| Comando | Azione | Capitolo |
|---------|--------|----------|
| `r` | Mostra registri CPU | [22](22-debugging-vice.md) |
| `m $addr` | Mostra memoria | [22](22-debugging-vice.md) |
| `d $addr` | Disassembla | [22](22-debugging-vice.md) |
| `b $addr` | Breakpoint su esecuzione | [22](22-debugging-vice.md) |
| `w $addr` | Watchpoint su accesso | [22](22-debugging-vice.md) |
| `wl $addr` | Watchpoint su lettura | [22](22-debugging-vice.md) |
| `ws $addr` | Watchpoint su scrittura | [22](22-debugging-vice.md) |
| `g` | Continua esecuzione | [22](22-debugging-vice.md) |
| `x` | Step over | [22](22-debugging-vice.md) |
| `z` | Step into | [22](22-debugging-vice.md) |
| `bc` | Cancella breakpoint | [22](22-debugging-vice.md) |
| `bl` | Lista breakpoint | [22](22-debugging-vice.md) |
| `a $addr` | Assembla in memoria | [22](22-debugging-vice.md) |
| `l "file" $start $end` | Salva memoria su file | [22](22-debugging-vice.md) |
