/// obj_BlackNarrationBase: Step
if (line_i < array_length(lines)) {
    var target = string(lines[line_i]);
    if (char_i < string_length(target)) {
        char_i += spd;
        typed = string_copy(target, 1, floor(char_i));
        _ready_for_click = false;
    } else {
        _ready_for_click = true;
        if (mouse_check_button_pressed(mb_left)) {
            line_i++; char_i = 0; typed = "";
        }
    }
} else {
    if (mouse_check_button_pressed(mb_left)) {
        room_goto(next_room);
    }
}
