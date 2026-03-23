```lua
-- Standard Hook für onTick()
-- Wird jeden Frame ausgeführt. Vorsicht: Belastet die Performance!
function onTick(tick_time)
    -- Hier Logik eintragen, die kontinuierlich laufen soll
    local vehicle_id = 1
    local is_active = server.getVehicleSeat(vehicle_id, "main_seat")
    
    if is_active then
        -- do something
    end
end
```
