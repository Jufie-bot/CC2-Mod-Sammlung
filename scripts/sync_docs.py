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
    
    # --- 1. Hero & Vision Header ---
    content.append("# 📟 CC2 Mod Development Hub\n")
    content.append(f"![Mods Total](https://img.shields.io/badge/Mods_Total-{mod_count}-blue?style=for-the-badge&logo=github)")
    content.append(f"![Analyzed](https://img.shields.io/badge/Analysed-{analyzed_count}-orange?style=for-the-badge&logo=bookstack)")
    content.append("![Discord](https://img.shields.io/badge/Discord-Join%20Us-7289DA?style=for-the-badge&logo=discord&logoColor=white)\n")
    
    content.append("## 🎯 Die Vision: Dekonstruktion & Neuschöpfung")
    content.append("Willkommen im Herzen der Carrier Command 2 Modding-Forschung. Dieses Projekt ist weit mehr als eine bloße Sammlung von Dateien – es ist ein **technisches Labor**, das darauf spezialisiert ist, die verborgene Logik des Spiels zu entschlüsseln.\n")
    content.append("Unsere Mission ist es, bestehende Mods und Spieldateien (XML/Lua) bis ins kleinste Detail zu analysieren, um Best-Practices zu etablieren und die Grundlage für die nächste Generation von Overhauls zu schaffen. Jede Variable, jede Vektorberechnung und jede Konstante wird hier hinterfragt, um das Maximum aus der Simulation herauszuholen.\n")

    # --- 2. News & Breakthroughs ---
    content.append("## 📡 Labor-Bericht: Aktuelle Durchbrüche")
    content.append("> [!IMPORTANT]")
    content.append("> **Fokus-Analyse**: Die Dekonstruktion der `Island_turret_placement_QoL` liefert aktuell bahnbrechende Erkenntnisse darüber, wie das Spiel Objekt-IDs für Verteidigungstürme zur Laufzeit verarbeitet. Diese Entdeckung wird die Entwicklung eigener Map-Verteidigungen revolutionieren.\n")

    # --- 3. Main Wiki Referral ---
    content.append("## 🏛️ Forschungs-Zentrale (Das Wiki)")
    content.append("Die gesamte technische Dokumentation, Code-Breakdowns und Entwickler-Standards haben wir in unser umfangreiches Wiki ausgelagert. Dort findest du das gebündelte Wissen aus hunderten Stunden Reverse Engineering.\n")
    content.append("👉 **[Zum offiziellen Dokumentations-Wiki](wiki_new/Home.md)**\n")
    content.append("*Hinweis: Im Wiki findest du auch den [Git Master-Guide](wiki_new/Git_Quickstart.md), falls du selbst zum Projekt beitragen möchtest.*\n")

    # --- 4. Collapsed Mod Archive ---
    content.append("## 📂 Archivierte Sammlungen")
    content.append(f"Unser Labor verwaltet derzeit **{mod_count} verschiedene Modifikationen**, die als Grundlage für unsere Analysen dienen.\n")
    content.append("<details>")
    content.append("<summary><b>📂 Vollständiges Archiv anzeigen (Klicken zum Ausklappen)</b></summary>\n")
    content.extend(categories_content)
    content.append("</details>\n")

    # --- 5. Footer ---
    content.append("---\n")
    content.append("### 🛰️ Kontakt & Mitwirkung")
    content.append("- [Feedback oder Analyse-Wunsch](.github/ISSUE_TEMPLATE/bug_report.md)")
    content.append("- [Community Discord](https://discord.gg/example)")
    content.append("- [Entwickler-Portal](CONTRIBUTING.md)\n")
    content.append(f"*Letzte automatische Synchronisierung: {os.popen('date /t').read().strip()} | Status: ✔️ Online*")

    with open(readme_path, "w", encoding="utf-8-sig") as f:
        f.write("\n".join(content))
    
    print(f"README.md erfolgreich aktualisiert | Mods: {mod_count} | Analysen: {analyzed_count}")

if __name__ == "__main__":
    generate_readme()
