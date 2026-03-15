# 📟 CC2 Mod Development Hub

![Mods Total](https://img.shields.io/badge/Mods_Total-95-blue?style=for-the-badge&logo=github)
![Analyzed](https://img.shields.io/badge/Analysed-0-orange?style=for-the-badge&logo=bookstack)
![System_Version](https://img.shields.io/badge/Systemstruktur-v5.3-success?style=for-the-badge)

## 🎯 Die Vision: Dekonstruktion & Neuschöpfung
Willkommen im Herzen der Carrier Command 2 Modding-Forschung. Dieses Repository ist keine klassische Mod-Ablage, sondern ein echtes **technisches Labor**, das sich der vollständigen Dekonstruktion der Spielmechaniken verschrieben hat.

Unsere Mission: Wir belassen es nicht dabei, Mods einfach nur herunterzuladen und zu spielen. Wir zerlegen hunderte von existierenden Mods und Spieldateien (XML/Lua) bis auf die elementarste Ebene. Wir analysieren Parameter, testen Geschwindigkeitsvektoren und sezieren KI-Skripte. Unser absolutes Ziel ist es, Best-Practices zu etablieren, die **Grundlage für die nächste Generation von gigantischen Overhauls** zu schaffen und das absolute Maximum aus der Simulation herauszuholen.

## ⚙️ Wie wir arbeiten (Der Labor-Workflow)
Jede Modifikation, die unser Labor betritt, durchläuft einen strengen **Forschungs-Fließbandprozess**:
1. **Code lesen**: Wir analysieren den rohen XML/Lua-Code der Mod, um die Logik exakt zu verstehen.
2. **Referenz-Vergleich**: Die Mod wird gegen unsere Vanilla-Game-Referenzen geprüft, um die Änderungen zum Original herauszuarbeiten.
3. **Labor-Bericht**: Wir verfassen eine Deep-Dive Detailanalyse der Mod-Struktur und Parameter.
4. **Extraktion (Sandkasten)**: Nützliche Code-Snippets, Hooks und IDs werden in unseren Sandkasten extrahiert, um sofort für neue Bastel-Projekte wiederverwendet werden zu können.
5. **Wissens-Transfer**: Die finale Analyse fließt in unser zentrales Wiki-System ein, damit das gesamte Wissen persistent dokumentiert ist.

## 🏗️ System-Architektur (Masterpläne v5.3)
Dieses Labor basiert auf einer streng strukturierten Architektur. Diese vier internen Kontext-Dokumente bilden den **konzeptionellen Masterplan** für unsere Arbeitsweise:
1. 🏛️ [**00_SYSTEMSTRUKTUR.md**](00_SYSTEMSTRUKTUR.md) – Übersicht unserer 6 Säulen (Forschung, Wiki, Sandkasten, Eigene Mods, Community, Konfiguration).
2. 🏷️ [**01_BOARDS_UND_LABELS.md**](01_BOARDS_UND_LABELS.md) – Die feste Definition unseres GitHub-Projekt-Routings und der Fließbänder.
3. 📖 [**02_WIKI_STRUKTUR.md**](02_WIKI_STRUKTUR.md) – Architektur unseres 15-teiligen Wissens-Hubs.
4. 🚀 [**03_IMPLEMENTATION.md**](03_IMPLEMENTATION.md) – Der Arbeits- und Umbau-Plan des Labors.

## 🪣 Der Sandkasten (Unsere Werkbank)
Der **Sandkasten** (`sandbox/`) ist das operative Herzstück für Mod-Entwickler. Hier lagern wir alles, was man braucht, um eigene Kreationen zu formen:
- **Vanilla-Referenzen**: Die extrahierten Originaldateien des Spiels, katalogisiert nach Patch-Datum.
- **Snippets & IDs**: Tausende Objekt-IDs, komplexe LUA-Hook-Gerüste und Balance-Strings für die `constants.txt`, um blitzschnell Prototypen bauen zu können.
- **Templates**: Vorgefertigte Boilerplates für neue Mods, die unsere Best-Practices bereits integrieren.

## 🧠 Das Wiki: Ein 15-teiliges System, kein klassisches Wiki
Unser Wiki ist **keine lose Sammlung von Artikeln**! Vergiss klassische Wikis. Unser Wissens-Hub ist ein hochgradig durchdachtes, **15-teiliges System**, das als das primäre 'Hirn' des Projekts dient. Nur strukturierte, kuratierte und im Spiel getestete Informationen erhalten einen Platz.

Dort findest du unter anderem:
- **Theoretische Grenzen**: Was ist im Spiel überhaupt moddbar und was nicht?
- **Labor-Experimente**: Direkte Gegenüberstellungen, wenn mehrere Mods dasselbe Problem lösen.
- **Mod-Galerien**: Der Status-Bericht aller je von uns getesteten Mods.
- **Game-Referenzen**: Das extrem tiefe Nachschlagewerk zu allen XML-Dateien, Lua-Umgebungen und Physik-Vektoren.

👉 **[Betritt das offizielle CC2-Forschungs-Wiki](https://github.com/Jufie-bot/CC2-Mod-Sammlung/wiki)**

## 📂 Archivierte Sammlungen
Unser Labor verwaltet derzeit **95 verschiedene Modifikationen**, die als Grundlage für unsere Analysen dienen.

<details>
<summary><b>📂 Vollständiges Archiv anzeigen (Klicken zum Ausklappen)</b></summary>

#### Audio (18)
- AA & Depth Wolfenstein alarm
- Alarm Ahhh
- Apocalypse Sound Mod
- Arleigh Burke GQ Alarm
- Condition One Alarm
- Cyclops Alarm - Subnautica
- DramaticAlarmMod
- First Order Dreadnought Alarm
- Goofy lil sound mod (WIP)
- Highfleet sound replacer
- Klaxon Alarm
- Phalanx CIWS Gun Sound
- Skidders Pack
- Sound Enhancement
- Unit Death Wolfenstein alarm
- Wolfenstein Bridge Alarm
- alarm_unsc
- deep sound

#### Gameplay (29)
- 20mm Balance Test
- AGM-114
- AGM-65K
- AGM-X
- AIM-120
- AIM-9
- AI_Skynet
- Beginner Mod
- Blue Bridge Light
- Blue Camo Skin for Character
- Bot Head
- Droid Speed
- EagleEye Scouting Buff
- Enter the Life Raft
- GBU-27 Paveway III
- Higher Resolution Combined
- Higher Resolution Navigation
- Just A Few Hardpoints More
- Light Blue Water Color
- Lubricant
- R-60M
- RIM-161
- Rev_Auto Scout
- Rev_Engineering
- Rev_Heavy Manta
- Rev_Resupply+
- SKY TV
- Spread modifier
- logistics+

#### Kategorienübergreifende (1)
- Revolution 1.6-2

#### UI (8)
- AdvancedRadar
- FC Navy x UI Enhancer
- HUD Rate of Climb
- Higher Resolution Radar
- Radar Range 20km
- Rotate Power Screen
- Tactical Operations Centre 1.5
- UI Enhancer

#### Vehicles (26)
- 20mm Aircraft Wider Spread
- 2x Vehicle Water Speed
- 3x Vehicle Water Speed
- 5x Vehicle Water Speed
- Assault Barge
- Battle Carrier Refit + Captain Controls
- Callsigns for Vehicles
- Carrier CIWS Ammo Increase
- Combat Carrier
- Combat Carrier VLS
- Combat Carrier+Carrier Speed Change
- Luz's Naval Expansion Beta - 1.0.1
- Muffled Carrier Engine
- Mule 2
- Needlefish Mk2
- Quality of Life+ p2 - Blue Bridge Light, Repair Bay Terminals, Captain Controls, Carrier VLS, Lubricant
- Reused
- ST pod (v1.0)
- Ship Wakes
- Specialized Chassis UI
- Specialized Chassis V
- Starting Aircraft Altitude
- Utility
- Vanilla Friendly Barge Boost
- Vehicle IDs
- Walrus I am

#### Weapons (13)
- 15mm Turrets
- 2x Cruise Missile Speed
- Cement bomb
- Gentle Missile Speed Buff
- Island turret placement QoL
- Mark84 bomb
- Missile Reformat
- Naval Gun Stabilizer
- Salty's Missile Damage Edit
- Supersonic Cruise Missile
- Torpedo & Missile Wolfenstein alarm
- Torpedo Reformat
- Turret Utility

</details>

---

### 🛰️ Kontakt & Mitwirkung
- [Feedback oder Analyse-Wunsch](.github/ISSUE_TEMPLATE/bug_report.md)
- [Community Discord](https://discord.gg/example)
- [Entwickler-Portal](CONTRIBUTING.md)

*Letzte automatische Synchronisierung: 15.03.2026 | Status: ✔️ Online*