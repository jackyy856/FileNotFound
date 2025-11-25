/// obj_EscapeMenu — Step (edge-latched mouse + ESC; safe clearing)

var mx  = mx_gui;           // use cached GUI coords from Begin Step
var my  = my_gui;
var mbp = mb_left_edge;     // use latched click edge from Begin Step

function _hit_xy(r, _mx, _my) {
    return (_mx >= r.x) && (_my >= r.y) && (_mx < r.x + r.w) && (_my < r.y + r.h);
}

// Keep layout sane if GUI size changed
if (display_get_gui_width() != _last_gui_w || display_get_gui_height() != _last_gui_h) {
    _layout();
}

// ---------- ESC toggle (use latched edge from Begin Step) ----------
if (esc_edge) {
    if (active) {
        if (state == "confirm") state = "submenu";
        else if (state == "submenu") { state = "root"; submenu = ""; }
        else active = false;
    } else {
        active = true; state = "root"; submenu = "";
    }
}

// Toast timer
if (toast_t > 0) toast_t--;

// Closed? Bail
if (!active) {
    global.pause_menu_active = false;
    exit;
}

switch (state) {

    case "root": {
        if (mbp) {
            for (var i = 0; i < array_length(buttons_root); i++) {
                var b = buttons_root[i];
                if (_hit_xy(b, mx, my)) {
                    switch (b.kind) {
                        case "load":      state = "submenu"; submenu = "load";      break;
                        case "save":      state = "submenu"; submenu = "save";      break;
                        case "settings":  state = "submenu"; submenu = "settings";  break;
                        case "mainmenu":
                            state = "confirm"; submenu = "mainmenu"; confirm_slot = -1;
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

        // Back
        if (mbp && _hit_xy(btn_back, mx, my)) {
            if (submenu == "settings") {
                global.master_volume = clamp(slider_val, 0, 100);
                audio_master_gain(global.master_volume / 100);
            }
            submenu = ""; state = "root";
            break;
        }

        if (submenu == "settings") {
            var knob_x = slider.x + (slider_val/100) * slider.w - slider.knob_w*0.5;
            var knob   = { x: knob_x, y: slider.y - 6, w: slider.knob_w, h: slider.h + 12 };

            if (mbp) {
                var rail = { x:slider.x, y:slider.y-8, w:slider.w, h:slider.h+16 };
                if (_hit_xy(knob, mx, my)) {
                    slider.dragging = true;
                } else if (_hit_xy(rail, mx, my)) {
                    var t = clamp((mx - slider.x) / slider.w, 0, 1);
                    slider_val           = round(t * 100);
                    global.master_volume = slider_val;
                    audio_master_gain(slider_val / 100);
                }
            }
            // drag uses continuous button state (kept as-is)
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
                    if (_hit_xy(sl, mx, my)) {
                        confirm_slot = sl.idx;
                        if (submenu == "load") {
                            var f = _slot_file(confirm_slot);
                            if (!file_exists(f)) { _toast("Save slot empty"); }
                            else {
                                state = "confirm";
                                confirm_title = "Load Save File";
                                confirm_msg   = "Load this save file?";
                            }
                        } else {
                            state = "confirm";
                            confirm_title = "Save Game";
                            confirm_msg   = "Overwrite this save slot?";
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
            if (_hit_xy(c0, mx, my)) {
                if (submenu == "mainmenu") { state = "root"; submenu = ""; }
                else state = "submenu";
            }
            else if (_hit_xy(c1, mx, my)) {
                if (submenu == "mainmenu") {
                    // Harden against stray controllers that redirect out of Menu
                    with (Obj_logincontrol) { alarm[0] = -1; instance_destroy(); }
                    with (obj_SaveSelectController) instance_destroy();
                    with (obj_SettingsController)   instance_destroy();

                    active = false; state = "root"; submenu = "";
                    var R = is_undefined(_menu_room) ? room : _menu_room();
                    room_goto(R);
                }
                else if (submenu == "load") {
                    if (_save_load(confirm_slot)) { active = false; state = "root"; submenu = ""; }
                    else { state = "submenu"; _toast("Save slot empty or corrupt"); }
                }
                else if (submenu == "save") {
                    _save_write(confirm_slot);
                    _toast("Saved");
                    state   = "submenu";
                    submenu = "save";
                }
            }
        }
    } break;

    case "toast": {
        if (toast_t <= 0) state = "root";
    } break;
}

// Swallow this frame’s inputs *after* handling
if (mbp) mouse_clear(mb_left);       // only clear if we actually used the click
if (esc_edge) keyboard_clear(vk_escape); // only clear when we used ESC
