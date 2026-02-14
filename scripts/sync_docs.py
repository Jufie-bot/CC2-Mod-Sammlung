import os
import re

def generate_readme():
    workspace_path = r"f:\Workspace\Mod sammlung"
    readme_path = os.path.join(workspace_path, "README.md")
    handbuch_path = os.path.join(workspace_path, "Technisches_Entwickler_Handbuch.md")
    kategorien_path = os.path.join(workspace_path, "Mod_Kategorien_Liste.md")

    content = []
    content.append("# Carrier Command 2 - Mod-Sammlung\n")
    content.append("Herzlich willkommen in der zentralen Mod-Sammlung für Carrier Command 2. Dieses Repository dient als technische Referenz und Übersicht über ein umfangreiches Set an XML- und Lua-Modifikationen.\n")
    
    content.append("## 📊 Projekt-Übersicht\n")
    
    # Analyze directory for count
    items = os.listdir(workspace_path)
    mod_count = len([d for d in items if os.path.isdir(os.path.join(workspace_path, d)) and not d.startswith('.')])
    
    content.append(f"- **Anzahl der Mods:** {mod_count}")
    content.append("- **Fokus:** XML-Tuning, Lua-Scripting, Audio-Assets")
    content.append("- **Framework:** [Revolution 1.6-2](f:/Workspace/Mod%20sammlung/Revolution%201.6-2)\n")

    content.append("## 🛠️ Wichtige Dokumentation\n")
    content.append("- [Technisches Entwickler-Handbuch](Technisches_Entwickler_Handbuch.md): Detaillierte Analyse jeder Mod.")
    content.append("- [Entwickler-Standards](Entwickler_Standards.md): Best Practices für CC2-Modding.")
    content.append("- [Mod-Kategorien-Liste](Mod_Kategorien_Liste.md): Thematische Einordnung.\n")

    content.append("## 📂 Mod-Kategorien (Auszug)\n")
    if os.path.exists(kategorien_path):
        with open(kategorien_path, 'r', encoding='utf-8') as f:
            k_lines = f.readlines()
            for line in k_lines:
                if line.startswith("## "):
                    content.append(line.strip())
                elif line.startswith("*   **"):
                    content.append(line.strip())
    
    content.append("\n---\n")
    content.append("*Automatisches Update generiert via `sync_docs.py`.*")

    with open(readme_path, 'w', encoding='utf-8') as f:
        f.write("\n".join(content))
    
    print(f"README.md erfolgreich erstellt in {readme_path}")

if __name__ == "__main__":
    generate_readme()
