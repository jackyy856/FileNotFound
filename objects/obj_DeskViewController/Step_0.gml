
/// Handles editor hotkeys, capture flow, save/load, and gameplay clicks.

/// --- Overlay + timers
// Ensure panel exists and recalc if GUI size changed (handles window resize)
var current_gui_w = display_get_gui_width();
var current_gui_h = display_get_gui_height();
if (!variable_instance_exists(id, "panel_main")) {
    _init_panel();
    _recalc_layout();
} else if (current_gui_w != panel_main.w || current_gui_h != panel_main.h) {
    _init_panel();
    _recalc_layout();
}

var p = [ device_mouse_x_to_gui(0), device_mouse_y_to_gui(0) ];
if (dialog_timer > 0) dialog_timer--;

// If the intro email app is visible, let it own prompts + clicks.
// Stop this controller from showing or updating its own dialog.
if (instance_exists(obj_EmailIntro)) {
    var e = instance_find(obj_EmailIntro, 0);
    if (e.app_visible) {
        dialog_text  = "";
        dialog_timer = 0;
        exit;
    }
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
