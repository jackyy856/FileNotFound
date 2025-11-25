/// obj_GalleryApp - Step

// --- CLICK-THROUGH SHIELD (so desktop icons don't fire when we click the window) ---
if (!variable_global_exists("_ui_click_consumed")) {
    global._ui_click_consumed = false;
}

var mx = mouse_x;
var my = mouse_y;
var left_press = mouse_check_button_pressed(mb_left);

// If the gallery window is open, keep all its rects in sync with window_x/y
if (gallery_open) {
    // Update button positions
    close_btn = [window_x + window_w - 40, window_y + 10, 30, 30]; 
    back_btn  = [window_x + 15, window_y + 10, 70, 30];
    left_btn  = [window_x + 30, window_y + window_h/2 - nav_btn_size/2, nav_btn_size, nav_btn_size];
    right_btn = [window_x + window_w - nav_btn_size - 30, window_y + window_h/2 - nav_btn_size/2, nav_btn_size, nav_btn_size];
    
    // Zoom buttons
    zoom_in_btn    = [window_x + window_w - 50, window_y + header_h + 100, 40, 30];
    zoom_out_btn   = [window_x + window_w - 50, window_y + header_h + 140, 40, 30];
    zoom_reset_btn = [window_x + window_w - 50, window_y + header_h + 180, 40, 30];
    
    // File browser layout
    files_top    = window_y + header_h + 20;
    files_left   = window_x + 20;
    files_width  = window_w - 40;
    files_height = window_h - header_h - 40;
}

// ---------- HANDLE CLICKS ----------
if (left_press) {

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
        
        // Start dragging image if click wasn’t on any button
        if (!check_button_click(mx, my, left_btn) && 
            !check_button_click(mx, my, right_btn) &&
            !check_button_click(mx, my, back_btn) &&
            !check_button_click(mx, my, zoom_in_btn) &&
            !check_button_click(mx, my, zoom_out_btn) &&
            !check_button_click(mx, my, zoom_reset_btn) &&
            !check_button_click(mx, my, close_btn)) {
            
            is_dragging  = true;
            drag_start_x = mx - pan_x;
            drag_start_y = my - pan_y;
        }
    }
    else {
        // 5) Browser mode: click on a row opens that image / puzzle
        var clicked_index = get_clicked_file(mx, my);
        if (clicked_index != -1) {
            open_fullscreen(clicked_index);
            return;
        }
    }
}

// ---------- DRAGGING / KEYBOARD ----------

// Mouse release stops dragging
if (mouse_check_button_released(mb_left)) {
    is_dragging = false;
}

// Drag image while in fullscreen
if (fullscreen_mode && is_dragging) {
    pan_x = mouse_x - drag_start_x;
    pan_y = mouse_y - drag_start_y;
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
