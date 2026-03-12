# Detailanalyse: Island turret placement QoL Mod

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
