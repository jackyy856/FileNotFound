if (!global.apps_unlocked.RecycleBin) {
    // optional: play a “locked” sound or brief tooltip later
    exit;
}

// if locked, ignore click
if (!global.apps_unlocked.Files) {
    // optional: play a “locked” sound or brief tooltip later
    exit;
}

var exists   = variable_struct_exists(global.apps_unlocked, app_key);
var unlocked = exists ? variable_struct_get(global.apps_unlocked, app_key) : false;

if (!unlocked) 
{
    // locked feedback 
    show_debug_message(app_key + " locked");
    exit;
}

// open/focus the app window
if (!instance_exists(app_obj)) 
{
    instance_create_layer(0, 0, "Instances", app_obj);
}
else 
{
    with (app_obj) {
        is_minimized = false;  // restore if minimized
        window_focus = true;
    }
}
