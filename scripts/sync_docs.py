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
    
    # --- 1. Header & Vision ---
    content.append("# 📟 CC2 Mod Development Hub\n")
    content.append(f"![Mods Total](https://img.shields.io/badge/Mods_Total-{mod_count}-blue?style=for-the-badge&logo=github)")
    content.append(f"![Analyzed](https://img.shields.io/badge/Analysed-{analyzed_count}-orange?style=for-the-badge&logo=bookstack)")
    content.append("![Status](https://img.shields.io/badge/Status-Active_Development-success?style=for-the-badge)\n")
    
    content.append("## 🎯 Die Vision")
    content.append("> **\"Dekonstruktion bestehender Logik, um die nächste Generation von CC2-Mods zu erschaffen.\"**\n")
    content.append("Dieser Hub ist nicht nur ein Archiv. Er ist ein technisches Forschungslabor für Carrier Command 2. Hier werden Mods in ihre Einzelteile zerlegt (XML/Lua), um Best-Practices für zukünftige Overhauls zu etablieren.\n")

    # --- 2. Modding Guide (Navigation Hub) ---
    content.append("## 🗺️ Der ultimative Modding-Explorer\n")
    content.append("| 🟢 Einstieg für Neulinge | 🔬 Forschung & Deep-Dives | 🛠️ Projekt-Steuerung |")
    content.append("| :--- | :--- | :--- |")
    content.append("| [**Wiki Home**](wiki_new/Home.md) | [**Technische Referenz**](wiki_new/Technische-Referenz.md) | [**Projekt-Entwicklung**](wiki_new/Projekt_Entwicklung.md) |")
    content.append("| [**Grundlagen**](wiki_new/Modding_Grundlagen.md) | [**Code-Analysen**](wiki_new/Code_Detail_Analyse.md) | [**Entwickler-Standards**](wiki_new/Entwickler_Standards.md) |")
    content.append("| [**Mod-Liste**](wiki_new/Mod_Kategorien_Liste.md) | [**Lua Referenz**](wiki_new/Lua_Referenz.md) | [**Live-Status**](#-live-status-sammlung) |\n")

    # --- 3. Live-Status ---
    content.append("## 📡 Live-Status Sammlung\n")
    content.append(f"Derzeit befinden sich **{mod_count} Mods** in der Bibliothek, wovon **{analyzed_count} tiefgehend technisch analysiert** wurden.\n")
    
    content.append("<details>")
    content.append("<summary><b>📂 Vollständige Mod-Liste anzeigen (Klicken zum Ausklappen)</b></summary>\n")
    content.extend(categories_content)
    content.append("</details>\n")

    # --- 4. Footer ---
    content.append("---\n")
    content.append("### 💬 Kontakt")
    content.append("- [Fehler oder neue Analyse vorschlagen](.github/ISSUE_TEMPLATE/bug_report.md)")
    content.append("- [Wiki-Beitrag leisten](CONTRIBUTING.md)\n")
    content.append(f"*Zuletzt automatisch synchronisiert: März 2026 via `sync_docs.py`*")

    with open(readme_path, "w", encoding="utf-8-sig") as f:
        f.write("\n".join(content))
    
    print(f"README.md erfolgreich aktualisiert | Mods: {mod_count} | Analysen: {analyzed_count}")

if __name__ == "__main__":
    generate_readme()
