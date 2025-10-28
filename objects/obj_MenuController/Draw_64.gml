draw_set_halign(fa_left); 
draw_set_valign(fa_top);

// narration fills full window (works for narr1 and narr2)
if (state == "narr1" || state == "narr2") {
    var gw = display_get_gui_width(), gh = display_get_gui_height();
    draw_set_color(c_black); draw_rectangle(0,0,gw,gh,false);

    var full  = lines[line_index];
    var shown = string_copy(full, 1, floor(visible_chars));

    var tw = string_width_ext(full, 12, max_w);
    var th = string_height_ext(full, 12, max_w);
    var x_left = (gw - tw) * 0.5;
    var y_top  = (gh - th) * 0.5;

    draw_set_alpha(0.15); draw_set_color(c_black);
    draw_roundrect(x_left-18, y_top-18, x_left+tw+18, y_top+th+18, false);
    draw_set_alpha(1);

    draw_set_color(c_white);
    draw_text_ext(x_left, y_top, shown, 12, max_w);

    if (done_line) {
        draw_set_alpha(0.6);
        draw_set_halign(fa_center); draw_set_valign(fa_middle);
        draw_text(gw*0.5, y_top + th + 32, "[ click ]");
        draw_set_alpha(1);
        draw_set_halign(fa_left); draw_set_valign(fa_top);
    }
    exit;
}

// full-window panel
var gw = display_get_gui_width(), gh = display_get_gui_height();
draw_set_alpha(0.15); draw_set_color(c_black);
draw_roundrect(8, 8, gw+8, gh+8, false);
draw_set_alpha(1);
draw_set_color(make_color_rgb(28,32,38));
draw_roundrect(0, 0, gw, gh, false);
draw_set_color(c_white);

switch (state) {

case "main":
    draw_text(32, 32, "Main Menu");
    for (var i = 0; i < array_length(buttons); i++) {
        var b = buttons[i];
        var over = ((device_mouse_x_to_gui(0)>=b.x)&&(device_mouse_y_to_gui(0)>=b.y)
                 && (device_mouse_x_to_gui(0)<b.x+b.w)&&(device_mouse_y_to_gui(0)<b.y+b.h));
        draw_set_color(over ? make_color_rgb(80,170,120) : make_color_rgb(230,230,230));
        draw_roundrect(b.x, b.y, b.x+b.w, b.y+b.h, false);
        draw_set_color(over ? c_white : c_black);
        draw_text(b.x + 22, b.y + 20, b.label);
    }
break;

case "load":
    draw_text(32, 32, "Load Game");
    for (var s = 0; s < array_length(slots); s++) {
        var sl = slots[s];
        var over = ((device_mouse_x_to_gui(0)>=sl.x)&&(device_mouse_y_to_gui(0)>=sl.y)
                 && (device_mouse_x_to_gui(0)<sl.x+sl.w)&&(device_mouse_y_to_gui(0)<sl.y+sl.h));
        draw_set_color(over ? make_color_rgb(80,170,120) : make_color_rgb(230,230,230));
        draw_roundrect(sl.x, sl.y, sl.x+sl.w, sl.y+sl.h, false);

        draw_set_color(make_color_rgb(210,210,210));
        draw_roundrect(sl.x+22, sl.y+22, sl.x+sl.w-22, sl.y+138, false);
        draw_set_color(c_black);
        draw_text(sl.x + 30, sl.y + 30, "(art)");
        draw_text(sl.x + 30, sl.y + 154, "Save Slot " + string(sl.idx));
        draw_set_color(make_color_rgb(120,120,120));
        draw_text(sl.x + 30, sl.y + 182, "Empty");
    }
    var b = back_btn;
    draw_set_color(make_color_rgb(230,230,230));
    draw_roundrect(b.x, b.y, b.x+b.w, b.y+b.h, false);
    draw_set_color(c_black);
    draw_text(b.x + 18, b.y + 12, b.label);
break;

case "settings":
    draw_text(32, 32, "Settings");
    draw_text(slider.x, slider.y - 48, "Master Volume: " + string(slider_val));

    draw_set_color(make_color_rgb(210,210,210));
    draw_rectangle(slider.x, slider.y, slider.x + slider.w, slider.y + slider.h, false);

    var knob_x = slider.x + (slider_val/100) * slider.w - slider.knob_w*0.5;
    draw_set_color(make_color_rgb(80,170,120));
    draw_roundrect(knob_x, slider.y - 10, knob_x + slider.knob_w, slider.y + slider.h + 10, false);

    var bb = back_btn;
    draw_set_color(make_color_rgb(230,230,230));
    draw_roundrect(bb.x, bb.y, bb.x+bb.w, bb.y+bb.h, false);
    draw_set_color(c_black);
    draw_text(bb.x + 18, bb.y + 12, b.label);
break;
}
