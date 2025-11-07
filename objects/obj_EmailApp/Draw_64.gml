draw_set_alpha(1);
draw_set_color(c_white);
draw_rectangle(window_x, window_y, window_x + window_w, window_y + window_h, false);
draw_set_color(c_black);
draw_rectangle(window_x, window_y, window_x + window_w, window_y + window_h, true);

//header
draw_set_font(font_title);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_text(window_x + 16, window_y + 12, "MailApp");

// ---- minimize button (light gray) ----
var bcol_min = make_colour_rgb(230,230,230);
draw_set_color(bcol_min);
draw_rectangle(min_btn[0], min_btn[1], min_btn[0] + min_btn[2], min_btn[1] + min_btn[3], false);
draw_set_color(c_black);
draw_rectangle(min_btn[0], min_btn[1], min_btn[0] + min_btn[2], min_btn[1] + min_btn[3], true);
draw_text(min_btn[0] + 8, min_btn[1] + 2, "-");

//close button (light gray fill + black border/text)
var bcol = make_colour_rgb(230,230,230);
draw_set_color(bcol);
draw_rectangle(close_btn[0], close_btn[1], close_btn[0] + close_btn[2], close_btn[1] + close_btn[3], false);
draw_set_color(c_black);
draw_rectangle(close_btn[0], close_btn[1], close_btn[0] + close_btn[2], close_btn[1] + close_btn[3], true);
draw_text(close_btn[0] + 7, close_btn[1] + 2, "X");

// If minimized: don't draw the body/content; only title bar visible
if (is_minimized) exit;

//content
draw_set_font(font_body);
draw_set_color(c_black);

if (selected_index == -1) 
{
    var rowY = list_top;
    var len = array_length(inbox);
    for (var i = 0; i < len; i++) 
    {
        draw_set_alpha(0.08);
        draw_set_color(c_black);
        draw_rectangle(list_left, rowY, list_left + list_w, rowY + row_h, false);
        draw_set_alpha(1);

        if (!inbox[i].read) 
        {
            draw_circle(list_left + 10, rowY + row_h * 0.5, 4, false);
        }

        var subj = string(inbox[i].subject);
        var from = string(inbox[i].from);

        var _is_cor = variable_struct_exists(inbox[i], "is_corrupted") && inbox[i].is_corrupted;
        if (_is_cor) {
            draw_set_font(font_body);
            var neon     = make_colour_rgb(0, 200, 0);
            var iconSize = 12;
            var iconX    = list_left + 24;
            var iconY    = rowY + (row_h - iconSize) * 0.5 + 1;

            draw_set_color(c_red);
            draw_rectangle(iconX, iconY, iconX + iconSize, iconY + iconSize, false);
            draw_set_color(c_white);
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_text(iconX + iconSize * 0.5, iconY + iconSize * 0.5 + 1, "!");

            var fromX = iconX + iconSize + 4;
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
            draw_set_color(c_red);
            draw_text(fromX, rowY + 6, from);

            var sep  = " — ";
            var sepX = fromX + string_width(from);
            draw_set_color(c_black);
            draw_text(sepX, rowY + 6, sep);

            var subjX = sepX + string_width(sep);
            draw_set_color(neon);
            draw_text(subjX, rowY + 6, subj);

            draw_set_color(neon);
            draw_circle(list_left + 10, rowY + row_h * 0.5, 4, false);
        } else {
            draw_set_color(c_black);
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
            draw_text(list_left + 24, rowY + 6, from + " — " + subj);

            if (!inbox[i].read) {
                draw_circle(list_left + 10, rowY + row_h * 0.5, 4, false);
            }
        }

        rowY += row_h;
        if (rowY > list_top + list_h) break;
    }
} 
else 
{
    // back button
    var bcol_back = make_colour_rgb(230,230,230);
    draw_set_color(bcol_back);
    draw_rectangle(back_btn[0], back_btn[1], back_btn[0] + back_btn[2], back_btn[1] + back_btn[3], false);
    draw_set_color(c_black);
    draw_rectangle(back_btn[0], back_btn[1], back_btn[0] + back_btn[2], back_btn[1] + back_btn[3], true);
    draw_text(back_btn[0] + 10, back_btn[1] + 3, "< Back");

    var em = inbox[selected_index];

    var _em_cor = variable_struct_exists(em, "is_corrupted") && em.is_corrupted;
    if (!_em_cor || puzzle_solved) {
        var tx = window_x + 20;
        var ty = window_y + header_h + 12;

        draw_set_color(c_black);
        draw_set_font(font_title);
        draw_text(tx, ty, em.subject);
        ty += 28;

        draw_set_font(font_body);
        draw_text(tx, ty, "From: " + em.from);
        ty += 22;

        var body_w = window_w - 40;
        draw_text_ext(tx, ty, em.body, 12, body_w);
    }
    else
    {
        var tx = window_x + 20;
        var ty = window_y + header_h + 12;
        var neon = make_colour_rgb(0, 200, 0);

        draw_set_font(font_title);
        draw_set_color(neon);
        draw_text(tx, ty, "Email Corrupted");
        draw_text(tx+1, ty, "Email Corrupted");
        draw_text(tx-1, ty, "Email Corrupted");
        ty += 28;

        // Binary rain background area (ABS using local struct)
        var rx = window_x + bin_area_local.x;
        var ry = window_y + bin_area_local.y;
        var rw = bin_area_local.w;
        var rh = bin_area_local.h;

        // base
        draw_set_color(make_colour_rgb(16, 24, 16));
        draw_rectangle(rx, ry, rx + rw, ry + rh, false);

        // rows of digits (no overshoot)
        var cell       = max(10, bin_cell);
        var scroll_mod = bin_scroll % cell;
        var first_row  = ry + ((cell - scroll_mod) % cell);
        if (first_row == ry + cell) first_row = ry;

        for (var gy = first_row; gy <= ry + rh - cell; gy += cell) {
            var row = floor((gy - ry) / cell);
            for (var gx = rx; gx <= rx + rw - cell; gx += cell) {
                var col = floor((gx - rx) / cell);
                var h = (col * 73856093) ^ (row * 19349663);
                var bit = h & 1;
                var ch  = bit ? "1" : "0";
                var bright = (h >> 1) & 3;
                var shade  = clamp(140 + bright*25, 140, 240);
                draw_set_color(make_colour_rgb(0, shade, 0));
                draw_set_font(font_body);
                draw_set_halign(fa_left);
                draw_set_valign(fa_top);
                draw_text(gx + 2, gy + 1, ch);
            }
        }

        // Puzzle area (ABS)
        var pax = window_x + puzzle_area_local.x;
        var pay = window_y + puzzle_area_local.y;
        var paw = puzzle_area_local.w;
        var pah = puzzle_area_local.h;

        draw_set_color(c_black);
        draw_rectangle(pax, pay, pax + paw, pay + pah, false);
        draw_set_color(neon);
        draw_rectangle(pax, pay, pax + paw, pay + pah, true);

        // Instruction
        var itext = "Arrange the words (left→right).";
        draw_set_font(font_body);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        draw_set_color(c_black);
        draw_text(pax-1, pay-26, itext);
        draw_text(pax+1, pay-26, itext);
        draw_text(pax,   pay-27, itext);
        draw_text(pax,   pay-25, itext);
        draw_set_color(c_white);
        draw_text(pax, pay-26, itext);

        // Word tiles (ABS from LOCAL)
        for (var i = 0; i < array_length(word_btns); i++) {
            var b = word_btns[i];
            var ax = window_x + b.x;
            var ay = window_y + b.y;

            draw_set_color(c_black);
            draw_rectangle(ax, ay, ax + b.w, ay + b.h, false);

            draw_set_color(neon);
            draw_rectangle(ax, ay, ax + b.w, ay + b.h, true);

            draw_set_font(font_body);
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_set_color(neon);
            draw_text(ax + b.w * 0.5, ay + b.h * 0.5, b.text);
        }

        // Modal if solved (ABS)
        if (puzzle_solved) {
            var mw = 420, mh = 160;
            var mx = window_x + (window_w - mw) * 0.5;
            var my = window_y + (window_h - mh) * 0.5;

            draw_set_color(make_colour_rgb(250,250,250));
            draw_rectangle(mx, my, mx+mw, my+mh, false);
            draw_set_color(c_black);
            draw_rectangle(mx, my, mx+mw, my+mh, true);

            draw_set_font(font_title);
            draw_text(mx + 16, my + 16, "Email Recovered");

            draw_set_font(font_body);
            draw_text_ext(mx + 16, my + 52, puzzle_message, 12, mw - 32);

            ok_btn_local[0] = (mx + mw - 16 - ok_btn_local[2]) - window_x;
            ok_btn_local[1] = (my + mh - 16 - ok_btn_local[3]) - window_y;

            var bcol2 = make_colour_rgb(230,230,230);
            var obx = mx + mw - 16 - ok_btn_local[2];
            var oby = my + mh - 16 - ok_btn_local[3];
            draw_set_color(bcol2);
            draw_rectangle(obx, oby, obx+ok_btn_local[2], oby+ok_btn_local[3], false);
            draw_set_color(c_black);
            draw_rectangle(obx, oby, obx+ok_btn_local[2], oby+ok_btn_local[3], true);
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_text(obx+ok_btn_local[2]*0.5, oby+ok_btn_local[3]*0.5, "Ok");
        }
    }
}
