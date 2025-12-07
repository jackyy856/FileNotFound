// Draw taskbar background
draw_set_color(c_black);
draw_set_alpha(1);
draw_rectangle(0, taskbar_y, 1920, 1080, false); 
draw_set_alpha(1);

//draw Back to Menu
draw_sprite(BacktoMenu, 0, 40, taskbar_y);

// Draw WiFi icon - Green if connected, white if not
if (connected_network >= 0) {
    draw_set_color(make_color_rgb(0, 255, 0)); // Green when connected
} else {
    draw_set_color(c_white); // White when disconnected
}
var wifi_center_x = wifi_btn_x + system_btn_size/2;
var wifi_center_y = wifi_btn_y + system_btn_size/2;

// Draw WiFi symbol
for (var i = 0; i < 3; i++) {
    var radius = (i + 1) * system_btn_size/3;
    var start_angle = 45;
    var end_angle = 135;
    var segments = 8;
    
    for (var j = 0; j < segments; j++) {
        var angle1 = degtorad(start_angle + (j * (end_angle - start_angle) / segments));
        var angle2 = degtorad(start_angle + ((j + 1) * (end_angle - start_angle) / segments));
        
        var x1 = wifi_center_x + cos(angle1) * radius;
        var y1 = wifi_center_y - sin(angle1) * radius;
        var x2 = wifi_center_x + cos(angle2) * radius;
        var y2 = wifi_center_y - sin(angle2) * radius;
        
        draw_line(x1, y1, x2, y2);
    }
}
draw_circle(wifi_center_x, wifi_center_y, system_btn_size/8, true);

// Draw date/time area
draw_set_color(make_color_rgb(60, 60, 60));
draw_rectangle(date_btn_x - 5, taskbar_y + 2, 1920, taskbar_y + taskbar_height - 2, true);

// Time and date text
draw_set_color(c_white);
draw_set_font(Date);
draw_text(date_btn_x + 13, taskbar_y + 10, display_time);
draw_text(date_btn_x + 9, taskbar_y + 30, display_date);

// Draw WiFi flyout if visible
if (wifi_flyout_visible) {
    // Position flyout above taskbar
    wifi_flyout_x = wifi_btn_x - 280;
    wifi_flyout_y = taskbar_y - wifi_flyout_height;
    
    // Flyout background
    draw_set_color(make_color_rgb(30, 30, 30));
    draw_rectangle(wifi_flyout_x, wifi_flyout_y, wifi_flyout_x + wifi_flyout_width, wifi_flyout_y + wifi_flyout_height, true);
    draw_set_color(make_color_rgb(80, 80, 80));
    draw_rectangle(wifi_flyout_x, wifi_flyout_y, wifi_flyout_x + wifi_flyout_width, wifi_flyout_y + wifi_flyout_height, false);
    
    // Header
    draw_set_color(make_color_rgb(50, 50, 50));
    draw_rectangle(wifi_flyout_x, wifi_flyout_y, wifi_flyout_x + wifi_flyout_width, wifi_flyout_y + 60, true);
    
    // Title and status
    draw_set_color(c_white);
    draw_set_font(-1);
    draw_text(wifi_flyout_x + 20, wifi_flyout_y + 20, "Wi-Fi");
    
    // Status text - Show connection status
    if (connected_network >= 0) {
        draw_set_color(make_color_rgb(150, 255, 150)); // Light green
        draw_text(wifi_flyout_x + 20, wifi_flyout_y + 40, "Connected to: " + networks[connected_network]);
    } else {
        draw_set_color(make_color_rgb(150, 150, 150)); // Gray
        draw_text(wifi_flyout_x + 20, wifi_flyout_y + 40, "Not connected");
    }
    
    // Available Networks section
    var networks_start_y = wifi_flyout_y + 70;
    draw_set_color(c_white);
    draw_text(wifi_flyout_x + 20, networks_start_y, "Available Networks");
    
    // Draw network list and store button positions
    for (var i = 0; i < array_length(networks); i++) {
        var network_y = networks_start_y + 30 + (i * 40);
        
        // Store network button position for click detection
        network_buttons[i] = [wifi_flyout_x + 10, network_y, wifi_flyout_x + wifi_flyout_width - 10, network_y + 35];
        
        // Network item background (highlight selected)
        if (i == selected_network) {
            draw_set_color(make_color_rgb(60, 60, 80));
            draw_rectangle(wifi_flyout_x + 10, network_y, wifi_flyout_x + wifi_flyout_width - 10, network_y + 35, true);
        }
        
        // WiFi icon for network
        draw_small_wifi_icon(wifi_flyout_x + 20, network_y + 17, 16);
        
        // Network name
        draw_set_color(c_white);
        draw_text(wifi_flyout_x + 45, network_y + 10, networks[i]);
    }
    
    // Draw input field ONLY if a network is selected AND input should be visible
    if (selected_network >= 0 && input_field_visible) {
        var input_start_y = networks_start_y + 30 + (array_length(networks) * 40) + 20;
        draw_network_input_field(selected_network, input_start_y);
    }
}


// Helper function for small WiFi icon with 3 curves
function draw_small_wifi_icon(x, y, size) {
    draw_set_color(make_color_rgb(150, 150, 150));
    var center_x = x + size/2;
    var center_y = y + size/2;
    
    // Draw 3 curved arcs for the WiFi symbol
    for (var i = 0; i < 3; i++) {
        var radius = (i + 1) * size/4;
        var start_angle = 45;
        var end_angle = 135;
        var segments = 6;
        
        for (var j = 0; j < segments; j++) {
            var angle1 = degtorad(start_angle + (j * (end_angle - start_angle) / segments));
            var angle2 = degtorad(start_angle + ((j + 1) * (end_angle - start_angle) / segments));
            
            var x1 = center_x + cos(angle1) * radius;
            var y1 = center_y - sin(angle1) * radius;
            var x2 = center_x + cos(angle2) * radius;
            var y2 = center_y - sin(angle2) * radius;
            
            draw_line(x1, y1, x2, y2);
        }
    }
    
    // Draw center dot
    draw_circle(center_x, center_y, size/15, true);
}

// Helper function for network input field 
function draw_network_input_field(network_index, start_y) {
    var base_y = start_y;
    
    // Get the network name safely
    var current_network_name = "";
    if (network_index >= 0 && network_index < array_length(networks)) {
        current_network_name = networks[network_index];
    } else {
        current_network_name = "Unknown";
    }
    
    // Network name header
    draw_set_color(c_white);
    draw_text(wifi_flyout_x + 20, base_y + 5, "Connecting to: " + current_network_name);
    
    // Password section 
    var left_column_x = wifi_flyout_x + 20;
    
    // Password label and input field
    draw_set_color(c_white);
    draw_text(left_column_x, base_y + 35, "Password:");
    
    // Password input field
    var input_field_y = base_y + 55;
    var input_field_width = 180;
    
    // Input field border
    draw_set_color(c_white);
    draw_rectangle(left_column_x, input_field_y, left_column_x + input_field_width, input_field_y + 30, true);
    
    // Input field background (black)
    draw_set_color(c_black);
    draw_rectangle(left_column_x + 1, input_field_y + 1, left_column_x + input_field_width - 1, input_field_y + 29, false);
    
    // Input text - Show both the text AND cursor
    draw_set_color(c_white); 
    
    // Show blinking cursor when active -
    var cursor = "";
    if (input_field_visible && input_field_has_focus) {
        // Use 60 frames (1 second) for slower, more natural blinking
        if ((current_time div 60) mod 2 == 0) {
            cursor = "|";
        }
    }
    
    // Draw the actual input text + cursor
    draw_text(left_column_x + 5, input_field_y + 8, input_text + cursor);
    
    // Character counter
    var counter_x = left_column_x + input_field_width + 5;
    draw_set_color(make_color_rgb(150, 150, 150));
    draw_text(counter_x, input_field_y + 8, string(string_length(input_text)) + "/20");
    
    // For Myers0923 ONLY, show password dropdown
    if (current_network_name == "Myers0923") {
       
        var dropdown_icon_x = counter_x + 50; 
        var dropdown_icon_y = input_field_y;
        var dropdown_icon_size = 30;
        
        // Store dropdown position for click detection
        dropdown_button_bounds = [dropdown_icon_x, dropdown_icon_y, dropdown_icon_x + dropdown_icon_size, dropdown_icon_y + dropdown_icon_size];
        
        // Dropdown icon background
        draw_set_color(c_black); 
        draw_rectangle(dropdown_icon_x, dropdown_icon_y, dropdown_icon_x + dropdown_icon_size, dropdown_icon_y + dropdown_icon_size, false);
        draw_set_color(c_white); // White border
        draw_rectangle(dropdown_icon_x, dropdown_icon_y, dropdown_icon_x + dropdown_icon_size, dropdown_icon_y + dropdown_icon_size, true);

        // Dropdown arrow 
        draw_set_color(c_white);
        var center_x = dropdown_icon_x + dropdown_icon_size/2;
        var center_y = dropdown_icon_y + dropdown_icon_size/2;
        var arrow_size = 6;
        draw_triangle(
            center_x - arrow_size, center_y - arrow_size/2, 
            center_x + arrow_size, center_y - arrow_size/2,  
            center_x, center_y + arrow_size/2,              
            true 
        );
       
        // DROPDOWN OPTIONS WHEN OPEN
        if (password_dropdown_visible) {
            var options_start_x = left_column_x;
            var options_start_y = input_field_y + 40;
            var option_width = 250;
            
            // Dropdown background - Dark background with white border
            draw_set_color(make_color_rgb(40, 40, 40)); // Dark background
            draw_rectangle(options_start_x, options_start_y, options_start_x + option_width, options_start_y + 85, false);
            draw_set_color(c_white); // White border
            draw_rectangle(options_start_x, options_start_y, options_start_x + option_width, options_start_y + 85, true);
            
            // Draw each password option - White text on dark background
            for (var i = 0; i < array_length(password_options); i++) {
                var option_y = options_start_y + 5 + (i * 40);
                
                // Store option bounds for click detection
                if (i < array_length(password_option_bounds)) {
                    password_option_bounds[i] = [options_start_x, option_y, options_start_x + option_width, option_y + 35];
                }
                
                // Highlight selected option
                if (selected_passwords[i]) {
                    draw_set_color(make_color_rgb(60, 60, 100));
                    draw_rectangle(options_start_x + 2, option_y, options_start_x + option_width - 2, option_y + 35, true);
                }
                
                // Checkbox - White checkbox
                draw_set_color(c_white);
                var checkbox_x = options_start_x + 15;
                var checkbox_y = option_y + 12;
                draw_rectangle(checkbox_x, checkbox_y, checkbox_x + 15, checkbox_y + 15, false);
                
                // Draw X mark if selected (easier than checkmark)
                if (selected_passwords[i]) {
                    draw_set_color(c_black);
                    draw_line_width(checkbox_x + 3, checkbox_y + 3,   
                        checkbox_x + 12, checkbox_y + 12,
                        2);
                    draw_line_width(checkbox_x + 12, checkbox_y + 3, 
                        checkbox_x + 3, checkbox_y + 12,
                        2);
                }
                
                // Password option text
                draw_set_color(c_white);
                draw_text(options_start_x + 40, option_y + 10, password_options[i]);
            }
        }
        
        // Instructions for Myers0923 (same as other networks)
        var instructions_y = base_y + 100;
        if (password_dropdown_visible) {
            instructions_y = base_y + 180;
        }
        
        // Instructions for Myers0923
        draw_set_color(make_color_rgb(150, 150, 150));
        draw_text(left_column_x, instructions_y, "Press Enter to check password");
        
        // Show incorrect password message OR success message
        if (incorrect_timer > 0) {
            draw_set_color(c_red);
            draw_text(left_column_x, instructions_y + 30, "Incorrect password");
        } else if (connection_success && connection_message_timer > 0 && selected_network == array_find(networks, "Myers0923")) {
            draw_set_color(make_color_rgb(0, 255, 0)); // Green color
            draw_text(left_column_x, instructions_y + 30, "Connect Successfully");
        }
       
        // Show "click connect" message when both passwords are selected
        if (selected_passwords[0] && selected_passwords[1]) {
            draw_set_color(make_color_rgb(0, 255, 0));
            draw_text(left_column_x, instructions_y + 60, "You are tricked");
        }
    } else {
        // FOR OTHER NETWORKS: No dropdown, only Enter key instructions
        var instructions_y = base_y + 100;
        
        // Instructions for other networks
        draw_set_color(make_color_rgb(150, 150, 150));
        draw_text(left_column_x, instructions_y, "Press Enter to check password");
        
        // Show incorrect password message OR success message for other networks
        if (incorrect_timer > 0) {
            draw_set_color(c_red);
            draw_text(left_column_x, instructions_y + 30, "Incorrect password");
        } else if (connection_success && connection_message_timer > 0 && selected_network >= 0) {
            draw_set_color(make_color_rgb(0, 255, 0)); // Green color
            draw_text(left_column_x, instructions_y + 30, "Connect Successfully");
        }
    }
}