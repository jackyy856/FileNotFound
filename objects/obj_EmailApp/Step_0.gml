// --- mouse in GUI space ---
var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

// --- small helper ---
function point_in_rect(px, py, x, y, w, h) {
    return (px >= x) && (py >= y) && (px < x + w) && (py < y + h);
}

// --- NEW: one-frame desktop click shield (prevents click-through) ---
if (!variable_global_exists("_ui_click_consumed")) global._ui_click_consumed = false;
if (mouse_check_button_pressed(mb_left) && _in_win(mx,my)) {
    global._ui_click_consumed = true;
}

// --- NEW: cursor mode: default on actionable buttons; 4-way on frame/drag ---
var over_close = point_in_rect(mx,my, close_btn[0],close_btn[1],close_btn[2],close_btn[3]);
var over_min   = point_in_rect(mx,my, min_btn[0],  min_btn[1],  min_btn[2],  min_btn[3]);
var over_back  = point_in_rect(mx,my, back_btn[0], back_btn[1], back_btn[2], back_btn[3]);

var over_drag  = _in_win(mx,my) && _on_drag_border(mx,my);
if (over_close || over_min || (selected_index!=-1 && over_back)) window_set_cursor(cr_default);
else if (over_drag) window_set_cursor(cr_size_all);
else window_set_cursor(cr_default);

// --- NEW: minimize toggle (drawn even when minimized) ---
if (mouse_check_button_pressed(mb_left) && over_min) {
    is_minimized = !is_minimized;
    exit; // don’t process content when toggling minimize
}

// close button
if (mouse_check_button_pressed(mb_left) && over_close) {
    instance_destroy();
    exit;
}

// --- NEW: drag frame (all edges), disabled while minimized ---
if (!is_minimized) {
    if (mouse_check_button_pressed(mb_left) && over_drag) {
        dragging = true; 
        drag_dx = mx - window_x; 
        drag_dy = my - window_y;
    }
    if (dragging) {
        window_x = mx - drag_dx;
        window_y = my - drag_dy;
        _recalc_email_layout();
        // keep puzzle tiles relative to mouse; we don't auto-shift them
        if (!mouse_check_button(mb_left)) dragging = false;
    }
}

// bail content if minimized (titlebar only)
if (is_minimized) exit;

// ynbox view -> click a row to open
if (selected_index == -1) {
    if (mouse_check_button_pressed(mb_left) &&
        mx >= list_left && mx <= list_left + list_w &&
        my >= list_top  && my <= list_top  + list_h) {

        var idx = floor((my - list_top) / row_h);
        var len = array_length(inbox);
        if (idx >= 0 && idx < len) {
            selected_index = idx;
            inbox[idx].read = true;

            // suspicious email -> unlock Messenger
            if (inbox[idx].is_suspicious) {
                if (!is_undefined(global.apps_unlocked) && is_struct(global.apps_unlocked)) {
                    global.apps_unlocked.Messenger = true;
                }
            }

            // >>> Activate puzzle only if this is the corrupted email and the gate is on
            if (idx == corrupted_index) {
                puzzle_active     = puzzle_gate && !puzzle_solved;
                puzzle_scattered  = false; // mark as needing scatter on first frame
            }
        }
    }
}
// Message view -> back
else {
    if (mouse_check_button_pressed(mb_left)) {
        if (point_in_rect(mx, my, back_btn[0], back_btn[1], back_btn[2], back_btn[3])) {
            selected_index    = -1;
            puzzle_active     = false;
            puzzle_scattered  = false; // reset; will rescat ter next time we open
        }
    }
}

// ---------- DRAG & DROP for puzzle (only when viewing the corrupted email) ----------
if (selected_index != -1) {
    var em = inbox[selected_index];
    var _em_cor = variable_struct_exists(em,"is_corrupted") && em.is_corrupted;

    // One-time spawn: if corrupted and active but not scattered yet -> scatter now
	if (_em_cor && puzzle_active && !puzzle_scattered) {
	    var rx = window_x + 12;
	    var ry = window_y + header_h + 8;
	    var rw = window_w - 24;
	    var rh = window_h - header_h - 80;

	    var region_h = clamp(ceil(rh * 0.35), 80, rh - 40);

	    var minx = floor(rx + 8);
	    var maxx = floor(rx + rw - word_btn_w - 8);
	    var miny = floor(ry + rh - region_h);
	    var maxy = floor(ry + rh - word_btn_h - 8);

	    if (maxx < minx || maxy < miny) {
	        minx = floor(puzzle_area.x + 8);
	        maxx = floor(puzzle_area.x + puzzle_area.w - word_btn_w - 8);
	        miny = floor(puzzle_area.y + puzzle_area.h + 8);
	        maxy = floor(ry + rh - word_btn_h - 8);
	        if (maxx < minx) { var _tx = minx; minx = maxx; maxx = _tx; }
	        if (maxy < miny) { var _ty = miny; miny = maxy; maxy = _ty; }
	    }

	    minx = max(0, minx); miny = max(0, miny);

	    for (var s = 0; s < array_length(word_btns); s++) {
	        var rxpos = irandom_range(minx, maxx);
	        var rypos = irandom_range(miny, maxy);

	        word_btns[s].x = word_btns[s].ox = rxpos;
	        word_btns[s].y = word_btns[s].oy = rypos;
	        word_btns[s].placed   = false;
	        word_btns[s].dragging = false;
	    }

	    puzzle_scattered = true;
	}

    // Handle Ok button on modal
    if (_em_cor && puzzle_solved) {
        if (mouse_check_button_pressed(mb_left)) {
            var mx2 = device_mouse_x_to_gui(0);
            var my2 = device_mouse_y_to_gui(0);
            if (mx2 >= ok_btn[0] && mx2 <= ok_btn[0]+ok_btn[2] &&
                my2 >= ok_btn[1] && my2 <= ok_btn[1]+ok_btn[3]) {
                // Dismiss modal
            }
        }
        exit; // don't allow interacting with buttons under modal
    }

    if (_em_cor && puzzle_active) {
        var mx3 = device_mouse_x_to_gui(0);
        var my3 = device_mouse_y_to_gui(0);

        if (mouse_check_button_pressed(mb_left)) {
            for (var i = array_length(word_btns)-1; i >= 0; i--) {
                var b = word_btns[i];
                if (point_in_rect(mx3, my3, b.x, b.y, b.w, b.h)) {
                    word_btns[i].dragging = true;
                    word_btns[i].dx = mx3 - b.x;
                    word_btns[i].dy = my3 - b.y;
                    word_btns[i].placed = false;
                    break;
                }
            }
        }

        if (mouse_check_button(mb_left)) {
            for (var i2 = 0; i2 < array_length(word_btns); i2++) {
                if (word_btns[i2].dragging) {
                    word_btns[i2].x = mx3 - word_btns[i2].dx;
                    word_btns[i2].y = my3 - word_btns[i2].dy;
                }
            }
        }

        if (mouse_check_button_released(mb_left)) {
            for (var i3 = 0; i3 < array_length(word_btns); i3++) {
                if (word_btns[i3].dragging) {
                    word_btns[i3].dragging = false;

                    var inside = point_in_rect(
                        mx3, my3,
                        puzzle_area.x, puzzle_area.y, puzzle_area.w, puzzle_area.h
                    );

                    if (inside) {
                        word_btns[i3].placed = true;
                    } else {
                        word_btns[i3].placed = false;
                        word_btns[i3].x = word_btns[i3].ox;
                        word_btns[i3].y = word_btns[i3].oy;
                    }
                }
            }

            var placed = [];
            for (var j = 0; j < array_length(word_btns); j++) {
                if (word_btns[j].placed) array_push(placed, word_btns[j]);
            }

            array_sort(placed, function(a, b) { return a.x - b.x; });

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
                    title_text += (p == 0) ? puzzle_target[p] : (" " + puzzle_target[p]);
                }

                inbox[corrupted_index].subject = title_text;
                inbox[corrupted_index].body =
                    "Great work. The Wi-Fi password is: \"ARCADIA-Guest-42\".\n\n" +
                    "You can now connect to proceed.";

                inbox[corrupted_index].is_corrupted = false;

                puzzle_message = "The message has been reconstructed.\n" +
                                 "Title recovered: \"" + title_text + "\"";
            }
        }
    }
}

// --- advance binary rain scroll ---
bin_scroll += bin_speed;
if (bin_scroll >= bin_cell) bin_scroll -= bin_cell;
