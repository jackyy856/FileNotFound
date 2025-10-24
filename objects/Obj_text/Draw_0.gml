// Draw text box background
draw_set_color(c_white);
draw_rectangle(x, y, x + width, y + height, false);
draw_set_color(c_black);
draw_rectangle(x, y, x + width, y + height, true);

// Draw text or placeholder - LEFT ALIGNED
var display_text = text;
if (text == "" && placeholder != "") {
    draw_set_color(c_gray);
    display_text = placeholder;
} else {
    draw_set_color(c_black);
}

// LEFT ALIGN with vertical centering
var text_x = x + 10; // 10px padding from left
var text_y = y + (height / 2) - (string_height(display_text) / 2);

draw_text(text_x, text_y, display_text);