import os
import subprocess
import json
from datetime import date

# ============================================================
# KATEGORIE -> LABEL MAPPING
# Ordnername in mods/ -> GitHub Label Name
# ============================================================
CATEGORY_LABEL_MAP = {
    "Audio":                    "Audio & Sounds",
    "Gameplay":                 "Gameplay & Balancing",
    "UI":                       "UI / HUD",
    "Vehicles":                 "Fahrzeuge & Schiffe",
    "Weapons":                  "Waffen & Geschütze",
    "Kategorienübergreifende":  "KI & Skynet",
    "Kategorien\u00fcbergreifende": "KI & Skynet",  # Fallback für Encoding-Varianten
}

DEFAULT_LABEL = "Typ: Forschung & Analyse"
STATUS_LABEL  = "Status: Neu erkannt"


def get_existing_issues():
    """Gibt alle Issue-Titel (offen + geschlossen) zurück."""
    result = subprocess.run(
        ["gh", "issue", "list", "--state", "all", "--json", "title", "--limit", "500"],
        capture_output=True, text=True
    )
    if result.returncode != 0:
        print(f"[FEHLER] Issues konnten nicht abgefragt werden: {result.stderr}")
        return []
    return [issue["title"] for issue in json.loads(result.stdout)]


def get_category_labels(category: str) -> list[str]:
    """Gibt die passenden Labels für eine Mod-Kategorie zurück."""
    area_label = CATEGORY_LABEL_MAP.get(category, DEFAULT_LABEL)
    return [DEFAULT_LABEL, area_label, STATUS_LABEL]


def create_issue(mod_category: str, mod_name: str) -> str | None:
    """Erstellt ein GitHub Issue für eine neu erkannte Mod."""
    title  = f"[ANALYSE] {mod_category}-Mod: {mod_name}"
    labels = get_category_labels(mod_category)
    body   = (
        f"## 🔍 Neue Mod erkannt: `{mod_name}`\n\n"
        f"**Kategorie:** `{mod_category}`  \n"
        f"**Pfad:** `mods/{mod_category}/{mod_name}/`  \n"
        f"**Analyse-Datei:** `analysis/{mod_category}/{mod_name}/analyse.md`\n\n"
        f"### Workflow\n"
        f"- [ ] Dateien der Mod sichten\n"
        f"- [ ] Änderungen zu Vanilla dokumentieren\n"
        f"- [ ] Erkenntnisse in `analyse.md` eintragen\n"
        f"- [ ] `status: wiki-ready` setzen -> Wiki-Seite wird automatisch erstellt\n\n"
        f"---\n"
        f"_Dieses Issue wurde automatisch generiert. Analysiere und ändere dann den Status in `analyse.md`._"
    )

    print(f"  -> Erstelle Issue: {title}")
    label_args = []
    for label in labels:
        label_args += ["--label", label]

    result = subprocess.run(
        ["gh", "issue", "create", "--title", title, "--body", body] + label_args,
        capture_output=True, text=True
    )
    if result.returncode != 0:
        print(f"  [FEHLER] {result.stderr.strip()}")
        return None
    url = result.stdout.strip()
    print(f"  [OK] Erstellt: {url}")
    return url


def ensure_analysis_file(mod_category: str, mod_name: str):
    """Erstellt eine analyse.md mit YAML-Frontmatter falls noch nicht vorhanden."""
    analysis_dir  = os.path.join("analysis", mod_category, mod_name)
    analysis_file = os.path.join(analysis_dir, "analyse.md")

    if os.path.exists(analysis_file):
        print(f"  [INFO] analyse.md bereits vorhanden: {analysis_file}")
        return

    os.makedirs(analysis_dir, exist_ok=True)
    today = date.today().isoformat()
    content = (
        f"---\n"
        f"mod: \"{mod_name}\"\n"
        f"category: \"{mod_category}\"\n"
        f"status: offen\n"
        f"priority: normal\n"
        f"wiki_page: \"\"\n"
        f"related_mods: []\n"
        f"last_updated: {today}\n"
        f"---\n\n"
        f"# Analyse: {mod_name}\n\n"
        f"## Rohdaten / Sichtung\n\n"
        f"> TODO: Dateien in `mods/{mod_category}/{mod_name}/` sichten und hier notieren.\n\n"
        f"## Erkenntnisse\n\n"
        f"> TODO: Was verändert diese Mod am Spiel?\n\n"
        f"## Offene Fragen\n\n"
        f"> TODO: Was ist noch unklar?\n\n"
        f"## Notizen für eigene Mods\n\n"
        f"> TODO: Was kann ich in `Skynet V4 + Extras` übernehmen?\n"
    )
    with open(analysis_file, "w", encoding="utf-8") as f:
        f.write(content)
    print(f"  [FILE] analyse.md erstellt: {analysis_file}")


def main():
    existing_titles = get_existing_issues()
    mods_dir = "mods"

    if not os.path.exists(mods_dir):
        print(f"[FEHLER] Verzeichnis '{mods_dir}' nicht gefunden.")
        return

    created = 0
    skipped = 0

    for category in sorted(os.listdir(mods_dir)):
        category_path = os.path.join(mods_dir, category)
        if not os.path.isdir(category_path):
            continue

        print(f"\n[DIR] Kategorie: {category}")
        for mod_name in sorted(os.listdir(category_path)):
            mod_path = os.path.join(category_path, mod_name)
            if not os.path.isdir(mod_path):
                continue

            # Prüfen: Existiert schon ein Issue (verschiedene Titel-Formate)
            expected_title = f"[ANALYSE] {category}-Mod: {mod_name}"
            legacy_title   = f"[ANALYSE] {category}-Mod untersuchen: {mod_name}"
            legacy_title2  = f"[ANALYSE] Gameplay-Mod untersuchen: {mod_name}"

            if any(t in existing_titles for t in [expected_title, legacy_title, legacy_title2]):
                print(f"  [SKIP] Überspringe '{mod_name}': Issue existiert")
                skipped += 1
            else:
                create_issue(category, mod_name)
                created += 1

            # Analyse-Datei immer sichern (auch wenn Issue schon existiert)
            ensure_analysis_file(category, mod_name)

    print(f"\n[OK] Fertig. Erstellt: {created} Issues, Übersprungen: {skipped}")


if __name__ == "__main__":
    main()
