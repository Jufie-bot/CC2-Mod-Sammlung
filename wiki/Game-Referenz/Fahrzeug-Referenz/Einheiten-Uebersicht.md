# Einheiten Übersicht

Diese Übersicht beschreibt die wichtigsten Fahrzeug-Typen und Objekte in Carrier Command 2, ihre Eigenschaften und Modding-Besonderheiten.

## Übersichtstabelle
| Einheit | Index (e_game_object_type) | Typ | Besonderheiten |
| :--- | :---: | :--- | :--- |
| **Carrier** | 0 | Schiff | Basis des Spielers. Kann Luft- und Bodeneinheiten aufnehmen. |
| **Seal** | 2 | Land (leicht) | Standard-Aufklärer, 1 Turm, 2 Utility-Slots. |
| **Walrus** | 4 | Land (mittel) | Robuster als Seal, 1 Turm, 2 Utility-Slots. |
| **Bear** | 6 | Land (schwer) | Kettenfahrzeug, kann 100mm/120mm tragen, 2 Utility-Slots. |
| **Albatross** | 8 | Luft (Flugzeug) | 4 Hardpoints, 1 Turm-Slot. |
| **Manta** | 10 | Luft (Jet) | Schnell, 4 Hardpoints, 1 Kamera-Slot, 1 AWACS, 2 Utility-Slots. |
| **Razorbill** | 12 | Luft (Heli) | Wendig, 2 Hardpoints, 2 Utility-Slots. |
| **Petrel** | 14 | Luft (Transport) | Schwertransporter für Bodeneinheiten (außer Türme/Droids). |
| **Barge** | 16 | Schiff (Logistik) | Transportiert Fracht/Treibstoff. Verbraucht keinen Treibstoff. |
| **Needlefish** | 77 | Schiff (Kampf) | Schnell, 2 Hardpoints. |
| **Swordfish** | 79 | Schiff (Kampf) | Schweres Kampfschiff, 3 Hardpoints. |
| **Droid** | 97 | Land (KI) | Eingesetzt durch MULE. 2x 30mm Kanonen mit hohem Schaden. |
| **Virus Bot** | 58 | Land (KI) | Übernimmt feindliche Inseln. |
| **Turret** | 59 | Gebäude | Stationäre Verteidigung auf Inseln. |

---

## Modding-Notizen
*   **Invulnerabilität:** Einheiten, die von einem Petrel getragen werden, verbrauchen keinen Treibstoff und sind unverwundbar.
*   **Airlift-Limits:** Standardmäßig kann der Petrel keine Türme, Droids oder Virus-Bots heben. Dies kann jedoch via XML oder Save-Editing geändert werden.
*   **Save-Editing:** Schiffe wie die Needlefish können via Save-Editing mit untypischen Waffen (z.B. Cruise Missiles) bestückt werden.
*   **Drydock (Index 64):** In Lua oft als "Jetty" bezeichnet. Ort, an dem der Carrier startet. Unzerstörbar und unbeweglich.
