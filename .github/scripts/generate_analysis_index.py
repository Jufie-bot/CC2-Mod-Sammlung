# -*- coding: utf-8 -*-
"""
generate_analysis_index.py
===========================
Phase F: Generiert automatisch eine analysis/_index.md mit einer
          vollstaendigen Uebersicht aller vorhandenen Analysen,
          deren Status und Verlinkungen zu den Wiki-Seiten.

Ausgabe:
  analysis/_index.md   (vollstaendige Uebersicht)
"""

import os
import re
from pathlib import Path
from datetime import date
from collections import defaultdict

try:
    import yaml
except ImportError:
    import subprocess
    subprocess.run(["pip", "install", "pyyaml", "--quiet"], check=True)
    import yaml


ANALYSIS_DIR = Path("analysis")

STATUS_SORT_ORDER = {
    "offen":      0,
    "analysiert": 1,
    "wiki-ready": 2,
    "fertig":     3,
}

STATUS_BADGE = {
    "offen":      "🔴 Offen",
    "analysiert": "🟡 In Analyse",
    "wiki-ready": "🟢 Wiki-Ready",
    "fertig":     "✅ Fertig",
}

PRIORITY_BADGE = {
    "hoch":    "🔴 Hoch",
    "normal":  "🟡 Normal",
    "niedrig": "🟢 Niedrig",
}


def parse_frontmatter(md_path: Path) -> dict:
    """Liest YAML-Frontmatter aus einer analyse.md."""
    try:
        content = md_path.read_text(encoding="utf-8")
        match   = re.match(r"^---\s*\n(.*?)\n---", content, re.DOTALL)
        if match:
            return yaml.safe_load(match.group(1)) or {}
    except Exception as e:
        print(f"  [WARN] Parse-Fehler {md_path}: {e}")
    return {}


def collect_analyses() -> dict[str, list[dict]]:
    """Sammelt alle analyse.md Dateien und liest ihren Status aus."""
    results = defaultdict(list)

    for analyse_file in sorted(ANALYSIS_DIR.rglob("analyse.md")):
        parts = analyse_file.relative_to(ANALYSIS_DIR).parts
        if len(parts) < 3:
            continue

        category = parts[0]
        mod_name = parts[1]
        meta     = parse_frontmatter(analyse_file)

        results[category].append({
            "name":       meta.get("mod",      mod_name),
            "category":   meta.get("category", category),
            "status":     meta.get("status",   "offen"),
            "priority":   meta.get("priority", "normal"),
            "wiki_page":  meta.get("wiki_page", ""),
            "updated":    meta.get("last_updated", "–"),
            "path":       str(analyse_file).replace("\\", "/"),
        })

    return results


def generate_stat_block(all_analyses: dict[str, list[dict]]) -> str:
    """Erstellt einen Statistik-Block mit Gesamtzahlen."""
    total    = sum(len(v) for v in all_analyses.values())
    by_status: dict[str, int] = defaultdict(int)
    for mods in all_analyses.values():
        for mod in mods:
            by_status[mod["status"]] += 1

    rows = [
        f"| 🔴 Offen       | {by_status.get('offen', 0)} |",
        f"| 🟡 In Analyse  | {by_status.get('analysiert', 0)} |",
        f"| 🟢 Wiki-Ready  | {by_status.get('wiki-ready', 0)} |",
        f"| ✅ Fertig      | {by_status.get('fertig', 0)} |",
        f"| **Gesamt**     | **{total}** |",
    ]
    return "\n".join(rows)


def generate_category_section(category: str, mods: list[dict]) -> str:
    """Erstellt den Tabellen-Abschnitt fuer eine Kategorie."""
    # Sortiere nach Status-Prioritaet, dann alphabetisch
    sorted_mods = sorted(mods, key=lambda m: (
        STATUS_SORT_ORDER.get(m["status"], 99),
        m["name"].lower()
    ))

    rows = []
    for mod in sorted_mods:
        status    = STATUS_BADGE.get(mod["status"], mod["status"])
        priority  = PRIORITY_BADGE.get(mod["priority"], mod["priority"])
        wiki_link = f"[Link](wiki/Mod-Galerie/{category}/{mod['name']}.md)" if mod.get("wiki_page") else "–"
        rows.append(
            f"| `{mod['name']}` | {status} | {priority} | {mod['updated']} | {wiki_link} |"
        )

    rows_md = "\n".join(rows)
    count   = len(mods)

    return f"""\

### {category} ({count})

| Mod | Status | Prioritaet | Aktualisiert | Wiki |
|---|---|---|---|---|
{rows_md}
"""


def run():
    """Hauptfunktion: Generiert analysis/_index.md."""
    if not ANALYSIS_DIR.exists():
        print(f"[FEHLER] analysis/ Verzeichnis nicht gefunden.")
        return

    all_analyses = collect_analyses()
    today        = date.today().isoformat()
    stat_block   = generate_stat_block(all_analyses)

    # Abschnitte fuer jede Kategorie
    category_sections = ""
    for category in sorted(all_analyses.keys()):
        mods = all_analyses[category]
        if mods:
            category_sections += generate_category_section(category, mods)

    total = sum(len(v) for v in all_analyses.values())

    content = f"""\
---
title: "Analyse-Index"
auto_generated: true
last_updated: {today}
total_analyses: {total}
---

# Analyse-Index

> Vollstaendige Uebersicht aller Mod-Analysen im Labor.
> Diese Datei wird automatisch generiert – bitte nicht manuell bearbeiten.

## Statistik

| Status | Anzahl |
|---|---|
{stat_block}

## Analysen nach Kategorie
{category_sections}

---

*Automatisch generiert am {today}. Quelle: `analysis/**/analyse.md` YAML-Frontmatter*
"""

    index_file = ANALYSIS_DIR / "_index.md"
    index_file.write_text(content, encoding="utf-8")
    print(f"[OK] analysis/_index.md generiert ({total} Analysen)")


if __name__ == "__main__":
    run()
