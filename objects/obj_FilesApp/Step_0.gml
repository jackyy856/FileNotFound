var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

function point_in_rect(px, py, x, y, w, h) {
    return (px >= x) && (py >= y) && (px < x + w) && (py < y + h);
}

// --- NEW: click shield to avoid click-through ---
if (!variable_global_exists("_ui_click_consumed")) global._ui_click_consumed = false;
if (mouse_check_button_pressed(mb_left) && _in_win(mx,my)) {
    global._ui_click_consumed = true;
}

// --- NEW: cursor logic (4-way on frame; default on buttons) ---
var over_close = point_in_rect(mx,my, close_btn[0],close_btn[1],close_btn[2],close_btn[3]);
var over_min   = point_in_rect(mx,my, min_btn[0],  min_btn[1],  min_btn[2],  min_btn[3]);
var over_back  = point_in_rect(mx,my, back_btn[0], back_btn[1], back_btn[2], back_btn[3]);
var over_up    = point_in_rect(mx,my, up_btn[0],   up_btn[1],   up_btn[2],   up_btn[3]);

var over_drag  = _in_win(mx,my) && _on_drag_border(mx,my);
if (over_close || over_min || (mode=="view" && over_back) || (cwd.parent!=noone && over_up)) window_set_cursor(cr_default);
else if (over_drag) window_set_cursor(cr_size_all);
else window_set_cursor(cr_default);

// Close
if (mouse_check_button_pressed(mb_left) && over_close) {
    instance_destroy();
    exit;
}

// Minimize
if (mouse_check_button_pressed(mb_left) && over_min) {
    is_minimized = !is_minimized;
    exit;
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
        _recalc_files_layout();
        if (!mouse_check_button(mb_left)) dragging = false;
    }
}

// ESC behavior
if (keyboard_check_pressed(vk_escape)) {
    if (mode == "view") {
        mode = "list";
        selected_index = -1;
    } else {
        instance_destroy();
    }
}

// Back / Up (on breadcrumbs line)
if (mouse_check_button_pressed(mb_left)) {
    if (mode == "view" && over_back) {
        mode = "list";
        selected_index = -1;
        exit;
    }
    if (cwd.parent != noone && over_up) {
        cwd = cwd.parent;
        var n = array_length(breadcrumbs);
        if (n > 0) array_resize(breadcrumbs, n - 1);
        mode = "list";
        selected_index = -1;
        exit;
    }
}

// Grid interactions (list mode) — disabled when minimized
if (!is_minimized && mode == "list") {
    var grid_x = list_left;
    var grid_y = content_top;
    var cols   = grid_cols;
    var rows   = ceil(array_length(cwd.children) / cols);

    var within =
        (mx >= grid_x) && (mx < grid_x + cols * cell_w) &&
        (my >= grid_y) && (my < grid_y + rows * cell_h);

    if (within && mouse_check_button_pressed(mb_left)) {
        var col = floor((mx - grid_x) / cell_w);
        var row = floor((my - grid_y) / cell_h);
        var idx = row * cols + col;

        var len = array_length(cwd.children);
        if (idx >= 0 && idx < len) {
            selected_index = idx;
            var item = cwd.children[idx];

            if (item.type == "folder") {
                cwd = item;
                breadcrumbs[array_length(breadcrumbs)] = cwd;
                selected_index = -1;
            } else if (item.type == "text") {
                viewer_type = "text";
                viewer_text = string(item.content);
                mode = "view";
            } else if (item.type == "image") {
                viewer_type = "image";
                if (is_undefined(item.sprite)) { viewer_sprite = -1; } else { viewer_sprite = item.sprite; }
                mode = "view";
            }
        }
    }
}
