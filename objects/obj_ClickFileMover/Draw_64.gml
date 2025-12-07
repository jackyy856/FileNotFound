/// obj_ClickFileMover - Draw GUI

// Convert room coordinates (x,y) to GUI coordinates
var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();

var sx = gui_w / room_width;
var sy = gui_h / room_height;

var gx = x * sx;
var gy = y * sy;

// If you assigned a sprite, draw that. Otherwise draw a placeholder box.
if (sprite_index != -1 && sprite_index != noone) {
    draw_sprite_ext(sprite_index, image_index, gx, gy, sx, sy, image_angle, c_white, image_alpha);
} else {
    var w = 64;
    var h = 80;

    draw_set_color(c_white);
    draw_rectangle(gx - w * 0.5, gy - h * 0.5, gx + w * 0.5, gy + h * 0.5, false);

    draw_set_color(c_dkgray);
    draw_rectangle(gx - w * 0.5, gy - h * 0.5, gx + w * 0.5, gy + h * 0.5, true);

    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(gx, gy, "FILE");
}
