import os

def generate_readme():
    workspace_path = os.getcwd()
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
        for root, dirs, files in os.walk(mods_path):
            if "mod.xml" in files:
                mod_count += 1
                rel_path = os.path.relpath(root, mods_path)
                category = rel_path.split(os.sep)[0]
                mod_name = os.path.basename(root)
                
                # Check if we already have a header for this category
                # (Simple approach: just list them all for now, better grouping could be done)
                # For now, let's just list the mod name and its category
                # content.append(f"- **{mod_name}** ({category})") 
                
    # Better approach: Iterate categories
    if os.path.exists(mods_path):
        categories = [d for d in os.listdir(mods_path) if os.path.isdir(os.path.join(mods_path, d))]
        for category in sorted(categories):
            content.append(f"### {category}")
            cat_path = os.path.join(mods_path, category)
            # Find mods in this category (could be nested)
            for root, dirs, files in os.walk(cat_path):
                if "mod.xml" in files:
                    mod_name = os.path.basename(root)
                    content.append(f"- {mod_name}")
            content.append("")

    content.append(f"\n**Gesamtanzahl Mods:** {mod_count}\n")
    
    content.append("## 🤝 Mitwirken\n")
    content.append("Bitte lies [CONTRIBUTING.md](CONTRIBUTING.md) und [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) bevor du Änderungen einreichst.\n")
    
    content.append("## 📜 Lizenz\n")
    content.append("Siehe [LICENSE](LICENSE) (falls vorhanden) für Details.\n")

    with open(readme_path, "w", encoding="utf-8") as f:
        f.write("\n".join(content))
    
    print(f"README.md regenerated with {mod_count} mods.")

if __name__ == "__main__":
    generate_readme()
