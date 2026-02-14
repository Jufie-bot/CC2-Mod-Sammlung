# Code-Detail-Analyse (Original vs. Mod)

Dieses Dokument ist das Herzstück der technischen Analyse. Es zeigt für jede Mod, was *genau* im Code geändert wurde.

---

## 1. Physik & Movement Mods

### **2x Vehicle Water Speed (Autor: QuantX)**
*   **Datei:** `content/game_objects/vehicle_chassis_wheel_*.xml`
*   **Original Code (Vanilla):**
    ```xml
    <force_emitter name="water" magnitude="18.0">
    <force_emitter name="water_side" magnitude="2.0">
    ```
*   **Mod Code:**
    ```xml
    <force_emitter name="water" magnitude="37.0"> <!-- Ca. 2x Kraft -->
    <force_emitter name="water_side" magnitude="4.0">
    ```
*   **Analyse:**
    Erhöht die Schubkraft.
    *Bewertung:* ⚠️ Unsauber. Erhöhte Kraft führt bei Wellengang zum Abheben.
    *Besser:* `drag="0.5"` (Widerstand halbieren).

### **3x / 5x Vehicle Water Speed**
*   **Code-Vergleich:**
    Erhöht `magnitude` auf 50.0 bzw. 90.0.
*   **Analyse:**
    Physik bricht zusammen. Schiffe werden zu Flugzeugen.
    *Bewertung:* ❌ Völlig instabil.

### **Missile Reformat (Autor: Ribbons)**
*   **Datei:** `content/game_objects/missile_*.xml`
*   **Original Code (Vanilla):**
    ```xml
    <missile turn_rate="0.15" fuel="100">
    ```
*   **Mod Code:**
    ```xml
    <missile turn_rate="0.25" fuel="60"> <!-- Wendiger, weniger Reichweite -->
    <guidance_delay>1.5</guidance_delay> <!-- Neu hinzugefügt -->
    ```
*   **Analyse:**
    `guidance_delay` sorgt dafür, dass die Rakete erst gerade fliegt (vertikaler Start aus VLS), bevor sie lenkt.
    *Bewertung:* ✅ Exzellent. Nutzt XML-Features, die Vanilla kaum verwendet.

### **Torpedo Reformat (Autor: Ribbons)**
*   **Datei:** `torpedo.xml`
*   **Original Code:**
    Lineare Bewegung.
*   **Mod Code:**
    Anpassung von `steer_force` und `drag`.
*   **Analyse:**
    Torpedos driften mehr (Trägheit), fühlen sich "schwerer" an.
    *Bewertung:* ✅ Gute Simulation von Unterwasser-Physik.

---

## 2. UI & Scripting Mods

### **UI Enhancer (Autor: QuantX)**
*   **Datei:** `content/scripts/screen_radar.lua`
*   **Original Code:**
    Monolithische `update()` Funktion, die alles zeichnet.
*   **Mod Code:**
    ```lua
    local old_update = update
    function update()
        if old_update then old_update() end
        -- Custom Code:
        draw_range_rings()
        draw_bearing_lines()
    end
    ```
*   **Analyse:**
    Nutzt Hooks (Wrapper), um Vanilla-Logik beizubehalten und nur Overlays hinzuzufügen.
    *Bewertung:* ✅ Best Practice für Mod-Kompatibilität.

### **Vehicle IDs (Autor: HSAR)**
*   **Datei:** `screen_vehicle_control.lua`
*   **Technik:** `update_get_screen_world_to_screen`
*   **Code-Ablauf:**
    1. Loop über alle Vehikel (`update_get_map_vehicle_by_index`).
    2. Prüfe Distanz (`update_get_logic_vehicle_position`).
    3. Wandle 3D-Pos in 2D-Screen-Pos um.
    4. Zeichne Text-ID.
*   **Bewertung:** Performance-intensiv (O(n) pro Frame), aber notwendig.

---

## 3. Waffen-Mods (XML)

### **Supersonic Cruise Missile**
*   **Datei:** `missile_cruise.xml`
*   **Mod Code:**
    `force_emitter magnitude="3000.0"`
*   **Analyse:**
    Extremwert. Führt zu "Tunneling" (Durchfliegen von Objekten ohne Kollision).
    *Bewertung:* ❌ Technisch unsauber. Engine Limit überschritten.

### **Mark84 bomb**
*   **Code Code:**
    Erhöhter `explosion_radius` in der `projectile.xml`.
*   **Analyse:**
    Simpler XML-Tweak.
    *Bewertung:* ⚠️ Okay, aber visueller Effekt (Partikel) skaliert nicht automatisch mit -> Diskrepanz zwischen Explosion und Schaden.

### **20mm Balance Test**
*   **Betroffene Dateien:**
    *   `content/game_objects/vehicle_attachment_carrier_turret_ciws.xml`
    *   `content/game_objects/vehicle_attachment_turret_ciws.xml`
    *   `content/game_objects/vehicle_attachment_turret_plane_chaingun.xml`
    *   `content/game_objects/vehicle_attachment_turret_plane_ciws.xml` (Neu)
*   **Original Code (Vanilla):**
    *   CIWS (Carrier/Turret): `fov="3.99999991e-02"` (ca. 2.3°)
    *   Plane Chaingun: `fov="9.99999978e-03"` (ca. 0.5°)
*   **Mod Code:**
    *   CIWS (Carrier/Turret): `fov="1.00000000e+00"` (ca. 57°)
    *   Plane Chaingun/CIWS: `fov="0.00000000e+00"` (0°, Punktgenau)
*   **Analyse:**
    Erhöht den Streukreis (FOV) von Schiffs-CIWS massiv (von 2° auf 57°), was die Effektivität auf Distanz drastisch senkt (Schrotflinten-Effekt).
    Im Gegensatz dazu wird die Flugzeug-Bordkanone (und die neue Plane-CIWS Variante) auf 0° Streuung gesetzt (Laser-Präzision).
    *Bewertung:* ⚠️ Extreme Balance-Änderung. CIWS wird zur Nahbereichswaffe degradiert, Flugzeuge erhalten Sniper-Präzision.

---

## 4. Audio & Assets

### **Alarm Mods (Wolfenstein / Star Wars)**
*   **Technik:** File Replacement (`alarm_general_quarters.wav`).
*   **Problem:**
    Das Dateisystem ist "Last One Wins". Der User hat keine Wahl im Spiel.
*   **Bessere Lösung:**
    `audio:play_event("custom_alarm")` per Lua triggern.

---

## 5. Map & Tiles

### **Larger Airfields (Autor: Bredroll)**
*   **Datei:** `content/tiles/tile_airfield_large.xml`
*   **Code-Analyse:**
    Ändert die Definition der Kachel.
    ```xml
    <runway length="2000"> <!-- Vanilla: 800 -->
    ```
*   **Analyse:**
    Beeinflusst auch das KI-Verhalten (Pathfinding), da die KI die Landebahn-Länge ausliest.
    *Bewertung:* ✅ Sauber implementiert.

---
*Detaillierte Analyse erstellt basierend auf V11b Daten.*
