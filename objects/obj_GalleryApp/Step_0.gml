if (gallery_open) {
    // Update button positions
    close_btn = [window_x + window_w - 40, window_y + 10, 30, 30]; 
    back_btn  = [window_x + 15, window_y + 10, 70, 30];
    left_btn  = [window_x + 30, window_y + window_h/2 - nav_btn_size/2, nav_btn_size, nav_btn_size];
    right_btn = [window_x + window_w - nav_btn_size - 30, window_y + window_h/2 - nav_btn_size/2, nav_btn_size, nav_btn_size];
    
    // Zoom buttons
    zoom_in_btn = [window_x + window_w - 50, window_y + header_h + 100, 40, 30];
    zoom_out_btn = [window_x + window_w - 50, window_y + header_h + 140, 40, 30];
    zoom_reset_btn = [window_x + window_w - 50, window_y + header_h + 180, 40, 30];
    
    // Update file browser layout too
    files_top = window_y + header_h + 20;
    files_left = window_x + 20;
    files_width = window_w - 40;
    files_height = window_h - header_h - 40;
}

// Handle mouse clicks
if (mouse_check_button_pressed(mb_left)) {
    var mx = mouse_x;
    var my = mouse_y;
    
    // Close button works in all modes
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
    
    if (puzzle_mode) {
        // In puzzle mode, only handle back button - puzzle handles the rest
        if (check_button_click(mx, my, back_btn)) {
            exit_puzzle();
            return;
        }
        // Let the puzzle manager handle other clicks
        return;
    }
    
    if (fullscreen_mode) {
        // Back button in fullscreen
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
        
        // ZOOM BUTTONS
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
        
        // Start dragging if clicking on image area
        if (!check_button_click(mx, my, left_btn) && 
            !check_button_click(mx, my, right_btn) &&
            !check_button_click(mx, my, back_btn) &&
            !check_button_click(mx, my, zoom_in_btn) &&
            !check_button_click(mx, my, zoom_out_btn) &&
            !check_button_click(mx, my, zoom_reset_btn) &&
            !check_button_click(mx, my, close_btn)) {
            
            is_dragging = true;
            drag_start_x = mx - pan_x;
            drag_start_y = my - pan_y;
        }
    } else {
        // Gallery view - check file clicks
        var clicked_index = get_clicked_file(mx, my);
        if (clicked_index != -1) {
            open_fullscreen(clicked_index);
            return;
        }
    }
}

// Handle mouse release
if (mouse_check_button_released(mb_left)) {
    is_dragging = false;
}

// Handle dragging in fullscreen mode
if (fullscreen_mode && is_dragging) {
    pan_x = mouse_x - drag_start_x;
    pan_y = mouse_y - drag_start_y;
}

// Handle keyboard controls
if (puzzle_mode) {
    // ESC to exit puzzle
    if (keyboard_check_pressed(vk_escape)) {
        exit_puzzle();
    }
} else if (fullscreen_mode) {
    // Keyboard zoom controls
    if (keyboard_check_pressed(ord("=")) || keyboard_check_pressed(vk_add)) {
        zoom_scale = min(zoom_scale + 0.3, max_zoom);
    }
    if (keyboard_check_pressed(ord("-")) || keyboard_check_pressed(vk_subtract)) {
        zoom_scale = max(zoom_scale - 0.3, min_zoom);
    }
    
    // Keyboard navigation
    if (keyboard_check_pressed(vk_escape)) {
        exit_fullscreen();
    }
    if (keyboard_check_pressed(vk_left)) {
        navigate_image(-1);
    }
    if (keyboard_check_pressed(vk_right)) {
        navigate_image(1);
    }
    
    // Reset view with R key
    if (keyboard_check_pressed(ord("R"))) {
        zoom_scale = 1.0;
        pan_x = 0;
        pan_y = 0;
    }
}