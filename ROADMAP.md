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

### 9. PDF Mapping_the_Commodore_64 troncato

Il PDF `Compute_s_Mapping_the_Commodore_64.pdf` ha solo 2 pagine ma pesa 29.8 MB — probabilmente scansione ad alta risoluzione o file corrotto.

**Azione:** Sostituire con una copia integra o rimuovere (il manuale "Programmer's Reference Guide" e piu che sufficiente come riferimento).

---

### 10. 02-istruzioni-fondamentali: esercizio svolto integrato

Il capitolo 02 contiene la sezione "Rainbow effetto (esercizio svolto)" che e un esempio completo ma non e separato dagli esercizi finali. Un principiante potrebbe confonderlo con un esercizio obbligatorio.

**Azione:** Spostarlo in una sezione "Esempio Svolto" ben evidenziata prima degli esercizi, o trasformarlo nell'esercizio 5 del capitolo.

---

## Visione a Lungo Termine

### 11. Progetto assemblato funzionante .prg

Attualmente le soluzioni sono file `.asm` separati. Un obiettivo ambizioso e fornire un file `.prg` pre-assemblato e funzionante su C64 reale/emulatore per ogni capitolo.

**Azione:** Script di build che assembla tutte le soluzioni e genera `.prg` pronti da caricare.

---

### 12. Makefile / Script di automazione

Un `Makefile` (o script bash) per:
- assemblare tutte le soluzioni con TMP
- generare report di dimensione del codice
- validare la sintassi di tutti i `.asm`
- contare righe/byte per capitolo

---

### 13. Tool di validazione incrociata

Uno script che:
- verifica che ogni esercizio in `md/` abbia corrispondenza in `soluzioni/`
- verifica che ogni link in README punti a file esistente
- verifica che il numero di esercizi sia >= 5 per capitolo
- rileva caratteri non PETSCII o sintassi TMP non valida

---

### 14. Espansione con capitolo su caricatore/loader

Un capitolo 21 su come scrivere un caricatore personalizzato (raster loader o loader con effetti) per il gioco finale. Completamento naturale del percorso.

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
| 8 | BASSA | PDF troncato da sostituire | 30 min |
| 9 | BASSA | Rainbow effetto da separare | 30 min |
| 10 | FUTURO | File .prg pre-assemblati | 5-7 giorni |
| 11 | FUTURO | Makefile automazione | 2-3 giorni |
| 12 | FUTURO | Tool validazione incrociata | 2 giorni |
| 13 | FUTURO | Capitolo 21 caricatore | 5-7 giorni |
