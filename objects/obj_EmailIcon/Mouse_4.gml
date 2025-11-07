// Block if a window already claimed this click (no click-through)
if (variable_global_exists("_ui_click_consumed") && global._ui_click_consumed) {
    global._ui_click_consumed = false;
    exit;
}

// open email app
var exists   = variable_struct_exists(global.apps_unlocked, app_key);
var unlocked = exists ? variable_struct_get(global.apps_unlocked, app_key) : false;

if (!unlocked) {
    show_debug_message(app_key + " locked");
    exit;
}

if (!instance_exists(app_obj)) {
    instance_create_layer(0, 0, "Instances", app_obj);
} else {
    with (app_obj) window_focus = true;
}
