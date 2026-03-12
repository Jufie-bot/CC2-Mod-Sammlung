# Detailanalyse: 15mm Turrets Mod

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
