/// obj_GalleryIcon - Mouse Left Pressed

// If some app window already consumed this click, don't open
if (variable_global_exists("_ui_click_consumed") && global._ui_click_consumed) {
    global._ui_click_consumed = false;
    exit;
}

// Locked check
var exists   = variable_struct_exists(global.apps_unlocked, app_key);
var unlocked = exists ? variable_struct_get(global.apps_unlocked, app_key) : false;

if (!unlocked) {
    show_debug_message(app_key + " locked");
    exit;
}

// Open or focus app
if (!instance_exists(app_obj)) {
    var inst = instance_create_layer(0, 0, "Instances", app_obj);
    with (inst) {
        if (!variable_global_exists("window_z_next")) global.window_z_next = -10;
        depth = global.window_z_next;
        global.window_z_next -= 1;
        window_focus = true;
        if (!is_undefined(open_gallery)) open_gallery();
    }
} else {
    with (app_obj) {
        if (!variable_global_exists("window_z_next")) global.window_z_next = depth;
        global.window_z_next -= 1;
        depth = global.window_z_next;
        window_focus = true;
        if (!is_undefined(open_gallery)) open_gallery();
    }
}
