# Spiel-Konstanten Analyse (constants.txt)

> [!IMPORTANT]
> **Technischer Durchbruch:** Entgegen offizieller Informationen können viele Core-Werte des Spiels über die Datei `mod_dev_kit/source/scripts/constants.txt` geändert werden!

Diese Datei erlaubt tiefgreifende Balance-Änderungen ohne Lua-Hacks.

## 1. Waffenschaden & Radius
Hier können Schaden und Explosionsradius für alle Projektile eingestellt werden.
```txt
// Schaden
projectile_type_15mm_damage 12
projectile_type_40mm_damage 50
projectile_type_160mm_artillery_damage 100

// Radius
projectile_type_20mm_radius 3.0
projectile_type_160mm_artillery_radius 10.0
```

## 2. Fahrzeug-Werte (HP & Rüstung)
Erlaubt das Anpassen der Widerstandsfähigkeit (`hp`) und Schadensminderung (`armour`).
*   **Carrier:** `carrier_hp 5000`, `carrier_armour 40`
*   **Schiffe:** `sea_ship_heavy_hp 600`
*   **Flugzeuge:** `air_wing_heavy_hp 80` (Manta), `air_rotor_heavy_hp 160` (Razorbill)
*   **Bodenfahrzeuge:** `land_wheel_heavy_hp 400` (Bear)

## 3. Treibstoff
Kapazität und Verbrauch können global oder pro Chassistyp geändert werden.
```txt
base_fuel_capacity 1000.0          // Standard
ship_heavy_fuel_capacity 20000.0   // Trägerschiff-Erweiterung?
rotor_heavy_fuel_consumption 8.0   // Verbrauch pro Tick/Sekunde
```

## 4. Wirtschaft & Produktion
Kosten und Zeit für die Herstellung von Items.
*   **Kosten:** `item_vehicle_wheel_heavy_production_cost 1500`
*   **Zeit:** `item_vehicle_wheel_heavy_production_time 300` (Sekunden)

## 5. Munitionskapazität
Wie viel Munition ein Turm oder Container fasst.
*   `turret_30mm_ammo_capacity 250`
*   `turret_ciws_ammo_capacity 400` (Vanilla Wert)
*   `turret_missile_ammo_capacity 4` (IR Missiles am Chassis)

## 6. KI & Umwelt
*   **Radar:** `ai_radar_awacs_vision_range 8000.0` (Sichtweite der KI)
*   **Wetter:** `cloud_count 350`, `cloud_height_base 2000.0` (Kann für Performance-Mods genutzt werden!)
*   **Inseln:** `island_difficulty_max 4`

## Fazit für Modder
Anstatt Physik-Tricks zu nutzen (z.B. extrem hohe Geschwindigkeiten für mehr "Wumms"), sollten Balance-Mods primär diese Datei nutzen. Sie ist sauberer und verursacht weniger Nebenwirkungen (wie Glitches oder Lag).
