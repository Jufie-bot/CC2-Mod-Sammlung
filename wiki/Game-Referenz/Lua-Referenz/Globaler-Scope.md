# Globaler Scope (Lua)

In der CC2 Lua-Umgebung existieren viele vordefinierte globale Variablen, Tabellen und Enums, die direkt genutzt werden können. Diese werden beim Start der Lua-Instanz vom Spiel bereitgestellt.

## Eigene Globals dumpen
Um herauszufinden, welche Variablen in einem spezifischen Kontext (z. B. auf einem bestimmten Bildschirm) verfügbar sind, kann folgender Code-Schnipsel genutzt werden:

```lua
local seen={}
function dump(t,i) 
    seen[t]=true 
    local s={}
    local n=0 
    for k in pairs(t) do n=n+1 s[n]=k end 
    table.sort(s) 
    for k,v in ipairs(s) do 
        print(i,v) 
        v=t[v] 
        if type(v)=="table" and not seen[v] then
            dump(v,i.."\t") 
        end 
    end 
end 
print("----------------") 
dump(_G,"")
```

---

## Wichtige Enums (Auszug)
Enums werden verwendet, um Zustände oder Typen eindeutig zu identifizieren.

| Enum-Kategorie | Beschreibung | Beispiele |
| :--- | :--- | :--- |
| `e_game_object_type` | Fahrzeug- und Objekttypen. | `chassis_carrier`, `chassis_sea_barge`, `airfield` |
| `e_inventory_item` | Items im Lagerbestand. | `ammo_30mm`, `hardpoint_missile_ir`, `fuel_barrel` |
| `e_audio_effect_type`| Soundeffekte für `update_play_sound`. | `telemetry_1_radar`, `missile_launch`, `ui_beep_1` |
| `e_game_input` | Steuerungs-Eingaben. | `attachment_fire`, `axis_vehicle_throttle`, `back` |
| `e_loc` | Lokalisierungs-IDs. | `acronym_kilometers`, `fuel_level`, `interaction_exit` |
| `e_attack_type` | Angriffsmuster für die KI. | `missile_single`, `torpedo_single`, `gun` |
| `e_active_input` | Aktives Eingabegerät. | `keyboard`, `gamepad` |

---

## Globale Farb-Konstanten (color8)
Diese Farben können direkt für `update_ui_*` Funktionen genutzt werden.

*   `color_friendly`: Die Teamfarbe (meist Blau).
*   `color_enemy`: Die feindliche Teamfarbe (Rot).
*   `color_white`, `color_black`, `color_empty`.
*   `color_highlight`: Cyan/Hellblau für selektierte Elemente.
*   `color_status_ok` (Grün), `color_status_bad` (Rot), `color_status_warning` (Gelb).

---

## Globale Variablen (Laufzeit)
Variablen, die sich während der Laufzeit ändern:

*   `g_animation_time`: Fortlaufende Zeit für Animationen.
*   `g_blink_timer`: Ein oszillierender Wert für blinkende UI-Elemente.
*   `g_cursor_pos_x` / `g_cursor_pos_y`: Aktuelle Mausposition auf dem Screen.
*   `g_is_mouse_mode`: True, wenn die Maus zur Steuerung genutzt wird.
