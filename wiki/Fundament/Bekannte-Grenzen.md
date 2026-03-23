---
title: Bekannte Grenzen des Moddings
section: Fundament
status: Welle-1
game-version: 2026-03
---

# Bekannte Grenzen des CC2-Moddings

Diese Seite dokumentiert, was in CC2 **nicht** modbar ist. Genauso wichtig wie das Mögliche.

---

## Absolute Grenzen (Engine-Level)

| Nicht modbar | Grund |
|:---|:---|
| Neue 3D-Assets / Modelle | Engine lädt nur vorhandene Meshes. Kein Asset-Import. |
| Neue Texturen | Gleiches Prinzip — nur Override bestehender Texturen möglich. |
| Neue Spielmechaniken | Keine Engine-API. Nur Parameterwerte änderbar. |
| Neue Einheitentypen | Einheiten-IDs sind hardcoded. |
| Netzwerk-Code | Multiplayer-Logik ist nicht zugänglich. |

## Eingeschränkt modbar

| Eingeschränkt | Was geht | Was nicht geht |
|:---|:---|:---|
| KI-Verhalten | `constants.txt` Parameter (Aggression, Reichweite) | Entscheidungslogik der KI |
| Physik | Masse, Schub, Damage-Scaling | Physik-Engine selbst |
| Audio | Sound-Dateien ersetzen | Neue Trigger-Events hinzufügen |
| Lua-Scripte | Vollständiger Zugang via `library_custom_*` | Nur was Hooks exponieren |

## Das "Last one wins"-Prinzip

Wenn zwei Mods dieselbe Datei überschreiben, gewinnt die **zuletzt geladene** Mod. Das führt zu Kompatibilitätsproblemen. Lösung: Minimale Overrides, nur was nötig ist ändern.

> Siehe auch: [[Code-Standards/Allgemeine-Regeln]] und [[Code-Standards/YAML-Frontmatter]]
