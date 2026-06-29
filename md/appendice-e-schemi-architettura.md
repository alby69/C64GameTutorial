# Appendice E — Schemi Rapidi: Architettura di Gioco

## Architettura a 3 Strati (3-Layer Architecture)

```
 ┌─────────────────────────────────────────────────┐
 │                                                 │
 │               STRATO GIOCO                       │
 │   (Game Layer - logica specifica del gioco)      │
 │                                                 │
 │   GameState: MENU → PLAY → GAMEOVER             │
 │   Entita: giocatore, nemici, proiettili, boss   │
 │   WaveSystem: spawn, battaglia, pausa           │
 │   UI: punteggio, vite, messaggi                 │
 │                                                 │
 ├─────────────────────────────────────────────────┤
 │                                                 │
 │               STRATO ENGINE                      │
 │   (Engine Layer - astrazione hardware)           │
 │                                                 │
 │   EntityManager: pool, creazione, rimozione     │
 │   SpriteMultiplexer: zone, IRQ cascade          │
 │   AudioEngine: suoni, musica, canali            │
 │   InputManager: joystick, edge detection        │
 │   CollisionManager: box overlap detection       │
 │   Scroller: movimento parallasse                │
 │                                                 │
 ├─────────────────────────────────────────────────┤
 │                                                 │
 │               STRATO KERNEL                      │
 │   (Kernel Layer - hardware nudo)                 │
 │                                                 │
 │   Boot: setup CPU, VIC-II, SID, CIA             │
 │   IRQManager: catena raster, schedulazione       │
 │   Scheduler: task cooperativi a priorita        │
 │   RasterISR: split zone, commutazione colori    │
 │   VIC-II setup: registri, sprite pointers       │
 │   SID setup: volume, filtri, velocita           │
 │                                                 │
 └─────────────────────────────────────────────────┘
```

### Flusso di Chiamata

```
Kernel.IRQ          Kernel.Scheduler
  │                     │
  ├─ RasterSplit        ├─ Task engine.aggiornaEntita()
  │  (commuta zona)     ├─ Task engine.gestisciCollisioni()
  │                     ├─ Task engine.renderizzaSprite()
  └─ IRQManager         ├─ Task engine.aggiornaAudio()
     (prepara prox IRQ) └─ Task game.aggiornaGameState()
```

---

## Macchina a Stati del Gioco

```
           ┌─────────────────────────┐
           │       RESET / POWER     │
           └──────────┬──────────────┘
                      │
                      ▼
              ┌───────────────┐
         ┌───│     MENU      │◄────────────┐
         │   │ (titolo/attesa)│             │
         │   └───────┬───────┘             │
         │           │ FIRE premuto        │
         │           ▼                     │
         │   ┌───────────────┐             │
         │   │     PLAY      │             │
         │   │ (gioco attivo)│             │
         │   └───────┬───────┘             │
         │           │                     │
         │    ┌──────┴──────┐              │
         │    ▼              ▼             │
         │  Vita persa   Boss sconfitto    │
         │    │              │             │
         │    ▼              │             │
         │  Vite > 0? ──s├──┤             │
         │    │             │              │
         │   s├             ▼              │
         │    │      ┌───────────────┐     │
         │    │      │   VITTORIA    │     │
         │    │      └───────────────┘     │
         │    ▼              │             │
         │  ┌────────────┐   │             │
         │  │ GAMEOVER   │◄──┘             │
         │  │ (game over)│                 │
         │  └─────┬──────┘                 │
         │        │ FIRE/FADE              │
         └────────┘                       │
                                     (vittoria→
                                      titolo)
```

---

## Macchina a Stati Wave (Onde nemiche)

```
              ┌─────────────────┐
              │    SPAWN        │
              │ (fai apparire i │
              │  nemici uno a   │
              │  uno o a gruppi)│
              └────────┬────────┘
                       │
                       ▼
              ┌─────────────────┐
         ┌───│    BATTAGLIA    │───┐
         │   │ (nemici attivi, │   │
         │   │  giocatore      │   │
         │   │  combatte)      │   │
         │   └────────┬────────┘   │
         │            │            │
         │     ┌──────┴──┐        │
         │     ▼         ▼        │
         │   Nemici   Nemici      │
         │   vivi?    finiti      │
         │     │         │        │
         │     ▼         ▼        │
         │     (loop)   ┌──────────────┐
         │              │   PAUSA      │
         │              │ (breve attesa│
         │              │  tra onde)   │
         │              └──────┬───────┘
         │                     │
         └─────────────────────┘ (prossima ondata)
```

---

## Game Loop Confronto

### WAIT_FRAME (Ciclo Principale)

```
MAIN_LOOP:
  WAIT: LDA $D011        ; attende il raster
        BMI WAIT          ; finche' non esce dal VBLANK

  ; --- VBLANK (311 righe, ~11000 cicli) ---
  JSR LEGGI_JOYSTICK      ; Input
  JSR MUOVI_NEMICI        ; Logica
  JSR COLLISIONI          ; Collisioni
  JSR MUOVI_SPRITE        ; Output
  JMP MAIN_LOOP
```

### IRQ (1 interrupt per frame)

```
MAIN_LOOP:
  JSR LEGGI_JOYSTICK
  JSR MUOVI_NEMICI
  JSR COLLISIONI
  JSR MUOVI_SPRITE
  JMP MAIN_LOOP

ISR:
  ; VIC-II ha raggiunto una riga raster
  ACK interrupt
  ; eventuali operazioni sincronizzate
  RTI
```

### Doppio IRQ / Raster Split

```
ZONA_HUD_IRQ:            ; riga 30
  ACK interrupt
  prepara prossimo IRQ → riga 200
  RTI

ZONA_GIOCO_IRQ:          ; riga 200
  ACK interrupt
  prepara prossimo IRQ → riga 250
  (cambia registro colore, scroll, etc.)
  RTI

ZONA_BARRA_IRQ:          ; riga 250
  ACK interrupt
  prepara prossimo IRQ → riga 30
  RTI
```

---

## Task Scheduler Cooperativo

```
 Priorita: 0 = VBLANK, 1 = ALTA, 2 = NORMA, 3 = BASSA

 SCHEDULER_LOOP:
   LDX #0               ; parte dalla priorita massima
   ...
   JSR [TASK_PTR,X]     ; esegue un task alla volta
   ...
   JMP SCHEDULER_LOOP

 ┌──────────┬───────────┬───────────────────┐
 │ Priorita │ Frequenza │ Cosa fa           │
 ├──────────┼───────────┼───────────────────┤
 │ 0 VBLANK │ ogni frame│ Legge joystick    │
 │ 1 ALTA   │ ogni frame│ Gestione sprite   │
 │ 2 NORMA  │ ogni frame│ Collisioni, audio │
 │ 3 BASSA  │ ogni 2-3  │ Logica nemici     │
 │          │ frame     │ (non critica)     │
 └──────────┴───────────┴───────────────────┘
```

### Esempio vettori task

```
TaskTable:
  .word Task_Vblank       ; prio 0
  .word Task_Sprites      ; prio 1
  .word Task_GameLogic    ; prio 2
  .word Task_Audio        ; prio 3
```

---

## Flusso Frame Completo

```
   ┌─────────────────────────────────────────────────┐
   │  VBLANK (~11000 cicli CPU)                       │
   │  ├─ Scheduler: priorita 0 (joystick input)       │
   │  ├─ Scheduler: priorita 1 (sprite multiplexing)  │
   │  ├─ Scheduler: priorita 2 (logica di gioco)      │
   │  └─ Scheduler: priorita 3 (audio engine)         │
   ├─────────────────────────────────────────────────┤
   │  RASTER VISIBILE (~18000 cicli CPU)               │
   │  ├─ IRQ Zona HUD (riga 40)                        │
   │  │   └─ setta colore, bordo                       │
   │  ├─ IRQ Zona Gioco (riga 200)                     │
   │  │   └─ setta colore, scroll                      │
   │  ├─ IRQ Zona Barra (riga 250)                     │
   │  │   └─ setta colore, hud inferiore               │
   │  └─ (cicli rimanenti: idle/BASSA priorita)        │
   └─────────────────────────────────────────────────┘
```

---

## Sistema di Pool (Bullet Pool / Object Pool)

```
 POOL: array di strutture entita

 ┌─────┬──────┬──────┬─────┬─────┐
 │ att │  X   │  Y   │tipo │ ... │
 ├─────┼──────┼──────┼─────┼─────┤
 │  0  │  50  │ 100  │  P  │ ... │  ← attivo
 │  0  │  60  │ 120  │  B  │ ... │  ← attivo
 │  1  │  0   │  0   │  0  │ ... │  ← inattivo (libero)
 │  1  │  80  │ 200  │  E  │ ... │  ← attivo
 │  1  │  0   │  0   │  0  │ ... │  ← inattivo (libero)
 └─────┴──────┴──────┴─────┴─────┘
   ↑                     ↑
   flag attivo (1=libero) │
                          prossimo slot disponibile

 Gestione pool:

 CREATE:
   scorri pool → trova entrata con flag=1
   se trovata → flag=0, campi inizializzati
   se piena → non creare (silenzioso fallimento)

 DESTROY:
   flag=1, campi azzerati

 UPDATE:
   scorri pool → per ogni flag=0 → aggiorna
```

---

## Boss State Machine

```
              ┌────────────────────────────┐
              │         INTRO              │
              │ (entra in schermo,         │
              │  lampeggia, grida di       │
              │  battaglia animato)        │
              └───────────┬────────────────┘
                          │
                          ▼
              ┌────────────────────────────┐
         ┌───│       FASE 1               │───┐
         │   │ (schemi di attacco base,   │   │
         │   │  pochi colpi, movimento    │   │
         │   │  semplice)                 │   │
         │   └───────────┬────────────────┘   │
         │               │ health < 66%       │
         │               ▼                    │
         │   ┌────────────────────────────┐   │
         │   │       FASE 2               │   │
         │   │ (piu proiettili, pattern   │   │
         │   │  nuovi, movimento veloce)  │   │
         │   └───────────┬────────────────┘   │
         │               │ health < 33%       │
         │               ▼                    │
         │   ┌────────────────────────────┐   │
         │   │       FASE 3 (ENRAGED)     │   │
         │   │ (attacco furioso,          │   │
         │   │  proiettili ovunque,       │   │
         │   │  effetti speciali)         │   │
         │   └───────────┬────────────────┘   │
         │               │ health = 0         │
         │               ▼                    │
         │   ┌────────────────────────────┐   │
         │   │        MORTE               │   │
         │   │ (animazione esplosione,    │   │
         │   │  punteggio bonus,          │   │
         │   │  eventuali drop)           │   │
         │   └────────────────────────────┘   │
         └────────────────────────────────────┘
   (se ancora vivo → loop nella fase corrente)
```
