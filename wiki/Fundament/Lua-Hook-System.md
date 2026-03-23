---
title: Lua-Hook-System
section: Fundament
status: Welle-1
game-version: 2026-03
---

# Lua-Hook-System

CC2 erlaubt benutzerdefinierte Lua-Skripte über ein Hook-System mit speziellen Dateinamen.

---

## Dateitypen und Hooks

| Dateiname | Hook-Typ | Wann aufgerufen |
|:---|:---|:---|
| `library_custom_0.lua` bis `library_custom_9.lua` | Allgemeine Hooks | Jeden Tick |
| `screen_*.lua` | HUD-Rendering-Hook | Beim Zeichnen des Bildschirms |
| `interactions.lua` | Interaktions-Hook | Bei Spieler-Aktionen |

## Pflichtfunktionen

```lua
-- Jede library_custom_*.lua muss beide Funktionen enthalten
function onTick()
    -- Läuft ~60x pro Sekunde
    -- Hier: Logik, Berechnung, Daten lesen
end

function onDraw()
    -- Für screen_* Dateien: HUD-Rendering
    -- Für library_custom_*: normalerweise leer lassen
end
```

## Input/Output Composite

```lua
-- Lesen (Kanal 1-32)
local speed = input.getNumber(1)
local active = input.getBool(1)

-- Schreiben
output.setNumber(1, speed * 2)
output.setBool(1, true)
```

## Ladereihenfolge

1. Vanilla-Scripts
2. Mod-Scripts (alphabetisch nach Mod-ID)
3. Letzte geladene Mod "gewinnt" bei Konflikten

> Wenn `library_custom_0.lua` genutzt wird: keine 0 in Vanilla → sicher für eigene Mods.

> Weiterführend: [[Game-Referenz/Lua-Referenz/Lua-Kernfunktionen]] | [[sandbox/snippets/lua/hook-geruest.lua]]
