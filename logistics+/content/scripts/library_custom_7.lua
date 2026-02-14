
if g_rev_mods ~= nil then
	table.insert(g_rev_mods, "Logistics+")
end

function lp_custom_unload_barge(barge, carrier)
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

function lp_custom_pickup_barge(barge, carrier, tile)
	-- if there are not two waypoints, then wipe and add collect and drop
	local wpc = barge:get_waypoint_count()
	if wpc ~= 2 then
		barge:clear_waypoints()
		local tile_pos = tile:get_position_xz()
		local waypoint_id = barge:add_waypoint(tile_pos:x(), tile_pos:y())
		barge:set_waypoint_type_barge_load_tile(waypoint_id, tile:get_id())
		local pos = carrier:get_position_xz()
		waypoint_id = barge:add_waypoint(pos:x(), pos:y())
		barge:set_waypoint_type_barge_unload_carrier(waypoint_id, carrier:get_id())
	end
end


function lp_get_island_has_requested_cargo(vehicle, tile)
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

function lplus_render(screen_w, screen_h, x, y, w, h, is_tab_active, screen_vehicle)
	local st, v = pcall(_lplus_render, screen_w, screen_h, x, y, w, h, is_tab_active, screen_vehicle)
	if not st then
		print(v)
	end
	return v
end

function _lplus_render(screen_w, screen_h, x, y, w, h, is_tab_active, screen_vehicle)
	local ui = g_ui
	update_ui_push_offset(x, y)
	local is_local = update_get_is_focus_local()
	ui:begin_window("-", 5, 0, w - 10, h, nil, true, 1)

	if screen_vehicle and screen_vehicle:get() then

		local enable_btn = update_get_loc(e_loc.upp_no)
		if g_tab_logiplus.is_enabled then
			enable_btn = update_get_loc(e_loc.upp_yes)
		end
		ui:text_basic( "Logistics+ " .. update_get_loc(e_loc.upp_active))
		if ui:button(enable_btn, true, 0) then
			g_tab_logiplus.is_enabled = not g_tab_logiplus.is_enabled
		end

		g_tab_logiplus:update()

	end

	ui:end_window()
	update_ui_pop_offset()
end


function lplus_input_event(input, action)
	if input == e_input.back then
        return true
    end
    g_ui:input_event(input, action)
    return false
end

function lplus_input_pointer(is_hovered, x, y)
	g_ui:input_pointer(is_hovered, x, y)
end

function lplus_input_scroll(dy)
	g_ui:input_scroll(dy)
end

function lp_get_nearest_island_tile(x, y)
    local tile_count = update_get_tile_count()
    local index = 0
    local nearest = nil
    local dist = 90000 * 90000

    local pos = vec2(x, y)

    while index < tile_count do
        local tile = update_get_tile_by_index(index)
        if tile:get() then
            index = index + 1
            local tile_pos = tile:get_position_xz()
            local tile_dist_sq = vec2_dist_sq(tile_pos, pos)

            if tile_dist_sq < dist then
                dist = tile_dist_sq
                nearest = tile
            end
        end
    end
    return nearest
end

g_tab_logiplus = {
	tab_title = e_loc.upp_logistics,
	render = lplus_render,
	input_event = lplus_input_event,
	input_pointer = lplus_input_pointer,
	input_scroll = lplus_input_scroll,
	is_overlay = false,
	is_enabled = false,
	interval = 30,
	next_tick = 30,
	update = function(self)
		local now = update_get_logic_tick()
		local ui = g_ui

		-- look at all islands
		local carrier = update_get_screen_vehicle()
		local our_team = update_get_screen_team_id()
		local island_count = update_get_tile_count()
		local stocked = {}

		-- find all island that have cargo we want
		for i = 0, island_count - 1 do
			local island = update_get_tile_by_index(i)
			if island:get_team_control() == our_team then
				if lp_get_island_has_requested_cargo(carrier, island) then
					table.insert(stocked, island)
				end
			end
		end

		ui:text_basic(string.format("Islands with requested stock: %d", #stocked))

		-- find all barges
		local barges = {}
		local idle_barges = {}
		local barge_tiles = {}
		local tile_barge = {}

		local vehicle_count = update_get_map_vehicle_count()
		for i = 0, vehicle_count - 1, 1 do
			local vehicle = update_get_map_vehicle_by_index(i)
			if vehicle:get() then
				local vehicle_team = vehicle:get_team()
				if vehicle_team == our_team then
					local vehicle_definition_index = vehicle:get_definition_index()
					if vehicle_definition_index == e_game_object_type.chassis_sea_barge then
						table.insert(barges, vehicle)
						local wpc = vehicle:get_waypoint_count()
						if wpc == 0 then
							table.insert(idle_barges, vehicle)
						else
							-- find out what islands this barge is going to
							for w = 0, wpc do
								local waypoint_data = vehicle:get_waypoint(w)
								if waypoint_data:get() then
									local waypoint_type = waypoint_data:get_type()
									if waypoint_type == e_waypoint_type.barge_load_tile then
										local wpp = waypoint_data:get_position_xz()
										local pickup = lp_get_nearest_island_tile(wpp:x(), wpp:y())
										barge_tiles[pickup:get_id()] = vehicle:get_id()
										tile_barge[vehicle:get_id()] = pickup:get_id()
									end
								end
							end
						end
					end
				end
			end
		end

		ui:text_basic(string.format("Active barges: %d/%d", #barges - #idle_barges, #barges))
		ui:text_basic(string.format("Logistic tick: %d", self.next_tick))

		if self.is_enabled then
			ui:text_basic("Keep this tab selected for barge automation")
		end

		if self.is_enabled and now > self.next_tick then
			self.next_tick = self.interval + now

			-- find the nearest idle barge to each stocked island and setup a route
			for i, tile in pairs(stocked) do
				if barge_tiles[tile:get_id()] == nil then -- no barge is going here
					--print("need a barge for", tile:get_name())
					local tile_pos = tile:get_position_xz()
					local dist_sq = 9999999999
					-- find the nearest idle barge to this tile
					local nearest_barge = nil
					for j, barge in pairs(idle_barges) do
						if barge:get_waypoint_count() == 0 then
							local bp = barge:get_position_xz()
							local bdist_sq = vec2_dist_sq(bp, tile_pos)
							if bdist_sq < dist_sq then
								nearest_barge = barge
								-- print("barge", barge:get_id(), "is nearest", tile:get_name())
							end
						end
					end
					if nearest_barge then
						--print("order barge", nearest_barge:get_id(), "to", tile:get_name())
						lp_custom_pickup_barge(nearest_barge, carrier, tile)
					end
				end
			end
		end
	end,
}

-- insertion code
real_begin_load_x = begin_load
inserted_logi_plus = false

function begin_load()
	real_begin_load_x()
	if begin_get_screen_name and begin_get_screen_name() == "screen_inv_r_large" then
		if not inserted_logi_plus then
			inserted_logi_plus = true
			local last_tab_id = -1
			for k, v in pairs(g_tabs) do
				if type(k) == "number" then
					last_tab_id = math.max(k, last_tab_id)
				end
			end
			local next_tab = last_tab_id + 1
			g_tabs.logiplus = next_tab
			g_tabs[next_tab] = g_tab_logiplus
		end

	end
end