# Detailanalyse: Mark84 bomb Mod

## Übersicht
- **Mod-Name:** Mark84 bomb
- **Kategorie:** Weapons
- **Dateien:** `content/meshes/projectiles/projectiles/bomb_3.mesh`

## Technische Analyse

### Mechanik
Die "Mark84 bomb" Mod ist eine reine Asset-Replacement-Modifikation. Sie ersetzt das visuelle Modell der schweren Bombe (Bomb 3) durch ein Modell, das der realen Mark 84 Mehrzweckbombe nachempfunden ist.

### Analyse der Dateistruktur
Die Mod überschreibt die Datei:
`content/meshes/projectiles/projectiles/bomb_3.mesh`

Dies ist das Standard-Mesh für die schweren Bomben (Bomb 3) in *Carrier Command 2*. Da nur die `.mesh` Datei vorhanden ist, werden keine XML-Eigenschaften (wie Explosionsradius oder Masse) verändert.

### Code-Beispiel (Vanilla-Referenz)
Da die Mod keine XML-Dateien enthält, nutzt sie die Standardwerte aus der `bomb_3.xml` des Spiels. Ein Vergleich zeigt, dass die Logik unverändert bleibt:

**Vanilla/Mod Spiellogik (Identisch):**
```xml
<!-- Auszug aus der internen bomb_3.xml Definition -->
<projectile_definition explosion_magnitude="250.0" search_radius="10.0" />
<physics mass="500.0" drag="0.015" />
```

### Besonderheiten
- **Visueller Effekt:** Die Mark 84 ist in der Realität eine 2000-Pfund-Bombe. Das neue Modell verleiht der schweren Bombe im Spiel ein realistischeres Aussehen.
- **Kompatibilität:** Da keine Skripte oder XML-Dateien geändert werden, ist die Mod extrem stabil und mit allen Gameplay-Mods kompatibel, außer solchen, die ebenfalls `bomb_3.mesh` ersetzen.

## Fazit
Eine ästhetische Modifikation für Enthusiasten realistischer Militärtechnik. Sie demonstriert die einfache Austauschbarkeit von 3D-Modellen in *Carrier Command 2*.
