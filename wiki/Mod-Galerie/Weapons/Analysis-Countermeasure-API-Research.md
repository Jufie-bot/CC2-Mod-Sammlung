# Analyse: Forschungsbericht zu Gegenmaßnahmen (GGM) API

## Übersicht
In dieser Forschungsreihe wurde untersucht, inwieweit die automatische Auslösung von Gegenmaßnahmen (Flares und Torpedo-Noisemaker/Decoys) über Lua-Skripte in Carrier Command 2 (CC2) möglich ist.

## Wichtigste Ergebnisse

### 1. Flare-Launcher (Carrier)
*   **Definition:** `attachment_turret_carrier_flare_launcher` (ID 29).
*   **Steuerung:** Die Auslösung erfolgt im Originalspiel über physische Brücken-Buttons (`carrier_weapons_fire_8`).
*   **Lua-API:** Es existiert **keine direkte Lua-Funktion** (z.B. `fire_flare()`), um den Launcher auszulösen.
*   **Moduszustand:** Der `control_mode` unterstützt für Flares keinen "Auto"-Modus, der eigenständig auf Bedrohungen reagiert.
*   **Fazit:** Eine direkte Automatisierung des verbauten Launchers via Lua ist nicht vorgesehen.

### 2. Torpedos & Abwehr (Hardpoints)
*   **KI-Verhalten:** Einheiten können über Wegpunkte mit `e_attack_type.torpedo_single` angewiesen werden, Torpedos abzufeuern.
*   **Defensiv-Systeme:** Ähnlich wie bei Flares gibt es für Hardpoint-Gegenmaßnahmen (Decoys, Noisemaker) keine skriptbare "Instant-Fire"-Schnittstelle für den Spieler-Carrier.
*   **Team-System:** In `e_team_target_weapon_type` ist `carrier_flare` (ID 2) definiert. Dies deutet darauf hin, dass die Engine intern Flares als "Anforderung" behandelt, für die es jedoch keine Lua-Schnittstelle zur Einreichung gibt.

### 3. Technische Details & Konstanten
*   **Sound-IDs:** `flare_launch` (ID 19) wird beim Abfeuern abgespielt.
*   **Ammo-Kapazität:** Standardmäßig 10-16 Schuss (definiert in `constants.txt`).
*   **Input-ID:** `e_game_input.attachment_fire` (ID 20) wird für das manuelle Abfeuern verwendet.

## Implementierungsideen für die Zukunft (Automatisierung)

Obwohl ein direkter Funktionsaufruf fehlt, gibt es zwei theoretische Lösungsansätze für eine "Automatisierung":

1.  **Objekt-Spawning (Simulation):** 
    Ein Skript erkennt eintreffende Bedrohungen (via Radar-Analyse) und spawnt bei Bedarf ein neues Flare-Objekt (`torpedo_decoy` oder ähnliches) direkt an der Position des Carriers. Dies umgeht den eigentlichen Launcher-Mechanismus.
    
2.  **Input-Simulierung (Hack):**
    Theoretische Simulation des Button-Drucks auf der Brücke. Dies ist jedoch hochkomplex und instabil, da es den Fokus des Spielers beeinflussen könnte.

## Zusammenfassung
Die Automatisierung von Gegenmaßnahmen ist **prinzipiell machbar**, erfordert aber einen Workaround über das Spawning von Entitäten, da die Engine keine skriptgesteuerte Auslösung der vorhandenen Launcher-Hardware erlaubt.

---
*Erstellt am: 17.03.2026*
*Status: Abgeschlossen (Forschung)*
