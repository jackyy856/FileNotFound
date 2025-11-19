// Block if mouse is currently over any app window (prevent click-through)
over_window = false;

// Email window
with (obj_EmailApp) {
    if (!is_minimized) {
        var mx = device_mouse_x_to_gui(0);
        var my = device_mouse_y_to_gui(0);
        if (mx >= window_x && my >= window_y &&
            mx < window_x + window_w && my < window_y + window_h) {
            other.over_window = true;
        }
    }
}

// Files window
with (obj_FilesApp) {
    if (!is_minimized) {
        var mx = device_mouse_x_to_gui(0);
        var my = device_mouse_y_to_gui(0);
        if (mx >= window_x && my >= window_y &&
            mx < window_x + window_w && my < window_y + window_h) {
            other.over_window = true;
        }
    }
}

// Gallery window
with (obj_GalleryApp) {
    if (!is_minimized) {
        var mx = device_mouse_x_to_gui(0);
        var my = device_mouse_y_to_gui(0);
        if (mx >= window_x && my >= window_y &&
            mx < window_x + window_w && my < window_y + window_h) {
            other.over_window = true;
        }
    }
}

// Sticky Notes window
with (obj_StickyNoteApp) {
    if (!is_minimized) {
        var mx = device_mouse_x_to_gui(0);
        var my = device_mouse_y_to_gui(0);
        var _x2 = x1 + w;
        var _y2 = y1 + h;
        if (mx >= x1 && my >= y1 &&
            mx < _x2 && my < _y2) {
            other.over_window = true;
        }
    }
}

// Hacker Messenger window
with (obj_HackerMsgrApp) {
    if (!minimized) {
        var mx = device_mouse_x_to_gui(0);
        var my = device_mouse_y_to_gui(0);
        var _hx2 = win_x + win_w;
        var _hy2 = win_y + win_h_full;
        if (mx >= win_x && my >= win_y &&
            mx < _hx2 && my < _hy2) {
            other.over_window = true;
        }
    }
}

if (over_window) {
    exit;
}

if (variable_global_exists("_ui_click_consumed") && global._ui_click_consumed) {
    global._ui_click_consumed = false;
    exit;
}

var exists   = variable_struct_exists(global.apps_unlocked, app_key);
var unlocked = exists ? variable_struct_get(global.apps_unlocked, app_key) : false;

if (!unlocked) {
    show_debug_message(app_key + " locked");
    exit;
}

if (!instance_exists(app_obj)) {
    var inst = instance_create_layer(0, 0, "Instances", app_obj);
    with (inst) {
        if (!variable_global_exists("window_z_next")) global.window_z_next = -10;
        depth = global.window_z_next;
        global.window_z_next -= 1;
        window_focus = true;
    }
} else {
    with (app_obj) {
        if (!variable_global_exists("window_z_next")) global.window_z_next = depth;
        global.window_z_next -= 1;
        depth = global.window_z_next;
        window_focus = true;
        if (is_undefined(open_gallery)) {} else open_gallery();
    }
}
