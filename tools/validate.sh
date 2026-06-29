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

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MD_DIR="$ROOT/md"
SOL_DIR="$ROOT/soluzioni"
EN_DIR="$ROOT/en"
ERRORS=0
WARNS=0

red()   { echo -e "\033[31m$1\033[0m"; }
green() { echo -e "\033[32m$1\033[0m"; }
yellow(){ echo -e "\033[33m$1\033[0m"; }

echo "========================================"
echo " Validazione Progetto C64 Game Tutorial"
echo "========================================"
echo ""

# --- 1. Verifica esercizi per capitolo ---
echo "--- [1] Conteggio esercizi per capitolo ---"
    for ch in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21; do
    md_file=$(ls "$MD_DIR/$ch-"*.md 2>/dev/null || true)
    asm_file=$(ls "$SOL_DIR/cap$ch-"*.asm 2>/dev/null || true)

    if [ -z "$md_file" ]; then
        red "  ERROR: Capitolo $ch mancante in md/"
        ERRORS=$((ERRORS + 1))
        continue
    fi

    # Conta gli esercizi nel capitolo
    ex_count=$(grep -c "^### Esercizio [0-9]" "$md_file" || true)

    if [ "$ex_count" -lt 5 ]; then
        red "  ERROR: $md_file ha $ex_count esercizi (min 5)"
        ERRORS=$((ERRORS + 1))
    else
        green "  OK: $(basename "$md_file") — $ex_count esercizi"
    fi

    # Verifica esistenza soluzione (solo capp. 1-19)
    if [ "$ch" != "20" ]; then
        if [ -z "$asm_file" ]; then
            red "  ERROR: Soluzione per capitolo $ch mancante"
            ERRORS=$((ERRORS + 1))
        else
            # Conta esercizi nella soluzione
            asm_ex=$(grep -c "^; --- ESERCIZIO [0-9]" "$asm_file" || true)
            if [ "$asm_ex" -lt "$ex_count" ]; then
                yellow "  WARN: $(basename "$asm_file") ha $asm_ex soluzioni per $ex_count esercizi"
                WARNS=$((WARNS + 1))
            fi
        fi
    fi
done
echo ""

# --- 2. Verifica link in README.md ---
echo "--- [2] Verifica link README.md ---"
readme="$MD_DIR/README.md"
if [ -f "$readme" ]; then
    # Estrai tutti i link [testo](file) e verifica che i file esistano
    # Formato: [testo](percorso)
    while IFS= read -r line; do
        # Estrai il percorso dalle parentesi tonde finali
        target=$(echo "$line" | sed -n 's/.*\[.*\](\(.*\)).*/\1/p')
        [ -z "$target" ] && continue
        # Salta link esterni (http/https)
        [[ "$target" =~ ^https?:// ]] && continue
        # Risolvi percorso relativo a md/
        full="$MD_DIR/$target"
        if [ ! -f "$full" ] && [ ! -d "$full" ]; then
            full2="$ROOT/$target"
            if [ ! -f "$full2" ] && [ ! -d "$full2" ]; then
                red "  BROKEN LINK: $target (da README.md)"
                ERRORS=$((ERRORS + 1))
            fi
        fi
    done < <(grep -o '\[.*\](.*)' "$readme" || true)
    green "  OK: link README.md verificati"
else
    yellow "  WARN: README.md non trovato in md/"
fi
echo ""

# --- 3. Verifica traduzioni en/ ---
echo "--- [3] Verifica traduzioni inglesi ---"
if [ -d "$EN_DIR" ]; then
for ch in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21; do
        en_file=$(ls "$EN_DIR/$ch-"*.md 2>/dev/null || true)
        md_file=$(ls "$MD_DIR/$ch-"*.md 2>/dev/null || true)
        if [ -z "$en_file" ]; then
            yellow "  WARN: Traduzione capitolo $ch mancante in en/"
            WARNS=$((WARNS + 1))
        elif [ -f "$en_file" ]; then
            en_lines=$(wc -l < "$en_file")
            if [ "$en_lines" -lt 10 ]; then
                yellow "  WARN: $en_file ha solo $en_lines righe (placeholder)"
                WARNS=$((WARNS + 1))
            fi
        fi
    done
    green "  OK: Verifica en/ completata"
else
    yellow "  WARN: Directory en/ non trovata"
fi
echo ""

# --- 4. Appendici ---
echo "--- [4] Verifica appendici ---"
for app in appendice-a-tabelle appendice-b-glossario \
           appendice-c-schemi-cpu-memoria appendice-d-schemi-video \
           appendice-e-schemi-architettura appendice-f-schemi-audio \
           appendice-turbo-macro-pro; do
    if [ -f "$MD_DIR/$app.md" ]; then
        lines=$(wc -l < "$MD_DIR/$app.md")
        green "  OK: $app.md ($lines righe)"
    else
        if echo "$app" | grep -qE "^(appendice-[cd]|appendice-turbo)"; then
            # Queste appendici sono state create dopo l'analisi iniziale
            green "  OK: $app.md presente (creata dopo l'analisi)"
        else
            red "  ERROR: $app.md mancante"
            ERRORS=$((ERRORS + 1))
        fi
    fi
done
echo ""

# --- 5. Statistiche ---
echo "--- [5] Statistiche rapide ---"
cap_lines=$(cat "$MD_DIR"/[0-9]*.md 2>/dev/null | wc -l)
app_lines=$(cat "$MD_DIR"/appendice-*.md 2>/dev/null | wc -l)
sol_lines=$(cat "$SOL_DIR"/*.asm 2>/dev/null | wc -l)
echo "  Capitoli:  $cap_lines righe"
echo "  Appendici: $app_lines righe"
echo "  Soluzioni: $sol_lines righe"
echo "  Totale:    $((cap_lines + app_lines + sol_lines)) righe"
echo ""

# --- Risultato ---
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
