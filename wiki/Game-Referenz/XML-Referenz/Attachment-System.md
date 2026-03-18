# Attachment-System (Game Objects)

Das Attachment-System definiert, welche Module (Waffen, Sensoren, Fracht) an welche Hardpoints eines Fahrzeugs oder einer Station montiert werden können.

## Attachment-IDs & Typen
Diese IDs werden in den Chassis-XMLs (`attachment_type`) und in Speicherständen verwendet.

| ID | Name | Beschreibung |
| :--- | :--- | :--- |
| **17** | Gun30mm | Standard 30mm Bordkanone. |
| **18** | Gun100mm | 100mm Turm für Bodenfahrzeuge/Schiffe. |
| **19** | Gun120mm | 120mm Turm. |
| **20** | ShipGun160mm | Schwere 160mm Schiffsartillerie. |
| **21** | Gun20mm | Präzise 20mm Flugzeugkanone. |
| **22** | RocketPod | Raketenwerfer (19 Raketen), CIWS-anfällig? |
| **23** | VirusBot | Infiltrations-Bot. |
| **24** | CIWS | Bodenmontierte Raketenabwehr. |
| **25** | MissileIRLauncher | Infrarot-Raketenwerfer (Magazin für 4). |
| **26** | ShipCIWS | Schiffsbasierte Raketenabwehr (eingeschränkter Richtbereich). |
| **27** | MissileAALauncher | AA-Launcher für Kriegsschiffe. |
| **28** | ShipCruiseMissile | Marschflugkörper für Schiffe. |
| **29** | ShipFlare | Signalraketen für Schiffe (nur Beleuchtung). |
| **30** | ShipCam | Beobachtungskamera für den Träger. |
| **31-33**| Bomb0/1/2 | Verschiedene Bombentypen. |
| **34** | MissileIR | Einzelne IR-Rakete. |
| **35** | MissileLaser | Lasergesteuerter Marschflugkörper (Luft-Boden). |
| **36** | MissileAA | Einzelne AA-Rakete. |
| **37** | ObsCam | Standard Beobachtungskamera. |
| **38** | DriverSeat | Implizites Attachment in Slot 0 aller Einheiten. |
| **39** | AirObsCam | Beobachtungskamera für Luftfahrzeuge. |
| **40** | SmallCam | Kompakte Kamera. |
| **41** | AWACS | Luftgestütztes Radar. |
| **42** | FuelTank | Abwurftank für Flugzeuge (1000l). |
| **43** | Flares | Täuschkörper-Werfer. |
| **70** | Torpedo | Standard Torpedo. |
| **72** | MissileTV | TV-gesteuerte Rakete (manuelle Lenkung). |
| **73** | Noisemaker | Akustischer Täuschkörper. |
| **74** | TorpedoCM | Torpedo-Abwehrmaßnahme. |
| **75** | ShipTorpedo | Schiffsgestützter Torpedowerfer. |
| **76** | ShipCM | Täuschkörper für Schiffe. |
| **81** | Radar | Standard Radar-Anlage. |
| **82** | SonicPulse | Schall-Impulsgeber. |
| **83** | SmokeBomb | Rauchbombe. |
| **84** | SmokeTrail | Rauchspur-Emitter. |
| **85** | Gun40mm | 40mm Kanone. |
| **87** | Gun15mm | Kleiner Turm (Insel-Verteidigung), nutzt 30mm Munition. |
| **90-94**| Rearm 20-120mm| Aufmunitionierungs-Boxen für den Mule. |
| **95** | Refuel | Treibstoff-Versorgungs-Box für den Mule. |
| **96** | RearmIR | IR-Raketen-Nachschub für den Mule. |
| **99** | Autocannon | Bewaffnung des Kampf-Droids (hoher Schaden). |
| **100** | BattleDroids | Mule-Abwurfbox für Kampf-Droids. |

## Besonderheiten
*   **Gun15mm**: Kann via Lua auf beliebige gedockte Einheiten montiert werden, auch wenn nicht im Bestand vorhanden.
*   **MissileAALauncher**: Funktioniert nur auf Needlefish, Swordfish oder dem Träger zuverlässig.
*   **MissileLaser/TV**: KI feuert diese Waffen im Vanilla-Zustand fast nie ab.
