# Skript-Analyse: `mod_dev_kit/source/scripts`

Dieses Dokument bietet eine detaillierte Analyse der Lua-Skripte im Verzeichnis `mod_dev_kit/source/scripts`. Es erklärt den Zweck jedes Skripts, was es definiert und was modifiziert werden kann.

## Kernbibliotheken (Core Libraries)

### `library_enum.lua`
**Zweck:** Definiert globale Enumerations-Tabellen, die in allen Spielskripten verwendet werden.
**Wichtige Definitionen:**
- `e_game_object_type`: IDs für alle Fahrzeug-Chassis, Geschütztürme und Aufsätze (z.B. `chassis_carrier`, `attachment_turret_ciws`).
- `e_game_object_attachment_type`: Typen von Aufsatz-Slots (z.B. `plate_small`, `plate_large`).
- `e_loc`: IDs für Lokalisierungs-Strings (z.B. `upp_carrier`, `upp_fuel`).
- `e_input`: IDs für Eingabe-Events (z.B. `pointer_1`, `text_enter`).
**Verwendung:** Nutzen Sie diese Enums anstelle von direkten Zahlen, um den Code lesbar und kompatibel mit Spiel-Updates zu halten.

### `library_util.lua`
**Zweck:** Bietet Hilfsfunktionen für Mathematik, Rendering und Datenkonvertierung.
**Wichtige Funktionen:**
- **Mathematik:** `lerp`, `clamp`, `vec2_dist`, `vec3_dist`, `iff` (ternärer Operator).
- **Farbe:** Definiert standardisierte Farben wie `color_white`, `color_status_ok`, `color_enemy`.
- **Icons:** `atlas_icons` Tabelle mappt Icon-Namen auf ihre Textur-Indices. `get_attachment_icons(def_index)` gibt Icons für einen bestimmten Aufsatz zurück.
- **Koordinaten-Konvertierung:** `get_screen_from_world` und `get_world_from_screen` zum Mappen von 3D-Weltkoordinaten auf 2D-Bildschirmkoordinaten (nützlich für HUDs).

### `library_vehicle.lua`
**Zweck:** Hilfsfunktionen zum Abrufen statischer Daten über Fahrzeuge und Aufsätze.
**Wichtige Funktionen:**
- **Datenzugriff:** `get_chassis_data_by_definition_index(index)` gibt Namen, Icon und Beschreibung für ein Chassis zurück.
- **Klassifizierung:** `get_is_vehicle_[air|sea|land|airliftable]` prüft Fahrzeugtypen.
- **Fähigkeiten:** `get_vehicle_capability(vehicle)` gibt einen Zusammenfassungs-String der Waffen zurück (z.B. "Msl/AA/Gun").

### `library_ui.lua`
**Zweck:** Ein eigenes "Immediate Mode" GUI-System, implementiert in Lua.
**Hauptmerkmale:**
- **Fenster-Management:** `begin_window`, `end_window`, `begin_window_dialog`.
- **Eingabe-Verarbeitung:** Verarbeitet Maus/Tastatur/Gamepad-Eingaben und verwaltet den Fokus.
- **Widgets:** `button`, `slider`, `checkbox`, `header`, `list_item`.
- **Layout:** `begin_nav_row`, `end_nav_row` für Grid-Layouts.
**Verwendung:** Wird von allen `screen_*.lua` Skripten verwendet, um ihre Benutzeroberflächen zu zeichnen.

### `interactions.lua`
**Zweck:** Verwaltet Gameplay-Feedback und UI-Overlays auf hoher Ebene.
**Wichtige Systeme:**
- **Interaktionen:** Aufforderungen wie "Drücke [E] zum Interagieren". Verwaltet über `g_interactions`.
- **Ziele:** Missionsziele, die auf dem Bildschirm angezeigt werden. Verwaltet über `g_objectives`.
- **Untertitel:** Dialogtext-Verarbeitung. Verwaltet über `g_subtitles`.
- **Voice Chat:** UI zur Anzeige sprechender Teilnehmer. Verwaltet über `g_voice_chat`.
- **Nachrichtenbox:** Kritische Warnungen oder Tutorial-Nachrichten.

---

## Kern-Gameplay-Screens

### `vehicle_hud.lua`
**Zweck:** Das Haupt-Heads-Up Display (HUD), sichtbar bei der Fahrzeugsteuerung.
**Hauptmerkmale:**
- **Benachrichtigungssystem:** Zeigt Modusänderungen an (z.B. "Manuelle Steuerung", "Unterstützung abgebrochen") über `g_notification`.
- **Aufsatz-Hotbar:** Rendert die Waffen-/Utility-Slots am unteren Rand über `render_attachment_hotbar`.
- **Aufsatz-Info:** Zeigt Munitionsstand, Treibstoff und Status des ausgewählten Aufsatzes über `render_attachment_info`.
- **Integration:** Ruft spezifische Render-Funktionen basierend auf dem Fahrzeugtyp auf (z.B. `render_flight_hud`, `render_carrier_hud`).
**Modding-Potential:** Passen Sie `g_attachment_slot_size` oder Layout-Positionen an, um das HUD anzupassen.

### `screen_vehicle_control.lua`
**Zweck:** Der "Taktische Karten"- oder "Kommandozentrale"-Bildschirm (oft über die Kartentaste aufgerufen).
**Hauptmerkmale:**
- **Karten-Interaktion:** Handhabt Auswahl (`g_selection`), Ziehen (`g_drag`) und Hervorhebung (`g_highlighted`) von Einheiten und Wegpunkten.
- **Träger-Management:** Rendert die UI der Träger-Andockbuchten (`render_selection_carrier`).
- **Fahrzeug-Loadout:** Erlaubt das Ändern von Fahrzeugwaffen und Chassis-Einstellungen via `imgui_vehicle_chassis_loadout`.
- **Kommandozentrale:** Verwaltet Insel-Produktionswarteschlangen und Turmbau (`render_selection_command_center`).
**Komplexität:** Hoch. Dies ist die zentrale Logik für das RTS-Einheitenmanagement.

### `screen_holomap.lua`
**Zweck:** Rendert die holografische 3D-Karte, die in der Brücken- oder Strategieansicht verwendet wird.
**Hauptmerkmale:**
- **Rendering:** Rendert Inseln, Fahrzeuge, Kacheln und Grids im 3D-Raum (`g_map_x`, `g_map_z`).
- **Benachrichtigungen:** Behandelt wichtige Kartenereignisse wie "Insel erobert" oder "Blaupause freigeschaltet" (`render_notification_display`).
- **Eingabe:** Unterstützt Panning, Zooming und Cursor-Interaktion sowohl im Maus- als auch im Tastatur-Modus.
**Anpassung:** `g_colors` Tabelle definiert die Farbpalette für das Hologramm.

### `screen_compass.lua`
**Zweck:** Zeigt das Kompass-Overlay an.
**Hauptmerkmale:**
- **Visualisierungen:** Rendert eine rotierende Kompassscheibe und Neigungsindikatoren.
- **Daten:** Liest Fahrzeugrotation (Yaw, Pitch, Roll) aus, um UI-Elemente zu aktualisieren.

---

## Menü-Screens

### `screen_menu_main.lua`
**Zweck:** Der zentrale Hub für die Nicht-Gameplay-UI des Spiels.
**Hauptmerkmale:**
- **Zustandsverwaltung:** Nutzt `g_screen_index` und `g_screens` Enum zum Umschalten zwischen Unterbildschirmen (Neues Spiel, Beitreten, Host, Mods, etc.).
- **Multiplayer:** Behandelt Logik für Hosting (öffentlich/privat), Beitreten via Steam Friends oder Einladungscode, und Lobby-Management.
- **Modding-UI:** Enthält Interfaces zum Durchsuchen installierter Mods, Aktivieren/Deaktivieren und Hochladen von Mods in den Steam Workshop.
- **Benutzerdefiniertes Spiel:** Bietet UI zum Einrichten benutzerdefinierter Spielparameter.

---

## Waffen-Screens

### `screen_weapons_anti_air.lua`
**Zweck:** Spezialisierte UI für Flugabwehr-Waffenstationen.
**Hauptmerkmale:**
- **Visualisierungen:** Rendert Raketen-Icons, Munitionsbalken und "Tracking"/"Locked" Status-Labels.
- **Feedback:** Spielt Audio-Pieptöne (`update_play_sound`) beim Verfolgen von Zielen.
- **Layout:** Zeigt Informationen für mehrere Waffenaufsätze nebeneinander an.

### `screen_weapons_support.lua`
**Zweck:** UI für Unterstützungs-Waffen (Marschflugkörper, Hauptgeschütz).
**Hauptmerkmale:**
- **Status:** Zeigt "Offline", "Beschädigt" oder aktiven Status für schwere Waffen.
- **Munition:** Rendert spezifische Icons für Marschflugkörper vs. Granaten.
- **Befehle:** Zeigt aktuelle Zielbefehle an, die vom Kommandobildschirm übermittelt wurden.

---

## Logistik & System-Screens

### `screen_inventory.lua`
**Zweck:** Das Hauptinterface für Logistik und Inventarverwaltung.
**Hauptmerkmale:**
- **Tabs:** "Lager" (Schiffsinventar), "Karte" (Logistik-Overlay), "Barges" (Barge-Verwaltung).
- **Logistik-Karte:** Eine spezialisierte Kartenansicht zum Bestellen von Barges und Verwalten von Fabrikwarteschlangen.
- **Barge-Verwaltung:** Detaillierter Status und Kontrolle für Logistik-Barges, inklusive Transferfortschritt.

### `screen_damage.lua`
**Zweck:** Schadenskontroll-Interface.
**Hauptmerkmale:**
- **Schadenszonen:** Visualisiert die Fahrzeuggesundheit über spezifische Zonen (Vorne Links, Rumpf, Brücke, etc.).
- **Reparatur-Steuerung:** Erlaubt das Umschalten der Reparaturpriorität für bestimmte Zonen.
- **Schadensvisualisierung:** Verwendet farbkodierte Icons, um die Schwere des Schadens anzuzeigen.

### `screen_navigation.lua`
**Zweck:** 2D-Navigationskarte.
**Hauptmerkmale:**
- **Modi:** Unterstützt verschiedene Wetter-Overlays (Kartografie, Wind, Niederschlag, Nebel).
- **Steuerung:** Erlaubt das Setzen von Kursen und Anzeigen des Fahrzeugstatus.
- **Visualisierung:** Rendert Inseln und Fahrzeuge in einer 2D-Draufsicht.