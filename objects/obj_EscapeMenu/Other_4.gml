/// obj_EscapeMenu — Room Start
// Don’t auto-open and don’t leave any stale drag/toast running.
active = false;
state  = "root";
submenu = "";
confirm_slot = -1;
if (is_struct(slider)) slider.dragging = false;
toast_t = 0;

// Rebuild layout if GUI changed across rooms
if (display_get_gui_width() != _last_gui_w || display_get_gui_height() != _last_gui_h) {
    _layout();
}

// THE FIX: if we land in the Menu room, guarantee the controller exists.
if (room == room_Menu) {
    if (!instance_exists(obj_MenuController)) {
        var lyr = layer_exists("Instances") ? "Instances" : layer_get_name(layer_get_id(0));
        instance_create_layer(room_width * 0.5, room_height * 0.5, lyr, obj_MenuController);
    }
}
