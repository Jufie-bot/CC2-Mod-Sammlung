-- attachment hardpoint overrides

-- useful constants to reduce typing later
g_std_wing_attachments = {
	-- the weapons all aircraft can normally mount on wing pylons
	e_game_object_type.attachment_turret_plane_chaingun,
	e_game_object_type.attachment_turret_rocket_pod,
	e_game_object_type.attachment_hardpoint_bomb_1,
	e_game_object_type.attachment_hardpoint_bomb_2,
	e_game_object_type.attachment_hardpoint_bomb_3,
	e_game_object_type.attachment_hardpoint_missile_ir,
	e_game_object_type.attachment_hardpoint_missile_laser,
	e_game_object_type.attachment_hardpoint_missile_aa,
	e_game_object_type.attachment_hardpoint_missile_tv,
	e_game_object_type.attachment_hardpoint_torpedo,
	e_game_object_type.attachment_hardpoint_torpedo_noisemaker,
	e_game_object_type.attachment_hardpoint_torpedo_decoy,
	e_game_object_type.attachment_fuel_tank_plane
}

g_std_wing_utils = {
	-- the utility items aircraft can normally use
	e_game_object_type.attachment_flare_launcher,
	e_game_object_type.attachment_sonic_pulse_generator,
	e_game_object_type.attachment_smoke_launcher_explosive,
	e_game_object_type.attachment_smoke_launcher_stream
}

if g_rev_aircraft_max_payload then
    g_rev_aircraft_max_payload[e_game_object_type.chassis_air_wing_heavy] = 5000
end

g_revolution_override_attachment_options = {
	-- each [x] element is a chassis type
	-- the value can have rows, or options or both,

	-- to prevent a hardpoint being used, you need to omit it from `rows` for that unit
	-- to limit/expand the choices for a hardpoint, you define an `options` value

	[e_game_object_type.chassis_air_wing_heavy] = {
		-- the manta here is roughly the Revoltion 1.2 Manta with some changes to
		-- illustrate the example
		rows = {
			-- each row shows where the hardpoint box graphic will appear for each hardpoint
			-- in this example, there are 3 rows for the manta
			{
				{ i = 1, x = 0, y = -23 }, -- front camera slot
				{ i = 2, x = 8, y = -11 }  -- internal gun
			},
			{
				{ i = 8, x = -26, y = 11 }, -- left outer
				{ i = 4, x = -16, y = 0 }, -- left inner
				{ i = 3, x = 0, y = 0 },   -- centre
				{ i = 5, x = 16, y = 0 },  -- right inner
				{ i = 9, x = 26, y = 11 }   -- right outer
			},
			{
				{ i = 6, x = -13, y = 20 }, -- left util
				{ i = 7, x = 13, y = 20 }   -- right util
			}
		},
		options = {
			-- the list of attachment choices for each hardpoint on the unit
			-- the [x] numbers here are the attachment index numbers, they
			-- normally correspond to the i=x values above or in library_ui.lua

			-- nose slot
			[1] = {
				e_game_object_type.attachment_camera_plane,
				e_game_object_type.attachment_turret_gimbal_30mm,
			},
			-- left wing inner
			[4] = g_std_wing_attachments,  -- g_std_wing_attachments is a list defined above

			-- middle
			[3] = {
				-- middle hardpoint limited to fuel or light/medium bombs
				e_game_object_type.attachment_fuel_tank_plane,
				e_game_object_type.attachment_hardpoint_bomb_1,
				e_game_object_type.attachment_hardpoint_bomb_2,
                e_game_object_type.attachment_hardpoint_bomb_3,
                e_game_object_type.attachment_turret_rocket_pod,
			},

			-- internal gun
			[2] = {
				-- internal hardpoint limited to chaingun only
				e_game_object_type.attachment_turret_plane_chaingun
			},

			-- right wing inner
			[5] = g_std_wing_attachments,

			-- left wing outer
			[8] = g_std_wing_attachments,

			-- right wing outer
			[9] = g_std_wing_attachments,

			-- utils
			[6] = g_std_wing_utils,
			[7] = g_std_wing_utils,


		}
	}
}


if g_radar_ranges == nil then
	-- revolution is not installed, tell the user
	update_screen_overrides = function(screen_w, screen_h, ticks)
		update_ui_text(20, 20, "Heavy Manta mod needs Revolution mod 1.3+",
				110, 0, color_white, 0)
		return false
	end
end
if g_rev_mods ~= nil then
	table.insert(g_rev_mods, "Heavy Manta")
end