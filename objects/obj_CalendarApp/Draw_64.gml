 /// obj_CalendarApp - Draw GUI

var x1 = window_x;
var y1 = window_y;
var x2 = window_x + window_w;
var y2 = window_y + window_h;

// Colors
var col_border = make_color_rgb(25, 28, 33);
var col_header = make_color_rgb(40, 40, 60);
var col_body   = make_color_rgb(18, 18, 22);

// Frame
draw_set_alpha(1);
draw_set_color(col_border);
draw_rectangle(x1 - 2, y1 - 2, x2 + 2, y2 + 2, false);

// Body
draw_set_color(col_body);
draw_rectangle(x1, y1, x2, y2, false);

// Header
draw_set_color(col_header);
draw_rectangle(x1, y1, x2, y1 + header_h, false);

// Title
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_middle);
draw_text(x1 + 16, y1 + header_h * 0.5, title);

// Buttons
// close
draw_set_color(c_red);
draw_rectangle(
    close_btn[0], close_btn[1],
    close_btn[0] + close_btn[2],
    close_btn[1] + close_btn[3],
    false
);
draw_set_color(c_white);
draw_text(close_btn[0] + 9, close_btn[1] + 5, "x");

// minimize
draw_set_color(c_white);
draw_rectangle(
    min_btn[0], min_btn[1],
    min_btn[0] + min_btn[2],
    min_btn[1] + min_btn[3],
    false
);
draw_set_color(c_black);
draw_text(min_btn[0] + 9, min_btn[1] + 5, "_");

// If minimized, don't draw content
if (is_minimized) {
    exit;
}

// ---- Calendar content ----

var body_x1 = x1 + 12;
var body_y1 = y1 + header_h + 12;
var body_x2 = x2 - 12;
var body_y2 = y2 - 12;

var body_w = body_x2 - body_x1;
var body_h = body_y2 - body_y1;

// Background panel
draw_set_color(make_color_rgb(10, 10, 14));
draw_rectangle(body_x1, body_y1, body_x2, body_y2, false);

// Draw calendar sprite scaled to fit
if (sprite_exists(calendar_sprite)) {
    var sw = sprite_get_width(calendar_sprite);
    var sh = sprite_get_height(calendar_sprite);

    if (sw > 0 && sh > 0) {
        var sx  = body_w / sw;
        var sy  = body_h / sh;
        var scl = min(sx, sy);

        var draw_w = sw * scl;
        var draw_h = sh * scl;

        var cx = body_x1 + (body_w - draw_w) * 0.5;
        var cy = body_y1 + (body_h - draw_h) * 0.5;

        draw_sprite_ext(
            calendar_sprite, 0,
            cx + draw_w * 0.5,
            cy + draw_h * 0.5,
            scl, scl, 0, c_white, 1
        );
    }
}
