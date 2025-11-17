
var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

var x1 = win_x;
var y1 = win_y;
var x2 = win_x + win_w;
var y2 = win_y + win_h;

var header_bottom   = y1 + header_h - 20;
var header_vis_h    = header_bottom - y1;         
var footer_top_full = win_y + win_h_full - footer_h; 

// ----------------
// buttons
// ----------------
var btn_margin = 8;
var btn_size   = max(12, header_vis_h - btn_margin * 2); // keep in header

// Close "x" button 
btn_close_x2 = x2 - btn_margin ;
btn_close_x1 = btn_close_x2 - btn_size;
btn_close_y1 = y1 + btn_margin;
btn_close_y2 = btn_close_y1 + btn_size;

// minimize button
btn_min_x2 = btn_close_x1 - btn_margin;
btn_min_x1 = btn_min_x2 - btn_size;
btn_min_y1 = btn_close_y1;
btn_min_y2 = btn_close_y2;

// ----------------
// mouse press: buttons + drag start
// ----------------
if (mouse_check_button_pressed(mb_left))
{
    // close
    if (mx >= btn_close_x1 && mx <= btn_close_x2 &&
        my >= btn_close_y1 && my <= btn_close_y2)
    {
        instance_destroy();
    }
    // minimize
    else if (mx >= btn_min_x1 && mx <= btn_min_x2 &&
             my >= btn_min_y1 && my <= btn_min_y2)
    {
        minimized = !minimized;
        win_h     = minimized ? header_vis_h : win_h_full; // only show visible header when minimized
    }
    // drag start in header area
    else if (mx >= x1 && mx <= x2 &&
             my >= y1 && my <= header_bottom)
    {
        dragging = true;
        drag_dx  = mx - win_x;
        drag_dy  = my - win_y;
    }
}

// stop dragging
if (!mouse_check_button(mb_left))
{
    dragging = false;
}

// drag move
if (dragging)
{
    win_x = mx - drag_dx;
    win_y = my - drag_dy;
}

// ----------------
// scroll (mouse wheel) – only when not minimized
// ----------------
if (!minimized)
{
    var content_x1 = x1;
    var content_x2 = x2;
    var content_y1 = header_bottom;
    var content_y2 = footer_top_full;

    var over_messages =
        (mx >= content_x1 && mx <= content_x2 &&
         my >= content_y1 && my <= content_y2);

    if (over_messages && max_scroll > 0)
    {
        var step_px = 18;

        if (mouse_wheel_up())
        {
            scroll = max(0, scroll - step_px);
        }
        if (mouse_wheel_down())
        {
            scroll = min(max_scroll, scroll + step_px);
        }
    }
}


