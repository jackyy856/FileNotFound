/// obj_EmailApp - Step

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

// ------------------ CLOSE / MINIMIZE / BACK ------------------
if (mouse_check_button_pressed(mb_left)) {
    // Check if in puzzle mode for back button (only if we have valid selection)
    if (selected_index >= 0 && selected_index < array_length(inbox)) {
        var em_check = inbox[selected_index];
        var _em_cor = variable_struct_exists(em_check, "is_corrupted") && em_check.is_corrupted;
        
        if (_em_cor && puzzle_active && !puzzle_solved) {
            // Puzzle view back button (in header)
            var puzzle_back_btn_x = window_x + window_w - (30 * 4) - 20;
            var puzzle_back_btn_y = window_y + (header_h - 26) / 2;
            var puzzle_back_btn_w = 70;
            var puzzle_back_btn_h = 26;
            
            if (mx >= puzzle_back_btn_x && mx < puzzle_back_btn_x + puzzle_back_btn_w &&
                my >= puzzle_back_btn_y && my < puzzle_back_btn_y + puzzle_back_btn_h) {
                selected_index = -1;
                puzzle_active = false;
                puzzle_hint_timer = 0;
                puzzle_show_hint = false;
                exit;
            }
        }
    }
            
            // close (X)
            if (over_close) {
                instance_destroy();
                exit;
            }
            // minimize (-)
            if (over_min) {
                is_minimized = !is_minimized;
                exit;
            }
        }

// If minimized: do not process content UI below
if (is_minimized) {
    // advance binary rain lightly to keep animation coherent if you still draw it
    bin_scroll += bin_speed;
    if (bin_scroll >= bin_cell) bin_scroll -= bin_cell;
    // also reset hint timer while hidden
    puzzle_hint_timer = 0;
    puzzle_show_hint = false;
    exit;
}

// if email is locked: window works, but no content
if (email_locked) {
    // check if wifi puzzle has been solved while this window is open
    if (variable_global_exists("wifi_ever_connected") && global.wifi_ever_connected) {
        email_locked = false;
    } else {
        // still locked, bail out
        exit;
    }
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
        
        // Find actual email index (accounting for filtered emails)
        var visible_count = 0;
        var actual_idx = -1;
        for (var i = 0; i < len; i++) {
            var show_in_inbox = variable_struct_exists(inbox[i], "show_in_inbox") ? inbox[i].show_in_inbox : true;
            if (show_in_inbox) {
                if (visible_count == idx) {
                    actual_idx = i;
                    break;
                }
                visible_count++;
            }
        }
        
        if (actual_idx >= 0 && actual_idx < len) {
            selected_index = actual_idx;
            inbox[actual_idx].read = true;
            thread_scroll = 0; // Reset scroll when opening new email

            // unlock messenger if suspicious
	    if (inbox[actual_idx].is_suspicious) {
		    if (!is_undefined(global.apps_unlocked) && is_struct(global.apps_unlocked)) {
		        global.apps_unlocked.HackerMsgr = true;
		    }
		}


            if (actual_idx == corrupted_index) {
                puzzle_active     = puzzle_gate && !puzzle_solved;
                puzzle_hint_timer = 0;
                puzzle_show_hint  = false;
            } else {
                puzzle_active     = false;
                puzzle_hint_timer = 0;
                puzzle_show_hint  = false;
            }
        }
    }
} else {
    // Thread view scrollbar
    var em = inbox[selected_index];
    var is_thread = variable_struct_exists(em, "thread_id") && em.thread_id != undefined;
    
    // Handle scrollbar for both single emails and threads
    var tab_h = 48;
    var back_btn_bottom = back_btn[1] + back_btn[3];
    var safe_start_y = max(back_btn_bottom + 15, window_y + header_h + tab_h + 15);
    var tx = window_x + 20;
    var ty = safe_start_y;
    var body_w = window_w - 40;
    
    var is_thread = variable_struct_exists(em, "thread_id") && em.thread_id != undefined;
    var total_h = 0;
    
    if (is_thread) {
        // Calculate thread height
        var thread = (variable_struct_exists(em, "thread_id") ? em.thread_id : em.id);
        var chain = [];
        for (var i = 0; i < array_length(inbox); i++) {
            if (variable_struct_exists(inbox[i], "thread_id")) {
                if (inbox[i].thread_id == thread) {
                    array_push(chain, inbox[i]);
                }
            }
        }
        
        if (array_length(chain) > 1) {
            // Calculate with tentative body_w first
            var tentative_body_w = window_w - 40;
            for (var m = 0; m < array_length(chain); m++) {
                total_h += 26 + 26 + 26 + 34; // subject + from + to + sent spacing
                total_h += string_height_ext(chain[m].body, 12, tentative_body_w) + 22;
                if (m < array_length(chain) - 1) total_h += 24; // divider
            }
            // Adjust body_w if scrollbar needed
            var visible_h = window_y + window_h - 40 - ty;
            if (total_h > visible_h) {
                body_w = window_w - 40 - 12 - 8 - 20; // Account for scrollbar
                // Recalculate with adjusted width
                total_h = 0;
                for (var m2 = 0; m2 < array_length(chain); m2++) {
                    total_h += 26 + 26 + 26 + 34;
                    total_h += string_height_ext(chain[m2].body, 12, body_w) + 22;
                    if (m2 < array_length(chain) - 1) total_h += 24;
                }
            }
        }
    } else {
        // Single email - calculate height (already handled in Draw, but need for scrollbar)
        total_h += 30; // subject
        total_h += 30; // from
        var has_to = variable_struct_exists(em, "to") && em.to != "";
        if (has_to) total_h += 30; // to
        total_h += 60; // spacing
        total_h += string_height_ext(em.body, 12, body_w); // body
    }
    
    if (total_h > 0) {
        var visible_h = window_y + window_h - 40 - ty;
        var scroll_max = max(0, total_h - visible_h);
        
        // Mouse wheel scrolling for both single emails and threads
        var scroll_delta = 0;
        if (mouse_wheel_up())   scroll_delta -= 30;
        if (mouse_wheel_down()) scroll_delta += 30;
        
        if (scroll_delta != 0 && mx >= window_x && mx < window_x + window_w && 
            my >= window_y + header_h && my < window_y + window_h) {
            thread_scroll += scroll_delta;
            thread_scroll = clamp(thread_scroll, 0, scroll_max);
        }
    }
    
    if (mouse_check_button_pressed(mb_left)) {
        if (over_back) {
            selected_index    = -1;
            puzzle_active     = false;
            puzzle_hint_timer = 0;
            puzzle_show_hint  = false;
            thread_scroll     = 0; // Reset scroll when going back
        }
    }
}

// ------------------ PUZZLE DnD (LOCAL) ------------------
if (selected_index != -1) {
    var em = inbox[selected_index];
    var _em_cor = variable_struct_exists(em,"is_corrupted") && em.is_corrupted;

    // Modal OK (LOCAL) when solved (no actual modal now, but keep block)
    if (_em_cor && puzzle_solved) {
        if (mouse_check_button_pressed(mb_left)) {
            var bx = ok_btn_local[0], by = ok_btn_local[1], bw = ok_btn_local[2], bh = ok_btn_local[3];
            if (in_local(mx_local, my_local, bx, by, bw, bh)) {
                // dismiss modal (email already flipped to normal in success block)
            }
        }
        // still advance binary rain
        bin_scroll += bin_speed;
        if (bin_scroll >= bin_cell) bin_scroll -= bin_cell;
        // hint not needed after solved
        puzzle_hint_timer = 0;
        puzzle_show_hint  = false;
        exit;
    }

    if (_em_cor && puzzle_active) {
        // START DRAG - allow dragging even if placed (so player can rearrange)
        if (mouse_check_button_pressed(mb_left)) {
            for (var i = array_length(word_btns)-1; i >= 0; i--) {
                var b = word_btns[i];
                // Check if mouse is over button (whether placed or not)
                if (in_local(mx_local, my_local, b.x, b.y, b.w, b.h)) {
                    b.dragging  = true;
                    b.dx        = mx_local - b.x;
                    b.dy        = my_local - b.y;
                    // Clear placement when starting to drag
                    b.placed    = false;
                    b.slot_index= -1;
                    word_btns[i]= b;
                    break;
                }
            }
        }

        // DRAG
        if (mouse_check_button(mb_left)) {
            for (var i2 = 0; i2 < array_length(word_btns); i2++) if (word_btns[i2].dragging) {
                word_btns[i2].x = mx_local - word_btns[i2].dx;
                word_btns[i2].y = my_local - word_btns[i2].dy;
            }
        }

        // DROP
        if (mouse_check_button_released(mb_left)) {
            for (var i3 = 0; i3 < array_length(word_btns); i3++) if (word_btns[i3].dragging) {
                word_btns[i3].dragging = false;

                var inside = in_local(
                    mx_local, my_local,
                    puzzle_area_local.x, puzzle_area_local.y,
                    puzzle_area_local.w, puzzle_area_local.h
                );

                if (inside) {
                    var snapped = false;

                    var slot_len = array_length(puzzle_slots);
                    if (slot_len > 0) {
                        var best_slot = 0;
                        var best_dist = 1000000000;

                        // compare tile's current x with each slot.x
                        for (var s = 0; s < slot_len; s++) {
                            var sx = puzzle_slots[s].x;
                            var d  = abs(word_btns[i3].x - sx);
                            if (d < best_dist) {
                                best_dist = d;
                                best_slot = s;
                            }
                        }

                        // check if that slot is already taken by another tile
                        var slot_taken = false;
                        for (var k = 0; k < array_length(word_btns); k++) {
                            if (k != i3) {
                                var wb2 = word_btns[k];
                                if (wb2.placed && wb2.slot_index == best_slot) {
                                    slot_taken = true;
                                    break;
                                }
                            }
                        }

                        if (!slot_taken) {
                            // snap into that slot
                            word_btns[i3].placed     = true;
                            word_btns[i3].slot_index = best_slot;
                            word_btns[i3].x          = puzzle_slots[best_slot].x;
                            word_btns[i3].y          = puzzle_slots[best_slot].y;
                            snapped = true;
                        }
                    }

                    // if couldn't snap (slot taken or no slots), return to bottom
                    if (!snapped) {
                        word_btns[i3].placed     = false;
                        word_btns[i3].slot_index = -1;
                        word_btns[i3].x          = word_btns[i3].ox;
                        word_btns[i3].y          = word_btns[i3].oy;
                    }
                } else {
                    // dropped outside puzzle box → return to bottom
                    word_btns[i3].placed     = false;
                    word_btns[i3].slot_index = -1;
                    word_btns[i3].x          = word_btns[i3].ox;
                    word_btns[i3].y          = word_btns[i3].oy;
                }
            }

            // Validate order based on slots
            var slots_n        = array_length(puzzle_target);
            var slot_word_texts= array_create(slots_n, undefined);
            var slot_tile_index= array_create(slots_n, -1);
            var slot_filled    = 0;

            for (var j = 0; j < array_length(word_btns); j++) {
                var wb = word_btns[j];
                if (wb.placed && wb.slot_index >= 0 && wb.slot_index < slots_n) {
                    slot_filled++;
                    slot_word_texts[wb.slot_index] = wb.text;
                    slot_tile_index[wb.slot_index] = j;
                }
            }

            var ok = (slot_filled == slots_n);
            if (ok) {
                // text order check
                for (var t = 0; t < slots_n; t++) {
                    if (is_undefined(slot_word_texts[t]) || slot_word_texts[t] != puzzle_target[t]) {
                        ok = false;
                        break;
                    }
                }
            }

            if (ok) {
                puzzle_solved  = true;
                puzzle_active  = false;

                var title_text = "";
                for (var q = 0; q < array_length(puzzle_target); q++) {
                    title_text += (q==0)? puzzle_target[q] : (" " + puzzle_target[q]);
                }

                inbox[corrupted_index].subject = title_text;
                inbox[corrupted_index].body =
                    "It does.\n\nHere's your first key sucker.";
                // Add missing fields that Draw expects
                if (!variable_struct_exists(inbox[corrupted_index], "to")) {
                    inbox[corrupted_index].to = "";
                }
                if (!variable_struct_exists(inbox[corrupted_index], "from")) {
                    inbox[corrupted_index].from = "System";
                }

                inbox[corrupted_index].is_corrupted = false;

                puzzle_message = "The message has been reconstructed.\n" +
                                 "Real subject: \"" + title_text + "\"";

                // reset hint state
                puzzle_hint_timer = 0;
                puzzle_show_hint  = false;
            }
        }
    }
}


// ------------------ HINT TIMER (20s on corrupted puzzle) ------------------
if (selected_index == corrupted_index && puzzle_active && !puzzle_solved) {
    puzzle_hint_timer += 1;
    if (puzzle_hint_timer >= room_speed * 20) {
        puzzle_show_hint = true;
    }
} else if (!puzzle_solved) {
    // reset if not actively puzzling
    puzzle_hint_timer = 0;
    puzzle_show_hint  = false;
}

// ------------------ CLICKABLE KEY (first key reward) ------------------
if (selected_index == corrupted_index && puzzle_solved && !email_key1_collected) {
    if (mouse_check_button_pressed(mb_left)) {
        var kx = email_key1_rect[0];
        var ky = email_key1_rect[1];
        var kw = email_key1_rect[2];
        var kh = email_key1_rect[3];

        if (mx >= kx && my >= ky && mx <= kx + kw && my <= ky + kh) {
            // mark collected
            email_key1_collected = true;

            // play key SFX immediately
            audio_play_sound(sfx_keywow, 1, false);

            // ensure global key array exists
            if (!variable_global_exists("key_collected")) {
                global.key_collected = array_create(3, false);
            }
            global.key_collected[0] = true;  // first key obtained

            // unlock Calendar app
            if (!variable_global_exists("apps_unlocked")) {
                global.apps_unlocked = {
                    Email      : true,
                    HackerMsgr : true,
                    Calendar   : false,
                    Files      : false,
                    Gallery    : false,
                    RecycleBin : false,
                    Notes      : true,
                    Slack      : false
                };
            }
            global.apps_unlocked.Calendar = true;

            // start 2.5s delay before hacker reacts
            key1_hacker_delay = room_speed * 2.5;
        }
    }
}

// ------------------ DELAYED HACKER NOTIF AFTER KEY #1 ------------------
if (key1_hacker_delay > 0) {
    key1_hacker_delay -= 1;
    if (key1_hacker_delay <= 0) {
        // safety init
        if (!variable_global_exists("hacker_key1_hint_pending")) {
            global.hacker_key1_hint_pending = false;
        }

        // trigger hacker sequence once
        if (!global.hacker_key1_hint_pending) {
            global.hacker_key1_hint_pending = true;
        }
    }
}



// advance binary rain
bin_scroll += bin_speed;
if (bin_scroll >= bin_cell) bin_scroll -= bin_cell;
