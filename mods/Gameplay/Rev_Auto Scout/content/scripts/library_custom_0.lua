if g_rev_major == nil or g_rev_minor < 4 then
	-- revolution is not installed, tell the user
	update_screen_overrides = function(screen_w, screen_h, ticks)
		update_ui_text(20, 20, "Rev:Auto Scan needs Revolution mod 1.4+",
				110, 0, color_white, 0)
		return false
	end
end

if g_rev_mods ~= nil then
	table.insert(g_rev_mods, "Auto Scan")
end

g_original_get_is_visible_by_modded_radar =  get_is_visible_by_modded_radar

local _all_cameras = {}
local _all_cameras_last_update = -1000


local function iter_vehicles(filter)
    local vehicle_count = update_get_map_vehicle_count()
    local index = 0

    local skip = function(v)
        return v == nil or v:get() == false or (filter ~= nil and filter(v) == false)
    end

    return function()
        local vehicle = nil

        while index < vehicle_count do
            vehicle = update_get_map_vehicle_by_index(index)
            index = index + 1

            if skip(vehicle) then
                vehicle = nil
            else
                break
            end
        end

        if vehicle ~= nil then
            return index, vehicle
        end
    end
end

local function update_all_cameras()
	-- find all friendly, deployed air obs cameras
	local now = update_get_logic_tick()

	if now > _all_cameras_last_update + 60 then
		local team_id = update_get_screen_team_id()
		_all_cameras_last_update = now
		_all_cameras = {}

		local vehicle_count = update_get_map_vehicle_count()

    	for vid = 0, vehicle_count - 1 do
        	local v = update_get_map_vehicle_by_index(vid)
			if v and v:get() and get_is_vehicle_air(v:get_definition_index()) then
				local v_team = get_unit_team(v)
				if v_team == team_id and not get_vehicle_docked(v) then
					local attachment_count = v:get_attachment_count()
					for i = 1, attachment_count do
						local a = v:get_attachment(i)
						if a and a:get() then
							local a_def = a:get_definition_index()
							if a_def == e_game_object_type.attachment_camera_plane then
								table.insert(_all_cameras, v:get_id())
							end
						end
					end
				end
			end
		end
	end
end


function get_is_visible_by_modded_radar(vehicle)
	if vehicle and vehicle:get() then
		update_all_cameras()
		local screen_team = update_get_screen_team_id()
		local v_team = get_vehicle_team_id(vehicle)
		if screen_team ~= v_team then
			if not get_vehicle_docked(vehicle) then
				local v_def = vehicle:get_definition_index()
				if not get_is_vehicle_air(v_def) and not get_is_vehicle_sea(v_def) then
					local v_pos = get_pos_xz(vehicle)
					for _, cam_id in pairs(_all_cameras) do
						local cam = update_get_map_vehicle_by_id(cam_id)
						if cam and cam:get() then
							local cam_pos = get_pos_xz(cam)
							local dist = vec2_dist(cam_pos, v_pos)
							if dist < 4500 then
								return true
							end
						end
					end
				end
			end
		end
	end
	return g_original_get_is_visible_by_modded_radar(vehicle)
end