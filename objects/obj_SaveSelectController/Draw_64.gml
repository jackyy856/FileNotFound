// panel
draw_set_alpha(0.15); draw_set_color(c_black);
draw_roundrect(panel_x+6, panel_y+6, panel_x+panel_w+6, panel_y+panel_h+6, false);
draw_set_alpha(1);

draw_set_color(make_color_rgb(28,32,38));
draw_roundrect(panel_x, panel_y, panel_x+panel_w, panel_y+panel_h, false);

draw_set_color(c_white);
draw_text(panel_x + 24, panel_y + 24, "Load Game");

// slots
var n = array_length(slots);
for (var i = 0; i < n; i++) {
    var s = slots[i];
    var over = _hit(s, device_mouse_x_to_gui(0), device_mouse_y_to_gui(0));
    draw_set_color(over ? make_color_rgb(80,170,120) : make_color_rgb(230,230,230));
    draw_roundrect(s.x, s.y, s.x+s.w, s.y+s.h, false);

    // art placeholder box
    draw_set_color(make_color_rgb(210,210,210));
    draw_roundrect(s.x+16, s.y+16, s.x+s.w-16, s.y+120, false);
    draw_set_color(c_black);
    draw_text(s.x + 24, s.y + 24, "(art)");

    draw_text(s.x + 24, s.y + 140, "Save Slot " + string(s.idx));
    draw_set_color(make_color_rgb(120,120,120));
    draw_text(s.x + 24, s.y + 164, "Empty");
    draw_set_color(c_black);
}

// back
var b = back_btn;
draw_set_color(make_color_rgb(230,230,230));
draw_roundrect(b.x, b.y, b.x+b.w, b.y+b.h, false);
draw_set_color(c_black);
draw_text(b.x + 16, b.y + 10, b.label);
