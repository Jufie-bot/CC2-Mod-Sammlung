g_blink_timer = 0

function begin()
    begin_load()
end

g_installed_new_hardware = 0

function find_drydock()
    local this_vehicle = update_get_screen_vehicle()
    if this_vehicle:get() == false then return end
    local this_vehicle_id = this_vehicle:get_id()
    local vehicle_count = update_get_map_vehicle_count()
    local index = 0
    while index < vehicle_count do
        print(string.format("Scanning for %d ..", index))
        local vehicle = update_get_map_vehicle_by_index(index)
        print("v")
        if vehicle:get() then
            print("v get")
            def = vehicle:get_definition_index()
            print("v def")
            if def == e_game_object_type.drydock then
                print("v is a certified drydock")
                local child = vehicle:get_attached_vehicle_id(0)
                print("v child")
                if child == this_vehicle_id then
                    print("v drydock correct")
                    return vehicle
                end
            end
        end
        index = index + 1
    end

    return nil
end


function do_combat_carrier_setup()
    g_installed_new_hardware = 1
    print("Setup carrier weapons..")
    local drydock = find_drydock()
    if drydock then
        print(string.format("Drydock id is %d", drydock:get_id()))

        print("Setup weapons..BL")
        drydock:set_attached_vehicle_attachment(0, 14, e_game_object_type.attachment_turret_15mm)
        print("Setup weapons..BR")
        drydock:set_attached_vehicle_attachment(0, 15, e_game_object_type.attachment_turret_15mm)
        print("Setup weapons..FR")
        drydock:set_attached_vehicle_attachment(0, 16, e_game_object_type.attachment_turret_15mm)
        print("Setup weapons..FL")
        drydock:set_attached_vehicle_attachment(0, 17, e_game_object_type.attachment_turret_15mm)
        print("Setup weapons..B")
        drydock:set_attached_vehicle_attachment(0, 18, e_game_object_type.attachment_turret_15mm)
        print("Setup weapons..E")
        drydock:set_attached_vehicle_attachment(0, 19, e_game_object_type.attachment_turret_15mm)
        print("setup weapons..G")
        drydock:set_attached_vehicle_attachment(0, 20, e_game_object_type.attachment_turret_droid)
        print("Setup weapons..H1")
        drydock:set_attached_vehicle_attachment(0, 21, e_game_object_type.attachment_turret_droid)
        print("Setup weapons..H2")
        drydock:set_attached_vehicle_attachment(0, 22, e_game_object_type.attachment_turret_droid)
        print("Setup weapons..LOG1")
        drydock:set_attached_vehicle_attachment(0, 23, e_game_object_type.attachment_logistics_container_20mm)
        print("Setup weapons..LOG2")
        drydock:set_attached_vehicle_attachment(0, 24, e_game_object_type.attachment_logistics_container_30mm)
        print("Setup weapons..LOG3")
        drydock:set_attached_vehicle_attachment(0, 25, e_game_object_type.attachment_logistics_container_40mm)
        print("Setup weapons..LOG4")
        drydock:set_attached_vehicle_attachment(0, 26, e_game_object_type.attachment_logistics_container_100mm)
        print("Setup weapons..LOG5")
        drydock:set_attached_vehicle_attachment(0, 27, e_game_object_type.attachment_logistics_container_120mm)
        print("Setup weapons..LOG6")
        drydock:set_attached_vehicle_attachment(0, 28, e_game_object_type.attachment_logistics_container_fuel)
        print("Setup weapons..LOG7")
        drydock:set_attached_vehicle_attachment(0, 29, e_game_object_type.attachment_logistics_container_ir_missile)
        print("Setup weapons..LM")
        drydock:set_attached_vehicle_attachment(0, 30, e_game_object_type.attachment_hardpoint_missile_laser)
        print("Setup weapons..FUEL")
        drydock:set_attached_vehicle_attachment(0, 31, e_game_object_type.attachment_fuel_tank_plane)
        print("Setup weapons..SCBL")
        drydock:set_attached_vehicle_attachment(0, 32, e_game_object_type.attachment_turret_droid)
        print("Setup weapons..SCBR")
        drydock:set_attached_vehicle_attachment(0, 33, e_game_object_type.attachment_turret_droid)
        print("Setup weapons..SCFR")
        drydock:set_attached_vehicle_attachment(0, 34, e_game_object_type.attachment_turret_droid)
        print("Setup weapons..SCFL")
        drydock:set_attached_vehicle_attachment(0, 35, e_game_object_type.attachment_turret_droid)
        print("Setup weapons..WEAPONS ONLINE")
    end
end


function update(screen_w, screen_h, ticks)

    if g_installed_new_hardware == 0 then

        pcall(do_combat_carrier_setup)
    end

    if update_screen_overrides(screen_w, screen_h, ticks)  then return end

    local this_vehicle = update_get_screen_vehicle()
    if this_vehicle:get() == false then return end
    local this_vehicle_object = update_get_vehicle_by_id(this_vehicle:get_id())
    if this_vehicle_object:get() == false then return end

    g_blink_timer = g_blink_timer + 1
    if(g_blink_timer > 30)
    then 
        g_blink_timer = 0 
    end

    local active_mode = this_vehicle_object:get_self_destruct_mode()
    local countdown = this_vehicle_object:get_self_destruct_countdown()

    update_ui_rectangle_outline((screen_w/2)-20, (screen_h/2)-2, 40, 12, color_white)

    if active_mode == g_self_destruct_modes.locked then
        update_ui_text(0, screen_h/2, update_get_loc(e_loc.upp_lck), 128, 1, color_white, 0)
    elseif active_mode == g_self_destruct_modes.input then
        if g_blink_timer > 5 then
          update_ui_text(0, screen_h/2, string.format("%.2f", countdown / 30), 128, 1, color_white, 0)
        end
    elseif active_mode == g_self_destruct_modes.ready then
        col = color_status_warning
        update_ui_text(0, screen_h/2-12, update_get_loc(e_loc.upp_armed), 128, 1, color_white, 0)
        update_ui_text(0, screen_h/2, string.format("%.2f", countdown / 30), 128, 1, color_white, 0)
    end 
end

function input_event(event, action)
    if action == e_input_action.release then
        if event == e_input.back then
            update_set_screen_state_exit()
        end
    end
end