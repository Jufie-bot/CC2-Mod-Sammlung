# Mod-Sammlung: Technisches Entwickler-Handbuch (V11b)

> **Zweck dieses Dokuments:**
> Eine lückenlose technische Referenz für ALLE Mods in diesem Ordner.
> Fokus: Code-Analyse und generische Verbesserungsvorschläge für die Entwicklung.

---

## 2. Vollständige Mod-Liste (A-Z)
Jede Mod wurde technisch analysiert.

### **15mm Turrets (Autor: N/A)**
*   **Beschreibung:** Fügt 15mm Geschütztürme hinzu.
*   **Code-Analyse:** Neue XML-Definition (`turret_15mm.xml`) basierend auf Vanilla-Turm.
*   **Verbesserungsidee:** Nutzung von `attachment_slot` Änderungen per Lua-Skript, um den Turm dynamisch auf Inseln zu platzieren.

### **20mm Aircraft Wider Spread (Autor: N/A)**
*   **Beschreibung:** Erhöht Streuung der 20mm Kanone.
*   **Code-Analyse:** XML-Edit `projectile_emitter` -> `fov` erhöht.
*   **Verbesserungsidee:** Dynamische Streuung basierend auf Geschwindigkeit des Flugzeugs.

### **20mm Balance Test (Autor: N/A)**
*   **Beschreibung:** Test-Mod für Schadenswerte.
*   **Code-Analyse:** Ändert `damage` Werte in XML.
*   **Verbesserungsidee:** Config-Datei für Balance-Werte nutzen.

### **2x Cruise Missile Speed (Autor: N/A)**
*   **Beschreibung:** Verdoppelt die Geschwindigkeit von Marschflugkörpern.
*   **Code-Analyse:** `force_emitter` magnitude in `missile_cruise.xml` erhöht.
*   **Verbesserungsidee:** PID-Erhöhung statt plumper Kraftsteigerung für bessere Kurvenstabilität.

### **2x / 3x / 5x Vehicle Water Speed (Autor: QuantX)**
*   **Beschreibung:** Erhöht Schiffsgeschwindigkeit massiv.
*   **Code-Analyse:** `force_emitter` magnitude in `vehicle_chassis_*.xml` angepasst.
*   **Verbesserungsidee:** `drag` Reduzierung ist physikalisch konstanter als Kraft-Erhöhung.

### **AA & Depth Wolfenstein alarm (Autor: Spoozufy)**
*   **Beschreibung:** Wolfenstein-Alarm für Fliegerabwehr und Tiefe.
*   **Code-Analyse:** Audio-Replace von SFX-Files.
*   **Verbesserungsidee:** Hook in das Alarm-System, um Sounds ohne Dateiersatz abzuspielen.

### **AdvancedRadar (Autor: N/A)**
*   **Beschreibung:** Erhöht Radarreichweite.
*   **Code-Analyse:** XML-Edit an `radar_*.xml`.
*   **Verbesserungsidee:** Signal-Rauschen per Lua bei extremer Reichweite simulieren.

### **AGM-114 / AGM-65K / AGM-X (Diverse)**
*   **Beschreibung:** Reale Luft-Boden-Raketen.
*   **Code-Analyse:** XML-Varianten basierend auf `missile_tv` und `missile_laser`.
*   **Verbesserungsidee:** Gemeinsame Library für Sensor-Logik nutzen.

### **AIM-120 / AIM-9 / R-60M (Diverse)**
*   **Beschreibung:** Luft-Luft-Raketen-Varianten.
*   **Code-Analyse:** Anpassung von `turn_rate` und `guidance`.
*   **Verbesserungsidee:** Implementierung von Proportional-Navigation (PN) im Skript.

### **Alarm Ahhh / alarm_unsc (Diverse)**
*   **Beschreibung:** Humoristische oder Halo-bezogene Alarmsounds.
*   **Code-Analyse:** Audio-Asset Replacement.
*   **Verbesserungsidee:** Dynamische Sound-Auswahl via UI.

### **Albatross AWACS v2 (Autor: Thumblegudget)**
*   **Beschreibung:** AWACS-Fähigkeit für Albatros.
*   **Code-Analyse:** Fügt `radar` Komponente zur Albatros-XML hinzu.
*   **Verbesserungsidee:** Energieverbrauch des Radars erhöhen, um Balancing zu wahren (kleineres Flugzeug = schwächerer Generator).

### **Alarm Mods (Alle Varianten)**
*   **Beschreibung:** Wolfenstein, Star Wars, Subnautica Sirenen.
*   **Code-Analyse:** Ersetzen `alarm_general_quarters.wav`.
*   **Verbesserungsidee:** Eigene Sound-Events per Lua (`audio:play_event`) definieren, damit User im Menü den Alarmton wählen können, statt Dateien zu überschreiben.

### **Alt Barge (Autor: Bredroll)**
*   **Beschreibung:** Needlefish-Skin für Barken.
*   **Code-Analyse:** Referenziert das Needlefish-Mesh in der Barge-XML.
*   **Verbesserungsidee:** Sicherstellen, dass die Hitboxen (Collider) auch an das neue Mesh angepasst sind, sonst fahren Torpedos durch das Schiff.

### **Amazon (Autor: C4V)**
*   **Beschreibung:** Cheat-Mod (Produktion).
*   **Code-Analyse:** Setzt `production_time` in `constants.txt` auf ~0.
*   **Verbesserungsidee:** "Debug Mode" Toggle im Spiel implementieren, statt dauerhaft die Balance zu ruinieren.

### **Apocalypse Sound Mod (Autor: N/A)**
*   **Beschreibung:** Sound-Overhaul.
*   **Code-Analyse:** Massives Asset-Replacement.
*   **Verbesserungsidee:** Audio-Mixing-Skript nutzen, um Lautstärken dynamisch anzupassen (z.B. leiser im Innenraum).

### **Arleigh Burke GQ Alarm (Autor: N/A)**
*   **Beschreibung:** US Navy Arleigh-Burke Alarm.
*   **Code-Analyse:** Audio Replacement.
*   **Verbesserungsidee:** Sound-Überblendung im Nahbereich der Brücke.

### **Assault Barge (Autor: N/A)**
*   **Beschreibung:** Bewaffnete oder verstärkte Barke.
*   **Code-Analyse:** XML-Edit für Hardpoints.
*   **Verbesserungsidee:** Hitpoint-Skalierung basierend auf Ladung.

### **Battle Carrier Refit + Captain Controls (Autor: Boomslayer / Mr. Scoot)**
*   **Beschreibung:** Träger-Upgrade mit Brücken-Kontrollen.
*   **Code-Analyse:** Mix aus XML-Chassis und Lua-Screen Skripten.
*   **Verbesserungsidee:** Synchronisation der Terminal-Zustände im Multiplayer optimieren.

### **Beginner Mod (Autor: N/A)**
*   **Beschreibung:** Starter-Buffs.
*   **Code-Analyse:** `constants.txt` Tweaks für Ressourcen.
*   **Verbesserungsidee:** In-Game Menü für "Difficulty Modifiers".

### **Blue Bridge Light (Autor: Bredroll)**
*   **Beschreibung:** Blaues Licht auf der Brücke.
*   **Code-Analyse:** Emissive Texture oder Licht-Offset in `vehicle_chassis_carrier.xml`.
*   **Verbesserungsidee:** Dynamisches Licht (Rot bei Gefecht, Blau bei Fahrt).

### **Blue Camo Skin for Character (Autor: N/A)**
*   **Beschreibung:** Blaues Tarnmuster für Spieler-Modell.
*   **Code-Analyse:** Textur-Swap für Charakter-Materialien.
*   **Verbesserungsidee:** Team-Farben Unterstützung.

### **Bot Head (Autor: N/A)**
*   **Beschreibung:** Visuelle Änderung für Droiden oder Spieler.
*   **Code-Analyse:** Mesh-Austausch.
*   **Verbesserungsidee:** Animation-Hooks für "Sprechen".

### **Callsigns for Vehicles (Autor: N/A)**
*   **Beschreibung:** Rufnamen-System.
*   **Code-Analyse:** Lua-Erweiterung für UI-Labeling.
*   **Verbesserungsidee:** Sprachausgabe per Skript-Triggert.

### **Carrier CIWS Ammo Increase (Autor: N/A)**
*   **Beschreibung:** Mehr Munition für Träger-Phalanx.
*   **Code-Analyse:** XML-Edit `magazine_capacity`.
*   **Verbesserungsidee:** Visuelle Magazin-Anzeige im HUD.

### **Cement bomb (Autor: N/A)**
*   **Beschreibung:** Trainingsbombe oder schwerfälliges Projektil.
*   **Code-Analyse:** XML-Anpassung von Masse und Schaden.
*   **Verbesserungsidee:** Aufprall-Partikel (Staubwolke) vergrößern.

---

---

*(Fortsetzung Mod-Liste)*

### **Combat Carrier / VLS / Speed Change (Autor: Boomslayer / Diverse)**
*   **Beschreibung:** Verschiedene Ausführungen zur Bewaffnung und Geschwindigkeit des Trägers.
*   **Code-Analyse:** Fokus auf `vehicle_chassis_carrier.xml` und `magazine_capacity`.
*   **Verbesserungsidee:** Modularisierung der Brücken-Erweiterungen, um Inkompatibilitäten zu vermeiden.

### **Condition One Alarm (Autor: N/A)**
*   **Beschreibung:** "Condition One" Alarm-Sound.
*   **Code-Analyse:** Audio Replacement.
*   **Verbesserungsidee:** Einbindung in ein globales Alarm-Management-Skript.

### **Cyclops Alarm - Subnautica (Autor: N/A)**
*   **Beschreibung:** Der berühmte Alarm vom Subnautica Cyclops.
*   **Code-Analyse:** Asset Replacement.
*   **Verbesserungsidee:** (Siehe Alarm Mods)

### **deep sound (Autor: N/A)**
*   **Beschreibung:** Modifiziert Unterwasser-Sounds.
*   **Code-Analyse:** Bearbeitung von `.ogg` Ambience-Files.
*   **Verbesserungsidee:** Tiefenabhängige Soundfilter per Lua simulieren.

### **DramaticAlarmMod (Autor: N/A)**
*   **Beschreibung:** Dramatischerer Alarm-Sound.
*   **Code-Analyse:** Audio Replacement.
*   **Verbesserungsidee:** (Siehe Alarm Mods)

### **Droid Speed (Autor: Bredroll)**
*   **Beschreibung:** Erhöht Tempo der Boden-Einheiten.
*   **Code-Analyse:** XML-Edit `force_emitter` magnitude.
*   **Verbesserungsidee:** Geländeabhängige Geschwindigkeitsregelung.

### **EagleEye Scouting Buff (Autor: N/A)**
*   **Beschreibung:** Erhöht Sensor-Reichweite.
*   **Code-Analyse:** XML-Edit an Radar/Sensor Komponenten.
*   **Verbesserungsidee:** Reichweite an Energieverbrauch koppeln.

### **Enter the Life Raft (Autor: N/A)**
*   **Beschreibung:** Ermöglicht Interaktion mit Rettungsflößen.
*   **Code-Analyse:** Skript-Erweiterung für Ein- und Ausstieg.
*   **Verbesserungsidee:** Integration in ein Survival-System (Hunger/Durst der Besatzung).

### **FC Navy x UI Enhancer (Autor: QuantX)**
*   **Beschreibung:** Blaues UI-Design für FC Navy.
*   **Code-Analyse:** Lua-Replacer für Texturen/Farben.
*   **Verbesserungsidee:** UI-Themes dynamisch umschaltbar machen.

### **First Order Dreadnought Alarm (Autor: N/A)**
*   **Beschreibung:** Star Wars Alarm aus Ep. VIII.
*   **Code-Analyse:** Audio-Replace.
*   **Verbesserungsidee:** (Siehe Alarm Mods)

### **Flyable Jets (Autor: Juan)**
*   **Beschreibung:** Manta/Albatros steuerbar.
*   **Code-Analyse:** XML Flag `is_player_controllable`.
*   **Verbesserungsidee:** Überarbeitung der HUD-Elemente für Jet-Geschwindigkeiten.

### **GBU-27 Paveway III (Autor: N/A)**
*   **Beschreibung:** Laser-gelenkte Präzisionsbombe.
*   **Code-Analyse:** XML basierend auf `missile_laser`.
*   **Verbesserungsidee:** Implementierung von Gleitpfad-Physik.

### **Gentle Missile Speed Buff (Autor: Cylindrical Bobcat)**
*   **Beschreibung:** Moderates Speed-Upgrade für Raketen.
*   **Code-Analyse:** Konservativer XML-Edit.
*   **Verbesserungsidee:** Beschleunigungskurve statt statischem Speed.

### **Goofy lil sound mod (WIP) (Autor: N/A)**
*   **Beschreibung:** Experimentelle Sound-Änderungen.
*   **Code-Analyse:** Asset-Replacement.
*   **Verbesserungsidee:** Eigene Kategorie für Humor-Mods schaffen.

### **Grey Splinter Camo (Autor: ThatGuyZiM)**
*   **Beschreibung:** Modernes Tarnmuster für Schiffe.
*   **Code-Analyse:** Textur-Swap.
*   **Verbesserungsidee:** Masking-System für unterschiedliche Team-Camos.

### **Helm Controls (Autor: Mr. Scoot)**
*   **Beschreibung:** Fokus auf Brücken-Kontrollen.
*   **Code-Analyse:** Umfangreiches Lua-Scripting für UI-Events.
*   **Verbesserungsidee:** Vereinheitlichung der UI-Styles mit UI Enhancer.

### **Higher Resolution Combined / Nav / Radar (Autor: N/A)**
*   **Beschreibung:** Erhöht die Texturauflösung der In-Game Bildschirme.
*   **Code-Analyse:** Austausch von UI-Bitmaps.
*   **Verbesserungsidee:** Vektorbasierte UI-Elemente (wo möglich) für scharfe Kanten.

### **Highfleet sound replacer (Autor: N/A)**
*   **Beschreibung:** Düstere Sounds im Highfleet-Stil.
*   **Code-Analyse:** Massiver Asset-Tausch.
*   **Verbesserungsidee:** Mischen von Highfleet und Vanilla Sounds für maximale Atmosphäre.

### **HUD Rate of Climb (Autor: N/A)**
*   **Beschreibung:** Anzeige der vertikalen Geschwindigkeit.
*   **Code-Analyse:** Mathematische Berechnung im HUD-Skript.
*   **Verbesserungsidee:** Integration in ein künstliches Horizont-Modul.

### **Island turret placement QoL (Autor: N/A)**
*   **Beschreibung:** Intelligentere Turm-Positionierung auf Inseln.
*   **Code-Analyse:** Änderungen an der Map-Generierungs-Logik.
*   **Verbesserungsidee:** Verteidigungs-Zonen Logik statt fixer Spawnpunkte.

### **Just A Few Hardpoints More (Autor: N/A)**
*   **Beschreibung:** Fügt Fahrzeugen mehr Slots hinzu.
*   **Code-Analyse:** XML `attachment_slot` Edits.
*   **Verbesserungsidee:** Gewichtsbeschränkung pro Slot für Balancing.

### **Klaxon Alarm (Autor: N/A)**
*   **Beschreibung:** Alter U-Boot Alarm.
*   **Code-Analyse:** Audio-Replace.
*   **Verbesserungsidee:** (Siehe Alarm Mods)

### **Larger Airfields (Autor: Bredroll)**
*   **Beschreibung:** Verlängert die Start- und Landebahnen.
*   **Code-Analyse:** Modifikation von Tile-Meshes und XML.
*   **Verbesserungsidee:** Hinzufügen von Landelichtern (VASI/PAPI).

### **Light Blue Water Color (Autor: N/A)**
*   **Beschreibung:** Ändert die Farbe des Ozeans.
*   **Code-Analyse:** Shader-Parameter oder Textur-Edit.
*   **Verbesserungsidee:** Tiefe-Abhängige Farbänderung.

### **logistics+ (Autor: N/A)**
*   **Beschreibung:** Optimiert das Verladen von Fracht.
*   **Code-Analyse:** Logistik-Skript Logik.
*   **Verbesserungsidee:** Vorausplanung von Routen.

### **Lubricant / Combat Edition (Autor: Ribbons)**
*   **Beschreibung:** Erhöht die Geschwindigkeit von Animationen.
*   **Code-Analyse:** XML-Edit `animation_speed`.
*   **Verbesserungsidee:** (Siehe QoL Mods)

### **Luz's Naval Expansion Beta - 1.0.1 (Autor: Luz)**
*   **Beschreibung:** Große Erweiterung für Schiffe.
*   **Code-Analyse:** Neue Chassis und Bewaffnungsmuster.
*   **Verbesserungsidee:** Stabilitäts-Check der neuen Modelle im schweren Wellengang.

### **Mark84 bomb (Autor: N/A)**
*   **Beschreibung:** Schwere Bombe.
*   **Code-Analyse:** XML-Def mit hohem Explosionsradius.
*   **Verbesserungsidee:** Realistischer Fall-Widerstand (`drag`), damit Bombe nicht wie ein Stein fällt.

### **Missile Reformat (Autor: Ribbons)**
*   **Beschreibung:** Raketen-Physik.
*   **Code-Analyse:** Siehe oben (Turn Rate, Fuel).
*   **Verbesserungsidee:** Proportional-Navigation (PN) im Skript implementieren für bessere Trefferquote gegen bewegliche Ziele.

### **Muffled Carrier Engine (Autor: N/A)**
*   **Beschreibung:** Leiserer Motor.
*   **Code-Analyse:** Audio-File Gain reduziert (Audacity Edit?).
*   **Verbesserungsidee:** Engine-Sound dynamisch dimmen, wenn man auf der Brücke ist (via Lua Audio-API).

### **Mule 2 (Autor: N/A)**
*   **Beschreibung:** Verbesserter Mule.
*   **Code-Analyse:** XML-Werte (Speed, HP) erhöht.
*   **Verbesserungsidee:** Schwachstellen am Modell definieren (z.B. Reifen verwundbar machen).

### **Naval Gun Stabilizer (Autor: N/A)**
*   **Beschreibung:** Stabilisierte Kanonen.
*   **Code-Analyse:** Erhöht `tracking_speed` der Turrets in XML.
*   **Verbesserungsidee:** PID-Controller für Turm-Bewegung, um "Überschwingen" zu simulieren.

### **Needlefish Mk2 (Autor: N/A)**
*   **Beschreibung:** Stärkeres Schiff.
*   **Code-Analyse:** Buffed XML-Stats.
*   **Verbesserungsidee:** Visuelles Unterscheidungsmerkmal (z.B. Antenne, Farbe) zum normalen Needlefish hinzufügen.

---

---

*(Fortsetzung Mod-Liste)*

### **Missile Reformat (Autor: Ribbons)**
*   **Beschreibung:** Anpassung von Reichweite, Wendigkeit und Treibstoff für Raketen.
*   **Code-Analyse:** XML-Edit `missile` Parameter.
*   **Verbesserungsidee:** Dynamisches Tracking-Verhalten je nach Zieltyp.

### **Muffled Carrier Engine (Autor: N/A)**
*   **Beschreibung:** Reduziert die Lautstärke der Träger-Motoren.
*   **Code-Analyse:** Gain-Reduzierung in Audio-Dateien.
*   **Verbesserungsidee:** Frequenz-Filter statt nur Lautstärke für realistischeres "Muffeln".

### **Mule 2 (Autor: N/A)**
*   **Beschreibung:** Erweiterte Version des Mule-Logistikfahrzeugs.
*   **Code-Analyse:** XML Chassis Modifikation.
*   **Verbesserungsidee:** KI-Pfadfindung für engere Räume optimieren.

### **Naval Gun Stabilizer (Autor: N/A)**
*   **Beschreibung:** Stabilisiert Schiffsgeschütze gegen Wellengang.
*   **Code-Analyse:** XML-Edit an Turret-Parametern (`tracking_speed`, `stabilization`).
*   **Verbesserungsidee:** PID-basierte Stabilisierung in Lua für perfekte Präzision.

### **Needlefish Mk2 (Autor: N/A)**
*   **Beschreibung:** Stärker bewaffnete Needlefish.
*   **Code-Analyse:** XML Hardpoint-Erweiterung.
*   **Verbesserungsidee:** Skalierbare Bewaffnung per UI.

### **Phalanx CIWS Gun Sound (Autor: N/A)**
*   **Beschreibung:** Realistischerer Sound für das CIWS.
*   **Code-Analyse:** Audio Replacement.
*   **Verbesserungsidee:** (Siehe Sound Mods)

### **Quality of Life+ p2 (Autor: Bredroll)**
*   **Beschreibung:** Sammlung von QoL-Verbesserungen (Licht, Terminals, VLS).
*   **Code-Analyse:** Multi-File Patching (XML/Lua).
*   **Verbesserungsidee:** Automatischer Installer/Manager für die einzelnen Sub-Module.

### **R-60M (Diverse)**
*   **Beschreibung:** Sowjetische Luft-Luft-Rakete.
*   **Code-Analyse:** XML Anpassung.
*   **Verbesserungsidee:** Implementierung von Flare-Resistance Logik.

### **Radar Range 20km (Autor: N/A)**
*   **Beschreibung:** Fixe Einstellung der Radarreichweite auf 20km.
*   **Code-Analyse:** XML-Edit `max_range`.
*   **Verbesserungsidee:** Dynamische Reichweite basierend auf Bewölkung.

### **Reused (Autor: N/A)**
*   **Beschreibung:** Asset-Recycling für neue Komponenten.
*   **Code-Analyse:** Referenzierung vorhandener Meshes in neuen XMLs.
*   **Verbesserungsidee:** Dokumentation der internen Asset-IDs für andere Modder.

### **Revolution 1.6-2 (Autor: Bredroll)**
*   **Beschreibung:** Das wohl wichtigste Modding-Framework der Community.
*   **Code-Analyse:** Globales Lua-Environment Hooking.
*   **Verbesserungsidee:** Performance-Monitoring der einzelnen Revolution-Module.

### **Rev_Auto Scout / Engineering / Heavy Manta / Resupply+ (Autor: Bredroll)**
*   **Beschreibung:** Spezialmodule für das Revolution-Framework.
*   **Code-Analyse:** Lua Extension Scripts.
*   **Verbesserungsidee:** Vereinheitlichung der UI-Benachrichtigungen.

### **RIM-161 (Autor: FelineCat)**
*   **Beschreibung:** Hochleistungs-Abfangrakete.
*   **Code-Analyse:** XML/Lua Hybrid für Guidance.
*   **Verbesserungsidee:** Exo-atmosphärisches Trägheitsmodell (Skript).

### **Rotate Power Screen (Autor: Musket)**
*   **Beschreibung:** Orientierung des Energiemanagement-Screens geändert.
*   **Code-Analyse:** Lua UI Koordinaten-Transformation.
*   **Verbesserungsidee:** Touch-Unterstützung für das gedrehte Layout.

### **Salty's Missile Damage Edit (Autor: SaltySeabisc)**
*   **Beschreibung:** Balancing-Änderung für Raketenschaden.
*   **Code-Analyse:** XML `damage` Tweaks.
*   **Verbesserungsidee:** Schadensmodell basierend auf Auftreffwinkel.

### **Ship Wakes (Autor: Bredroll)**
*   **Beschreibung:** Realistischere Kielwasser-Effekte.
*   **Code-Analyse:** Partikel-System XML Modifikation.
*   **Verbesserungsidee:** Gischt-Farbe an die Wasserfarbe der Map anpassen.

### **Skidders Pack (Autor: Red Dragon)**
*   **Beschreibung:** Gameplay & Assets Mix.
*   **Code-Analyse:** Diverse XML/Audio Patches.
*   **Verbesserungsidee:** Aufteilung in funktionale Pakete.

### **SKY TV (Autor: Bredroll)**
*   **Beschreibung:** Kamera-gesteuerte Raketen mit 25km Reichweite.
*   **Code-Analyse:** XML `camera_range` und `max_range`.
*   **Verbesserungsidee:** Signal-Rauschen per Lua bei großer Distanz zum Träger.

### **Sound Enhancement (Autor: N/A)**
*   **Beschreibung:** Umfassendes Audio-Update.
*   **Code-Analyse:** Asset Replacement.
*   **Verbesserungsidee:** Nutzung von Audio-Echtzeiteffekten der Engine.

### **Specialized Chassis UI / V (Diverse)**
*   **Beschreibung:** UI-Anpassungen für verschiedene Fahrzeugtypen.
*   **Code-Analyse:** Lua Screen Scripting.
*   **Verbesserungsidee:** Universelles UI-Framework für alle Chassis.

### **Spread modifier (Autor: Ribbons)**
*   **Beschreibung:** Ändert die Streuung von Geschützen.
*   **Code-Analyse:** XML-Edit `spread`.
*   **Verbesserungsidee:** Realistischer Rückstoß-Offset per Skript.

### **ST pod (v1.0) (Autor: FelineCat)**
*   **Beschreibung:** Zusätzlicher Targeting-Pod für Flugzeuge.
*   **Code-Analyse:** Kamera-Komponenten XML.
*   **Verbesserungsidee:** Nachtsicht/Infrarot-Modus per Skript.

### **Starting Aircraft Altitude (Autor: Mr. Scoot)**
*   **Beschreibung:** Ermöglicht die Wahl der Starthöhe beim Launch.
*   **Code-Analyse:** Lua UI Edit in `screen_landing.lua`.
*   **Verbesserungsidee:** Geländebasierte Sicherheits-Abfrage für die gewählte Höhe.

### **Supersonic Cruise Missile (Autor: No Name)**
*   **Beschreibung:** Extrem schnelle Marschflugkörper.
*   **Code-Analyse:** XML `force_emitter` auf Maximum.
*   **Verbesserungsidee:** (Siehe Physik-Kapitel: Tunneling vermeiden).

### **Tactical Operations Centre 1.5 / HD (Autor: Bredroll)**
*   **Beschreibung:** Massive Erweiterung der Brücke und der Träger-Funktionen.
*   **Code-Analyse:** Komplexes Mesh-Replacement und Lua-Scripting.
*   **Verbesserungsidee:** Integration in ein globales Ship-Management-System.

### **Torpedo & Missile Wolfenstein alarm (Autor: Spoozufy)**
*   **Beschreibung:** Spezielle Warnsounds für Torpedo/Raketen-Anflug.
*   **Code-Analyse:** Audio Replacement.
*   **Verbesserungsidee:** (Siehe Alarm Mods)

### **Torpedo Reformat (Autor: Ribbons)**
*   **Beschreibung:** Überarbeitung der Torpedo-Physik (Geschwindigkeit, Turn-Rate).
*   **Code-Analyse:** XML-Edit an Torpedo-Daten.
*   **Verbesserungsidee:** Kavitations-Effekte (Sound/Partikel) bei hoher Geschwindigkeit simulieren.

### **Turret Utility (Autor: Ribbons)**
*   **Beschreibung:** Hilfsfunktionen für Geschütztürme.
*   **Code-Analyse:** XML/Lua Mix.
*   **Verbesserungsidee:** Automatisches Ausrichten auf markierte Ziele.

### **UI Enhancer (Autor: QuantX)**
*   **Beschreibung:** Die Standard-Mod für UI-Verbesserungen.
*   **Code-Analyse:** Exzellente Nutzung von Lua-Hooks.
*   **Verbesserungsidee:** Benutzerdefinierte Profile für verschiedene Rollen (Kommandant vs. Pilot).

### **Unit Death Wolfenstein alarm (Autor: Spoozufy)**
*   **Beschreibung:** Alarm-Sound beim Verlust von Einheiten.
*   **Code-Analyse:** Audio Replacement.
*   **Verbesserungsidee:** (Siehe Alarm Mods)

### **Utility (Autor: Ribbons)**
*   **Beschreibung:** Sammlung von kleinen Hilfskonzepten.
*   **Code-Analyse:** XML/Lua Tweaks.
*   **Verbesserungsidee:** Zusammenführung in ein einheitliches Dienstprogramm.

### **Vanilla Friendly Barge Boost (Autor: Teledahn)**
*   **Beschreibung:** Moderater Speed-Boost für Barken, der die Spielbalance erhält.
*   **Code-Analyse:** Konservativer XML-Edit.
*   **Verbesserungsidee:** (Hervorragende Mod, kein Handlungsbedarf).

### **Vehicle IDs (Autor: HSAR)**
*   **Beschreibung:** Zeigt IDs direkt über den Fahrzeugen in der 3D-Welt.
*   **Code-Analyse:** Lua `world_to_screen` Transformationen.
*   **Verbesserungsidee:** Performance-Optimierung durch Reduzierung der Update-Rate für ferne Ziele.

### **Walrus I am (Autor: Bredroll)**
*   **Beschreibung:** Walrus-Chassis mit erweiterten Fähigkeiten (Speed/Bewaffnung).
*   **Code-Analyse:** XML Chassis Modifikation.
*   **Verbesserungsidee:** Dynamisches Umschalten zwischen Rad- und Wasserantriebsanimationen.

### **Wolfenstein Bridge Alarm (Autor: Spoozufy)**
*   **Beschreibung:** Der klassische Wolfenstein-Alarmsound für die Brücke.
*   **Code-Analyse:** Audio Replacement.
*   **Verbesserungsidee:** (Siehe Alarm Mods)

---

## 3. Technische Detail-Analyse (Deep Dive)
*Ausgewählte Beispiele für sauberen vs. unsauberen Code.*

### 3.1. Physik & Movement
Der Unterschied zwischen **Kraft** (`force_emitter`) und **Widerstand** (`drag`) ist entscheidend.
*   **Sauber:** Widerstand verringern (Schiff gleitet besser).
*   **Unsauber:** Kraft verzehnfachen (Schiff wird zur Rakete und fliegt bei Wellen weg).
*   *Lektion:* Immer erst `drag` tunen, dann `force`.

### 3.2. Scripting & UI
Der **UI Enhancer** zeigt, wie man `Hooks` schreibt:
```lua
local old_update = update
function update()
  old_update() -- Original-Code ausführen
  my_custom_code() -- Eigenes Overlay rendern
end
```
Das ist der einzige Weg, um Kompatibilität mit Updates zu sichern.

---
*Vollständiges Entwickler-Verzeichnis erstellt für Modding-Referenz (V11b).*

