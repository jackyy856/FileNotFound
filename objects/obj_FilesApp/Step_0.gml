/// --- CLICK-THROUGH GUARD (header, do not clear mouse here) ---
if (!variable_global_exists("_ui_click_consumed")) global._ui_click_consumed = false;
if (!variable_instance_exists(id, "__ui_click_inside")) __ui_click_inside = false;

var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);
var _wx = window_x, _wy = window_y, _ww = window_w, _wh = window_h;

if (mouse_check_button_pressed(mb_left)) {
    if (_mx >= _wx && _my >= _wy && _mx < _wx + _ww && _my < _wy + _wh) {
        __ui_click_inside = true;
    }
}

var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

function point_in_rect(px, py, x, y, w, h) {
    return (px >= x) && (py >= y) && (px < x + w) && (py < y + h);
}

// cooldown to prevent icon click from also opening a file immediately
if (open_cooldown > 0) open_cooldown--;

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
if (over_close || over_min || (mode=="view" && over_back) || (cwd.parent!=noone && over_up)) {
    window_set_cursor(cr_default);
}
else if (over_drag && mode != "firewall") {
    window_set_cursor(cr_size_all);
}
else {
    window_set_cursor(cr_default);
}

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

// --- drag frame (disabled when minimized OR in firewall puzzle) ---
if (!is_minimized && mode != "firewall") {
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
    } else if (mode == "firewall") {
        mode = "list";
        firewall_state = "idle";
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

    if (within && mouse_check_button_pressed(mb_left) && open_cooldown <= 0) {
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
            } else if (item.type == "puzzle_firewall") {
                mode = "firewall";
                firewall_start();
            }
        }
    }
}

// --- Firewall puzzle interactions ---
if (!is_minimized && mode == "firewall") {

    // ----- column geometry (match Draw GUI exactly) -----
    var panel_x1 = window_x + 140;
    var panel_y1 = content_top + 20;
    var panel_x2 = window_x + window_w - 140;
    var panel_y2 = window_y + window_h - 80;

    var deny_x1 = panel_x1 + 40;
    var deny_y1 = panel_y1 + 40;
    var deny_x2 = (panel_x1 + panel_x2) * 0.5 - 20;
    var deny_y2 = panel_y2 - 40;

    var admit_x1 = (panel_x1 + panel_x2) * 0.5 + 20;
    var admit_y1 = deny_y1;
    var admit_x2 = panel_x2 - 40;
    var admit_y2 = deny_y2;

    // rects used for hit tests
    var deny_x  = deny_x1;
    var deny_y  = deny_y1;
    var deny_w  = deny_x2 - deny_x1;
    var deny_h  = deny_y2 - deny_y1;

    var admit_x = admit_x1;
    var admit_y = admit_y1;
    var admit_w = admit_x2 - admit_x1;
    var admit_h = admit_y2 - admit_y1;

    // confirm dialog rect + buttons (must match Draw)
    var cw = 420;
    var ch = 140;
    var cx = window_x + (window_w - cw) * 0.5;
    var cy = window_y + (window_h - ch) * 0.5;

    var ok_w = 96, ok_h = 32;
    var ok_x = cx + cw - ok_w - 24;
    var ok_y = cy + ch - ok_h - 24;

    var cancel_w = 96, cancel_h = 32;
    var cancel_x = cx + 24;
    var cancel_y = ok_y;

    var n_cards = array_length(firewall_cards);

    // ----- drag cards (only in play/confirm) -----
    if (firewall_state == "play" || firewall_state == "confirm") {

        // pick up card
        if (mouse_check_button_pressed(mb_left)) {
            for (var i = n_cards - 1; i >= 0; i--) {
                var c = firewall_cards[i];
                if (point_in_rect(mx, my, c.x, c.y, c.w, c.h)) {
                    c.dragging = true;
                    c.drag_dx  = mx - c.x;
                    c.drag_dy  = my - c.y;

                    // bring to front
                    var last = n_cards - 1;
                    firewall_cards[i] = firewall_cards[last];
                    firewall_cards[last] = c;
                    break;
                }
            }
        }

        // move + drop
        for (var j = 0; j < n_cards; j++) {
            var cc = firewall_cards[j];
            if (cc.dragging) {
                cc.x = mx - cc.drag_dx;
                cc.y = my - cc.drag_dy;

                if (!mouse_check_button(mb_left)) {
                    cc.dragging = false;

                    var cx2 = cc.x + cc.w * 0.5;
                    var cy2 = cc.y + cc.h * 0.5;

                    if (point_in_rect(cx2, cy2, deny_x, deny_y, deny_w, deny_h)) {
                        cc.col = 0; // Deny
                    } else if (point_in_rect(cx2, cy2, admit_x, admit_y, admit_w, admit_h)) {
                        cc.col = 1; // Admit
                    } else {
                        cc.col = -1; // not in any box
                    }
                }
            }
            firewall_cards[j] = cc;
        }

        // are ALL cards placed in *either* column?
        var all_placed = (n_cards > 0);
        for (var k = 0; k < n_cards; k++) {
            if (firewall_cards[k].col < 0) { // -1 = unplaced
                all_placed = false;
                break;
            }
        }

        if (all_placed && firewall_state == "play") {
            firewall_state = "confirm";
        }
        if (!all_placed && firewall_state == "confirm") {
            firewall_state = "play";
        }
    }

    // ----- confirm popup buttons -----
    if (firewall_state == "confirm") {
        if (mouse_check_button_pressed(mb_left)) {
            if (point_in_rect(mx, my, ok_x, ok_y, ok_w, ok_h)) {
                // lock answers -> start auto "truth" animation
                firewall_state  = "auto";
                firewall_auto_t = 0;
            } else if (point_in_rect(mx, my, cancel_x, cancel_y, cancel_w, cancel_h)) {
                firewall_state = "play";
            }
        }
    }

        // ----- auto-move: stack everything in Admit -----
    if (firewall_state == "auto") {
        firewall_auto_t += 1;

        var admit_mid_x = (admit_x1 + admit_x2) * 0.5;
        var base_y      = deny_y1 + 60;
        var row_h       = 72;

        // Build order: first all cards the player put in Admit, then Deny
        var admit_list = [];
        var deny_list  = [];

        for (var a = 0; a < n_cards; a++) {
            var ca = firewall_cards[a];
            if (ca.col == 1) {
                admit_list[array_length(admit_list)] = a;
            } else {
                deny_list[array_length(deny_list)] = a;
            }
        }

        var slot = 0;

        // cards already in Admit stay on top, just tidy into stack
        for (var ai = 0; ai < array_length(admit_list); ai++) {
            var idx_a = admit_list[ai];
            var cA    = firewall_cards[idx_a];

            var tx = admit_mid_x - cA.w * 0.5;
            var ty = base_y + slot * row_h;

            cA.x += (tx - cA.x) * 0.2;
            cA.y += (ty - cA.y) * 0.2;
            cA.col = 1;

            firewall_cards[idx_a] = cA;
            slot++;
        }

        // cards from Deny slide over and stack underneath
        for (var di = 0; di < array_length(deny_list); di++) {
            var idx_d = deny_list[di];
            var cD    = firewall_cards[idx_d];

            var tx2 = admit_mid_x - cD.w * 0.5;
            var ty2 = base_y + slot * row_h;

            cD.x += (tx2 - cD.x) * 0.2;
            cD.y += (ty2 - cD.y) * 0.2;
            cD.col = 1;

            firewall_cards[idx_d] = cD;
            slot++;
        }

        // after short delay, show hacker file (always) and only grant key once
        if (firewall_auto_t > 45) {
            firewall_state = "done";

            // give the red key once
            if (!firewall_key_given) {
                firewall_key_given = true;
                global.key_red = true;
            }

            viewer_type = "text";
            viewer_text =
                "FIREWALL LOG UNLOCKED\n\n" +
                "Hacker: \"Yeah. That's right, Vanessa. You did all of it.\n" +
                "You lit the match. You walked away. You buried the truth.\"\n\n" +
                "Hacker: \"I know everything you tried to bury. And now you do too.\"\n\n" +
                "Click the red key.";

            // tell view mode to draw the key sprites
            viewer_show_red_key = true;

            mode = "view";
            selected_index = -1;
        }
    }
}
