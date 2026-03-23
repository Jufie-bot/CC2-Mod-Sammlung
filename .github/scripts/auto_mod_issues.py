import os
import subprocess
import json

def get_existing_issues():
    print("Frage bestehende Issues über GitHub API ab...")
    result = subprocess.run(
        ["gh", "issue", "list", "--state", "all", "--json", "title", "--limit", "500"],
        capture_output=True, text=True
    )
    if result.returncode != 0:
        print(f"Fehler: {result.stderr}")
        return []
    
    issues = json.loads(result.stdout)
    return [issue["title"] for issue in issues]

def create_issue(mod_category, mod_name):
    title = f"[ANALYSE] {mod_category}-Mod untersuchen: {mod_name}"
    body = f"Im Labor-Verzeichnis `mods/{mod_category}/` liegt die Mod **{mod_name}**.\n\n" \
           f"**Geplante Aufgaben:**\n" \
           f"- [ ] Dateien der Mod sichten\n" \
           f"- [ ] Änderungen an den Vanilla-Skripten dokumentieren\n" \
           f"- [ ] Relevante Erkenntnisse für eigene Projekte übernehmen\n\n" \
           f"_Hinweis: Dieses Issue wurde automatisch generiert, da ein neuer Mod-Ordner hinzugefügt wurde._"
    
    print(f"Erstelle neues Issue für '{mod_name}'...")
    subprocess.run([
        "gh", "issue", "create",
        "--title", title,
        "--body", body,
        "--label", "Typ: Forschung & Analyse"
    ], check=True)

def main():
    existing_titles = get_existing_issues()
    mods_dir = "mods"
    
    if not os.path.exists(mods_dir):
        print(f"Verzeichnis '{mods_dir}' nicht gefunden. Beende Skript.")
        return

    for category in os.listdir(mods_dir):
        category_path = os.path.join(mods_dir, category)
        if os.path.isdir(category_path):
            for mod in os.listdir(category_path):
                mod_path = os.path.join(category_path, mod)
                if os.path.isdir(mod_path):
                    expected_title = f"[ANALYSE] {category}-Mod untersuchen: {mod}"
                    expected_title_legacy = f"[ANALYSE] Gameplay-Mod untersuchen: {mod}" # Fallback
                    if expected_title not in existing_titles and expected_title_legacy not in existing_titles:
                        try:
                            create_issue(category, mod)
                        except Exception as e:
                            print(f"Fehler beim Erstellen von {mod}: {e}")
                    else:
                        print(f"Ueberspringe '{mod}': Issue existiert bereits.")

if __name__ == "__main__":
    main()
