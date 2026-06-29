# Manuale di Programmazione per Giochi Arcade su C64

> Turbo Macro Pro — Assembly 6502 — VIC-II — SID

## Struttura del Manuale

```
md/
├── 01-03   PARTE 1 — Fondamenti di 6502 e TMP
├── 04-06   PARTE 2 — Grafica e Sprite
├── 07-08   PARTE 3 — Raster Interrupt e Sincronismo
├── 09-13   PARTE 4 — Gameplay
├── 14-15   PARTE 5 — Audio SID
├── 16-18   PARTE 6 — Tecniche Avanzate
├── 19-20   PARTE 7 — Architettura Professionale
├── A-TMP   Appendici (A-F + TMP)
```

---

## PARTE 1 — Fondamenti

| File | Argomento | Riga | Obiettivi |
|---|---|---|---|
| [01-introduzione-c64-tmp.md](01-introduzione-c64-tmp.md) | CPU 6510, memoria, TMP, primo programma | 292 | Ambientarsi, compilare, eseguire |
| [02-istruzioni-fondamentali.md](02-istruzioni-fondamentali.md) | Istruzioni LDA/STA, registri A/X/Y, Zero Page | 322 | Dichiarare variabili, confrontare valori |
| [03-indirizzamento-cicli-ritardi.md](03-indirizzamento-cicli-ritardi.md) | Indirizzamento, stack, ritardi software | 355 | Cicli, array, sottoroutine |

## PARTE 2 — Grafica e Sprite

| File | Argomento | Riga | Obiettivi |
|---|---|---|---|
| [04-memoria-video-e-caratteri.md](04-memoria-video-e-caratteri.md) | Screen RAM, Color RAM, caratteri, HUD | 361 | Testo a schermo, menu, layout |
| [05-sprite-hardware-vic-ii.md](05-sprite-hardware-vic-ii.md) | Registri VIC-II, sprite pointer, primo sprite | 308 | Visualizzare uno sprite a schermo |
| [06-movimento-e-controllo-sprite.md](06-movimento-e-controllo-sprite.md) | Movimento X/Y, MSB, multicolore, animazione | 430 | Muovere e animare sprite |

## PARTE 3 — Raster Interrupt e Sincronismo

| File | Argomento | Riga | Obiettivi |
|---|---|---|---|
| [07-raster-interrupt.md](07-raster-interrupt.md) | Raster beam, IRQ, ISR, cambio colore | 410 | Installare un interrupt al raster |
| [08-game-loop-sincronizzato.md](08-game-loop-sincronizzato.md) | Game loop 50 Hz, frame counter, animazione | 466 | Struttura portante del gioco |

## PARTE 4 — Gameplay

| File | Argomento | Riga | Obiettivi |
|---|---|---|---|
| [09-joystick-e-input.md](09-joystick-e-input.md) | CIA $DC01, edge detection, movimento player | 418 | Controllare il giocatore |
| [10-collisioni-software.md](10-collisioni-software.md) | Bounding box, $D01E, reazioni | 371 | Rilevare scontri tra sprite |
| [11-sistema-proiettili.md](11-sistema-proiettili.md) | Pool, spawn, movimento, rimozione | 498 | Sparare e gestire proiettili |
| [12-wave-system-e-ai-nemici.md](12-wave-system-e-ai-nemici.md) | Onde nemiche, pseudo-AI, difficolta | 487 | Creare ondate di nemici intelligenti |
| [13-punteggio-e-stati-gioco.md](13-punteggio-e-stati-gioco.md) | Punteggio 16 bit, state machine, reset | 473 | Gestire MENU → PLAY → GAME OVER |

## PARTE 5 — Audio

| File | Argomento | Riga | Obiettivi |
|---|---|---|---|
| [14-audio-sid-base.md](14-audio-sid-base.md) | SID $D400, frequenza, waveform, beep | 338 | Primi suoni con il chip SID |
| [15-audio-engine-e-sfx.md](15-audio-engine-e-sfx.md) | Coda SFX, canali, integrazione raster | 364 | Sistema audio professionale |

## PARTE 6 — Tecniche Avanzate

| File | Argomento | Riga | Obiettivi |
|---|---|---|---|
| [16-sprite-multiplexing.md](16-sprite-multiplexing.md) | Multiplexing, zone raster, buffer | 435 | Mostrare 8+ sprite sullo schermo |
| [17-parallax-e-raster-split.md](17-parallax-e-raster-split.md) | Raster split, parallax, scroll | 479 | Effetti di profondita e separazione HUD |
| [18-boss-system.md](18-boss-system.md) | Boss multi-fase, pattern attacco, transizioni | 510 | Scontri epici con boss finali |

## PARTE 7 — Architettura Professionale

| File | Argomento | Riga | Obiettivi |
|---|---|---|---|
| [19-kernel-engine-riutilizzabile.md](19-kernel-engine-riutilizzabile.md) | Kernel engine 3 strati, entity system, memoria | 469 | Struttura modulare riutilizzabile |
| [20-arcade-os-e-oltre.md](20-arcade-os-e-oltre.md) | Arcade OS, interrupt chaining, self-mod code | 294 | Concetti finali e orizzonti |

## Appendici

| File | Argomento | Riga |
|---|---|---|
| [appendice-a-tabelle.md](appendice-a-tabelle.md) | Tabelle colori, memoria, registri VIC-II/SID/CIA, istruzioni 6502, PETSCII | 312 |
| [appendice-b-glossario.md](appendice-b-glossario.md) | Glossario di tutti i termini usati nel manuale | 267 |
| [appendice-c-schemi-cpu-memoria.md](appendice-c-schemi-cpu-memoria.md) | CPU 6510, flag, indirizzamento, stack, mappa memoria, CIA/joystick | 310 |
| [appendice-d-schemi-video.md](appendice-d-schemi-video.md) | Screen RAM layout, sprite data format, VIC-II registri, raster IRQ, split zone, collisioni | 255 |
| [appendice-e-schemi-architettura.md](appendice-e-schemi-architettura.md) | 3-layer architecture, state machine, wave system, game loop, scheduler, pool, boss AI | 290 |
| [appendice-f-schemi-audio.md](appendice-f-schemi-audio.md) | SID registri, forme d'onda, ADSR, pipeline audio, parallasse, budget cicli, CIA/VIC-II control | 232 |
| [appendice-turbo-macro-pro.md](appendice-turbo-macro-pro.md) | Guida rapida a TMP: installazione, sintassi, pseudo-op, macro, editor, comandi, TMPx | 290 |

---

## Come usare il manuale

1. **Sequenziale**: i capitoli sono in ordine di difficolta crescente
2. **Esercizi**: ogni capitolo termina con 5 esercizi per verificare l'apprendimento
3. **Prerequisiti**: PARTE 1 e propedeutica a tutto il resto; PARTE 4 presuppone PARTE 3; PARTE 6 presuppone PARTE 4
4. **Codice**: tutti gli snippet sono in sintassi Turbo Macro Pro e possono essere copiati e assemblati direttamente

---

## Riepilogo

| Parti | File | Righe totali |
|---|---|---|
| PARTE 1 — Fondamenti | 3 | ~970 |
| PARTE 2 — Grafica | 3 | ~1100 |
| PARTE 3 — Raster/Sync | 2 | ~880 |
| PARTE 4 — Gameplay | 5 | ~2250 |
| PARTE 5 — Audio | 2 | ~700 |
| PARTE 6 — Avanzato | 3 | ~1420 |
| PARTE 7 — Architettura | 2 | ~760 |
| Appendici | 7 | ~1950 |
| **Totale** | **27** | **~10500** |
