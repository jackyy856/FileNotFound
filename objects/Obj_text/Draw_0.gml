// Draw rounded text box background
var corner_radius = 8;

// Shadow effect
draw_set_color(make_color_rgb(180, 180, 180));
draw_roundrect(x + 1, y + 1, x + width + 1, y + height + 1, corner_radius);

// Main box - change color when active
if (active) {
    draw_set_color(make_color_rgb(240, 240, 255)); // Light blue when active
} else {
    draw_set_color(c_white);
}
draw_roundrect(x, y, x + width, y + height, corner_radius);

// Border - thicker when active
if (active) {
    draw_set_color(make_color_rgb(100, 100, 255)); // Blue border when active
    draw_roundrect(x - 1, y - 1, x + width + 1, y + height + 1, corner_radius + 1);
} else {
    draw_set_color(make_color_rgb(150, 150, 150)); // Gray border when inactive
    draw_roundrect(x, y, x + width, y + height, corner_radius);
}

// Draw text or placeholder - LEFT ALIGNED
var display_text = text;
if (text == "" && placeholder != "") {
    draw_set_color(make_color_rgb(150, 150, 150)); // Light gray for placeholder
    display_text = placeholder;
} else {
    draw_set_color(c_white);
    
    // Convert to asterisks if password field
    if (is_password && text != "") {
        display_text = "";
        for (var i = 0; i < string_length(text); i++) {
            display_text += "*";
        }
    }
}

// LEFT ALIGN with vertical centering
var text_x = x + 10; // 10px padding from left
var text_y = y + (height / 2);

// Calculate text width for cursor positioning
var text_width = string_width(display_text);
var char_widths = array_create(string_length(display_text));

// Get individual character widths for accurate cursor positioning
for (var i = 0; i < string_length(display_text); i++) {
    char_widths[i] = string_width(string_char_at(display_text, i + 1));
}

// Draw the text
draw_set_halign(fa_left);
draw_set_valign(fa_middle);
draw_text(text_x, text_y, display_text);

// Draw cursor when active
if (active && cursor_visible) {
    var cursor_x = text_x;
    
    // Calculate cursor position based on character widths
    if (cursor_position > 0) {
        for (var i = 0; i < min(cursor_position, array_length(char_widths)); i++) {
            cursor_x += char_widths[i];
        }
    }
    
    // Draw cursor line
    draw_set_color(c_white);
    draw_line(cursor_x, y + 5, cursor_x, y + height - 5);
}

// Reset alignment
draw_set_halign(fa_left);
draw_set_valign(fa_top);