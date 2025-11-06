/// obj_EscapeMenu — Step

// Rebuild if Create hasn't populated yet or GUI size changed
if (is_undefined(buttons_root)) { _layout(); }
if (display_get_gui_width()  != _last_gui_w || display_get_gui_height() != _last_gui_h) {
    _layout();
}

// Input snapshot
var mx  = device_mouse_x_to_gui(0);
var my  = device_mouse_y_to_gui(0);
var mbp = mouse_check_button_pressed(mb_left);

// Toggle overlay with Esc (after start menu)
if (keyboard_check_pressed(vk_escape)) {
    if (active) {
        if (state == "confirm")       state = "submenu";
        else if (state == "submenu") { state = "root"; submenu = ""; }
        else                          active = false;
    } else {
        active  = true;
        state   = "root";
        submenu = "";
    }
}

// Toast timer
if (toast_t > 0) toast_t--;

// If hidden, do nothing
if (!active) exit;

// Simple slot names for “fake” save/load toasts (kept for UX feedback)
function _slot_name(idx) {
    var key = "slot_" + string(idx);
    if (variable_global_exists(key)) return string(variable_global_get(key));
    return "Empty Save Slot";
}
function _save_to(idx) {
    var key = "slot_" + string(idx);
    variable_global_set(key, date_datetime_string(date_current_datetime()));
    toast_txt = "Saved to Slot " + string(idx);
    toast_t   = room_speed * 2;
}
function _load_from(idx) {
    var key = "slot_" + string(idx);
    if (variable_global_exists(key)) {
        active    = false;
        toast_txt = "Loaded Slot " + string(idx);
        toast_t   = room_speed * 2;
    } else {
        toast_txt = "Save slot empty";
        toast_t   = room_speed * 2;
    }
}

// ---------------- State machine ----------------
switch (state) {

    case "root": {
        if (mbp) {
            for (var i = 0; i < array_length(buttons_root); i++) {
                var b = buttons_root[i];
                if (_hit(b, mx, my)) {
                    switch (b.kind) {
                        case "load":
                            state = "submenu"; submenu = "load";
                        break;
                        case "save":
                            state = "submenu"; submenu = "save";
                        break;
                        case "settings":
                            state = "submenu"; submenu = "settings";
                        break;
                        case "mainmenu":
                            state = "confirm"; submenu = "mainmenu";
                            confirm_slot  = -1;
                            confirm_title = "Exit to Main Menu";
                            confirm_msg   = "Any unsaved progress will be lost.";
                        break;
                    }
                    break;
                }
            }
        }
    } break;

    case "submenu": {

        // universal back
        if (mbp && _hit(btn_back, mx, my)) {
            if (submenu == "settings") {
                global.master_volume = clamp(slider_val, 0, 100);
                audio_master_gain(global.master_volume / 100);
            }
            submenu = "";
            state   = "root";
            break;
        }

        if (submenu == "settings") {
            var knob_x = slider.x + (slider_val/100) * slider.w - slider.knob_w*0.5;
            var knob   = { x: knob_x, y: slider.y - 6, w: slider.knob_w, h: slider.h + 12 };

            if (mbp) {
                if (_hit(knob, mx, my)) {
                    slider.dragging = true;
                } else if (_hit({x:slider.x, y:slider.y-8, w:slider.w, h:slider.h+16}, mx, my)) {
                    var t = clamp((mx - slider.x) / slider.w, 0, 1);
                    slider_val           = round(t * 100);
                    global.master_volume = slider_val;
                    audio_master_gain(slider_val / 100);
                }
            }
            if (slider.dragging) {
                if (!mouse_check_button(mb_left)) slider.dragging = false;
                else {
                    var t2 = clamp((mx - slider.x) / slider.w, 0, 1);
                    slider_val           = round(t2 * 100);
                    global.master_volume = slider_val;
                    audio_master_gain(slider_val / 100);
                }
            }
        }
        else if (submenu == "load" || submenu == "save") {
            if (mbp) {
                for (var s = 0; s < array_length(slots); s++) {
                    var sl = slots[s];
                    if (_hit(sl, mx, my)) {
                        confirm_slot = sl.idx;
                        if (submenu == "load") {
                            var k = "slot_" + string(confirm_slot);
                            if (!variable_global_exists(k)) {
                                toast_txt = "Save slot empty";
                                toast_t   = room_speed * 2;
                            } else {
                                confirm_title = "Load this save file?";
                                confirm_msg   = _slot_name(confirm_slot);
                                state = "confirm";
                            }
                        } else { // save
                            confirm_title = "Overwrite this save file?";
                            confirm_msg   = _slot_name(confirm_slot);
                            state = "confirm";
                        }
                        break;
                    }
                }
            }
        }
    } break;

    case "confirm": {
        if (mbp) {
            var c0 = confirm_buttons[0]; // Cancel
            var c1 = confirm_buttons[1]; // Confirm
            if (_hit(c0, mx, my)) {
                if (submenu == "mainmenu") { state = "root"; submenu = ""; }
                else                        state = "submenu";
            }
            else if (_hit(c1, mx, my)) {
                if (submenu == "mainmenu") {
                    active  = false;
                    state   = "root";
                    submenu = "";
                    room_goto(room_Menu);
                }
                else if (submenu == "load") {
                    _load_from(confirm_slot);  // swap to _save_load(confirm_slot) for real loads
                    active  = false;
                    state   = "root";
                    submenu = "";
                }
                else if (submenu == "save") {
                    _save_to(confirm_slot);    // swap to _save_write(confirm_slot) for real saves
                    state   = "submenu";
                    submenu = "save";
                }
            }
        }
    } break;
}
