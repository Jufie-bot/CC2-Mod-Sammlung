-- Skynet V4.0 - Island Levels, Torpedoes & Bilingual Logs
-- Implementiert von: Antigravity AI
-- Datum: 2026-02-14

function skynet_begin_load()
    if begin_get_screen_name ~= nil then
        local screen_name = begin_get_screen_name()
        if screen_name == "holomap_screen" then
            if g_original_update == nil then
                g_original_update = update
                print("Skynet V4: Hook in holomap_screen erfolgreich. / Hook successful.")
                update = wrap_update
            end
        end
    end

    if g_original_begin_load ~= nil then
        g_original_begin_load()
    end
end

function wrap_update(screen_w, screen_h, ticks)
    g_original_update(screen_w, screen_h, ticks)

    if get_is_controller_peer() then
        ai_skynet_update()
    end
end

if begin_load and g_original_begin_load == nil then
    g_original_begin_load = begin_load
    begin_load = skynet_begin_load
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
        return false
    end
    return false
end

g_controller = false
g_last_skynet_update = 0
g_skynet_interval = 600 -- 20 Sekunden / 20 Seconds

-- Konfiguration V4
g_skynet_alarm_level = 0 -- 0=Peace, 1=Warning, 2=War
g_skynet_alarm_timer = 0
g_skynet_last_known_player_pos = nil

function ai_skynet_update()
    local now = update_get_logic_tick()
    if now - g_last_skynet_update < g_skynet_interval then
        return
    end
    g_last_skynet_update = now

    if get_is_controller_peer() then
        g_controller = true
    end

    -- 1. Bedrohungsanalyse / Threat Assessment
    skynet_assess_threat()

    -- 2. Produktion / Production
    if g_skynet_alarm_level > 0 then
        skynet_production()
    end

    -- 3. Taktik / Tactics
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
            print("Skynet: Eindringling in Basis-Nähe entdeckt! (Warnung) / Intruder near base! (Warning)")
        end
        g_skynet_last_known_player_pos = carrier_pos
        g_skynet_alarm_timer = 3000
    elseif is_visible then
        g_skynet_last_known_player_pos = carrier_pos
        print("Skynet: Spieler auf Radar. / Player on radar.")
    else
        if g_skynet_alarm_timer > 0 then
            g_skynet_alarm_timer = g_skynet_alarm_timer - g_skynet_interval
        else
            if g_skynet_alarm_level > 0 then
                print("Skynet: Ziel verloren. Alarm aufgehoben. / Target lost. Alarm cancelled.")
                g_skynet_alarm_level = 0
                g_skynet_last_known_player_pos = nil
            end
        end
    end

    if g_skynet_alarm_level == 1 and dist_to_nearest_base < 2000 then
        g_skynet_alarm_level = 2
        print("Skynet: Feindliche Handlung vermutet! (Krieg) / Hostile action detected! (War)")
    end
end

function skynet_production()
    local tile_count = update_get_tile_count()
    for i = 0, tile_count - 1 do
        local tile = update_get_tile_by_index(i)
        if tile:get() and tile:get_team_control() == 0 then -- Team 0 (AI)
            local queue_count = tile:get_facility_production_queue_defense_count()

            if queue_count < 1 then
                local roll = math.random()
                local item_to_build = 10 -- Albatross

                if roll < 0.33 then item_to_build = 6 end -- Bear
                if roll < 0.66 then item_to_build = 77 end -- Seal

                tile:set_facility_add_production_queue_defense_item(item_to_build, 1)
            end
        end
    end
end

function skynet_tactics()
    if g_skynet_alarm_level == 0 then return end

    local target_pos = g_skynet_last_known_player_pos
    if not target_pos then return end

    local vehicle_count = update_get_map_vehicle_count()
    local commanded = 0

    for i = 0, vehicle_count - 1 do
        local vehicle = update_get_map_vehicle_by_index(i)
        if vehicle:get() and vehicle:get_team() == 0 then
            local dist_sq = vec2_dist_sq(target_pos, vehicle:get_position_xz())

            -- Max Range 10km
            if dist_sq < (10000 * 10000) then
                if math.random() < 0.3 then
                    local unit_id = vehicle:get_id()

                    -- V4 Logic: Check Island Difficulty
                    -- Find nearest friendly island to this unit to determine "Squad Level"
                    local nearest_island, dist_island = get_nearest_friendly_island(vehicle:get_position_xz())
                    local difficulty = 1
                    if nearest_island then
                        difficulty = nearest_island:get_difficulty_level()
                    end

                    if g_skynet_alarm_level == 2 then
                        -- V4: Difficulty Behavior
                        -- Level 3 Islands are "Elite/Smart": 50% chance to HIDE/WAIT instead of charging
                        if difficulty >= 3 and math.random() < 0.5 then
                            print("Skynet: Elite-Einheit " ..
                                unit_id .. " wartet im Hinterhalt. / Elite unit waiting in ambush.")
                            -- Do nothing (Hold position) or maybe move slightly back?
                            -- For now: Just don't give attack order -> Passive/Defensive behavior
                        else
                            -- Attack!
                            local wid = vehicle:add_waypoint(target_pos:x(), target_pos:y())
                            local jitter = (math.random() - 0.5) * 200
                            vehicle:set_waypoint_position(wid, target_pos:x() + jitter, target_pos:y() + jitter)

                            -- V4: Torpedo Usage
                            local atype = e_attack_type.any

                            -- If we have torpedoes and target is likely a ship (Carrier), use them!
                            if vehicle:get_is_attack_type_capable(e_attack_type.torpedo_single, true) then
                                atype = e_attack_type.torpedo_single
                                print("Skynet: Einheit " .. unit_id .. " feuert Torpedos! / Firing torpedoes!")
                            elseif vehicle:get_is_attack_type_capable(e_attack_type.order_cruise_missile, true, true,
                                true) then
                                atype = e_attack_type.order_cruise_missile
                            end

                            vehicle:set_waypoint_attack_target_target_id(wid, update_get_screen_vehicle():get_id())
                            vehicle:set_waypoint_attack_target_attack_type(wid, 1, atype)
                        end
                    end
                end
            end
        end
    end
end

-- Hilfsfunktionen / Helper Functions
function get_dist_to_nearest_ai_base(pos)
    local min_dist = 1000000000
    local tile_count = update_get_tile_count()
    for i = 0, tile_count - 1 do
        local tile = update_get_tile_by_index(i)
        if tile:get() and tile:get_team_control() == 0 then
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
        if tile:get() and tile:get_team_control() == 0 then -- Friendly to AI
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
        if tile:get() and tile:get_team_control() == 1 then
            count = count + 1
        end
    end
    return count
end

if _G["g_rev_mods"] ~= nil then
    table.insert(_G["g_rev_mods"], "AI: Skynet V4 (Levels & Torpedoes)")
end
