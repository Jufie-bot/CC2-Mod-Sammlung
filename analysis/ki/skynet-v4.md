# Skynet V4 - Technische Analyse

Dieses Dokument schlüsselt die Funktionsweise deiner aktuellen **Skynet V4 Mod** auf.
Es basiert auf dem Scan des Ordners `f:/Workspace/Meine Mod`.

---

## 1. Kern-Logik (`library_custom_3.lua`)
Das Herzstück der Mod. Hier "denkt" Skynet.

### Architektur
*   **Hook:** Die Mod klinkt sich in `holomap_screen` ein. Sobald dieser geladen wird, überschreibt sie die globale `update()` Funktion mit einem Wrapper (`wrap_update`), der alle 20 Sekunden (`g_skynet_interval = 600`) die KI-Logik feuert.
*   **Zustand:** Skynet speichert einen globalen Alarm-Status (`g_skynet_alarm_level`: 0=Peace, 1=Warning, 2=War).

### Die 3 Säulen der KI
1.  **Bedrohungsanalyse (`skynet_assess_threat`)**
    *   Prüft, ob der Spieler sichtbar ist (`is_visible`).
    *   Prüft Distanz zur nächsten KI-Basis.
    *   **Logik:**
        *   Sichtbar + <5km Basis-Nähe -> **Alarm Stufe 1 (Warnung)**.
        *   Stufe 1 + <2km Basis-Nähe -> **Alarm Stufe 2 (Krieg)**.
        *   Wenn unsichtbar: Alarm läuft nach Timer (50 Sek) ab.

2.  **Produktion (`skynet_production`)**
    *   Läuft nur bei Alarm > 0.
    *   Iteriert über *alle* KI-Fabriken.
    *   **Logik:** Wenn Warteschlange leer ist, baue Einheiten nach Zufall:
        *   33% **Bear** (Chassis 6)
        *   33% **Seal** (Chassis 77)
        *   34% **Albatross** (Chassis 10)

3.  **Taktik (`skynet_tactics`)**
    *   Läuft nur bei Alarm > 0.
    *   Steuert Fahrzeuge im Radius von 10km um den Spieler.
    *   **Features:**
        *   **Elite-Inseln (V4):** Einheiten von schweren Inseln (Level 3+) warten zu 50% im Hinterhalt, statt blind anzugreifen.
        *   **Torpedo-Nutzung (V4):** Wenn eine Einheit Torpedos hat, nutzt sie diese bevorzugt gegen Schiffe (Statusmeldung: *"Einheit X feuert Torpedos!"*).
        *   **Jitter:** Fügt dem Zielpunkt Zufall rauschen hinzu, damit Einheiten nicht alle exakt auf denselben Punkt fahren.

---

## 2. Visuelle & Audio Änderungen

### UI (`screen_navigation.lua`)
*   Das ist der Navigations-Bildschirm.
*   **Map Mode:** Scheint die verschiedenen Karten-Modi (Niederschlag, Nebel etc.) per UI steuerbar zu machen.
*   **Carrier Launch:** Beinhaltet Logik zum Starten des Trägers aus dem Dock.
*   *Anmerkung:* Diese Datei sieht sehr nach Vanilla-Code mit minimalen Anpassungen aus.

### Audio (`content/audio/`)
*   Enthält 4 Varianten von `bridge_alarm_*.ogg`.
*   Das deutet darauf hin, dass der Alarmton per `constants.txt` oder Skript ausgetauscht wurde.

### Grafik (`vehicle_chassis_carrier.xml`)
*   Sehr große Datei (4000+ Zeilen).
*   Definiert das physikalische Modell, Meshes und Lichter des Trägers.
*   Sieht nach der Basis für visuelle Mods wie "Blue Bridge Light" aus.

---

## 3. Bewertung der Code-Qualität

### ✅ Positiv (Gut gelöst)
*   **Hooking:** `library_custom_3.lua` nutzt einen sauberen Hook (`old_update`), statt Vanilla-Dateien zu löschen. Das macht die KI sehr kompatibel.
*   **State Machine:** Die Unterscheidung in Alarm-Stufen (0, 1, 2) ist eine solide Basis für komplexes Verhalten.
*   **Performance:** Die Begrenzung auf alle 20 Sekunden (`ticks`) ist klug, um Lag zu vermeiden.

### ⚠️ Verbesserungspotenzial
*   **Hardcoding:** Viele Werte (Chassis-IDs 6, 77, 10) sind fest im Code. Besser wäre eine Config-Tabelle am Anfang.
*   **Modulladung:** Der Hook in `holomap_screen` ist etwas fragil. Wenn der User nie die Map öffnet, startet Skynet theoretisch nie? (Muss geprüft werden).
*   **Schwachstelle Produktion:** Skynet spammt die Queue voll, prüft aber nicht, ob *Ressourcen* da sind. Das könnte die KI-Wirtschaft bankrott machen.

---
*Analyse-Stand: 2026-02-14 (V4)*
