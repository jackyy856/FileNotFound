/// obj_RecycleBinApp - Draw GUI

if (!variable_instance_exists(id, "is_minimized")) {
    is_minimized = false;
}

// ----- drop shadow -----
draw_set_alpha(0.15);
draw_set_color(c_black);
draw_roundrect(x1 + 6, y1 + 6, x2 + 6, y2 + 6, false);
draw_set_alpha(1);

// ----- title bar -----
var bar_col = window_focus ? make_color_rgb(28,32,38) : make_color_rgb(40,44,50);
draw_set_color(bar_col);
draw_roundrect(x1, y1, x2, y1 + bar_h, false);

// title text
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_text(x1 + 12, y1 + 10, title);

// header buttons (same geometry as AppBase Step)
var bx_close_x1 = x2 - btn_pad - btn_w;
var bx_close_y1 = y1 + btn_pad;
var bx_close_x2 = bx_close_x1 + btn_w;
var bx_close_y2 = bx_close_y1 + btn_h;

var bx_min_x1 = bx_close_x1 - 6 - btn_w;
var bx_min_y1 = bx_close_y1;
var bx_min_x2 = bx_min_x1 + btn_w;
var bx_min_y2 = bx_min_y1 + btn_h;

// minimize button
draw_set_color(make_color_rgb(215,215,215));
draw_roundrect(bx_min_x1, bx_min_y1, bx_min_x2, bx_min_y2, false);
draw_set_color(c_black);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text((bx_min_x1 + bx_min_x2) * 0.5, (bx_min_y1 + bx_min_y2) * 0.5, "_");

// close button
draw_set_color(make_color_rgb(230,70,70));
draw_roundrect(bx_close_x1, bx_close_y1, bx_close_x2, bx_close_y2, false);
draw_set_color(c_white);
draw_text((bx_close_x1 + bx_close_x2) * 0.5, (bx_close_y1 + bx_close_y2) * 0.5, "x");

// ---------- below only draws when NOT minimized ----------
if (is_minimized) {
    exit; // keep small header visible only
}

// body background
draw_set_color(make_color_rgb(248,248,248));
draw_roundrect(x1, y1 + bar_h, x2, y2, false);

// inner content background
draw_set_color(c_white);
draw_roundrect(content_x1, content_y1, content_x2, content_y2, false);

// ===== BIN + FILE PAPERS + POPUPS (same as before, no labels on papers) =====

var cx1 = content_x1;
var cy1 = content_y1;
var cx2 = content_x2;
var cy2 = content_y2;

var content_w = cx2 - cx1;
var content_h = cy2 - cy1;

var bin_cx = cx1 + content_w * 0.5;
var bin_cy = cy1 + content_h * 0.55;

var bin_half_w = bin_width * 0.5;
var bin_half_h = bin_height * 0.5;

var bin_left   = bin_cx - bin_half_w;
var bin_top    = bin_cy - bin_half_h;
var bin_right  = bin_cx + bin_half_w;
var bin_bottom = bin_cy + bin_half_h;

var inner_radius = max(bin_half_w, bin_half_h);
var drop_radius  = inner_radius + bin_drop_margin;

// target “halo”
draw_set_color(make_colour_rgb(210, 230, 255));
draw_set_alpha(0.35);
draw_circle(bin_cx, bin_cy, drop_radius, false);
draw_set_alpha(1);

// bin body
draw_set_color(make_colour_rgb(230,230,230));
draw_rectangle(bin_left, bin_top, bin_right, bin_bottom, false);
draw_set_color(c_black);
draw_rectangle(bin_left, bin_top, bin_right, bin_bottom, true);

// bin lip
draw_set_color(make_colour_rgb(245,245,245));
draw_rectangle(bin_left, bin_top - 14, bin_right, bin_top, false);
draw_set_color(c_black);
draw_rectangle(bin_left, bin_top - 14, bin_right, bin_top, true);

// recycle icon
draw_set_color(c_black);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text(bin_cx, bin_cy, "♻");

// coloured files (papers only, no labels)
for (var i = 0; i < file_count; i++) {
    var f = files[i];
    if (f.box_open) continue;

    var file_half_w = 40;
    var file_half_h = 24;

    draw_set_color(f.color);
    draw_rectangle(
        f.x - file_half_w,
        f.y - file_half_h,
        f.x + file_half_w,
        f.y + file_half_h,
        false
    );

    draw_set_color(c_black);
    draw_rectangle(
        f.x - file_half_w,
        f.y - file_half_h,
        f.x + file_half_w,
        f.y + file_half_h,
        true
    );
}

// popups
var title_h  = 28;
var scroll_w = 10;

for (var j = 0; j < file_count; j++) {
    var g = files[j];
    if (!g.box_open) continue;

    var bx = g.box_x;
    var by = g.box_y;
    var bw = g.box_w;
    var bh = g.box_h;

    // popup body
    draw_set_color(c_white);
    draw_rectangle(bx, by, bx + bw, by + bh, false);
    draw_set_color(c_black);
    draw_rectangle(bx, by, bx + bw, by + bh, true);

    // title bar
    draw_set_color(make_colour_rgb(235,235,235));
    draw_rectangle(bx, by, bx + bw, by + title_h, false);
    draw_set_color(c_black);
    draw_rectangle(bx, by, bx + bw, by + title_h, true);

    // title text
    draw_set_halign(fa_left);
    draw_set_valign(fa_middle);
    draw_text(bx + 10, by + title_h * 0.5, g.label);

    // X button (centered)
    var x_size   = 18;
    var x_left   = bx + bw - x_size - 8;
    var x_top    = by + 5;
    var x_right  = x_left + x_size;
    var x_bottom = x_top + x_size;

    draw_set_color(make_colour_rgb(250,220,220));
    draw_rectangle(x_left, x_top, x_right, x_bottom, false);
    draw_set_color(c_black);
    draw_rectangle(x_left, x_top, x_right, x_bottom, true);

    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text((x_left + x_right) * 0.5, (x_top + x_bottom) * 0.5, "X");

        // text area
	    var text_left   = bx + 12;
	    var text_top    = by + title_h + 8;
	    var text_right  = bx + bw - 12 - scroll_w - 4;
	    var text_bottom = by + bh - 10;
	    var text_w      = text_right - text_left;
	    var visible_h   = text_bottom - text_top;

	    if (text_w > 0 && visible_h > 0) {
	        // ensure surface exists and is correct size
	        if (!surface_exists(text_surface)
	            || surface_get_width(text_surface)  != text_w
	            || surface_get_height(text_surface) != visible_h)
	        {
	            if (surface_exists(text_surface)) surface_free(text_surface);
	            text_surface = surface_create(text_w, visible_h);
	        }

	        // draw text into the surface (clipped to its bounds)
	        surface_set_target(text_surface);
	        draw_clear_alpha(c_white, 1);  // white background inside the popup
	        draw_set_halign(fa_left);
	        draw_set_valign(fa_top);
	        draw_set_color(c_black);
	        draw_text_ext(0, -g.scroll, g.content, -1, text_w);
	        surface_reset_target();

	        // now draw the surface into the popup's text area
	        draw_surface(text_surface, text_left, text_top);
	    }

    // scrollbar track
    var track_left   = bx + bw - 8 - scroll_w;
    var track_right  = track_left + scroll_w;
    var track_top    = by + title_h + 6;
    var track_bottom = by + bh - 6;

    draw_set_color(make_colour_rgb(235,235,235));
    draw_rectangle(track_left, track_top, track_right, track_bottom, false);
    draw_set_color(c_black);
    draw_rectangle(track_left, track_top, track_right, track_bottom, true);

    // thumb
    if (g.scroll_max > 0) {
        var visible_h = text_bottom - text_top;
        var track_h   = track_bottom - track_top;
        var thumb_h   = max(20, track_h * (visible_h / (visible_h + g.scroll_max)));
        var ratio     = (g.scroll_max == 0) ? 0 : (g.scroll / g.scroll_max);
        var thumb_top = track_top + ratio * (track_h - thumb_h);
        var thumb_bottom = thumb_top + thumb_h;

        draw_set_color(make_colour_rgb(180,180,180));
        draw_rectangle(track_left + 1, thumb_top + 1, track_right - 1, thumb_bottom - 1, false);
    }
}
