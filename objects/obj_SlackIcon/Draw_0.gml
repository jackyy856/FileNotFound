/// Draw Slack icon and LOCKED overlay if needed

draw_self();

var locked = !(variable_struct_exists(global.apps_unlocked, app_key)
            &&  variable_struct_get(global.apps_unlocked, app_key));

if (locked)
{
    draw_set_alpha(0.55);
    draw_set_color(c_black);
    draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, false);
    draw_set_alpha(1);

    draw_set_color(c_white);
    draw_text(x - 24, y + sprite_get_bbox_bottom(sprite_index)/2 - 8, "LOCKED");
}
