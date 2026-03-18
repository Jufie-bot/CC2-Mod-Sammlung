# Detailanalyse: Torpedo Reformat Mod

## Übersicht
- **Mod-Name:** Torpedo Reformat
- **Kategorie:** Weapons
- **Dateien:** 
    - `content/game_objects/torpedo.xml`
    - `content/game_objects/torpedo_decoy.xml`
    - `content/game_objects/torpedo_noisemaker.xml`
    - `content/game_objects/torpedo_sonar_buoy.xml`

## Technische Analyse

### Mechanik
Ähnlich wie die "Missile Reformat" Mod, zielt diese Modifikation darauf ab, die Leistung von Unterwasser-Projektilen durch physikalische Eingriffe zu verbessern. Der Fokus liegt hierbei auf der Beschleunigung und Manövrierfähigkeit unter Wasser.

### Code-Vergleich: Physik-Tweak in `torpedo.xml`

Die Mod fügt explizite Körperdefinitionen hinzu, um die standardmäßigen (und oft trägen) Unterwasser-Physikeigenschaften der Engine zu umgehen.

**Vanilla (Original):**
```xml
<data display_name="Bomb 1" bounding_radius="1.00000000e+00" lod_scale="1.00000000e+00" ai_type="0">
	<bodies/> <!-- Leer: nutzt Standardwerte für Wasserwiderstand und Masse -->
</data>
```

**Mod-Version:**
```xml
<bodies>
    <body mass="1.00000000e+00" name="body" is_static="false">
        <boxes>
            <box>
                <size x="3.50000000e-01" y="3.50000000e+00" z="3.50000000e-01"/>
            </box>
        </boxes>
    </body>
</bodies>
```

### Auswirkungen auf Untersysteme
Die Mod beschränkt sich nicht nur auf den Standard-Torpedo, sondern passt auch Hilfssysteme an:
- **Decoys & Noisemakers:** Durch die Massereduzierung auf `1.0` können diese Gegenstände schneller ausgestoßen werden und nehmen schneller ihre Position im Wasser ein, was die Verteidigungsfähigkeit des Trägers gegen feindliche Torpedos verbessert.
- **Sonar Buoys:** Die Bojen erreichen schneller ihre Zieltiefe/Position.

## Fazit
Eine umfassende Überarbeitung der Unterwasser-Waffensysteme. Durch die Angleichung der Massenwerte auf `1.0` fühlen sich Torpedos deutlich reaktionsschneller an und leiden weniger unter der oft simulierten "Trägheit" des Wassers in der Physik-Engine. Dies ist eine essentielle Mod für Spieler, die eine direktere Kontrolle über ihre Marine-Bewaffnung bevorzugen.
