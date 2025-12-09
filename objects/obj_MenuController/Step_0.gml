var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

// Update save message timer
if (save_message_timer > 0)
{
    save_message_timer--;
}

// Handle exit states first (they overlay everything)
switch (exit_state)
{
    case "none":
        // Handle narration states FIRST (narr1 and narr2)
        if (state == "narr1" || state == "narr2") 
        {
            // Initialize narration if needed
            if (array_length(lines) > 0 && line_index == 0 && visible_chars == 0)
            {
                show_debug_message("Starting narration: " + string(state));
                done_line = false;
            }
            
            // Typewriter effect
            if (!done_line) {
                visible_chars += type_speed;
                if (visible_chars >= string_length(lines[line_index])) {
                    visible_chars = string_length(lines[line_index]); 
                    done_line = true;
                }
            }
            
            // Advance on click or key press
            if (mouse_check_button_pressed(mb_left) || keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) {
                _advance();
            }
            
            // Check for exit button - FIXED: Use actual sprite size
            var exit_sprite_w = sprite_get_width(BacktoMenu);
            var exit_sprite_h = sprite_get_height(BacktoMenu);
            if (mouse_check_button_pressed(mb_left)) {
                if (point_in_rectangle(mx, my, 40, taskbar_y, 40 + exit_sprite_w, taskbar_y + exit_sprite_h))
                {
                    pre_exit_state = state;
                    exit_state = "confirm";
                }
            }
            
            // Exit early - don't process other states
            break;
        }
        
        // If not in narration, handle other states
        switch (state) {
            
            case "main":
                if (mouse_check_button_pressed(mb_left)) {
                    // Check menu buttons
                    for (var i = 0; i < array_length(buttons); i++) {
                        var b = buttons[i];
                        if (_hit(b, mx, my)) {
                            switch (b.kind) {
                                case "load":     state = "load";    break;
                                case "new":
                                    global.flags = ds_map_create();
                                    lines = [
                                        "You've just come home from a long day as head of financial management at Rosenwood Corporation.",
                                        "...but the achiever in you is itching to check your inbox for the 76th time today."
                                    ];
                                    line_index = 0; visible_chars = 0; done_line = false;
                                    state = "narr1";
                                break;
                                case "settings": state = "settings"; break;
                            }
                        }
                    }
                    
                    // Check for exit button - FIXED: Use actual sprite size
                    var exit_sprite_w = sprite_get_width(BacktoMenu);
                    var exit_sprite_h = sprite_get_height(BacktoMenu);
                    if (point_in_rectangle(mx, my, 40, taskbar_y, 40 + exit_sprite_w, taskbar_y + exit_sprite_h))
                    {
                        pre_exit_state = state;
                        exit_state = "confirm";
                    }
                }
            break;
            
            case "load":
                if (mouse_check_button_pressed(mb_left)) {
                    if (_hit(back_btn, mx, my)) { state = "main"; break; }
                    
                    for (var s = 0; s < array_length(slots); s++) {
                        var sl = slots[s];
                        if (_hit(sl, mx, my)) {
                            // Check if save exists
                            if (_save_exists(sl.idx)) {
                                // Load the save data
                                _load_game_from_slot(sl.idx);
                                
                                // Go to the saved room
                                if (variable_global_exists("current_room")) {
                                    room_goto(asset_get_index(global.current_room));
                                } else {
                                    // Default to narration
                                    lines = [
                                        "Loading your saved game...",
                                        "Continuing your investigation..."
                                    ];
                                    line_index = 0; visible_chars = 0; done_line = false;
                                    state = "narr1";
                                }
                            } else {
                                // New game on empty slot
                                show_debug_message("Starting new game in slot " + string(sl.idx));
                                global.save_slot = sl.idx;
                                global.flags = ds_map_create();
                                lines = [
                                    "You've just come home from a long day as head of financial management at Rosenwood Corporation.",
                                    "...but the achiever in you is itching to check your inbox for the 76th time today."
                                ];
                                line_index = 0; visible_chars = 0; done_line = false;
                                state = "narr1";
                            }
                            break;
                        }
                    }
                    
                    // Check for exit button - FIXED: Use actual sprite size
                    var exit_sprite_w = sprite_get_width(BacktoMenu);
                    var exit_sprite_h = sprite_get_height(BacktoMenu);
                    if (point_in_rectangle(mx, my, 40, taskbar_y, 40 + exit_sprite_w, taskbar_y + exit_sprite_h)) {
                        pre_exit_state = state;
                        exit_state = "confirm";
                    }
                }
            break;
            
            case "settings":
                var knob_x = slider.x + (slider_val/100) * slider.w - slider.knob_w*0.5;
                var knob = {x:knob_x, y:slider.y - 7, w:slider.knob_w, h:slider.h + 14};
                
                if (mouse_check_button_pressed(mb_left)) {
                    if (_hit(back_btn, mx, my)) { state = "main"; break; }
                    
                    if (_hit(knob, mx, my)) slider.dragging = true;
                    else if (_hit({x:slider.x, y:slider.y-12, w:slider.w, h:slider.h+24}, mx, my)) {
                        var t = clamp((mx - slider.x) / slider.w, 0, 1);
                        slider_val = round(t * 100);
                        audio_master_gain(slider_val/100);
                        global.master_volume = slider_val;
                    }
                    
                    // Check for exit button - FIXED: Use actual sprite size
                    var exit_sprite_w = sprite_get_width(BacktoMenu);
                    var exit_sprite_h = sprite_get_height(BacktoMenu);
                    if (point_in_rectangle(mx, my, 40, taskbar_y, 40 + exit_sprite_w, taskbar_y + exit_sprite_h))
                    {
                        pre_exit_state = state;
                        exit_state = "confirm";
                    }
                }
                
                if (slider.dragging) {
                    if (!mouse_check_button(mb_left)) slider.dragging = false;
                    else {
                        var t2 = clamp((mx - slider.x) / slider.w, 0, 1);
                        slider_val = round(t2 * 100);
                        audio_master_gain(slider_val/100);
                        global.master_volume = slider_val;
                    }
                }
            break;
        }
    break;
    
    case "confirm":
        // Handle confirmation dialog
        var dialog_w = 500;
        var dialog_h = 250;
        var dialog_x = (display_get_gui_width() - dialog_w) * 0.5;
        var dialog_y = (display_get_gui_height() - dialog_h) * 0.5;
        
        var btn_w = 140;
        var btn_h = 48;
        
        // Yes button (Save) - Left side
        var btn_yes_x = dialog_x + 100;
        var btn_yes_y = dialog_y + dialog_h - btn_h - 30;
        var btn_yes = {x: btn_yes_x, y: btn_yes_y, w: btn_w, h: btn_h};
        
        // No button (Exit without saving) - Right side  
        var btn_no_x = dialog_x + dialog_w - btn_w - 100;
        var btn_no_y = dialog_y + dialog_h - btn_h - 30;
        var btn_no = {x: btn_no_x, y: btn_no_y, w: btn_w, h: btn_h};
        
        if (mouse_check_button_pressed(mb_left))
        {
            // Check which button was clicked
            if (_hit(btn_yes, mx, my))
            {
                exit_state = "save_select";
                selected_save_slot = -1;
            }
            else if (_hit(btn_no, mx, my))
            {
                exit_state = "none";
                state = pre_exit_state;
                game_end();
            }
        }
        
        // ESC key cancels the dialog (goes back to menu)
        if (keyboard_check_pressed(vk_escape))
        {
            exit_state = "none";
            state = pre_exit_state;
        }
        
        // ENTER key triggers save
        if (keyboard_check_pressed(vk_enter))
        {
            exit_state = "save_select";
            selected_save_slot = -1;
        }
    break;
    
    case "save_select":
        // Handle save selection screen
        var panel_w = 900;
        var panel_h = 500;
        var panel_x = (display_get_gui_width() - panel_w) * 0.5;
        var panel_y = (display_get_gui_height() - panel_h) * 0.5;
        
        var slot_w = 240; 
        var slot_h = 240;
        var gap = 40;
        
        var start_x = panel_x + (panel_w - (3*slot_w + 2*gap)) * 0.5;
        var row_y = panel_y + 120;
        
        var save_slots = [
            {x:start_x + 0*(slot_w+gap), y:row_y, w:slot_w, h:slot_h, idx:1},
            {x:start_x + 1*(slot_w+gap), y:row_y, w:slot_w, h:slot_h, idx:2},
            {x:start_x + 2*(slot_w+gap), y:row_y, w:slot_w, h:slot_h, idx:3}
        ];
        
        // ESC key goes back to confirmation
        if (keyboard_check_pressed(vk_escape))
        {
            exit_state = "confirm";
        }
        
        if (mouse_check_button_pressed(mb_left))
        {
            // Check save slots
            for (var i = 0; i < array_length(save_slots); i++)
            {
                var s = save_slots[i];
                if (_hit(s, mx, my))
                {
                    selected_save_slot = s.idx;
                    // Save the game
                    if (_save_game_to_slot(s.idx))
                    {
                        save_message_timer = room_speed * 2; // Show for 2 seconds
                        exit_state = "saving";
                    }
                    break;
                }
            }
        }
    break;
    
    case "saving":
        // Wait for message to show, then exit
        if (save_message_timer <= 0)
        {
            game_end();
        }
        
        // Allow cancel with ESC even while saving
        if (keyboard_check_pressed(vk_escape))
        {
            exit_state = "none";
            state = pre_exit_state;
        }
    break;
}