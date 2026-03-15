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
    content.append("![System_Version](https://img.shields.io/badge/Systemstruktur-v5.3-success?style=for-the-badge)\n")
    
    content.append("## 🎯 Die Vision: Dekonstruktion & Neuschöpfung")
    content.append("Willkommen im Herzen der Carrier Command 2 Modding-Forschung. Dieses Repository ist keine klassische Mod-Ablage, sondern ein echtes **technisches Labor**, das sich der vollständigen Dekonstruktion der Spielmechaniken verschrieben hat.\n")
    content.append("Unsere Mission: Wir belassen es nicht dabei, Mods einfach nur herunterzuladen und zu spielen. Wir zerlegen hunderte von existierenden Mods und Spieldateien (XML/Lua) bis auf die elementarste Ebene. Wir analysieren Parameter, testen Geschwindigkeitsvektoren und sezieren KI-Skripte. Unser absolutes Ziel ist es, Best-Practices zu etablieren, die **Grundlage für die nächste Generation von gigantischen Overhauls** zu schaffen und das absolute Maximum aus der Simulation herauszuholen.\n")

    # --- 2. Workflow ---
    content.append("## ⚙️ Wie wir arbeiten (Der Labor-Workflow)")
    content.append("Jede Modifikation, die unser Labor betritt, durchläuft einen strengen **Forschungs-Fließbandprozess**:")
    content.append("1. **Code lesen**: Wir analysieren den rohen XML/Lua-Code der Mod, um die Logik exakt zu verstehen.")
    content.append("2. **Referenz-Vergleich**: Die Mod wird gegen unsere Vanilla-Game-Referenzen geprüft, um die Änderungen zum Original herauszuarbeiten.")
    content.append("3. **Labor-Bericht**: Wir verfassen eine Deep-Dive Detailanalyse der Mod-Struktur und Parameter.")
    content.append("4. **Extraktion (Sandkasten)**: Nützliche Code-Snippets, Hooks und IDs werden in unseren Sandkasten extrahiert, um sofort für neue Bastel-Projekte wiederverwendet werden zu können.")
    content.append("5. **Wissens-Transfer**: Die finale Analyse fließt in unser zentrales Wiki-System ein, damit das gesamte Wissen persistent dokumentiert ist.\n")

    # --- 3. Kontext & System-Architektur ---
    content.append("## 🏗️ System-Architektur (Masterpläne v5.3)")
    content.append("Dieses Labor basiert auf einer streng strukturierten Architektur. Diese vier internen Kontext-Dokumente bilden den **konzeptionellen Masterplan** für unsere Arbeitsweise:")
    content.append("1. 🏛️ [**00_SYSTEMSTRUKTUR.md**](00_SYSTEMSTRUKTUR.md) – Übersicht unserer 6 Säulen (Forschung, Wiki, Sandkasten, Eigene Mods, Community, Konfiguration).")
    content.append("2. 🏷️ [**01_BOARDS_UND_LABELS.md**](01_BOARDS_UND_LABELS.md) – Die feste Definition unseres GitHub-Projekt-Routings und der Fließbänder.")
    content.append("3. 📖 [**02_WIKI_STRUKTUR.md**](02_WIKI_STRUKTUR.md) – Architektur unseres 15-teiligen Wissens-Hubs.")
    content.append("4. 🚀 [**03_IMPLEMENTATION.md**](03_IMPLEMENTATION.md) – Der Arbeits- und Umbau-Plan des Labors.\n")

    # --- 4. Der Sandkasten ---
    content.append("## 🪣 Der Sandkasten (Unsere Werkbank)")
    content.append("Der **Sandkasten** (`sandbox/`) ist das operative Herzstück für Mod-Entwickler. Hier lagern wir alles, was man braucht, um eigene Kreationen zu formen:")
    content.append("- **Vanilla-Referenzen**: Die extrahierten Originaldateien des Spiels, katalogisiert nach Patch-Datum.")
    content.append("- **Snippets & IDs**: Tausende Objekt-IDs, komplexe LUA-Hook-Gerüste und Balance-Strings für die `constants.txt`, um blitzschnell Prototypen bauen zu können.")
    content.append("- **Templates**: Vorgefertigte Boilerplates für neue Mods, die unsere Best-Practices bereits integrieren.\n")

    # --- 5. The Non-Classical Wiki ---
    content.append("## 🧠 Das Wiki: Ein 15-teiliges System, kein klassisches Wiki")
    content.append("Unser Wiki ist **keine lose Sammlung von Artikeln**! Vergiss klassische Wikis. Unser Wissens-Hub ist ein hochgradig durchdachtes, **15-teiliges System**, das als das primäre 'Hirn' des Projekts dient. Nur strukturierte, kuratierte und im Spiel getestete Informationen erhalten einen Platz.\n")
    content.append("Dort findest du unter anderem:")
    content.append("- **Theoretische Grenzen**: Was ist im Spiel überhaupt moddbar und was nicht?")
    content.append("- **Labor-Experimente**: Direkte Gegenüberstellungen, wenn mehrere Mods dasselbe Problem lösen.")
    content.append("- **Mod-Galerien**: Der Status-Bericht aller je von uns getesteten Mods.")
    content.append("- **Game-Referenzen**: Das extrem tiefe Nachschlagewerk zu allen XML-Dateien, Lua-Umgebungen und Physik-Vektoren.\n")
    content.append("👉 **[Betritt das offizielle CC2-Forschungs-Wiki](https://github.com/Jufie-bot/CC2-Mod-Sammlung/wiki)**\n")

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
