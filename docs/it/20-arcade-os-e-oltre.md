# Capitolo 20 — Verso un Arcade OS e Oltre

## Obiettivi

Al termine di questo capitolo saprai:

- I concetti avanzati dell'Arcade OS Kernel
- Come funziona l'interrupt chaining
- Cos'e il self-modifying code
- Come evolvere il tuo engine
- Dove trovare risorse per approfondire

---

## 20.1 L'evoluzione in Arcade OS

Unendo Kernel Engine (cap. 19) e rendering avanzato, si arriva al concetto di **Arcade OS**: un micro-sistema operativo che esegue il gioco come un processo schedulato.

```
┌─────────────────────────────────────┐
│ ARCADE OS KERNEL                    │
│  - Scheduler a priorita             │
│  - Gestione interrupt raster        │
│  - Time-slicing delle risorse VIC   │
├─────────────────────────────────────┤
│ SOTTOSISTEMI                        │
│  - Sprite Virtualization Layer      │
│  - Raster Split Manager             │
│  - Scroll Engine Unificato          │
│  - Audio Engine                     │
├─────────────────────────────────────┤
│ GIOCO (task schedulato)             │
│  - AI nemici                        │
│  - Collisioni                       │
│  - Logica di gioco                  │
└─────────────────────────────────────┘
```

### Il raster come scheduler

Il cuore dell'Arcade OS non e un loop. E il **raster interrupt** che diventa il clock del sistema:

```
Raster 0-50   → Game logic (AI, fisica, collisioni)
Raster 50-150 → Sprite multiplexing (zona A)
Raster 150-230→ Sprite multiplexing (zona B), scroll
Raster 230-250→ Audio update, pulizia fine frame
```

---

## 20.2 Interrupt Chaining

Invece di un singolo IRQ, possiamo creare una **catena di interrupt**:

```asm
; Ogni IRQ installa il prossimo handler

IRQ_CHAIN_0
    PHA
    JSR GAME_LOGIC

    ; Installa prossimo
    LDA #<IRQ_CHAIN_1
    STA $0314
    LDA #>IRQ_CHAIN_1
    STA $0315

    LDA #80
    STA $D012

    PLA
    LDA $D019
    STA $D019
    JMP $EA31

IRQ_CHAIN_1
    PHA
    JSR SPRITE_ZONE_A

    LDA #<IRQ_CHAIN_2
    STA $0314
    LDA #>IRQ_CHAIN_2
    STA $0315

    LDA #160
    STA $D012

    PLA
    LDA $D019
    STA $D019
    JMP $EA31

IRQ_CHAIN_2
    PHA
    JSR SPRITE_ZONE_B
    JSR AUDIO_UPDATE

    LDA #<IRQ_CHAIN_0
    STA $0314
    LDA #>IRQ_CHAIN_0
    STA $0315

    LDA #0
    STA $D012

    PLA
    LDA $D019
    STA $D019
    JMP $EA31
```

---

## 20.3 Self-Modifying Code

Una tecnica potente (ma pericolosa): il codice che modifica se stesso.

```asm
; Esempio: patchare un'istruzione a runtime

    ; In base allo stato, cambia il target di un salto
    LDA GAME_STATE
    ASL
    TAX
    LDA JUMP_TABLE,X
    STA PATCH_ADDR
    LDA JUMP_TABLE+1,X
    STA PATCH_ADDR+1

    ; Il JMP sara modificato prima di essere eseguito
PATCH_ADDR
    JMP $0000          ; viene sovrascritto

JUMP_TABLE
    .word MENU_UPDATE
    .word PLAY_UPDATE
    .word GAMEOVER_UPDATE
```

### Perche usarlo?

- Velocita: evita confronti in hot path
- Flessibilita: cambia comportamento a runtime
- Codice compatto

### Perche evitarlo (se possibile)

- Difficile da debuggare
- Non funziona su ROM
- Pericoloso su C64 (codice in RAM)

---

## 20.4 Sprite Virtualization Layer

Concetto avanzato: invece di pensare a sprite HW, lavoriamo con **sprite virtuali**:

```asm
; Pool di sprite virtuali (max 32)
VSPRITE_X   = $0300    ; 32 byte
VSPRITE_Y   = $0320    ; 32 byte
VSPRITE_TYPE = $0340   ; 32 byte
VSPRITE_ACTIVE = $0360 ; 32 byte

MAX_VSPRITE = 32

; Il kernel mappa automaticamente gli sprite virtuali
; sugli 8 sprite hardware usando multiplexing

RESOLVE_VSPRITES
    ; Ordina per Y
    ; Assegna agli 8 slot HW
    ; Aggiorna nei raster interrupt
    RTS
```

---

## 20.5 Scroll Engine Unificato

Un motore di scrolling che gestisce tutto:

```asm
SCROLL_X    = $F0      ; scroll fine orizzontale (0-7)
SCROLL_Y    = $F1      ; scroll fine verticale (0-7)
SCROLL_MAP  = $F2      ; puntatore mappa

UPDATE_SCROLL
    INC SCROLL_X
    LDA SCROLL_X
    CMP #8
    BNE US_DONE

    LDA #0
    STA SCROLL_X
    JSR SCROLL_MAP_X    ; scroll grossolano della tilemap

US_DONE
    LDA SCROLL_X
    ORA #%11001000      ; mantieni 40 colonne + bit video
    STA $D016

    RTS

SCROLL_MAP_X
    ; Shiftare la tilemap a sinistra di una colonna
    ; ... logica di copia memoria ...
    RTS
```

---

## 20.6 Riepilogo delle tecniche avanzate

| Tecnica | Descrizione | Quando usarla |
|---|---|---|
| **Raster chain** | IRQ multipli in cascata | Sempre, per giochi complessi |
| **Entity system** | Array di componenti | Giochi con 10+ entita |
| **Multiplexing** | Riuso sprite HW | Giochi con 8+ sprite |
| **Self-modify** | Codice che si modifica | Hot path, salti dinamici |
| **Raster split** | Cambi VIC-II a meta schermo | HUD, effetti, parallax |
| **Double buffer** | Due buffer di sprite | Anti-flicker |
| **Audio queue** | Coda comandi SID | Effetti audio multipli |

---

## 20.7 Checklist per un gioco arcade completo

```
[ ] Setup iniziale (IRQ, VIC, SID)
[ ] Menu/titolo
[ ] Input joystick
[ ] Player (movimento, sparo)
[ ] Pool proiettili
[ ] Wave system (nemici a ondate)
[ ] AI nemici (movimento, tiro)
[ ] Collision detection
[ ] Punteggio e vite
[ ] Game Over / restart
[ ] Audio (SFX, musica base)
[ ] HUD (punteggio, vite)
[ ] Schermate di transizione
[ ] Ottimizzazioni (multiplexing se serve)
[ ] Test e bilanciamento
```

---

## 20.8 Dove andare da qui

### Risorse per approfondire

| Risorsa | Descrizione |
|---|---|
| **Codebase64** | Tutorial e codice C64 |
| **Lemon64** | Forum di programmazione C64 |
| **CSDb** | Scene Database: esempi di codice |
| **Mapper 64** | Documentazione registri VIC-II |
| **Programming the 6502** | Libro di Rodney Zaks |

### Prossimi progetti possibili

1. **Space Invaders** — con tutto quello che hai imparato
2. **Galaga** — aggiungi formazioni nemiche
3. **Pac-Man** — gestione labirinto e fantasmi
4. **Arkanoid** — pallina, mattoni, rimbalzi
5. **Scroller** — gioco a scorrimento orizzontale
6. **Platform** — salto, gravita, collisioni con tilemap

### Consigli finali

```
1. Inizia piccolo, finisci il gioco
2. Prima fa funzionare, poi ottimizza
3. Usa il raster di debug per il tempo CPU
4. Salva spesso su disco!
5. Testa su hardware reale se possibile
6. Ogni gioco finito ti insegna piu di 10 iniziati
```

---

## Esercizi

### Esercizio 1
Spiega la differenza tra interrupt chaining e polling. In quali situazioni conviene l'uno rispetto all'altro?

### Esercizio 2
Descrivi come funziona lo sprite virtualization: come si fa a gestire 32 sprite logici con solo 8 sprite hardware? Quale componente dell'Arcade OS si occupa di questo?

### Esercizio 3
Cosa si intende per self-modifying code? Fai un esempio di quando puo essere utile e spiega quali rischi comporta.

### Esercizio 4
Disegna lo schema dell'architettura a 3 strati (Kernel → Engine → Game) e spiega il flusso di una tipica chiamata: da dove parte, quali strati attraversa, cosa fa ciascuno.

### Esercizio 5
Prendi la checklist finale del capitolo e applicala mentalmente a un gioco che vorresti sviluppare. Elenca: scelta del genere, risoluzione, quanti sprite servono, tipo di audio, schema di controllo.

> **Nota:** Gli esercizi di questo capitolo sono concettuali e non richiedono soluzioni assembly.

---

## Riepilogo

Hai imparato:

- Il concetto di Arcade OS come kernel schedulato
- Interrupt chaining per pipeline multi-fase
- Self-modifying code (uso e rischi)
- Sprite virtualization per gestire 32 sprite
- Scroll engine unificato
- Checklist completa per un gioco arcade
- Risorse per continuare a imparare

## Riferimenti

- [Capitolo 19 — Kernel engine](19-kernel-engine-riutilizzabile.md) — base su cui si fonda l'Arcade OS
- [Capitolo 7 — Raster interrupt](07-raster-interrupt.md) — interrupt chaining
- [Capitolo 16 — Sprite multiplexing](16-sprite-multiplexing.md) — sprite virtualization
- [Tutti i capitoli precedenti](/md/) — prerequisiti per arrivare qui
