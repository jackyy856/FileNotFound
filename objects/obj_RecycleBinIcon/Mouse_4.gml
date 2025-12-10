/// obj_RecycleBinIcon - Mouse Left Pressed

// If Recycle Bin isn't unlocked globally, play meow & bail
if (!global.apps_unlocked.RecycleBin) {
    audio_play_sound(sfx_meow2, 1, .25);
    exit;
}

// If some app window already consumed this click, don't open
if (variable_global_exists("_ui_click_consumed") && global._ui_click_consumed) {
    global._ui_click_consumed = false;
    exit;
}

// Locked check using the shared apps_unlocked struct and app_key
// (app_key is set in this icon's Create event to "RecycleBin")
var exists   = variable_struct_exists(global.apps_unlocked, app_key);
var unlocked = exists ? variable_struct_get(global.apps_unlocked, app_key) : false;

if (!unlocked) {
    show_debug_message(app_key + " locked");
    exit;
}

// Open or focus the Recycle Bin app window
if (!instance_exists(app_obj)) {
    // app_obj is set in Create to obj_RecycleBinApp
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
    }
}
