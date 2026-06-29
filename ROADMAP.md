# ROADMAP — Miglioramenti del Progetto C64 Game Tutorial

Analisi effettuata il 2026-06-29 su 91 file totali (69 MB, di cui 69 MB di PDF).

---

## Criticita — Da risolvere subito

### 1. Numero esercizi incoerente

Il README promette "5 esercizi per capitolo", ma la realta e:

| Capitolo | Esercizi | Dovrebbero |
|---|---|---|
| 01 | 3 | 5 |
| 02 | 4 | 5 |
| 04 | 4 | 5 |
| 05 | 4 | 5 |
| 20 | 0 | 5 |

**Azione:** Uniformare a 5 esercizi per tutti i capitoli. Per il cap.20, creare 5 esercizi concettuali sull'Arcade OS (es. "spiega la differenza tra interrupt chaining e polling"). Aggiungere le relative soluzioni in `soluzioni/cap20-arcade-os.asm`.

---

### 2. .gitignore assente

I 3 PDF in `manuali/` pesano 69 MB. Senza `.gitignore` vengono tracciati da Git, appesantendo inutilmente il repository.

**Azione:** Creare `.gitignore` con:

```
manuali/
*.prg
*.bin
*.o
```

---

### 3. Mappatura esercizi incompleta in testa ai file soluzione

I file in `soluzioni/` hanno sezioni commentate ma manca una mappa veloce all'inizio che colleghi ogni esercizio al paragrafo del capitolo corrispondente.

**Azione:** Aggiungere un'intestazione a ogni `.asm` con tabella esercizio→riferimento capitolo.

---

### 4. docs/ directory vuota

La directory `docs/` non contiene nulla. Va ripulita o usata.

**Azione:** Rimuovere `docs/` dal tracking finche non ci sono contenuti da metterci.

---

## Miglioramenti a Medio Termine

### 5. Traduzione inglese (en/)

22 file su 23 sono placeholder di 4 righe. Il progetto e in italiano, ma una traduzione inglese lo renderebbe accessibile a tutta la community C64.

**Azione:** Tradurre capitolo per capitolo partendo dalla Parte 1 (fondamenti) che e propedeutica. Lasciare il README come roadmap della traduzione.

---

### 6. Tabella riepilogativa soluzioni

Manca un file `soluzioni/README.md` che descriva cosa contiene ogni soluzione, come assemblarle e come caricarle su C64 o emulatore.

**Azione:** Creare `soluzioni/README.md` con istruzioni per VICE/CCS64, comandi TMP, e tabella esercizio→file.

---

### 7. Appendici inglesi (en/)

Le appendici E e F esistono in `md/` ma non hanno corrispettivo in `en/`. Una volta tradotte le appendici A-B, vanno aggiunte anche C-D-E-F nella directory `en/`.

---

### 8. Riferimenti incrociati tra capitoli

I capitoli non hanno link tra loro (es. "vedi cap. 7 per i raster interrupt" o "vedi soluzione in soluzioni/capXX.asm").

**Azione:** Aggiungere una sezione "Riferimenti" in fondo a ogni capitolo con link ad altri capitoli e alla soluzione corrispondente.

---

### 9. ✅ PDF Mapping_the_Commodore_64 troncato — RISOLTO

Il PDF corrotto era gia stato rimosso da `manuali/`. Ora contiene solo 2 PDF integri.

---

### 10. 02-istruzioni-fondamentali: esercizio svolto integrato

Il capitolo 02 contiene la sezione "Rainbow effetto (esercizio svolto)" che e un esempio completo ma non e separato dagli esercizi finali. Un principiante potrebbe confonderlo con un esercizio obbligatorio.

**Azione:** Spostarlo in una sezione "Esempio Svolto" ben evidenziata prima degli esercizi, o trasformarlo nell'esercizio 5 del capitolo.

---

## Visione a Lungo Termine

### 11. ✅ Progetto assemblato funzionante .prg — RISOLTO

Il `Makefile` genera `.prg` da ogni `.asm` in `soluzioni/` con `make all`.
I file `.prg` vanno in `prg/` (gitignored).

---

### 12. ✅ Makefile / Script di automazione — RISOLTO

`Makefile` creato con target: `all` (assembla .prg), `stats` (conta righe/byte),
`validate` (esegue tools/validate.sh), `clean`.

---

### 13. ✅ Tool di validazione incrociata — RISOLTO

`tools/validate.sh` verifica: conteggio esercizi >=5, link README, soluzioni
corrispondenti, traduzioni presenti, appendici integre.

---

### 14. ✅ Espansione con capitolo su caricatore/loader — RISOLTO

Creato `md/21-caricatore-personalizzato.md` con: caricatore KERNAL, effetto raster,
caricamento settore per settore, turbo loader, boot loader a 3 fasi.
Soluzioni in `soluzioni/cap21-caricatore.asm`.
Placeholder inglese in `en/21-custom-loader.md`.

---

## Riepilogo Priorita

| # | Priorita | Cosa | Sforzo |
|---|---|---|---|
| 1 | CRITICA | Uniformare esercizi a 5/capitolo | 2-3 giorni |
| 2 | CRITICA | Creare .gitignore | 10 min |
| 3 | ALTA | Mappa esercizi in soluzioni/ | 1 giorno |
| 4 | ALTA | docs/ vuota: rimuovere o popolare | 10 min |
| 5 | MEDIA | Traduzione inglese Parte 1 | 3-4 giorni |
| 6 | MEDIA | soluzioni/README.md | 1 giorno |
| 7 | MEDIA | Riferimenti incrociati nei capitoli | 2-3 giorni |
| 8 | ✅ COMPLETATO | PDF troncato rimosso | — |
| 9 | BASSA | Rainbow effetto da separare | 30 min |
| 10 | ✅ COMPLETATO | File .prg via Makefile | — |
| 11 | ✅ COMPLETATO | Makefile automazione | — |
| 12 | ✅ COMPLETATO | Tool validazione incrociata | — |
| 13 | ✅ COMPLETATO | Capitolo 21 caricatore | — |
