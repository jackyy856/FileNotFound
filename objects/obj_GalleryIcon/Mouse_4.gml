//open gallery app

// Respect a click already claimed by a window this frame
if (!variable_global_exists("_ui_click_consumed")) global._ui_click_consumed = false;
if (global._ui_click_consumed) exit;

var exists   = variable_struct_exists(global.apps_unlocked, app_key);
var unlocked = exists ? variable_struct_get(global.apps_unlocked, app_key) : false;

if (!unlocked) {
    show_debug_message(app_key + " locked");
    exit;
}

if (!instance_exists(app_obj)) {
    instance_create_layer(0, 0, "Instances", app_obj);
} else {
    with (app_obj) {
        window_focus = true;
        if (is_undefined(open_gallery) == false) open_gallery(); // keep your behavior
    }
}

global._ui_click_consumed = true;
mouse_clear(mb_left);
