import os

def generate_readme():
    # Script is in scripts/, so root is ../
    script_dir = os.path.dirname(os.path.abspath(__file__))
    workspace_path = os.path.abspath(os.path.join(script_dir, "../"))
    
    print(f"DEBUG: Workspace Path erkannt als: {workspace_path}")

    readme_path = os.path.join(workspace_path, "README.md")
    
    content = []
    content.append("# Carrier Command 2 - Mod Sammlung 🛠️\n")
    content.append("![Version](https://img.shields.io/badge/version-4.0.0-blue?style=for-the-badge)")
    content.append("![License](https://img.shields.io/badge/license-MIT-green?style=for-the-badge)")
    content.append("![Status](https://img.shields.io/badge/status-active-success?style=for-the-badge)")
    content.append("![Discord](https://img.shields.io/badge/discord-join-5865F2?style=for-the-badge&logo=discord&logoColor=white)\n")
    
    content.append("Eine umfangreiche Sammlung von Mods, Verbesserungen und Skripten für Carrier Command 2.")
    content.append("Diese Sammlung zielt darauf ab, das Gameplay durch Audio-, Visuelle- und Balance-Anpassungen zu optimieren.\n")
    
    content.append("## 📂 Kategorien\n")
    content.append("Die Mods sind in folgende Kategorien unterteilt:\n")
    
    mods_path = os.path.join(workspace_path, "mods")
    mod_count = 0
    
    if os.path.exists(mods_path):
        # List categories (first level directories)
        categories = sorted([d for d in os.listdir(mods_path) if os.path.isdir(os.path.join(mods_path, d))])
        
        for category in categories:
            cat_header_added = False
            cat_path = os.path.join(mods_path, category)
            
            # Find mods in this category (recursive)
            for root, dirs, files in os.walk(cat_path):
                if "mod.xml" in files:
                    if not cat_header_added:
                        content.append(f"### {category}")
                        cat_header_added = True
                    
                    mod_name = os.path.basename(root)
                    # Optional: Read mod name from mod.xml if possible, but folder name is fine
                    content.append(f"- {mod_name}")
                    mod_count += 1
            
            if cat_header_added:
                content.append("")

    content.append(f"\n**Gesamtanzahl Mods:** {mod_count}\n")
    
    content.append("## 🤝 Mitwirken\n")
    content.append("Bitte lies [CONTRIBUTING.md](CONTRIBUTING.md) und [GOVERNANCE.md](GOVERNANCE.md) bevor du Änderungen einreichst.\n")
    content.append("## 📜 Lizenz\n")
    content.append("Siehe [LICENSE](LICENSE) (falls vorhanden) für Details.\n")
    
    content.append("---\n")
    content.append("*Automatisch generiert via `scripts/sync_docs.py`.*")

    with open(readme_path, "w", encoding="utf-8") as f:
        f.write("\n".join(content))
    
    print(f"README.md erfolgreich erstellt in {readme_path} mit {mod_count} Mods.")

if __name__ == "__main__":
    generate_readme()
