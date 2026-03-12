# Entwickler-Standards & Best Practices

Dieses Dokument fasst die "Lessons Learned" aus der Analyse von über 100 Mods zusammen. Es dient als Leitfaden für sauberen Code in Carrier Command 2.

---

## 1. Code-Architektur (Lua)

### ✅ DO: Hooks verwenden
Anstatt komplette Script-Dateien des Spiels zu ersetzen, nutze Hooks, um deine Funktion in den bestehenden Ablauf einzuklinken.
**Beispiel (UI Enhancer):**
```lua
local old_update = update
function update()
    if old_update then old_update() end
    my_custom_overlay()
end
```
*Warum?* Erhöht die Kompatibilität mit Spiele-Updates und anderen Mods massiv.

### ❌ DON'T: Core-Files überschreiben
Vermeide es, Dateien wie `screen_radar.lua` komplett zu ersetzen, es sei denn, es ist absolut unvermeidbar. Wenn zwei Mods dieselbe Datei ersetzen, gewinnt die letzte – die andere geht kaputt.

### ✅ DO: Konfiguration auslagern
Definiere Farben, Größen und magische Zahlen am Anfang der Datei oder in einer separaten `config.lua`.
*Warum?* Erlaubt schnelles Balancing ohne Code-Suche.

### ❌ DON'T: Polling in `update()`
Vermeide rechenintensive Abfragen (z.B. "Suche alle Einheiten im Radius X") in der `update()` Funktion, die 60-mal pro Sekunde läuft.
*Besser:* Prüfe nur alle 10 Frames oder nutze Events.

---

## 2. Physik & XML-Tuning

### ✅ DO: Drag (Widerstand) vs. Force (Kraft)
Um Schiffe schneller zu machen, verringere primär den `drag` (Wasserwiderstand).
*Warum?* Das Schiff gleitet besser. Nur `force` zu erhöhen führt dazu, dass das Schiff bei Wellengang wie eine Rakete abhebt, da der Kraftvektor starr am Rumpf "klebt".

### ❌ DON'T: Extremwerte
Werte wie `magnitude="3000"` (Supersonic Missile) führen zu "Tunneling": Das Objekt bewegt sich so schnell, dass es in einem Frame *vor* dem Ziel und im nächsten *hinter* dem Ziel ist. Die Kollision wird nicht registriert.

### ✅ DO: Vererbung nutzen
Wenn du eine Variante einer Waffe erstellst (z.B. "Mk2 Missile"), kopiere die XML, aber versuche Referenzen auf bestehende Meshes und Sounds zu nutzen, um die Mod-Größe klein zu halten.

---

## 3. Assets (Audio & Grafik)

### ❌ DON'T: Destruktives Ersetzen
Überschreibe keine Vanilla-Sounds wie `alarm_general_quarters.wav`.
*Warum?* Der User kann nur einen Alarm haben.
*Besser:* Füge den Sound als neue Datei hinzu (`my_alarm.wav`) und spiele ihn per Lua-Skript ab.

### ✅ DO: LODs (Level of Detail)
Wenn du neue 3D-Modelle einfügst (wie TOC 1.5 HD), erstelle unbedingt LOD-Stufen.
*Warum?* Ohne LODs bricht die Performance in VR oder auf schwächeren PCs ein, wenn man weit weg ist.

---

## 4. UI & UX

### ✅ DO: Skalierung beachten
Denke daran, dass UI-Elemente auf verschiedenen Monitor-Größen und in VR funktionieren müssen. Nutze relative Koordinaten statt absoluter Pixel-Werte.

### ✅ DO: Occlusion Culling für Tags
Wenn du 3D-Tags (wie in Vehicle IDs) renderst, prüfe, ob das Ziel sichtbar ist (Raycast). Text durch Berge hindurch zu sehen, zerstört die Immersion.

---
*Leitfaden basierend auf Analyse V11.*
