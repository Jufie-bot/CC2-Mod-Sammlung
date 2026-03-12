# Projekt-Entwicklung & Workspace Übersicht

Eine chronologische Reise durch die Evolution der **CC2 Mod-Sammlung**.

## 1. Ursprung & Initialisierung
Das Projekt begann als einfache Sammlung von Modifikationen ("Mod Sammlung") ohne klare Struktur.
*   **Initiale Phase:** Manuelles Sammeln von Mods.
*   **Herausforderung:** Fehlende Übersicht über Kompatibilitäten und technische Details.

## 2. Strukturierung & Kategorisierung
Um der wachsenden Anzahl von Mods Herr zu werden, wurde eine strikte Ordnerstruktur eingeführt:
*   `mods/Audio/`
*   `mods/Gameplay/`
*   `mods/Overhauls/` (Komplexe Mods wie Revolution)
*   `mods/UI/`
*   `mods/Vehicles/`
*   `mods/Weapons/`

Diese Umstrukturierung ermöglichte automatisierte Prozesse, da Skripte nun genau wissen, wo sie nach validen Mods suchen müssen.

## 3. Automatisierung (CI/CD)
Ein großer Meilenstein war die Einführung von **GitHub Actions**.
*   **Code-Validierung:** Automatische Prüfung auf XML-Syntaxfehler.
*   **Dokumentations-Sync:** Automatische Aktualisierung der `README.md` basierend auf den vorhandenen Mods.
*   **Wiki-Sync:** Automatische Spiegelung der Dokumentation ins GitHub Wiki.

## 4. Technische Tiefenanalyse ("The Breakdown")
Die vielleicht wichtigste Phase war die technische Analyse der Spielmechaniken.
*   **Discovery:** Entdeckung, dass `constants.txt` (Schaden, HP, Produktion) veränderbar ist – entgegen der offiziellen Dokumentation.
*   **Reverse Engineering:** Analyse von Lua-Funktionen (`update_world_to_screen`) durch Untersuchung existierender Mods (HSAR Vehicle IDs).

## 5. Der aktuelle Workspace
Der Workspace ist heute eine hybride Umgebung aus:
1.  **Mod-Repository:** Eine kuratierte Sammlung von ~140 Mods.
2.  **Wissens-Datenbank:** Ein vollständiges lokales Wiki (`.github/*.md`).
3.  **Entwicklungsumgebung:** Integrierte Tools (`constants.txt` Analyse) für neue Mods.

### Status Quo
*   **Aktive Mods:** >100
*   **Dokumentations-Level:** 100% (Alle Mods technisch erfasst)
*   **Automatisierungs-Grad:** Hoch (Auto-Readme, Auto-Wiki)
