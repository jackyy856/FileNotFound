var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

function point_in_rect(px, py, x, y, w, h) {
    return (px >= x) && (py >= y) && (px < x + w) && (py < y + h);
}

// close button
if (mouse_check_button_pressed(mb_left)) {
    if (point_in_rect(mx, my, close_btn[0], close_btn[1], close_btn[2], close_btn[3])) {
        instance_destroy();
        exit;
    }
}

// ynbox view -> click a row to open
if (selected_index == -1) {
    if (mouse_check_button_pressed(mb_left) &&
        mx >= list_left && mx <= list_left + list_w &&
        my >= list_top  && my <= list_top  + list_h) {

        var idx = floor((my - list_top) / row_h);
        var len = array_length(inbox); // array_length_1d(inbox)
        if (idx >= 0 && idx < len) {
            selected_index = idx;
            inbox[idx].read = true;

            // suspicious email -> unlock Messenger (STRUCT access with dot)
            if (inbox[idx].is_suspicious) {
                if (!is_undefined(global.apps_unlocked)) {
                    // struct access:
                    if (is_struct(global.apps_unlocked)) {
                        global.apps_unlocked.Messenger = true;
                    }
                    // if switch to a ds_map, use:
                    // else if (ds_exists(global.apps_unlocked, ds_type_map)) {
                    //     global.apps_unlocked[? "Messenger"] = true;
                    // }
                }
            }
        }
    }
}
// Message view → back
else {
    if (mouse_check_button_pressed(mb_left)) {
        if (point_in_rect(mx, my, back_btn[0], back_btn[1], back_btn[2], back_btn[3])) {
            selected_index = -1;
        }
    }
}