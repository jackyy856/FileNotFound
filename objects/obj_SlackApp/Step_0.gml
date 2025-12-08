/// Slack app Step: dragging, minimizing, selection, scroll

var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

var is_down  = mouse_check_button(mb_left);
var pressed  = mouse_check_button_pressed(mb_left);

if (!variable_global_exists("_ui_click_consumed")) {
    global._ui_click_consumed = false;
}

if (open_cooldown > 0) {
    open_cooldown -= 1;
}

// If we are minimized, only care about restoring from tab
if (is_minimized) {
    var gui_h = display_get_gui_height();
    var tab_x = min_tab_margin;
    var tab_y = gui_h - min_tab_h - min_tab_margin;

    if (pressed && _rect_contains(mx, my, tab_x, tab_y, min_tab_w, min_tab_h)) {
        is_minimized = false;
        window_focus = true;
        global._ui_click_consumed = true;
    }

    exit;
}

// ---------------- Dragging & focus rectangle ----------------
if (pressed && !_rect_contains(mx, my, window_x, window_y, window_w, window_h)) {
    window_focus = false;
}

// ---------------- Header buttons & start dragging ----------------
if (pressed && !global._ui_click_consumed) {
    // Close
    if (_rect_contains(mx, my, btn_close_x1, btn_close_y1, btn_w, btn_h)) {
        global._ui_click_consumed = true;
        instance_destroy();
        exit;
    }

    // Minimize
    if (_rect_contains(mx, my, btn_min_x1, btn_min_y1, btn_w, btn_h)) {
        is_minimized = true;
        window_focus = false;
        global._ui_click_consumed = true;
        exit;
    }

    // Start dragging on header bar
    if (_rect_contains(mx, my, window_x, window_y, window_w, header_h)) {
        is_dragging = true;
        drag_dx = mx - window_x;
        drag_dy = my - window_y;
        window_focus = true;
        global._ui_click_consumed = true;
    }
}

// Apply dragging
if (is_dragging) {
    if (is_down) {
        window_x = mx - drag_dx;
        window_y = my - drag_dy;
        _recalc_layout();
    } else {
        is_dragging = false;
    }
}

// ---------------- Sidebar selection (channels / DMs) ----------------
var sidebar_w = 260;
if (pressed && !global._ui_click_consumed) {
    if (_rect_contains(mx, my, sidebar_x1, content_y1, sidebar_w, content_y2 - content_y1)) {
        global._ui_click_consumed = true;

        var list_y = content_y1 + 24;
        var row_h  = 20;

        // channels
        var ch_count = array_length(channels);
        var ch_list_y1 = list_y;
        var ch_list_h  = ch_count * row_h;

        if (my >= ch_list_y1 && my < ch_list_y1 + ch_list_h) {
            var idx = (my - ch_list_y1) div row_h;
            if (idx >= 0 && idx < ch_count) {
                selected_channel = idx;
                selected_dm = -1;
                chat_scroll = 100000; // snap to bottom for channel view too
            }
        }

        // move list_y down to DM section
        list_y = ch_list_y1 + ch_list_h + 14 + 22;

        var dm_count  = array_length(dm_names);
        var dm_list_y1 = list_y;
        var dm_list_h = dm_count * row_h;

        if (my >= dm_list_y1 && my < dm_list_y1 + dm_list_h) {
            var d_idx = (my - dm_list_y1) div row_h;
            if (d_idx >= 0 && d_idx < dm_count) {
                selected_dm = d_idx;
                selected_channel = -1;
                chat_scroll = 100000; // start at bottom of that DM
            }
        }
    }
}

// ---------------- Chat scroll with mouse wheel ----------------
var scroll_delta = 0;

// Normal chat behavior: wheel UP -> older (scroll up), wheel DOWN -> newer (scroll down)
if (mouse_wheel_up())   scroll_delta -= 30;  // move toward bottom (newer)
if (mouse_wheel_down()) scroll_delta += 30;  // move toward top (older)


if (scroll_delta != 0) {
    var chat_w = (chat_x2 - chat_x1);
    var chat_h = (content_y2 - content_y1);
    if (_rect_contains(mx, my, chat_x1, content_y1, chat_w, chat_h)) {
        chat_scroll += scroll_delta;
        // clamped in Draw GUI when we know convo height
    }
}
