# Modding Grundlagen

Basierend auf der offiziellen Geometa-Dokumentation.

## 1. Wie Mods funktionieren
Mods in Carrier Command 2 funktionieren ausschließlich durch das **Überschreiben (Override)** von Dateien.
*   Es gibt keinen "Merge"-Mechanismus für Dateien. Wenn zwei Mods dieselbe Datei ändern (z.B. `vehicle_hud.lua`), ist nur die Mod aktiv, die zuletzt geladen wurde ("Last one wins").
*   Du kannst keine völlig neuen Dateitypen einführen, sondern nur bestehende Assets aus dem Spiel (`rom_0`) ersetzen.

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

## 4. Save-Editing (Fortgeschritten)
Das direkte Bearbeiten der `save.xml`-Dateien eröffnet viele Möglichkeiten, die über normales Modding hinausgehen, birgt aber auch ein hohes Absturzrisiko.

**Mögliche Modifikationen per Save-Game:**
*   Menschlichen Teams bestimmte Einheiten geben (z.B. Swordfish).
*   Beliebige Waffen an Flugzeuge, Schiffe oder Türme montieren.
*   Inseln hinzufügen oder entfernen (bis zum Limit von 64).
*   Inventar von Träger und Inseln direkt modifizieren.
*   Insel-Biome und Produktionsarten ändern.

**Community Map-Editoren (Empfohlen):**
Anstatt die XML manuell zu bearbeiten, solltest du diese Tools nutzen:
*   [**cc2me**](https://github.com/cc2modteam/cc2me): Fügt/entfernt Einheiten und Inseln, ändert Waffen und Munitionszahlen.
*   [**carrier command 2 saves editor**](https://bitbucket.org/Developpeur3d/carrier-command-2-saves-editor/src/master/): Ändert Carrier Inventar, Insel-Blueprints und fügt/entfernt Inseln.
