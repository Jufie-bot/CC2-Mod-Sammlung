import os

def generate_readme():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    workspace_path = os.path.abspath(os.path.join(script_dir, "../"))
    
    readme_path = os.path.join(workspace_path, "README.md")
    wiki_path = os.path.join(workspace_path, "wiki_new")
    detail_analyse_path = os.path.join(workspace_path, ".github/workflows/Detailanalyse")
    
    # Count Analyzed Mods
    analyzed_count = 0
    if os.path.exists(detail_analyse_path):
        analyzed_count = len([f for f in os.listdir(detail_analyse_path) if f.endswith(".md")])
    
    # Total Mod Count
    mods_path = os.path.join(workspace_path, "mods")
    mod_count = 0
    categories_content = []
    
    if os.path.exists(mods_path):
        categories = sorted([d for d in os.listdir(mods_path) if os.path.isdir(os.path.join(mods_path, d))])
        for category in categories:
            cat_path = os.path.join(mods_path, category)
            cat_mods = []
            for root, dirs, files in os.walk(cat_path):
                if "mod.xml" in files:
                    cat_mods.append(os.path.basename(root))
            
            if cat_mods:
                categories_content.append(f"#### {category} ({len(cat_mods)})")
                for mod in sorted(cat_mods):
                    categories_content.append(f"- {mod}")
                categories_content.append("")
                mod_count += len(cat_mods)

    content = []
    
    # --- 1. Hero Section & Vision ---
    content.append("# 📟 CC2 Mod Development Hub\n")
    content.append(f"![Mods Total](https://img.shields.io/badge/Mods_Total-{mod_count}-blue?style=for-the-badge&logo=github)")
    content.append(f"![Analyzed](https://img.shields.io/badge/Analysed-{analyzed_count}-orange?style=for-the-badge&logo=bookstack)")
    content.append("![Discord](https://img.shields.io/badge/Discord-Join%20Us-7289DA?style=for-the-badge&logo=discord&logoColor=white)\n")
    
    content.append("## 🎯 Die Vision")
    content.append("> **\"Die ultimative Mod-Entwicklung: Ich analysiere nicht nur, ich erschaffe neu.\"**\n")
    content.append("Herzlich willkommen in meinem Forschungslabor. Dies ist weit mehr als nur eine Sammlung von existierenden Mods. Hier werden die Grenzen von Carrier Command 2 durch dekonstruktive Analyse und innovatives Re-Engineering neu definiert.\n")

    # --- 2. Central Navigation (The Hub) ---
    content.append("## 🗺️ Forschungs-Zentrale")
    content.append("Nutze das Wiki für detaillierte Einblicke in unsere Entdeckungen und Standards.\n")
    content.append("| 🟢 Für Einsteiger | 🔬 Forschung & Technik | 🛠️ Projekt & Leitung |")
    content.append("| :--- | :--- | :--- |")
    content.append("| [**Wiki Home**](wiki_new/Home.md) | [**Technische Referenz**](wiki_new/Technische-Referenz.md) | [**Projekt-Entwicklung**](wiki_new/Projekt_Entwicklung.md) |")
    content.append("| [**Git Quickstart**](wiki_new/Git_Quickstart.md) | [**Code-Detail-Analyse**](wiki_new/Code_Detail_Analyse.md) | [**Entwickler-Standards**](wiki_new/Entwickler_Standards.md) |")
    content.append("| [**Anleitung: Release**](wiki_new/Git_Quickstart.md#📦-7-profi-tipp-einzelne-mods-teilen-branches--tags) | [**Lua Referenz**](wiki_new/Lua_Referenz.md) | [**Community Discord**](https://discord.gg/example) |\n")

    # --- 3. Community & News ---
    content.append("## 📡 Projekt-News & Community")
    content.append("Aktuelle Durchbrüche und Ankündigungen direkt aus dem Labor.\n")
    content.append("> [!TIP]")
    content.append("> **Neuankündigung**: Die technische Analyse der `Island_turret_placement_QoL` ist abgeschlossen und liefert bahnbrechende Erkenntnisse für die KI-Platzierung!\n")
    
    # --- 4. Library Overview (Collapsed) ---
    content.append("## 📂 Archivierte Sammlungen")
    content.append(f"Derzeit befinden sich **{mod_count} Mods** in unserer Bibliothek.\n")
    content.append("<details>")
    content.append("<summary><b>Vollständige Mod-Liste anzeigen</b></summary>\n")
    content.extend(categories_content)
    content.append("</details>\n")

    # --- 5. Footer ---
    content.append("---\n")
    content.append("### 🛰️ Kontakt & Mitwirkung")
    content.append("- [Fehler melden](.github/ISSUE_TEMPLATE/bug_report.md)")
    content.append("- [Zum Discord Server](https://discord.gg/example)")
    content.append("- [Wiki-Beitrag leisten](CONTRIBUTING.md)\n")
    content.append(f"*Letzte Synchronisierung: {os.popen('date /t').read().strip()} | Automatischer Hub Status: ✔️*")

    with open(readme_path, "w", encoding="utf-8-sig") as f:
        f.write("\n".join(content))
    
    print(f"README.md erfolgreich aktualisiert | Mods: {mod_count} | Analysen: {analyzed_count}")

if __name__ == "__main__":
    generate_readme()
