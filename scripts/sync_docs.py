import os

def generate_readme():
    # Script is in scripts/, so root is ../
    script_dir = os.path.dirname(os.path.abspath(__file__))
    workspace_path = os.path.abspath(os.path.join(script_dir, "../"))
    
    print(f"DEBUG: Workspace Path erkannt als: {workspace_path}")

    readme_path = os.path.join(workspace_path, "README.md")
    github_path = os.path.join(workspace_path, ".github")
    
    # Paths to analysis docs
    handbuch_path = os.path.join(github_path, "Technisches_Entwickler_Handbuch.md")
    labels_path = os.path.join(github_path, "labels.md")
    governance_path = os.path.join(workspace_path, "GOVERNANCE.md") # Actually in .github/GOVERNANCE.md (moved earlier) or root depending on last step? Checking...
    # Based on last output, GOVERNANCE and CONTRIBUTING are in root or .github? 
    # Let's assume standard .github location for cleanliness, but check if they exist there.
    # Actually, previous steps moved them to root. Let's check root first.
    
    wiki_home = "https://github.com/Jufie-bot/CC2-Mod-Sammlung/wiki"

    # Count Analyzed Mods
    analyzed_count = 0
    if os.path.exists(handbuch_path):
        with open(handbuch_path, 'r', encoding='utf-8') as f:
            for line in f:
                if line.strip().startswith("## ") and "Zusammenfassung" not in line:
                    analyzed_count += 1

    content = []
    
    # --- 1. Header & Badges ---
    content.append("# Carrier Command 2 - Mod Development Hub �\n")
    content.append(f"![Mods Total](https://img.shields.io/badge/Mods_Total-Dynamic-blue?style=for-the-badge&logo=github)") # Placeholder
    content.append(f"![Analyzed](https://img.shields.io/badge/Analysed-{analyzed_count}-orange?style=for-the-badge&logo=bookstack)")
    content.append("![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)")
    content.append("![Status](https://img.shields.io/badge/Status-Active_Development-success?style=for-the-badge)")
    content.append("![Discord](https://img.shields.io/badge/Discord-Join-5865F2?style=for-the-badge&logo=discord&logoColor=white)\n")

    # --- 2. Vision & Mission ---
    content.append("## 🎯 Vision: Die Ultimative Mod-Entwicklung\n")
    content.append("> **\"Ich analysiere nicht nur – ich erschaffe neu.\"**\n")
    content.append("Herzlich willkommen in meinem Forschungslabor. Dieses Repository ist weit mehr als nur eine Sammlung von existierenden Mods.\n")
    content.append("### 🧬 Mein Ziel")
    content.append("Ich arbeite an einer **eigenen, umfassenden Modifikation** für Carrier Command 2. Um das bestmögliche Ergebnis zu erzielen, gehe ich wissenschaftlich vor:")
    content.append("1.  **Sammeln**: Ich archiviere fast alle verfügbaren Mods.")
    content.append("2.  **Dekonstruieren**: Ich analysiere den Quellcode (Lua & XML), um zu verstehen, *wie* andere Entwickler Probleme gelöst haben.")
    content.append("3.  **Lernen & Dokumentieren**: Jede Erkenntnis landet in diesem Repository – als Wissen für mich und die gesamte Community.")
    content.append("4.  **Erschaffen**: Mit diesem Wissen baue ich meine eigene Vision.\n")

    # --- 3. Struktur der Sammlung ---
    content.append("## 📂 Struktur der Sammlung\n")
    content.append("Damit du dich zurechtfindest, ist alles sauber kategorisiert. ")
    content.append("Jeder Ordner in `mods/` repräsentiert einen technischen Bereich:\n")
    content.append("| Kategorie | Inhalt |")
    content.append("| :--- | :--- |")
    content.append("| **🔊 Audio** | Sound-Overhauls, Alarme, Stimmen |")
    content.append("| **🚗 Vehicles** | Neue Chassis, Anpassungen an Schiffen/Fahrzeugen |")
    content.append("| **⚔️ Weapons** | Turrets, Missiles, Torpedos, Ballistik |")
    content.append("| **💻 UI** | Interface-Anpassungen, Map-Overlays, Screens |")
    content.append("| **📜 Scripts** | Reine Lua-Bibliotheken und Helper-Funktionen |")
    content.append("| **🗺️ Maps** | Custom Islands und Kartendaten |\n")

    # --- 4. Zentrale Dokumentation (Knowledge Base) ---
    content.append("## 🧠 Knowledge Base & Analysen\n")
    content.append("Hier findest du das Herzstück meiner Arbeit – die Dokumentation.\n")
    
    content.append("### 📘 [Technisches Entwickler-Handbuch](.github/Technisches_Entwickler_Handbuch.md)")
    content.append(f"> **Status:** {analyzed_count} Mods detailliert analysiert.")
    content.append("Hier zerlege ich Mods in ihre Einzelteile. Ich dokumentiere XML-Tricks, Lua-Hacks und versteckte Spielmechaniken.\n")
    
    content.append("### � [Code Detail Analyse](.github/Code_Detail_Analyse.md)")
    content.append("Tiefgehende Betrachtung von spezifischen Algorithmen. Wie funktioniert das Zielsystem? Wie werden Wegpunkte berechnet?\n")

    content.append("### 📏 [Entwickler Standards](.github/Entwickler_Standards.md)")
    content.append("Meine Regeln für sauberen Code. Wenn du mitmachen willst oder einfach guten Code schreiben möchtest, lies das hier.\n")
    
    if os.path.exists(labels_path):
        content.append("### 🏷️ [Label-Guide](.github/labels.md)")
        content.append("Bedeutung der GitHub Labels (Priority, Status, etc.) für unser Projektmanagement.\n")
    
    content.append(f"### 📚 [Das Projekt-Wiki]({wiki_home})")
    content.append("Für alles, was den Rahmen einer einzelnen Datei sprengt. Tutorials, Guides und mehr.\n")

    # --- 5. Projekt-Management & Regeln ---
    content.append("## ⚖️ Regeln & Sicherheit\n")
    content.append("Damit die Zusammenarbeit funktioniert, haben wir klare Spielregeln:\n")
    
    # Check for these files in root or .github
    if os.path.exists(os.path.join(workspace_path, "GOVERNANCE.md")):
        content.append("- **[GOVERNANCE](GOVERNANCE.md)**: Wer entscheidet was? Wer darf mergen?")
    elif os.path.exists(os.path.join(github_path, "GOVERNANCE.md")):
        content.append("- **[GOVERNANCE](.github/GOVERNANCE.md)**: Wer entscheidet was? Wer darf mergen?")
        
    if os.path.exists(os.path.join(workspace_path, "SECURITY.md")):
        content.append("- **[SECURITY](SECURITY.md)**: So melden wir Sicherheitslücken.")
    elif os.path.exists(os.path.join(github_path, "SECURITY.md")):
        content.append("- **[SECURITY](.github/SECURITY.md)**: So melden wir Sicherheitslücken.")
        
    if os.path.exists(os.path.join(workspace_path, "CONTRIBUTING.md")):
        content.append("- **[CONTRIBUTING](CONTRIBUTING.md)**: Wie du Pull Requests einreichst (Wichtig!).")
    elif os.path.exists(os.path.join(github_path, "CONTRIBUTING.md")):
        content.append("- **[CONTRIBUTING](.github/CONTRIBUTING.md)**: Wie du Pull Requests einreichst (Wichtig!).")
    
    content.append("\n")

    # --- 6. Mod Categories & Count (Dynamic List) ---
    content.append("## 📦 Inhalt der Sammlung (Live-Status)\n")
    
    mods_path = os.path.join(workspace_path, "mods")
    mod_count = 0
    categories_content = []
    
    if os.path.exists(mods_path):
        categories = sorted([d for d in os.listdir(mods_path) if os.path.isdir(os.path.join(mods_path, d))])
        
        for category in categories:
            cat_path = os.path.join(mods_path, category)
            # Find mods in this category (recursive)
            cat_mods = []
            for root, dirs, files in os.walk(cat_path):
                if "mod.xml" in files:
                    mod_name = os.path.basename(root)
                    cat_mods.append(mod_name)
            
            if cat_mods:
                categories_content.append(f"### {category} ({len(cat_mods)})")
                for mod in sorted(cat_mods):
                     categories_content.append(f"- {mod}")
                categories_content.append("")
                mod_count += len(cat_mods)

    # Note: Update the badge line with the real count using a placeholder replacement
    content[1] = content[1].replace("Dynamic", str(mod_count))
    
    content.extend(categories_content)

    content.append(f"\n**Gesamtanzahl Mods in der Library:** {mod_count}\n")
    
    # --- 7. Footer ---
    content.append("---\n")
    content.append("### 💬 Kontakt & Community\n")
    content.append("- [Fehler gefunden?](.github/ISSUE_TEMPLATE/bug_report.md) | [Idee vorschlagen?](.github/ISSUE_TEMPLATE/feature_request.md)\n")
    content.append(f"*Automatisch generiert via `scripts/sync_docs.py`.*")

    with open(readme_path, "w", encoding="utf-8") as f:
        f.write("\n".join(content))
    
    print(f"ULTIMATE README.md erfolgreich erstellt | Mods: {mod_count} | Analysiert: {analyzed_count}")

if __name__ == "__main__":
    generate_readme()
