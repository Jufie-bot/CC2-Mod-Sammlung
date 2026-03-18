# Detailanalyse: Salty's Missile Damage Edit Mod

## Übersicht
- **Mod-Name:** Salty's Missile Damage Edit
- **Kategorie:** Weapons
- **Dateien:** `content/scripts/constants.txt`

## Technische Analyse

### Mechanik
Diese Mod bietet eine subtile Balance-Änderung für das Raketen-Arsenal. Sie erhöht den Explosionsschaden von taktischen Raketen um genau 5%.

### Code-Vergleich: `constants.txt`

Die Mod nutzt die `constants.txt`, um globale Variablen der Spiel-Engine zu überschreiben. Dies ist eine sehr saubere und kompatible Methode des Moddings.

**Vanilla (Original):**
```text
missile_1_explosion_damage_scale 1.0
missile_2_explosion_damage_scale 1.0
missile_tv_explosion_damage_scale 1.0
```

**Mod-Version:**
```text
missile_1_explosion_damage_scale 1.05
missile_2_explosion_damage_scale 1.05
missile_tv_explosion_damage_scale 1.05
```

### Analyse der betroffenen Einheiten
- **Missile 1 (IR):** Profitiert von der Erhöhung, was besonders gegen leicht gepanzerte Ziele einen Unterschied machen kann.
- **Missile 2 (Laser):** Erhält ebenfalls den 5% Buff.
- **TV Missile:** Die ferngesteuerte Rakete wird leicht schlagkräftiger.

Interessanterweise bleibt die `missile_5_explosion_damage_scale` (Gimbale/Schwere Rakete) auf `1.0` (Vanilla), was darauf hindeutet, dass der Autor nur die leichteren, taktischen Raketen stärken wollte.

## Fazit
Eine minimale, aber präzise Modifikation. Sie ist ein perfektes Beispiel für "Data-Only" Modding, das keine Skripte verändert und somit maximale Kompatibilität mit anderen Mods (wie z.B. Speed-Mods) gewährleistet.
