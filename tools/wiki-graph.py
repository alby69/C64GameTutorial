#!/usr/bin/env python3
"""
wiki-graph.py — Genera mappa concettuale interattiva SVG (wiki graph)
per il C64 Game Tutorial, ispirato al wiki grafo di C64-LLM.

Uso:
  python tools/wiki-graph.py data/wiki-graph.json site/wiki-graph.svg

Formato JSON nodi:
  { "id": "...", "label": "...", "category": "...", "description": "..." }

Formato JSON archi:
  { "from": "...", "to": "...", "label": "..." }

Categorie con colore:
  capitolo (blu), chip (rosso), software (verde), concetto (viola)
"""

import json, sys, os, math

CATEGORY_COLORS = {
    "capitolo": "#3498db",
    "chip":     "#e74c3c",
    "software": "#27ae60",
    "concetto": "#8e44ad",
}

def load_graph(path):
    with open(path) as f:
        return json.load(f)

def kamada_kawai(nodes, edges, width, height, iterations=200):
    """Simple force-directed layout (spring model)."""
    n = len(nodes)
    ids = [node["id"] for node in nodes]
    idx = {id_: i for i, id_ in enumerate(ids)}
    pos = {}

    # Initialize circle layout
    cx, cy = width / 2, height / 2
    for i, node in enumerate(nodes):
        angle = 2 * math.pi * i / n
        r = min(width, height) * 0.35
        pos[node["id"]] = [cx + r * math.cos(angle), cy + r * math.sin(angle)]

    # Edge adjacency
    adj = {id_: [] for id_ in ids}
    for edge in edges:
        f = edge["from"]
        t = edge["to"]
        if f in idx and t in idx:
            adj[f].append(t)
            adj[t].append(f)

    # Simple spring relaxation
    for _ in range(iterations):
        forces = {id_: [0, 0] for id_ in ids}
        # Repulsion between all pairs
        for i in range(n):
            for j in range(i + 1, n):
                a, b = ids[i], ids[j]
                dx = pos[a][0] - pos[b][0]
                dy = pos[a][1] - pos[b][1]
                d = math.sqrt(dx * dx + dy * dy) + 1
                f = 5000 / (d * d)
                fx = f * dx / d
                fy = f * dy / d
                forces[a][0] += fx
                forces[a][1] += fy
                forces[b][0] -= fx
                forces[b][1] -= fy
        # Attraction along edges
        for edge in edges:
            a, b = edge["from"], edge["to"]
            if a not in idx or b not in idx:
                continue
            dx = pos[b][0] - pos[a][0]
            dy = pos[b][1] - pos[a][1]
            d = math.sqrt(dx * dx + dy * dy) + 1
            f = d / 50
            fx = f * dx / d
            fy = f * dy / d
            forces[a][0] += fx
            forces[a][1] += fy
            forces[b][0] -= fx
            forces[b][1] -= fy
        # Apply with damping
        for id_ in ids:
            pos[id_][0] += forces[id_][0] * 0.1
            pos[id_][1] += forces[id_][1] * 0.1

    # Normalize to viewport
    xs = [pos[id_][0] for id_ in ids]
    ys = [pos[id_][1] for id_ in ids]
    min_x, max_x = min(xs), max(xs)
    min_y, max_y = min(ys), max(ys)
    range_x = max(max_x - min_x, 1)
    range_y = max(max_y - min_y, 1)
    pad = 60
    for id_ in ids:
        pos[id_][0] = pad + (pos[id_][0] - min_x) / range_x * (width - 2 * pad)
        pos[id_][1] = pad + (pos[id_][1] - min_y) / range_y * (height - 2 * pad)

    return pos

FONT = "Consolas, 'Courier New', monospace"

def generate_svg(graph, pos, width, height):
    nodes = graph["nodes"]
    edges = graph["edges"]
    ids = {n["id"] for n in nodes}

    # Filter edges to only those between known nodes
    valid_edges = [e for e in edges if e["from"] in ids and e["to"] in ids]

    # Build node map
    node_map = {n["id"]: n for n in nodes}

    ns = 'xmlns="http://www.w3.org/2000/svg"'

    lines = [
        f'<svg {ns} viewBox="0 0 {width} {height}" width="100%" height="100%">',
        '<defs>',
        '  <marker id="arrowhead" markerWidth="10" markerHeight="7" refX="10" refY="3.5" orient="auto">',
        '    <polygon points="0 0, 10 3.5, 0 7" fill="#999" />',
        '  </marker>',
        '</defs>',
        '<rect width="100%" height="100%" fill="#1a1a2e" />',
        '<g id="wiki-viewport" style="cursor:grab">',
    ]

    # Render edges
    for e in valid_edges:
        f, t = e["from"], e["to"]
        x1, y1 = pos[f]
        x2, y2 = pos[t]
        # Shorten line near node (stop at node radius)
        dx, dy = x2 - x1, y2 - y1
        d = math.sqrt(dx*dx + dy*dy) + 0.001
        r = 20
        x1s = x1 + dx * r / d
        y1s = y1 + dy * r / d
        x2s = x2 - dx * r / d
        y2s = y2 - dy * r / d
        lines.append(
            f'  <line x1="{x1s:.1f}" y1="{y1s:.1f}" '
            f'x2="{x2s:.1f}" y2="{y2s:.1f}" '
            'stroke="#555" stroke-width="1.5" marker-end="url(#arrowhead)" '
            'class="wiki-edge" />'
        )
        # Label on edge midpoint
        mx, my = (x1 + x2) / 2, (y1 + y2) / 2 - 8
        lines.append(
            f'  <text x="{mx:.1f}" y="{my:.1f}" '
            f'fill="#777" font-size="8" font-family="{FONT}" '
            'text-anchor="middle" class="wiki-edge-label">'
            f'{e["label"]}</text>'
        )

    # Render nodes
    for n in nodes:
        x, y = pos[n["id"]]
        color = CATEGORY_COLORS.get(n["category"], "#3498db")
        r = 22 if n["category"] == "capitolo" else 18

        # Node circle
        lines.append(
            f'  <circle cx="{x:.1f}" cy="{y:.1f}" r="{r}" '
            f'fill="{color}" fill-opacity="0.85" stroke="#fff" stroke-width="2" '
            f'class="wiki-node" data-id="{n["id"]}" '
            f'onclick="window.showNode(\'{n["id"]}\')" '
            'style="cursor:pointer" />'
        )
        # Label
        label = n["label"]
        short_label = label if len(label) <= 14 else label[:12] + ".."
        lines.append(
            f'  <text x="{x:.1f}" y="{y + 3:.1f}" '
            f'fill="#fff" font-size="7" font-family="{FONT}" '
            f'text-anchor="middle" class="wiki-label" '
            f'style="pointer-events:none">{short_label}</text>'
        )

    # Legend
    ly = height - 20
    for i, (cat, col) in enumerate(CATEGORY_COLORS.items()):
        lx = 20 + i * 130
        lines.append(f'  <circle cx="{lx}" cy="{ly - 3}" r="5" fill="{col}" />')
        lines.append(
            f'  <text x="{lx + 10}" y="{ly}" fill="#bbb" font-size="9" '
            f'font-family="{FONT}">{cat}</text>'
        )

    lines.append('</g>')

    # Info panel (hidden by default, shown via JS)
    lines.extend([
        '<g id="info-panel" transform="translate(10, 10)" visibility="hidden">',
        '  <rect width="0" height="0" fill="#222" rx="6" stroke="#555" stroke-width="1" />',
        '  <text id="info-title" x="12" y="24" fill="#fff" font-size="12" font-family="Consolas, monospace" font-weight="bold" />',
        '  <text id="info-desc" x="12" y="42" fill="#ccc" font-size="10" font-family="Consolas, monospace" />',
        '  <text id="info-links" x="12" y="60" fill="#8af" font-size="9" font-family="Consolas, monospace" />',
        '  <text x="12" y="78" fill="#666" font-size="8" font-family="Consolas, monospace" id="info-context" />',
        '</g>',
    ])

    # Reset view button
    lines.extend([
        '<g id="reset-btn" transform="translate(10, 10)" style="cursor:pointer" onclick="window.resetView()">',
        '  <rect width="16" height="16" fill="#444" rx="3" />',
        '  <text x="8" y="13" fill="#fff" font-size="12" text-anchor="middle" font-family="Consolas, monospace">↺</text>',
        '</g>',
    ])

    # Embed data as hidden text for JS access
    lines.append(
        f'<text id="wiki-nodes-data" visibility="hidden">{json.dumps(graph["nodes"])}</text>'
    )
    lines.append(
        f'<text id="wiki-edges-data" visibility="hidden">{json.dumps(valid_edges)}</text>'
    )

    # Embedded JS
    lines.append('<script type="text/javascript"><![CDATA[')
    lines.append(JS_CODE)
    lines.append(']]></script>')
    lines.append('</svg>')
    return '\n'.join(lines)

JS_CODE = """
(function() {
  var vp = document.getElementById('wiki-viewport');
  var scale = 1, tx = 0, ty = 0;
  var isPanning = false, startX, startY;
  var nodesData = {}, edgesData = [];

  try {
    var nodesEl = document.getElementById('wiki-nodes-data');
    var edgesEl = document.getElementById('wiki-edges-data');
    if (nodesEl) {
      JSON.parse(nodesEl.textContent).forEach(function(n) { nodesData[n.id] = n; });
    }
    if (edgesEl) {
      edgesData = JSON.parse(edgesEl.textContent);
    }
  } catch(e) { console.error('Graph data parse error', e); }

  function updateTransform() {
    vp.setAttribute('transform', 'translate(' + tx + ',' + ty + ') scale(' + scale + ')');
  }

  window.showNode = function(id) {
    var n = nodesData[id];
    if (!n) return;
    var panel = document.getElementById('info-panel');
    panel.setAttribute('visibility', 'visible');
    document.getElementById('info-title').textContent = n.label + ' (' + n.category + ')';
    document.getElementById('info-desc').textContent = (n.description || '').substring(0, 120) + (n.description && n.description.length > 120 ? '...' : '');
    var links = '';
    edgesData.forEach(function(e) {
      if (e.from === id) links += '  → ' + nodesData[e.to].label + ' [' + e.label + ']\\n';
      if (e.to === id) links += '  ← ' + nodesData[e.from].label + ' [' + e.label + ']\\n';
    });
    var ctx = document.getElementById('info-context');
    ctx.textContent = '';
    if (links) {
      document.getElementById('info-links').textContent = 'Connessioni:';
      var lines = links.split('\\n');
      var panelH = Math.max(90, 60 + lines.length * 14);
      panel.querySelector('rect').setAttribute('height', panelH);
      panel.querySelector('rect').setAttribute('width', Math.max(300, 200 + id.length * 6));
      for (var i = 0; i < lines.length; i++) {
        if (!lines[i]) continue;
        var t = document.createElementNS('http://www.w3.org/2000/svg', 'text');
        t.setAttribute('x', '12');
        t.setAttribute('y', (76 + i * 14));
        t.setAttribute('fill', '#8af');
        t.setAttribute('font-size', '9');
        t.setAttribute('font-family', 'Consolas, monospace');
        t.textContent = lines[i];
        panel.appendChild(t);
      }
    } else {
      document.getElementById('info-links').textContent = 'Nessuna connessione';
      panel.querySelector('rect').setAttribute('height', 80);
      panel.querySelector('rect').setAttribute('width', 250);
    }
  };

  window.resetView = function() {
    scale = 1; tx = 0; ty = 0;
    updateTransform();
    var panel = document.getElementById('info-panel');
    panel.setAttribute('visibility', 'hidden');
  };

  // Zoom on wheel
  vp.addEventListener('wheel', function(e) {
    e.preventDefault();
    var rect = vp.closest('svg').getBoundingClientRect();
    var mx = e.clientX - rect.left;
    var my = e.clientY - rect.top;
    var oldScale = scale;
    scale *= (e.deltaY < 0) ? 1.1 : 0.9;
    scale = Math.max(0.3, Math.min(3, scale));
    tx = mx - (mx - tx) * (scale / oldScale);
    ty = my - (my - ty) * (scale / oldScale);
    updateTransform();
  });

  // Pan on drag
  vp.addEventListener('mousedown', function(e) {
    if (e.target.classList.contains('wiki-node') || e.target.classList.contains('wiki-label')) return;
    isPanning = true;
    startX = e.clientX - tx;
    startY = e.clientY - ty;
    vp.style.cursor = 'grabbing';
  });

  window.addEventListener('mousemove', function(e) {
    if (!isPanning) return;
    tx = e.clientX - startX;
    ty = e.clientY - startY;
    updateTransform();
  });

  window.addEventListener('mouseup', function() {
    isPanning = false;
    if (vp) vp.style.cursor = 'grab';
  });

  // Show legend
  updateTransform();
})();
"""

def main():
    if len(sys.argv) != 3:
        print("Uso: python tools/wiki-graph.py <input.json> <output.svg>")
        sys.exit(1)

    in_path, out_path = sys.argv[1], sys.argv[2]
    if not os.path.exists(in_path):
        print(f"Errore: {in_path} non trovato")
        sys.exit(1)

    graph = load_graph(in_path)
    os.makedirs(os.path.dirname(out_path) or ".", exist_ok=True)

    w, h = 960, 640
    pos = kamada_kawai(graph["nodes"], graph["edges"], w, h)
    svg = generate_svg(graph, pos, w, h)

    with open(out_path, "w") as f:
        f.write(svg)
    print(f"Wiki graph salvato in {out_path}")
    print(f"  Nodi: {len(graph['nodes'])}")
    print(f"  Archi: {len([e for e in graph['edges'] if e['from'] in {n['id'] for n in graph['nodes']} and e['to'] in {n['id'] for n in graph['nodes']}])}")

if __name__ == "__main__":
    main()
