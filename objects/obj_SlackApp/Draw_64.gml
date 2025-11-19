/// Draw Slack-style UI with simple, non-overlapping bubbles

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

// minimize button
draw_set_color(make_color_rgb(180, 190, 200));
draw_rectangle(btn_min_x1, btn_min_y1, btn_min_x1 + btn_w, btn_min_y1 + btn_h, false);
draw_set_color(make_color_rgb(30, 34, 40));
draw_text(btn_min_x1 + 7, btn_min_y1 + 3, "_");

// close button
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
    var dm_name = dm_names[selected_dm];
    draw_set_color(c_white);
    draw_text(chat_x1 + 12, content_y1 + 6, dm_name);

    // Layout constants for bubbles
    var chat_y_start = content_y1 + 32;
    var line_y       = chat_y_start - chat_scroll;
    var chat_inner_w = (chat_x2 - chat_x1) - 24;
    var bubble_w     = chat_inner_w * 0.90;
    var text_wrap_w  = bubble_w - 18; // inside the bubble
    var bubble_h     = 56;            // FIXED height per message
    var bubble_gap   = 14;            // vertical gap between messages
    var line_sep     = 4;             // draw_text_ext line spacing

    var msgs      = dm_convos[selected_dm];
    var msg_count = array_length(msgs);

    for (i = 0; i < msg_count; i++) {
        var m     = msgs[i];
        var text  = m.text;
        var is_me = (m.who == "me");

        // bubble x position: them = left, me = right
        var bx1;
        if (is_me) {
            // align to the right side of the chat panel
            bx1 = chat_x1 + (chat_inner_w - bubble_w) + 12;
        } else {
            // align to the left side
            bx1 = chat_x1 + 12;
        }

        var by1 = line_y;
        var by2 = line_y + bubble_h;

        // only draw if visible in chat area
        if (by2 >= content_y1 && by1 <= content_y2) {
            if (is_me) {
                draw_set_color(make_color_rgb(67, 181, 129)); // green bubble
            } else {
                draw_set_color(make_color_rgb(55, 65, 81));   // dark bubble
            }

            draw_roundrect(bx1, by1, bx1 + bubble_w, by2, false);

            draw_set_color(c_white);
            draw_text_ext(bx1 + 9, by1 + 8, text, line_sep, text_wrap_w);
        }

        // move down: fixed height + fixed gap so nothing can overlap
        line_y += bubble_h + bubble_gap;
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
