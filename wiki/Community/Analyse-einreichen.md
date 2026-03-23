---
title: Analyse einreichen
section: Community
status: Welle-1
---

# Analyse einreichen

Du hast eine CC2-Mod analysiert und möchtest dein Wissen mit der Community teilen? Super!

---

## Schritte

1. **GitHub Issue erstellen** mit dem Template "🔬 Forschungsaufgabe (Mod-Analyse)"
2. Label `research` + passendes `cat:*`-Label hinzufügen
3. Deine Analyse als Markdown schreiben (YAML-Frontmatter nicht vergessen: [[Code-Standards/YAML-Frontmatter]])
4. Pull Request öffnen mit der Analyse-Datei in `analysis/mods/[kategorie]/`

## Format der Analyse

Nutze die Vorlage in `sandbox/templates/` als Ausgangspunkt.

Pflichtabschnitte:
- **Was macht die Mod?** (kurze Beschreibung)
- **Veränderte Dateien** (welche XML/Lua-Dateien)
- **Code-Beispiele** (konkrete Parameter-Änderungen)
- **Fazit** (Erkenntnisse, Kompatibilitätsprobleme)

## Was danach passiert

Pull Requests werden geprüft. Bei Akzeptanz:
- Die Analyse erscheint in der Mod-Galerie
- Das zugehörige Issue wird auf "Abgeschlossen" gesetzt
- Du wirst als Autor in der Analyse-Datei verewigt
