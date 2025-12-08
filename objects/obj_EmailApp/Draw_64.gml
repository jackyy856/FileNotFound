/// obj_EmailApp - Draw GUI

draw_set_alpha(1);

// draw header bar (always)
draw_set_color(c_white);
draw_rectangle(window_x, window_y, window_x + window_w, window_y + header_h, false);
draw_set_color(c_black);
draw_rectangle(window_x, window_y, window_x + window_w, window_y + header_h, true);

// if not minimized, draw full body frame
if (!is_minimized) {
    draw_set_color(c_white);
    draw_rectangle(window_x, window_y + header_h, window_x + window_w, window_y + window_h, false);
    draw_set_color(c_black);
    draw_rectangle(window_x, window_y + header_h, window_x + window_w, window_y + window_h, true);
}

// header text
draw_set_font(font_title);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_black);
draw_text(window_x + 16, window_y + 12, "MailApp");

// ---- minimize button (light gray) ----
var bcol_min = make_colour_rgb(230,230,230);
draw_set_color(bcol_min);
draw_rectangle(min_btn[0], min_btn[1], min_btn[0] + min_btn[2], min_btn[1] + min_btn[3], false);
draw_set_color(c_black);
draw_rectangle(min_btn[0], min_btn[1], min_btn[0] + min_btn[2], min_btn[1] + min_btn[3], true);
draw_text(min_btn[0] + 8, min_btn[1] + 2, "-");

// close button (light gray fill + black border/text)
var bcol = make_colour_rgb(230,230,230);
draw_set_color(bcol);
draw_rectangle(close_btn[0], close_btn[1], close_btn[0] + close_btn[2], close_btn[1] + close_btn[3], false);
draw_set_color(c_black);
draw_rectangle(close_btn[0], close_btn[1], close_btn[0] + close_btn[2], close_btn[1] + close_btn[3], true);
draw_text(close_btn[0] + 7, close_btn[1] + 2, "X");

// If minimized: don't draw the body/content; only title bar visible
if (is_minimized) {
    // reset state for others and exit
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_font(-1);
    draw_set_color(c_white);
    draw_set_alpha(1);
    exit;
}

// locked wifi state – show simple modal and skip normal content
if (email_locked) {
    // body area
    var x1 = window_x;
    var y1 = window_y + header_h;
    var x2 = window_x + window_w;
    var y2 = window_y + window_h;

    // optional: light dim over body (you already drew white frame)
    draw_set_color(c_white);
    draw_rectangle(x1, y1, x2, y2, false);

    // centered modal box
    var box_w = 360;
    var box_h = 120;
    var cx    = (x1 + x2) * 0.5;
    var cy    = (y1 + y2) * 0.5;

    var bx1 = cx - box_w * 0.5;
    var by1 = cy - box_h * 0.5;
    var bx2 = cx + box_w * 0.5;
    var by2 = cy + box_h * 0.5;

    draw_set_color(c_white);
    draw_roundrect(bx1, by1, bx2, by2, false);

    draw_set_color(c_black);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_font(font_body);

    draw_text(cx, cy, email_locked_msg);

    // reset state and exit, so no inbox/puzzle is drawn
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_font(-1);
    draw_set_color(c_white);
    draw_set_alpha(1);
    exit;
}

// content
draw_set_font(font_body);
draw_set_color(c_black);

if (selected_index == -1) {
    // inbox list
    var rowY = list_top;
    var len = array_length(inbox);
    for (var i = 0; i < len; i++) {
        draw_set_alpha(0.08);
        draw_set_color(c_black);
        draw_rectangle(list_left, rowY, list_left + list_w, rowY + row_h, false);
        draw_set_alpha(1);

        if (!inbox[i].read) {
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
else {
    // back button
    var bcol_back = make_colour_rgb(230,230,230);
    draw_set_color(bcol_back);
    draw_rectangle(back_btn[0], back_btn[1], back_btn[0] + back_btn[2], back_btn[1] + back_btn[3], false);
    draw_set_color(c_black);
    draw_rectangle(back_btn[0], back_btn[1], back_btn[0] + back_btn[2], back_btn[1] + back_btn[3], true);
    draw_text(back_btn[0] + 10, back_btn[1] + 3, "< Back");

    var em = inbox[selected_index];

    var _em_cor = variable_struct_exists(em, "is_corrupted") && em.is_corrupted;

    // == Normal mail / solved ==
	if (!_em_cor || puzzle_solved) {
	    var tx = window_x + 20;
	    var ty = window_y + header_h + 12;

	    // Subject
	    draw_set_color(c_black);
	    draw_set_font(font_title);
	    draw_text(tx, ty, em.subject);
	    ty += 28;

	    // From
	    draw_set_font(font_body);
	    draw_text(tx, ty, "From: " + em.from);
	    ty += 22;

	    // Special layout for recovered corrupted email
	    if (selected_index == corrupted_index && puzzle_solved) {
	        // Line 1 + line 2
	        var line1 = "it sure does.";
	        var line2 = "here's your key, sucker. click it to claim it :P";

	        // First line
	        draw_text(tx, ty, line1);
	        ty += 24;

	        // Second line
	        draw_text(tx, ty, line2);

	        // Choose key sprite (glow variant if collected)
	        var key_spr = email_key1_collected ? spr_green_glow_key : spr_green_key;

	        var raw_w = sprite_get_width(key_spr);
	        var raw_h = sprite_get_height(key_spr);

	        // scale down big PNGs to a nice height (e.g. 64px)
	        var desired_h = 64;
	        var key_scale = (raw_h > 0) ? (desired_h / raw_h) : 1;

	        var key_w = raw_w * key_scale;
	        var key_h = raw_h * key_scale;

	        // Place key just to the right of the second line
	        var gap   = 20; // space between text and key
	        var key_x = tx + string_width(line2) + gap;
	        var key_y = ty - key_h * 0.6; // slight lift so it sits nicely with text

	        // store rect for Step click detection (scaled)
	        email_key1_rect = [key_x, key_y, key_w, key_h];

	        // subtle glow if not yet collected
	        if (!email_key1_collected) {
	            draw_set_alpha(0.4);
	            draw_set_color(c_white);
	            draw_roundrect(key_x - 6, key_y - 6,
	                           key_x + key_w + 6, key_y + key_h + 6, false);
	            draw_set_alpha(1);
	        }

	        // draw key sprite at scale
	        draw_sprite_ext(key_spr, 0, key_x, key_y, key_scale, key_scale, 0, c_white, 1);
	    }
	    else {
	        // normal emails: just draw the body
	        var body_w = window_w - 40;
	        draw_text_ext(tx, ty, em.body, 12, body_w);
	    }
	}
	
    // == Corrupted view with riddle, binary rain, and puzzle ==
    else {
        var neon = make_colour_rgb(0, 200, 0);

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

        // Email Corrupted title in white area above hacker box
		var neon    = make_colour_rgb(0, 200, 0);
		draw_set_font(font_title);
		draw_set_color(neon);

		var title_x = window_x + 100;
		var title_y = window_y + 30;
		draw_text(title_x, title_y, "Email Corrupted");

		// Riddle text, plain black, in the white box
		var riddle_text = "Riddle: What an awful job!";
		var riddle_x    = title_x + 600;
		var riddle_y    = title_y - 5;

		draw_set_font(font_body); // or font_riddle if you prefer that one
		draw_set_color(c_black);
		draw_text(riddle_x, riddle_y, riddle_text);


        // Hint dialog box (on top of binary rain, so readable)
        if (puzzle_show_hint) {
            var hw = 420;
            var hh = 80;
            var hx = rx + (rw - hw) * 0.5;
            var hy = ry + 20;

            draw_set_color(make_colour_rgb(240,240,240));
            draw_rectangle(hx, hy, hx + hw, hy + hh, false);
            draw_set_color(c_black);
            draw_rectangle(hx, hy, hx + hw, hy + hh, true);

            var hint_tx = hx + 12;
            var hint_ty = hy + 14;

            draw_set_font(font_body);
            draw_set_color(c_black);
            draw_text(hint_tx, hint_ty, "Hint: Those emails look messy....");
            draw_text(hint_tx, hint_ty + 20, "What do you really think about that place?");
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
        var itext = "Arrange the words (left > right).";
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

        // === WORD TILES (ABS from LOCAL, old style: black bg, green outline) ===
        for (var i2 = 0; i2 < array_length(word_btns); i2++) {
            var b2 = word_btns[i2];
            var ax = window_x + b2.x;
            var ay = window_y + b2.y;

            var w2 = b2.w;
            var h2 = b2.h;

            // fill
            draw_set_color(c_black);
            draw_rectangle(ax, ay, ax + w2, ay + h2, false);

            // outline
            draw_set_color(neon);
            draw_rectangle(ax, ay, ax + w2, ay + h2, true);

            // text
            draw_set_font(font_body);
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_set_color(neon);
            draw_text(ax + w2 * 0.5, ay + h2 * 0.5, b2.text);
        }

        // (Optional modal if you ever re-enable it; harmless now)
        if (puzzle_solved) {
            var mw = 420, mh = 160;
            var mx2 = window_x + (window_w - mw) * 0.5;
            var my2 = window_y + (window_h - mh) * 0.5;

            draw_set_color(make_colour_rgb(250,250,250));
            draw_rectangle(mx2, my2, mx2+mw, my2+mh, false);
            draw_set_color(c_black);
            draw_rectangle(mx2, my2, mx2+mw, my2+mh, true);

            draw_set_font(font_title);
            draw_text(mx2 + 16, my2 + 16, "Email Recovered");

            draw_set_font(font_body);
            draw_text_ext(mx2 + 16, my2 + 52, puzzle_message, 12, mw - 32);

            ok_btn_local[0] = (mx2 + mw - 16 - ok_btn_local[2]) - window_x;
            ok_btn_local[1] = (my2 + mh - 16 - ok_btn_local[3]) - window_y;

            var bcol2 = make_colour_rgb(230,230,230);
            var obx = mx2 + mw - 16 - ok_btn_local[2];
            var oby = my2 + mh - 16 - ok_btn_local[3];
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

// ---- RESET DRAW STATE so other apps (taskbar clock, notes) aren't affected ----
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_font(-1);
draw_set_color(c_white);
draw_set_alpha(1);
