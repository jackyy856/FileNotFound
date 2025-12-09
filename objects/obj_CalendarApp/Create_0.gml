/// obj_CalendarApp - Create

// If you inherit from a base app, keep this
event_inherited(); 

title    = "Calendar";
window_w = 950;
window_h = 490;

// position somewhere reasonable on GUI
window_x = 160;
window_y = 120;

header_h = 48;
is_minimized = false;

// buttons (screen coords)
var btn_size = 30;
var btn_y    = window_y + (header_h - btn_size) / 2;

var min_x1   = window_x + window_w - (btn_size * 2) - 8;
var min_x2   = min_x1 + btn_size;

var close_x1 = window_x + window_w - btn_size - 4;
var close_x2 = close_x1 + btn_size;

min_btn   = [min_x1, btn_y, btn_size, btn_size];
close_btn = [close_x1, btn_y, btn_size, btn_size];

window_dragging = false;
window_drag_dx  = 0;
window_drag_dy  = 0;

calendar_sprite = spr_CalendarMonth; 
