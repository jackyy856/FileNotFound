/// obj_BlackNarrationBase: Draw GUI
draw_clear(c_black);
draw_set_color(c_white);
draw_set_halign(fa_center); draw_set_valign(fa_middle);
// centered wrapped typewriter text
draw_text_ext(gui_w * 0.5, y_text, typed, 24, wrap_w);

if (_ready_for_click) {
    draw_text(gui_w * 0.5, y_text + 56, "[ click ]");
}
