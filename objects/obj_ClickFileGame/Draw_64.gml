/// obj_ClickFileGame - Draw GUI

var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();

// title
draw_set_alpha(1);
draw_set_font(-1);
draw_set_halign(fa_center);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_text(gui_w * 0.5, 24, "Click the real file!");

// bottom hint
draw_set_valign(fa_bottom);
draw_text(gui_w * 0.5, gui_h - 24, "Six files are moving. One is the real one.");

// DEBUG: show how many movers exist
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_text(16, 16, "Files: " + string(instance_number(obj_ClickFileMover)));
