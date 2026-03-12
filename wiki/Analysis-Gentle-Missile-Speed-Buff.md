# Detailanalyse: Gentle Missile Speed Buff Mod

## Übersicht
- **Mod-Name:** Gentle Missile Speed Buff
- **Kategorie:** Weapons
- **Dateien:** 
    - `content/game_objects/missile_2.xml` (IR Missile)
    - `content/game_objects/missile_4.xml` (Laser Missile)
    - `content/game_objects/missile_cruise.xml` (Cruise Missile)
    - `content/game_objects/missile_tv.xml` (TV Missile)

## Technische Analyse

### Mechanik
Wie der Name vermuten lässt, bietet diese Mod eine "sanftere" Erhöhung der Geschwindigkeiten im Vergleich zu extremeren Mods. Sie deckt jedoch eine breitere Palette von Raketentypen ab.

### Physik-Tweak
Die Mod nutzt die gleiche technische Grundlage wie die "2x Speed" Mod: Sie fügt einen expliziten `<body mass="1.0">` hinzu, wo Vanilla-Dateien leere Sektionen haben.

**Vergleich der Massen:**
- **Vanilla:** Undefiniert (nutzt Engine-Defaults).
- **Mod:** `1.0` für alle Raketentypen.

Durch die Reduktion der Masse bei gleichbleibender Schubkraft (`thruster`) erhöht sich die Beschleunigung (`a = F/m`).

### Unterschiede zu anderen Speed-Mods
Interessant ist der Vergleich der **Kollisionsboxen** (`<box>`) in der `missile_cruise.xml`:
- **2x Cruise Missile Speed Mod:** Nutzt eine Box-Größe von `0.35`.
- **Gentle Missile Speed Buff Mod:** Nutzt eine Box-Größe von `0.385`.

Die "Gentle"-Mod verwendet also leicht größere Kollisionsboxen. Dies könnte dazu dienen, die Trefferwahrscheinlichkeit bei höheren Geschwindigkeiten zu stabilisieren, da Projektile bei hoher Geschwindigkeit dazu neigen können, durch Objekte "hindurchzutunneln", wenn die Kollisionsprüfung zwischen zwei Frames stattfindet.

## Fazit
Eine umfassende Balance-Mod, die das gesamte Raketen-Arsenal beschleunigt. Sie folgt dem Standard-Muster der Massereduktion, achtet aber durch leicht angepasste Kollisionsboxen auf die Stabilität der Spielphysik.
