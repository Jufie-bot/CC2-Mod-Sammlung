# Lua Referenz

Basierend auf der Community-Wiki Dokumentation und Code-Analysen.

## Skript-Umgebung
Jeder Bildschirm auf dem Carrier (und das HUD) hat seine eigene Lua-Instanz.
*   **Lade-Reihenfolge:**
    1.  `library_enum.lua`
    2.  `library_util.lua`
    3.  `library_vehicle.lua`
    4.  `library_ui.lua`
    5.  `screen_*.lua` (Dein Skript)

### Lebenszyklus
1.  **`begin()`**: Wird einmalig beim Start aufgerufen.
    *   Nutze dies für Initialisierungen.
    *   Verfügbare Funktionen: `begin_get_ui_region_index()`, `begin_get_screen_name()`.
2.  **`update()`**: Wird jeden Frame (oder Tick) aufgerufen.
    *   Hier passiert die Logik und das Zeichnen (Rendering).
3.  **`input()`**: Verarbeitet Eingaben (Maus, Tastatur).

## 2. Native Funktionen (C++)
Diese Funktionen sind im Spiel hardcodiert und bieten hohe Performance. Die meisten beginnen mit `update_*`.

### System & Navigation
*   **`e_active_input = update_get_active_input_type()`**: Gibt den aktuellen Eingabemodus zurück (`keyboard` oder `controller`).
*   **`string = update_get_loc(e_loc)`**: Gibt den lokalisierten Text für einen Index aus `e_loc` zurück.
*   **`Vehicle = update_get_screen_vehicle()`**: Gibt das Handle für das Fahrzeug zurück, an dem der Bildschirm montiert ist.
*   **`update_set_screen_state_exit()`**: Beendet den aktuellen Bildschirm/Kamera-Modus.
*   **`update_play_sound(e_audio_effect_type)`**: Löst einen Soundeffekt aus (nur zu Fuß/On-Foot verfügbar).

### UI Rendering
*   **`update_ui_text(x, y, text, width, alignment, color, 0)`**: Zeichnet Text.
*   **`update_ui_image(x, y, atlas_index, color, rotation)`**: Zeichnet ein Icon aus dem Texture-Atlas.
*   **`update_ui_line(x1, y1, x2, y2, color)`**: Zeichnet eine Linie.
*   **`update_ui_rectangle(x, y, w, h, color)`**: Zeichnet ein gefülltes Rechteck.
*   **`update_world_to_screen(world_pos)`**: Projiziert eine 3D-Weltkoordinate auf 2D-Bildschirmkoordinaten.

---

## 3. Objekt-Methoden (OO)

### Fahrzeug-Methoden (v:...)
Fahrzeug-Objekte (`Vehicle`) sind der Hauptweg zur Interaktion mit Einheiten.
*   **`ref = v:get()`**: Aktualisiert das Lua-Objekt mit Werten aus der Engine. Gibt `nil` zurück, wenn das Fahrzeug nicht (mehr) existiert.
*   **`index = v:get_definition_index()`**: Gibt den Typ (`e_game_object_type`) zurück.
*   **`bool = v:get_is_docked()`**: Prüft, ob das Fahrzeug gedockt ist.
*   **`bool = v:get_is_visible()`**: Prüft Sichtbarkeit für das eigene Team.
*   **`Position = v:get_position()`**: Gibt das `Position`-Objekt der Einheit zurück.
*   **`count = v:get_waypoint_count()`**: Anzahl der Wegpunkte (funktioniert nicht im HUD-Skript).
*   **`waypoint = v:get_waypoint(num)`**: Gibt einen Wegpunkt zurück (funktioniert nicht im HUD-Skript).

### Positions-Methoden (p:...)
Repräsentieren einen 3D-Punkt in der Welt. **Hinweis:** Bei Fahrzeugen ist x = Breitengrad, y = Höhe, z = Längengrad. Bei Holomap-Wegpunkten sind y und z oft vertauscht.
*   **`float = p:x()`**: Gibt die X-Koordinate zurück.
*   **`float = p:y()`**: Gibt die Y-Koordinate (Höhe) zurück.
*   **`float = p:z()`**: Gibt die Z-Koordinate zurück.

---

## 4. Lua-Bibliotheken (`library_*.lua`)
Diese Funktionen sind in den mitgelieferten Lua-Dateien definiert und können im Mod-Dev-Kit eingesehen werden.

*   **`begin_load()`**: Standard-Initialisierung für Skynet/Revolution Hooks.
*   **`update_ui_rectangle_outline()`**: Zeichnet einen Rahmen (Helper).
*   **`get_screen_from_world()`**: Projektion für 2D-Karten.
