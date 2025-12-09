var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

if (toast_timer > 0) toast_timer--;

switch (state) {

case "main":
    if (mouse_check_button_pressed(mb_left)) {
        for (var i = 0; i < array_length(buttons); i++) {
            var b = buttons[i];
            if (_hit(b, mx, my)) {
                switch (b.kind) {
                    case "load":     state = "load";    break;
                    case "new":
                        global.flags = {};
                        lines = [
                            "You've just come home from a long day as head of financial management at Rosenwood Corporation.",
                            "...but the achiever in you is itching to check your inbox for the 76th time today."
                        ];
                        line_index = 0; visible_chars = 0; done_line = false;
                        state = "narr1";
                    break;
                    case "settings": state = "settings"; break;
                }
            }
        }
    }
break;

case "load":
    if (mouse_check_button_pressed(mb_left)) {
        if (_hit(back_btn, mx, my)) { state = "main"; break; }
        var api_ready = _ensure_save_api_ready();
        for (var s = 0; s < array_length(slots); s++) {
            var sl = slots[s];
            if (_hit(sl, mx, my)) {
                if (!api_ready) {
                    _menu_toast("Save system still initialising");
                    break;
                }

                var loaded = global.save_api.save_load(sl.idx);
                if (!loaded) {
                    var err = "Save slot empty or corrupt";
                    if (variable_global_exists("_last_save_error") && string_length(string(global._last_save_error)) > 0) {
                        err = string(global._last_save_error);
                    }
                    _menu_toast(err);
                }
                break;
            }
        }
    }
break;

case "settings":
    var knob_x = slider.x + (slider_val/100) * slider.w - slider.knob_w*0.5;
    var knob = {x:knob_x, y:slider.y - 7, w:slider.knob_w, h:slider.h + 14};

    if (mouse_check_button_pressed(mb_left)) {
        if (_hit(back_btn, mx, my)) { state = "main"; break; }
        if (_hit(knob, mx, my)) slider.dragging = true;
        else if (_hit({x:slider.x,y:slider.y-12,w:slider.w,h:slider.h+24}, mx, my)) {
            var t = clamp((mx - slider.x) / slider.w, 0, 1);
            slider_val = round(t * 100);
            audio_master_gain(slider_val/100);
            global.master_volume = slider_val;
        }
    }
    if (slider.dragging) {
        if (!mouse_check_button(mb_left)) slider.dragging = false;
        else {
            var t2 = clamp((mx - slider.x) / slider.w, 0, 1);
            slider_val = round(t2 * 100);
            audio_master_gain(slider_val/100);
            global.master_volume = slider_val;
        }
    }
break;

// narr1 and narr2 behave the same in Step; only their exit differs (handled in _advance)
case "narr1":
case "narr2":
    if (!done_line) {
        visible_chars += type_speed;
        if (visible_chars >= string_length(lines[line_index])) {
            visible_chars = string_length(lines[line_index]); 
            done_line = true;
        }
    }
    if (mouse_check_button_pressed(mb_left) || keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) {
        _advance();
    }
break;
}
