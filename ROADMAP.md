# ROADMAP — Miglioramenti del Progetto C64 Game Tutorial

Analisi effettuata il 2026-06-29 — aggiornata al commit `63cd848`.

---

## Stato Attuale (27/27 punti)

| # | Area | Stato |
|---|---|---|
| 1 | Esercizi uniformati a 5/capitolo | ✅ |
| 2 | .gitignore presente | ✅ |
| 3 | Mappa esercizi in testa ai file soluzione | ✅ |
| 4 | docs/ vuota rimossa | ✅ |
| 5 | Traduzione inglese en/ | 🔄 3/24 tradotti |
| 6 | soluzioni/README.md presente | ✅ |
| 7 | Appendici inglesi C,D,E,F mancanti | 🔄 |
| 8 | Riferimenti incrociati tra capitoli | ✅ |
| 9 | PDF troncato rimosso | ✅ |
| 10 | Rainbow effetto in cap02 da separare | 🔄 |
| 11 | Makefile: build .prg | ✅ |
| 12 | Makefile: automazione | ✅ |
| 13 | Tool validazione incrociata | ✅ |
| 14 | Capitolo 21 caricatore | ✅ |

**Riepilogo:** 11/14 completati, 3 in corso.

---

## Ancora Aperti

### 5. 🔄 Traduzione inglese (en/)

| Capitolo | italiano | inglese | Stato |
|---|---|---|---|
| 01 | 295 righe | 304 righe | ✅ Tradotto |
| 02 | 323 righe | 331 righe | ✅ Tradotto |
| 03 | 352 righe | 361 righe | ✅ Tradotto |
| 04-21 | ~7500 righe | 4 righe cad. | ❌ Placeholder |
| App. A-B | ~580 righe | 4 righe cad. | ❌ Placeholder |

**Azione:** Tradurre capitolo per capitolo partendo dalla Parte 2 (sprite/video)
che e piu interessante per i nuovi arrivati.

---

### 7. 🔄 Appendici inglesi C,D,E,F (en/)

In `md/` esistono 6 appendici (A-F) + turbo macro pro.
In `en/` esistono solo A e B come placeholder.

**Azione:** Aggiungere `en/appendix-c-*`, `en/appendix-d-*`, `en/appendix-e-*`,
`en/appendix-f-*`, `en/appendix-turbo-macro-pro.md`.

---

### 10. 🔄 Rainbow effetto da separare (cap02)

Il capitolo 02 ha una sezione `2.9 Rainbow effetto (esempio svolto)` che e un
esempio completo ma e in mezzo al testo prima degli esercizi. Un principiante
potrebbe confonderlo con un esercizio obbligatorio.

**Azione:** Spostarlo in una sezione "Esempio Svolto" ben evidenziata prima
degli esercizi, o trasformarlo nell'esercizio 5 del capitolo.

---

## Nuove Proposte — Miglioramenti Futuri

### 15. Soluzione mancante per capitolo 20

`soluzioni/cap20-arcade-os.asm` non esiste. Tutti gli altri capitoli hanno
la loro soluzione.

**Azione:** Creare 5 soluzioni per il cap.20 (Arcade OS, interrupt chaining,
self-modifying code).

---

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

## Riepilogo Priorita Aggiornato

| # | Priorita | Cosa | Sforzo |
|---|---|---|---|
| 1-4 | ✅ COMPLETATO | Struttura progetto | — |
| 5 | 🔄 ALTA | Traduzione inglese Parte 2 | 5-7 giorni |
| 6 | ✅ COMPLETATO | soluzioni/README.md | — |
| 7 | 🔄 MEDIA | Appendici inglesi C-F | 2 giorni |
| 8 | ✅ COMPLETATO | Riferimenti incrociati | — |
| 9 | ✅ COMPLETATO | PDF troncato | — |
| 10 | 🔄 BASSA | Rainbow effetto da separare | 30 min |
| 11-14 | ✅ COMPLETATO | Makefile, validazione, cap21 | — |
| **15** | MEDIA | Soluzione cap.20 mancante | 1 giorno |
| **16** | ALTA | Gioco completo unificato | 7-10 giorni |
| **17** | MEDIA | Capitolo 22 debugging VICE | 3-4 giorni |
| **18** | MEDIA | Capitolo 23 titolo/highscore | 3-4 giorni |
| **19** | MEDIA | Capitolo 24 scrolling | 3-4 giorni |
| **20** | BASSA | Tabella dimensioni codice | 1 giorno |
| **21** | BASSA | Test automatici VICE | 3-4 giorni |
| **22** | BASSA | Indice analitico | 1 giorno |
