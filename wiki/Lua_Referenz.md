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

## Native Funktionen (C++)
Diese Funktionen sind im Spiel hardcodiert und bieten hohe Performance.

### Welt-zu-Bildschirm Projektion
*   **`update_world_to_screen(world_pos)`**
    *   *Verwendung:* Projiziert eine 3D-Weltkoordinate auf 2D-Bildschirmkoordinaten.
    *   *Wichtig für:* HUD-Elemente, Zielmarker, Namensschilder über Fahrzeugen.
    *   *Beispiel:* `local screen_pos = update_world_to_screen(target_pos)`

### UI Rendering
*   **`update_ui_text(x, y, text, width, alignment, color, 0)`**: Zeichnet Text.
*   **`update_ui_image(x, y, atlas_index, color, rotation)`**: Zeichnet ein Icon aus dem Texture-Atlas.
*   **`update_ui_line(x1, y1, x2, y2, color)`**: Zeichnet eine Linie.
*   **`update_ui_rectangle(x, y, w, h, color)`**: Zeichnet ein gefülltes Rechteck.

### Input Management
*   **`update_add_ui_interaction(text, input_enum)`**: Zeigt eine Taste/Button-Interaktion unten links an.
*   **`update_add_ui_interaction_special(text, special_enum)`**: Für komplexe Inputs wie Drosselklappe (Throttle) oder Lenkung.

## Lua-Funktionen (Libraries)
Diese Funktionen sind in den `library_*.lua` Dateien definiert und können von dir eingesehen/geändert werden.

*   **`begin_load()`**
*   **`update_ui_rectangle_outline()`**
*   **`get_screen_from_world()`** (Achtung: Anders als `update_world_to_screen`, meist für 2D-Karten gedacht).
