# Detailanalyse: Naval Gun Stabilizer Mod

## Übersicht
- **Mod-Name:** Naval Gun Stabilizer
- **Kategorie:** Weapons
- **Dateien:** `content/game_objects/vehicle_attachment_carrier_turret_main_gun.xml`

## Technische Analyse

### Mechanik
Die "Naval Gun Stabilizer" Mod verbessert die Präzision des Hauptgeschützes des Flugzeugträgers. Entgegen dem Namen wird kein physikalischer Stabilisator hinzugefügt, sondern die Streuung des Projektilauslasses (Muzzle) reduziert.

### Code-Vergleich: Präzisions-Tweak

In *Carrier Command 2* definiert der Wert `fov` (Field of View) bei einem `projectile_emitter` die Streuung der Schüsse. Ein niedrigerer Wert bedeutet höhere Genauigkeit.

**Vanilla (Original):**
```xml
<projectile_emitters>
    <projectile_emitter name="muzzle" fov="5.99999987e-02">
        <!-- ... -->
    </projectile_emitter>
</projectile_emitters>
```

**Mod-Version:**
Die Mod reduziert diesen Wert massiv (~66% weniger Streuung):
```xml
<projectile_emitters>
    <projectile_emitter name="muzzle" fov="1.99999987e-02">
        <!-- ... -->
    </projectile_emitter>
</projectile_emitters>
```

### Effekt im Spiel
Durch die Reduktion von `0.06` auf `0.02` wird der Streukreis des Geschützes auf Drittel des ursprünglichen Maßes verkleinert. Dies ermöglicht präzise Treffer auf große Distanzen, was besonders gegen kleine Ziele oder spezifische Subsysteme nützlich ist.

## Fazit
Eine einfache, aber sehr effektive Modifikation. Sie zeigt, wie durch das Anpassen eines einzelnen Attributs (`fov`) in der XML-Definition einer Waffe das Balancing und das "Gefühl" der Steuerung signifikant verändert werden kann.
