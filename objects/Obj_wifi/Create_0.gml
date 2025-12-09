// Taskbar properties
taskbar_height = 60;
taskbar_y = 1080 - taskbar_height;

// App buttons
max_visible_apps = 8;
app_btn_width = 120;
app_btn_height = 45;
opened_apps = [];

// System icons
wifi_btn_x = 1740;
date_btn_x = 1810;
system_btn_size = 25;
wifi_btn_y = taskbar_y + 25;

// Time and date
display_time = "";
display_date = "";

// WiFi Flyout variables
wifi_flyout_visible = false;
wifi_flyout_x = 0;
wifi_flyout_y = 0;
wifi_flyout_width = 350;
wifi_flyout_height = 600;

// Network list
networks = ["Myers0923", "FORMS-@1774", "Nite", "FredrickWifi"];
selected_network = -1;
network_buttons = [];

// ===== ADD THESE VARIABLES =====
// Connection status
connected_network = -1; // -1 = none, 0+ = connected network index
connection_success = false;
connection_message_timer = 0;
// ===============================

// Password options for Myers0923
password_options = ["password01", "password02"];
selected_passwords = [false, false];
password_dropdown_visible = true;

// Input field
input_field_visible = false;
input_text = "";
input_max_length = 20;
input_field_has_focus = false;

// Message display
incorrect_timer = 0;
incorrect_duration = 150;

// Hacker sequence
hacker_sequence_triggered = false;

// Time tracking
last_time_update = 0;
update_interval = 1000;

// Click detection bounds
dropdown_button_bounds = [0, 0, 0, 0];
password_option_bounds = [];
connect_btn_bounds = [0, 0, 0, 0];
cancel_btn_bounds = [0, 0, 0, 0];

// Initialize network buttons array
for (var i = 0; i < array_length(networks); i++) {
    array_push(network_buttons, [0, 0, 0, 0]);
}

// Initialize password option bounds array
for (var i = 0; i < array_length(password_options); i++) {
    array_push(password_option_bounds, [0, 0, 0, 0]);
}

/// Update time and date
update_time_date = function() {
    var datetime = date_current_datetime();
    var hours = date_get_hour(datetime);
    var minutes = date_get_minute(datetime);
    var am_pm = "AM";
    
    if (hours >= 12) {
        am_pm = "PM";
        if (hours > 12) hours -= 12;
    }
    if (hours == 0) hours = 12;
    
    display_time = string(hours) + ":" + (minutes < 10 ? "0" : "") + string(minutes) + " " + am_pm;
    display_date = string(date_get_month(datetime)) + "/" + string(date_get_day(datetime)) + "/" + string(date_get_year(datetime));
}

// Handle network click
handle_network_click = function(network_index) {
    selected_network = network_index;
    input_field_visible = true;
    input_field_has_focus = true; 
    input_text = "";
    incorrect_timer = 0;
    password_dropdown_visible = true;
    connection_message_timer = 0; // Reset any success message
    
    // Reset password selection when switching networks
    selected_passwords = [false, false];
    hacker_sequence_triggered = false;
    
    show_debug_message("Selected network: " + networks[network_index]);
}

// Handle password submission
handle_password_submission = function() {
    if (selected_network == -1) return;
    
    var network_name = networks[selected_network];
    show_debug_message("Password submitted for: " + network_name);
    show_debug_message("Input text: " + input_text);
    
    if (network_name == "Myers0923") {
        // Special handling for Myers0923 - two password options
        if (selected_passwords[0] && selected_passwords[1]) {
            // Both passwords selected - trigger hacker sequence
            trigger_hacker_sequence();
            return;
        }
        
        // Check correct password for Myers0923
        if (input_text == "collateral85") {
            show_debug_message("*** CORRECT PASSWORD FOR MYERS0923!");
            
            // ===== ADD THIS: Set connection success =====
            connection_success = true;
            connected_network = selected_network;
            connection_message_timer = 180; // Show message for 3 seconds at 60fps
            // ============================================
            
            // Clear input
            input_text = "";
            input_field_visible = false;
            input_field_has_focus = false;
            password_dropdown_visible = false;
            selected_passwords = [false, false];
            
        } else {
            incorrect_timer = incorrect_duration;
            show_debug_message("Incorrect password for Myers0923");
        }
    } else {
        // For other networks, only accept "password123"
        if (input_text == "password123") {
            show_debug_message("*** CORRECT PASSWORD! ACCESS GRANTED ***");
            
           
            connection_success = true;
            connected_network = selected_network;
            connection_message_timer = 180;
            // ============================================
            
            // Clear input
            input_text = "";
            input_field_visible = false;
            input_field_has_focus = false;
            
        } else {
            incorrect_timer = incorrect_duration;
            show_debug_message("Incorrect password");
        }
    }
}

// Trigger hacker sequence
trigger_hacker_sequence = function() {
    hacker_sequence_triggered = true;
    show_debug_message("*** HACKER SEQUENCE TRIGGERED! ***");
    show_debug_message("*** JACKY: Connect next story sequence here ***");
}

// Update time immediately
update_time_date();

function _save_state_blob() {
    return {
        wifi_flyout_visible: wifi_flyout_visible,
        wifi_flyout_x: wifi_flyout_x,
        wifi_flyout_y: wifi_flyout_y,
        selected_network: selected_network,
        connected_network: connected_network,
        connection_success: connection_success,
        connection_message_timer: connection_message_timer,
        selected_passwords: selected_passwords,
        password_dropdown_visible: password_dropdown_visible,
        input_field_visible: input_field_visible,
        input_field_has_focus: input_field_has_focus,
        input_text: input_text,
        opened_apps: opened_apps,
        hacker_sequence_triggered: hacker_sequence_triggered,
        wifi_flyout_width: wifi_flyout_width,
        wifi_flyout_height: wifi_flyout_height,
        wifi_btn_x: wifi_btn_x,
        wifi_btn_y: wifi_btn_y
    };
}

function _apply_state_blob(blob) {
    if (!is_struct(blob)) return;
    if (!is_undefined(blob.wifi_flyout_visible)) wifi_flyout_visible = blob.wifi_flyout_visible;
    if (!is_undefined(blob.wifi_flyout_x)) wifi_flyout_x = blob.wifi_flyout_x;
    if (!is_undefined(blob.wifi_flyout_y)) wifi_flyout_y = blob.wifi_flyout_y;
    if (!is_undefined(blob.selected_network)) selected_network = blob.selected_network;
    if (!is_undefined(blob.connected_network)) connected_network = blob.connected_network;
    if (!is_undefined(blob.connection_success)) connection_success = blob.connection_success;
    if (!is_undefined(blob.connection_message_timer)) connection_message_timer = blob.connection_message_timer;
    if (!is_undefined(blob.selected_passwords)) selected_passwords = blob.selected_passwords;
    if (!is_undefined(blob.password_dropdown_visible)) password_dropdown_visible = blob.password_dropdown_visible;
    if (!is_undefined(blob.input_field_visible)) input_field_visible = blob.input_field_visible;
    if (!is_undefined(blob.input_field_has_focus)) input_field_has_focus = blob.input_field_has_focus;
    if (!is_undefined(blob.input_text)) input_text = blob.input_text;
    if (!is_undefined(blob.opened_apps)) opened_apps = blob.opened_apps;
    if (!is_undefined(blob.hacker_sequence_triggered)) hacker_sequence_triggered = blob.hacker_sequence_triggered;
    if (!is_undefined(blob.wifi_flyout_width)) wifi_flyout_width = blob.wifi_flyout_width;
    if (!is_undefined(blob.wifi_flyout_height)) wifi_flyout_height = blob.wifi_flyout_height;
    if (!is_undefined(blob.wifi_btn_x)) wifi_btn_x = blob.wifi_btn_x;
    if (!is_undefined(blob.wifi_btn_y)) wifi_btn_y = blob.wifi_btn_y;
}

if (variable_global_exists("_pending_save_chunks") && is_struct(global._pending_save_chunks)) {
    if (variable_struct_exists(global._pending_save_chunks, "wifi_state")
    && !is_undefined(global._pending_save_chunks.wifi_state)) {
        _apply_state_blob(global._pending_save_chunks.wifi_state);
        global._pending_save_chunks.wifi_state = undefined;
    }
}