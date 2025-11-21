// Draw taskbar background
draw_set_color(make_color_rgb(40, 40, 40));
draw_set_alpha(0.95);
draw_rectangle(0, taskbar_y, 1920, 1080, true);
draw_set_alpha(1);

// Draw search button
draw_set_color(make_color_rgb(80, 80, 80));
draw_rectangle(search_btn_x, search_btn_y, search_btn_x + search_btn_size, search_btn_y + search_btn_size, true);
draw_set_color(make_color_rgb(120, 120, 120));
draw_rectangle(search_btn_x, search_btn_y, search_btn_x + search_btn_size, search_btn_y + search_btn_size, false);

// Search icon
draw_set_color(c_white);
var center_x = search_btn_x + search_btn_size/2;
var center_y = search_btn_y + search_btn_size/2;
draw_circle(center_x - 2, center_y - 2, search_btn_size/3, false);
var handle_x1 = center_x + 2;
var handle_y1 = center_y + 2;
var handle_x2 = center_x + search_btn_size/3;
var handle_y2 = center_y + search_btn_size/3;
draw_line(handle_x1, handle_y1, handle_x2, handle_y2);

// Draw opened apps
var start_x = search_btn_x + search_btn_size + 20;
for (var i = 0; i < array_length(opened_apps); i++) {
    if (i >= max_visible_apps) break;
    
    var app = opened_apps[i];
    var app_x = start_x + (i * (app_btn_width + 5));
    var app_y = taskbar_y + 7;
    
    // App button background
    draw_set_color(make_color_rgb(60, 60, 60));
    draw_rectangle(app_x, app_y, app_x + app_btn_width, app_y + app_btn_height, true);
    draw_set_color(make_color_rgb(100, 100, 100));
    draw_rectangle(app_x, app_y, app_x + app_btn_width, app_y + app_btn_height, false);
    
    // App name
    draw_set_color(c_white);
    draw_set_font(-1);
    draw_text(app_x + 8, app_y + 15, app);
}

// Draw WiFi icon
draw_set_color(c_white);
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
draw_rectangle(date_btn_x - 10, taskbar_y + 2, 1920, taskbar_y + taskbar_height - 2, true);

// Time and date text
draw_set_color(c_white);
draw_set_font(-1);
draw_text(date_btn_x, taskbar_y + 15, display_time);
draw_text(date_btn_x, taskbar_y + 35, display_date);

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
    draw_set_color(make_color_rgb(150, 150, 150));
    draw_text(wifi_flyout_x + 20, wifi_flyout_y + 40, "Connected, secured");
    
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

// DEBUG: Show click area
draw_set_color(c_red);
draw_set_alpha(0.3);
draw_rectangle(wifi_btn_x, wifi_btn_y, wifi_btn_x + system_btn_size, wifi_btn_y + system_btn_size, true);
draw_set_alpha(1);

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
    draw_rectangle(left_column_x, input_field_y, left_column_x + input_field_width, input_field_y + 30, false);
    
    // Input field background (black)
    draw_set_color(c_black);
    draw_rectangle(left_column_x + 1, input_field_y + 1, left_column_x + input_field_width - 1, input_field_y + 29, true);
    
    // Input text - Show both the text AND cursor
    draw_set_color(c_black); 
    
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
    draw_set_color(make_color_rgb(150, 150, 150));
    draw_text(left_column_x + input_field_width + 5, input_field_y + 8, string(string_length(input_text)) + "/20");
    
    // For Myers0923 ONLY, show password dropdown and Connect button
    if (current_network_name == "Myers0923") {
        var dropdown_icon_x = left_column_x + input_field_width + 10;
        var dropdown_icon_y = input_field_y;
        var dropdown_icon_size = 30;
        
        // Store dropdown position for click detection
        dropdown_button_bounds = [dropdown_icon_x, dropdown_icon_y, dropdown_icon_x + dropdown_icon_size, dropdown_icon_y + dropdown_icon_size];
        
        // Dropdown icon background
        draw_set_color(make_color_rgb(70, 70, 70)); // Gray background
        draw_rectangle(dropdown_icon_x, dropdown_icon_y, dropdown_icon_x + dropdown_icon_size, dropdown_icon_y + dropdown_icon_size, true);
        draw_set_color(c_white); // White border
        draw_rectangle(dropdown_icon_x, dropdown_icon_y, dropdown_icon_x + dropdown_icon_size, dropdown_icon_y + dropdown_icon_size, false);
        
        // Dropdown arrow 
        draw_set_color(c_black);
        draw_text(dropdown_icon_x + 12, dropdown_icon_y + 8, "▼");
       
        // DROPDOWN OPTIONS WHEN OPEN
        if (password_dropdown_visible) {
            var options_start_x = left_column_x;
            var options_start_y = input_field_y + 40;
            var option_width = 250;
            
            // Dropdown background - Dark background with white border
            draw_set_color(make_color_rgb(40, 40, 40)); // Dark background
            draw_rectangle(options_start_x, options_start_y, options_start_x + option_width, options_start_y + 85, true);
            draw_set_color(c_white); // White border
            draw_rectangle(options_start_x, options_start_y, options_start_x + option_width, options_start_y + 85, false);
            
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
                
                // Checkmark if selected - White checkmark
                if (selected_passwords[i]) {
                    draw_set_color(c_white);
                    draw_text(checkbox_x + 3, checkbox_y - 1, "✓");
                }
                
                // Password option text - White text
                draw_set_color(c_black);
                draw_text(options_start_x + 40, option_y + 10, password_options[i]);
            }
        }
        
        // Connect/Cancel buttons 
        var connect_btn_y = base_y + 100;
        if (password_dropdown_visible) {
            connect_btn_y = base_y + 180;
        }
        
        // Store button positions
        connect_btn_bounds = [wifi_flyout_x + 60, connect_btn_y, wifi_flyout_x + 150, connect_btn_y + 35];
        cancel_btn_bounds = [wifi_flyout_x + 170, connect_btn_y, wifi_flyout_x + 260, connect_btn_y + 35];
        
        // Connect button
        draw_set_color(make_color_rgb(0, 120, 215));
        draw_rectangle(connect_btn_bounds[0], connect_btn_bounds[1], connect_btn_bounds[2], connect_btn_bounds[3], true);
        draw_set_color(c_white);
        draw_text(wifi_flyout_x + 84, connect_btn_y + 10, "Connect");
        
        // Cancel button
        draw_set_color(make_color_rgb(80, 80, 80));
        draw_rectangle(cancel_btn_bounds[0], cancel_btn_bounds[1], cancel_btn_bounds[2], cancel_btn_bounds[3], true);
        draw_set_color(c_white);
        draw_text(wifi_flyout_x + 195, connect_btn_y + 10, "Cancel");
        
        // Show "click connect" message when both passwords are selected
        if (selected_passwords[0] && selected_passwords[1]) {
            draw_set_color(make_color_rgb(0, 255, 0));
            draw_text(left_column_x -10, connect_btn_y + 50, "✓ Both passwords analyzed \n  Click Connect");
        }
        
        
		} else {
        // FOR OTHER NETWORKS: No Connect button, only Enter key instructions
        var instructions_y = base_y + 100;
        
        // Instructions for other networks
        draw_set_color(make_color_rgb(150, 150, 150));
        draw_text(left_column_x, instructions_y, "Press Enter to check password");
        
        // Show incorrect password message for other networks
        if (incorrect_timer > 0) {
            draw_set_color(c_red);
            draw_text(left_column_x, instructions_y + 30, "Incorrect password");
        }
    }
}