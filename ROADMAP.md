# ROADMAP — Miglioramenti del Progetto C64 Game Tutorial

Analisi effettuata il 2026-06-29 — aggiornata al commit `HEAD`.

---

## Stato Attuale (32/32 completati — Fase 3+)

Tutti i 32 punti originali e della Fase 2 sono stati completati. Di seguito i nuovi
miglioramenti proposti per elevare il tutorial al livello "Master", coprendo le
tecniche dei leggendari programmatori degli anni '80.

| # | Area | Stato |
|---|---|---|
| 1-32 | Fasi 1 e 2 completate (Capitoli 01-27, Tooling, CI/CD) | ✅ |
| 33 | Capitolo custom charset (tiles) | ❌ |
| 34 | Creazione immagini disco .d64 | ❌ |
| 35 | **Capitolo: Self-Modifying Code** (Pattern Braybrook) | ❌ |
| 36 | **Capitolo: Memory Overlay & Bank Switching** | ❌ |
| 37 | **Capitolo: Scrolling Full-Screen Professionale** | ❌ |
| 38 | **Capitolo: Sprite Multiplexing Avanzato** | ❌ |
| 39 | **Capitolo: Stable Raster & Timing di Ciclo** | ❌ |
| 40 | **Capitolo: FLI/FLD e Tecniche Demo-Scene** | ❌ |
| 41 | **Capitolo: SID Avanzato (Filter, Ring Mod, Sync)** | ❌ |
| 42 | **Capitolo: Entity Component System (ECS) in 6502** | ❌ |
| 43 | **Capitolo: Compressione e Fast Loader IRQ** | ❌ |
| 44 | **Capitolo: Debug e Profiling su Hardware Reale** | ❌ |
| 45 | **Sezione: Code Archaeology** (Analisi Elite/Cadaver) | ❌ |

---

## Completati Fase 1 e 2

### 1–14. Struttura progetto, traduzioni, tooling
Esercizi uniformati, traduzione inglese completa, Makefile, validazione automatica.

### 15-20. Arcade OS e Kernel
`soluzioni/cap20-arcade-os.asm`, architettura 3-layer, template gioco completo.

### 21-27. Strumenti e Refiniture
Debugging VICE, Titolo/High Score, Scrolling, size-report, vice-test, PNG→sprite.

### 28-32. Hardware Avanzato e Web
Turbo Loader, REU, Music Tracker, Sito Web Statico, Mappa dipendenze.

---

## 🏗️ Fase 3: Le Tecniche dei Maestri

L'obiettivo è coprire le tecniche di **ottimizzazione estrema** e **gestione memoria** che hanno reso leggendari i lavori di Andrew Braybrook, Jeff Minter e Tony Crowther.

### 35. Self-Modifying Code (SMC)
- Variabili integrate nelle istruzioni (Immediate → Absolute).
- Puntatori senza indirezione.
- Salti condizionali "nascosti" tramite byte-eating.

### 36. Memory Overlay & Bank Switching
- Gestione dei 64KB oltre i limiti del KERNAL/BASIC.
- Pattern per caricamenti single-load con sovrascrittura del codice di boot.
- Memory map dinamica e allocator minimale.

### 37. Scrolling Full-Screen Professionale
- Redraw della Color RAM a $D800$ (split raster).
- Ottimizzazioni per il redraw (skip color write).
- Parallax multilayer con charset switching e FLD.

### 38. Sprite Multiplexing Avanzato
- Algoritmi di sorting "a ordine persistente" (oltre il bubble sort).
- Gestione di 32+ sprite con sincronizzazione perfetta.

---

## 🎨 Fase 4: Grafica e Audio Elite

### 39. Stable Raster & Timing di Ciclo
- Tecnica del "Double IRQ" per raster stabilizzato al ciclo singolo.
- Sincronizzazione sprite nel border.
- Gestione delle "Bad Lines" del VIC-II.

### 40. FLI/FLD e Tecniche Demo-Scene
- Flexible Line Distance per scroll verticale fluido.
- Flexible Line Interpretation (FLI) per grafica ad alta risoluzione/colore.

### 41. SID Avanzato
- Design dei filtri risonanti.
- Ring Modulation e Hard Sync per effetti metallici/alieni.
- Mixer software per musica e SFX simultanei senza conflitti.

---

## 📐 Fase 5: Architettura e Ottimizzazione

### 42. Entity Component System (ECS) in 6502
- Evoluzione dal pool di entità verso Struct of Arrays (SoA).
- Update selettivo basato su bitmask/flags.

### 43. Compressione e Fast Loader IRQ
- Integrazione con Exomizer/Byteboozer.
- Scrittura di un loader IRQ che carica dati durante il gameplay.

### 44. Debug e Profiling Real-Hardware
- Utilizzo del border color trick come oscilloscopio software.
- Profiling dei cicli CPU per ogni routine critica.

### 45. Sezione: Code Archaeology
Analisi approfondita di sorgenti reali:
- **Elite C64** (Mark Moxon): gestione 3D e economia procedurale.
- **C64 Game Framework** (Cadaver): architettura professionale moderna.
- **Uridium/Paradroid** (Braybrook): analisi delle routine di scroll e SMC.
