// window geometry
x1 = 220;   
y1 = 80;    
w  = 720;   // width
h  = 480;   // height
bar_h = 36; // title bar height

// derived
x2 = x1 + w;
y2 = y1 + h;

// ui state
title = "App";
dragging = false;
drag_dx = 0; drag_dy = 0;
is_minimized = false;
window_focus = true; // you can use this for tinting later

// buttons
btn_w = 24; btn_h = 20; btn_pad = 8;

// content rect (what children draw into)
pad = 12;
content_x1 = x1 + pad;
content_y1 = y1 + bar_h + pad;
content_x2 = x2 - pad;
content_y2 = y2 - pad;

// recalc rects after moving/resizing
function _recalc() 
{
    x2 = x1 + w; y2 = y1 + h;
    content_x1 = x1 + pad;
    content_y1 = y1 + bar_h + pad;
    content_x2 = x2 - pad;
    content_y2 = y2 - pad;
}