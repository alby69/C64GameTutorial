# ROADMAP — Miglioramenti del Progetto C64 Game Tutorial

Analisi effettuata il 2026-06-29 — aggiornata al commit `HEAD`.

---

## Stato Attuale (35/35 punti)

| # | Area | Stato |
|---|---|---|
| 1 | Esercizi uniformati a 5/capitolo | ✅ |
| 2 | .gitignore presente | ✅ |
| 3 | Mappa esercizi in testa ai file soluzione | ✅ |
| 4 | docs/ vuota rimossa | ✅ |
| 5 | Traduzione inglese en/ | ✅ 21/21 capitoli tradotti |
| 6 | soluzioni/README.md presente | ✅ |
| 7 | Appendici inglesi en/ | ✅ Placeholder C,D,E,F,TMP |
| 8 | Riferimenti incrociati tra capitoli | ✅ |
| 9 | PDF troncato rimosso | ✅ |
| 10 | Rainbow effetto in cap02 separato | ✅ |
| 11 | Makefile: build .prg | ✅ |
| 12 | Makefile: automazione | ✅ |
| 13 | Tool validazione incrociata | ✅ |
| 14 | Capitolo 21 caricatore | ✅ |
| 15 | Soluzione capitolo 20 mancante | ✅ |
| 16 | Gioco completo unificato | ❌ |
| 17 | Debugging con VICE (cap. 22) | ❌ |
| 18 | Schermate titolo e high score (cap. 23) | ❌ |
| 19 | Scrolling a schermo (cap. 24) | ❌ |
| 20 | Tabella dimensioni codice | ❌ |
| 21 | Test automatici con VICE headless | ❌ |
| 22 | Indice analitico | ❌ |

**Riepilogo:** 15/22 completati, 0 in corso, 7 aperti.

---

## Completati

### 5. ✅ Traduzione inglese (en/)

Tutti i 21 capitoli sono tradotti in inglese:

| Capitolo | Righe | Stato |
|---|---|---|
| 01-03 | ~1000 | ✅ Tradotto |
| 04-17 | ~5600 | ✅ Tradotto |
| 18-21 | ~1700 | ✅ Tradotto |
| Appendici A-B | ~580 | ❌ Ancora da tradurre |
| Appendici C-F, TMP | ~1400 | ✅ Placeholder esistenti |

### 7. ✅ Appendici inglesi C,D,E,F (en/)

File placeholder creati in `en/`:
- `en/appendix-c-cpu-memory.md`
- `en/appendix-d-video-schematics.md`
- `en/appendix-e-architecture-schematics.md`
- `en/appendix-f-audio-schematics.md`
- `en/appendix-turbo-macro-pro.md`

### 10. ✅ Rainbow effetto separato (cap02)

Spostato in sezione "💡 ESEMPIO SVOLTO" prima degli esercizi, in entrambe le versioni.

---

## Ancora Aperti

### 15. ✅ Soluzione per capitolo 20

`soluzioni/cap20-arcade-os.asm` creato con 5 dimostrazioni pratiche:
1. Interrupt chaining (catena IRQ a 3 stadi)
2. Sprite virtualization (mapping 32 -> 8 HW)
3. Self-modifying code (jump table auto-patching)
4. Architettura 3-layer (kernel/engine/game)
5. Scheletro gioco completo (Space Invaders minimal)

Nota: le soluzioni non sono assemblabili come singolo .prg perche
gli esercizi sono concettuali; il file e un riferimento didattico.

---

## Nuove Proposte — Miglioramenti Futuri

### 16. Gioco completo unificato

Tutti i capitoli insegnano concetti separati. Un file `.prg` finale che
unisca TUTTI i concetti in un unico gioco giocabile (shooter con sprite,
multiplexing, raster, audio, loader, boss, wave system, punteggio).

**Azione:** Creare `soluzioni/game-finale.asm` e `prg/game-finale.prg`.

---

### 17. Debugging con VICE (capitolo 22)

Le soluzioni sono testabili solo caricandole su C64 o emulatore. Manca una
guida al debugging con VICE: breakpoint, monitor assembly, watchpoint, trace.

**Azione:** Scrivere `md/22-debugging-vice.md` con esercizi su come usare
il monitor di VICE per trovare bug.

---

### 18. Schermate titolo e high score (capitolo 23)

Il ciclo di gioco non ha una schermata titolo ne un sistema di high score
persistente (salvataggio su disco).

**Azione:** Scrivere `md/23-titolo-highscore.md` — schermata titolo con
sprite animate, lettura/scrittura high score su disco.

---

### 19. Scrolling a schermo (capitolo 24)

Manca lo scrolling hardware/software del C64: scroll verticale orizzontale,
scroll a 8 pixel, scroll a 1 pixel, fine scrolling con raster.

**Azione:** Scrivere `md/24-scrolling.md` con esercizi su scroll
verticale, orizzontale, parallasse avanzato.

---

### 20. Tabella dimensioni codice

Uno script che genera una tabella markdown con righe/byte/indirizzo per
ogni soluzione, da includere in `soluzioni/README.md`.

**Azione:** `tools/size-report.sh` → tabella markdown.

---

### 21. Test automatici con VICE headless

Usare `x64sc -moncommands` per caricare ogni soluzione, verificare che
non vada in crash, e catturare screenshot.

**Azione:** Script che lancia VICE in modalita test per ogni `.prg`.

---

### 22. Indice analitico

Una pagina `md/INDICE.md` con elenco di tutti i registri, indirizzi,
istruzioni e concetti, con link al capitolo che li introduce.

---

## Riepilogo Priorita

| # | Priorita | Cosa | Sforzo |
|---|---|---|---|
| 1-14 | ✅ COMPLETATO | Struttura progetto, traduzioni, tooling | — |
| 15 | ✅ COMPLETATO | Soluzione cap.20 | — |
| 16 | ALTA | Gioco completo unificato | 7-10 giorni |
| 17 | MEDIA | Capitolo 22 debugging VICE | 3-4 giorni |
| 18 | MEDIA | Capitolo 23 titolo/highscore | 3-4 giorni |
| 19 | MEDIA | Capitolo 24 scrolling | 3-4 giorni |
| 20 | BASSA | Tabella dimensioni codice | 1 giorno |
| 21 | BASSA | Test automatici VICE | 3-4 giorni |
| 22 | BASSA | Indice analitico | 1 giorno |
