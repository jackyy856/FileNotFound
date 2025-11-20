/// --- CLICK-THROUGH GUARD (header, do not clear mouse here) ---
if (!variable_global_exists("_ui_click_consumed")) global._ui_click_consumed = false;
if (!variable_instance_exists(id, "__ui_click_inside")) __ui_click_inside = false;

var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);
var _wx = window_x, _wy = window_y, _ww = window_w, _wh = window_h;

if (mouse_check_button_pressed(mb_left)) {
    if (_mx >= _wx && _my >= _wy && _mx < _wx + _ww && _my < _wy + _wh) {
        // Remember that this frame started with a click inside our window.
        // We’ll actually mark it as “consumed” in End Step, AFTER our own UI has used it.
        __ui_click_inside = true;
    }
}


if (!gallery_open) exit;

var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);


// cooldown to prevent icon click from instantly opening an image row
if (open_cooldown > 0) open_cooldown--;

// --- NEW: click shield ---
if (!variable_global_exists("_ui_click_consumed")) global._ui_click_consumed = false;
if (mouse_check_button_pressed(mb_left) && _in_win(mx,my)) {
    global._ui_click_consumed = true;
}

// --- NEW: cursor on frame vs buttons ---
var over_close = check_button_click(mx,my, close_btn);
var over_min   = check_button_click(mx,my, min_btn);
var over_back  = check_button_click(mx,my, back_btn);
var over_drag  = _in_win(mx,my) && _on_drag_border(mx,my);
if (over_close || over_min || (fullscreen_mode && over_back)) window_set_cursor(cr_default);
else if (over_drag) window_set_cursor(cr_size_all);
else window_set_cursor(cr_default);

// Handle mouse clicks (top-level buttons)
if (mouse_check_button_pressed(mb_left)) {
    if (check_button_click(mx,my, close_btn)) { instance_destroy(); exit; }
    if (check_button_click(mx,my, min_btn)) { is_minimized = !is_minimized; exit; }
}

// --- NEW: drag frame (disabled when minimized) ---
if (!is_minimized) {
    if (mouse_check_button_pressed(mb_left) && over_drag) {
        dragging = true; 
        drag_dx = mx - window_x; 
        drag_dy = my - window_y;
    }
    if (dragging) {
        window_x = mx - drag_dx;
        window_y = my - drag_dy;
        _recalc_gallery_layout();
        if (!mouse_check_button(mb_left)) dragging = false;
    }
}

// if minimized, skip inner interactions
if (is_minimized) exit;

// Fullscreen mode interactions
if (fullscreen_mode) {
    if (mouse_check_button_pressed(mb_left)) {
        if (check_button_click(mx, my, back_btn)) { exit_fullscreen(); return; }
        if (check_button_click(mx, my, left_btn)) { navigate_image(-1); return; }
        if (check_button_click(mx, my, right_btn)) { navigate_image(1);  return; }
        if (check_button_click(mx, my, zoom_in_btn))    { zoom_scale = min(zoom_scale + 0.3, max_zoom); return; }
        if (check_button_click(mx, my, zoom_out_btn))   { zoom_scale = max(zoom_scale - 0.3, min_zoom); return; }
        if (check_button_click(mx, my, zoom_reset_btn)) { zoom_scale = 1.0; pan_x = 0; pan_y = 0; return; }

        // Start dragging image
        if (!check_button_click(mx,my,left_btn) && !check_button_click(mx,my,right_btn)
         && !check_button_click(mx,my,back_btn) && !check_button_click(mx,my,zoom_in_btn)
         && !check_button_click(mx,my,zoom_out_btn) && !check_button_click(mx,my,zoom_reset_btn)
         && !check_button_click(mx,my,close_btn) && !check_button_click(mx,my,min_btn)) {
            is_dragging = true;
            drag_start_x = mx - pan_x;
            drag_start_y = my - pan_y;
        }
    }

    if (mouse_check_button_released(mb_left)) is_dragging = false;
    if (is_dragging) { pan_x = mx - drag_start_x; pan_y = my - drag_start_y; }

    if (keyboard_check_pressed(ord("=")) || keyboard_check_pressed(vk_add)) zoom_scale = min(zoom_scale + 0.3, max_zoom);
    if (keyboard_check_pressed(ord("-")) || keyboard_check_pressed(vk_subtract)) zoom_scale = max(zoom_scale - 0.3, min_zoom);
    if (keyboard_check_pressed(vk_escape)) exit_fullscreen();
    if (keyboard_check_pressed(vk_left))  navigate_image(-1);
    if (keyboard_check_pressed(vk_right)) navigate_image(1);
    if (keyboard_check_pressed(ord("R"))) { zoom_scale = 1.0; pan_x = 0; pan_y = 0; }
}
else
{
    // File list click opens fullscreen (after cooldown)
    if (mouse_check_button_pressed(mb_left) && open_cooldown <= 0) {
        var clicked_index = get_clicked_file(mx, my);
        if (clicked_index != -1) { open_fullscreen(clicked_index); return; }
    }
}

