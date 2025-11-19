/// Slack app Step: dragging, minimizing, selection, scroll

var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

var is_down   = mouse_check_button(mb_left);
var pressed   = mouse_check_button_pressed(mb_left);
var released  = mouse_check_button_released(mb_left);

// ensure click gate exists
if (!variable_global_exists("_ui_click_consumed")) {
    global._ui_click_consumed = false;
}

if (open_cooldown > 0) {
    open_cooldown -= 1;
}

// ---------------- Minimized state ----------------
if (is_minimized) {
    var gui_h = display_get_gui_height();
    var tab_x = min_tab_margin;
    var tab_y = gui_h - min_tab_h - min_tab_margin;

    if (pressed && _rect_contains(mx, my, tab_x, tab_y, min_tab_w, min_tab_h)) {
        is_minimized = false;
        window_focus = true;
        global._ui_click_consumed = true;
    }

    // when minimized, ignore everything else
    exit;
}

// ---------------- Stop dragging when mouse released ----------------
if (released) {
    is_dragging = false;
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

// apply dragging while mouse is held
if (is_dragging && is_down) {
    window_x = mx - drag_dx;
    window_y = my - drag_dy;
    _recalc_layout();
}

// safety: if mouse button not held at all, do not drag
if (!is_down) {
    is_dragging = false;
}

// ---------------- Sidebar selection (channels / DMs) ----------------
if (pressed && !global._ui_click_consumed) {
    // inside sidebar?
    if (_rect_contains(mx, my, sidebar_x1, content_y1, sidebar_w, content_y2 - content_y1)) {

        var ch_title_y = content_y1 + 4;
        var ch_list_y1 = ch_title_y + 20;

        var ch_count   = array_length(channels);
        var ch_list_h  = ch_count * row_h;

        var dm_title_y = ch_list_y1 + ch_list_h + 18;
        var dm_list_y1 = dm_title_y + 20;

        // channels
        if (my >= ch_list_y1 && my < ch_list_y1 + ch_list_h) {
            var idx = (my - ch_list_y1) div row_h;
            if (idx >= 0 && idx < ch_count) {
                selected_channel = idx;
                selected_dm = -1;
                chat_scroll = 0;
                global._ui_click_consumed = true;
            }
        }

        // DMs
        var dm_count  = array_length(dm_names);
        var dm_list_h = dm_count * row_h;

        if (!global._ui_click_consumed) {
            if (my >= dm_list_y1 && my < dm_list_y1 + dm_list_h) {
                var d_idx = (my - dm_list_y1) div row_h;
                if (d_idx >= 0 && d_idx < dm_count) {
                    selected_dm = d_idx;
                    selected_channel = -1;
                    chat_scroll = 0;
                    global._ui_click_consumed = true;
                }
            }
        }
    }
}

// ---------------- Chat scroll with mouse wheel ----------------
var scroll_delta = 0;
if (mouse_wheel_up())   scroll_delta -= 24;
if (mouse_wheel_down()) scroll_delta += 24;

if (scroll_delta != 0) {
    if (_rect_contains(mx, my, chat_x1, content_y1, chat_x2 - chat_x1, content_y2 - content_y1)) {
        chat_scroll += scroll_delta;
        if (chat_scroll < 0) chat_scroll = 0;
    }
}
