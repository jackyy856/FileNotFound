// Handle mouse click
if (mouse_check_button_pressed(mb_left)) {
    if (mouse_x >= x && mouse_x <= x + width && mouse_y >= y && mouse_y <= y + height) {
        active = true;
        keyboard_string = ""; // Clear buffer when focused
    } else {
        active = false;
    }
}

// Handle keyboard when active
if (active) {
    // Use keyboard_string but limit to one character per frame
    var new_text = keyboard_string;
    if (new_text != "") {
        // Only add the first character and clear the rest
        if (string_length(text) < max_length) {
            text += string_char_at(new_text, 1);
        }
        keyboard_string = ""; // Clear the entire buffer
    }
    
    // Handle backspace separately
    if (keyboard_check_pressed(vk_backspace)) {
        if (string_length(text) > 0) {
            text = string_copy(text, 1, string_length(text) - 1);
        }
    }
}