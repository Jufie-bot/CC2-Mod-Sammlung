---
title: YAML-Frontmatter Standard
section: Code-Standards
status: Welle-1
game-version: 2026-03
---

# YAML-Frontmatter Standard

Jede Analyse-Datei in `analysis/` beginnt mit einem YAML-Frontmatter-Block. Dieser verknüpft die Datei mit GitHub Issues und liefert Metadaten für die Automatisierung.

---

## Pflichtfelder

```yaml
---
title: "Name der Mod"
category: weapons       # audio|ui|gameplay|weapons|vehicles|kategorienuebergreifend|ki
game-version: 2026-03   # Datum des Spielstands zum Analysezeitpunkt
status: in-progress     # draft|in-progress|complete|wiki-ready
issue-id: 42            # Nummer des zugehörigen GitHub Issues
---
```

## Warum nicht als Label?

- `game-version` würde nach jedem Spiel-Update veralten — dann müssten alle Issues neu gelabelt werden
- `issue-id` ist eine 1:1-Verbindung — kein Label-System sinnvoll

## Vollständiges Beispiel

```yaml
---
title: "15mm Turrets"
category: weapons
game-version: 2026-03
status: wiki-ready
issue-id: 7
level: deep-dive
author: julian
analysiert-am: 2026-03-01
---
```

> **Hinweis:** Nach diesem Standard werden Analysen von `sync_docs.py` korrekt ins Wiki übertragen.
