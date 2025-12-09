/// Open or focus the Slack app window when this icon is clicked

// If still locked, ignore click
if (!global.apps_unlocked.Slack) {
    // optional later: locked sound / tooltip
    exit;
}

// Respect global click gate (same pattern as other icons)
if (variable_global_exists("_ui_click_consumed") && global._ui_click_consumed) {
    exit;
}

// Is this app unlocked?
var exists   = variable_struct_exists(global.apps_unlocked, app_key);
var unlocked = exists ? variable_struct_get(global.apps_unlocked, app_key) : false;

if (!unlocked) {
    show_debug_message(app_key + " locked");
    exit;
}

// Create a window if none exists, otherwise bring it to front
if (!instance_exists(app_obj)) {
    var inst = instance_create_layer(0, 0, "Instances", app_obj);
    with (inst) {
        // set a sensible default spawn position
        window_x = 420;
        window_y = 140;
        _recalc_layout();

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

// Consume the click so it doesn’t fall through
if (variable_global_exists("_ui_click_consumed")) {
    global._ui_click_consumed = true;
}
