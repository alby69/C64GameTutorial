# ROADMAP — Miglioramenti del Progetto C64 Game Tutorial

Analisi effettuata il 2026-06-29 — aggiornata al commit `HEAD`.

---

## Stato Attuale (22/22 completati — Nuova Fase)

Tutti i 22 punti originali sono stati completati. Di seguito i nuovi
miglioramenti proposti per la prossima fase del progetto.

| # | Area | Stato |
|---|---|---|
| 1-22 | Punti originali (struttura, traduzioni, capitoli 22-24, tooling) | ✅ |
| 23 | Appendici A-B in inglese | ❌ |
| 24 | CI/CD GitHub Actions (build + validate automatici) | ❌ |
| 25 | Generazione PDF da markdown | ❌ |
| 26 | Template gioco espanso in gioco completo giocabile | ❌ |
| 27 | Tool convertitore PNG → dati sprite C64 | ❌ |
| 28 | Capitolo caricatore turbo (fast loader) | ❌ |
| 29 | Capitolo REU (RAM Expansion Unit) | ❌ |
| 30 | Integrazione music tracker (GoatTracker/DefMon) | ❌ |
| 31 | Sito web statico del manuale | ❌ |
| 32 | Mappa dipendenze tra capitoli | ❌ |

**Riepilogo:** 0/10 nuovi completati, 0 in corso, 10 aperti.

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

### 23. Appendici A-B in inglese

Traduzione di `md/appendice-a-tabelle.md` e `md/appendice-b-glossario.md`
in `en/appendix-a-reference-tables.md` e `en/appendix-b-glossary.md`.

**Azione:** Tradurre le due appendici mancanti.

---

### 24. CI/CD GitHub Actions

Workflow automatico che esegue `make validate` e `tools/validate.sh`
su ogni push e pull request.

**Azione:** Creare `.github/workflows/validate.yml`.

---

### 25. Generazione PDF da markdown

Script che converte tutti i capitoli in un unico PDF impaginato
(con `pandoc` + template LaTeX o `md-to-pdf`).

**Azione:** `tools/build-pdf.sh` + template.

---

### 26. Template gioco espanso in gioco completo

Completare il template `game/` in un gioco giocabile: livelli,
scoring completo, schermata titolo, game over, high score su disco,
boss finale, audio SFX.

**Azione:** Espandere `game/` con contenuti dai capitoli 13, 18, 23, 24.

---

### 27. Tool convertitore PNG → dati sprite C64

Script Python che converte immagini PNG (24x21 o 12x21 pixel)
in dati sprite C64 (64 byte, multicolor o HIRES).

**Azione:** `tools/png2sprite.py` — output in formato `.asm`.

---

### 28. Capitolo caricatore turbo

Tecniche per velocizzare il caricamento da disco 1541:
lettura diretta della GCR, IRQ loader, parallel cable, JiffyDOS.

**Azione:** `md/25-turbo-loader.md` + soluzioni.

---

### 29. Capitolo REU (RAM Expansion Unit)

Utilizzo della REU 1700/1750/1764 per espandere la RAM
oltre i 64 KB: copia rapida, swap banchi, DMA.

**Azione:** `md/26-reu-expansion.md` + soluzioni.

---

### 30. Integrazione music tracker

Suonare musica composta con GoatTracker o DefMon da assembly:
formato `.sid`, player routine, integrazione con SFX.

**Azione:** Capitolo su player SID + esempio musica + soluzioni.

---

### 31. Sito web statico del manuale

Generare una versione HTML navigabile del manuale con
indice, ricerca, link cliccabili, esempi di codice colorati.

**Azione:** Template statico + script di generazione.

---

### 32. Mappa dipendenze tra capitoli

Grafico (testuale o SVG) che mostra le dipendenze tra capitoli:
quali prerequisiti servono prima di affrontare un capitolo.

**Azione:** `tools/dep-graph.sh` → output DOT/SVG.

---

## Riepilogo Priorità (Fase 2)

| # | Priorità | Cosa | Sforzo |
|---|---|---|---|
| 23 | ALTA | Appendici A-B in inglese | 2 giorni |
| 24 | ALTA | CI/CD GitHub Actions | 1 giorno |
| 25 | MEDIA | Generazione PDF | 2 giorni |
| 26 | MEDIA | Template gioco espanso | 1-2 settimane |
| 27 | BASSA | Tool convertitore PNG → sprite | 1 giorno |
| 28 | BASSA | Capitolo caricatore turbo | 3-4 giorni |
| 29 | BASSA | Capitolo REU | 2-3 giorni |
| 30 | BASSA | Integrazione music tracker | 3-4 giorni |
| 31 | BASSA | Sito web statico | 1 settimana |
| 32 | BASSA | Mappa dipendenze capitoli | 1 giorno |
