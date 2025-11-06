// --- mouse in GUI space ---
var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

// --- small helper ---
function point_in_rect(px, py, x, y, w, h) {
    return (px >= x) && (py >= y) && (px < x + w) && (py < y + h);
}

// close button
if (mouse_check_button_pressed(mb_left)) {
    if (point_in_rect(mx, my, close_btn[0], close_btn[1], close_btn[2], close_btn[3])) {
        instance_destroy();
        exit;
    }
}

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
	    // Derive from CURRENT window geometry (GUI coords)
	    var rx = window_x + 12;
	    var ry = window_y + header_h + 8;
	    var rw = window_w - 24;
	    var rh = window_h - header_h - 80;

	    // Scatter within the BOTTOM slice of the rain area
	    var region_h = clamp(ceil(rh * 0.35), 80, rh - 40);

	    // Compute integer bounds to keep irandom_range happy
	    var minx = floor(rx + 8);
	    var maxx = floor(rx + rw - word_btn_w - 8);
	    var miny = floor(ry + rh - region_h);
	    var maxy = floor(ry + rh - word_btn_h - 8);

	    // Fallback: if bounds collapse for any reason, fall back to inside the puzzle_area bottom
	    if (maxx < minx || maxy < miny) {
	        minx = floor(puzzle_area.x + 8);
	        maxx = floor(puzzle_area.x + puzzle_area.w - word_btn_w - 8);
	        miny = floor(puzzle_area.y + puzzle_area.h + 8);
	        maxy = floor(ry + rh - word_btn_h - 8);
	        if (maxx < minx) { var _tx = minx; minx = maxx; maxx = _tx; }
	        if (maxy < miny) { var _ty = miny; miny = maxy; maxy = _ty; }
	    }

	    // Final guard (hard clamp into GUI space)
	    minx = max(0, minx); miny = max(0, miny);

	    for (var s = 0; s < array_length(word_btns); s++) {
	        var rxpos = irandom_range(minx, maxx);
	        var rypos = irandom_range(miny, maxy);

	        // Set BOTH current position and snap-back origin to the scattered spots
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
            var mx = device_mouse_x_to_gui(0);
            var my = device_mouse_y_to_gui(0);
            if (mx >= ok_btn[0] && mx <= ok_btn[0]+ok_btn[2] &&
                my >= ok_btn[1] && my <= ok_btn[1]+ok_btn[3]) {
                // Dismiss modal -> remain on recovered email
                // Optional: selected_index = -1;
            }
        }
        exit; // don't allow interacting with buttons under modal
    }

    if (_em_cor && puzzle_active) {
        var mx = device_mouse_x_to_gui(0);
        var my = device_mouse_y_to_gui(0);

        // START DRAG: pick topmost button under cursor
        if (mouse_check_button_pressed(mb_left)) {
            for (var i = array_length(word_btns)-1; i >= 0; i--) {
                var b = word_btns[i];
                if (point_in_rect(mx, my, b.x, b.y, b.w, b.h)) {
                    word_btns[i].dragging = true;
                    word_btns[i].dx = mx - b.x;
                    word_btns[i].dy = my - b.y;
                    word_btns[i].placed = false; // remove from placed while grabbing
                    break;
                }
            }
        }

        // DRAGGING: follow cursor
        if (mouse_check_button(mb_left)) {
            for (var i = 0; i < array_length(word_btns); i++) {
                if (word_btns[i].dragging) {
                    word_btns[i].x = mx - word_btns[i].dx;
                    word_btns[i].y = my - word_btns[i].dy;
                }
            }
        }

        // DROP: snap to area or snap-back
        if (mouse_check_button_released(mb_left)) {
            for (var i = 0; i < array_length(word_btns); i++) {
                if (word_btns[i].dragging) {
                    word_btns[i].dragging = false;

                    var inside = point_in_rect(
                        mx, my,
                        puzzle_area.x, puzzle_area.y, puzzle_area.w, puzzle_area.h
                    );

                    if (inside) {
                        word_btns[i].placed = true;
                        // Let it sit wherever dropped; we validate by x-order
                    } else {
                        word_btns[i].placed = false;
                        // Snap back to the scattered origin
                        word_btns[i].x = word_btns[i].ox;
                        word_btns[i].y = word_btns[i].oy;
                    }
                }
            }

            // After any drop, recompute order of placed words and validate
            var placed = [];
            for (var j = 0; j < array_length(word_btns); j++) {
                if (word_btns[j].placed) {
                    array_push(placed, word_btns[j]);
                }
            }

            // sort placed by x (left -> right)
            array_sort(placed, function(a, b) { return a.x - b.x; });

            // Build placed text array
            var placed_texts = [];
            for (var k = 0; k < array_length(placed); k++) {
                array_push(placed_texts, placed[k].text);
            }

            // Validation: exactly matches target, no other words
            var ok = (array_length(placed_texts) == array_length(puzzle_target));
            if (ok) {
                for (var t = 0; t < array_length(puzzle_target); t++) {
                    if (placed_texts[t] != puzzle_target[t]) { ok = false; break; }
                }
            }

            if (ok) {
                // --- SOLVED ---
                puzzle_solved  = true;
                puzzle_active  = false;

                // join puzzle_target with spaces to form the recovered title
                var title_text = "";
                for (var p = 0; p < array_length(puzzle_target); p++) {
                    title_text += (p == 0) ? puzzle_target[p] : (" " + puzzle_target[p]);
                }

                // Update email title/body
                inbox[corrupted_index].subject = title_text;
                inbox[corrupted_index].body =
                    "Great work. The Wi-Fi password is: \"ARCADIA-Guest-42\".\n\n" +
                    "You can now connect to proceed."; // TODO: replace with your real text

                // Turn off corruption so red ⚠️ and green subject go away automatically
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
