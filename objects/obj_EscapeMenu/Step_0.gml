/// obj_EscapeMenu — Step (closure-free)

var mx  = device_mouse_x_to_gui(0);
var my  = device_mouse_y_to_gui(0);
var mbp = mouse_check_button_pressed(mb_left);

function _hit_xy(r, _mx, _my) {
    return (_mx >= r.x) && (_my >= r.y) && (_mx < r.x + r.w) && (_my < r.y + r.h);
}

// keep layout sane if GUI size changed
if (display_get_gui_width() != _last_gui_w || display_get_gui_height() != _last_gui_h) {
    _layout();
}

// ESC toggle
if (keyboard_check_pressed(vk_escape)) {
    if (active) {
        if (state == "confirm") state = "submenu";
        else if (state == "submenu") { state = "root"; submenu = ""; }
        else active = false;
    } else {
        active = true; state = "root"; submenu = "";
    }
}

// toast timer
if (toast_t > 0) toast_t--;

// closed? bail
if (!active) exit;

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

        // back
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
                    active = false; state = "root"; submenu = "";
                    room_goto(room_Menu);   // we’ll spawn MenuController on Room Start
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

// don’t leak clicks into the game
mouse_clear(mb_left);
keyboard_clear(vk_escape);
