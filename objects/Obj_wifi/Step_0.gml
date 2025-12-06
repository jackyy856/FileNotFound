// --- Timers & clock ---------------------------------------------------------

// Update time every second
if (current_time - last_time_update >= update_interval) {
    update_time_date();
    last_time_update = current_time;
}

// Update incorrect message timer
if (incorrect_timer > 0) {
    incorrect_timer--;
}

// --- Layout follow -----------------------------------------------------------

// Update flyout position when visible
if (wifi_flyout_visible) {
    wifi_flyout_x = wifi_btn_x - wifi_flyout_width;
    wifi_flyout_y = taskbar_y - wifi_flyout_height;
}

// --- Safety: don't interfere with global input when pause menu is active ----
var pause_menu_active = instance_exists(obj_EscapeMenu) && obj_EscapeMenu.active;

// --- Text input (Wi-Fi password field) --------------------------------------
// Handle keyboard input for text field - SINGLE CHARACTER AT A TIME
if (!pause_menu_active && input_field_visible && input_field_has_focus) {

    // Use keyboard_string but limit to one character per frame
    var new_text = keyboard_string;
    if (new_text != "") {
        if (string_length(input_text) < input_max_length) {
            input_text += string_char_at(new_text, 1);
        }
        // Clear the entire buffer so we don't keep appending old buffered chars
        keyboard_string = "";
    }

    // Handle backspace separately
    if (keyboard_check_pressed(vk_backspace)) {
        if (string_length(input_text) > 0) {
            input_text = string_copy(input_text, 1, string_length(input_text) - 1);
        }
    }

    // Enter key submits
    if (keyboard_check_pressed(vk_enter)) {
        handle_password_submission();
    }

    var last = keyboard_lastkey;
    if (last != 0 && last != vk_escape) {
        keyboard_clear(last);
    }
}


if (connection_message_timer > 0) {
    connection_message_timer--;
    if (connection_message_timer <= 0) {
        connection_success = false;
   
    }
}

// --- Hacker sequence trigger -------------------------------------------------
if (selected_network != -1 && networks[selected_network] == "Myers0923") {
    var both_selected = selected_passwords[0] && selected_passwords[1];
    if (both_selected && !hacker_sequence_triggered) {
        trigger_hacker_sequence();
    }
}
