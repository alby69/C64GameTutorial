# Changelog

Tutti i cambiamenti significativi a questo progetto saranno documentati in questo file.

Il formato è basato su [Keep a Changelog](https://keepachangelog.com/it-IT/1.1.0/).

## [1.0.0] - 2026-07-01

### Aggiunto
- **Sito Web Statico**: Generazione automatica con MkDocs Material e deploy su GitHub Pages.
- **Workflow CI/CD**:
    - Validazione e assemblaggio automatico di tutte le soluzioni con TMPx.
    - Generazione automatica del PDF del manuale.
- **Supporto Capitolo 20**: Aggiunto file placeholder `soluzioni/cap20-arcade-os.asm` per completezza del build.
- **Anteprima Tool**: Anteprima ASCII nel terminale per `tools/png2sprite.py`.
- **Documentazione**:
    - Creato `CONTRIBUTING.md` con linee guida per i contributori.
    - Creato `CHANGELOG.md` (questo file).
    - Aggiunti Issue Template per segnalazione errori nei capitoli.
    - Documentazione della cartella `data/`.
- **Risorse Comunità**: Link a CSDb e Lemon64 nel README.

### Modificato
- **Makefile**: Aggiunto target `make help`, gestione errori migliorata e supporto per il capitolo 20.
- **README**: Aggiornate le statistiche del progetto, aggiunto badge dello stato CI e sezione Quick Start.
- **Roadmap**: Portata a termine la Fase 2 (32/32 punti completati).

### Sicurezza
- Corretti i link al repository che puntavano a un utente errato.
