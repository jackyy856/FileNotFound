var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

if (mouse_check_button_pressed(mb_left)) {
    if (_hit(back_btn, mx, my)) {
        room_goto(room_Menu);
        exit;
    }
    // choose a slot (placeholder behavior)
    var n = array_length(slots);
    for (var i = 0; i < n; i++) {
        var s = slots[i];
        if (_hit(s, mx, my)) {
            global.save_slot = s.idx; // just remember which slot
            // here you would load… but for prototype, just go to Black_1
            room_goto(room_Black_1);
        }
    }
}
