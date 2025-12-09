// obj_CalendarIcon - Mouse Left Pressed

if (!global.apps_unlocked.Calendar) {
    // optional: play locked sound
    exit;
}

// open calendar app
var inst = instance_find(obj_CalendarApp, 0);
if (!instance_exists(inst)) {
    instance_create_layer(x, y, "Instances", obj_CalendarApp);
} else {
    inst.is_minimized = false;
    
}
