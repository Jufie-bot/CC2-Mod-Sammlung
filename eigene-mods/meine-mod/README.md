# Skynet Mod V4 - Dokumentation

Willkommen in der Entwickler-Dokumentation für **Skynet V4**, einer umfassenden Modifikation für Carrier Command 2.

Diese Datei dient als lebendes Dokument. Sie wird bei jedem Update aktualisiert, um den aktuellen Stand der Features und technischen Implementierungen festzuhalten.

---

## 🚀 Übersicht
**Ziel der Mod:** Ein intelligenterer, bedrohlicherer Computer-Gegner ("Skynet"), kombiniert mit atmosphärischen Grafik- und Sound-Verbesserungen.

*   **Version:** V4.0 (Stand: 14.02.2026)
*   **Autor:** Antigravity / User
*   **Status:** In aktiver Entwicklung

---

## 🧠 1. KI-System (Skynet)

Die KI-Logik befindet sich in: `content/scripts/library_custom_3.lua`

### Funktionsweise
Die Mod klinkt sich über einen Hook in den `holomap_screen` ein und führt alle 20 Sekunden eine KI-Routine aus.

### A. Alarm-Stufen
Skynet unterscheidet drei Bedrohungs-Level, basierend auf der Sichtbarkeit und Position des Spielers:
*   **Stufe 0 (Frieden):** Standard-Zustand. Passive Patrouillen.
*   **Stufe 1 (Warnung):** Spieler in Radar-Reichweite (<5km zur Basis).
*   **Stufe 2 (Krieg):** Akute Bedrohung (<2km zur Basis). Skynet mobilisiert alle verfügbaren Einheiten.

### B. Verbesserte Taktik (V4)
*   **Elite-Inseln:** Einheiten, die von schweren Inseln (Schwierigkeit 3+) stammen, stürmen nicht blind los. Sie haben eine 50%-Chance, im Hinterhalt zu warten ("Ambush").
*   **Torpedo-Einsatz:** Einheiten (z.B. Seals, Mantas) prüfen, ob das Ziel ein Schiff ist. Wenn ja, feuern sie bevorzugt Torpedos ab.
*   **Jitter-Bewegung:** Zielkoordinaten werden leicht variiert ("Jitter"), damit KI-Gruppen nicht als Klumpen auf denselben Punkt fahren.

### C. Produktion
Wenn Alarm herrscht und die Warteschlangen leer sind, produziert Skynet autonom Nachschub:
*   33% **Bear** (Schwerer Panzer)
*   33% **Seal** (Amphibien-Fahrzeug)
*   34% **Albatross** (Luftüberlegenheit)

---

## 🎨 2. Grafik & Atmosphäre

### Beleuchtung (Blue Bridge)
*   **Datei:** `content/game_objects/vehicle_chassis_carrier.xml`
*   **Änderung:** Die Standard-Beleuchtung der Brücke und des Hangars wurde durch kühles, blaues Licht ersetzt, um eine "High-Tech"-Atmosphäre zu schaffen.
*   *Hinweis:* Dies geschieht durch physikalische Lichtquellen im XML, nicht durch Post-Processing.

### Shader
*   **Dateien:** `content/shaders/ocean_foam.glsl`, `ocean_volume.glsl`
*   **Änderung:** Anpassungen an der Darstellung von Schaumkronen und Wasservolumen für realistischere Ozeane.

---

## 🔊 3. Audio

### Alarm-System
*   **Dateien:** `content/audio/bridge_alarm_*.ogg`
*   **Änderung:** Die Standard-Alarmsounds ("General Quarters") wurden durch eigene, bedrohlichere Sounds ersetzt. Diese werden situationsabhängig abgespielt.

---

## 🛠️ Geplante Features & To-Do

*   [ ] **Ressourcen-Check:** Die KI-Produktion soll prüfen, ob genug Geld da ist.
*   [ ] **Config-Datei:** Auslagern von festen Werten (Chassis-IDs, Timer) in eine `config.lua`.
