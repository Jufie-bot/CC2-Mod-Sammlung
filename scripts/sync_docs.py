#!/usr/bin/env python3
"""
sync_docs.py — CC2 Labor Dokumentations-Synchronisation
Version: 2.0
Aufgabe:
  1. Liest alle Analyse-Dateien aus analysis/ mit YAML-Frontmatter
  2. Generiert Statistiken (Anzahl Mods, Status-Verteilung)
  3. Aktualisiert README.md und wiki/Home.md Stats-Block
  4. Generiert wiki/Mod-Galerie/Statistiken.md

Verwendung: python scripts/sync_docs.py [--dry-run]
"""

import os
import sys
import yaml
import re
from pathlib import Path
from datetime import datetime

# Windows: UTF-8 erzwingen
if sys.stdout.encoding and sys.stdout.encoding.lower() != 'utf-8':
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')

# Pfade
ROOT = Path(__file__).parent.parent
ANALYSIS_DIR = ROOT / "analysis"
WIKI_DIR = ROOT / "wiki"
README = ROOT / "README.md"
HOME_MD = WIKI_DIR / "Home.md"
STATS_MD = WIKI_DIR / "Mod-Galerie" / "Statistiken.md"

DRY_RUN = "--dry-run" in sys.argv


def parse_frontmatter(filepath: Path) -> dict:
    """Liest YAML-Frontmatter aus einer Markdown-Datei."""
    try:
        content = filepath.read_text(encoding="utf-8")
        if not content.startswith("---"):
            return {}
        end = content.find("---", 3)
        if end == -1:
            return {}
        return yaml.safe_load(content[3:end]) or {}
    except Exception as e:
        print(f"  Warnung: {filepath.name} — {e}")
        return {}


def collect_analyses() -> list[dict]:
    """Sammelt alle Analyse-Dateien mit YAML-Frontmatter."""
    results = []
    for md_file in ANALYSIS_DIR.rglob("*.md"):
        if md_file.name.startswith("."):
            continue
        fm = parse_frontmatter(md_file)
        if not fm:
            continue
        fm["_path"] = str(md_file.relative_to(ROOT))
        fm["_file"] = md_file.name
        results.append(fm)
    return results


def build_stats(analyses: list[dict]) -> dict:
    """Berechnet Statistiken aus den Analysen."""
    status_counts = {}
    category_counts = {}
    total = len(analyses)

    for a in analyses:
        status = a.get("status", "unbekannt")
        category = a.get("category", "unbekannt")
        status_counts[status] = status_counts.get(status, 0) + 1
        category_counts[category] = category_counts.get(category, 0) + 1

    wiki_ready = status_counts.get("wiki-ready", 0) + status_counts.get("complete", 0)
    in_progress = status_counts.get("in-progress", 0)

    return {
        "total": total,
        "wiki_ready": wiki_ready,
        "in_progress": in_progress,
        "by_status": status_counts,
        "by_category": category_counts,
        "updated": datetime.now().strftime("%Y-%m-%d"),
    }


def render_stats_block(stats: dict) -> str:
    """Erstellt den Stats-Markdown-Block für README/Home."""
    lines = [
        f"| 📦 Mods analysiert | **{stats['total']}** |",
        f"| ✅ Wiki-ready | **{stats['wiki_ready']}** |",
        f"| 🔄 In Bearbeitung | **{stats['in_progress']}** |",
        f"| 📅 Zuletzt aktualisiert | **{stats['updated']}** |",
    ]
    return "\n".join(lines)


def update_block(filepath: Path, begin_tag: str, end_tag: str, new_content: str) -> bool:
    """Ersetzt Inhalt zwischen BEGIN und END Tags."""
    if not filepath.exists():
        print(f"  Übersprungen (nicht gefunden): {filepath}")
        return False

    text = filepath.read_text(encoding="utf-8")
    pattern = rf"({re.escape(begin_tag)}\n)(.*?)(\n{re.escape(end_tag)})"

    if not re.search(pattern, text, re.DOTALL):
        print(f"  Warnung: Tag '{begin_tag}' nicht in {filepath.name} gefunden")
        return False

    updated = re.sub(
        pattern,
        lambda m: f"{m.group(1)}{new_content}{m.group(3)}",
        text,
        flags=re.DOTALL,
    )

    if not DRY_RUN:
        filepath.write_text(updated, encoding="utf-8")
        print(f"  Aktualisiert: {filepath.name}")
    else:
        print(f"  [DRY-RUN] Würde aktualisieren: {filepath.name}")
    return True


def generate_statistiken_md(analyses: list[dict], stats: dict) -> str:
    """Generiert die vollständige Statistiken-Seite für die Mod-Galerie."""
    lines = [
        "---",
        "title: Mod-Galerie Statistiken",
        f"generated: {stats['updated']}",
        "---",
        "",
        "# Mod-Galerie — Statistiken",
        f"*Automatisch generiert am {stats['updated']} durch sync_docs.py*",
        "",
        "## Übersicht",
        "",
        "| Kategorie | Anzahl |",
        "|:---|:---|",
    ]

    for cat, count in sorted(stats["by_category"].items()):
        lines.append(f"| {cat} | {count} |")

    lines += [
        "",
        "## Status-Verteilung",
        "",
        "| Status | Anzahl |",
        "|:---|:---|",
    ]
    for status, count in sorted(stats["by_status"].items()):
        lines.append(f"| {status} | {count} |")

    lines += [
        "",
        "## Alle Analysen",
        "",
        "| Mod | Kategorie | Status | Level |",
        "|:---|:---|:---|:---|",
    ]
    for a in sorted(analyses, key=lambda x: x.get("category", "") + x.get("title", "")):
        title = a.get("title", a.get("_file", "?"))
        cat = a.get("category", "–")
        status = a.get("status", "–")
        level = a.get("level", "–")
        lines.append(f"| {title} | {cat} | {status} | {level} |")

    return "\n".join(lines)


def main():
    print("[SYNC] sync_docs.py starten...")
    print(f"  Modus: {'DRY-RUN' if DRY_RUN else 'LIVE'}")
    print(f"  Root: {ROOT}")

    analyses = collect_analyses()
    print(f"\n[INFO] {len(analyses)} Analysen gefunden")

    if not analyses:
        print("  Keine Analysen mit YAML-Frontmatter gefunden. Abbruch.")
        return

    stats = build_stats(analyses)
    stats_block = render_stats_block(stats)

    print("\n[STATS]")
    for k, v in stats.items():
        if k not in ("by_status", "by_category"):
            print(f"  {k}: {v}")

    print("\n[UPDATE] README.md und Home.md aktualisieren...")
    update_block(README, "<!-- BEGIN:stats -->", "<!-- END:stats -->", stats_block)
    update_block(HOME_MD, "<!-- BEGIN:stats -->", "<!-- END:stats -->", stats_block)

    print("\n[GEN] Statistiken.md generieren...")
    stats_content = generate_statistiken_md(analyses, stats)
    if not DRY_RUN:
        STATS_MD.parent.mkdir(parents=True, exist_ok=True)
        STATS_MD.write_text(stats_content, encoding="utf-8")
        print(f"  Erstellt: {STATS_MD.relative_to(ROOT)}")
    else:
        print(f"  [DRY-RUN] Wuerde erstellen: {STATS_MD.relative_to(ROOT)}")

    print("\n[OK] sync_docs.py abgeschlossen.")


if __name__ == "__main__":
    main()
