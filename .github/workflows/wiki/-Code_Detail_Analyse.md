# Mod-Sammlung: Code Detail-Analyse & Dokumentation

> **Status:** Work in Progress
> **Erstellt am:** 14.02.2026
> **Zweck:** Technische Dokumentation aller Mods für Entwickler und Maintainer.

---

## 2. Gameplay Mods

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

### Assault Barge
*   **Kategorie:** Fahrzeuge / Overhaul
*   **Dateien:** `vehicle_chassis_barge.xml`
*   **Analyse:**
    *   Massiver visueller Overhaul durch Hinzufügen zahlreicher Meshes (Container, Radar, Carrier-Teile).
    *   Erhöht `force_emitter` für Wasserantrieb auf `1300.0`.
    *   Strukturiert die `vehicle_attachments` um (Mischung aus Typ 0 und Typ 1).

### Combat Carrier (Variants: Base, VLS, Speed Change)
*   **Kategorie:** Fahrzeuge / Overhaul / Scripting
*   **Dateien:** `vehicle_chassis_carrier.xml`, `screen_self_destruct.lua`, `screen_vehicle_loadout.lua`
*   **Analyse:**
    *   **Base:** Verdoppelt den Antrieb (`4800` vs `2400`). Fügt 4 Manövrierdüsen (600 Magnitude) hinzu.
    *   **Script-Hack:** Nutzt `screen_self_destruct.lua` (oder Loadout-Script), um beim ersten Start via `drydock:set_attached_vehicle_attachment` automatisch 15mm Turrets (oder Laser VLS) auf neue Hardpoints (ID 14-17) zu installieren.
    *   **VLS-Variant:** Fügt spezifische XML-Slots für Raketen (Typ 3) und entsprechende VLS-Meshes hinzu.
    *   **Speed-Variant:** Extremwert-Tweak mit `15000` Magnitude für Wasserantrieb.
    *   **UI-Fix:** Überschreibt `get_ui_vehicle_chassis_attachments` in Lua, um die neuen Slot-Icons im Loadout-Screen korrekt zu positionieren.

### Ship Wakes
*   **Kategorie:** Fahrzeuge / Visuals
*   **Dateien:** `vehicle_chassis_carrier.xml`, `vehicle_chassis_barge.xml`, etc.
*   **Analyse:**
    *   Fügt `foam_emitters` hinzu oder vergrößert diese (Radius/Scale auf ~20).
    *   Erzeugt die optische Bug- und Heckwelle im Wasser.

---

## 3. Weapon Mods
*(Analyse läuft...)*
