/// STEP — obj_StickyNoteApp (single-press typing + capitals, no symbols)

var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

// Drag title bar
var in_title = point_in_rect(mx, my, x1, y1, w, bar_h);

if (mouse_check_button_pressed(mb_left) && in_title && !is_minimized && !pw_modal_open) {
    dragging = true;
    drag_dx = mx - x1;
    drag_dy = my - y1;
    window_focus = true;
}
if (dragging) {
    x1 = mx - drag_dx;
    y1 = my - drag_dy;
    _recalc();
    if (!mouse_check_button(mb_left)) dragging = false;
}

// Window buttons
var bx_close_x1 = x2 - btn_pad - btn_w;
var bx_close_y1 = y1 + btn_pad;
var bx_min_x1   = bx_close_x1 - 6 - btn_w;
var bx_min_y1   = bx_close_y1;

if (!pw_modal_open && mouse_check_button_pressed(mb_left)) {
    if (point_in_rect(mx, my, bx_close_x1, bx_close_y1, btn_w, btn_h)) {
        instance_destroy();
    } else if (point_in_rect(mx, my, bx_min_x1, bx_min_y1, btn_w, btn_h)) {
        is_minimized = !is_minimized;
    }
}

// ESC: close modal first, else close app
if (keyboard_check_pressed(vk_escape)) {
    if (pw_modal_open) {
        pw_modal_open = false;
        pw_input = "";
        pw_feedback = "";
    } else {
        instance_destroy();
    }
}

// Scroll list
if (!pw_modal_open && selected_index == -1 && !is_minimized) {
    var wheel = mouse_wheel_up() - mouse_wheel_down();
    if (wheel != 0) {
        var visible_h = (content_y2 - content_y1);
        var max_scroll = max(0, array_length(notes) * row_h - visible_h);
        list_scroll = clamp(list_scroll - wheel * 24, 0, max_scroll);
    }
}

// Click list rows
if (!pw_modal_open && mouse_check_button_pressed(mb_left) && selected_index == -1 && !is_minimized) {
    var area_w = (content_x2 - content_x1);
    var area_h = (content_y2 - content_y1);
    if (point_in_rect(mx, my, content_x1, content_y1, area_w, area_h)) {
        var local_y = my - content_y1 + list_scroll;
        var idx = floor(local_y / row_h);
        if (idx >= 0 && idx < array_length(notes)) {
            var n = notes[idx];
            if (n.locked) {
                pw_modal_open = true;
                pw_note_index = idx;
                pw_input = "";
                pw_attempts = 0;
                pw_feedback = "";
            } else {
                selected_index = idx;
                notes[idx].read = true;
            }
        }
    }
}

// Back from reading view
if (!pw_modal_open && selected_index != -1 && mouse_check_button_pressed(mb_left) && !is_minimized) {
    var back_x = content_x1;
    var back_y = content_y1 - 32;
    if (point_in_rect(mx, my, back_x, back_y, 88, 24)) {
        selected_index = -1;
    }
}

// ---------- Password modal ----------
if (pw_modal_open) {
    // No keyboard_string nonsense; we handle one character per press.

    // Helper: add a single character if under length
    function _pw_add_char(ch) {
        if (string_length(pw_input) < 16) pw_input += ch;
    }

    var shift = keyboard_check(vk_shift);

    // Digits 0–9 (no symbols)
    for (var kc = 48; kc <= 57; kc++) {
        if (keyboard_check_pressed(kc)) {
            _pw_add_char(chr(kc));
        }
    }

    // Letters A–Z. Shift = uppercase, otherwise lowercase.
    for (var kc = 65; kc <= 90; kc++) {
        if (keyboard_check_pressed(kc)) {
            var ch = chr(kc);                // "A".."Z"
            if (!shift) ch = string_lower(ch);
            _pw_add_char(ch);
        }
    }

    // Backspace: remove one char per press
    if (keyboard_check_pressed(vk_backspace) && string_length(pw_input) > 0) {
        pw_input = string_copy(pw_input, 1, string_length(pw_input) - 1);
    }

    // Modal geometry
    var mw  = pw_box_w, mh = pw_box_h;
    var mx1 = x1 + (w - mw) * 0.5;
    var my1 = y1 + (h - mh) * 0.5;
    var btnW = 96, btnH = 28;

    var ok_x = mx1 + mw - btnW - 16;
    var ok_y = my1 + mh - btnH - 16;
    var cancel_x = mx1 + 16;
    var cancel_y = ok_y;

    var confirm = false;

    // Mouse clicks
    if (mouse_check_button_pressed(mb_left)) {
        if (point_in_rect(mx, my, ok_x, ok_y, btnW, btnH)) {
            confirm = true;
        } else if (point_in_rect(mx, my, cancel_x, cancel_y, btnW, btnH)) {
            pw_modal_open = false; pw_input = ""; pw_feedback = "";
        }
    }
    // Enter confirms
    if (keyboard_check_pressed(vk_enter)) confirm = true;

    // Check password
    if (confirm) {
        var n = notes[pw_note_index];
        if (string_lower(pw_input) == string_lower(n.password)) {
            notes[pw_note_index].locked = false;
            notes[pw_note_index].read   = true;
            selected_index = pw_note_index;
            pw_modal_open = false; pw_input = ""; pw_feedback = "";
        } else {
            pw_attempts += 1;
            pw_feedback = "Incorrect.";
            if (pw_attempts >= pw_max_attempts) {
                pw_modal_open = false;
                alarm[0] = room_speed * 2; // short cooldown
            }
        }
    }
}
