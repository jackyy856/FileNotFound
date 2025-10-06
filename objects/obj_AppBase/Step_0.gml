// read mouse in GUI space
var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

// regions
var in_title = point_in_rectangle(mx, my, x1, y1, x2, y1 + bar_h);

// begin drag on title press
if (mouse_check_button_pressed(mb_left) && in_title && !is_minimized) {
    dragging = true;
    drag_dx = mx - x1;
    drag_dy = my - y1;
    window_focus = true; 
}

// drag movement
if (dragging) {
    x1 = mx - drag_dx;
    y1 = my - drag_dy;
    script_execute(_recalc);
    if (!mouse_check_button(mb_left)) dragging = false;
}

// buttons
var bx_close_x1 = x2 - btn_pad - btn_w;
var bx_close_y1 = y1 + btn_pad;
var bx_close_x2 = bx_close_x1 + btn_w;
var bx_close_y2 = bx_close_y1 + btn_h;

var bx_min_x1 = bx_close_x1 - 6 - btn_w;
var bx_min_y1 = bx_close_y1;
var bx_min_x2 = bx_min_x1 + btn_w;
var bx_min_y2 = bx_min_y1 + btn_h;

// clicks on buttons
if (mouse_check_button_pressed(mb_left)) 
{
    if (point_in_rectangle(mx, my, bx_close_x1, bx_close_y1, bx_close_x2, bx_close_y2)) 
	{
        instance_destroy(); // exit
    } else
    if (point_in_rectangle(mx, my, bx_min_x1, bx_min_y1, bx_min_x2, bx_min_y2)) 
	{	
        is_minimized = !is_minimized; // minimize
    }
}

// hotkeys
if (keyboard_check_pressed(vk_escape)) instance_destroy(); // ESC closes