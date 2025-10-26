/// DRAW GUI — obj_StickyNoteApp (stable, no GPU scissor, fixed lock marker)

// shadow
draw_set_alpha(0.15);
draw_set_color(c_black);
draw_roundrect(x1+6, y1+6, x2+6, y2+6, false);
draw_set_alpha(1);

// title bar
var bar_col = make_color_rgb(28,32,38);
draw_set_color(bar_col);
draw_roundrect(x1, y1, x2, y1 + bar_h, false);

// title
draw_set_color(c_white);
draw_set_font(font_title);
draw_text(x1 + 12, y1 + 10, title);

// window buttons
var bx_close_x1 = x2 - btn_pad - btn_w;
var bx_close_y1 = y1 + btn_pad;
var bx_min_x1   = bx_close_x1 - 6 - btn_w;
var bx_min_y1   = bx_close_y1;

// minimize
draw_set_color(make_color_rgb(215,215,215));
draw_roundrect(bx_min_x1, bx_min_y1, bx_min_x1+btn_w, bx_min_y1+btn_h, false);
draw_set_color(c_black);
draw_text(bx_min_x1+7, bx_min_y1+3, "_");

// close
draw_set_color(make_color_rgb(230,70,70));
draw_roundrect(bx_close_x1, bx_close_y1, bx_close_x1+btn_w, bx_close_y1+btn_h, false);
draw_set_color(c_white);
draw_text(bx_close_x1+7, bx_close_y1+3, "x");

// body shell
if (is_minimized) exit;

draw_set_color(make_color_rgb(248,248,248));
draw_roundrect(x1, y1 + bar_h, x2, y2, false);

// content background
draw_set_color(c_white);
draw_roundrect(content_x1, content_y1, content_x2, content_y2, false);

draw_set_font(font_body);
draw_set_color(c_black);

// ===================== LIST VIEW =====================
if (selected_index == -1) {

    draw_set_alpha(0.7);
    draw_text(content_x1, content_y1 - 28, "All Notes");
    draw_set_alpha(1);

    var area_w = (content_x2 - content_x1);
    var area_h = (content_y2 - content_y1);

    var count     = array_length(notes);
    var start_row = max(0, floor(list_scroll / row_h));
    var vis_rows  = ceil(area_h / row_h) + 1;
    var end_row   = min(count - 1, start_row + vis_rows);

    for (var i = start_row; i <= end_row; i++) {
        var row_y  = content_y1 + (i * row_h - list_scroll);
        var n      = notes[i];

        // row background
        draw_set_alpha(0.06);
        draw_set_color(c_black);
        draw_rectangle(content_x1, row_y, content_x1 + area_w, row_y + row_h, false);
        draw_set_alpha(1);

        // left gutter for markers
        var gutter_x = content_x1 + 12;  // 24px gutter centered at +12
        var title_x  = content_x1 + 36;  // title always starts after gutter

        // marker: padlock for locked notes
        if (n.locked) {
            draw_set_color(c_black);
            var cy = row_y + row_h * 0.5;
            // shackle
            draw_circle(gutter_x + 6, cy - 2, 5, false);
            // body
            draw_rectangle(gutter_x + 2, cy, gutter_x + 10, cy + 8, false);
        }
        // marker: unread dot if not locked
        else if (!n.read) {
            draw_set_color(c_black);
            draw_circle(gutter_x + 6, row_y + row_h * 0.5, 4, false);
        }

        // title
        draw_set_color(c_black);
        draw_text(title_x, row_y + 10, n.title);

        // tag on right
        draw_set_alpha(0.6);
        draw_set_halign(fa_right);
        draw_text(content_x1 + area_w - 12, row_y + 10, string(n.tag));
        draw_set_halign(fa_left);
        draw_set_alpha(1);
    }

// ===================== READING VIEW =====================
} else {
    var back_x = content_x1;
    var back_y = content_y1 - 32;

    draw_set_color(make_color_rgb(230,230,230));
    draw_roundrect(back_x, back_y, back_x+88, back_y+24, false);
    draw_set_color(c_black);
    draw_text(back_x + 10, back_y + 4, "< Back");

    var n = notes[selected_index];
    var tx = content_x1;
    var ty = content_y1;

    draw_set_font(font_title);
    draw_text(tx, ty, n.title);
    ty += 28;

    draw_set_font(font_body);
    draw_text_ext(tx, ty, n.body, 12, (content_x2 - content_x1) - 16);
}

// ===================== PASSWORD MODAL =====================
if (pw_modal_open) {
    // dim backdrop
    draw_set_alpha(0.35);
    draw_set_color(c_black);
    draw_rectangle(x1, y1, x2, y2, false);
    draw_set_alpha(1);

    var mw = pw_box_w;
    var mh = pw_box_h;
    var mx1 = x1 + (w - mw) * 0.5;
    var my1 = y1 + (h - mh) * 0.5;

    // panel
    draw_set_color(c_white);
    draw_roundrect(mx1, my1, mx1+mw, my1+mh, false);
    draw_set_color(c_black);
    draw_rectangle(mx1, my1, mx1+mw, my1+mh, true);

    draw_set_font(font_title);
    draw_text(mx1 + 16, my1 + 12, "Enter Password");

    // input box
    var ibx = mx1 + 16;
    var iby = my1 + 54;
    var ibw = mw - 32;
    var ibh = 28;

    draw_set_color(make_color_rgb(240,240,240));
    draw_roundrect(ibx, iby, ibx+ibw, iby+ibh, false);

    draw_set_color(c_black);
    draw_set_font(font_body);
    draw_text(ibx + 8, iby + 6, pw_input);

    // feedback
    draw_set_color(make_color_rgb(180,40,40));
    draw_text(mx1 + 16, my1 + 92, pw_feedback);

    // buttons
    var btnW = 96;
    var btnH = 28;
    var ok_x = mx1 + mw - btnW - 16;
    var ok_y = my1 + mh - btnH - 16;
    var cancel_x = mx1 + 16;
    var cancel_y = ok_y;

    draw_set_color(make_color_rgb(230,230,230));
    draw_roundrect(cancel_x, cancel_y, cancel_x+btnW, cancel_y+btnH, false);
    draw_set_color(c_black);
    draw_text(cancel_x + 20, cancel_y + 5, "Cancel");

    draw_set_color(make_color_rgb(40,160,80));
    draw_roundrect(ok_x, ok_y, ok_x+btnW, ok_y+btnH, false);
    draw_set_color(c_white);
    draw_text(ok_x + 34, ok_y + 5, "OK");
}
