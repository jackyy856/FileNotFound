// SETTINGS — Step
var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);

function __hit(_x,_y,_w,_h){ return (_mx>=_x)&&(_my>=_y)&&(_mx<_x+_w)&&(_my<_y+_h); }

if (mouse_check_button(mb_left) && __hit(slider_x-8, slider_y-16, slider_w+16, 32)){
    var t = clamp((_mx - slider_x) / slider_w, 0, 1);
    volume = t;
    audio_master_gain(volume);
}

if (mouse_check_button_pressed(mb_left) && __hit(back_x,back_y,back_w,back_h)){
    room_goto(room_Menu);
}
