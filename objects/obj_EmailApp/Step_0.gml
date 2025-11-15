var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);
var mx_local = mx - window_x;
var my_local = my - window_y;

function in_local(px, py, x, y, w, h) {
    return (px >= x) && (py >= y) && (px < x + w) && (py < y + h);
}

// cooldown to prevent double-open when app spawns
if (open_cooldown > 0) open_cooldown--;

// mark if a press started inside our active region
if (mouse_check_button_pressed(mb_left)) {
    // If minimized, only the title bar counts as "inside"
    if (is_minimized) {
        if (in_local(mx_local, my_local, 0, 0, window_w, header_h)) {
            __ui_click_inside = true;
        }
    } else {
        if (mx >= window_x && my >= window_y && mx < window_x + window_w && my < window_y + window_h) {
            __ui_click_inside = true;
        }
    }
}

// soft block initial opener click
if (__ui_first_frame_block > 0) __ui_first_frame_block--;

// ------------------ WINDOW DRAG (title bar + border) ------------------
var in_titlebar = in_local(mx_local, my_local, 0, 0, window_w, header_h);

// buttons (local)
var over_close = in_local(mx_local, my_local, close_btn[0]-window_x, close_btn[1]-window_y, close_btn[2], close_btn[3]);
var over_min   = in_local(mx_local, my_local, min_btn[0]-window_x,   min_btn[1]-window_y,   min_btn[2],   min_btn[3]);
var over_back  = (selected_index != -1) &&
                 in_local(mx_local, my_local, back_btn[0]-window_x,  back_btn[1]-window_y,  back_btn[2],  back_btn[3]);

// 4-way cursor on frame edges, but not on buttons
var over_drag  = _in_win(mx,my) && _on_drag_border(mx,my);
if (over_close || over_min || over_back) {
    window_set_cursor(cr_default);
} else if (over_drag) {
    window_set_cursor(cr_size_all);
} else {
    window_set_cursor(cr_default);
}

// begin drag from title bar OR frame border
if (mouse_check_button_pressed(mb_left) && (in_titlebar || over_drag)) {
    window_dragging = true;
    window_drag_dx = mx - window_x;
    window_drag_dy = my - window_y;
}
if (window_dragging) {
    window_x = mx - window_drag_dx;
    window_y = my - window_drag_dy;
    _recalc_email_layout();
    if (!mouse_check_button(mb_left)) window_dragging = false;
}

// ------------------ CLOSE / MINIMIZE ------------------
if (mouse_check_button_pressed(mb_left)) {
    // close (X)
    if (over_close) {
        instance_destroy();
        exit;
    }
    // minimize (-)
    if (over_min) {
        is_minimized = !is_minimized;
        // when minimized, we ignore content interactions but can still drag the title bar
        exit;
    }
}

// If minimized: do not process content UI below
if (is_minimized) {
    // advance binary rain lightly to keep animation coherent if you still draw it
    bin_scroll += bin_speed;
    if (bin_scroll >= bin_cell) bin_scroll -= bin_cell;
    exit;
}

// ------------------ INBOX / MESSAGE NAV ------------------
if (selected_index == -1) {
    if (open_cooldown <= 0 &&
        mouse_check_button_pressed(mb_left) &&
        mx >= list_left && mx <= list_left + list_w &&
        my >= list_top  && my <= list_top  + list_h)
    {
        var idx = floor((my - list_top) / row_h);
        var len = array_length(inbox);
        if (idx >= 0 && idx < len) {
            selected_index = idx;
            inbox[idx].read = true;

            if (inbox[idx].is_suspicious) {
                if (!is_undefined(global.apps_unlocked) && is_struct(global.apps_unlocked)) {
                    global.apps_unlocked.Messenger = true;
                }
            }

            if (idx == corrupted_index) {
                puzzle_active     = puzzle_gate && !puzzle_solved;
            }
        }
    }
} else {
    if (mouse_check_button_pressed(mb_left)) {
        if (over_back) {
            selected_index    = -1;
            puzzle_active     = false;
        }
    }
}

// ------------------ PUZZLE DnD (LOCAL) ------------------
if (selected_index != -1) {
    var em = inbox[selected_index];
    var _em_cor = variable_struct_exists(em,"is_corrupted") && em.is_corrupted;

    // Modal OK (LOCAL) when solved
    if (_em_cor && puzzle_solved) {
        if (mouse_check_button_pressed(mb_left)) {
            var bx = ok_btn_local[0], by = ok_btn_local[1], bw = ok_btn_local[2], bh = ok_btn_local[3];
            if (in_local(mx_local, my_local, bx, by, bw, bh)) {
                // dismiss modal (if you want to do something)
            }
        }
        exit;
    }

    if (_em_cor && puzzle_active) {
        // START DRAG
        if (mouse_check_button_pressed(mb_left)) {
            for (var i = array_length(word_btns)-1; i >= 0; i--) {
                var b = word_btns[i];
                if (in_local(mx_local, my_local, b.x, b.y, b.w, b.h)) {
                    b.dragging = true;
                    b.dx = mx_local - b.x;
                    b.dy = my_local - b.y;
                    b.placed = false;
                    word_btns[i] = b;
                    break;
                }
            }
        }
        // DRAG
        if (mouse_check_button(mb_left)) {
            for (var i = 0; i < array_length(word_btns); i++) if (word_btns[i].dragging) {
                word_btns[i].x = mx_local - word_btns[i].dx;
                word_btns[i].y = my_local - word_btns[i].dy;
            }
        }
        // DROP
        if (mouse_check_button_released(mb_left)) {
            for (var i = 0; i < array_length(word_btns); i++) if (word_btns[i].dragging) {
                word_btns[i].dragging = false;

                var inside = in_local(mx_local, my_local, puzzle_area_local.x, puzzle_area_local.y, puzzle_area_local.w, puzzle_area_local.h);
                if (inside) {
                    word_btns[i].placed = true;
                } else {
                    word_btns[i].placed = false;
                    word_btns[i].x = word_btns[i].ox;
                    word_btns[i].y = word_btns[i].oy;
                }
            }

            // Validate order (by LOCAL x)
            var placed = [];
            for (var j = 0; j < array_length(word_btns); j++) if (word_btns[j].placed) array_push(placed, word_btns[j]);
            array_sort(placed, function(a,b){ return a.x - b.x; });

            var placed_texts = [];
            for (var k = 0; k < array_length(placed); k++) array_push(placed_texts, placed[k].text);

            var ok = (array_length(placed_texts) == array_length(puzzle_target));
            if (ok) {
                for (var t = 0; t < array_length(puzzle_target); t++) {
                    if (placed_texts[t] != puzzle_target[t]) { ok = false; break; }
                }
            }

            if (ok) {
                puzzle_solved  = true;
                puzzle_active  = false;

                var title_text = "";
                for (var p = 0; p < array_length(puzzle_target); p++) {
                    title_text += (p==0)? puzzle_target[p] : (" " + puzzle_target[p]);
                }

                inbox[corrupted_index].subject = title_text;
                inbox[corrupted_index].body =
                    "Great work. The Wi-Fi password is: \"ARCADIA-Guest-42\".\n\n" +
                    "You can now connect to proceed."; // TODO: your text
                inbox[corrupted_index].is_corrupted = false;

                puzzle_message = "The message has been reconstructed.\n" +
                                 "Title recovered: \"" + title_text + "\"";
            }
        }
    }
}

// advance binary rain
bin_scroll += bin_speed;
if (bin_scroll >= bin_cell) bin_scroll -= bin_cell;
