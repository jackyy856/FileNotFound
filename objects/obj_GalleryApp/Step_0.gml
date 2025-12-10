/// obj_GalleryApp - Step

// Use GUI coordinates for window management
var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);
var mx_local = mx - window_x;
var my_local = my - window_y;

// --- CLICK-THROUGH SHIELD (so desktop icons don't fire when we click the window) ---
if (!variable_global_exists("_ui_click_consumed")) {
    global._ui_click_consumed = false;
}

// ------------------ WINDOW DRAG (title bar + border) ------------------
var in_titlebar = (mx_local >= 0 && mx_local < window_w && my_local >= 0 && my_local < header_h);

// 4-way cursor on frame edges and title bar
var over_drag = _in_win(mx, my) && _on_drag_border(mx, my);

// Set cursor
var over_close = (mx >= close_btn[0] && mx <= close_btn[0] + close_btn[2] && my >= close_btn[1] && my <= close_btn[1] + close_btn[3]);
var over_back = false;
if (fullscreen_mode || puzzle_mode) {
    over_back = (mx >= back_btn[0] && mx <= back_btn[0] + back_btn[2] && my >= back_btn[1] && my <= back_btn[1] + back_btn[3]);
} else if (inbox_mode) {
    over_back = (mx >= inbox_back_btn[0] && mx <= inbox_back_btn[0] + inbox_back_btn[2] && my >= inbox_back_btn[1] && my <= inbox_back_btn[1] + inbox_back_btn[3]);
}

if (over_close || over_back) {
    window_set_cursor(cr_default);
} else if (over_drag && !is_minimized) {
    window_set_cursor(cr_size_all);
} else {
    window_set_cursor(cr_default);
}

// Begin drag from title bar OR frame border
if (mouse_check_button_pressed(mb_left) && (in_titlebar || over_drag) && !over_close && !over_back) {
    window_dragging = true;
    window_drag_dx = mx - window_x;
    window_drag_dy = my - window_y;
}

// Apply dragging
if (window_dragging && mouse_check_button(mb_left)) {
    window_x = mx - window_drag_dx;
    window_y = my - window_drag_dy;
    
    // Recalculate all button positions
    _recalc_gallery_layout();
} else {
    window_dragging = false;
}

var left_press = mouse_check_button_pressed(mb_left);

// If the gallery window is open, keep all its rects in sync with window_x/y
// (Button positions are updated in drag handler, but initialize here)
if (gallery_open) {
    // File browser layout
    files_top    = window_y + header_h + 20;
    files_left   = window_x + 20;
    files_width  = window_w - 40;
    files_height = window_h - header_h - 40;
}

// ---------- HANDLE CLICKS ----------
// Handle inbox key clicks separately (like EmailApp does) - check regardless of window_dragging
// ------------------ CLICKABLE KEY (red key reward) ------------------
if (inbox_mode && gallery_open && !inbox_key_collected) {
    if (mouse_check_button_pressed(mb_left)) {
        var rx = inbox_key_rect[0];
        var ry = inbox_key_rect[1];
        var rw = inbox_key_rect[2];
        var rh = inbox_key_rect[3];
        
        // Use same bounds checking as EmailApp
        if (mx >= rx && mx <= rx + rw && my >= ry && my <= ry + rh && rw > 0 && rh > 0) {
            // Mark collected locally (for immediate Draw feedback)
            inbox_key_collected = true;
            // Swap sprite to glow variant immediately
            inbox_key_sprite = spr_red_glow_key;
            // Play key SFX safely
            var _snd = asset_get_index("sfx_keywow");
            if (_snd != -1) {
                audio_play_sound(_snd, 1, false);
            }
            
            // Ensure global array exists
            if (!variable_global_exists("key_collected")) {
                global.key_collected = array_create(3, false);
            }
            
            // Set global array (for KeySlots on desktop)
            global.key_collected[1] = true;  // RED key
            show_debug_message("Red key clicked in inbox! inbox_key_collected=" + string(inbox_key_collected) + ", global.key_collected[1]=" + string(global.key_collected[1]));

            // Trigger delayed hacker hint for key #2 (unlock Files / firewall nudge)
            if (!variable_global_exists("hacker_key2_hint_fired")) global.hacker_key2_hint_fired = false;
            if (!variable_global_exists("hacker_key2_delay"))      global.hacker_key2_delay      = -1;

            if (!global.hacker_key2_hint_fired) {
                global.hacker_key2_hint_fired = true;
                global.hacker_key2_delay      = room_speed * 2; // 2s delay before ping
                // Mark hacker unread so icon pings after delay resolves
                if (variable_global_exists("hacker_unread")) {
                    global.hacker_unread = true;
                }
            }
        } else {
            // Debug: show what was clicked
            show_debug_message("Click missed key. mx=" + string(mx) + ", my=" + string(my) + ", rect=[" + string(rx) + "," + string(ry) + "," + string(rw) + "," + string(rh) + "]");
        }
    }
}

// Handle inbox back button
if (mouse_check_button_pressed(mb_left) && inbox_mode && gallery_open) {
    if (check_button_click(mx, my, inbox_back_btn)) {
        inbox_mode          = false;
        fullscreen_mode     = false;
        puzzle_mode         = false;
        current_image_index = -1;
    }
}

// Other clicks
if (left_press && !window_dragging) {

    // 1) Mark this click as "used" if it lands anywhere inside the gallery window
    if (mx >= window_x && my >= window_y &&
        mx <  window_x + window_w &&
        my <  window_y + window_h) {
        global._ui_click_consumed = true;
    }

    // 2) Close button works in all modes
    if (check_button_click(mx, my, close_btn)) {
        if (puzzle_mode) {
            exit_puzzle();
        } else if (fullscreen_mode) {
            exit_fullscreen();
        } else {
            instance_destroy();
        }
        exit;
    }
    
    // 3) Puzzle mode: only Back is handled here; pieces are handled by obj_puzzle_piece
    if (puzzle_mode) {
        if (check_button_click(mx, my, back_btn)) {
            exit_puzzle();
            return;
        }
        return;
    }
    
    // 3.5) Inbox mode clicks are handled above (before window_dragging check)
    if (inbox_mode) {
        return; // Already handled above
    }
    
    // 4) Fullscreen image mode
    if (fullscreen_mode) {
        if (check_button_click(mx, my, back_btn)) {
            exit_fullscreen();
            return;
        }
        
        // Navigation arrows
        if (check_button_click(mx, my, left_btn)) {
            navigate_image(-1);
            return;
        }
        if (check_button_click(mx, my, right_btn)) {
            navigate_image(1);
            return;
        }
        
        // Zoom buttons
        if (check_button_click(mx, my, zoom_in_btn)) {
            zoom_scale = min(zoom_scale + 0.3, max_zoom);
            return;
        }
        if (check_button_click(mx, my, zoom_out_btn)) {
            zoom_scale = max(zoom_scale - 0.3, min_zoom);
            return;
        }
        if (check_button_click(mx, my, zoom_reset_btn)) {
            zoom_scale = 1.0;
            pan_x = 0;
            pan_y = 0;
            return;
        }
        
        // Start dragging image if click wasn't on any button
        if (!check_button_click(mx, my, left_btn)  &&
            !check_button_click(mx, my, right_btn) &&
            !check_button_click(mx, my, back_btn)  &&
            !check_button_click(mx, my, zoom_in_btn) &&
            !check_button_click(mx, my, zoom_out_btn) &&
            !check_button_click(mx, my, zoom_reset_btn) &&
            !check_button_click(mx, my, close_btn) &&
            !in_titlebar && !over_drag) {
            
            is_dragging  = true;
            drag_start_x = mx - pan_x;
            drag_start_y = my - pan_y;
        }
    }
    else if (!fullscreen_mode) {
        // 5) Browser mode: click on a row opens that image / puzzle
        var clicked_index = get_clicked_file(mx, my);
        if (clicked_index != -1) {
            open_fullscreen(clicked_index);
            return;
        }
    }
}

// ---------- DRAGGING / KEYBOARD ----------

// Mouse release stops image dragging (for panning in fullscreen)
if (mouse_check_button_released(mb_left)) {
    is_dragging = false;
}

// Drag image while in fullscreen (use GUI coordinates)
if (fullscreen_mode && is_dragging) {
    pan_x = mx - drag_start_x;
    pan_y = my - drag_start_y;
}

// Keyboard controls
if (puzzle_mode) {
    if (keyboard_check_pressed(vk_escape)) {
        exit_puzzle();
    }
}
else if (fullscreen_mode) {
    if (keyboard_check_pressed(ord("=")) || keyboard_check_pressed(vk_add)) {
        zoom_scale = min(zoom_scale + 0.3, max_zoom);
    }
    if (keyboard_check_pressed(ord("-")) || keyboard_check_pressed(vk_subtract)) {
        zoom_scale = max(zoom_scale - 0.3, min_zoom);
    }
    
    if (keyboard_check_pressed(vk_escape)) {
        exit_fullscreen();
    }
    if (keyboard_check_pressed(vk_left)) {
        navigate_image(-1);
    }
    if (keyboard_check_pressed(vk_right)) {
        navigate_image(1);
    }
    
    if (keyboard_check_pressed(ord("R"))) {
        zoom_scale = 1.0;
        pan_x = 0;
        pan_y = 0;
    }
}
