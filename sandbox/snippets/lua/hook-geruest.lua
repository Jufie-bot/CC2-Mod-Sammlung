-- Snippet: Lua Hook-Gerüst für library_custom_*
-- Quelle: analysis/lua/, sandbox/vanilla-referenz/scripts/
-- game-version: 2026-03

-- WICHTIG: Datei muss benannt sein: library_custom_[dein_name].lua
-- Wird automatisch vom Spiel geladen wenn sie im mod-Ordner liegt.

-- Event: Am Anfang einer Tick-Sitzung (jede Runde)
function onTick()
    -- Dein Code hier — läuft jeden Tick (~60x pro Sekunde)
end

-- Event: Wenn ein Signal über den Input empfangen wird
function onDraw()
    -- Nur für screen_* Dateien relevant (HUD-Rendering)
    -- Für library_custom_* normalerweise leer lassen
end

-- Beispiel: Wert über Composite lesen
-- local speed = input.getNumber(1)    -- Kanal 1
-- local active = input.getBool(1)     -- Bool-Kanal 1

-- Beispiel: Wert über Composite schreiben
-- output.setNumber(1, speed * 2)
-- output.setBool(1, true)
