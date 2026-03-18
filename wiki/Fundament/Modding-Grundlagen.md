# Modding Grundlagen

Basierend auf der offiziellen Geometa-Dokumentation.

## 1. Wie Mods funktionieren
Mods in Carrier Command 2 funktionieren ausschließlich durch das **Überschreiben (Override)** von Dateien.
*   Es gibt keinen "Merge"-Mechanismus für Dateien. Wenn zwei Mods dieselbe Datei ändern (z. B. `vehicle_hud.lua`), ist nur die Mod aktiv, die zuletzt geladen wurde ("Last one wins").
*   Du kannst keine völlig neuen Dateitypen einführen, sondern nur bestehende Assets aus dem Spiel (`rom_0`) ersetzen.

## 2. Fähigkeiten & Grenzen des Moddings
Das Modding-System von CC2 ist mächtig, hat aber spezifische Grenzen je nach Dateityp.

### Was modifiziert werden kann:
*   **Kontrollbildschirme**: Zusätzliche Wegpunkt-Optionen, Loadout-Limits, neue Bildschirme für Träger oder Einheiten.
*   **Fahrzeug-HUD & Kameras**: Zusätzliche Details in der Zielansicht, Treibstoff-Timer, erweiterte Zielerfassungs-Modi.
*   **Fahrzeug-Konfiguration**: Hinzufügen oder Verschieben von Hardpoints (via XML).
*   **Waffen-Physik**: Streuung von Schiffsgeschützen, Geschwindigkeiten von Raketen und Torpedos.
*   **Visuals & Audio**: Skins, neue 3D-Modelle für Einheiten, neue Soundeffekte.

### Aktuelle Limitierungen (Hardcoded):
*   Munitionskapazität von Waffen ändern.
*   Schadenswerte von Waffen ändern (nur indirekt via Physik/Explosion).
*   Hitpoints oder Treibstoffkapazität von Einheiten ändern.
*   Völlig neue Einheiten-Typen erstellen (man kann nur bestehende Chassis ersetzen).
*   Flugzeuge auf Inseln, Barken oder Needlefish landen lassen.

### Skript-Beschränkungen nach Kontext
Nicht alle Skripte haben Zugriff auf dieselben nativen Funktionen:

| Skript | Zugriff auf Fahrzeuge | Sounds abspielen | Besonderheit |
| :--- | :--- | :--- | :--- |
| `screen_vehicle_control.lua` | Ja | Nein | Hauptsteuerung |
| `screen_radar.lua` | Nein | Ja | Radar-Logik |
| `screen_weapons_anti_air.lua` | Nein | Ja | Waffen-Steuerung |
| `vehicle_hud.lua` | Teilweise | Nein | Eingeschränkter Scope |

## 3. Ordnerstruktur

## 2. Ordnerstruktur
Jede Mod benötigt einen eigenen Ordner im Mod-Verzeichnis:
*   **Windows:** `%appdata%\Carrier Command 2\mods\<ModName>`
*   **Mac:** `~/Library/Application Support/Carrier Command 2/mods/<ModName>`

### Wichtige Dateien
1.  **`mod.xml`**: Die Definitionsdatei.
    ```xml
    <?xml version="1.0" encoding="UTF-8"?>
    <data name="Mein Mod Name" author="Dein Name" description="Beschreibung deiner Mod." />
    ```
2.  **`thumbnail.png`**: Vorschaubild für den Steam Workshop (Quadratisch empfohlen).
3.  **`content/`**: Dieser Ordner spiegelt die Spielstruktur wider. Dateien hier ersetzen die Originaldateien.
    *   *Beispiel:* Um das HUD zu ändern, muss deine Datei hier liegen: `content/scripts/vehicle_hud.lua`.

## 3. Das Mod Dev Kit (SDK)
Das Spiel liefert ein `mod_dev_kit` (zu finden im Spielordner).
*   **`source`**: Enthält die unkompilierten Originaldateien (Modelle, Texturen, Skripte).
*   **`bin`**: Enthält Tools wie `build_content.exe`.

### Workflow
1.  Kopiere `bin` und `source` in deinen Mod-Ordner.
2.  Lösche aus `source` alles, was du **nicht** ändern willst (spart Kompilierzeit).
3.  Bearbeite die Dateien im `source`-Ordner.
4.  Führe `bin/build_content.exe` aus.
    *   Dies kompiliert deine Änderungen und schiebt sie in den `content/`-Ordner, wo das Spiel sie lesen kann.

> [!WARNING]
> Änderungen direkt im `content/`-Ordner funktionieren bei Skripten (`.lua`, `.xml`), aber Modelle und Texturen müssen zwingend durch den Compiler laufen!

## 5. Weiterführende Themen
*   [[Save Editing]] – Fortgeschrittenes Editieren von Speicherständen für tiefergreifende Änderungen.
*   [[Lua Debugging]] – Guide zur Fehlersuche in Skripten.
