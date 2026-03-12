# Technische Referenz: Mod-Analysen
> [!NOTE]
> Diese Seite wird automatisch aus den Einzel-Analysen in `.github/` generiert.


## Übersicht
- **Mod-Name:** 15mm Turrets
- **Kategorie:** Weapons
- **Dateien:** `content/scripts/screen_vehicle_loadout.lua`

## Technische Analyse

### Mechanik
Die Mod ermöglicht es Spielern, 15mm-Geschütztürme auszurüsten, die im Basisspiel (Vanilla) zwar definiert, aber im Loadout-Menü versteckt sind. Dies wird durch eine kleine, aber entscheidende Änderung im UI-Skript erreicht.

### Code-Änderung in `screen_vehicle_loadout.lua`

**Vanilla-Code (Original):**
```lua
function get_selected_vehicle_attachment_options(attachment_type)
    -- ...
    for i = 0, option_count - 1 do
        local attachment_definition = update_get_attachment_option(attachment_type, i)

        if attachment_definition > -1 and update_get_attachment_option_hidden(attachment_definition) == false then
            local attachment_data = get_attachment_data_by_definition_index(attachment_definition)
            -- ...
        end
    end
    -- ...
end
```

**Mod-Code (Geändert):**
```lua
function get_selected_vehicle_attachment_options(attachment_type)
    -- ...
    for i = 0, option_count - 1 do
        local attachment_definition = update_get_attachment_option(attachment_type, i)

        if attachment_definition > -1 then -- Prüfung auf 'hidden' wurde entfernt
            local attachment_data = get_attachment_data_by_definition_index(attachment_definition)
            -- ...
        end
    end
    -- ...
end
```

### Zusammenfassung der Auswirkung
Durch das Entfernen des Checks `update_get_attachment_option_hidden(attachment_definition) == false` werden alle für einen Slot-Typ verfügbaren Attachments angezeigt, auch wenn sie in den Spieldaten als "versteckt" markiert sind. Da das 15mm-Geschütz im Spiel existiert, aber standardmäßig versteckt ist, wird es durch diese Änderung im Menü wählbar.

## Fazit
Eine sehr effiziente Modifikation, die bestehende Spielressourcen freischaltet, ohne neue Assets hinzufügen zu müssen. Sie demonstriert, wie die Spiel-Engine von Carrier Command 2 Filter für Inhalte nutzt, die durch einfache Skript-Overrides umgangen werden können.

---

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

---

## Übersicht
- **Mod-Name:** Cement bomb
- **Kategorie:** Weapons
- **Dateien:** `content/meshes/projectiles/projectiles/bomb_1.mesh`

## Technische Analyse

### Mechanik
Die "Cement bomb" Mod ist eine reine Asset-Replacement-Modifikation. Sie ändert weder die Physik noch die Schadenswerte oder die Logik der Bomben im Spiel.

### Analyse der Dateistruktur
Die Mod überschreibt die Binärdatei für das Modell:
`content/meshes/projectiles/projectiles/bomb_1.mesh`

### Besonderheiten
- **Keine XML-Änderungen:** Da keine XML-Datei (wie `bomb_1.xml`) mitgeliefert wird, bleiben die funktionalen Eigenschaften identisch mit Vanilla:
  ```xml
  <!-- Beispiel für eine unveränderte Eigenschaft in den Spieldaten -->
  <physics mass="250.0" drag="0.01" /> <!-- Werte bleiben Vanilla -->
  ```
- **Kompatibilität:** Die Mod ist mit allen Mods kompatibel, die keine Änderungen an `bomb_1.mesh` vornehmen.

## Fazit
Eine einfache kosmetische Modifikation, die zeigt, wie das Spiel durch das Überschreiben von Verzeichnispfaden in der `content/`-Struktur Assets austauscht.

---

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

---

## Übersicht
- **Mod-Name:** Island turret placement QoL
- **Kategorie:** Weapons
- **Dateien:** `content/scripts/screen_vehicle_control.lua`

## Technische Analyse

### Mechanik
Diese Mod verbessert die Benutzerfreundlichkeit (Quality of Life) bei der Verteidigung von Inseln. Sie ermöglicht es dem Spieler, die Produktion von Geschütztürmen direkt über die Kartenoberfläche abzubrechen, anstatt nur über das Menü des Command Centers.

### Code-Änderungen in `screen_vehicle_control.lua`

Die Mod fügt eine Logik hinzu, die beim Klicken auf einen Turm-Spawn-Punkt prüft, ob dort bereits ein Bauauftrag vorliegt. Falls ja, wird dieser abgebrochen.

**Vanilla-Verhalten (Auszug):**
```lua
-- In der Funktion, die Klicks auf Turm-Spawns verarbeitet
local marker_index, is_valid = island:get_turret_spawn(turret_spawn_index)
if is_valid then
    island:set_facility_add_production_queue_defense_item(item, marker_index)
    g_command_center_ui.is_place_turret = false
    g_command_center_ui.selected_item = -1
    g_selection:clear()
end
```

**Mod-Verhalten (Geändert):**
```lua
local marker_index, is_valid = island:get_turret_spawn(turret_spawn_index)
if is_valid then
    island:set_facility_add_production_queue_defense_item(item, marker_index)
else
    -- NEU: Wenn der Spot nicht valid ist (weil er belegt ist), 
    -- wird versucht, den Auftrag zu stornieren.
    local item_type_id, queue_index = get_island_turret_queue_number(island, marker_index)
    cancel_turret(island, queue_index)
end
```

### Neue Hilfsfunktionen
Die Mod führt mehrere neue Funktionen ein, um den Status der Turm-Queue zu verwalten und anzuzeigen:

1.  **`cancel_turret(island, turret_queue_index)`**: Ruft die Engine-Funktion zum Entfernen eines Queue-Items auf.
2.  **`get_island_turret_queue_number(island, marker_index)`**: Findet heraus, an welcher Position in der Warteschlange sich ein bestimmter Marker befindet.
3.  **`get_island_turret_progress(island, turret_spawn_index)`**: Berechnet den Fortschritt (Baut gerade, in Warteschlange, fertig oder leer).
4.  **`imgui_turret_button(...)`**: Eine neue UI-Komponente für die Darstellung der Turm-Optionen im Command Center.

## Fazit
Eine technisch ausgereifte Mod, die tief in das `screen_vehicle_control.lua` Skript eingreift. Sie nutzt geschickt vorhandene Marker-Daten, um die Interaktion mit der Spielwelt (Insel-Verteidigung) intuitiver zu gestalten.

---

## Übersicht
- **Mod-Name:** Mark84 bomb
- **Kategorie:** Weapons
- **Dateien:** `content/meshes/projectiles/projectiles/bomb_3.mesh`

## Technische Analyse

### Mechanik
Die "Mark84 bomb" Mod ist eine reine Asset-Replacement-Modifikation. Sie ersetzt das visuelle Modell der schweren Bombe (Bomb 3) durch ein Modell, das der realen Mark 84 Mehrzweckbombe nachempfunden ist.

### Analyse der Dateistruktur
Die Mod überschreibt die Datei:
`content/meshes/projectiles/projectiles/bomb_3.mesh`

Dies ist das Standard-Mesh für die schweren Bomben (Bomb 3) in *Carrier Command 2*. Da nur die `.mesh` Datei vorhanden ist, werden keine XML-Eigenschaften (wie Explosionsradius oder Masse) verändert.

### Code-Beispiel (Vanilla-Referenz)
Da die Mod keine XML-Dateien enthält, nutzt sie die Standardwerte aus der `bomb_3.xml` des Spiels. Ein Vergleich zeigt, dass die Logik unverändert bleibt:

**Vanilla/Mod Spiellogik (Identisch):**
```xml
<!-- Auszug aus der internen bomb_3.xml Definition -->
<projectile_definition explosion_magnitude="250.0" search_radius="10.0" />
<physics mass="500.0" drag="0.015" />
```

### Besonderheiten
- **Visueller Effekt:** Die Mark 84 ist in der Realität eine 2000-Pfund-Bombe. Das neue Modell verleiht der schweren Bombe im Spiel ein realistischeres Aussehen.
- **Kompatibilität:** Da keine Skripte oder XML-Dateien geändert werden, ist die Mod extrem stabil und mit allen Gameplay-Mods kompatibel, außer solchen, die ebenfalls `bomb_3.mesh` ersetzen.

## Fazit
Eine ästhetische Modifikation für Enthusiasten realistischer Militärtechnik. Sie demonstriert die einfache Austauschbarkeit von 3D-Modellen in *Carrier Command 2*.

---

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

---

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

---

## Übersicht
- **Mod-Name:** Salty's Missile Damage Edit
- **Kategorie:** Weapons
- **Dateien:** `content/scripts/constants.txt`

## Technische Analyse

### Mechanik
Diese Mod bietet eine subtile Balance-Änderung für das Raketen-Arsenal. Sie erhöht den Explosionsschaden von taktischen Raketen um genau 5%.

### Code-Vergleich: `constants.txt`

Die Mod nutzt die `constants.txt`, um globale Variablen der Spiel-Engine zu überschreiben. Dies ist eine sehr saubere und kompatible Methode des Moddings.

**Vanilla (Original):**
```text
missile_1_explosion_damage_scale 1.0
missile_2_explosion_damage_scale 1.0
missile_tv_explosion_damage_scale 1.0
```

**Mod-Version:**
```text
missile_1_explosion_damage_scale 1.05
missile_2_explosion_damage_scale 1.05
missile_tv_explosion_damage_scale 1.05
```

### Analyse der betroffenen Einheiten
- **Missile 1 (IR):** Profitiert von der Erhöhung, was besonders gegen leicht gepanzerte Ziele einen Unterschied machen kann.
- **Missile 2 (Laser):** Erhält ebenfalls den 5% Buff.
- **TV Missile:** Die ferngesteuerte Rakete wird leicht schlagkräftiger.

Interessanterweise bleibt die `missile_5_explosion_damage_scale` (Gimbale/Schwere Rakete) auf `1.0` (Vanilla), was darauf hindeutet, dass der Autor nur die leichteren, taktischen Raketen stärken wollte.

## Fazit
Eine minimale, aber präzise Modifikation. Sie ist ein perfektes Beispiel für "Data-Only" Modding, das keine Skripte verändert und somit maximale Kompatibilität mit anderen Mods (wie z.B. Speed-Mods) gewährleistet.

---

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

---

## Übersicht
- **Mod-Name:** Torpedo & Missile Wolfenstein alarm
- **Kategorie:** Weapons / Audio
- **Dateien:** `content/audio/telemetry07.ogg`

## Technische Analyse

### Mechanik
Diese Mod ist eine reine Audio-Modifikation. Sie ändert keine Spiellogik, sondern ersetzt lediglich ein Sound-Asset durch ein anderes.

### Analyse der Dateistruktur
Die Mod überschreibt die Datei:
`content/audio/telemetry07.ogg`

In *Carrier Command 2* ist dies der Sound-Effekt für den Alarm bei anfliegenden Raketen oder Torpedos. Durch das Ersetzen dieser Datei wird der Standard-Piepton durch einen atmosphärischeren Alarm ersetzt, der an klassische Militärsimulatoren oder Spiele erinnert (Referenz: Wolfenstein).

### Code-Beispiel (Referenz)
Da es sich um ein reines Asset-Replacement handelt, gibt es keine Code-Änderungen in XML- oder Lua-Dateien. Das Spiel lädt die Datei dynamisch aus dem Mod-Ordner, da der Pfad in der `content`-Struktur identisch mit dem des Hauptspiels ist.

### Besonderheiten
- **Kompatibilität:** Da keine Skripte oder XML-Dateien betroffen sind, ist diese Mod zu 100% mit allen Gameplay-Mods kompatibel. Es kann jedoch nur eine Mod gleichzeitig den `telemetry07.ogg` Sound ändern.
- **Audio-Format:** Die Datei liegt im `.ogg` (Vorbis) Format vor, was dem Standard von CC2 entspricht.

## Fazit
Eine einfache, aber atmosphärische Modifikation für die akustische Rückmeldung im Spiel. Sie zeigt, wie leicht Audio-Assets durch das Einhalten der Ordnerstruktur ausgetauscht werden können.

---

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

---

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

---
