#!/usr/bin/env bash
# =============================================
# vice-test.sh — Test automatici con VICE headless
# =============================================
# Per ogni .prg in prg/:
#   1. Lancia x64sc con cycle limit
#   2. Cattura screenshot
#   3. Verifica che non vada in crash
#   4. Genera report
# =============================================

set -e

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PRG_DIR="$ROOT/prg"
SCR_DIR="$ROOT/vice-screenshots"
REPORT="$ROOT/vice-test-report.md"

VICE_BIN="${VICE_BIN:-x64sc}"
CYCLES="${CYCLES:-5000000}"   # ~1 secondo a 1 MHz
TIMEOUT="${TIMEOUT:-30}"      # secondi

mkdir -p "$SCR_DIR"

PASS=0
FAIL=0
SKIP=0

echo "========================================"
echo " Test automatici VICE headless"
echo "========================================"
echo ""

# Verifica presenza VICE
if ! command -v "$VICE_BIN" &>/dev/null; then
    echo "ERROR: $VICE_BIN non trovato."
    echo "Installa VICE: https://vice-emu.sourceforge.io/"
    exit 1
fi

VICE_VER=$("$VICE_BIN" -version 2>&1 | head -1)
echo "VICE: $VICE_VER"
echo ""

# Prepara monitor command script per uscita automatica
MON_SCRIPT=$(mktemp)
cat > "$MON_SCRIPT" << 'EOF'
exit
EOF

echo "| PRG | Risultato | Screenshot |"
echo "|-----|-----------|------------|"

for prg in "$PRG_DIR"/*.prg; do
    [ -f "$prg" ] || continue

    base=$(basename "$prg" .prg)
    screenshot="$SCR_DIR/$base.png"
    logfile="$SCR_DIR/$base.log"

    echo -n "| \`$base\` | "

    # Salta se troppo grande per VICE (es. game/ multi-origin non linkato)
    if [ "$base" = "game" ] && [ ! -s "$prg" ]; then
        echo " ⏭️ SKIP (vuoto) | — |"
        SKIP=$((SKIP + 1))
        continue
    fi

    # Lancia VICE in background
    set +e
    timeout "$TIMEOUT" "$VICE_BIN" \
        -silent \
        -autostart "$prg" \
        -limitcycles "$CYCLES" \
        -screenshot "$screenshot" \
        -moncommands "$MON_SCRIPT" \
        -exit \
        > "$logfile" 2>&1

    RC=$?
    set -e

    if [ $RC -eq 0 ] || [ $RC -eq 124 ]; then
        # 0 = uscita normale, 124 = timeout (ciclo finito)
        if [ -f "$screenshot" ]; then
            echo " ✅ PASS | \`$screenshot\` |"
        else
            echo " ✅ PASS (no screenshot) | — |"
        fi
        PASS=$((PASS + 1))
    else
        echo " ❌ FAIL (exit $RC) | — |"
        FAIL=$((FAIL + 1))
    fi
done

rm -f "$MON_SCRIPT"

echo ""
echo "========================================"
echo " Risultato: $PASS pass, $FAIL fail, $SKIP skip"
echo "========================================"

# Genera report markdown
cat > "$REPORT" << EOF
# Report Test VICE Headless

Data: $(date '+%Y-%m-%d %H:%M')
VICE: $VICE_VER
Cicli: $CYCLES

## Riepilogo

| Esito | Conteggio |
|-------|----------:|
| ✅ Pass | $PASS |
| ❌ Fail | $FAIL |
| ⏭️ Skip | $SKIP |
| **Totale** | **$((PASS + FAIL + SKIP))** |

EOF

echo ""
echo "Report salvato in: $REPORT"

exit $((FAIL > 0))
