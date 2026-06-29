# ROADMAP — Miglioramenti del Progetto C64 Game Tutorial

Analisi effettuata il 2026-06-29 — aggiornata al commit `HEAD`.

---

## Stato Attuale (22/22 completati — Nuova Fase)

Tutti i 22 punti originali sono stati completati. Di seguito i nuovi
miglioramenti proposti per la prossima fase del progetto.

| # | Area | Stato |
|---|---|---|
| 1-22 | Punti originali (struttura, traduzioni, capitoli 22-24, tooling) | ✅ |
| 23 | Appendici A-B in inglese | ✅ |
| 24 | CI/CD GitHub Actions (build + validate automatici) | ✅ |
| 25 | Generazione PDF da markdown | ✅ |
| 26 | Template gioco espanso (scroll + high score + title) | ✅ |
| 27 | Tool convertitore PNG → dati sprite C64 | ✅ |
| 28 | Capitolo caricatore turbo (fast loader) | ✅ |
| 29 | Capitolo REU (RAM Expansion Unit) | ✅ |
| 30 | Integrazione music tracker (GoatTracker/DefMon) | ✅ |
| 31 | Sito web statico del manuale | ✅ |
| 32 | Mappa dipendenze tra capitoli | ✅ |

**Riepilogo:** 9/10 nuovi completati, 0 in corso, 1 aperto.

---

## Completati Fase 1

### 1–14. Struttura progetto, traduzioni, tooling

Esercizi uniformati a 5/capitolo, `.gitignore`, mappa esercizi nei file
soluzione, traduzione inglese completa (24 capitoli), appendici inglesi
(placeholder), Makefile con build `.prg` e automazione, validazione
incrociata (`tools/validate.sh`, `make validate`).

### 15. Soluzione capitolo 20

`soluzioni/cap20-arcade-os.asm` — 5 demo concettuali (chaining interrupt,
virtualizzazione sprite, self-modify, 3-layer, skeleton game).

### 16. Gioco completo unificato

`game/` — template vertical shooter multi-file con 13 file `.asm`,
architettura 3-layer (INPUT→LOGIC→RENDER), scheduler a 50 Hz,
sistema entità, player, nemici, collisioni, audio.

### 17. Debugging con VICE

`md/22-debugging-vice.md` + traduzione inglese + soluzioni.
Monitor VICE, breakpoint/watchpoint, raster debug, stack debug.

### 18. Schermate titolo e high score

`md/23-titolo-highscore.md` + traduzione inglese + soluzioni.
Titolo animato, KERNAL SAVE/LOAD per high score, game-over.

### 19. Scrolling hardware

`md/24-scrolling.md` + traduzione inglese + soluzioni.
Scroll fine/grossolano, raster split, parallax, verticale.

### 20. Tabella dimensioni codice

`tools/size-report.sh` — genera tabella markdown con origine/righe/esercizi/byte.
Tabella integrata in `soluzioni/README.md`. `make size-report`.

### 21. Test automatici VICE headless

`tools/vice-test.sh` — per ogni `.prg` lancia `x64sc` con cycle limit
e screenshot. `make vice-test`.

### 22. Indice analitico

`md/INDICE.md` — registri VIC-II/CIA/SID, istruzioni 6502, routine KERNAL,
mappa memoria, comandi VICE, concetti per capitolo.

---

## Nuove Proposte (Fase 2)

### 23. ✅ Appendici A-B in inglese

`en/appendix-a-reference-tables.md` e `en/appendix-b-glossary.md`.
Tabelle di riferimento (colori, memoria, registri, istruzioni) e glossario
completo tradotti dall'italiano.

---

### 24. ✅ CI/CD GitHub Actions

`.github/workflows/validate.yml` — esegue `make validate` e
`tools/validate.sh` su ogni push/PR al branch `main`.

---

### 25. ✅ Generazione PDF da markdown

`tools/build-pdf.sh` — usa pandoc + xelatex per generare un unico PDF
con tutti i 24 capitoli + appendici, TOC, evidenziazione sintassi.

---

### 26. ✅ Template gioco espanso (scroll + high score + title)

Nuovi file:
- `game/scroll.asm` — scrolling starfield a 2 layer (parallax)
- `game/highscore.asm` — salvataggio/caricamento high score su disco

Modificati:
- `game/main.asm` — include chain aggiornata
- `game/config.asm` — nuove variabili ZP (scroll, HS)
- `game/states.asm` — title con HS, scrolling durante il gioco,
  game-over con verifica e salvataggio record

---

### 27. ✅ Tool convertitore PNG → dati sprite C64

`tools/png2sprite.py` — converte immagini PNG (24x21 o 12x21 pixel)
in dati sprite C64 (64 byte, multicolor o HIRES). Output in formato `.asm`.

---

### 28. ✅ Capitolo caricatore turbo

`md/25-turbo-loader.md` + `en/25-turbo-loader.md` + soluzioni.
Lettura diretta GCR, IRQ loader, parallel cable.

---

### 29. ✅ Capitolo REU (RAM Expansion Unit)

`md/26-reu-expansion.md` + `en/26-reu-expansion.md` + soluzioni.
Registri DMA, copia C64↔REU, bank swapping, salvataggio stato.

---

### 30. ✅ Integrazione music tracker

`md/27-music-tracker-integration.md` + `en/27-music-tracker-integration.md` + soluzioni.
Player minimale, mixer musica+SFX, integrazione GoatTracker.

---

### 31. Sito web statico del manuale

Generare una versione HTML navigabile del manuale con
indice, ricerca, link cliccabili, esempi di codice colorati.

**Azione:** Template statico + script di generazione.

---

### 32. ✅ Mappa dipendenze tra capitoli

`tools/dep-graph.sh` — genera grafico DOT delle dipendenze tra capitoli.
Mostra quali prerequisiti servono prima di ogni capitolo.

---

## Riepilogo Priorità (Fase 2)

| # | Priorità | Cosa | Sforzo |
|---|---|---|---|
| 23 | ✅ | Appendici A-B in inglese | 2 giorni |
| 24 | ✅ | CI/CD GitHub Actions | 1 giorno |
| 25 | ✅ | Generazione PDF | 2 giorni |
| 26 | ✅ | Template gioco espanso | 1-2 settimane |
| 27 | ✅ | Tool convertitore PNG → sprite | 1 giorno |
| 28 | ✅ | Capitolo caricatore turbo | 3-4 giorni |
| 29 | ✅ | Capitolo REU | 2-3 giorni |
| 30 | ✅ | Integrazione music tracker | 3-4 giorni |
| 31 | ✅ | Sito web statico | 1 settimana |
| 32 | ✅ | Mappa dipendenze capitoli | 1 giorno |
