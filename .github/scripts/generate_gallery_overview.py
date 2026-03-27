# -*- coding: utf-8 -*-
"""
generate_gallery_overview.py
=============================
Phase E: Generiert automatisch Uebersichtsseiten fuer jede Kategorie
          in wiki/Mod-Galerie/, basierend auf den vorhandenen .md Seiten.

Ausgabe:
  wiki/Mod-Galerie/Audio.md       (Uebersicht aller Audio-Mods)
  wiki/Mod-Galerie/Gameplay.md    (Uebersicht aller Gameplay-Mods)
  ...usw.

Wird eingebunden in generate_sidebar.py oder direkt aufgerufen.
"""

import os
import re
from pathlib import Path
from datetime import date

try:
    import yaml
except ImportError:
    import subprocess
    subprocess.run(["pip", "install", "pyyaml", "--quiet"], check=True)
    import yaml


GALLERY_DIR = Path("wiki") / "Mod-Galerie"

CATEGORY_ICONS = {
    "Audio":                    "🔊",
    "Gameplay":                 "🎮",
    "Kategorienuebergreifende": "🔧",
    "UI":                       "🖥️",
    "Vehicles":                 "🚢",
    "Weapons":                  "⚔️",
}

CATEGORY_DESCRIPTIONS = {
    "Audio":                    "Mods, die Soundeffekte, Musik oder Audioverhalten veraendern.",
    "Gameplay":                 "Mods, die Spielmechaniken, Balancing oder KI-Verhalten modifizieren.",
    "Kategorienuebergreifende": "Mods, die mehrere Bereiche (Gameplay, Audio, UI) gleichzeitig beeinflussen.",
    "UI":                       "Mods, die das HUD, Menues oder visuelle Benutzeroberflaeche anpassen.",
    "Vehicles":                 "Mods fuer Fahrzeuge, Schiffe und Drohnen.",
    "Weapons":                  "Mods, die Waffen, Projektile oder Waffenbalancing aendern.",
}


def parse_mod_meta(md_path: Path) -> dict:
    """Liest YAML-Frontmatter aus einer Wiki-Mod-Datei."""
    try:
        content = md_path.read_text(encoding="utf-8")
        match = re.match(r"^---\s*\n(.*?)\n---", content, re.DOTALL)
        if match:
            return yaml.safe_load(match.group(1)) or {}
    except Exception:
        pass
    return {}


def generate_category_overview(category: str, category_path: Path) -> str:
    """Generiert den Inhalt einer Kategorie-Uebersichtsseite."""
    icon        = CATEGORY_ICONS.get(category, "📦")
    description = CATEGORY_DESCRIPTIONS.get(category, f"Mods in der Kategorie {category}.")
    today       = date.today().isoformat()

    # Alle Mod-Seiten in dieser Kategorie einlesen
    mod_files = sorted([f for f in category_path.glob("*.md")
                        if f.name != f"{category}.md"])

    # Tabellen-Eintraege
    table_rows = []
    for mod_file in mod_files:
        mod_name = mod_file.stem
        meta     = parse_mod_meta(mod_file)
        status   = meta.get("status", "offen")
        priority = meta.get("priority", "normal")

        status_badge = {
            "offen":      "🔴 Offen",
            "analysiert": "🟡 In Analyse",
            "wiki-ready": "🟢 Wiki-Ready",
            "fertig":     "✅ Fertig",
        }.get(status, status)

        priority_badge = {
            "hoch":  "🔴 Hoch",
            "normal": "🟡 Normal",
            "niedrig": "🟢 Niedrig",
        }.get(priority, priority)

        table_rows.append(
            f"| [[{mod_name}]] | {status_badge} | {priority_badge} |"
        )

    count    = len(mod_files)
    table_md = "\n".join(table_rows) if table_rows else "| _(noch keine Seiten)_ | – | – |"

    return f"""\
---
title: "Mod-Galerie: {category}"
section: Mod-Galerie
category: {category}
auto_generated: true
last_updated: {today}
---

# {icon} Mod-Galerie: {category}

> {description}

**Seiten in dieser Kategorie:** {count}

## Uebersicht

| Mod | Status | Prioritaet |
|---|---|---|
{table_md}

---

*Diese Seite wird automatisch generiert. Letzte Aktualisierung: {today}*
"""


def generate_gallery_main(categories: list[str], counts: dict[str, int]) -> str:
    """Generiert die Haupt-Uebersichtsseite der Mod-Galerie."""
    today = date.today().isoformat()
    total = sum(counts.values())

    rows = []
    for cat in sorted(categories):
        icon  = CATEGORY_ICONS.get(cat, "📦")
        count = counts.get(cat, 0)
        rows.append(f"| {icon} [[{cat}]] | {count} |")

    rows_md = "\n".join(rows)

    return f"""\
---
title: "Mod-Galerie"
section: Mod-Galerie
auto_generated: true
last_updated: {today}
---

# Mod-Galerie

> Alle analysierten externen Mods, kategorisiert und dokumentiert.

**Gesamt analysierte Mods:** {total}

## Kategorien

| Kategorie | Anzahl Seiten |
|---|---|
{rows_md}

---

*Diese Seite wird automatisch generiert. Letzte Aktualisierung: {today}*
"""


def run():
    """Hauptfunktion: Generiert alle Uebersichtsseiten."""
    if not GALLERY_DIR.exists():
        print(f"[FEHLER] Mod-Galerie-Ordner nicht gefunden: {GALLERY_DIR}")
        return

    categories = [d.name for d in sorted(GALLERY_DIR.iterdir()) if d.is_dir()]
    counts     = {}

    for category in categories:
        cat_path   = GALLERY_DIR / category
        mod_files  = [f for f in cat_path.glob("*.md") if f.name != f"{category}.md"]
        counts[category] = len(mod_files)

        if mod_files:  # Nur Uebersicht erstellen wenn Mods vorhanden
            content   = generate_category_overview(category, cat_path)
            out_file  = GALLERY_DIR / f"{category}.md"
            out_file.write_text(content, encoding="utf-8")
            print(f"  [OK] {out_file} ({len(mod_files)} Mods)")
        else:
            print(f"  [SKIP] {category}: noch keine Mods")

    # Haupt-Galerie-Seite
    main_content = generate_gallery_main(categories, counts)
    main_file    = GALLERY_DIR / "Mod-Galerie.md"
    main_file.write_text(main_content, encoding="utf-8")
    print(f"  [OK] Haupt-Galerie: {main_file} ({sum(counts.values())} Mods gesamt)")


if __name__ == "__main__":
    run()
