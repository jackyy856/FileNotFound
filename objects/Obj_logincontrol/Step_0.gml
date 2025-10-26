// Check for Enter key press
if (keyboard_check_pressed(vk_enter)) {
    if (password_box.text == correct_password) {
        global.username = "Boss";
        room_goto(room_Desktop);
    } else {
        login_message = "Incorrect!";
    }
}

// Check for hint click at (920, 630)
if (mouse_check_button_pressed(mb_left)) {
    var mx = mouse_x;
    var my = mouse_y;
    
    // Check if clicking hint area around (920, 630)
    if (mx >= hint_x && mx <= hint_x + hint_width && my >= hint_y && my <= hint_y + hint_height) {
        hint_clicked = !hint_clicked; // Toggle hint state
    }
}