// Handle mouse click
if (mouse_check_button_pressed(mb_left)) {
    if (mouse_x >= x && mouse_x <= x + width && mouse_y >= y && mouse_y <= y + height) {
        active = true;
        keyboard_string = ""; // Clear buffer when focused
        cursor_position = string_length(text); // Set cursor to end
    } else {
        active = false;
    }
}

// Handle keyboard when active
if (active) {
    // Update cursor blink
    cursor_timer++;
    if (cursor_timer >= cursor_blink_speed) {
        cursor_visible = !cursor_visible;
        cursor_timer = 0;
    }
    
    // Use keyboard_string but limit to one character per frame
    var new_text = keyboard_string;
    if (new_text != "") {
        // Only add the first character and clear the rest
        if (string_length(text) < max_length) {
            // Insert at cursor position
            var before_cursor = string_copy(text, 1, cursor_position);
            var after_cursor = string_copy(text, cursor_position + 1, string_length(text) - cursor_position);
            text = before_cursor + string_char_at(new_text, 1) + after_cursor;
            cursor_position++; // Move cursor forward
        }
        keyboard_string = ""; // Clear the entire buffer
    }
    
    // Handle backspace
    if (keyboard_check_pressed(vk_backspace)) {
        if (string_length(text) > 0 && cursor_position > 0) {
            var before_cursor = string_copy(text, 1, cursor_position - 1);
            var after_cursor = string_copy(text, cursor_position + 1, string_length(text) - cursor_position);
            text = before_cursor + after_cursor;
            cursor_position--; // Move cursor back
        }
    }
    
    // Handle delete key
    if (keyboard_check_pressed(vk_delete)) {
        if (string_length(text) > 0 && cursor_position < string_length(text)) {
            var before_cursor = string_copy(text, 1, cursor_position);
            var after_cursor = string_copy(text, cursor_position + 2, string_length(text) - cursor_position - 1);
            text = before_cursor + after_cursor;
        }
    }
    
    // Handle left arrow
    if (keyboard_check_pressed(vk_left)) {
        if (cursor_position > 0) {
            cursor_position--;
        }
    }
    
    // Handle right arrow
    if (keyboard_check_pressed(vk_right)) {
        if (cursor_position < string_length(text)) {
            cursor_position++;
        }
    }
    
    // Handle home key
    if (keyboard_check_pressed(vk_home)) {
        cursor_position = 0;
    }
    
    // Handle end key
    if (keyboard_check_pressed(vk_end)) {
        cursor_position = string_length(text);
    }
} else {
    // Reset cursor when not active
    cursor_visible = true;
    cursor_timer = 0;
}