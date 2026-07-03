#!/usr/bin/env bash
# =============================================
# size-report.sh — Tabella dimensioni codice
# =============================================
# Genera una tabella markdown con:
#   - Capitolo
#   - File soluzione
#   - Indirizzo origine (*=)
#   - Righe di codice
#   - Esercizi
#   - Byte .prg (se disponibile)
# =============================================

set -e

JSON_OUTPUT=false
if [[ "$*" == *"--json"* ]]; then
    JSON_OUTPUT=true
fi

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SOL_DIR="$ROOT/soluzioni"
PRG_DIR="$ROOT/prg"

if [ "$JSON_OUTPUT" = false ]; then
    echo "# Report Dimensioni Codice"
    echo ""
    echo "Generato il: $(date '+%Y-%m-%d %H:%M')"
    echo ""
    echo "| Cap | File | Origine | Righe | Esercizi | PRG byte |"
    echo "|-----|------|---------|------:|---------:|---------:|"
fi

# Processa file in ordine numerico
for f in "$SOL_DIR"/cap[0-9]*.asm; do
    base=$(basename "$f")
    ch=$(echo "$base" | sed 's/cap0*//; s/-.*//')

    # Linee totali
    lines=$(wc -l < "$f")

    # Conta esercizi
    ex=$(grep -c "^; --- ESERCIZIO [0-9]" "$f" || true)

    # Primo indirizzo *= (normalizza spazi)
    origin=$(grep -m1 '^\*=' "$f" | sed 's/^\*=[[:space:]]*\$//; s/[[:space:]]*;.*//')
    if [ -z "$origin" ]; then
        origin="N/A"
    else
        origin="\$$origin"
    fi

    # PRG size se disponibile
    prg_size="N/A"
    prg_file="$PRG_DIR/cap$ch.prg"
    if [ -f "$prg_file" ]; then
        prg_size=$(wc -c < "$prg_file")
        prg_size="$prg_size B"
    fi

    if [ "$JSON_OUTPUT" = false ]; then
        echo "| $ch | \`$base\` | $origin | $lines | $ex | $prg_size |"
    fi
done

# Aggiungi game/ se disponibile
if [ -d "$ROOT/game" ]; then
    game_lines=$(find "$ROOT/game" -name '*.asm' -exec cat {} + | wc -l)
    game_files=$(find "$ROOT/game" -name '*.asm' | wc -l)
    prg_size="N/A"
    if [ -f "$PRG_DIR/game.prg" ]; then
        prg_size=$(wc -c < "$PRG_DIR/game.prg")
        prg_size="$prg_size B"
    fi
    if [ "$JSON_OUTPUT" = false ]; then
        echo "| — | \`game/\` ($game_files file) | — | $game_lines | — | $prg_size |"
    fi
fi

total_sol_lines=$(cat "$SOL_DIR"/*.asm 2>/dev/null | wc -l)

if [ "$JSON_OUTPUT" = true ]; then
    echo "{\"total_solutions_lines\": $total_sol_lines}"
else
    echo ""
    echo "---"
    echo ""
    echo "Righe totali soluzioni: $total_sol_lines"
fi
