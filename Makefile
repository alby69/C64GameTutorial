# Makefile per C64 Game Tutorial — Build, validazione e statistiche
#
# Prerequisiti:
#   TMPx cross-assembler: https://style64.org/release/tmpx-v1.1.0-style
#   Oppure su Debian/Ubuntu: sudo apt install tmpx (se disponibile)
#
# Obiettivi principali:
#   make all       — assembla tutte le soluzioni in .prg
#   make validate  — controlla consistenza esercizi/capitoli
#   make stats     — mostra statistiche righe/byte per capitolo
#   make clean     — rimuove i .prg generati

TMPX := tmpx
SOL_DIR := soluzioni
PRG_DIR := prg
MD_DIR := md

CHAPTERS := 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19
SOL_FILES := $(addprefix $(SOL_DIR)/cap, $(addsuffix -*, $(CHAPTERS)))
PRG_FILES := $(addprefix $(PRG_DIR)/cap, $(addsuffix .prg, $(CHAPTERS)))

.PHONY: all validate stats clean dirs check-tmpx

all: dirs check-tmpx $(PRG_FILES)

dirs:
	@mkdir -p $(PRG_DIR)

check-tmpx:
	@command -v $(TMPX) >/dev/null 2>&1 || { \
		echo "ERROR: tmpx non trovato. Installa TMPx da:"; \
		echo "  https://style64.org/release/tmpx-v1.1.0-style"; \
		exit 1; \
	}

# Regola generica: .asm → .prg
$(PRG_DIR)/cap01.prg: $(SOL_DIR)/cap01-introduzione.asm
	$(TMPX) -o $@ $<

$(PRG_DIR)/cap02.prg: $(SOL_DIR)/cap02-istruzioni.asm
	$(TMPX) -o $@ $<

$(PRG_DIR)/cap03.prg: $(SOL_DIR)/cap03-indirizzamento.asm
	$(TMPX) -o $@ $<

$(PRG_DIR)/cap04.prg: $(SOL_DIR)/cap04-memoria-video.asm
	$(TMPX) -o $@ $<

$(PRG_DIR)/cap05.prg: $(SOL_DIR)/cap05-sprite.asm
	$(TMPX) -o $@ $<

$(PRG_DIR)/cap06.prg: $(SOL_DIR)/cap06-movimento-sprite.asm
	$(TMPX) -o $@ $<

$(PRG_DIR)/cap07.prg: $(SOL_DIR)/cap07-raster.asm
	$(TMPX) -o $@ $<

$(PRG_DIR)/cap08.prg: $(SOL_DIR)/cap08-game-loop.asm
	$(TMPX) -o $@ $<

$(PRG_DIR)/cap09.prg: $(SOL_DIR)/cap09-joystick.asm
	$(TMPX) -o $@ $<

$(PRG_DIR)/cap10.prg: $(SOL_DIR)/cap10-collisioni.asm
	$(TMPX) -o $@ $<

$(PRG_DIR)/cap11.prg: $(SOL_DIR)/cap11-proiettili.asm
	$(TMPX) -o $@ $<

$(PRG_DIR)/cap12.prg: $(SOL_DIR)/cap12-wave-ai.asm
	$(TMPX) -o $@ $<

$(PRG_DIR)/cap13.prg: $(SOL_DIR)/cap13-punteggio-stati.asm
	$(TMPX) -o $@ $<

$(PRG_DIR)/cap14.prg: $(SOL_DIR)/cap14-audio-base.asm
	$(TMPX) -o $@ $<

$(PRG_DIR)/cap15.prg: $(SOL_DIR)/cap15-audio-engine.asm
	$(TMPX) -o $@ $<

$(PRG_DIR)/cap16.prg: $(SOL_DIR)/cap16-multiplexing.asm
	$(TMPX) -o $@ $<

$(PRG_DIR)/cap17.prg: $(SOL_DIR)/cap17-parallax-raster-split.asm
	$(TMPX) -o $@ $<

$(PRG_DIR)/cap18.prg: $(SOL_DIR)/cap18-boss.asm
	$(TMPX) -o $@ $<

$(PRG_DIR)/cap19.prg: $(SOL_DIR)/cap19-kernel-engine.asm
	$(TMPX) -o $@ $<

# Statistiche
stats:
	@echo "=== Statistiche progetto ==="
	@echo ""
	@echo "--- Capitoli (md/) ---"
	@wc -l $(MD_DIR)/[0-9]*.md | sort -t/ -k2
	@echo ""
	@echo "--- Soluzioni (soluzioni/) ---"
	@wc -l $(SOL_DIR)/*.asm | sort -t/ -k2
	@echo ""
	@echo "--- Traduzioni (en/) ---"
	@wc -l en/[0-9]*.md en/README.md 2>/dev/null | sort -t/ -k2 || echo "(nessuna traduzione)"
	@echo ""
	@echo "--- Totale righe ---"
	@echo -n "  Capitoli: "; cat $(MD_DIR)/[0-9]*.md | wc -l
	@echo -n "  Soluzioni: "; cat $(SOL_DIR)/*.asm 2>/dev/null | wc -l
	@echo -n "  Appendici: "; cat $(MD_DIR)/appendice-*.md 2>/dev/null | wc -l
	@echo -n "  Totale:    "; cat $(MD_DIR)/[0-9]*.md $(MD_DIR)/appendice-*.md $(SOL_DIR)/*.asm 2>/dev/null | wc -l
	@echo ""
	@echo "--- Byte dei .prg (se generati) ---"
	@ls -la $(PRG_DIR)/*.prg 2>/dev/null | awk '{print $$5, $$9}' || echo "(nessun .prg)"

# Validazione
validate:
	@echo "=== Validazione progetto ==="
	@errors=0; \
	for ch in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21; do \
		md_file="$$(ls $(MD_DIR)/$$ch-*.md 2>/dev/null)"; \
		asm_file="$$(ls $(SOL_DIR)/cap$$ch-*.asm 2>/dev/null)"; \
		if [ -z "$$md_file" ]; then \
			echo "  WARN: capitolo $$ch mancante in md/"; \
			continue; \
		fi; \
		ex_count=$$(sed -n '/^### Esercizio/,/^### Esercizio/p' "$$md_file" | grep -c "^### Esercizio"); \
		if [ "$$ex_count" -lt 5 ] && [ "$$ch" != "20" ]; then \
			echo "  ERROR: $$md_file ha $$ex_count esercizi (servono 5)"; \
			errors=$$((errors + 1)); \
		elif [ "$$ch" = "20" ] && [ "$$ex_count" -lt 5 ]; then \
			echo "  ERROR: $$md_file ha $$ex_count esercizi (servono 5)"; \
			errors=$$((errors + 1)); \
		else \
			echo "  OK: $$md_file ($$ex_count esercizi)"; \
		fi; \
		if [ "$$ch" != "20" ] && [ -z "$$asm_file" ]; then \
			echo "  ERROR: soluzione per capitolo $$ch mancante"; \
			errors=$$((errors + 1)); \
		fi; \
	done; \
	echo ""; \
	if [ "$$errors" -gt 0 ]; then \
		echo "Trovati $$errors errori."; \
		exit 1; \
	else \
		echo "Nessun errore trovato."; \
	fi

# Pulisci .prg generati
clean:
	rm -rf $(PRG_DIR)
