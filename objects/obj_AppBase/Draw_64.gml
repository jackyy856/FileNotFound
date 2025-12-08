// drop shadow
draw_set_alpha(0.15);
draw_set_color(c_black);
draw_roundrect(x1+6, y1+6, x2+6, y2+6, false);
draw_set_alpha(1);

// title bar
var bar_col = window_focus ? make_color_rgb(28,32,38) : make_color_rgb(40,44,50);
draw_set_color(bar_col);
draw_roundrect(x1, y1, x2, y1 + bar_h, false);

// title text
draw_set_color(c_white);
draw_text(x1 + 12, y1 + 10, title);

// buttons: minimize and close
var bx_close_x1 = x2 - btn_pad - btn_w;
var bx_close_y1 = y1 + btn_pad;
var bx_close_x2 = bx_close_x1 + btn_w;
var bx_close_y2 = bx_close_y1 + btn_h;

var bx_min_x1 = bx_close_x1 - 6 - btn_w;
var bx_min_y1 = bx_close_y1;
var bx_min_x2 = bx_min_x1 + btn_w;
var bx_min_y2 = bx_min_y1 + btn_h;

// minimize
draw_set_color(make_color_rgb(215,215,215));
draw_roundrect(bx_min_x1, bx_min_y1, bx_min_x2, bx_min_y2, false);
draw_set_color(c_black);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text((bx_min_x1 + bx_min_x2) * 0.5, (bx_min_y1 + bx_min_y2) * 0.5, "_");

// close
draw_set_color(make_color_rgb(230,70,70));
draw_roundrect(bx_close_x1, bx_close_y1, bx_close_x2, bx_close_y2, false);
draw_set_color(c_white);
draw_text((bx_close_x1 + bx_close_x2) * 0.5, (bx_close_y1 + bx_close_y2) * 0.5, "x");

// body
if (!is_minimized) 
{
    draw_set_color(make_color_rgb(248,248,248));
    draw_roundrect(x1, y1 + bar_h, x2, y2, false);

    // content background
    draw_set_color(c_white);
    draw_roundrect(content_x1, content_y1, content_x2, content_y2, false);
}