#!/usr/bin/env bash
#
# build-site.sh — Genera sito web HTML statico del manuale
#
# Prerequisiti:
#   pandoc (con template HTML5)
#   python3 (per wiki-graph.py)
#
# Uso:
#   ./tools/build-site.sh              # genera site/
#   ./tools/build-site.sh --open       # genera e apre nel browser
#
# Output in site/
#   index.html               — homepage
#   wiki-graph.svg           — mappa concettuale interattiva
#   md/                      — capitoli in HTML
#   en/                      — traduzioni in HTML
#   assets/                  — CSS/JS
#   soluzioni/               — soluzioni in HTML preformattato
#

set -euo pipefail
cd "$(dirname "$0")/.."

SITE_DIR="site"
MD_DIR="md"
EN_DIR="en"
SOL_DIR="soluzioni"
CSS_FILE="$SITE_DIR/assets/style.css"
JS_FILE="$SITE_DIR/assets/script.js"

mkdir -p "$SITE_DIR/assets" "$SITE_DIR/md" "$SITE_DIR/en" "$SITE_DIR/soluzioni"

# ── 1. CSS ────────────────────────────────────────────
cat > "$CSS_FILE" << 'CSS'
:root {
  --bg: #1a1a2e;
  --surface: #16213e;
  --surface2: #0f3460;
  --text: #e0e0e0;
  --accent: #e94560;
  --link: #64b5f6;
  --code-bg: #2a2a3e;
  --code: #f8f8f2;
}
* { margin: 0; padding: 0; box-sizing: border-box; }
body {
  font-family: 'Segoe UI', system-ui, -apple-system, sans-serif;
  background: var(--bg);
  color: var(--text);
  line-height: 1.7;
  max-width: 960px;
  margin: 0 auto;
  padding: 20px;
}
h1, h2, h3, h4 { color: #fff; margin: 1.5em 0 0.5em; }
h1 { border-bottom: 2px solid var(--accent); padding-bottom: 0.3em; }
a { color: var(--link); text-decoration: none; }
a:hover { text-decoration: underline; }
pre, code {
  font-family: 'Consolas', 'Courier New', monospace;
  font-size: 0.9em;
}
pre {
  background: var(--code-bg);
  color: var(--code);
  padding: 12px 16px;
  border-radius: 6px;
  overflow-x: auto;
  margin: 1em 0;
}
code { background: var(--code-bg); padding: 2px 6px; border-radius: 3px; }
pre code { background: none; padding: 0; }
p { margin: 0.7em 0; }
ul, ol { margin: 0.5em 0 0.5em 1.5em; }
blockquote {
  border-left: 4px solid var(--accent);
  padding-left: 1em;
  margin: 1em 0;
  color: #aaa;
}
table { border-collapse: collapse; width: 100%; margin: 1em 0; }
th, td { border: 1px solid #444; padding: 6px 10px; text-align: left; }
th { background: var(--surface2); color: #fff; }
tr:nth-child(even) { background: rgba(255,255,255,0.03); }
nav { margin: 1em 0; padding: 1em 0; border-bottom: 1px solid #333; }
nav a { margin-right: 1em; font-size: 0.9em; }
img { max-width: 100%; }
.header { text-align: center; padding: 2em 0; }
.header h1 { border: none; }
.header p { color: #888; font-size: 1.1em; }
.footer { text-align: center; padding: 2em 0; color: #555; font-size: 0.85em; }
.graph-container {
  width: 100%;
  max-width: 960px;
  height: 640px;
  border: 1px solid #333;
  border-radius: 8px;
  overflow: hidden;
  margin: 1em 0;
}
.graph-container svg { width: 100%; height: 100%; }
.chapter-list { list-style: none; margin: 0; padding: 0; }
.chapter-list li {
  padding: 0.8em 1em;
  margin: 0.3em 0;
  background: var(--surface);
  border-radius: 6px;
  border-left: 4px solid var(--accent);
}
.chapter-list li a { font-size: 1.05em; display: block; }
.chapter-list li small { color: #888; }
.tag {
  display: inline-block;
  font-size: 0.75em;
  padding: 2px 8px;
  border-radius: 10px;
  background: var(--surface2);
  color: #aaa;
  margin: 0 3px;
}
CSS

# ── 2. Index page ─────────────────────────────────────
generate_index() {
  local md_files=()
  for f in "$MD_DIR"/[0-9]*.md; do
    base=$(basename "$f" .md)
    num="${base%%-*}"
    title=$(head -1 "$f" | sed 's/^# *//')
    md_files+=("$num|$base|$title")
  done
  IFS=$'\n' md_files=($(sort -t'|' -k1 -n <<< "${md_files[*]}"))

  local en_files=()
  for f in "$EN_DIR"/[0-9]*.md; do
    base=$(basename "$f" .md)
    num="${base%%-*}"
    title=$(head -1 "$f" | sed 's/^# *//')
    en_files+=("$num|$base|$title")
  done
  IFS=$'\n' en_files=($(sort -t'|' -k1 -n <<< "${en_files[*]}"))

  local sol_files=()
  for f in "$SOL_DIR"/cap*.asm; do
    base=$(basename "$f" .asm)
    sol_files+=("$base")
  done

  cat > "$SITE_DIR/index.html" << HTML
<!DOCTYPE html>
<html lang="it">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>C64 Game Tutorial — Manuale di Programmazione Arcade</title>
<link rel="stylesheet" href="assets/style.css">
</head>
<body>

<div class="header">
<h1>C64 Game Tutorial</h1>
<p>Manuale di Programmazione Arcade su Commodore 64</p>
<p style="font-size:0.85em;color:#666">
Assembly 6502 · Turbo Macro Pro · VIC-II · SID · CIA · KERNAL
</p>
</div>

<nav>
<a href="#capitoli">Capitoli</a>
<a href="#traduzioni">Traduzioni</a>
<a href="#wiki-graph">Wiki Graph</a>
<a href="#soluzioni">Soluzioni</a>
<a href="#appendici">Appendici</a>
</nav>

<h2 id="capitoli">Capitoli</h2>
<ul class="chapter-list">
HTML

  for entry in "${md_files[@]}"; do
    IFS='|' read -r num base title <<< "$entry"
    cat >> "$SITE_DIR/index.html" << HTML
  <li><a href="md/${base}.html">${title}</a> <small>cap. ${num}</small></li>
HTML
  done

  cat >> "$SITE_DIR/index.html" << HTML
</ul>

<h2 id="traduzioni">Traduzioni Inglesi</h2>
<ul class="chapter-list">
HTML

  for entry in "${en_files[@]}"; do
    IFS='|' read -r num base title <<< "$entry"
    cat >> "$SITE_DIR/index.html" << HTML
  <li><a href="en/${base}.html">${title}</a> <small>ch. ${num}</small></li>
HTML
  done

  cat >> "$SITE_DIR/index.html" << HTML
</ul>

<h2 id="wiki-graph">Wiki Graph — Mappa Concettuale</h2>
<p>Mappa interattiva dei capitoli e dei concetti. Trascina per muovere,
rotella per zoomare, clicca un nodo per i dettagli.</p>
<div class="graph-container">
  <object data="wiki-graph.svg" type="image/svg+xml" width="100%" height="100%">
    Il browser non supporta SVG.
  </object>
</div>

<h2 id="soluzioni">Soluzioni Assembly</h2>
<ul>
HTML

  for sol in "${sol_files[@]}"; do
    cat >> "$SITE_DIR/index.html" << HTML
  <li><a href="soluzioni/${sol}.html">${sol}</a></li>
HTML
  done

  cat >> "$SITE_DIR/index.html" << HTML
</ul>

<h2 id="appendici">Appendici</h2>
<ul>
HTML

  for f in "$MD_DIR"/appendice-*.md "$MD_DIR"/INDICE.md; do
    base=$(basename "$f" .md)
    title=$(head -1 "$f" 2>/dev/null | sed 's/^# *//' || echo "$base")
    cat >> "$SITE_DIR/index.html" << HTML
  <li><a href="md/${base}.html">${title}</a></li>
HTML
  done

  cat >> "$SITE_DIR/index.html" << HTML
</ul>

<div class="footer">
<p>C64 Game Tutorial — <a href="https://github.com/anomalyco/C64GameTutorial">GitHub</a></p>
<p>Licenza CC BY 4.0</p>
</div>

</body>
</html>
HTML
  echo "  index.html"
}

# ── 3. Convert markdown to HTML ────────────────────────
convert_md_to_html() {
  local src_dir="$1"
  local dst_dir="$SITE_DIR/$1"
  mkdir -p "$dst_dir"

  for f in "$src_dir"/*.md; do
    base=$(basename "$f" .md)
    html_file="$dst_dir/${base}.html"
    title=$(head -1 "$f" | sed 's/^# *//')

    # Build nav links to other chapters in same directory
    local nav_links="<a href=\"../index.html\">Home</a>"
    for other in "$src_dir"/[0-9]*.md; do
      if [ "$other" = "$f" ]; then continue; fi
      obase=$(basename "$other" .md)
      otitle=$(head -1 "$other" | sed 's/^# *//')
      nav_links="$nav_links <a href=\"${obase}.html\">${otitle%% -*}</a>"
    done

    # Use pandoc if available
    if command -v pandoc >/dev/null 2>&1; then
      pandoc "$f" \
        --from markdown+hard_line_breaks \
        --to html5 \
        --standalone \
        --metadata title="$title" \
        --metadata lang="it" \
        --variable="css:../assets/style.css" \
        --include-before-body="<nav>${nav_links}</nav>" \
        -o "$html_file" 2>/dev/null || {
          echo "    WARN: pandoc fallito per $f, fallback grezzo"
          fallback_html "$f" "$html_file" "$title" "../assets/style.css" "$nav_links"
        }
    else
      fallback_html "$f" "$html_file" "$title" "../assets/style.css" "$nav_links"
    fi
    echo "  $html_file"
  done
}

# Fallback: manual HTML when pandoc is not available
fallback_html() {
  local in="$1" out="$2" title="$3" css="$4" nav="$5"
  local body
  body=$(python3 -c "
import sys, markdown
with open('$in') as f:
    html = markdown.markdown(f.read(), extensions=['fenced_code', 'tables', 'codehilite'])
    print(html)
" 2>/dev/null) || body=$(sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g' "$in" | sed 's/$/<br>/')

  cat > "$out" << HTML
<!DOCTYPE html>
<html lang="it">
<head>
<meta charset="UTF-8">
<title>${title}</title>
<link rel="stylesheet" href="${css}">
</head>
<body>
${nav}
<h1>${title}</h1>
${body}
</body>
</html>
HTML
}

# ── 4. Convert solution .asm to HTML ──────────────────
convert_sol_to_html() {
  for f in "$SOL_DIR"/cap*.asm; do
    base=$(basename "$f" .asm)
    html_file="$SITE_DIR/soluzioni/${base}.html"

    python3 -c "
import html
with open('$f') as src:
    code = src.read()
with open('$html_file', 'w') as dst:
    dst.write('''<!DOCTYPE html>
<html lang=\"it\">
<head>
<meta charset=\"UTF-8\">
<title>${base}</title>
<link rel=\"stylesheet\" href=\"../assets/style.css\">
</head>
<body>
<nav><a href=\"../index.html\">Home</a> <a href=\"#\">Soluzioni</a></nav>
<h1>${base}</h1>
<pre><code>''')
    dst.write(html.escape(code))
    dst.write('</code></pre></body></html>')
    "
    echo "  $html_file"
  done
}

# ── 5. Generate wiki graph SVG ─────────────────────────
generate_wiki_graph() {
  if [ -f "data/wiki-graph.json" ]; then
    python3 tools/wiki-graph.py data/wiki-graph.json "$SITE_DIR/wiki-graph.svg"
  else
    echo "  WARN: data/wiki-graph.json non trovato, salto wiki graph"
  fi
}

# ── Main ───────────────────────────────────────────────
echo "=== Generazione sito web statico ==="
echo ""
echo "1. Wiki Graph SVG..."
generate_wiki_graph

echo "2. Index page..."
generate_index

echo "3. Capitoli (md/ → HTML)..."
convert_md_to_html "md"

echo "4. Traduzioni (en/ → HTML)..."
convert_md_to_html "en"

echo "5. Soluzioni (.asm → HTML)..."
convert_sol_to_html

echo ""
echo "=== Completato ==="
echo "Sito generato in: $SITE_DIR/"
echo "Apri con: xdg-open $SITE_DIR/index.html"

if [ "${1:-}" = "--open" ]; then
  xdg-open "$SITE_DIR/index.html" 2>/dev/null || open "$SITE_DIR/index.html" 2>/dev/null || true
fi
