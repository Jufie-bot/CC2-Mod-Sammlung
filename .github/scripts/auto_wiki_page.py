# -*- coding: utf-8 -*-
"""
auto_wiki_page.py
==================
Generiert automatisch eine Wiki-Seite aus einer fertigen analyse.md Datei.
Wird aufgerufen wenn YAML-Status 'wiki-ready' erkannt wurde.

Eingabe:  analysis/<Kategorie>/<Mod>/analyse.md
Ausgabe:  wiki/Mod-Galerie/<Kategorie>/<Mod>.md
"""

import os
import re
import subprocess
from datetime import date
from typing import Optional

try:
    import yaml
except ImportError:
    subprocess.run(["pip", "install", "pyyaml", "--quiet"], check=True)
    import yaml


# ============================================================
# KATEGORIE → WIKI-ORDNER MAPPING
# Mod-Kategorie aus analysis/ → Wiki-Zielordner unter Mod-Galerie/
# ============================================================
WIKI_FOLDER_MAP = {
    "Audio":                    "Audio",
    "Gameplay":                 "Gameplay",
    "UI":                       "Kategorienuebergreifende",  # UI → Übergreifend
    "Vehicles":                 "Vehicles",
    "Weapons":                  "Gameplay",                  # Waffen → Gameplay
    "Kategorienübergreifende":  "Kategorienuebergreifende",
}


def parse_yaml_and_body(filepath: str) -> tuple[dict, str]:
    """
    Liest YAML-Frontmatter und den Markdown-Body einer Datei.
    Returns: (meta_dict, body_string)
    """
    with open(filepath, "r", encoding="utf-8") as f:
        content = f.read()

    match = re.match(r"^---\s*\n(.*?)\n---\s*\n(.*)", content, re.DOTALL)
    if match:
        meta = yaml.safe_load(match.group(1)) or {}
        body = match.group(2).strip()
    else:
        meta = {}
        body = content.strip()

    return meta, body


def extract_section(body: str, heading: str) -> str:
    """Extrahiert den Inhalt eines Abschnitts aus dem Markdown-Body."""
    pattern = rf"## {re.escape(heading)}\s*\n(.*?)(?=\n## |\Z)"
    match = re.search(pattern, body, re.DOTALL)
    if match:
        content = match.group(1).strip()
        # Placeholder-Zeilen entfernen
        lines = [l for l in content.splitlines() if not l.strip().startswith("> TODO")]
        return "\n".join(lines).strip()
    return ""


def generate_wiki_page(meta: dict, body: str, mod_name: str, mod_category: str) -> str:
    """
    Generiert den Inhalt einer Wiki-Seite aus den Analyse-Daten.
    """
    today        = date.today().isoformat()
    priority     = meta.get("priority", "normal")
    related_mods = meta.get("related_mods", [])
    wiki_page    = meta.get("wiki_page", "")

    erkenntnisse = extract_section(body, "Erkenntnisse")
    rohdaten     = extract_section(body, "Rohdaten / Sichtung")
    fragen       = extract_section(body, "Offene Fragen")
    notizen      = extract_section(body, "Notizen für eigene Mods")

    related_str = ""
    if related_mods:
        links = [f"[[{m}]]" for m in related_mods]
        related_str = f"\n**Verwandte Mods:** {', '.join(links)}\n"

    notizen_block = ""
    if notizen:
        notizen_block = f"\n## 💡 Relevanz für eigene Mods\n\n{notizen}\n"

    fragen_block = ""
    if fragen:
        fragen_block = f"\n## ❓ Offene Fragen\n\n{fragen}\n"

    return f"""\
---
title: "{mod_name}"
category: Mod-Galerie / {mod_category}
status: analysiert
priority: {priority}
source: "mods/{mod_category}/{mod_name}/"
analyse_file: "analysis/{mod_category}/{mod_name}/analyse.md"
last_updated: {today}
---

# {mod_name}

> Automatisch generierte Wiki-Seite auf Basis der Mod-Analyse.{related_str}

## [WIKI] Übersicht

| Eigenschaft | Wert |
|---|---|
| **Kategorie** | {mod_category} |
| **Analysedatum** | {today} |
| **Priorität** | {priority} |

## 🔍 Analyse-Ergebnisse

{erkenntnisse if erkenntnisse else "_Noch kein Inhalt – bitte aus analyse.md befüllen._"}

## 📁 Rohdaten / Sichtung

{rohdaten if rohdaten else "_Noch kein Inhalt._"}
{notizen_block}{fragen_block}
---

*Diese Seite wurde automatisch aus `analysis/{mod_category}/{mod_name}/analyse.md` generiert.*  
*Letzte Aktualisierung: {today}*
"""


def write_wiki_page(mod_name: str, mod_category: str, content: str) -> str:
    """
    Schreibt die Wiki-Seite in den wiki/Mod-Galerie/-Ordner.
    Returns: Pfad der erstellten/aktualisierten Datei
    """
    target_folder = WIKI_FOLDER_MAP.get(mod_category, mod_category)
    wiki_dir      = os.path.join("wiki", "Mod-Galerie", target_folder)
    wiki_file     = os.path.join(wiki_dir, f"{mod_name}.md")

    os.makedirs(wiki_dir, exist_ok=True)
    with open(wiki_file, "w", encoding="utf-8") as f:
        f.write(content)

    print(f"  [FILE] Wiki-Seite geschrieben: {wiki_file}")
    return wiki_file


def commit_wiki_page(wiki_file: str, mod_name: str) -> bool:
    """Fügt die neue Wiki-Seite dem Git-Index hinzu und committet sie."""
    result_add = subprocess.run(["git", "add", wiki_file], capture_output=True, text=True)
    if result_add.returncode != 0:
        print(f"  [FEHLER] git add: {result_add.stderr}")
        return False

    commit_msg = f"wiki(auto): Seite für '{mod_name}' aus Analyse generiert"
    result_commit = subprocess.run(
        ["git", "commit", "--allow-empty", "-m", commit_msg],
        capture_output=True, text=True
    )

    if "nothing to commit" in result_commit.stdout:
        print(f"  [INFO] Keine Änderung – Wiki-Seite ist bereits aktuell.")
        return True

    if result_commit.returncode != 0:
        print(f"  [FEHLER] git commit: {result_commit.stderr}")
        return False

    print(f"  [OK] Commit: {commit_msg}")
    return True


def generate_from_analysis(analysis_filepath: str) -> bool:
    """
    Hauptfunktion: Liest analyse.md und schreibt die Wiki-Seite.
    Returns True bei Erfolg.
    """
    if not os.path.exists(analysis_filepath):
        print(f"  [FEHLER] Datei nicht gefunden: {analysis_filepath}")
        return False

    # Pfad parsen: analysis/<Kategorie>/<Mod>/analyse.md
    parts = analysis_filepath.replace("\\", "/").split("/")
    if len(parts) < 4 or parts[-1] != "analyse.md":
        print(f"  [FEHLER] Unerwarteter Pfad: {analysis_filepath}")
        return False

    mod_category = parts[1]
    mod_name     = parts[2]

    print(f"\n  [WIKI] Generiere Wiki-Seite fuer: {mod_name} ({mod_category})")

    meta, body = parse_yaml_and_body(analysis_filepath)

    # Status prüfen
    status = meta.get("status", "offen")
    if status not in ("wiki-ready", "fertig"):
        print(f"  [SKIP] Status ist '{status}' – Wiki-Generierung nur bei 'wiki-ready' oder 'fertig'")
        return False

    wiki_content = generate_wiki_page(meta, body, mod_name, mod_category)
    wiki_file    = write_wiki_page(mod_name, mod_category, wiki_content)

    return commit_wiki_page(wiki_file, mod_name)


def main():
    """
    CLI-Modus: Kann mit einem Pfad als Argument aufgerufen werden,
    oder durchsucht analysis/ nach wiki-ready Dateien.
    """
    import sys

    if len(sys.argv) > 1:
        # Direkter Aufruf mit Pfad: python auto_wiki_page.py analysis/Gameplay/logistics+/analyse.md
        filepath = sys.argv[1]
        success  = generate_from_analysis(filepath)
        sys.exit(0 if success else 1)
    else:
        # Alle wiki-ready Analysen suchen und verarbeiten
        print("[INFO] Suche nach wiki-ready Analyse-Dateien...")
        found = 0
        for root, dirs, files in os.walk("analysis"):
            for f in files:
                if f == "analyse.md":
                    filepath = os.path.join(root, f).replace("\\", "/")
                    try:
                        meta, _ = parse_yaml_and_body(filepath)
                        if meta.get("status") in ("wiki-ready", "fertig"):
                            generate_from_analysis(filepath)
                            found += 1
                    except Exception as e:
                        print(f"  [FEHLER] {filepath}: {e}")

        print(f"\n[OK] {found} Wiki-Seite(n) generiert/aktualisiert.")


if __name__ == "__main__":
    main()
