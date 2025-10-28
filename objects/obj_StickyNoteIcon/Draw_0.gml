draw_self();

// Fallback if Create hasn't run yet
if (!variable_instance_exists(id, "app_key")) app_key = "Note";

// Default to unlocked if the global struct isn't there
var unlocked = true;
if (variable_global_exists("apps_unlocked")) {
    if (is_struct(global.apps_unlocked) && variable_struct_exists(global.apps_unlocked, app_key)) {
        unlocked = variable_struct_get(global.apps_unlocked, app_key);
    }
}

if (!unlocked) {
    // Dim overlay + LOCKED label; won’t crash even without a sprite
    draw_set_alpha(0.55);
    draw_set_color(c_black);
    draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, false);
    draw_set_alpha(1);

    draw_set_color(c_white);
    draw_text(x - 24, y + sprite_get_bbox_bottom(sprite_index)/2 - 8, "LOCKED");
}
