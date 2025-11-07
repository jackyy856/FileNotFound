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

// minimize button (light gray)
var bcol_min = make_colour_rgb(230,230,230);
draw_set_color(bcol_min);
draw_rectangle(min_btn[0], min_btn[1], min_btn[0] + min_btn[2], min_btn[1] + min_btn[3], false);
draw_set_color(c_black);
draw_rectangle(min_btn[0], min_btn[1], min_btn[0] + min_btn[2], min_btn[1] + min_btn[3], true);
draw_text(min_btn[0] + 8, min_btn[1] + 2, "-");

//close button (light gray)
var bcol = make_colour_rgb(230,230,230);
draw_set_color(bcol);
draw_rectangle(close_btn[0], close_btn[1], close_btn[0] + close_btn[2], close_btn[1] + close_btn[3], false);
draw_set_color(c_black);
draw_rectangle(close_btn[0], close_btn[1], close_btn[0] + close_btn[2], close_btn[1] + close_btn[3], true);
draw_text(close_btn[0] + 7, close_btn[1] + 2, "X");

// content hidden when minimized
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

        /// Corrupted email visual in inbox
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
    // back button (light gray)
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

	    var rx = window_x + 12;
		var ry = window_y + header_h + 8;
		var rw = window_w - 24;
		var rh = window_h - header_h - 80;

	    draw_set_color(make_colour_rgb(16, 24, 16));
	    draw_rectangle(rx, ry, rx + rw, ry + rh, false);

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

	    draw_set_color(c_black);
	    draw_rectangle(puzzle_area.x, puzzle_area.y, puzzle_area.x + puzzle_area.w, puzzle_area.y + puzzle_area.h, false);
	    draw_set_color(neon);
	    draw_rectangle(puzzle_area.x, puzzle_area.y, puzzle_area.x + puzzle_area.w, puzzle_area.y + puzzle_area.h, true);

	    var ix = puzzle_area.x;
	    var iy = puzzle_area.y - 26;
	    var itext = "Arrange the words (left→right).";
	    draw_set_font(font_body);
	    draw_set_halign(fa_left);
	    draw_set_valign(fa_top);
	    draw_set_color(c_black);
	    draw_text(ix-1, iy, itext); draw_text(ix+1, iy, itext);
	    draw_text(ix, iy-1, itext); draw_text(ix, iy+1, itext);
	    draw_set_color(c_white);
	    draw_text(ix, iy, itext);

	    draw_set_alpha(1);

	    for (var i2 = 0; i2 < array_length(word_btns); i2++) {
	        var b = word_btns[i2];
	        draw_set_color(c_black);
	        draw_rectangle(b.x, b.y, b.x + b.w, b.y + b.h, false);
	        draw_set_color(neon);
	        draw_rectangle(b.x, b.y, b.x + b.w, b.y + b.h, true);
	        draw_set_font(font_body);
	        draw_set_halign(fa_center);
	        draw_set_valign(fa_middle);
	        draw_set_color(neon);
	        draw_text(b.x + b.w * 0.5, b.y + b.h * 0.5, b.text);
	    }

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

	        ok_btn[0] = mx2 + mw - 16 - ok_btn[2];
	        ok_btn[1] = my2 + mh - 16 - ok_btn[3];

	        var bcol2 = make_colour_rgb(230,230,230);
	        draw_set_color(bcol2);
	        draw_rectangle(ok_btn[0], ok_btn[1], ok_btn[0]+ok_btn[2], ok_btn[1]+ok_btn[3], false);
	        draw_set_color(c_black);
	        draw_rectangle(ok_btn[0], ok_btn[1], ok_btn[0]+ok_btn[2], ok_btn[1]+ok_btn[3], true);
	        draw_set_halign(fa_center);
	        draw_set_valign(fa_middle);
	        draw_text(ok_btn[0]+ok_btn[2]*0.5, ok_btn[1]+ok_btn[3]*0.5, "Ok");
	    }
	}
}
