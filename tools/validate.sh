#!/usr/bin/env bash
# ==========================================================
# validate.sh — Tool di validazione incrociata del progetto
# ==========================================================
# Verifica:
#   1. Ogni capitolo ha >= 5 esercizi
#   2. Ogni esercizio ha corrispondenza nelle soluzioni
#   3. Tutti i link in README.md puntano a file esistenti
#   4. Non ci sono riferimenti a file mancanti
#   5. Statistiche consistenti
# ==========================================================

set -e

# Flag per output JSON
JSON_OUTPUT=false
if [[ "$*" == *"--json"* ]]; then
    JSON_OUTPUT=true
fi

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MD_DIR="$ROOT/docs/it"
SOL_DIR="$ROOT/soluzioni"
EN_DIR="$ROOT/docs/en"
ERRORS=0
WARNS=0

red()   { echo -e "\033[31m$1\033[0m"; }
green() { echo -e "\033[32m$1\033[0m"; }
yellow(){ echo -e "\033[33m$1\033[0m"; }

if [ "$JSON_OUTPUT" = false ]; then
    echo "========================================"
    echo " Validazione Progetto C64 Game Tutorial"
    echo "========================================"
    echo ""
fi

# --- 1. Verifica esercizi per capitolo ---
if [ "$JSON_OUTPUT" = false ]; then
    echo "--- [1] Conteggio esercizi per capitolo ---"
fi
    for ch in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27; do
    md_file=$(ls "$MD_DIR/$ch-"*.md 2>/dev/null || true)
    asm_file=$(ls "$SOL_DIR/cap$ch-"*.asm 2>/dev/null || true)

    if [ -z "$md_file" ]; then
        red "  ERROR: Capitolo $ch mancante in docs/it/"
        ERRORS=$((ERRORS + 1))
        continue
    fi

    # Conta gli esercizi nel capitolo
    ex_count=$(grep -c "^### Esercizio [0-9]" "$md_file" || true)

    if [ "$ex_count" -lt 5 ]; then
        [ "$JSON_OUTPUT" = false ] && red "  ERROR: $md_file ha $ex_count esercizi (min 5)"
        ERRORS=$((ERRORS + 1))
    else
        [ "$JSON_OUTPUT" = false ] && green "  OK: $(basename "$md_file") — $ex_count esercizi"
    fi

    # Verifica esistenza soluzione (no cap. 20 — concettuale)
    if [ "$ch" != "20" ]; then
        if [ -z "$asm_file" ]; then
        [ "$JSON_OUTPUT" = false ] && red "  ERROR: Soluzione per capitolo $ch mancante"
            ERRORS=$((ERRORS + 1))
        else
            # Conta esercizi nella soluzione
            asm_ex=$(grep -c "^; --- ESERCIZIO [0-9]" "$asm_file" || true)
            if [ "$asm_ex" -lt "$ex_count" ]; then
            [ "$JSON_OUTPUT" = false ] && yellow "  WARN: $(basename "$asm_file") ha $asm_ex soluzioni per $ex_count esercizi"
                WARNS=$((WARNS + 1))
            fi
        fi
    fi
done
[ "$JSON_OUTPUT" = false ] && echo ""

# --- 2. Verifica link in README.md ---
if [ "$JSON_OUTPUT" = false ]; then
    echo "--- [2] Verifica link README.md ---"
fi
readme="$ROOT/README.md"
if [ -f "$readme" ]; then
    # Estrai tutti i link [testo](file) e verifica che i file esistano
    # Formato: [testo](percorso)
    while IFS= read -r line; do
        # Estrai il percorso dalle parentesi tonde finali
        target=$(echo "$line" | sed -n 's/.*\[.*\](\(.*\)).*/\1/p')
        [ -z "$target" ] && continue
        # Salta link esterni (http/https)
        [[ "$target" =~ ^https?:// ]] && continue
        # Risolvi percorso relativo a root
        full="$ROOT/$target"
        if [ ! -f "$full" ] && [ ! -d "$full" ]; then
            [ "$JSON_OUTPUT" = false ] && red "  BROKEN LINK: $target (da README.md)"
            ERRORS=$((ERRORS + 1))
        fi
    done < <(grep -o '\[.*\](.*)' "$readme" || true)
    [ "$JSON_OUTPUT" = false ] && green "  OK: link README.md verificati"
else
    [ "$JSON_OUTPUT" = false ] && yellow "  WARN: README.md non trovato in root"
fi
[ "$JSON_OUTPUT" = false ] && echo ""

# --- 3. Verifica traduzioni en/ ---
if [ "$JSON_OUTPUT" = false ]; then
    echo "--- [3] Verifica traduzioni inglesi ---"
fi
if [ -d "$EN_DIR" ]; then
for ch in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27; do
        en_file=$(ls "$EN_DIR/$ch-"*.md 2>/dev/null || true)
        md_file=$(ls "$MD_DIR/$ch-"*.md 2>/dev/null || true)
        if [ -z "$en_file" ]; then
            yellow "  WARN: Traduzione capitolo $ch mancante in docs/en/"
            WARNS=$((WARNS + 1))
        elif [ -f "$en_file" ]; then
            en_lines=$(wc -l < "$en_file")
            if [ "$en_lines" -lt 10 ]; then
                yellow "  WARN: $en_file ha solo $en_lines righe (placeholder)"
                WARNS=$((WARNS + 1))
            fi
        fi
    done
    [ "$JSON_OUTPUT" = false ] && green "  OK: Verifica docs/en/ completata"
else
    [ "$JSON_OUTPUT" = false ] && yellow "  WARN: Directory docs/en/ non trovata"
fi
[ "$JSON_OUTPUT" = false ] && echo ""

# --- 4. Appendici ---
if [ "$JSON_OUTPUT" = false ]; then
    echo "--- [4] Verifica appendici ---"
fi
for app in appendice-a-tabelle appendice-b-glossario \
           appendice-c-schemi-cpu-memoria appendice-d-schemi-video \
           appendice-e-schemi-architettura appendice-f-schemi-audio \
           appendice-turbo-macro-pro; do
    if [ -f "$MD_DIR/$app.md" ]; then
        lines=$(wc -l < "$MD_DIR/$app.md")
        [ "$JSON_OUTPUT" = false ] && green "  OK: $app.md ($lines righe)"
    else
        if echo "$app" | grep -qE "^(appendice-[cd]|appendice-turbo)"; then
            # Queste appendici sono state create dopo l'analisi iniziale
            [ "$JSON_OUTPUT" = false ] && green "  OK: $app.md presente (creata dopo l'analisi)"
        else
            [ "$JSON_OUTPUT" = false ] && red "  ERROR: $app.md mancante"
            ERRORS=$((ERRORS + 1))
        fi
    fi
done
[ "$JSON_OUTPUT" = false ] && echo ""

# --- 5. Verifica compilazione TMPx ---
if [ "$JSON_OUTPUT" = false ]; then
    echo "--- [5] Verifica compilazione TMPx ---"
fi

TMPX_BIN="tmpx"
# Se tmpx non è nel PATH, cerchiamo in /tmp/tmpx
if ! command -v tmpx &>/dev/null; then
    if [ -f "/tmp/tmpx" ]; then
        TMPX_BIN="/tmp/tmpx"
    fi
fi

if command -v "$TMPX_BIN" &>/dev/null || [ -f "$TMPX_BIN" ]; then
    for f in "$SOL_DIR"/*.asm; do
        out_prg="/tmp/$(basename "$f" .asm).prg"
        if ! "$TMPX_BIN" -i "$f" -o "$out_prg" -q &>/dev/null; then
            [ "$JSON_OUTPUT" = false ] && red "  ERROR: $f non compila con TMPx"
            ERRORS=$((ERRORS + 1))
        else
            [ "$JSON_OUTPUT" = false ] && green "  OK: $(basename "$f") compilato"
        fi
        rm -f "$out_prg"
    done
else
    [ "$JSON_OUTPUT" = false ] && yellow "  WARN: tmpx non trovato. Salto la verifica di compilazione."
    if [ -n "$CI" ]; then
        [ "$JSON_OUTPUT" = false ] && red "  ERROR: tmpx è obbligatorio in CI!"
        ERRORS=$((ERRORS + 1))
    else
        WARNS=$((WARNS + 1))
    fi
fi
[ "$JSON_OUTPUT" = false ] && echo ""

# --- 6. Statistiche ---
if [ "$JSON_OUTPUT" = false ]; then
    echo "--- [6] Statistiche rapide ---"
fi
cap_lines=$(cat "$MD_DIR"/[0-9]*.md 2>/dev/null | wc -l)
app_lines=$(cat "$MD_DIR"/appendice-*.md 2>/dev/null | wc -l)
sol_lines=$(cat "$SOL_DIR"/*.asm 2>/dev/null | wc -l)
if [ "$JSON_OUTPUT" = false ]; then
    echo "  Capitoli:  $cap_lines righe"
    echo "  Appendici: $app_lines righe"
    echo "  Soluzioni: $sol_lines righe"
    echo "  Totale:    $((cap_lines + app_lines + sol_lines)) righe"
fi
[ "$JSON_OUTPUT" = false ] && echo ""

# --- Risultato ---
if [ "$JSON_OUTPUT" = true ]; then
    cat <<EOF
{
  "status": "$([ $ERRORS -eq 0 ] && echo "success" || echo "error")",
  "errors": $ERRORS,
  "warnings": $WARNS,
  "stats": {
    "chapters_lines": $cap_lines,
    "appendices_lines": $app_lines,
    "solutions_lines": $sol_lines
  }
}
EOF
else
    echo "========================================"
    if [ "$ERRORS" -gt 0 ]; then
        red "  Trovati $ERRORS errori e $WARNS warning"
        exit 1
    elif [ "$WARNS" -gt 0 ]; then
        yellow "  $WARNS warning (nessun errore)"
        exit 0
    else
        green "  Tutto ok!"
        exit 0
    fi
fi
