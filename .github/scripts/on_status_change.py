import os
import subprocess
import json
import re
import yaml
from datetime import date
from typing import Optional

# ============================================================
# STATUS → AKTION MAPPING
# Wenn YAML-Frontmatter "status" diesen Wert hat → folgende Aktionen
# ============================================================
STATUS_ACTIONS = {
    "analysiert": {
        "add_labels":    ["Status: In Analyse"],
        "remove_labels": ["Status: Neu erkannt"],
        "comment":       "🔬 Analyse gestartet – Status automatisch auf 'In Analyse' gesetzt.",
    },
    "wiki-ready": {
        "add_labels":    ["Status: Wiki-Ready"],
        "remove_labels": ["Status: In Analyse", "Status: Neu erkannt"],
        "comment":       "✅ Wiki-Ready – Wiki-Seite wird automatisch generiert.",
        "create_wiki":   True,
    },
    "fertig": {
        "add_labels":    ["Status: Verified (Validiert)"],
        "remove_labels": ["Status: Wiki-Ready", "Status: In Analyse"],
        "comment":       "🏁 Analyse abgeschlossen. Issue wird geschlossen.",
        "close_issue":   True,
    }
}


def parse_yaml_frontmatter(filepath: str) -> Optional[dict]:
    """Liest das YAML-Frontmatter aus einer Markdown-Datei."""
    try:
        with open(filepath, "r", encoding="utf-8") as f:
            content = f.read()
        match = re.match(r"^---\s*\n(.*?)\n---", content, re.DOTALL)
        if match:
            return yaml.safe_load(match.group(1))
    except Exception as e:
        print(f"  [FEHLER] YAML-Parsing von {filepath}: {e}")
    return None


def find_issue_number(mod_category: str, mod_name: str) -> Optional[int]:
    """Sucht das zugehörige GitHub Issue anhand des Mod-Namens."""
    result = subprocess.run(
        ["gh", "issue", "list", "--state", "all", "--json", "number,title", "--limit", "500"],
        capture_output=True, text=True
    )
    if result.returncode != 0:
        return None

    issues = json.loads(result.stdout)
    search_terms = [
        f"[ANALYSE] {mod_category}-Mod: {mod_name}",
        f"[ANALYSE] {mod_category}-Mod untersuchen: {mod_name}",
    ]
    for issue in issues:
        if any(term in issue["title"] for term in search_terms):
            return issue["number"]
    return None


def apply_labels(issue_number: int, add: list[str], remove: list[str]):
    """Fügt Labels hinzu und entfernt alte Labels von einem Issue."""
    for label in add:
        subprocess.run(
            ["gh", "issue", "edit", str(issue_number), "--add-label", label],
            capture_output=True
        )
        print(f"    + Label: {label}")

    for label in remove:
        subprocess.run(
            ["gh", "issue", "edit", str(issue_number), "--remove-label", label],
            capture_output=True
        )
        print(f"    - Label: {label}")


def add_comment(issue_number: int, comment: str):
    """Schreibt einen Kommentar auf ein Issue."""
    subprocess.run(
        ["gh", "issue", "comment", str(issue_number), "--body", comment],
        capture_output=True
    )


def close_issue(issue_number: int):
    """Schließt ein Issue."""
    subprocess.run(
        ["gh", "issue", "close", str(issue_number)],
        capture_output=True
    )
    print(f"    🔒 Issue #{issue_number} geschlossen")


def create_wiki_issue(mod_category: str, mod_name: str, wiki_page: str = ""):
    """Erstellt ein Wiki-Aufgaben-Issue wenn Status 'wiki-ready' gesetzt."""
    title = f"[WIKI] {mod_name} dokumentieren"
    body = (
        f"## 📚 Wiki-Seite erstellen: {mod_name}\n\n"
        f"Die Analyse von **{mod_name}** (`{mod_category}`) ist abgeschlossen.\n\n"
        f"**Quell-Datei:** `analysis/{mod_category}/{mod_name}/analyse.md`  \n"
        f"**Ziel-Seite:** `wiki/Game-Referenz/{mod_category}/{mod_name}.md`\n\n"
        f"### Aufgaben\n"
        f"- [ ] Wiki-Seite aus analyse.md generieren / prüfen\n"
        f"- [ ] Verlinkungen in der Sidebar kontrollieren\n"
        f"- [ ] Issue schließen wenn fertig\n\n"
        f"---\n"
        f"_Automatisch erstellt bei Status-Änderung: wiki-ready_"
    )
    result = subprocess.run(
        ["gh", "issue", "create",
         "--title", title,
         "--body", body,
         "--label", "Wiki & Doku",
         "--label", "Status: Wiki-Ready"],
        capture_output=True, text=True
    )
    if result.returncode == 0:
        print(f"    📋 Wiki-Issue erstellt: {result.stdout.strip()}")


def process_changed_files(changed_files: list[str]):
    """Verarbeitet alle geänderten analyse.md Dateien."""
    for filepath in changed_files:
        # Nur analyse.md Dateien in analysis/**/ bearbeiten
        if not filepath.endswith("analyse.md") or not filepath.startswith("analysis/"):
            continue

        print(f"\n📄 Analysiere: {filepath}")
        parts = filepath.split("/")
        if len(parts) < 3:
            continue

        mod_category = parts[1]
        mod_name     = parts[2]

        meta = parse_yaml_frontmatter(filepath)
        if not meta:
            print(f"  [SKIP] Kein YAML-Frontmatter gefunden.")
            continue

        status = meta.get("status", "offen")
        print(f"  → Status: {status}")

        if status not in STATUS_ACTIONS:
            print(f"  [SKIP] Kein Trigger-Status (bekannte Trigger: {list(STATUS_ACTIONS.keys())})")
            continue

        action = STATUS_ACTIONS[status]
        issue_number = find_issue_number(mod_category, mod_name)

        if not issue_number:
            print(f"  [WARN] Passendes Issue nicht gefunden für {mod_category}/{mod_name}")
        else:
            print(f"  → Issue #{issue_number} gefunden")
            apply_labels(issue_number, action.get("add_labels", []), action.get("remove_labels", []))

            if "comment" in action:
                add_comment(issue_number, action["comment"])

            if action.get("close_issue"):
                close_issue(issue_number)

        if action.get("create_wiki"):
            create_wiki_issue(mod_category, mod_name, meta.get("wiki_page", ""))


def main():
    # Geänderte Dateien werden von der GitHub Action als Umgebungsvariable übergeben
    changed_env = os.environ.get("CHANGED_FILES", "")

    if changed_env:
        changed_files = [f.strip() for f in changed_env.split("\n") if f.strip()]
    else:
        # Lokaler Fallback: alle analyse.md Dateien suchen
        print("[INFO] Kein CHANGED_FILES gefunden – Alle analyse.md Dateien werden geprüft.")
        changed_files = []
        for root, dirs, files in os.walk("analysis"):
            for file in files:
                if file == "analyse.md":
                    changed_files.append(os.path.join(root, file).replace("\\", "/"))

    if not changed_files:
        print("[INFO] Keine relevanten Dateien gefunden.")
        return

    print(f"[INFO] Prüfe {len(changed_files)} Datei(en)...")
    process_changed_files(changed_files)
    print("\n✅ on_status_change.py abgeschlossen.")


if __name__ == "__main__":
    main()
