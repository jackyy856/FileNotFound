/// obj_FilesApp – Draw GUI

draw_set_alpha(1);

// Window frame
if (!is_minimized) {
    draw_set_color(c_white);
    draw_rectangle(window_x, window_y, window_x + window_w, window_y + window_h, false);
    draw_set_color(c_black);
    draw_rectangle(window_x, window_y, window_x + window_w, window_y + window_h, true);
} else {
    // only draw header when minimized
    draw_set_color(c_white);
    draw_rectangle(window_x, window_y, window_x + window_w, window_y + header_h, false);
    draw_set_color(c_black);
    draw_rectangle(window_x, window_y, window_x + window_w, window_y + header_h, true);
}

// Title bar
draw_set_font(font_title);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_black);
draw_text(window_x + 16, window_y + 12, "Files");

// Minimize button
var bmin = make_colour_rgb(230,230,230);
draw_set_color(bmin);
draw_rectangle(min_btn[0], min_btn[1], min_btn[0] + min_btn[2], min_btn[1] + min_btn[3], false);
draw_set_color(c_black);
draw_rectangle(min_btn[0], min_btn[1], min_btn[0] + min_btn[2], min_btn[1] + min_btn[3], true);
draw_text(min_btn[0] + 8, min_btn[1] + 2, "-");

// Close button
var bcol = make_colour_rgb(230,230,230);
draw_set_color(bcol);
draw_rectangle(close_btn[0], close_btn[1], close_btn[0] + close_btn[2], close_btn[1] + close_btn[3], false);
draw_set_color(c_black);
draw_rectangle(close_btn[0], close_btn[1], close_btn[0] + close_btn[2], close_btn[1] + close_btn[3], true);
draw_text(close_btn[0] + 7, close_btn[1] + 2, "X");

// If minimized, skip body
if (is_minimized) exit;

// Breadcrumbs (second line)
draw_set_font(font_body);
draw_set_color(make_colour_rgb(60,60,60));
var bc_text = "";
for (var i = 0; i < array_length(breadcrumbs); i++) {
    if (i > 0) bc_text += " / ";
    bc_text += string(breadcrumbs[i].name);
}
draw_text(list_left, breadcrumbs_y, bc_text);

// Back / Up buttons
if (mode == "view") {
    var bcol1 = make_colour_rgb(230,230,230);
    draw_set_color(bcol1);
    draw_rectangle(back_btn[0], back_btn[1], back_btn[0] + back_btn[2], back_btn[1] + back_btn[3], false);
    draw_set_color(c_black);
    draw_rectangle(back_btn[0], back_btn[1], back_btn[0] + back_btn[2], back_btn[1] + back_btn[3], true);
    draw_text(back_btn[0] + 10, back_btn[1] + 3, "< Back");
}
if (cwd.parent != noone) {
    var bcol2 = make_colour_rgb(230,230,230);
    draw_set_color(bcol2);
    draw_rectangle(up_btn[0], up_btn[1], up_btn[0] + up_btn[2], up_btn[1] + up_btn[3], false);
    draw_set_color(c_black);
    draw_rectangle(up_btn[0], up_btn[1], up_btn[0] + up_btn[2], up_btn[1] + up_btn[3], true);
    draw_text(up_btn[0] + 14, up_btn[1] + 3, "Up");
}

// ------------------ CONTENT ------------------
draw_set_font(font_body);
draw_set_color(c_black);

if (mode == "list") {
    // ------- ICON GRID -------
    var folder_spr = asset_get_index("spr_FilesIcon");
    var text_spr   = asset_get_index("spr_StickyNoteIcon");

    var items = cwd.children;
    var len   = array_length(items);
    var cols  = grid_cols;
    var x0    = list_left;
    var y0    = content_top;

    for (var i2 = 0; i2 < len; i2++) {
        var col = i2 mod cols;
        var row = i2 div cols;

        var cell_x = x0 + col * cell_w;
        var cell_y = y0 + row * cell_h;

        var icon_x = cell_x + (cell_w - icon_w) * 0.5;
        var icon_y = cell_y;

        var it = items[i2];

        if (it.type == "folder") {
            if (folder_spr != -1) {
                draw_sprite_ext(folder_spr, 0, icon_x + icon_w*0.5, icon_y + icon_h*0.5, 1, 1, 0, c_white, 1);
            } else {
                draw_set_alpha(0.06);
                draw_set_color(c_black);
                draw_rectangle(icon_x, icon_y, icon_x + icon_w, icon_y + icon_h, false);
                draw_set_alpha(1);
            }
        } else if (it.type == "text") {
            if (text_spr != -1) {
                draw_sprite_ext(text_spr, 0, icon_x + icon_w*0.5, icon_y + icon_h*0.5, 1, 1, 0, c_white, 1);
            } else {
                draw_set_alpha(0.06);
                draw_set_color(c_black);
                draw_rectangle(icon_x, icon_y, icon_x + icon_w, icon_y + icon_h, false);
                draw_set_alpha(1);
                draw_set_color(c_black);
                draw_text(icon_x + 8, icon_y + 8, "TXT");
            }
        } else if (it.type == "image") {
            if (!is_undefined(it.sprite) && it.sprite != -1) {
                var scale = 0.75;
                draw_sprite_ext(it.sprite, 0,
                    icon_x + icon_w*0.5, icon_y + icon_h*0.5,
                    scale, scale, 0, c_white, 1);
            } else {
                draw_set_alpha(0.06);
                draw_set_color(c_black);
                draw_rectangle(icon_x, icon_y, icon_x + icon_w, icon_y + icon_h, false);
                draw_set_alpha(1);
                draw_set_color(c_black);
                draw_text(icon_x + 8, icon_y + 8, "IMG");
            }
        } else if (it.type == "puzzle_firewall") {
            // Firewall.exe icon – simple placeholder
            draw_set_alpha(0.06);
            draw_set_color(c_black);
            draw_rectangle(icon_x, icon_y, icon_x + icon_w, icon_y + icon_h, false);
            draw_set_alpha(1);
            draw_set_color(c_black);
            draw_text(icon_x + 12, icon_y + 32, "FW");
        }

        draw_set_color(c_black);
        draw_set_halign(fa_center);
        var label_x = cell_x + cell_w * 0.5;
        var label_y = icon_y + icon_h + 8;
        draw_text_ext(label_x, label_y, string(it.name), 8, cell_w - 8);
        draw_set_halign(fa_left);
    }
}
else if (mode == "view") {
	// draw red key icon if this view wants it
    if (viewer_show_red_key) {
        var spr_key  = asset_get_index("spr_red_key");
        var spr_glow = asset_get_index("spr_red_glow_key");

        // position near bottom-right inside the Files window
        var key_x = window_x + window_w - 180;
        var key_y = window_y + window_h - 140;

        if (spr_glow != -1) {
            draw_sprite_ext(spr_glow, 0, key_x, key_y, 1, 1, 0, c_white, 1);
        }
        if (spr_key != -1) {
            draw_sprite_ext(spr_key, 0, key_x, key_y, 1, 1, 0, c_white, 1);
        }
    }
	
    // ------- STANDARD PREVIEW -------
    var tx = list_left;
    var ty = content_top;

    draw_set_font(font_title);
    draw_text(tx, breadcrumbs_y + 28, "Preview");

    draw_set_font(font_body);
    if (viewer_type == "text") {
        var body_w = window_w - 40;
        draw_text_ext(tx, ty + 24, viewer_text, 12, body_w);
    } else if (viewer_type == "image") {
        if (viewer_sprite != -1) {
            var cx = window_x + window_w * 0.5;
            var cy = window_y + header_h + (window_h - header_h) * 0.5;
            draw_sprite_ext(viewer_sprite, 0, cx, cy, 1, 1, 0, c_white, 1);
        } else {
            draw_set_alpha(0.05);
            draw_set_color(c_black);
            var px1 = tx, py1 = ty, px2 = window_x + window_w - 20, py2 = window_y + window_h - 20;
            draw_rectangle(px1, py1, px2, py2, false);
            draw_set_alpha(1);
            draw_set_color(c_black);
            draw_text(tx, ty, "(Image placeholder — assign a sprite to this file to preview)");
        }
    }
}
else if (mode == "firewall") {
    // ------- FIREWALL PUZZLE UI -------

    // big black panel
    var panel_x1 = window_x + 140;
    var panel_y1 = content_top + 20;
    var panel_x2 = window_x + window_w - 140;
    var panel_y2 = window_y + window_h - 80;

    draw_set_color(c_black);
    draw_rectangle(panel_x1, panel_y1, panel_x2, panel_y2, false);

    // deny / admit columns
    var deny_x1 = panel_x1 + 40;
    var deny_y1 = panel_y1 + 40;
    var deny_x2 = (panel_x1 + panel_x2) * 0.5 - 20;
    var deny_y2 = panel_y2 - 40;

    var admit_x1 = (panel_x1 + panel_x2) * 0.5 + 20;
    var admit_y1 = deny_y1;
    var admit_x2 = panel_x2 - 40;
    var admit_y2 = deny_y2;

    var col_deny  = make_colour_rgb(150, 80, 80);
    var col_admit = make_colour_rgb(70, 100, 150);

    draw_set_color(col_deny);
    draw_rectangle(deny_x1, deny_y1, deny_x2, deny_y2, false);

    draw_set_color(col_admit);
    draw_rectangle(admit_x1, admit_y1, admit_x2, admit_y2, false);

    // headings
    draw_set_font(font_title);
    draw_set_halign(fa_center);
    draw_set_color(c_white);
    draw_text((deny_x1 + deny_x2) * 0.5, deny_y1 + 16, "Deny");
    draw_text((admit_x1 + admit_x2) * 0.5, admit_y1 + 16, "Admit");

    // top text
    draw_set_font(font_body);
    if (firewall_state == "play") {
        draw_text((panel_x1 + panel_x2) * 0.5, panel_y1 + 4,
                  "Drag each sentence to Deny or Admit.");
    } else if (firewall_state == "auto") {
        draw_text((panel_x1 + panel_x2) * 0.5, panel_y1 + 4,
                  "You can't hide the truth from me.");
    } else if (firewall_state == "done") {
        draw_text((panel_x1 + panel_x2) * 0.5, panel_y1 + 4,
                  "I know everything you tried to bury.");
    }

    // cards
    draw_set_halign(fa_left);
    var n_cards = array_length(firewall_cards);
    for (var i3 = 0; i3 < n_cards; i3++) {
        var c = firewall_cards[i3];

        draw_set_color(c_white);
        draw_rectangle(c.x, c.y, c.x + c.w, c.y + c.h, false);
        draw_set_color(c_black);
        draw_rectangle(c.x, c.y, c.x + c.w, c.y + c.h, true);

        draw_set_color(c_black);
        draw_text_ext(c.x + 18, c.y + 18, c.text, 10, c.w - 36);
    }

    // confirm popup
    if (firewall_state == "confirm") {
        var cw = 420;
        var ch = 140;
        var cx = window_x + (window_w - cw) * 0.5;
        var cy = window_y + (window_h - ch) * 0.5;

        var ok_w = 96, ok_h = 32;
        var ok_x = cx + cw - ok_w - 24;
        var ok_y = cy + ch - ok_h - 24;

        var cancel_w = 96, cancel_h = 32;
        var cancel_x = cx + 24;
        var cancel_y = ok_y;

        // dialog box
        draw_set_alpha(0.85);
        draw_set_color(c_black);
        draw_rectangle(cx, cy, cx + cw, cy + ch, false);
        draw_set_alpha(1);
        draw_set_color(c_white);
        draw_rectangle(cx + 2, cy + 2, cx + cw - 2, cy + ch - 2, true);

        draw_set_color(c_black);
        draw_set_font(font_body);
        draw_set_halign(fa_left);
        draw_text(cx + 20, cy + 24, "Lock these answers in?");

        // OK button
        draw_set_color(make_colour_rgb(230,230,230));
        draw_rectangle(ok_x, ok_y, ok_x + ok_w, ok_y + ok_h, false);
        draw_set_color(c_black);
        draw_rectangle(ok_x, ok_y, ok_x + ok_w, ok_y + ok_h, true);
        draw_text(ok_x + 30, ok_y + 8, "OK");

        // Cancel button
        draw_set_color(make_colour_rgb(230,230,230));
        draw_rectangle(cancel_x, cancel_y, cancel_x + cancel_w, cancel_y + cancel_h, false);
        draw_set_color(c_black);
        draw_rectangle(cancel_x, cancel_y, cancel_x + cancel_w, cancel_y + cancel_h, true);
        draw_text(cancel_x + 16, cancel_y + 8, "Cancel");
    }

    draw_set_halign(fa_left);
}
