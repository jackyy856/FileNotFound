//open email app

//>>gate check
var exists   = variable_struct_exists(global.apps_unlocked, app_key);
var unlocked = exists ? variable_struct_get(global.apps_unlocked, app_key) : false;

if (!unlocked) 
{
    // Locked feedback — swap for your toast if you have one
    show_debug_message(app_key + " locked");
    exit;
}

// Open or focus the app window
if (!instance_exists(app_obj)) 
{
    instance_create_layer(0, 0, "Instances", app_obj);
} 
else 
{
    with (app_obj) window_focus = true; // optional focus behavior
}
