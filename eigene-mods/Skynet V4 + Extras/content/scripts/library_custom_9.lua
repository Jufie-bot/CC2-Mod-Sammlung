-- Skynet V4.0 - Island Levels, Torpedoes & Bilingual Logs
-- Implementiert von: Antigravity AI
-- Datum: 2026-02-14
-- Datum: 2026-02-14

function skynet_begin_load()
    if begin_get_screen_name ~= nil then
        local screen_name = begin_get_screen_name()
        
        -- KI-Hook für Holomap (PRIORITÄT 1)
        if screen_name == "holomap_screen" then
            if g_original_update == nil then
                g_original_update = update
                g_skynet_screen_type = "ai"
                g_skynet_is_master = true
                skynet_log("KI-Meistersystem initialisiert (HOLO).")
                update = wrap_update
            end
        -- HUD-Hook für Navigationsbildschirme (PRIORITÄT 2)
        elseif screen_name == "screen_nav_l" or screen_name == "screen_nav_m" or screen_name == "screen_nav_r" then
            if g_original_update == nil then
                g_original_update = update
                g_skynet_screen_type = "hud"
                -- Nur zum Master werden, wenn es der mittlere Bildschirm ist und kein anderer Bildschirm in dieser VM Master ist
                if screen_name == "screen_nav_m" then 
                    g_skynet_is_master = true
                    skynet_log("KI-Meistersystem initialisiert (NAV).")
                end
                update = wrap_update
            end
        elseif screen_name == "screen_ship_log" then
            if g_original_update == nil then
                g_original_update = update
                g_skynet_screen_type = "log"
                update = wrap_update
            end
        end
    end

    if g_original_begin_load ~= nil then
        g_original_begin_load()
    end
end

function wrap_update(screen_w, screen_h, ticks)
    if g_original_update ~= nil then
        g_original_update(screen_w, screen_h, ticks)
    end

    if g_skynet_is_master then
        if get_is_controller_peer() then
            ai_skynet_update()
        end
    end

    if g_skynet_screen_type == "hud" then
        -- HUD Anzeige entfernt (auf Wunsch des Users)
    elseif g_skynet_screen_type == "log" then
        -- Benutzerdefinierte Logs in den Schiffslog-Bildschirm injizieren
        if g_skynet_log and #g_skynet_log > 0 and g_ui ~= nil then
            for _, entry in ipairs(g_skynet_log) do
                local columns = {
                    { w=55, margin=5, value=format_time(entry.time), col=color_grey_dark },
                    { w=200, margin=5, value=entry.message, col=entry.col },
                }
                imgui_table_entry(g_ui, columns)
            end
        end
    end
end

if begin_load and g_original_begin_load == nil then
    g_original_begin_load = begin_load
    begin_load = skynet_begin_load
end

g_skynet_log = {}

function skynet_log(text, col, icon)
    table.insert(g_skynet_log, {
        time = update_get_logic_tick() / 30,
        message = text,
        col = col or color8(0, 255, 255, 255),
        icon = icon or atlas_icons.column_pending
    })
    -- Nur die letzten 50 Einträge im Speicher behalten
    if #g_skynet_log > 50 then
        table.remove(g_skynet_log, 1)
    end
    print("Skynet Log: " .. text)
end

function format_time(time)
    local seconds = math.floor(time) % 60
    local minutes = math.floor(time / 60) % 60
    local hours = math.min(math.floor(time / 60 / 60), 99)

    return string.format("%02.f:%02.f:%02.f", hours, minutes, seconds)
end

function get_is_controller_peer()
    local peers = {}
    local current_peer = update_get_local_peer_id()
    local screen_team_id = update_get_screen_team_id()
    local peer_count = update_get_peer_count()
    for i = 0, peer_count - 1 do
        local pid = update_get_peer_id(i)
        local name = update_get_peer_name(i)
        local team = update_get_peer_team(i)
        if team == screen_team_id then
            table.insert(peers, {
                name = name,
                pid = pid
            })
        end
    end
    table.sort(peers, function(a, b) return a.name > b.name end)
    for i, peer in pairs(peers) do
        if peer.pid == current_peer then
            return true
        end
    end
    return false
end

g_controller = false
g_last_skynet_update = 0
g_skynet_interval = 600 -- 20 Sekunden / 20 Seconds
g_skynet_budget = 1000 -- Startbudget

-- Konfiguration V4
g_skynet_alarm_level = 0 -- 0=Peace, 1=Warning, 2=War
g_skynet_alarm_timer = 0
g_skynet_last_known_player_pos = nil

g_skynet_chassis_names = {
    [6] = "BEAR",
    [77] = "SEAL",
    [10] = "ALBATROSS"
}

function ai_skynet_update()
    local now = update_get_logic_tick()
    if now - g_last_skynet_update < g_skynet_interval then
        return
    end
    g_last_skynet_update = now

    -- Budget-Aktualisierung
    local ai_islands = 0
    local tile_count = update_get_tile_count()
    for i = 0, tile_count - 1 do
        local tile = update_get_tile_by_index(i)
        if tile and tile:get() and tile:get_team_control() == 0 then
            ai_islands = ai_islands + 1
        end
    end
    -- Generiere alle 20s 50 pro Insel + 100 Basis
    g_skynet_budget = g_skynet_budget + (ai_islands * 50) + 100
    if g_skynet_budget > 25000 then g_skynet_budget = 25000 end -- Limit

    -- 1. Bedrohungsanalyse
    skynet_assess_threat()

    -- 2. Produktion
    if g_skynet_alarm_level > 0 then
        skynet_production()
    end

    -- 3. Taktik
    skynet_tactics()
end

function skynet_assess_threat()
    local carrier = update_get_screen_vehicle()
    if not carrier or not carrier:get() then return end

    local carrier_pos = carrier:get_position_xz()
    local is_visible = carrier:get_is_visible()
    local dist_to_nearest_base = get_dist_to_nearest_ai_base(carrier_pos)

    if is_visible and dist_to_nearest_base < 5000 then
        if g_skynet_alarm_level < 1 then
            g_skynet_alarm_level = 1
            skynet_log("Eindringling in Basis-Nähe! Warne lokale Einheiten.", color_status_warning, atlas_icons.hud_warning)
            print("Skynet: Eindringling in Basis-Nähe entdeckt! (Warnung)")
        end
        g_skynet_last_known_player_pos = carrier_pos
        g_skynet_alarm_timer = 3000
    elseif is_visible then
        g_skynet_last_known_player_pos = carrier_pos
        print("Skynet: Spieler auf Radar.")
    else
        if g_skynet_alarm_timer > 0 then
            g_skynet_alarm_timer = g_skynet_alarm_timer - g_skynet_interval
        else
            if g_skynet_alarm_level > 0 then
                print("Skynet: Ziel verloren. Alarm aufgehoben.")
                g_skynet_alarm_level = 0
                g_skynet_last_known_player_pos = nil
            end
        end
    end

    if g_skynet_alarm_level == 1 and dist_to_nearest_base < 2000 then
        g_skynet_alarm_level = 2
        skynet_log("Feindliche Aktivität entdeckt! Wechsle zum KRIEG-Protokoll.", color_status_bad, atlas_icons.hud_warning)
        print("Skynet: Feindliche Handlung vermutet! (Krieg)")
    end
end

function skynet_production()
    local tile_count = update_get_tile_count()
    for i = 0, tile_count - 1 do
        local tile = update_get_tile_by_index(i)
        if tile and tile:get() and tile:get_team_control() == 0 then -- Team 0 (KI)
            local queue_count = tile:get_facility_production_queue_defense_count()

            if queue_count < 1 then
                local roll = math.random()
                local item_to_build = 10 -- Albatross
                local cost = 1000

                if roll < 0.33 then 
                    item_to_build = 6 -- Bear
                    cost = 500
                elseif roll < 0.66 then 
                    item_to_build = 77 -- Seal
                    cost = 750
                end

                if g_skynet_budget >= cost then
                    tile:set_facility_add_production_queue_defense_item(item_to_build, 1)
                    g_skynet_budget = g_skynet_budget - cost
                    local unit_name = g_skynet_chassis_names[item_to_build] or "Unbekannte Einheit"
                    skynet_log("Produziere " .. unit_name .. " bei " .. tile:get_name(), nil, atlas_icons.map_icon_factory)
                end
            end
        end
    end
end

function skynet_tactics()
    if g_skynet_alarm_level == 0 then return end

    local target_pos = g_skynet_last_known_player_pos
    if not target_pos then return end

    local vehicle_count = update_get_map_vehicle_count()

    for i = 0, vehicle_count - 1 do
        local vehicle = update_get_map_vehicle_by_index(i)
        if vehicle ~= nil and vehicle:get() and vehicle:get_team() == 0 then
            local pos = vehicle:get_position_xz()
            local dist_sq = vec2_dist_sq(target_pos, pos)

            -- 1. Rückzugslogik (Neu in V4)
            local hp = vehicle:get_hitpoints()
            local total_hp = vehicle:get_total_hitpoints()
            
            if hp < (total_hp * 0.3) then
                if not vehicle.skynet_retreat then
                    skynet_log("Einheit " .. vehicle:get_id() .. " beschaedigt! Rueckzug zur Basis.", color_status_warning, atlas_icons.map_icon_surface_vehicle)
                    vehicle.skynet_retreat = true
                    vehicle:clear_waypoints()
                    local nearest_island, _ = get_nearest_friendly_island(pos)
                    if nearest_island then
                        local i_pos = nearest_island:get_position_xz()
                        vehicle:add_waypoint(i_pos:x(), i_pos:y())
                    end
                end
            -- 2. Angriffslogik
            elseif dist_sq < (10000 * 10000) then
                if math.random() < 0.3 then
                    local unit_id = vehicle:get_id()

                    -- V4 Logik: Insel-Schwierigkeitsgrad prüfen
                    local nearest_island, dist_island = get_nearest_friendly_island(pos)
                    local difficulty = 1
                    if nearest_island then
                        difficulty = nearest_island:get_difficulty_level()
                    end

                    if g_skynet_alarm_level == 2 then
                        -- Elite-KI (Level 3+)
                        if difficulty >= 3 and math.random() < 0.5 then
                            if not vehicle.skynet_ambush then
                                skynet_log("Einheit " .. unit_id .. " (Elite) im Hinterhalt.", color_status_ok, atlas_icons.map_icon_last_known_pos)
                                vehicle.skynet_ambush = true
                            end
                        else
                            -- Angriff!
                            local wid = vehicle:add_waypoint(target_pos:x(), target_pos:y())
                            local jitter = (math.random() - 0.5) * 200
                            vehicle:set_waypoint_position(wid, target_pos:x() + jitter, target_pos:y() + jitter)

                            -- Torpedo/Raketen Logik
                            local atype = e_attack_type.any
                            if vehicle:get_is_attack_type_capable(e_attack_type.torpedo_single, true) then
                                atype = e_attack_type.torpedo_single
                                skynet_log("Einheit " .. unit_id .. " feuert Torpedos!", color_status_bad, atlas_icons.map_icon_torpedo)
                            end

                            local carrier = update_get_screen_vehicle()
                            if carrier and carrier:get() then
                                vehicle:set_waypoint_attack_target_target_id(wid, carrier:get_id())
                                vehicle:set_waypoint_attack_target_attack_type(wid, 1, atype)
                            end
                        end
                    end
                end
            end
        end
    end
end


-- Hilfsfunktionen
function get_dist_to_nearest_ai_base(pos)
    local min_dist = 1000000000
    local tile_count = update_get_tile_count()
    for i = 0, tile_count - 1 do
        local tile = update_get_tile_by_index(i)
        if tile ~= nil and tile:get() and tile:get_team_control() == 0 then
            local t_pos = tile:get_position_xz()
            local dist = math.sqrt(vec2_dist_sq(pos, t_pos))
            if dist < min_dist then min_dist = dist end
        end
    end
    return min_dist
end

function get_nearest_friendly_island(pos)
    local best_dist = 1000000000
    local best_tile = nil

    local tile_count = update_get_tile_count()
    for i = 0, tile_count - 1 do
        local tile = update_get_tile_by_index(i)
        if tile and tile:get() and tile:get_team_control() == 0 then -- KI-befreundet
            local t_pos = tile:get_position_xz()
            local dist = vec2_dist_sq(pos, t_pos)
            if dist < best_dist then
                best_dist = dist
                best_tile = tile
            end
        end
    end
    return best_tile, best_dist
end

function get_player_island_count()
    local count = 0
    local tile_count = update_get_tile_count()
    for i = 0, tile_count - 1 do
        local tile = update_get_tile_by_index(i)
        if tile ~= nil and tile:get() and tile:get_team_control() == 1 then
            count = count + 1
        end
    end
    return count
end

if _G["g_rev_mods"] ~= nil then
    table.insert(_G["g_rev_mods"], "AI: Skynet V4 (Levels & Torpedoes)")
end

--------------------------------------------------------------------------------
-- REVOLUTION AUTOLAND FEATURES (PORTED)
--------------------------------------------------------------------------------

function setup_autoland(vehicle, pos, start_pos)
    if vehicle == nil or vehicle:get() == nil then return end
    
    if pos == nil then
        pos = vehicle:get_position_xz()
    end
    
    vehicle:clear_waypoints()
    local steps = 12
    local gnd = 0
    local glide_len = 350
    
    if start_pos == nil then
        start_pos = vec2(pos:x() - glide_len, pos:y() - glide_len)
    else
        local dx = pos:x() - start_pos:x()
        local dy = pos:y() - start_pos:y()
        local b = math.atan(dy, dx)
        local sy = math.sin(b) * glide_len
        local sx = math.cos(b) * glide_len
        start_pos = vec2(pos:x() - sx, pos:y() - sy)
    end

    local glide_start_x = start_pos:x()
    local glide_start_y = start_pos:y()
    local glide_end_x = pos:x()
    local glide_end_y = pos:y()
    local step_x = (glide_end_x - glide_start_x) / steps
    local step_y = (glide_end_y - glide_start_y) / steps
    
    -- Verschiebe den Haltepunkt um ca. 2.5 Schritte nach vorne, um exakt am Ziel zu landen
    glide_end_x = glide_end_x + (step_x * 2.5)
    glide_end_y = glide_end_y + (step_y * 2.5)
    glide_start_x = glide_start_x + (step_x * 2.5)
    glide_start_y = glide_start_y + (step_y * 2.5)

    -- Nächste befreundete Bodeneinheit für Höhenreferenz suchen
    local nearest_gnd_unit = nil
    local best_dist_sq = 100 * 100
    local vehicle_count = update_get_map_vehicle_count()
    local our_team = vehicle:get_team_id()
    
    for i = 0, vehicle_count - 1 do
        local unit = update_get_map_vehicle_by_index(i)
        if unit and unit:get() and unit:get_team_id() == our_team and not unit:get_is_docked() then
            local udef = unit:get_definition_index()
            -- Prüfe auf Träger, Bären, Maultiere (Bodeneinheiten)
            if udef == e_game_object_type.chassis_carrier or 
               udef == e_game_object_type.chassis_land_wheel_heavy or 
               udef == e_game_object_type.chassis_land_wheel_mule then
                local upos = unit:get_position_xz()
                local dsq = vec2_dist_sq(pos, upos)
                if dsq < best_dist_sq then
                    best_dist_sq = dsq
                    nearest_gnd_unit = unit
                end
            end
        end
    end

    if nearest_gnd_unit then
        gnd = math.floor(nearest_gnd_unit:get_position():y() - 5.5)
    end

    local approach_alt = 110
    for descent_steps = steps, 0, -1 do
        local wx = glide_end_x - (descent_steps * step_x)
        local wy = glide_end_y - (descent_steps * step_y)
        local walt = math.floor(gnd + approach_alt * descent_steps / steps)
        
        local wid = vehicle:add_waypoint(wx, wy)
        vehicle:set_waypoint_altitude(wid, walt)
    end
    
    local final_wid = vehicle:add_waypoint(glide_end_x, glide_end_y)
    vehicle:set_waypoint_altitude(final_wid, gnd)
    vehicle:set_waypoint_wait_group(final_wid, 3, true)
    
    skynet_log("Autoland für Einheit " .. vehicle:get_id() .. " eingeleitet.", color_status_ok)
end

--------------------------------------------------------------------------------
-- FOG OF WAR (FOW) FEATURES
--------------------------------------------------------------------------------




