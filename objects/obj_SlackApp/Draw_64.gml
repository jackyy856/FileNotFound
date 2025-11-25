/// Draw Slack-style UI with proper wrapping and non-overlapping bubbles

draw_set_alpha(1);
draw_set_font(font_body);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

// ---------------- Minimized tab ----------------
if (is_minimized) {
    var gui_h = display_get_gui_height();
    var tab_x = min_tab_margin;
    var tab_y = gui_h - min_tab_h - min_tab_margin;

    draw_set_color(make_color_rgb(31, 36, 48));
    draw_roundrect(tab_x, tab_y, tab_x + min_tab_w, tab_y + min_tab_h, false);

    draw_set_color(c_white);
    draw_text(tab_x + 10, tab_y + 4, "Slack");
    return;
}

// ---------------- Window background ----------------
draw_set_color(make_color_rgb(22, 27, 34));
draw_rectangle(window_x, window_y, window_x + window_w, window_y + window_h, false);

// Header bar
draw_set_color(make_color_rgb(36, 41, 51));
draw_rectangle(window_x, window_y, window_x + window_w, window_y + header_h, false);

// Title
draw_set_color(c_white);
draw_set_font(font_title);
draw_text(window_x + 14, window_y + 10, "Slack");

// Header buttons
draw_set_font(font_body);

// minimize
draw_set_color(make_color_rgb(180, 190, 200));
draw_rectangle(btn_min_x1, btn_min_y1, btn_min_x1 + btn_w, btn_min_y1 + btn_h, false);
draw_set_color(make_color_rgb(30, 34, 40));
draw_text(btn_min_x1 + 7, btn_min_y1 + 3, "_");

// close
draw_set_color(make_color_rgb(220, 80, 80));
draw_rectangle(btn_close_x1, btn_close_y1, btn_close_x1 + btn_w, btn_close_y1 + btn_h, false);
draw_set_color(c_white);
draw_text(btn_close_x1 + 7, btn_close_y1 + 2, "x");

// ---------------- Sidebar ----------------
draw_set_color(make_color_rgb(31, 36, 48));
draw_rectangle(sidebar_x1, content_y1, sidebar_x2, content_y2, false);

draw_set_color(make_color_rgb(144, 157, 189));
draw_text(sidebar_x1 + 12, content_y1 + 4, "CHANNELS");

var list_y = content_y1 + 24;
var i;

// channels
var ch_count = array_length(channels);
for (i = 0; i < ch_count; i++) {
    var is_sel_ch = (selected_channel == i && selected_dm == -1);
    if (is_sel_ch) {
        draw_set_color(make_color_rgb(44, 52, 70));
        draw_rectangle(sidebar_x1 + 4, list_y - 2, sidebar_x2 - 4, list_y + row_h - 2, false);
    }

    draw_set_color(c_white);
    draw_text(sidebar_x1 + 16, list_y, channels[i]);

    list_y += row_h;
}

list_y += 14;
draw_set_color(make_color_rgb(144, 157, 189));
draw_text(sidebar_x1 + 12, list_y, "DIRECT MESSAGES");
list_y += 22;

// DMs
var dm_count = array_length(dm_names);
for (i = 0; i < dm_count; i++) {
    var is_sel_dm = (selected_dm == i);
    if (is_sel_dm) {
        draw_set_color(make_color_rgb(44, 52, 70));
        draw_rectangle(sidebar_x1 + 4, list_y - 2, sidebar_x2 - 4, list_y + row_h - 2, false);
    }

    draw_set_color(c_white);
    draw_text(sidebar_x1 + 18, list_y, dm_names[i]);

    list_y += row_h;
}

// ---------------- Chat panel background ----------------
draw_set_color(make_color_rgb(24, 28, 38));
draw_rectangle(chat_x1, content_y1, chat_x2, content_y2, false);

// Border line
draw_set_color(make_color_rgb(47, 54, 71));
draw_line(sidebar_x2, content_y1, sidebar_x2, content_y2);

// ---------------- Chat content ----------------
draw_set_font(font_body);

if (selected_dm >= 0 && selected_dm < array_length(dm_convos)) {
    // Header: DM name
    var dm_name = dm_names[selected_dm];
    draw_set_color(c_white);
    draw_text(chat_x1 + 12, content_y1 + 6, dm_name);

    // layout constants inside chat panel
    var chat_y_start = content_y1 + 32;
    var chat_w       = (chat_x2 - chat_x1) - 24;  // inner width
    var bubble_w     = chat_w * 0.86;             // bubble width

    var pad_x    = 10;
    var pad_y    = 8;
    var gap_y    = 14;
    var line_sep = 4;
    var wrap_w   = bubble_w - pad_x * 2;

    // scrolling baseline
    var line_y = chat_y_start - chat_scroll;

    var msgs      = dm_convos[selected_dm];
    var msg_count = array_length(msgs);

    // visible vertical range
    var clip_y  = chat_y_start;
    var clip_y2 = content_y2 - 4;

    var line_h = string_height("Ag"); // height of one line with current font

    for (i = 0; i < msg_count; i++) {
        var m     = msgs[i];
        var text  = m.text;
        var is_me = (m.who == "me");

        // bubble X: them = left, me = right
        var bx1;
        if (is_me) {
            bx1 = chat_x1 + (chat_w - bubble_w) + 12; // right side bubble
        } else {
            bx1 = chat_x1 + 12;                       // left side bubble
        }

        // ------------ USE OUR WRAP FUNCTION ------------
        var lines = _wrap_text(text, wrap_w);
        var lc    = array_length(lines);

        var th = lc * line_h + line_sep * (lc - 1); // text height
        var bh = th + pad_y * 2;                    // bubble height

        var by1 = floor(line_y);
        var by2 = by1 + bh;

        // draw only if inside visible chat area
        if (by2 >= clip_y && by1 <= clip_y2) {
            if (is_me) {
                draw_set_color(make_color_rgb(67, 181, 129)); // green bubble
            } else {
                draw_set_color(make_color_rgb(55, 65, 81));   // dark bubble
            }

            draw_roundrect(bx1, by1, bx1 + bubble_w, by2, false);

            // draw each wrapped line manually
            draw_set_color(c_white);
            var ty = by1 + pad_y;
            for (var j = 0; j < lc; j++) {
                draw_text(bx1 + pad_x, ty, lines[j]);
                ty += line_h + line_sep;
            }
        }

        // move down for next bubble
        line_y += bh + gap_y;
    }
}
else if (selected_channel >= 0 && selected_channel < array_length(channels)) {
    var cname = channels[selected_channel];

    draw_set_color(c_white);
    draw_text(chat_x1 + 12, content_y1 + 6, cname);

    draw_set_color(make_color_rgb(176, 189, 220));
    draw_text(chat_x1 + 12, content_y1 + 36,
        "Channel history archived by compliance. Check finance drives for exports.");
}
else {
    draw_set_color(make_color_rgb(176, 189, 220));
    draw_text(chat_x1 + 12, content_y1 + 12, "Select a channel or DM from the left.");
}
