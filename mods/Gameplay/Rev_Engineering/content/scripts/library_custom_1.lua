-- revolution crafting system
--
-- when you are near and/or control particular island types you will be able to
-- unlock extra loadout options for some units, doing so will involve a "cost"
-- to be paid in carrier inventory stock (dumped over the side).
-- once fitted out in one of these special modes, if you remove anything
-- added by the alternate loadout, you wont be permitted to re-add it.

function custom_dynamic_vehicle_loadout_rows(vehicle, dynamic)
	local opt, fitted = rev_get_custom_upgrade_option(vehicle)
	local rows = {}
	if opt and fitted then
		for i, r in pairs(opt.rows) do
			if r ~= nil then
				rows[i] = r
			end
		end
		return rows
	end

	return dynamic
end

function custom_dynamic_vehicle_loadout_options(vehicle, dynamic, attachment_index)
	local replaced_opts = nil
	local opt, fitted = rev_get_custom_upgrade_option(vehicle)
	if opt and fitted then
		replaced_opts = opt.options[attachment_index]
	end

	if replaced_opts ~= nil then
		dynamic = replaced_opts
	end

	return dynamic
end


function rev_engineering_can_upgrade(vehicle)
	local opt, fitted = rev_get_custom_upgrade_option(vehicle)
	return opt and not fitted
end

g_prompt_upgrade_vehicle = nil

function rev_get_custom_upgrade_option(vehicle)
	if vehicle and vehicle:get() then
		local def = vehicle:get_definition_index()
		for _, value in pairs(g_revolution_crafting_items) do
			if value.chassis == def then
				-- if a special option isnt fitted
				local fitted = false
				local acount = vehicle:get_attachment_count()
				if acount == value.min_attachments then
					for anum, adef in pairs(value.attachments) do
						local a = vehicle:get_attachment(anum)
						if a and a:get() then
							local a_fitted = a:get_definition_index()
							if a_fitted == adef then
								fitted = true
							end
						end
					end
					return value, fitted
				end
			end
		end
	end
	return nil, nil
end


function custom_vehicle_input_event(event, action)
	if g_prompt_upgrade_vehicle then
		if event == e_input.back then
			g_prompt_upgrade_vehicle = nil
		end
	end
end

function custom_vehicle_loadout_update(screen_w, screen_h, ticks)
	if g_prompt_upgrade_vehicle then
		local vehicle = update_get_map_vehicle_by_id(g_prompt_upgrade_vehicle)
		local upgrade_option, fitted = rev_get_custom_upgrade_option(vehicle)

		if upgrade_option ~= nil then
			local carrier = get_managed_vehicle()
			update_add_ui_interaction(update_get_loc(e_loc.interaction_back), e_game_input.back)
			local ui = g_ui
			ui:begin_ui()
			local window = ui:begin_window("Engineering", 0, 0, screen_w, screen_h, nil, true, 1)
			-- title
			update_ui_rectangle(0, 0, screen_w, 14, color_white)
			window.cy = 3 + update_ui_text(0, 4, "UPGRADE UNIT?", screen_w, 1, color_black, 0)
			local v_def = vehicle:get_definition_index()

			-- body
			local v_name, v_icon, v_abbr, v_desc = get_chassis_data_by_definition_index(v_def)

			ui:text_basic(v_name, color_white, color_white)
			ui:text_basic("> " .. upgrade_option.name)
			ui:text_basic(upgrade_option.details)
			ui:text_basic("COST:")
			local has_reqs = true
			local costs = upgrade_option.cost
			for inv_item, inv_count in pairs(costs) do
				local has_count = carrier:get_inventory_count_by_item_index(inv_item)
				local col = color_grey_dark
				if has_count < inv_count then
					col = color_status_dark_red
					has_reqs = false
				end
				ui:text_basic(string.format("%dx %s", inv_count, g_item_data[inv_item].name), col)
			end

			if ui:button("APPLY", has_reqs, 1) then
				g_prompt_upgrade_vehicle = nil
				if update_get_is_focus_local() then
					-- do the upgrade
					for anum, _ in pairs(upgrade_option.options) do
						carrier:set_attached_vehicle_attachment(g_selected_bay_index, anum, -1)
					end
					for anum, adef in pairs(upgrade_option.attachments) do
						carrier:set_attached_vehicle_attachment(g_selected_bay_index, anum, adef)
					end
					-- "spend" the fuel
					for inv_item, inv_count in pairs(upgrade_option.cost) do
						if inv_item == e_inventory_item.fuel_barrel then
							carrier:set_inventory_order(inv_item, inv_count, e_carrier_order_operation.delete)
						end
					end
					sanitise_loadout(carrier, g_selected_bay_index)
				end
			end

			ui:end_window()
			ui:end_ui()
			return true
		else
			g_prompt_upgrade_vehicle = nil
		end
	end

	return false
end

function custom_ui_vehicle_loadout_chassis(ui, vehicle)
	local opt, fitted = rev_get_custom_upgrade_option(vehicle)
	if opt ~= nil then
		if not fitted then
			local carrier = get_managed_vehicle()
			sanitise_loadout(carrier, g_selected_bay_index)
		end
		rev_custom_button(ui, "REFIT",
				4, 72, 47, 18, not fitted, function()
					if vehicle and vehicle:get() then
						g_prompt_upgrade_vehicle = vehicle:get_id()
					end
				end)
	else
		g_prompt_upgrade_vehicle = nil
	end
end

--

local g__crafting_reduced_wing = {
	e_game_object_type.attachment_turret_plane_chaingun,
	e_game_object_type.attachment_hardpoint_bomb_1,
	e_game_object_type.attachment_hardpoint_missile_ir,
	e_game_object_type.attachment_hardpoint_missile_laser,
	e_game_object_type.attachment_hardpoint_missile_aa,
	e_game_object_type.attachment_hardpoint_torpedo_noisemaker,
	e_game_object_type.fuel_tank_aircraft,
}

local g__crafting_aa_reduced_wing = {
	e_game_object_type.attachment_hardpoint_missile_aa,
	e_game_object_type.attachment_hardpoint_missile_tv,
}

local g__crafting_aa_extra_wing = {
	e_game_object_type.attachment_hardpoint_missile_aa,
}

local g__crafting_flare_wing = {
	e_game_object_type.attachment_fuel_tank_plane,
	e_game_object_type.attachment_flare_launcher,
	e_game_object_type.attachment_smoke_launcher_explosive,
}

g_revolution_crafting_items = {
    {
		name="Specops Petrel",
		details="Flare & Virus",
        chassis=e_game_object_type.chassis_air_rotor_heavy,
		min_attachments=6,
        attachments={
            [4] = e_game_object_type.attachment_turret_robot_dog_capsule,
		},
		options={
			[1] = {
				e_game_object_type.attachment_camera_plane
			},
			[4] = {e_game_object_type.attachment_turret_robot_dog_capsule},
			[2] = {
				e_game_object_type.attachment_turret_plane_chaingun,
				e_game_object_type.attachment_fuel_tank_plane,
			},
			[5] = {
				e_game_object_type.attachment_flare_launcher,
				e_game_object_type.attachment_smoke_launcher_explosive,
			},
			[3] = {
				e_game_object_type.attachment_turret_plane_chaingun,
				e_game_object_type.attachment_fuel_tank_plane,
			},
		},
		rows={
			{
                { i=1, x=0, y=-22 }
            },
            {
                { i=2, x=-20, y=0 },
                { i=4, x=-10, y=0 },
                { i=5, x=10, y=0 },
                { i=3, x=20, y=0 }
            }
		},
        cost={
            [e_inventory_item.fuel_barrel] = 1,
            [e_inventory_item.virus_module] = 1,
        }
    },
	{
		name="Manta F2",
		details="Extra missiles",
		chassis=e_game_object_type.chassis_air_wing_heavy,
		min_attachments=11,
		attachments={
			[10] = e_game_object_type.attachment_camera_observation,
		},
		options={
			[4] = g__crafting_aa_reduced_wing,
			[5] = g__crafting_aa_reduced_wing,
			[8] = g__crafting_aa_extra_wing,
			[9] = g__crafting_aa_extra_wing,
			[10] = {
				e_game_object_type.attachment_camera_observation
			}
		},
		rows={
			{
				{ i = 1, x = 0, y = -23 }, -- front camera slot
				{ i = 2, x = 9, y = -4 }  -- internal gun
			},
			{
				{ i = 3, x = 0, y = 7 },   -- centre
				{ i = 4, x = -18, y = 7 }, -- left inner
				{ i = 5, x = 18, y = 7 },  -- right inner
			},
			{
				{ i = 6, x = -9, y = 24 }, -- left util
				{ i = 7, x = 9, y = 24 }   -- right util
			},
		    {
			   { i = 8, x = -26, y = 16 }, -- left wing
			   { i = 9, x = 26, y = 16 },  -- right wing
			   { i = 10, x = 0, y = 16 },  -- dorsal
			}
		},
		cost={
            [e_inventory_item.fuel_barrel] = 2,
			[e_inventory_item.attachment_camera_observation] = 1
        }
	},
	{
		name="Koala",
		details="Anti-Air system",
		chassis=e_game_object_type.chassis_land_wheel_heavy,
		min_attachments=9,
		attachments={
			[2] = e_game_object_type.attachment_radar_golfball
		},
		options={
			[2] = {e_game_object_type.attachment_radar_golfball},
			[4] = g__crafting_aa_reduced_wing,
			[5] = g__crafting_aa_reduced_wing,
			[6] = g__crafting_aa_reduced_wing,
			[7] = g__crafting_aa_reduced_wing,
			[8] = g__crafting_aa_reduced_wing,
		},
		rows={
			{
				{ i=2, x=0, y=-25 },
				{ i=4, x=-14, y=-6 },
				{ i=5, x=0, y=-6 },
				{ i=6, x=14, y=-6 },
				{ i=7, x=-14, y=20 },
				{ i=8, x=14, y=20 },
			}
		},
	    cost={
            [e_inventory_item.fuel_barrel] = 4,
			[e_inventory_item.attachment_radar_golfball] = 1,
        }
	},
	{
		name="Hinny",
		details="Mobile LGM Silo",
		chassis=e_game_object_type.chassis_land_wheel_mule,
		min_attachments=7,
		attachments={
			[1] = e_game_object_type.attachment_camera_observation
		},
		options={
			[1] = {e_game_object_type.attachment_camera_observation},
			[2] = {e_game_object_type.attachment_hardpoint_missile_laser},
			[3] = {e_game_object_type.attachment_hardpoint_missile_laser},
			[4] = {e_game_object_type.attachment_hardpoint_missile_laser},
			[5] = {e_game_object_type.attachment_hardpoint_missile_laser},
			[6] = {e_game_object_type.attachment_hardpoint_missile_laser},
		},
		rows={
			{
				{ i=1, x=-10, y=-21 },
				{ i=2, x=10, y=-21 },
				{ i=3, x=-10, y=-5 },
				{ i=4, x=10, y=-5 },
				{ i=5, x=-10, y=11 },
				{ i=6, x=10, y=11 },
			}
		},
	    cost={
            [e_inventory_item.fuel_barrel] = 2,
			[e_inventory_item.attachment_camera_observation] = 1,
        }
	}
}


if g_rev_major == nil or g_rev_minor < 4 then
	-- revolution 1.4 is not installed, tell the user
	update_screen_overrides = function(screen_w, screen_h, ticks)
		update_ui_text(20, 20, "Engineering needs Revolution mod 1.4+",
				110, 0, color_white, 0)
		return false
	end
end
if g_rev_mods ~= nil then
	table.insert(g_rev_mods, "Engineering")
end