# Mod-Sammlung: Code Detail-Analyse & Dokumentation

> **Status:** Work in Progress
> **Erstellt am:** 14.02.2026
> **Zweck:** Technische Dokumentation aller Mods für Entwickler und Maintainer.

---

---

## 1. Praxis-Beispiele: Wie Mods funktionieren

Um die Theorie greifbarer zu machen, analysieren wir hier zwei konkrete Code-Beispiele aus der Sammlung. Wir vergleichen die Mod-Dateien mit dem Standard-Verhalten.

### Beispiel A: Fahrzeug-Definition (`Mule 2`)

Die Datei `vehicle_chassis_wheel_mule.xml` definiert das physische Modell und die Eigenschaften des Mule-Chassis.

**Auszug aus der XML:**
```xml
<!-- Definition der Räder: Grip, Dämpfung und Position -->
<wheel steerable="true" 
       steering_magnitude="1.0" 
       stiffness="10.0" 
       damping="100.0" 
       suspension_length="0.65" 
       grip="100.0" 
       radius="0.575" 
       name="wheel_front_left">
    <pos x="-1.625" y="-0.60" z="2.645"/>
</wheel>

<!-- Definition von Waffen-Slots (Attachments) -->
<attachment name="attachment_front_left" type="7"> <!-- Typ 7 = Light Weapon z.B. Virus Bot -->
    <transform ... tx="-0.56" ty="0.68" tz="1.35"/>
</attachment>
```

**Was macht der Mod anders?**
- **Mehr Räder:** Der Standard-Mule hat 6 Räder. Dieser Mod definiert zusätzliche `<wheel>` Einträge für die mittleren Achsen, was die Geländegängigkeit erhöht.
- **Feste Waffen:** Der Mod integriert `air_defence_missile_stand` direkt in das Chassis-Mesh (`<mesh>`), anstatt es als optionales Attachment zu definieren. Das macht das Fahrzeug standardmäßig zu einer mobilen Flugabwehr.

### Beispiel B: UI-Logik (`UI Enhancer`)

Die Datei `screen_radar.lua` steuert das Radar-Verhalten. Der UI Enhancer ersetzt das simple Standard-Radar durch ein mehrschichtiges System.

**Auszug aus der Lua-Datei:**
```lua
-- Konfiguration für Multi-Layer Scan
g_scan_layer_count = 4 
g_layer_colors = { 
    color8(255, 0, 0, 255),   -- Rot (Layer 1)
    color8(255, 255, 0, 255), -- Gelb (Layer 2)
    color8(0, 255, 0, 255),   -- Grün (Layer 3)
    color8(0, 0, 255, 255),   -- Blau (Layer 4)
}

function update(screen_w, screen_h, ticks) 
    -- ...
    -- Scan-Logik: Raycast auf verschiedenen Höhen (-0.02 * i)
    for i=1, g_scan_layer_count do
        -- get_carrier_raycast ist eine interne Engine-Funktion
        local depth = this_vehicle_object:get_carrier_raycast(scan_angle, -0.02 * i)
        
        -- Speichern der Tiefe für das Rendering
        g_depth_data[i][g_scan_cursor].depth = math.min(g_max_scan_distance, depth)
    end
    -- ...
end
```

**Analyse:**
- **Raycasting:** Statt nur auf einer Ebene zu scannen (Vanilla), führt der Mod 4 Raycasts auf unterschiedlichen Höhen durch (`-0.02 * i`).
- **Visualisierung:** Die Ergebnisse werden in `g_depth_data` gespeichert und später als Dreiecke in verschiedenen Farben (`g_layer_colors`) gezeichnet. Das erlaubt dem Spieler, Hindernisse besser in der Tiefe einzuschätzen.

---

---

## 2. Gameplay Mods

> [!TIP]
> Weitere Code-Beispiele für Gameplay-Balancing (Schaden, HP) findest du in der separaten **[Game Constants Analyse](Game_Constants_Analyse.md)**.

### **20mm Balance Test (Autor: N/A)**
*   **Beschreibung:** Test-Mod für Schadenswerte.
*   **Code-Analyse:**
    *   **Datei:** `vehicle_attachment_turret_ciws.xml`
    *   **Änderung:** Erhöht den `projectile_emitter` FOV massiv auf ~57°, was die Waffe in eine Schrotflinte verwandelt.
    *   **Datei:** `vehicle_attachment_turret_plane_chaingun.xml`
    *   **Änderung:** Setzt FOV auf 0 für perfekte Präzision.
*   **Verbesserungsidee:** Nutzen der `constants.txt` für Schadensanpassung statt FOV-Hacks.

### **Just A Few Hardpoints More (Autor: N/A)**
*   **Beschreibung:** Fügt Fahrzeugen mehr Slots hinzu.
*   **Code-Analyse:**
    *   **Datei:** `vehicle_chassis_wheel_medium.xml` (Bear)
    *   **Änderung:** Fügt `missile_1` und `missile_2` als Typ 3 (Raketen) Attachments hinzu.
    *   **Position:** Leicht versetzt (`ty="0.52"`) am Chassis.
*   **Verbesserungsidee:** Gewichtsbeschränkung pro Slot für Balancing.

### **Spread modifier (Autor: Ribbons)**
*   **Beschreibung:** Ändert die Streuung von Geschützen.
*   **Code-Analyse:**
    *   **Datei:** `vehicle_attachment_turret_30mm.xml`
    *   **Änderung:** `fov` von `0.04` (~2.3°) auf `0.02` (~1.15°) reduziert.
*   **Verbesserungsidee:** Realistischer Rückstoß-Offset per Skript.

### **AGM-114 / AGM-65K / AGM-X / AIM-120**
*   **Typ:** Visual Replacement
*   **Code-Analyse:**
    *   Keine XML/Lua-Änderungen.
    *   Enthält nur `.mesh` Dateien in `content/meshes`.
    *   Ersetzt das Standard-Modell der Raketen rein optisch.

### **Rev_Auto Scout (Autor: Bredroll)**
*   **Beschreibung:** Automatisches Aufklären durch Flugzeuge.
*   **Code-Analyse:**
    *   **Datei:** `library_custom_0.lua`
    *   **Technik:** Hook in `get_is_visible_by_modded_radar`.
    *   **Logik:** Wenn Kamera-Flugzeug < 4.5km zum Ziel -> Sichtbar.
    *   **Abhängigkeit:** Mod "Revolution" Framework.

### **Rev_Engineering (Autor: Bredroll)**
*   **Beschreibung:** Crafting/Upgrade-System für Einheiten.
*   **Code-Analyse:**
    *   **Datei:** `library_custom_1.lua`
    *   **Technik:** UI-Injection in Loadout-Screen.
    *   **Logik:** Definiert "Rezepte" (`g_revolution_crafting_items`). Beispiel: "Specops Petrel" kostet 1x Fuel, 1x Virus Module. Ändert dynamisch die `attachment_options` des Vehikels.

### **Rev_Heavy Manta (Autor: Bredroll)**
*   **Beschreibung:** Erweitertes Loadout für Manta.
*   **Code-Analyse:**
    *   **Datei:** `library_custom_1.lua`
    *   **Technik:** Override der Hardpoint-Definitionen (`g_revolution_override_attachment_options`).
    *   **Logik:** Definiert neue Rows/Slots für `chassis_air_wing_heavy`. Nutzt eine Whitelist (`g_std_wing_attachments`) für erlaubte Waffen.

### **AI_Skynet (Autor: N/A)**
*   **Beschreibung:** Aggressive, eskalierende KI.
*   **Code-Analyse:**
    *   **Datei:** `library_custom_3.lua`
    *   **Technik:** Hook in `update()` via `skynet_begin_load()`.
    *   **Logik:**
        *   Berechnet "Bedrohungslevel" basierend auf Spieler-Inseln.
        *   Spawnt Angriffswellen (Schiffe, Air, Land).
        *   Nutzt Taktiken: "Encircle" (Einkreisen), "Ambush" (Hinterhalt).
        *   Rekrutiert "neutrale" Einheiten in der Nähe (18km Radius).
*   **Bewertung:** Sehr fortschrittliche KI-Modifikation. Nutzt clevere Vektor-Mathematik für Formationsflüge.

---


## 4. Vehicle Mods

### 2x Vehicle Water Speed
*   **Kategorie:** Physics / Stat Tweak
*   **Dateien:** `vehicle_chassis_wheel_heavy.xml`, `vehicle_chassis_wheel_medium.xml`, etc.
*   **Analyse:**
    *   Erhöht die `magnitude` des `force_emitter` (name="water").
    *   Beispiel (`wheel_heavy`): Magnitude 23.0 (Vanilla ist deutlich niedriger).
*   **Code-Detail:**
    ```xml
    <force_emitter name="water" magnitude="23.0">
    ```
*   **Hinweis:** Einfacher XML-Tweak, keine Script-Abhängigkeiten.

### Vehicle IDs
*   **Kategorie:** UI / Scripting
*   **Dateien:** `screen_vehicle_control.lua`
*   **Analyse:**
    *   Erweitert das UI-Scripting massiv (3000+ Zeilen).
    *   Definiert globale State-Tabellen (`g_selection`, `g_highlighted`) zur Verwaltung von Unit-Selektionen.
    *   Implementiert eigene Rendering-Funktionen (`ui_render_selection_carrier_vehicle_overview`), um IDs und zusätzliche Status-Infos über Fahrze Icons zu zeichnen.
*   **Code-Detail:**
    *   Nutzt `imgui`-ähnliche Strukturen für Fenster und Listen.
    *   Scheint Performance-intensiv zu sein (viele Loops über alle Vehikel in `update`).

### Muffled Carrier Engine
*   **Kategorie:** Audio / Asset Replacement
*   **Analyse:**
    *   Reine Audio-Mod (nur `.ogg` Dateien in `content/audio`).
    *   Keine Änderungen an XML oder Lua.
    *   Sicher zu kombinieren mit allen Code-Mods.
### Specialized Chassis UI
*   **Kategorie:** UI / Vehicle Overhaul
*   **Dateien:** `screen_vehicle_control.lua` (und viele andere Screens)
*   **Analyse:**
    *   Massiver Rewrite der Fahrzeug-Steuerung.
    *   **Feature:** Erweiterte Darstellung von Fahrzeug-Icons auf der Map (`ui_render_selection_carrier_vehicle_overview`).
    *   **Feature:** Detaillierte Status-Fenster für spezifische Chassis-Typen (`imgui_vehicle_chassis_loadout`).
    *   **Code-Detail:**
        *   Nutzt `g_ui` (imgui-Wrapper) intensiv für Fenster-Management.
        *   Eigene `render_selection_vehicle` Funktion, die je nach Chassis-Typ unterschiedliche Optionen (Self-Destruct, Camera, Loadout) anzeigt.

---

## 5. UI Mods

### UI Enhancer
*   **Kategorie:** UI Overhaul
*   **Dateien:** `screen_radar.lua`, etc.
*   **Analyse:**
    *   Ersetzt die Standard-Radar-Logik komplett.
    *   **Feature:** Multi-Layer Depth Scan. Es werden 4 "Ebenen" (`g_scan_layer_count = 4`) gescannt und in verschiedenen Farben (`g_layer_colors`) dargestellt.
    *   **Feature:** Kollisionswarnung. Prüft `min_distance` und gibt Warnungen (`upp_collision`) aus, wenn Objekte zu nah sind.
*   **Code-Detail:**
    ```lua
    -- screen_radar.lua
    for i=1, g_scan_layer_count do
        g_depth_data[i][g_scan_cursor].depth = math.min(g_max_scan_distance, this_vehicle_object:get_carrier_raycast(scan_angle, -0.02 * i))
    end
    ```

### Higher Resolution Radar
*   **Kategorie:** UI Mod
*   **Dateien:** `screen_vision_radar.lua`
*   **Analyse:**
    *   Erhöht die Radar-Auflösung und Reichweite.
    *   **Zoom-Levels:** Implementiert 3 Zoom-Stufen (2km, 5km, 10km) via `g_ranges = { 2000, 5000, 10000 }`.
    *   **Targeting:** Zeichnet Linien zu Zielen und zeigt IDs an.
    *   **Missile Warning:** Berechnet Distanz zu feindlichen Raketen (`hostile_missile_dist`) und spielt Warntöne ab (`update_play_sound(9)`).

---

## 5. Vehicle Mods

### **Luz's Naval Expansion Beta - 1.0.1 (Autor: Luz)**
*   **Beschreibung:** Verwandelt das kleine Navy-Schiff (Needlefish) in einen Mini-Träger/Logistik-Schiff.
*   **Code-Analyse:**
    *   **Datei:** `vehicle_chassis_ship_small.xml`
    *   **Änderung:** Ersetzt das Chassis komplett durch eine Konstruktion aus `aircraft_carrier_shell`-Meshes. Fügt `logistics_left` und `logistics_right` (Typ 7) Connectors hinzu.
*   **Kompatibilität:** Überschreibt das Standard-Needlefish-Chassis. Inkompatibel mit *Needlefish Mk2*.

### **Mule 2 (Autor: N/A)**
*   **Beschreibung:** Schwer bewaffnete, 8-rädrige Version des Mule.
*   **Code-Analyse:**
    *   **Datei:** `vehicle_chassis_wheel_mule.xml`
    *   **Änderung:** Fügt zusätzliche Räderpaare und Waffen-Attachments (`air_defence_missile_stand`) fest ins Chassis ein.
*   **Technik:** Nutzt Mesh-Transforms, um die zusätzlichen Räder zu positionieren.

### **Needlefish Mk2 (Autor: N/A)**
*   **Beschreibung:** Raketenboot-Variante.
*   **Code-Analyse:**
    *   **Datei:** `vehicle_chassis_ship_small.xml`
    *   **Änderung:** Fügt Raketensilos (`cruise_missile_silo_base`) zum Standard-Hull hinzu.
*   **Konflikt:** Überschreibt ebenfalls `vehicle_chassis_ship_small.xml` -> Konflikt mit Luz's Expansion.

### **Callsigns for Vehicles (Autor: N/A)**
*   **Beschreibung:** Fügt wahrscheinlich Callsigns zur UI hinzu.
*   **Code-Analyse:**
    *   **Datei:** `screen_vehicle_control.lua`
    *   **Problem:** Überschreibt das komplette Map-Screen-Script mit einer (vermutlich) veralteten Version (nutzt globale `g_selection_vehicle_id` statt `g_selection` Table).
*   **Warnung:** Hohes Risiko, Vanilla-UI-Fixes oder neue Map-Features zu brechen.

### **Logistics+ (Autor: N/A)**
*   **Beschreibung:** Automatisierungsskript für Logistik.
*   **Code-Analyse:**
    *   **Datei:** `library_custom_7.lua`
    *   **Funktion:** Fügt Logik hinzu, um Barge-Aufträge automatisch zu generieren.

### **Lubricant (Carrier) (Autor: N/A)**
*   **Beschreibung:** "Lubricant" Mod, der den Träger beleuchtet.
*   **Code-Analyse:**
    *   **Datei:** `vehicle_chassis_carrier.xml`
    *   **Änderung:** Fügt diverse Lichtquellen (`bridge_control_light`) hinzu. Rein visuell.

### **Utility (Autor: N/A)**
*   **Fahrzeuge:** Razor (`vehicle_chassis_rotor_small.xml`) und Manta (`vehicle_chassis_wing_heavy.xml`).
*   **Änderung:** Fügt kleine Utility-Slots (`left_small`, `right_small`) zum Razor und Bomben-Slots zum Manta hinzu.

## 6. Audio Mods

### General Audio Mods (Alarm, Sound Enhancement, etc.)
*   **Kategorie:** Audio / Asset Replacement
*   **Analyse:**
    *   Die meisten Audio-Mods (z.B. *Wolfenstein Alarm*, *Skidders Pack*) sind reine Asset-Replacements (.ogg Dateien).
    *   Einige (z.B. *Skidders Pack*) enthalten XML-Tweaks (`missile_cruise.xml`), um Audio-Events mit neuen Sound-Dateien zu verknüpfen.
    *   **Technisch:** Unkritisch für Code-Konflikte, solange keine Logik-Scripte enthalten sind.

---

## 7. Overhaul Mods

### Revolution 1.6-2 (Core)
*   **Kategorie:** Framework / Overhaul
*   **Dateien:** `library_vehicle.lua`, `library_ui.lua`, etc.
*   **Analyse:**
    *   Dient als Basis-Framework für andere Revolution-Module.
    *   **Hook-System:** Implementiert Hooks wie `g_revolution_custom_vehicle_chassis_data`, erlaubt es Sub-Mods, eigene Fahrzeug-Daten zu injizieren, ohne Core-Files zu überschreiben.
    *   **Airlift-Logic:** `g_mod_allow_airlift` Tabelle erlaubt feingranulare Kontrolle darüber, welche Vehikel geflogen werden können.
    *   **Autoland:** Eigene `setup_autoland`-Funktion mit komplexer Wegpunkt-Berechnung für Landeanflüge.
*   **Verbesserung:**
    *   Sehr mächtiges Framework. Entwickler von Unit-Mods sollten prüfen, ob sie sich in dieses Framework einklinken können, statt Vanilla-Methoden zu überschreiben.
*
---

## 3. Weapon Mods

### **15mm Turrets (Autor: N/A)**
*   **Beschreibung:** Ermöglicht die Nutzung von 15mm-Türmen.
*   **Code-Analyse:**
    *   **Datei:** `screen_vehicle_loadout.lua`
    *   **Logik:** Erweitert das Loadout-Script, um die 15mm-Variante korrekt im UI anzuzeigen und ausrüstbar zu machen.
    *   **Technik:** Entfernt die Sichtbarkeitsprüfung `update_get_attachment_option_hidden`, wodurch versteckte Vanilla-Inhalte freigeschaltet werden.
*   **Detaillierter Bericht:** [15mm_Turrets_analysiert.md](file:///f:/Workspace/Mod%20sammlung/.github/workflows/Detailanalyse/15mm_Turrets_analysiert.md)

### **Naval Gun Stabilizer (Autor: N/A)**
*   **Beschreibung:** Stabilisiert das Hauptgeschütz des Trägers.
*   **Code-Analyse:**
    *   **Datei:** `vehicle_attachment_carrier_turret_main_gun.xml`
    *   **Änderung:** Verringert `fov` im `projectile_emitter` von `0.06` auf `0.02`.
    *   **Detaillierter Bericht:** [Naval_Gun_Stabilizer_analysiert.md](file:///f:/Workspace/Mod%20sammlung/.github/workflows/Detailanalyse/Naval_Gun_Stabilizer_analysiert.md)

### **Turret Utility (Autor: N/A)**
*   **Beschreibung:** Fügt stationären Türen zusätzliche Slots für Kameras/Sensoren hinzu.
*   **Code-Analyse:**
    *   **Datei:** `stationary_turret.xml`.
    *   **Änderung:** Fügt `<attachment>` Slots vom Typ 0 und 2 hinzu.
    *   **Detaillierter Bericht:** [Turret_Utility_analysiert.md](file:///f:/Workspace/Mod%20sammlung/.github/workflows/Detailanalyse/Turret_Utility_analysiert.md)

### **Island turret placement QoL (Autor: N/A)**
*   **Beschreibung:** Verbessertes Platzieren von Insel-Türmen.
*   **Code-Analyse:**
    *   **Datei:** `screen_vehicle_control.lua`
    *   **Logik:** Ermöglicht das Abbrechen von Turm-Produktionen direkt über die Karte und fügt Status-Abfragen für die Queue hinzu.
    *   **Detaillierter Bericht:** [Island_turret_placement_QoL_analysiert.md](file:///f:/Workspace/Mod%20sammlung/.github/workflows/Detailanalyse/Island_turret_placement_QoL_analysiert.md)

### **Salty's Missile Damage Edit (Autor: SaltySeabisc)**
*   **Beschreibung:** +5% Schaden für Raketen.
*   **Code-Analyse:**
    *   **Datei:** `constants.txt` (Script-Override).
    *   **Änderung:**
        *   `missile_1_explosion_damage_scale` 1.0 -> 1.05
        *   `missile_2_explosion_damage_scale` 1.0 -> 1.05
        *   `missile_tv_explosion_damage_scale` 1.0 -> 1.05
    *   **Technik:** Nutzt die saubere Methode via `constants.txt` Override.
    *   **Detaillierter Bericht:** [Saltys_Missile_Damage_Edit_analysiert.md](file:///f:/Workspace/Mod%20sammlung/.github/workflows/Detailanalyse/Saltys_Missile_Damage_Edit_analysiert.md)
    *   **Detaillierter Bericht (Island Turrets):** [Island_turret_placement_QoL_analysiert.md](file:///f:/Workspace/Mod%20sammlung/.github/workflows/Detailanalyse/Island_turret_placement_QoL_analysiert.md)

### **Speed Mods (2x Cruise Speed, Gentle Buff, Supersonic)**
*   **Beschreibung:** Erhöhen die Geschwindigkeit von Raketen.
*   **Code-Analyse:**
    *   **Dateien:** `missile_cruise.xml`, `missile_2.xml`, etc.
    *   **Technik:**
        *   Diese Mods definieren den **physikalischen Körper** (`body`) der Rakete neu.
        *   **Trace:** Die Mods setzen die Masse oft auf sehr niedrige Werte (z.B. `mass="1.0"`, `0.1`, oder `1.0` bei 2x Speed).
        *   **Effekt:** Da die Schubkraft (`thruster`) der Waffe gleich bleibt, sorgt die verringerte Masse (F=m*a) für eine drastisch höhere Beschleunigung.
    *   **Detaillierter Bericht (2x Speed):** [2x_Cruise_Missile_Speed_analysiert.md](file:///f:/Workspace/Mod%20sammlung/.github/workflows/Detailanalyse/2x_Cruise_Missile_Speed_analysiert.md)
    *   **Detaillierter Bericht (Gentle Buff):** [Gentle_Missile_Speed_Buff_analysiert.md](file:///f:/Workspace/Mod%20sammlung/.github/workflows/Detailanalyse/Gentle_Missile_Speed_Buff_analysiert.md)
    *   **Detaillierter Bericht (Supersonic):** [Supersonic_Cruise_Missile_analysiert.md](file:///f:/Workspace/Mod%20sammlung/.github/workflows/Detailanalyse/Supersonic_Cruise_Missile_analysiert.md)
    *   **Hinweis:** Vanilla-Dateien haben oft keine expliziten `body`-Definitionen an dieser Stelle (nutzen Defaults), weshalb diese Mods durch das Hinzufügen expliziter, leichter Bodies funktionieren.

### **Missile / Torpedo Reformat (Autor: N/A)**
*   **Beschreibung:** Überarbeitung von Raketen und Torpedos.
*   **Code-Analyse:**
    *   **Dateien:** `missile_1.xml` bis `missile_5.xml`, `torpedo.xml`.
    *   **Technik:**
        *   Definiert explizite `bodies` mit `mass="0.1"` (sehr leicht -> sehr schnell).
        *   Passt `bounding_radius` und Collision-Boxen an.
        *   Scheint ein komplettes Rebalancing der Flugphysik durch Masseverringerung zu sein.
    *   **Detaillierter Bericht (Missile Reformat):** [Missile_Reformat_analysiert.md](file:///f:/Workspace/Mod%20sammlung/.github/workflows/Detailanalyse/Missile_Reformat_analysiert.md)
    *   **Detaillierter Bericht (Torpedo Reformat):** [Torpedo_Reformat_analysiert.md](file:///f:/Workspace/Mod%20sammlung/.github/workflows/Detailanalyse/Torpedo_Reformat_analysiert.md)

### **Visual / Audio Replacements**
*   **Cement bomb / Mark84 bomb**: Reine Mesh-Replacements (`.mesh`), keine Logik-Änderungen.
    *   **Detaillierter Bericht (Cement bomb):** [Cement_bomb_analysiert.md](file:///f:/Workspace/Mod%20sammlung/.github/workflows/Detailanalyse/Cement_bomb_analysiert.md)
    *   **Detaillierter Bericht (Mark84 bomb):** [Mark84_bomb_analysiert.md](file:///f:/Workspace/Mod%20sammlung/.github/workflows/Detailanalyse/Mark84_bomb_analysiert.md)
*   **Torpedo & Missile Wolfenstein alarm**: Reines Audio-Replacement (`telemetry07.ogg`), ersetzt den Alarm-Sound.
    *   **Detaillierter Bericht:** [Torpedo_Missile_Wolfenstein_alarm_analysiert.md](file:///f:/Workspace/Mod%20sammlung/.github/workflows/Detailanalyse/Torpedo_Missile_Wolfenstein_alarm_analysiert.md)

## 4. UI Mods

### **AdvancedRadar (Autor: N/A)**
*   **Beschreibung:** Fügt "Terrain Masking" zum Radar hinzu.
*   **Code-Analyse:**
    *   **Datei:** `screen_vision_radar.lua`
    *   **Logik:** Definiert `radar_islands` (feste Koordinaten/Radien) und eine `is_scan_blocked` Funktion. Versteckt Radar-Blips, wenn sie hinter diesen definierten Inseln sind.
*   **Besonderheit:** Simuliert Sichtlinien-Blockierung basierend auf hardcodierten Insel-Positionen.

### **Higher Resolution Radar (Autor: N/A)**
*   **Beschreibung:** Stark verbessertes Radar-Interface.
*   **Code-Analyse:**
    *   **Datei:** `screen_vision_radar.lua`
    *   **Änderungen:**
        *   Vergrößert den Radar-Radius von 50 auf 110 Pixel.
        *   Zeigt **Unit-IDs** als Text neben den Blips an.
        *   Zeigt **Richtungs-Vektoren** (Linien) für Flugzeuge und Fahrzeuge an.
        *   Fügt 15-Grad-Markierungen am Rand hinzu.

### **Radar Range 20km (Autor: N/A)**
*   **Beschreibung:** Erhöht die maximale Zoom-Stufe.
*   **Code-Analyse:**
    *   **Datei:** `screen_vision_radar.lua`
    *   **Änderung:** Erweitert `g_ranges` um einen 20.000m Eintrag.

### **Tactical Operations Centre 1.5 (TOC) (Autor: N/A)**
*   **Beschreibung:** Massiver Umbau des Carrier-Innenlebens (Brücke/Hangar).
*   **Code-Analyse:**
    *   **Datei:** `vehicle_chassis_carrier.xml`
    *   **Inhalt:** Fügt neue Räume (`specops-room`), Terminals (`hangar terminal`), Sitze, Lichter und Steuerungen hinzu.
    *   **Technik:** Nutzt dutzende neue Meshes und Collision-Bodies (`box`), um das Schiffsinnere physikalisch begehbar zu erweitern.
*   **Konflikt:** Kollidiert zwangsläufig mit jedem anderen Mod, der den Carrier-Rumpf (Chassis) bearbeitet (z.B. *Lubricant*).

### **UI Enhancer (Autor: N/A)**
*   **Beschreibung:** Kompletter UI-Overhaul.
*   **Analyse:** Enthält 27 Script-Dateien, die fast alle Bildschirme (Steuerung, Inventar, HUD, Map) ersetzen.
*   **Konfliktpotenzial:** Sehr hoch. Inkompatibel mit fast allen anderen UI-Mods (z.B. *Callsigns for Vehicles*), es sei denn, Kompatibilitäts-Patches (wie *FC Navy x UI Enhancer*) werden genutzt.
