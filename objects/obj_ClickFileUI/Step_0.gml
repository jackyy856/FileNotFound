/// obj_ClickFileUI - Step

var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

// Only react on actual clicks
if (!mouse_check_button_pressed(mb_left)) {
    exit;
}

var cx = 1920 * 0.5;
var cy = 1080 * 0.5;
var bw = 220;
var bh = 50;

// Countdown while on initial prompt
if (mode == 0 && !lose_triggered) {
    timer_frames = max(0, timer_frames - 1);
    if (timer_frames <= 0) {
        lose_triggered = true;
        result = "lose";
        global.file_minigame_result = "lose";
        mode = 3;
    }
}

if (mode == 0) {
    // Delete / Share buttons
    var btn_y = cy + 40;

    var del_x1   = cx - bw - 20;
    var del_x2   = del_x1 + bw;
    var share_x1 = cx + 20;
    var share_x2 = share_x1 + bw;

    if (mx >= del_x1 && mx <= del_x2 && my >= btn_y && my <= btn_y + bh) {
        // clicked Delete -> go to "Are you sure?"
        mode = 1;
        lose_triggered = false;
        timer_frames = room_speed * 5;
    }
    else if (mx >= share_x1 && mx <= share_x2 && my >= btn_y && my <= btn_y + bh) {
        // clicked Share -> go to Share screen
        mode = 2;
        lose_triggered = false;
        timer_frames = room_speed * 5;
    }
}
else if (mode == 1) {
    // "Are you sure?" Yes / Cancel
    var btn_y = cy + 40;

    var yes_x1 = cx - bw - 20;
    var yes_x2 = yes_x1 + bw;
    var no_x1  = cx + 20;
    var no_x2  = no_x1 + bw;

    if (mx >= yes_x1 && mx <= yes_x2 && my >= btn_y && my <= btn_y + bh) {
        // Yes -> delete the file instance and finish
        if (instance_exists(target_inst)) {
            with (target_inst) instance_destroy();
        }
        result = "deleted";
        global.file_minigame_result = "deleted";
        mode   = 3;
    }
    else if (mx >= no_x1 && mx <= no_x2 && my >= btn_y && my <= btn_y + bh) {
        // Cancel -> back to Delete / Share
        mode = 0;
        lose_triggered = false;
        timer_frames = room_speed * 5;
    }
}
else if (mode == 2) {
    // Share to Hacker + Cancel
    var btn_y = cy + 40;

    var share_x1  = cx - bw - 20;
    var share_x2  = share_x1 + bw;
    var cancel_x1 = cx + 20;
    var cancel_x2 = cancel_x1 + bw;

    if (mx >= share_x1 && mx <= share_x2 && my >= btn_y && my <= btn_y + bh) {
        // Actually share
        result = "shared";
        global.file_minigame_result = "shared";
        mode   = 3;
    }
    else if (mx >= cancel_x1 && mx <= cancel_x2 && my >= btn_y && my <= btn_y + bh) {
        // Cancel -> back to Delete / Share
        mode = 0;
        lose_triggered = false;
        timer_frames = room_speed * 5;
    }
}
else if (mode == 3) {
    // "Go back" after result
    var btn_y  = cy + 60;
    var back_x1 = cx - bw * 0.5;
    var back_x2 = cx + bw * 0.5;

    if (mx >= back_x1 && mx <= back_x2 && my >= btn_y && my <= btn_y + bh) {
        // Go to Credits room; ending sequence runs there
        room_goto(room_Credits);
    }
}


