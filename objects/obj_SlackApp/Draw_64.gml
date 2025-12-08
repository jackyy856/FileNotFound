/// Draw Slack-style UI with wrapping, dates + timestamps

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
draw_set_color(make_color_rgb(21, 24, 32));
draw_roundrect(window_x, window_y, window_x + window_w, window_y + window_h, false);

// Header bar
draw_set_color(make_color_rgb(31, 36, 48));
draw_rectangle(window_x, window_y, window_x + window_w, window_y + header_h, false);

draw_set_color(c_white);
draw_text(window_x + 10, window_y + 10, "Slack");

// Header buttons
draw_set_color(c_white);
draw_rectangle(btn_min_x1,  btn_min_y1,  btn_min_x1 + btn_w,  btn_min_y1 + btn_h,  false);
draw_rectangle(btn_close_x1, btn_close_y1, btn_close_x1 + btn_w, btn_close_y1 + btn_h, false);

draw_set_color(c_black);
draw_text(btn_min_x1 + 7,  btn_min_y1 + 2,  "-");
draw_text(btn_close_x1 + 7, btn_close_y1 + 2, "X");

// ---------------- Content area ----------------
var window_x2 = window_x + window_w;
var window_y2 = window_y + window_h;
var header_y2 = window_y + header_h;

var sidebar_x1 = window_x;
var sidebar_x2 = window_x + 260;

var content_y1 = header_y2 + 1;
var content_y2 = window_y2 - 1;

var chat_x1 = sidebar_x2 + 1;
var chat_x2 = window_x2 - 1;

// Sidebar background
draw_set_color(make_color_rgb(31, 36, 48));
draw_rectangle(sidebar_x1, content_y1, sidebar_x2, content_y2, false);

// Sidebar text
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
        draw_rectangle(sidebar_x1 + 4, list_y - 2, sidebar_x2 - 4, list_y + 18, false);
    }

    draw_set_color(c_white);
    draw_text(sidebar_x1 + 16, list_y, channels[i]);

    list_y += 20;
}

// DM header
list_y += 14;
draw_set_color(make_color_rgb(144, 157, 189));
draw_text(sidebar_x1 + 12, list_y, "DIRECT MESSAGES");
list_y += 22;

// direct messages list
var dm_count = array_length(dm_names);
for (i = 0; i < dm_count; i++) {
    var is_sel_dm = (selected_dm == i && selected_channel == -1);
    if (is_sel_dm) {
        draw_set_color(make_color_rgb(44, 52, 70));
        draw_rectangle(sidebar_x1 + 4, list_y - 2, sidebar_x2 - 4, list_y + 18, false);
    }

    draw_set_color(c_white);
    draw_text(sidebar_x1 + 16, list_y, dm_names[i]);
    list_y += 20;
}

// ---------------- Chat panel background ----------------
draw_set_color(make_color_rgb(17, 21, 32));
draw_rectangle(chat_x1, content_y1, chat_x2, content_y2, false);

// ---------------- Chat contents ----------------
if (selected_dm >= 0 && selected_dm < array_length(dm_convos)) {

    // Header: DM name
    var dm_name = dm_names[selected_dm];
    draw_set_color(c_white);
    draw_text(chat_x1 + 12, content_y1 + 6, dm_name);

    // layout constants inside chat panel
    var chat_y_start = content_y1 + 32;           // first line of chat area
    var chat_w       = (chat_x2 - chat_x1) - 24;
    var bubble_w     = chat_w * 0.84;             // a bit narrower

    var pad_x    = 10;
    var pad_y    = 8;
    var gap_y    = 14;
    var line_sep = 4;
    var wrap_w   = bubble_w - pad_x * 2;

    // visible vertical range for chat
    var clip_y  = chat_y_start;
    var clip_y2 = content_y2 - 12;
    var chat_h  = clip_y2 - clip_y;

    var line_h = string_height("Ag");

    var msgs      = dm_convos[selected_dm];
    var msg_count = array_length(msgs);

    var center_x = (chat_x1 + chat_x2) * 0.5;

    // ---------- First pass: compute total convo height ----------
    var total_h = 0;
    var day_h   = line_h + 14;

    for (i = 0; i < msg_count; i++) {
        var m0    = msgs[i];
        var kind0 = variable_struct_exists(m0, "kind") ? m0.kind : "msg";

        if (kind0 == "day") {
            total_h += day_h;
        } else {
            var text0  = m0.text;
            var lines0 = _wrap_text(text0, wrap_w);
            var lc0    = array_length(lines0);

            var th0 = lc0 * line_h + line_sep * (lc0 - 1);
            var bh0 = th0 + pad_y * 2;

            total_h += bh0;
        }

        if (i < msg_count - 1) total_h += gap_y;
    }

    // ---------- Scroll bounds & top Y (TOP-based scroll) ----------
    var max_scroll;
    if (total_h <= chat_h) {
        max_scroll  = 0;
        chat_scroll = 0;
    } else {
        max_scroll = total_h - chat_h;

        if (chat_scroll < 0)          chat_scroll = 0;
        if (chat_scroll > max_scroll) chat_scroll = max_scroll;
    }

    // top of the conversation in screen space
    // chat_scroll = 0      -> top at clip_y
    // chat_scroll = max    -> bottom at clip_y2
    var top_y  = clip_y - chat_scroll;
    var line_y = top_y;

    // ---------- Second pass: draw bubbles + date lines ----------
    for (i = 0; i < msg_count; i++) {
        var m    = msgs[i];
        var kind = variable_struct_exists(m, "kind") ? m.kind : "msg";

if (kind == "day") {
    var by1_d = floor(line_y);
    var by2_d = by1_d + day_h;

    if (by2_d >= clip_y && by1_d <= clip_y2) {
        var d_y = clamp(by1_d, clip_y, clip_y2 - line_h);
        // brighter date label for dark theme
        draw_set_color(make_color_rgb(200, 210, 230));
        draw_set_halign(fa_center);
        draw_set_valign(fa_top);
        draw_text(center_x, d_y + 4, m.label);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
    }

    line_y += day_h + gap_y;
    continue;
}


        // Normal message bubble
        var text  = m.text;
        var is_me = (m.who == "me");

        var bx1;
        if (is_me) bx1 = chat_x1 + (chat_w - bubble_w) + 12; // right
        else       bx1 = chat_x1 + 12;                       // left

        var lines = _wrap_text(text, wrap_w);
        var lc    = array_length(lines);

        var th = lc * line_h + line_sep * (lc - 1);
        var bh = th + pad_y * 2;

        var by1 = floor(line_y);
        var by2 = by1 + bh;

        // Skip completely if outside
        if (by2 < clip_y || by1 > clip_y2) {
            line_y += bh + gap_y;
            continue;
        }

        // Clamp bubble vertically inside chat area
        var draw_y1 = max(by1, clip_y);
        var draw_y2 = min(by2, clip_y2);

        // bubble background
        if (is_me) draw_set_color(make_color_rgb(67, 181, 129));
        else       draw_set_color(make_color_rgb(55, 65, 81));

        draw_roundrect(bx1, draw_y1, bx1 + bubble_w, draw_y2, false);

        // timestamp (top-right, small & grey)
        if (variable_struct_exists(m, "time")) {
            var ts_y = by1 + 2;
            if (ts_y >= clip_y && ts_y <= clip_y2) {
                draw_set_color(make_color_rgb(170, 180, 200));
                draw_set_halign(fa_right);
                draw_text(bx1 + bubble_w - pad_x, ts_y, m.time);
                draw_set_halign(fa_left);
            }
        }

        // message text (clip per line)
        draw_set_color(c_white);
        var ty = by1 + pad_y + line_h * 0.3;
        for (var j = 0; j < lc; j++) {
            if (ty + line_h >= clip_y && ty <= clip_y2) {
                draw_text(bx1 + pad_x, ty, lines[j]);
            }
            ty += line_h + line_sep;
        }

        line_y += bh + gap_y;
    }
}
else if (selected_channel >= 0 && selected_channel < array_length(channels)) {
    // ------------- CHANNEL VIEW (wrapped so it stays inside UI) -------------
    var cname = channels[selected_channel];

    draw_set_color(c_white);
    draw_text(chat_x1 + 12, content_y1 + 6, cname);

    var desc = "Channel history archived by compliance. Check finance drives for exports.";

    // Wrap this description inside the chat panel width so it never leaks out
    var chat_w_ch   = (chat_x2 - chat_x1) - 24;
    var wrap_w_ch   = chat_w_ch;            // text width limit
    var line_h_ch   = string_height("Ag");
    var lines_ch    = _wrap_text(desc, wrap_w_ch);
    var line_count  = array_length(lines_ch);
    var base_y      = content_y1 + 36;

    draw_set_color(make_color_rgb(176, 189, 220));
    for (var k = 0; k < line_count; k++) {
        draw_text(chat_x1 + 12, base_y + k * (line_h_ch + 2), lines_ch[k]);
    }
}
else {
    draw_set_color(make_color_rgb(176, 189, 220));
    draw_text(chat_x1 + 12, content_y1 + 12, "Select a channel or DM from the left.");
}
