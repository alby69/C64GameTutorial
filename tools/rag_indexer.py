#!/usr/bin/env python3
"""
rag_indexer.py — LLM RAG Metadata Indexer for C64GameTutorial
Parses all Markdown chapters and assembly sources, extracts code blocks,
and generates JSON index files for C64-Intelligence-SDK integration.
"""

import os
import re
import glob
import json

def extract_chapter_metadata(md_path):
    with open(md_path, "r", encoding="utf-8") as f:
        content = f.read()

    title_match = re.search(r'^#\s+(.*)', content, re.MULTILINE)
    title = title_match.group(1) if title_match else os.path.basename(md_path)

    code_blocks = re.findall(r'```(?:kickass|asm)?\n(.*?)```', content, re.DOTALL)

    return {
        "file": md_path,
        "title": title,
        "code_blocks_count": len(code_blocks),
        "char_count": len(content)
    }

def build_rag_index():
    md_files = sorted(glob.glob("docs/it/*.md") + glob.glob("docs/en/*.md"))
    asm_files = sorted(glob.glob("soluzioni/kickass/*.asm") + glob.glob("game/*.asm"))

    index_data = {
        "project": "C64GameTutorial",
        "total_documents": len(md_files),
        "total_assembly_files": len(asm_files),
        "chapters": [extract_chapter_metadata(f) for f in md_files],
        "assembly_sources": [f for f in asm_files]
    }

    out_path = "tools/rag_index.json"
    with open(out_path, "w", encoding="utf-8") as f:
        json.dump(index_data, f, indent=2)

    print(f"Generated RAG index: {out_path} ({len(md_files)} docs, {len(asm_files)} asm sources)")

if __name__ == "__main__":
    build_rag_index()
