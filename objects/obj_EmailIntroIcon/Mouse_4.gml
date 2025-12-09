/// obj_EmailIntroIcon — Left Pressed
// Spawn or open the intro email app on click.

// Try to find a sensible layer
var lyr = "Instances";
if (!layer_exists(lyr)) {
    lyr = layer_get_name(layer_get_id(0));
}

var inst = noone;
if (instance_exists(obj_EmailIntro)) {
    inst = instance_find(obj_EmailIntro, 0);
} else {
    inst = instance_create_layer(room_width * 0.5, room_height * 0.5, lyr, obj_EmailIntro);
}

if (inst != noone) {
    // Call open_app if present
    if (!is_undefined(inst.open_app)) {
        with (inst) open_app();
    } else {
        with (inst) { app_visible = true; is_minimized = false; }
    }
}

