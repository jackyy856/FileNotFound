// Update time every second
if (current_time - last_time_update >= update_interval) {
    update_time_date();
    last_time_update = current_time;
}

// Update incorrect message timer
if (incorrect_timer > 0) {
    incorrect_timer--;
}

// Update flyout position when visible
if (wifi_flyout_visible) {
    wifi_flyout_x = wifi_btn_x - wifi_flyout_width;
    wifi_flyout_y = taskbar_y - wifi_flyout_height;
}

// Handle keyboard input for text field - SINGLE CHARACTER AT A TIME
if (input_field_visible && input_field_has_focus) {
    // Use keyboard_string but limit to one character per frame
    var new_text = keyboard_string;
    if (new_text != "") {
        // Only add the first character and clear the rest
        if (string_length(input_text) < input_max_length) {
            input_text += string_char_at(new_text, 1);
        }
        keyboard_string = ""; // Clear the entire buffer
    }
    
    // Handle backspace separately
    if (keyboard_check_pressed(vk_backspace)) {
        if (string_length(input_text) > 0) {
            input_text = string_copy(input_text, 1, string_length(input_text) - 1);
        }
    }
    
    // Enter key
    if (keyboard_check_pressed(vk_enter)) {
        handle_password_submission();
    }
    
    // Also clear any other keyboard state to prevent repetition
    keyboard_clear(keyboard_lastkey);
}

// Check if both passwords selected for hacker sequence
if (selected_network != -1 && networks[selected_network] == "Myers0923") {
    var both_selected = selected_passwords[0] && selected_passwords[1];
    if (both_selected && !hacker_sequence_triggered) {
        trigger_hacker_sequence();
    }
}