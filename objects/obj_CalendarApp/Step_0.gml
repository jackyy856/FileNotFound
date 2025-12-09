/// obj_CalendarApp - Step

var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);
var mx_local = mx - window_x;
var my_local = my - window_y;

function in_local(px, py, x, y, w, h) {
    return (px >= x) && (py >= y) && (px < x + w) && (py < y + h);
}

// recompute button rects if window moved
var btn_size = close_btn[2]; // 30
var btn_y    = window_y + (header_h - btn_size) / 2;

var min_x1   = window_x + window_w - (btn_size * 2) - 8;
var close_x1 = window_x + window_w - btn_size - 4;

min_btn[0] = min_x1;
min_btn[1] = btn_y;

close_btn[0] = close_x1;
close_btn[1] = btn_y;

// title bar region
var in_titlebar = in_local(mx_local, my_local, 0, 0, window_w, header_h);

// button hover
var over_close = in_local(mx, my, close_btn[0], close_btn[1], close_btn[2], close_btn[3]);
var over_min   = in_local(mx, my, min_btn[0],   min_btn[1],   min_btn[2],   min_btn[3]);

// cursor
if (over_close || over_min || in_titlebar) {
    window_set_cursor(cr_default);
} else {
    window_set_cursor(cr_default);
}

// mouse press: buttons + drag start
if (mouse_check_button_pressed(mb_left)) {

    // close
    if (over_close) {
        instance_destroy();
        exit;
    }

    // minimize
    if (over_min) {
        is_minimized = !is_minimized;
        exit;
    }

    // drag start from title bar
    if (in_titlebar) {
        window_dragging = true;
        window_drag_dx  = mx - window_x;
        window_drag_dy  = my - window_y;
    }
}

// drag move
if (window_dragging) {
    window_x = mx - window_drag_dx;
    window_y = my - window_drag_dy;

    if (!mouse_check_button(mb_left)) {
        window_dragging = false;
    }
}
