# Detailanalyse: Supersonic Cruise Missile Mod

## Übersicht
- **Mod-Name:** Supersonic Cruise Missile
- **Kategorie:** Weapons
- **Dateien:** `content/game_objects/missile_cruise.xml`

## Technische Analyse

### Mechanik
Dies ist die extremste Variante der Cruise-Missile-Geschwindigkeits-Mods. Sie zielt darauf ab, die Rakete so schnell wie möglich zu machen, während sie gerade noch innerhalb der physikalischen Grenzen des Spiels funktioniert.

### Code-Vergleich: Physik-Tweak

Wie bei der "2x Speed" Mod wird die Masse auf `1.0` gesetzt. Der entscheidende Unterschied liegt jedoch in der Größe der Kollisionsbox (`<box>`).

**Vanilla (Original):**
```xml
<bodies/> <!-- Nutzt Engine-Standardwerte -->
```

**Supersonic Mod-Version:**
```xml
<bodies>
    <body mass="1.00000000e+00" name="body" is_static="false">
        <boxes>
            <box>
                <size x="2.50000000e-01" y="2.50000000e+00" z="2.50000000e-01"/>
            </box>
        </boxes>
    </body>
</bodies>
```

### Vergleich der Cruise-Missile-Mods
| Mod | Masse | Box-Größe (x/z) | Fokus |
| :--- | :--- | :--- | :--- |
| Gentle Missile Speed Buff | 1.0 | 0.385 | Stabilität & Trefferrate |
| 2x Cruise Missile Speed | 1.0 | 0.350 | Balance |
| **Supersonic Cruise Missile** | **1.0** | **0.250** | **Maximale Geschwindigkeit** |

### Analyse der Auswirkungen
Durch die Reduktion der Kollisionsbox auf `0.25` (ca. 35% kleiner als bei der Gentle-Mod) verringert die Mod das Risiko, dass die Rakete bei extrem hohen Geschwindigkeiten durch "Ghost-Kollisionen" mit der eigenen Abschussrampe oder nahen Objekten explodiert. Zudem ermöglicht die geringe Größe ein noch engeres Vorbeifliegen an Hindernissen.

## Fazit
Die "Supersonic" Mod reizt die Engine von *Carrier Command 2* bis zum Äußersten aus. Sie kombiniert die bewährte Massereduktion mit einer aggressiven Verkleinerung der Hitbox. Dies ist die Wahl für Spieler, die Raketen wollen, denen man kaum ausweichen kann, allerdings auf Kosten der visuellen Konsistenz bei der Kollision (die Rakete muss "näher" am Ziel sein, um zu explodieren).
