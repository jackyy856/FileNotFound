
var x1 = win_x;
var y1 = win_y;
var x2 = win_x + win_w;
var y2 = win_y + win_h;

var header_bottom   = y1 + header_h - 20;
var footer_top_full = win_y + win_h_full - footer_h;

// gui colors
var col_border  = make_color_rgb(25, 28, 33);
var col_body    = make_color_rgb(131, 10, 72); 
var col_header  = make_color_rgb(106, 98, 229);
var col_footer  = make_color_rgb(255, 49, 255);
var col_sep     = make_color_rgb(74, 5, 28);

draw_set_alpha(1);

// ---------------- window frame ----------------
draw_set_color(col_border);
draw_roundrect(x1 - 2, y1 - 2, x2 + 2, y2 + 2, false);

draw_set_color(col_body);
draw_roundrect(x1, y1, x2, y2, false);

// header bar
draw_set_color(col_header);
draw_rectangle(x1, y1, x2, header_bottom, false);

// body + footer
if (!minimized)
{
    draw_set_color(col_body);
    draw_rectangle(x1, header_bottom, x2, footer_top_full, false);

    draw_set_color(col_footer);
    draw_rectangle(x1, footer_top_full, x2, win_y + win_h_full, false);

    draw_set_color(col_sep);
    draw_line(x1, footer_top_full, x2, footer_top_full);
}

// header separator line
draw_set_color(col_sep);
draw_line(x1, header_bottom, x2, header_bottom);

// title
draw_set_color(c_white);
draw_text_transformed(x1 + 12, y1, "???????",1.8,1.8,0);

// ---------------- messages ----------------
if (!minimized)
{
    var content_x1 = x1;
    var content_x2 = x2;
    var content_y1 = header_bottom;
    var content_y2 = footer_top_full;

    var msg_total_h = msg_row_h + msg_spacing;
        var count = array_length(messages);

    // GUI -> display scaling for scissor
    var disp_w = display_get_width();
    var disp_h = display_get_height();
    var gui_w  = display_get_gui_width();
    var gui_h  = display_get_gui_height();

    var gui_scale_x = disp_w / gui_w;
    var gui_scale_y = disp_h / gui_h;

    var old_scissor = gpu_get_scissor();
    gpu_set_scissor(
        content_x1 * gui_scale_x - 25,
        content_y1 * gui_scale_y - 7,
        (content_x2 - content_x1) * gui_scale_x,
        (content_y2 - content_y1) * gui_scale_y - 16
    );

    var pfp_radius   = 28;
    var line_sep     = 4;
    var right_margin = 32;

    // running Y that accounts for different message heights
    var cur_y = content_y1 + msg_margin_top - scroll;

    for (var i = 0; i < count; i++)
    {
        var msg       = messages[i];
        var msg_y_top = cur_y;

        // ---------------- PFP ----------------
        var pfp_x = content_x1 + msg_margin_side + pfp_radius;
        var pfp_y = msg_y_top + pfp_radius + 8;

        if (sprite_exists(msg.spr_pfp))
        {
            var spr_w    = sprite_get_width(msg.spr_pfp);
            var spr_h    = sprite_get_height(msg.spr_pfp);
            var spr_size = max(spr_w, spr_h);
            var spr_scl  = (pfp_radius * 2.0) / spr_size;

            draw_sprite_ext(msg.spr_pfp, 0, pfp_x, pfp_y,
                            spr_scl, spr_scl, 0, c_white, 1);
        }
        else
        {
            draw_set_color(msg.col_pfp);
            draw_circle(pfp_x, pfp_y, pfp_radius, false);
        }

        // ---------------- username ----------------
        draw_set_color(msg.col_name);
        var name_x = pfp_x + pfp_radius + 18;
        var name_y = msg_y_top - 2;
        draw_text(name_x, name_y, msg.user);

        // ---------------- wrapped message text ----------------
        draw_set_color(make_color_rgb(40, 40, 40));
        var text_x = name_x;
        var text_y = name_y + 20;

        var right_limit = content_x2 - right_margin;
        var wrap_width  = max(10, right_limit - text_x);

        draw_text_ext(text_x, text_y, msg.text, line_sep, wrap_width);

        // ---------------- row height for next message ----------------
        var text_h      = string_height_ext(msg.text, line_sep, wrap_width);
        var text_bottom = text_y + text_h;
        var pfp_bottom  = pfp_y + pfp_radius;
        var row_bottom  = max(text_bottom, pfp_bottom);

        var row_height  = (row_bottom - msg_y_top) + msg_spacing;

        cur_y += row_height;
    }

    gpu_set_scissor(old_scissor);


    // ----------------
    // scrollbar (visual only, !!!!!!!!!ADD FUNCTIONALITY LATER!!!!!!!)
    // ----------------

    var view_height    = content_y2 - content_y1;
    var content_height = msg_margin_top * 2 + count * msg_total_h;

    if (content_height > view_height)
    {
        var track_margin = 4;
        var track_width  = 8;

        var track_x1 = content_x2 - track_margin - track_width;
        var track_x2 = content_x2 - track_margin;
        var track_y1 = content_y1 + track_margin;
        var track_y2 = content_y2 - track_margin;
        var track_h  = track_y2 - track_y1;

        var visible_ratio = clamp(view_height / content_height, 0.05, 1);
        var thumb_h       = track_h * visible_ratio;

        var scroll_ratio  = (max_scroll > 0) ? (scroll / max_scroll) : 0;
        var thumb_y1      = track_y1 + (track_h - thumb_h) * scroll_ratio;
        var thumb_y2      = thumb_y1 + thumb_h;

        // track
        draw_set_color(make_color_rgb(90, 15, 60));
        draw_rectangle(track_x1, track_y1, track_x2, track_y2, false);

        // thumb
        draw_set_color(make_color_rgb(255, 130, 255));
        draw_roundrect(track_x1 + 1, thumb_y1, track_x2 - 1, thumb_y2, false);
    }
}

// ---------------- buttons ----------------

// close [X]
draw_set_color(c_red);
draw_roundrect(btn_close_x1, btn_close_y1, btn_close_x2, btn_close_y2, false);
draw_set_color(c_white);
draw_text(btn_close_x1 + 7, btn_close_y1 + 3, "x");

// minimize [_]
draw_set_color(make_color_rgb(230, 230, 230));
draw_roundrect(btn_min_x1, btn_min_y1, btn_min_x2, btn_min_y2, false);
draw_set_color(c_black);
draw_text(btn_min_x1 + 6, btn_min_y1 + 2, "_");




/*



var x1 = win_x;
var y1 = win_y;
var x2 = win_x + win_w;
var y2 = win_y + win_h;

var header_bottom = y1 + header_h;
var footer_top_full = win_y + win_h_full - footer_h;

// colors 

var col_border  = make_color_rgb(25, 28, 33);
var col_body    = make_color_rgb(131, 10, 72); 
var col_header  = make_color_rgb(106, 98, 229);
var col_footer  = make_color_rgb(255, 49, 255);
var col_sep     = make_color_rgb(74, 5, 28);

draw_set_alpha(1);

// outer border
draw_set_color(col_border);
draw_roundrect(x1 - 2, y1 - 2, x2 + 2, y2 + 2, false);

// inner background
draw_set_color(col_body);
draw_roundrect(x1, y1, x2, y2, false);

// header bar
draw_set_color(col_header);
draw_rectangle(x1, y1, x2, header_bottom, false);

// Body + footer only when not minimized
if (!minimized)
{
    // Body area
    draw_set_color(col_body);
    draw_rectangle(x1, header_bottom, x2, footer_top_full, false);

    // Footer strip (input area)
    draw_set_color(col_footer);
    draw_rectangle(x1, footer_top_full, x2, win_y + win_h_full, false);

    // Footer separator line
    draw_set_color(col_sep);
    draw_line(x1, footer_top_full, x2, footer_top_full);
}

// header separator line
draw_set_color(col_sep);
draw_line(x1, header_bottom, x2, header_bottom);

// title 
draw_set_color(c_white);
draw_text(x1 + 12, y1 + 6, "Hacker");

// ----------------
// messages 
// ----------------
if (!minimized)
{
    var content_x1 = x1;
    var content_x2 = x2;
    var content_y1 = header_bottom;
    var content_y2 = footer_top_full;

    var msg_total_h = msg_row_h + msg_spacing;
    var count       = array_length(messages);

    // clip drawing to message area
    var old_scissor = gpu_get_scissor();
    gpu_set_scissor(content_x1, content_y1,
                    content_x2 - content_x1,
                    content_y2 - content_y1);

    for (var i = 0; i < count; i++)
    {
        // messages stored oldest->newest, top aligned, then shift by scroll
        var msg_y_top    = content_y1 + msg_margin_top + i * msg_total_h - scroll;
        var msg_y_bottom = msg_y_top + msg_row_h;

        if (msg_y_bottom < content_y1 || msg_y_top > content_y2)
        {
            continue;
        }

        var msg = messages[i];

        // left column: pfp
        var pfp_radius = 14;
        var pfp_x      = content_x1 + msg_margin_side + pfp_radius;
        var pfp_y      = msg_y_top + pfp_radius + 4;

        draw_set_color(msg.col_pfp);
        draw_circle(pfp_x, pfp_y, pfp_radius, false);

        // username
        draw_set_color(msg.col_name);
        var name_x = pfp_x + pfp_radius + 10;
        var name_y = msg_y_top + 2;
        draw_text(name_x, name_y, msg.user);

        // placeholder message text 
        draw_set_color(make_color_rgb(40, 40, 40));
        var text_x = name_x;
        var text_y = name_y + 18;
        draw_text(text_x, text_y, msg.text);
    }

    gpu_set_scissor(old_scissor);
}

// ----------------
// buttons
// ----------------

// close [X]
draw_set_color(c_red);
draw_roundrect(btn_close_x1, btn_close_y1, btn_close_x2, btn_close_y2, false);
draw_set_color(c_white);
draw_text(btn_close_x1 + 7, btn_close_y1 + 3, "x");

// minimize [_]
draw_set_color(make_color_rgb(230, 230, 230));
draw_roundrect(btn_min_x1, btn_min_y1, btn_min_x2, btn_min_y2, false);
draw_set_color(c_black);
draw_text(btn_min_x1 + 6, btn_min_y1 + 2, "_");


