# Detailanalyse: 2x Cruise Missile Speed Mod

## Übersicht
- **Mod-Name:** 2x Cruise Missile Speed
- **Kategorie:** Weapons
- **Dateien:** `content/game_objects/missile_cruise.xml`

## Technische Analyse

### Mechanik
Die Mod erhöht die Geschwindigkeit von Marschflugkörpern (Cruise Missiles) von ca. 78 m/s auf 139 m/s (Faktor ~1,78x). Dies wird nicht durch eine direkt Geschwindigkeitsvariable erreicht, sondern durch einen Eingriff in die Physik-Definition des Objekts.

### Physik-Tweak in `missile_cruise.xml`

**Vanilla (Original):**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<data display_name="Cruise Missile" bounding_radius="2.50000000e+00" ai_type="0">
	<bodies/>
	<constraints/>
    <!-- ... meshes, lights, etc. ... -->
</data>
```

**Mod-Version:**
Die Mod fügt eine explizite Körperdefinition hinzu, um die Masse zu kontrollieren:

```xml
<bodies>
    <body mass="1.00000000e+00" name="body" is_static="false">
        <transform m00="1.00000000e-01" m01="0.00000000e+00" m02="0.00000000e+00" m10="0.00000000e+00" m11="1.00000000e+00" m12="0.00000000e+00" m20="0.00000000e+00" m21="0.00000000e+00" m22="1.00000000e+00" tx="0.00000000e+00" ty="0.00000000e+00" tz="0.00000000e+00"/>
        <boxes>
            <box>
                <size x="3.50000000e-01" y="3.50000000e+00" z="3.50000000e-01"/>
            </box>
        </boxes>
    </body>
</bodies>
```

### Funktionsweise
1.  **Masse-Reduktion:** Durch das Setzen der Masse auf `1.0` (ein sehr niedriger Wert im Vergleich zu den Standardwerten der Engine für solche Objekte) wird die Beschleunigung massiv erhöht.
2.  **F = m * a:** Da die Schubkraft (`thruster`) des Triebwerks in den Spieldaten gleich bleibt, führt eine geringere Masse (`m`) zu einer deutlich höheren Beschleunigung (`a`).
3.  **Gleichgewicht:** Das Projektil erreicht schneller seine Endgeschwindigkeit, die durch den Luftwiderstand und die Schubkraft begrenzt wird. 

### Wichtige Erkenntnis
Der Autor merkt an, dass 139 m/s die "absolute Höchstgeschwindigkeit" ist, bei der die Zielgenauigkeit (Pinpoint Accuracy) noch erhalten bleibt. Höhere Geschwindigkeiten würden vermutlich dazu führen, dass die KI-Steuerung des Marschflugkörpers übersteuert oder das Ziel aufgrund der hohen Geschwindigkeit verfehlt.

## Fazit
Die Mod nutzt das physikalische Prinzip der Massereduzierung, um die Leistung von Waffen zu steigern. Dies ist eine saubere Methode, da sie keine Skripte benötigt und direkt die Engine-Physik anspricht.
