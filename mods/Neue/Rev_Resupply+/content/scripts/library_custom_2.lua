

if g_rev_mods ~= nil then
	table.insert(g_rev_mods, "Resupply+")
end

g_last_resuply_call = 0
g_barge_bay = 17
g_crr_barge_interval = 60

function custom_unload_barge(barge, carrier)
	local wpc = barge:get_waypoint_count()
	-- if the first waypoint is an unload, then do nothing
	if wpc == 1 then
		local first = barge:get_waypoint(0)
		if first then
			local waypoint_type = first:get_type()
			if waypoint_type == e_waypoint_type.barge_unload_carrier then
				return
			end
		end
	end
	barge:clear_waypoints()
	local pos = carrier:get_position_xz()
	local waypoint_id = barge:add_waypoint(pos:x(), pos:y())
	barge:set_waypoint_type_barge_unload_carrier(waypoint_id, carrier:get_id())
end

function custom_pickup_barge(barge, carrier, tile)
	-- if there are not two waypoints, then wipe and add collect and drop
	local wpc = barge:get_waypoint_count()
	if wpc ~= 2 then
		barge:clear_waypoints()
		local tile_pos = get_command_center_position(tile:get_id())
		local waypoint_id = barge:add_waypoint(tile_pos:x(), tile_pos:y())
		barge:set_waypoint_type_barge_load_tile(waypoint_id, tile:get_id())
		local pos = carrier:get_position_xz()
		waypoint_id = barge:add_waypoint(pos:x(), pos:y())
		barge:set_waypoint_type_barge_unload_carrier(waypoint_id, carrier:get_id())
	end
end


function get_island_has_requested_cargo(vehicle, tile)
	-- iterate through the cargo requests for this carrier, return true if the island has any of these items
	for _, category in pairs(g_item_categories) do
		if #category.items > 0 then
			for _, item in pairs(category.items) do
				if update_get_resource_item_hidden(item.index) == false then
					local order_count = vehicle:get_inventory_order(item.index)
					if order_count > 0 then
						local store_count = tile:get_facility_inventory_count(item.index)
						if store_count > 0 then
							return true
						end
					end
				end
			end
		end
	end

	return false
end


function rsp_render(screen_w, screen_h, x, y, w, h, is_tab_active, screen_vehicle)
	local ui = g_ui
	local now = update_get_logic_tick()
	update_ui_push_offset(x, y)
	local is_local = update_get_is_focus_local()
	ui:begin_window("-", 5, 0, w - 10, h, nil, true, 1)
	ui:text_basic("Resupply+", color8(255, 255, 0, 128))

	if screen_vehicle and screen_vehicle:get() then
		local pos = screen_vehicle:get_position_xz()
		local tile = get_nearest_island_tile(pos:x(), pos:y())
		local screen_team = update_get_screen_team_id()
		local tile_pos = get_command_center_position(tile:get_id())
		local tile_owned = screen_team == tile:get_team_control()
		local tile_name = get_island_name(tile)
		ui:text_basic(
				string.format("%-14s %18s",
						update_get_loc(e_loc.island),
						tile_name
				))

		if tile_owned then
			local dist = math.floor(vec2_dist(pos, tile_pos))
			local resupply_max_range = 2200
			local tile_has_cargo = get_island_has_requested_cargo(screen_vehicle, tile)
			local dist_col = nil
			local in_range = false
			if dist < 2500 then
				dist_col = color8(255, 255, 0, 64)
				if dist < resupply_max_range then
					dist_col = color8(0, 255, 0, 64)
					in_range = true
				end
			end
			local barge = get_rsp_barge(screen_vehicle)
			local barge_payload = 0
			if barge then
				barge_payload = barge:get_inventory_weight()
			end

			ui:text_basic(string.format("%32dm", dist), dist_col)

			local barge_btn_enabled = false
			local btn_msg = "Out of range"
			local status_msg = "Standby"
			local status_color = nil
			if in_range then
				if not barge then
					btn_msg = "Begin loading"
					barge_btn_enabled = true
				end

				if barge and barge_payload > 0 then
					btn_msg = "Busy.."
					status_msg = string.format("Unload %5dkg", math.floor(barge_payload))
				end

				if barge and barge_payload == 0 then
					btn_msg = "Cancel loading"
					barge_btn_enabled = true
				end

			end
			local barge_wpc = -1
			if barge then
				barge_wpc = barge:get_waypoint_count()

				if now - g_last_resuply_call > g_crr_barge_interval then
					g_last_resuply_call = now
					if barge_wpc == 2 then
						-- barge currently set to do pickup and delivery
						if barge_payload > 0 then
							custom_unload_barge(barge, screen_vehicle)
						end
					end
					if barge_wpc == 1 then
						-- barge is set to unload
						if barge_payload == 0 then
							-- its empty, clear waypoints
							barge:clear_waypoints()
						end
					end

					if barge_wpc == 0 then
						-- barge set to nothing
						if in_range and tile_has_cargo then
							-- set pickup
							custom_pickup_barge(barge, screen_vehicle, tile)
						end
					end

					if not in_range and barge_payload == 0 then
						-- too far and barge is empty, remove it automatically
						screen_vehicle:set_attached_vehicle_chassis(g_barge_bay, -1)
					end

				end
			end

			if tile_has_cargo then
				if in_range then
					status_msg = "Cargo available"
					status_color = color8(255, 255, 255, 255)
					if barge_wpc == 2 then
						status_msg = "Loading.."
					elseif barge_wpc == 1 then
						status_msg = "Unloading.."
					end
				end
			else
				if barge_payload > 0 then
					status_msg = "Unloading ..."
				end
			end
			ui:text_basic(status_msg, status_color)
			if ui:button(btn_msg, barge_btn_enabled, 0) then
				if barge == nil then
					-- attach barge and start loading
					if is_local then
						screen_vehicle:set_attached_vehicle_chassis(g_barge_bay, e_game_object_type.chassis_sea_barge)
					end
				elseif barge_payload == 0 then
					-- remove the barge
					screen_vehicle:set_attached_vehicle_chassis(g_barge_bay, -1)
				end
			end
		else
			ui:text_basic("Hostile Island", color8(255, 0, 0, 128))
		end
	end

	ui:end_window()
	update_ui_pop_offset()
end

function get_rsp_barge(screen_vehicle)
	local barge_id = screen_vehicle:get_attached_vehicle_id(g_barge_bay)
	local b = nil
	if barge_id then
		b = update_get_map_vehicle_by_id(barge_id)
	end
	if b and b:get() then
		return b
	end
	return nil
end

function rsp_input_event(input, action)
	if input == e_input.back then
        return true
    end
    g_ui:input_event(input, action)
    return false
end

function rsp_input_pointer(is_hovered, x, y)
	g_ui:input_pointer(is_hovered, x, y)
end

function rsp_input_scroll(dy)
	g_ui:input_scroll(dy)
end


g_tab_resupply = {
	tab_title = e_loc.upp_load,
	render = rsp_render,
	input_event = rsp_input_event,
	input_pointer = rsp_input_pointer,
	input_scroll = rsp_input_scroll,
	is_overlay = false
}

-- insertion code
real_begin_load = begin_load
inserted_resupply_plus = false

function begin_load()
	real_begin_load()
	if not inserted_resupply_plus then
		inserted_resupply_plus = true
		if g_tab_barges and g_tabs[4] == nil then
			-- this is the inventory screen
			g_tabs.resupply = 4
			g_tabs[4] = g_tab_resupply
		end
	end
end