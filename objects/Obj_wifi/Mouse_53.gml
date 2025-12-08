var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

//Back to Menu
if(point_in_rectangle(mx, my, 40, taskbar_y, 600 + system_btn_size, taskbar_y +system_btn_size ))
{
	room_goto(room_Menu);
}

//!!!!!!!!!!!!!!!vvvvvvvvvvvvvvvv REMOVE vvvvvvvvvvvvvvvv!!!!!!!!!!!!!!!!
// Check WiFi button click (hitbox moved up)
var wifi_hit_y = wifi_btn_y - wifi_hit_offset_y;
if (point_in_rectangle(mx, my,
    wifi_btn_x, wifi_hit_y,
    wifi_btn_x + system_btn_size, wifi_hit_y + system_btn_size))
{
    wifi_flyout_visible = !wifi_flyout_visible;
    show_debug_message("WiFi flyout toggled: " + string(wifi_flyout_visible));
    
    // Reset when opening flyout
    if (wifi_flyout_visible) {
        selected_network = -1;
        input_field_visible = false;
        password_dropdown_visible = false;
        selected_passwords = [false, false];
        hacker_sequence_triggered = false;
    }
}
//!!!!!!!!!!!!!!!^^^^^^^^^^^^^^^^ REMOVE ^^^^^^^^^^^^^^^^^^!!!!!!!!!!!!!!!!

/*!!!!!!!!!!!!!!!vvvvvvvvvvvvvvvv ADD BACK vvvvvvvvvvvvvvvv!!!!!!!!!!!!!!!!
// Check WiFi button click
if (point_in_rectangle(mx, my, wifi_btn_x, wifi_btn_y, wifi_btn_x + system_btn_size, wifi_btn_y + system_btn_size)) {
    wifi_flyout_visible = !wifi_flyout_visible;
    show_debug_message("WiFi flyout toggled: " + string(wifi_flyout_visible));
    
    // Reset when opening flyout
    if (wifi_flyout_visible) {
        selected_network = -1;
        input_field_visible = false;
        password_dropdown_visible = false;
        selected_passwords = [false, false];
        hacker_sequence_triggered = false;
    }
}

*///!!!!!!!!!!!!!!!^^^^^^^^^^^^^^^^ ADD BACK ^^^^^^^^^^^^^^^^^^!!!!!!!!!!!!!!!!
// Handle clicks in WiFi flyout
if (wifi_flyout_visible) {
    // Check network clicks
    for (var i = 0; i < array_length(network_buttons); i++) {
        if (point_in_rectangle(mx, my, network_buttons[i][0], network_buttons[i][1], network_buttons[i][2], network_buttons[i][3])) {
            handle_network_click(i);
            break;
        }
    }
    
    // Handle password dropdown for Myers0923
    if (selected_network != -1 && networks[selected_network] == "Myers0923" && input_field_visible) {
        // Check dropdown button click
        if (point_in_rectangle(mx, my, dropdown_button_bounds[0], dropdown_button_bounds[1], dropdown_button_bounds[2], dropdown_button_bounds[3])) {
            password_dropdown_visible = !password_dropdown_visible;
            show_debug_message("Password dropdown toggled: " + string(password_dropdown_visible));
        }
        
        // Check password option clicks when dropdown is open
        if (password_dropdown_visible) {
            for (var j = 0; j < array_length(password_options); j++) {
                if (j < array_length(password_option_bounds)) {
                    if (point_in_rectangle(mx, my, 
                        password_option_bounds[j][0], password_option_bounds[j][1], 
                        password_option_bounds[j][2], password_option_bounds[j][3])) {
                        
                        // Toggle selection AND auto-fill text field
                        selected_passwords[j] = !selected_passwords[j];
                        if (selected_passwords[j]) {
                            input_text = password_options[j];
                        } else {
                            input_text = ""; 
                        }
                        
                        // Deselect other option
                        for (var k = 0; k < array_length(password_options); k++) {
                            if (k != j) {
                                selected_passwords[k] = false;
                            }
                        }
                        
                        show_debug_message("Password option " + password_options[j] + " selected: " + string(selected_passwords[j]));
                        break;
                    }
                }
            }
        }
    }
   //!!!!!!!!!!!!!!!vvvvvvvvvvvvvvvvv REMOVE vvvvvvvvvvvvvvvvvvvvvvvvvvv!!!!!!!!!!!!!!!!
	// Close flyout if clicking outside
var wifi_hit_y = wifi_btn_y - wifi_hit_offset_y;
if (!point_in_rectangle(mx, my,
        wifi_flyout_x, wifi_flyout_y,
        wifi_flyout_x + wifi_flyout_width, wifi_flyout_y + wifi_flyout_height) &&
    !point_in_rectangle(mx, my,
        wifi_btn_x, wifi_hit_y,
        wifi_btn_x + system_btn_size, wifi_hit_y + system_btn_size))
{
    wifi_flyout_visible = false;
    input_field_visible = false;
    selected_network = -1;
    password_dropdown_visible = false;
    selected_passwords = [false, false];
    hacker_sequence_triggered = false;
}
//!!!!!!!!!!!!!!!^^^^^^^^^^^^^^^^ REMOVE ^^^^^^^^^^^^^^^^^^!!!!!!!!!!!!!!!!

/*//!!!!!!!!!!!!!!!vvvvvvvvvvvvvvvvvvv ADD BACK vvvvvvvvvvvvvvvvvvvvvvvv!!!!!!!!!!!!!!!!
    // Close flyout if clicking outside
    if (!point_in_rectangle(mx, my, wifi_flyout_x, wifi_flyout_y, wifi_flyout_x + wifi_flyout_width, wifi_flyout_y + wifi_flyout_height) &&
        !point_in_rectangle(mx, my, wifi_btn_x, wifi_btn_y, wifi_btn_x + system_btn_size, wifi_btn_y + system_btn_size)) {
        wifi_flyout_visible = false;
        input_field_visible = false;
        selected_network = -1;
        password_dropdown_visible = false;
        selected_passwords = [false, false];
        hacker_sequence_triggered = false;
    }
	*///!!!!!!!!!!!!!!!^^^^^^^^^^^^^^^^ ADD BACK ^^^^^^^^^^^^^^^^^^!!!!!!!!!!!!!!!!
}