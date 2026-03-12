# Detailanalyse: Turret Utility Mod

## Übersicht
- **Mod-Name:** Turret Utility
- **Kategorie:** Weapons
- **Dateien:** `content/game_objects/stationary_turret.xml`

## Technische Analyse

### Mechanik
Diese Mod erweitert die Hardware-Fähigkeiten der stationären Insel-Türme. Im Standardspiel sind diese Türme rein auf ihre Hauptbewaffnung beschränkt. Die Mod fügt zusätzliche "Attachment Slots" hinzu, was es ermöglicht, die Türme mit Hilfssystemen auszustatten.

### Code-Vergleich: `stationary_turret.xml`

In *Carrier Command 2* werden verfügbare Ausrüstungsslots über die `<attachments>` Sektion in der XML des Objekts definiert.

**Vanilla (Original):**
```xml
<attachments>
    <!-- Slot für das Hauptgeschütz (z.B. 30mm Turret) -->
    <attachment name="attachment" type="5">
        <transform ... />
    </attachment>
</attachments>
```

**Mod-Version:**
Die Mod fügt zwei neue Slots hinzu:
```xml
<attachments>
    <attachment name="attachment" type="5"> <!-- Hauptgeschütz -->
        <transform ... />
    </attachment>
    
    <!-- NEU: Kamera/Sensor Slot -->
    <attachment name="attachment" type="0">
        <transform ... />
    </attachment>
    
    <!-- NEU: Utility/Defense Slot -->
    <attachment name="attachment" type="2">
        <transform ... />
    </attachment>
</attachments>
```

### Funktionalität der neuen Slots
- **Type 0 (Camera/Sensor):** Erlaubt das Anbringen eines Gimbale-Sensors oder einer Kamera. Dadurch können stationäre Türme als Fernbeobachtungspunkte genutzt werden, was die Aufklärung auf Inseln massiv verbessert.
- **Type 2 (Utility):** Ermöglicht das Anbringen von Systemen wie Flare-Launchern. Dies erhöht die Überlebensfähigkeit der Türme gegen Raketenangriffe erheblich.

## Fazit
Eine exzellente Erweiterung für das Insel-Verteidigungs-Gameplay. Technisch gesehen ist es ein einfacher, aber wirkungsvoller Eingriff in die Objekt-Struktur. Durch das Hinzufügen von nur zwei Zeilen XML-Code wird die taktische Tiefe der stationären Verteidigung vervielfacht.
