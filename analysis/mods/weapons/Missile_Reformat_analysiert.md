# Detailanalyse: Missile Reformat Mod

## Übersicht
- **Mod-Name:** Missile Reformat
- **Kategorie:** Weapons
- **Dateien:** 
    - `content/game_objects/missile_1.xml` bis `missile_5.xml`
    - `content/game_objects/missile_cruise.xml`
    - `content/game_objects/missile_tv.xml`

## Technische Analyse

### Mechanik
"Missile Reformat" ist eine der aggressivsten Speed-Mods für Raketen. Während andere Mods oft einen Einheitswert von `1.0` verwenden, nutzt diese Mod extrem niedrige Massenwerte bis hin zu `0.1`, um eine explosive Beschleunigung zu erzielen.

### Code-Vergleich: Physik-Tweaks

#### IR Raketen (`missile_1.xml`)
Hier ist der Eingriff am stärksten. Die Masse wird auf ein Zehntel des Niveaus anderer Speed-Mods gesenkt.

**Vanilla (Original):**
```xml
<data display_name="Missile 1" bounding_radius="2.00000000e+00" ai_type="0">
	<bodies/> <!-- Leer: nutzt Standard-Engine-Masse -->
</data>
```

**Mod-Version:**
```xml
<bodies>
    <body mass="0.10000000e+00" name="body" is_static="false">
        <!-- Massiv verringerte Masse für extreme Beschleunigung -->
    </body>
</bodies>
```

#### Schwere Raketen (`missile_5.xml`)
Bei schwereren Projektilen wie der Gimbale-Rakete (Missile 5) ist die Mod defensiver, aber immer noch schneller als Vanilla.

**Vanilla (Original):**
```xml
<body mass="1.00000000e+00" name="body" is_static="false">
```

**Mod-Version:**
```xml
<body mass="0.50000000e+00" name="body" is_static="false">
```

### Zusammenfassung der Massen-Werte
| Raketentyp | Vanilla (Standard) | Gentle Buff Mod | Missile Reformat |
| :--- | :--- | :--- | :--- |
| Cruise Missile | ~250.0 (est.) | 1.0 | 1.0 |
| IR Missile (1/2) | ~50.0 (est.) | 1.0 | **0.1** |
| Laser Missile (4) | ~50.0 (est.) | 1.0 | **0.1** |

## Fazit
Die "Missile Reformat" Mod bietet die höchste Beschleunigung für taktische Raketen im gesamten Mod-Pack. Durch die Reduzierung der Masse auf `0.1` reagieren die Projektile fast instand auf Kurskorrekturen und erreichen ihre Höchstgeschwindigkeit in Millisekunden. Dies macht sie extrem schwer abzufangen, kann aber bei sehr hohen Geschwindigkeiten zu physikalischen Artefakten (Clipping) führen.
