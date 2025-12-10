 /// obj_EmailIntro - Draw GUI

// Hidden until opened
if (!app_visible) exit;

// Header bar
var hdr_bg = make_color_rgb(74, 82, 139);
draw_set_color(hdr_bg);
draw_rectangle(window_x, window_y, window_x + window_w, window_y + header_h, false);
draw_set_color(c_black);
draw_rectangle(window_x, window_y, window_x + window_w, window_y + header_h, true);

// Title
draw_set_color(c_white);
draw_set_font(font_title);
draw_set_halign(fa_left);
draw_set_valign(fa_middle);
draw_text(window_x + 12, window_y + header_h * 0.5, "Mail");

// Body
draw_set_color(c_white);
draw_rectangle(window_x, window_y + header_h, window_x + window_w, window_y + window_h, false);
draw_set_color(c_black);
draw_rectangle(window_x, window_y + header_h, window_x + window_w, window_y + window_h, true);

// Inbox view
if (selected_index == -1) {
    var rowY = list_top;
    for (var i = 0; i < array_length(inbox); i++) {
        var em = inbox[i];
        // row bg
        var bg = (i == 0) ? make_color_rgb(245,245,255) : make_color_rgb(250,250,250);
        draw_set_color(bg);
        draw_rectangle(list_left, rowY, list_left + list_w, rowY + row_h, false);
        // unread dot only for first
        if (!em.read) {
            draw_set_color(c_black);
            draw_circle(list_left + 8, rowY + row_h*0.5, 3, false);
        }
        // text (wrap to fit)
        draw_set_color(c_black);
        draw_set_font(font_body);
        draw_set_halign(fa_left); draw_set_valign(fa_top);
        var wrap_w = list_w - 32;
        draw_text_ext(list_left + 16, rowY + 6, em.from + " | " + em.subject, 12, wrap_w);
        rowY += row_h;
    }
    // Prompt bar (if any)
    if (prompt_timer > 0 && prompt_txt != "") {
        var gui_w = display_get_gui_width();
        var gui_h = display_get_gui_height();
        var m = 20, bar_h = 64;
        var y1 = gui_h - bar_h - m, y2 = gui_h - m;
        draw_set_alpha(0.92);
        draw_set_color(make_color_rgb(48,18,82));
        draw_roundrect(m, y1, gui_w - m, y2, false);
        draw_set_alpha(1);
        draw_set_color(make_color_rgb(156,90,255));
        draw_rectangle(m, y1, gui_w - m, y1 + 3, false);
        draw_set_color(c_white);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        draw_text_ext(m + 20, y1 + 16, prompt_txt, 16, gui_w - (m + 20) * 2);
    }
    exit;
}

// Email view (only announcement is openable)
var em = inbox[selected_index];
var tx = window_x + 16;
var ty = window_y + header_h + 12;

// Subject
draw_set_color(c_black);
draw_set_font(font_title);
draw_set_halign(fa_left); draw_set_valign(fa_top);
draw_text(tx, ty, em.subject);
ty += 28;

// From
draw_set_font(font_body);
draw_text(tx, ty, "From: " + em.from);
ty += 28;

// Body
draw_set_font(font_body);
draw_text_ext(tx, ty, em.body, 12, window_w - 32);
var body_h = string_height_ext(em.body, 12, window_w - 32);
var link_y = ty + body_h + 12;

// redeem link (wrap position)
draw_set_color(c_green);
draw_set_font(font_body);
draw_text(tx, link_y, "redeemithere.zet");
link_rect = [tx, link_y, string_width("redeemithere.zet"), 16];

// Prompt bar (if any)
if (prompt_timer > 0 && prompt_txt != "") {
    var gui_w = display_get_gui_width();
    var gui_h = display_get_gui_height();
    var m2 = 20, bar_h2 = 64;
    var yy1 = gui_h - bar_h2 - m2, yy2 = gui_h - m2;
    draw_set_alpha(0.92);
    draw_set_color(make_color_rgb(48,18,82));
    draw_roundrect(m2, yy1, gui_w - m2, yy2, false);
    draw_set_alpha(1);
    draw_set_color(make_color_rgb(156,90,255));
    draw_rectangle(m2, yy1, gui_w - m2, yy1 + 3, false);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_text_ext(m2 + 20, yy1 + 16, prompt_txt, 16, gui_w - (m2 + 20) * 2);
}

// Reset
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_font(-1);
draw_set_color(c_white);
draw_set_alpha(1);

