# Makefile per C64 Game Tutorial — Build, validazione e statistiche
#
# Prerequisiti:
#   TMPx cross-assembler: https://style64.org/release/tmpx-v1.1.0-style
#   KickAssembler: java -jar tools/KickAss.jar
#
# Obiettivi principali:
#   make all            — assembla tutte le soluzioni TMPx e KickAssembler
#   make validate       — controlla consistenza esercizi/capitoli
#   make stats          — mostra statistiche righe/byte per capitolo
#   make clean          — rimuove i .prg generati

TMPX := tmpx
SOL_DIR := soluzioni
PRG_DIR := prg
MD_DIR := docs/it

# KickAssembler Configuration
KICKASS_JAR := tools/KickAss.jar
KICKASS := java -jar $(KICKASS_JAR)
BUILD := build
SRC := src
KICKASS_SOL_DIR := soluzioni/kickass

CHAPTERS := 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 21 22 23 24 25 26 27
SOL_FILES := $(addprefix $(SOL_DIR)/cap, $(addsuffix -*, $(CHAPTERS)))
PRG_FILES := $(addprefix $(PRG_DIR)/cap, $(addsuffix .prg, $(CHAPTERS)))

KICKASS_CH := 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44
KICKASS_PRG_FILES := $(addprefix $(BUILD)/cap, $(addsuffix .prg, $(KICKASS_CH)))

.PHONY: all validate stats clean dirs check-tmpx size-report vice-test kickass-all

all: dirs kickass-all

dirs:
	@mkdir -p $(PRG_DIR)
	@mkdir -p $(BUILD)

$(KICKASS_JAR):
	@mkdir -p tools
	@wget -q http://theweb.dk/KickAssembler/KickAssembler.zip -O /tmp/KickAssembler.zip
	@unzip -q -o /tmp/KickAssembler.zip -d /tmp/kickass-extracted
	@cp /tmp/kickass-extracted/KickAss.jar $(KICKASS_JAR)

check-tmpx:
	@command -v $(TMPX) >/dev/null 2>&1 || { \
		echo "ERROR: tmpx non trovato. Installa TMPx da:"; \
		echo "  https://style64.org/release/tmpx-v1.1.0-style"; \
		exit 1; \
	}

# Regola generica: .asm → .prg per TMPx
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

$(PRG_DIR)/cap21.prg: $(SOL_DIR)/cap21-caricatore.asm
	$(TMPX) -o $@ $<

$(PRG_DIR)/cap22.prg: $(SOL_DIR)/cap22-debugging.asm
	$(TMPX) -o $@ $<

$(PRG_DIR)/cap23.prg: $(SOL_DIR)/cap23-titolo-highscore.asm
	$(TMPX) -o $@ $<

$(PRG_DIR)/cap24.prg: $(SOL_DIR)/cap24-scrolling.asm
	$(TMPX) -o $@ $<

$(PRG_DIR)/cap25.prg: $(SOL_DIR)/cap25-turbo-loader.asm
	$(TMPX) -o $@ $<

$(PRG_DIR)/cap26.prg: $(SOL_DIR)/cap26-reu-expansion.asm
	$(TMPX) -o $@ $<

$(PRG_DIR)/cap27.prg: $(SOL_DIR)/cap27-music-tracker.asm
	$(TMPX) -o $@ $<

# Gioco completo unificato (TMPx)
GAME_DIR := game
GAME_DEPS := $(wildcard $(GAME_DIR)/*.asm)

$(PRG_DIR)/game.prg: $(GAME_DIR)/main.asm $(GAME_DEPS)
	@if grep -q "BasicUpstart" $(GAME_DIR)/main.asm; then \
		echo "Skipping TMPx compilation for game.prg because game is now converted to KickAssembler."; \
	else \
		$(TMPX) -o $@ $<; \
	fi

# --- KickAssembler Targets ---

kickass-all: dirs $(KICKASS_JAR) $(KICKASS_PRG_FILES) $(BUILD)/game.prg

# Template helper macro per i capitoli KickAss
define KICKASS_CH_RULE
$(BUILD)/cap$(1).prg: $(firstword $(wildcard $(SRC)/cap$(1)/cap$(1).asm) $(wildcard $(KICKASS_SOL_DIR)/cap$(1)-*.asm)) | dirs $(KICKASS_JAR)
	@if [ -n "$<" ]; then \
		$(KICKASS) -o $$@ $<; \
	fi
cap$(1): $(BUILD)/cap$(1).prg
endef

$(foreach ch,$(KICKASS_CH),$(eval $(call KICKASS_CH_RULE,$(ch))))

# Gioco completo KickAss
$(BUILD)/game.prg: game/main.asm $(GAME_DEPS) | dirs $(KICKASS_JAR)
	$(KICKASS) -o $@ $<
game-kickass: $(BUILD)/game.prg

# Statistiche
stats:
	@echo "=== Statistiche progetto ==="
	@echo ""
	@echo "--- Capitoli (docs/it/) ---"
	@wc -l $(MD_DIR)/[0-9]*.md | sort -t/ -k2
	@echo ""
	@echo "--- Soluzioni (soluzioni/) ---"
	@wc -l $(SOL_DIR)/*.asm | sort -t/ -k2
	@echo ""
	@echo "--- Traduzioni (docs/en/) ---"
	@wc -l docs/en/[0-9]*.md docs/en/README.md 2>/dev/null | sort -t/ -k2 || echo "(nessuna traduzione)"
	@echo ""
	@echo "--- Totale righe ---"
	@echo -n "  Capitoli: "; cat $(MD_DIR)/[0-9]*.md | wc -l
	@echo -n "  Soluzioni: "; cat $(SOL_DIR)/*.asm 2>/dev/null | wc -l
	@echo -n "  Appendici: "; cat $(MD_DIR)/appendice-*.md 2>/dev/null | wc -l
	@echo -n "  Totale:    "; cat $(MD_DIR)/[0-9]*.md $(MD_DIR)/appendice-*.md $(SOL_DIR)/*.asm 2>/dev/null | wc -l
	@echo ""
	@echo "--- Byte dei .prg (se generati) ---"
	@ls -la $(PRG_DIR)/*.prg 2>/dev/null | awk '{print $$5, $$9}' || echo "(nessun .prg)"

# Validazione standard
validate:
	@tools/validate.sh

# Validazione per Intelligence SDK (output JSON)
validate-sdk:
	@tools/validate.sh --json

# Report dimensioni codice
size-report:
	@tools/size-report.sh

# Test automatici VICE (richiede VICE installato)
vice-test:
	@tools/vice-test.sh

# Pulisci .prg generati
clean:
	rm -rf $(PRG_DIR)
	rm -rf $(BUILD)
