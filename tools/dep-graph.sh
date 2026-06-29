#!/usr/bin/env bash
# =============================================
# dep-graph.sh — Mappa dipendenze tra capitoli
# =============================================
# Scansiona i file .md in md/ per riferimenti
# incrociati e genera un grafo DOT.
#
# Uso:
#   bash tools/dep-graph.sh          # stampa DOT
#   bash tools/dep-graph.sh | dot -Tsvg -o deps.svg
#   bash tools/dep-graph.sh --md     # tabella markdown
# =============================================

set -e

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MD_DIR="$ROOT/md"

# Ottieni numero capitolo dal filename
ch_num() {
    local f=$(basename "$1")
    echo "$f" | sed 's/^0*//; s/-.*//'
}

# Ottieni titolo capitolo dal filename (senza numero)
ch_title() {
    local f=$(basename "$1")
    echo "$f" | sed 's/^[0-9]*-//; s/\.md$//'
}

# Raccogli riferimenti
declare -A REFS
declare -A CHAPTERS

for f in "$MD_DIR"/[0-9]*.md; do
    src=$(ch_num "$f")
    src_title=$(ch_title "$f")
    CHAPTERS["$src"]="$src_title"

    # Cerca riferimenti ad altri capitoli: (capitolo X), [Capitolo X](...
    targets=$(grep -oiP '(capitolo\s*\d+|chapter\s*\d+|\[Capitolo\s+\d+|\[Chapter\s+\d+)' "$f" \
        | grep -oP '\d+' || true)

    for t in $targets; do
        # Salta riferimenti a se stesso
        [ "$t" = "$src" ] && continue
        # Salta numeri fuori range
        [ "$t" -lt 1 ] || [ "$t" -gt 30 ] && continue
        REFS["$src->$t"]=1
    done
done

MODE="${1:-dot}"

if [ "$MODE" = "--md" ]; then
    echo "# Mappa Dipendenze Capitoli"
    echo ""
    echo "| Capitolo | Dipende da |"
    echo "|----------|------------|"

    for src in $(echo "${!CHAPTERS[@]}" | tr ' ' '\n' | sort -n); do
        deps=""
        for tgt in $(echo "${!CHAPTERS[@]}" | tr ' ' '\n' | sort -n); do
            [ "$src" = "$tgt" ] && continue
            if [ "${REFS[$src->$tgt]:-}" = "1" ]; then
                [ -n "$deps" ] && deps="$deps, "
                deps="${deps}$tgt (${CHAPTERS[$tgt]})"
            fi
        done
        [ -z "$deps" ] && deps="—"
        echo "| $src — ${CHAPTERS[$src]} | $deps |"
    done
    echo ""
    echo "Generato da \`tools/dep-graph.sh\`."
else
    # DOT format
    echo "digraph C64Tutorial {"
    echo "  rankdir=LR;"
    echo "  node [shape=box, style=rounded];"
    echo "  splines=true;"
    echo ""

    for src in $(echo "${!CHAPTERS[@]}" | tr ' ' '\n' | sort -n); do
        echo "  ch$src [label=\"$src - ${CHAPTERS[$src]}\"];"
    done

    echo ""

    for edge in $(echo "${!REFS[@]}" | tr ' ' '\n' | sort -n); do
        src=$(echo "$edge" | cut -d- -f1)
        tgt=$(echo "$edge" | cut -d- -f3)
        echo "  ch$src -> ch$tgt;"
    done

    echo "}"
fi
