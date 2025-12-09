
/// Handles editor hotkeys, capture flow, save/load, and gameplay clicks.

/// --- Monitor edit (F1): Arrows move, Shift+W/A/S/D resize
if (keyboard_check_pressed(vk_f1)) edit_monitor = !edit_monitor;

if (edit_monitor) {
    var moved = false;

    if (keyboard_check(vk_left))  { MON_X -= 1; moved = true; }
    if (keyboard_check(vk_right)) { MON_X += 1; moved = true; }
    if (keyboard_check(vk_up))    { MON_Y -= 1; moved = true; }
    if (keyboard_check(vk_down))  { MON_Y += 1; moved = true; }

    var s = keyboard_check(vk_shift) ? 2 : 0;
    if (s > 0) {
        if (keyboard_check(ord("A"))) { MON_W -= s; moved = true; }
        if (keyboard_check(ord("D"))) { MON_W += s; moved = true; }
        if (keyboard_check(ord("W"))) { MON_H -= s; moved = true; }
        if (keyboard_check(ord("S"))) { MON_H += s; moved = true; }
    }
    if (moved) _recalc_layout();
}

/// --- Manual hotspot capture (1..5) – disabled during guided run
if (!guided_mode) {
    if (keyboard_check_pressed(ord("1"))) _capture_begin(1);
    if (keyboard_check_pressed(ord("2"))) _capture_begin(2);
    if (keyboard_check_pressed(ord("3"))) _capture_begin(3);
    if (keyboard_check_pressed(ord("4"))) _capture_begin(4);
    if (keyboard_check_pressed(ord("5"))) _capture_begin(5);
}


/// --- Capture click handling (consumes mouse; blocks gameplay clicks)
if (capture_mode && mouse_check_button_pressed(mb_left)) {
    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);

    if (is_undefined(capture_first)) {
        capture_first = [_mx, _my];
        show_prompt("Now click BOTTOM-RIGHT");
        exit;
    } else {
        var rect = _rect_from_points(capture_first, [_mx, _my]);
        switch (capture_target) {
            case 1: BTN_EMAIL_ICON = rect; break;
            case 2: BTN_BACK       = rect; break;
            case 3: BTN_CLOSEX     = rect; break;
            case 4: BTN_PHISH_SUBJ = rect; break;
            case 5: BTN_PHISH_LINK = rect; break;
        }
        capture_mode   = false;
        capture_target = -1;
        capture_first  = undefined;
        capture_completed = true;
        show_prompt("Capture saved");
        exit;
    }
}

/// --- Cancel capture (Esc)
if (capture_mode && keyboard_check_pressed(vk_escape)) {
    capture_mode = false; capture_target = -1; capture_first = undefined;
    capture_completed = false;
    show_prompt("Capture cancelled");
    if (guided_mode) _capture_begin(guided_ids[guided_idx]); // re-ask same item
}

/// --- Overlay + timers
// Recalculate panel if GUI size changed (handles window resize)
var current_gui_w = display_get_gui_width();
var current_gui_h = display_get_gui_height();
if (current_gui_w != panel_main.w || current_gui_h != panel_main.h) {
    _init_panel();
    _recalc_layout();
}

var p = [ device_mouse_x_to_gui(0), device_mouse_y_to_gui(0) ];
if (dialog_timer > 0) dialog_timer--;
if (keyboard_check_pressed(vk_f6)) { if (_load_layout()) show_prompt("Layout loaded"); else show_prompt("No saved layout"); }
if (keyboard_check_pressed(vk_f7)) { MON_X = 240; MON_Y = 110; MON_W = 1440; MON_H = 810; _recalc_layout(); show_prompt("Layout reset"); }

/// --- Guided auto-advance
if (guided_mode && capture_completed && !capture_mode) {
    capture_completed = false;
    _guided_advance();
}

/// --- Gameplay clicks (blocked while capturing/guided)
if (!capture_mode && !guided_mode && mouse_check_button_pressed(mb_left)) {
    switch (state) {
        case DeskState.DESK: {
            if (_in_rect(p, BTN_EMAIL_ICON)) state = DeskState.EMAIL_LIST;
            else show_prompt("I should check my email.");
        } break;

        case DeskState.EMAIL_LIST: {
            // Back is intentionally not present on the Email List PNG
            if (_in_rect(p, BTN_CLOSEX)) { state = DeskState.DESK; break; }
            if (_in_rect(p, BTN_PHISH_SUBJ)) state = DeskState.EMAIL_OPEN;
            else show_prompt("Congratulations…? Another $15 gift card from Shelby over at Systems, I presume…");
        } break;

        case DeskState.EMAIL_OPEN: {
            if (_in_rect(p, BTN_BACK))   { state = DeskState.EMAIL_LIST; break; }
            if (_in_rect(p, BTN_CLOSEX)) { state = DeskState.DESK;       break; }

            if (_in_rect(p, BTN_PHISH_LINK)) {
                // >>> Handoff to Menu for Black Narration Screen 2 <<<
                // obj_MenuController should detect these globals and start narr2.
                global._queued_narr_lines = [
                    "What just happened?",
                    "Oh right... that tech intern warned you about random links...",
                    "multiple times..."
                ];
                global._queued_narr_state = "narr2";
                room_goto(room_Menu);
            } else {
                show_prompt("Are you kidding? It’s about time I got rewarded for my work.");
            }
        } break;
    }
}
