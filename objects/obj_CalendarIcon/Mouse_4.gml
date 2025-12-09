/// obj_CalendarIcon - Mouse Left Pressed

// Block interaction when locked
if (!global.apps_unlocked.Calendar) {
    // optional: audio_play_sound(sfx_locked, 1, 0);
    exit;
}

// Open or focus the Calendar app
var inst = instance_find(obj_CalendarApp, 0);

if (!instance_exists(inst)) {
    // create on the same layer you use for other app windows (often "Instances")
    inst = instance_create_layer(x, y, "Instances", obj_CalendarApp);
} 

// ensure it is visible and not minimized
inst.visible     = true;
if (variable_instance_exists(inst, "is_minimized")) {
    inst.is_minimized = false;
}

// if you use global.window_z_next for z-order, bump it
if (variable_global_exists("window_z_next")) {
    inst.depth = global.window_z_next;
    global.window_z_next -= 1;
}
