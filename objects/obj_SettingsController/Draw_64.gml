// SETTINGS — Draw GUI
var card_col = make_color_rgb(28,32,38);
draw_set_color(card_col);
draw_roundrect(220,140,1140,620,false);

draw_set_color(c_white);
draw_text(250,170,"Settings");

draw_text(slider_x, slider_y - 40, "Master Volume: " + string(round(volume*100)));

draw_set_color(make_color_rgb(210,210,210));
draw_rectangle(slider_x, slider_y, slider_x+slider_w, slider_y+slider_h, false);

var kx = slider_x + volume * slider_w;
draw_set_color(make_color_rgb(90,180,140));
draw_circle(kx, slider_y + slider_h/2, knob_r, false);

draw_set_color(make_color_rgb(235,235,235));
draw_roundrect(back_x, back_y, back_x+back_w, back_y+back_h, false);
draw_set_color(make_color_rgb(20,20,20));
draw_text(back_x+16, back_y+12, "<  Back");
