function skynet_begin_load()
    if begin_get_screen_name ~= nil then
        local screen_name = begin_get_screen_name()
        if screen_name == "holomap_screen" then
            if g_original_update == nil then
                g_original_update = update
                print("custom_3_", screen_name, update)
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
        -- print(string.format("%s = %d", name, pid))
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
        -- get the first peer
        if peer.pid == current_peer then
            return true
        end
        print(string.format("controller is %d %s", peer.pid, peer.name))

        return false
    end
    return false
end

g_controller = false
g_last_skynet_update = 0
g_skynet_interval = 1800 -- 60 sec
function ai_skynet_update()
    local now = update_get_logic_tick()
    if now - g_last_skynet_update < g_skynet_interval then
        return
    end
    g_last_skynet_update = now
    if get_is_controller_peer() then
        g_controller = true
    end
    print("skynet loop")
    skynet_attack()
end

g_skynet_ship_wave_size = 2
g_skynet_air_wave_size = 4
g_skynet_bear_wave_size = 2
g_skynet_recruit_range = 18000 -- 18km
g_skynet_recruitment_chance = 0.5 -- 50% chance to recruit a unit per cycle

function skynet_attack()
    -- Escalation Logic: Calculate wave sizes based on player island count
    local player_islands = get_player_island_count()
    local ship_wave_size = math.min(4, 1 + math.floor(player_islands / 4))
    local air_wave_size = math.min(6, 1 + math.floor(player_islands / 3))

    print(string.format("Skynet Escalation: Islands=%d, Ships=%d, Air=%d", player_islands, ship_wave_size, air_wave_size))

    local carrier = update_get_screen_vehicle()
    if not carrier or not carrier:get() then return end
    local carrier_pos = carrier:get_position_xz()

    -- collect all ships/air and sort by distance
    local ships = {}
    local air_units = {}
    local land_units = {}

    local vehicle_count = update_get_map_vehicle_count()
    local current_recruit_range = g_skynet_recruit_range

    -- First pass: try normal range. If nothing found, try extended range (Emergency Recruitment)
    for pass = 1, 2 do
        local range_sq = current_recruit_range * current_recruit_range
        for i = 0, vehicle_count - 1 do
            local vehicle = update_get_map_vehicle_by_index(i)
            if vehicle:get() and vehicle:get_team() == 0 then
                if math.random() < g_skynet_recruitment_chance then
                    local def = vehicle:get_definition_index()
                    local dist_sq = vec2_dist_sq(carrier_pos, vehicle:get_position_xz())
                    if dist_sq < range_sq then
                        if get_is_vehicle_sea(def) then
                            table.insert(ships, { unit = vehicle, dist_sq = dist_sq })
                        elseif get_is_vehicle_air(def) then
                            table.insert(air_units, { unit = vehicle, dist_sq = dist_sq })
                        elseif get_is_vehicle_land(def) then
                            table.insert(land_units, { unit = vehicle, dist_sq = dist_sq })
                        end
                    end
                end
            end
        end

        if #ships > 0 or #air_units > 0 or #land_units > 0 then break end
        current_recruit_range = g_skynet_recruit_range * 2 -- Double range if no one found
        print("Emergency: No units in primary range, extending scan...")
    end

    table.sort(ships, function(a, b) return a.dist_sq < b.dist_sq end)
    table.sort(air_units, function(a, b) return a.dist_sq < b.dist_sq end)
    table.sort(land_units, function(a, b) return a.dist_sq < b.dist_sq end)

    -- Command units with various tactics
    command_wave(ships, ship_wave_size, carrier, carrier_pos, "ship")
    command_wave(air_units, air_wave_size, carrier, carrier_pos, "air")
    command_wave(land_units, g_skynet_bear_wave_size, carrier, carrier_pos, "land")
end

function command_wave(units, max_count, carrier, carrier_pos, type_name)
    local commanded = 0
    for i, v in ipairs(units) do
        if commanded >= max_count then break end

        local unit = v.unit
        local dist = math.sqrt(v.dist_sq)

        -- Tactic Selection: 1=Direct, 2=Ambush, 3=Encircle
        local tactic_roll = math.random(1, 100)
        local target_x, target_y = carrier_pos:x(), carrier_pos:y()

        if tactic_roll > 70 then -- Encircle (30% chance)
            local angle = math.random() * math.pi * 2
            local radius = 3900 -- Increased from 3000 (+30%)
            target_x = target_x + math.cos(angle) * radius
            target_y = target_y + math.sin(angle) * radius
            print(string.format("%s %d encircling...", type_name, unit:get_id()))
        elseif tactic_roll > 40 then -- Ambush/Stalk (30% chance)
            if dist > 7800 then -- Increased from 6000 (+30%)
                -- Move to a point between current pos and carrier, but stay 5.2km away
                local dir_x = (carrier_pos:x() - unit:get_position_xz():x()) / dist
                local dir_y = (carrier_pos:y() - unit:get_position_xz():y()) / dist
                target_x = carrier_pos:x() - dir_x * 5200 -- Increased from 4000 (+30%)
                target_y = carrier_pos:y() - dir_y * 5200
                print(string.format("%s %d stalking (ambush)...", type_name, unit:get_id()))
            end
        end

        unit:clear_waypoints()
        local wid = unit:add_waypoint(target_x, target_y)

        -- Attack trigger remains physical distance based
        local attack_range = 5500
        if type_name == "air" then attack_range = 5600 elseif type_name == "land" then attack_range = 2100 end

        if g_controller and dist < attack_range then
            local atype = e_attack_type.any
            if type_name == "ship" then
                local rnd = math.random(1, 3)
                if rnd == 1 and unit:get_is_attack_type_capable(e_attack_type.order_cruise_missile, true, true, true) then atype = e_attack_type
                        .order_cruise_missile
                elseif rnd == 2 and unit:get_is_attack_type_capable(e_attack_type.order_main_gun, true, true, true) then atype = e_attack_type
                        .order_main_gun
                end
            end

            local wpt = unit:get_waypoint_by_id(wid)
            if wpt and wpt:get() then
                unit:set_waypoint_attack_target_target_id(wid, carrier:get_id())
                unit:set_waypoint_attack_target_attack_type(wid, 1, atype)
            end
        end
        commanded = commanded + 1
    end
end

function get_is_vehicle_land(def)
    return def == e_game_object_type.chassis_land_wheel_heavy
        or def == e_game_object_type.chassis_land_wheel_medium
        or def == e_game_object_type.chassis_land_wheel_light
        or def == e_game_object_type.chassis_land_wheel_mule
        or def == e_game_object_type.chassis_deployable_droid
        or def == e_game_object_type.chassis_land_robot_dog
end

function get_player_island_count()
    local count = 0
    local tile_count = update_get_tile_count()
    for i = 0, tile_count - 1 do
        local tile = update_get_tile_by_index(i)
        if tile:get() and tile:get_team_control() == 1 then -- Team 1 is usually player
            count = count + 1
        end
    end
    return count
end

if g_rev_mods ~= nil then
    table.insert(g_rev_mods, "AI:Skynet")
end
