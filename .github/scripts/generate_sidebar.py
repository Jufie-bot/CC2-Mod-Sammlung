import os
from pathlib import Path

# Basis-Verzeichnis des Wikis
WIKI_DIR = Path("wiki")

# Die gewünschte Reihenfolge und Anzeige-Titel für die Kategorien in der Sidebar
CATEGORY_ORDER = {
    "System-Guide": "🗺️ Einstieg",
    "Fundament": "🏗️ Fundament",
    "Was-ist-moeglich": "🔍 Was ist möglich?",
    "Game-Referenz": "📖 Game-Referenz",
    "Labor-Experimente": "🧪 Labor-Experimente",
    "Guides-und-Tutorials": "🛠️ Guides & Tutorials",
    "Code-Standards": "📐 Code-Standards",
    "Mod-Galerie": "🗂️ Mod-Galerie",
    "Sandkasten": "🏗️ Sandkasten",
    "Kategorienuebergreifende-Mods": "🔧 Kategorienübergreifend",
    "Eigene-Mods": "👤 Eigene Mods",
    "Automatisierung": "⚙️ Automatisierung",
    "Spiel-Updates": "📅 Spiel-Updates",
    "Community": "🌍 Community"
}

def format_title(filename):
    # Macht 'Analysis-15mm-Turrets' zu 'Analysis 15mm Turrets' (optional) oder entfernt striche
    name = filename.replace("-", " ")
    # Entfernt führendes '-' für Backups wie '-Code_Detail_Analyse'
    if name.startswith(" "):
        name = name[1:]
    return name

def generate_sidebar():
    sidebar_lines = [
        "# 🧭 Navigation",
        "",
        "[Home](Home)",
        "",
        "---"
    ]
    
    # Durchlaufe definierte Kategorien in der gewünschten Reihenfolge
    for folder_name, display_title in CATEGORY_ORDER.items():
        folder_path = WIKI_DIR / folder_name
        if not folder_path.exists():
            continue
            
        sidebar_lines.append(f"\n### {display_title}")
        
        # Der Hauptlink für diese Kategorie (z.B. System-Guide.md)
        main_file = folder_path / f"{folder_name}.md"
        if main_file.exists():
            sidebar_lines.append(f"- [{folder_name.replace('-', ' ')}]({folder_name})")
        
        # Sammle alle weiteren Dateien im Ordner (inkl. Unterordner)
        sub_items = []
        for root, dirs, files in os.walk(folder_path):
            rel_root = Path(root).relative_to(folder_path)
            
            for file in sorted(files):
                if not file.endswith(".md"):
                    continue
                # Ignoriere die Haupt-Kategoriedatei (bereits hinzugefügt)
                if file == f"{folder_name}.md":
                    continue
                
                # Datei-Name ohne .md
                base_name = file[:-3]
                link_name = format_title(base_name)
                
                if rel_root == Path("."):
                    sub_items.append((0, None, base_name, link_name))
                else:
                    # In einem Unterordner
                    subfolder_name = rel_root.parts[0]
                    sub_items.append((1, subfolder_name, base_name, link_name))
        
        # Sortiere: Zuerst Dateien im Root des Kategorie-Ordners, dann Unterordner
        # Gruppierung nach Unterordner
        from collections import defaultdict
        grouped = defaultdict(list)
        for level, subfolder, base, link in sub_items:
            grouped[subfolder].append((base, link))
            
        # Zuerst die direkten Dateien
        for base, link in grouped[None]:
            sidebar_lines.append(f"  - [{link}]({base})")
            
        # Dann die Unterordner
        subfolders = [k for k in grouped.keys() if k is not None]
        for subfolder in sorted(subfolders):
            sidebar_lines.append(f"  - **{subfolder.replace('-', ' ')}**")
            for base, link in sorted(grouped[subfolder]):
                sidebar_lines.append(f"    - [{link}]({base})")

    # Footer
    sidebar_lines.append("\n---")
    sidebar_lines.append("[GitHub Repo](https://github.com/Jufie-bot/CC2-Mod-Sammlung)")

    # Schreibe die _Sidebar.md Datei
    sidebar_path = WIKI_DIR / "_Sidebar.md"
    with open(sidebar_path, "w", encoding="utf-8") as f:
        f.write("\n".join(sidebar_lines))
    
    print("[OK] _Sidebar.md wurde automatisch generiert!")

if __name__ == "__main__":
    generate_sidebar()
