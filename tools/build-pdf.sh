#!/usr/bin/env bash
# =============================================
# build-pdf.sh — Genera PDF del manuale
# =============================================
# Concatena tutti i capitoli + appendici e
# genera un PDF con pandoc + xelatex.
#
# Prerequisiti:
#   sudo apt install pandoc texlive-xetex
# =============================================

set -e

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUTDIR="$ROOT/pdf"
MD_DIR="$ROOT/md"

# Verifica pandoc
if ! command -v pandoc &>/dev/null; then
    echo "ERROR: pandoc non trovato. Installa con:"
    echo "  sudo apt install pandoc texlive-xetex"
    exit 1
fi

mkdir -p "$OUTDIR"

# Prepara lista file in ordine
FILES=()
for ch in $(seq -w 1 24); do
    f=$(ls "$MD_DIR/$ch"-*.md 2>/dev/null | head -1)
    [ -n "$f" ] && FILES+=("$f")
done

# Aggiungi appendici
for app in "$MD_DIR"/appendice-*.md; do
    [ -f "$app" ] && FILES+=("$app")
done

echo "File da includere: ${#FILES[@]}"
for f in "${FILES[@]}"; do
    echo "  $(basename "$f")"
done

# Combina
COMBINED=$(mktemp /tmp/c64-tutorial-XXXXXX.md)
for f in "${FILES[@]}"; do
    cat "$f" >> "$COMBINED"
    echo "" >> "$COMBINED"
    echo "\\newpage" >> "$COMBINED"
done

# Genera PDF
OUTFILE="$OUTDIR/C64-Game-Tutorial.pdf"
pandoc "$COMBINED" \
    -o "$OUTFILE" \
    --pdf-engine=xelatex \
    --toc \
    --toc-depth=2 \
    --highlight-style=tango \
    -V geometry:margin=2.5cm \
    -V title="C64 Arcade Game Programming Manual" \
    -V author="C64 Game Tutorial Project" \
    -V date="$(date '+%Y-%m-%d')" \
    -V papersize:a4 \
    -V mainfont="DejaVu Sans Mono" \
    -V monofont="DejaVu Sans Mono"

rm -f "$COMBINED"

echo ""
echo "PDF generato: $OUTFILE"
echo "Pagine: $(pdfinfo "$OUTFILE" 2>/dev/null | grep Pages | awk '{print $2}' || echo '?')"
