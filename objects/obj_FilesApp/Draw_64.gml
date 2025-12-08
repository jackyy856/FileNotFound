/// obj_FilesApp - Draw GUI

draw_set_alpha(1);
draw_set_font(-1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

// -----------------------------------------------------------------------
// MINIMIZED: draw only top bar
// -----------------------------------------------------------------------
if (is_minimized) {
    // header bar
    draw_set_color(c_white);
    draw_rectangle(window_x, window_y,
                   window_x + window_w,
                   window_y + header_h, false);

    draw_set_color(c_black);
    draw_rectangle(window_x, window_y,
                   window_x + window_w,
                   window_y + header_h, true);

    // title
    draw_set_color(c_black);
    draw_text(window_x + 8, window_y + 8, "Files");

    // minimize button
    var bcol_min = make_colour_rgb(230,230,230);
    draw_set_color(bcol_min);
    draw_rectangle(files_min_btn[0], files_min_btn[1],
                   files_min_btn[0] + files_min_btn[2],
                   files_min_btn[1] + files_min_btn[3], false);
    draw_set_color(c_black);
    draw_rectangle(files_min_btn[0], files_min_btn[1],
                   files_min_btn[0] + files_min_btn[2],
                   files_min_btn[1] + files_min_btn[3], true);
    draw_text(files_min_btn[0] + 8, files_min_btn[1] + 2, "-");

    // close button
    draw_set_color(bcol_min);
    draw_rectangle(files_close_btn[0], files_close_btn[1],
                   files_close_btn[0] + files_close_btn[2],
                   files_close_btn[1] + files_close_btn[3], false);
    draw_set_color(c_black);
    draw_rectangle(files_close_btn[0], files_close_btn[1],
                   files_close_btn[0] + files_close_btn[2],
                   files_close_btn[1] + files_close_btn[3], true);
    draw_text(files_close_btn[0] + 7, files_close_btn[1] + 2, "X");

    draw_set_alpha(1);
    exit;
}

// -----------------------------------------------------------------------
// FULL WINDOW BACKGROUND
// -----------------------------------------------------------------------
draw_set_color(c_white);
draw_rectangle(window_x, window_y,
               window_x + window_w,
               window_y + window_h, false);

draw_set_color(c_black);
draw_rectangle(window_x, window_y,
               window_x + window_w,
               window_y + window_h, true);

// title
draw_set_color(c_black);
draw_text(window_x + 8, window_y + 8, "Files");

// close / minimize buttons
var bcol = make_colour_rgb(230,230,230);

// minimize
draw_set_color(bcol);
draw_rectangle(files_min_btn[0], files_min_btn[1],
               files_min_btn[0] + files_min_btn[2],
               files_min_btn[1] + files_min_btn[3], false);
draw_set_color(c_black);
draw_rectangle(files_min_btn[0], files_min_btn[1],
               files_min_btn[0] + files_min_btn[2],
               files_min_btn[1] + files_min_btn[3], true);
draw_text(files_min_btn[0] + 8, files_min_btn[1] + 2, "-");

// close
draw_set_color(bcol);
draw_rectangle(files_close_btn[0], files_close_btn[1],
               files_close_btn[0] + files_close_btn[2],
               files_close_btn[1] + files_close_btn[3], false);
draw_set_color(c_black);
draw_rectangle(files_close_btn[0], files_close_btn[1],
               files_close_btn[0] + files_close_btn[2],
               files_close_btn[1] + files_close_btn[3], true);
draw_text(files_close_btn[0] + 7, files_close_btn[1] + 2, "X");

// -----------------------------------------------------------------------
//                               HOME VIEW
// -----------------------------------------------------------------------
if (view_mode == 0) {

    draw_set_color(c_black);
    draw_text(window_x + 8, window_y + header_h + 4, "Home");

    var spr_icon = spr_FilesIcon; // folder sprite

    for (var i = 0; i < array_length(home_entries); i++) {
        var e = home_entries[i];

        if (spr_icon != -1) {
            var sw = sprite_get_width(spr_icon);
            var sh = sprite_get_height(spr_icon);

            var cx = e.rx + e.rw * 0.5;
            var cy = e.ry + e.rh * 0.5;

            var scale = 1;
            if (sw > 0 && sh > 0) {
                var sx = (e.rw - 20) / sw;
                var sy = (e.rh - 20) / sh;
                scale = min(sx, sy);
            }

            draw_sprite_ext(spr_icon, 0, cx, cy, scale, scale, 0, c_white, 1);
        } else {
            draw_set_color(c_black);
            draw_rectangle(e.rx, e.ry, e.rx + e.rw, e.ry + e.rh, true);
        }

        // special "FW" marking on Firewall.exe card
        if (e.kind == "firewall") {
            draw_set_color(c_black);
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_text(e.rx + e.rw * 0.5, e.ry + e.rh * 0.5, "FW");
        }

        // centered label under icon
        draw_set_halign(fa_center);
        draw_set_valign(fa_top);
        draw_set_color(c_black);
        draw_text(e.rx + e.rw * 0.5, e.ry + e.rh + 10, e.label);
    }

    draw_set_alpha(1);
    exit;
}

// -----------------------------------------------------------------------
//                        FIREWALL PUZZLE VIEW
// -----------------------------------------------------------------------
if (view_mode == 1) {

    draw_set_color(c_black);
    draw_set_halign(fa_left);
    draw_text(window_x + 8, window_y + header_h + 4, "Home / Firewall.exe");

    // Back button
    var back_btn_x = window_x + window_w - 120;
    var back_btn_y = window_y + 60;
    var back_btn_w = 80;
    var back_btn_h = 24;

    var back_col = make_colour_rgb(230,230,230);
    draw_set_color(back_col);
    draw_rectangle(back_btn_x, back_btn_y,
                   back_btn_x + back_btn_w,
                   back_btn_y + back_btn_h, false);
    draw_set_color(c_black);
    draw_rectangle(back_btn_x, back_btn_y,
                   back_btn_x + back_btn_w,
                   back_btn_y + back_btn_h, true);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(back_btn_x + back_btn_w * 0.5,
              back_btn_y + back_btn_h * 0.5, "< Back");

    // instruction text (centered)
    draw_set_halign(fa_center);
    draw_set_color(c_black);
    draw_text(window_x + window_w * 0.5,
              window_y + window_h - 180,
              "Drag the sentences to your answer honestly");

    // outer frame
    draw_set_halign(fa_left);
    draw_set_color(c_black);
    draw_rectangle(fw_frame.x, fw_frame.y,
                   fw_frame.x + fw_frame.w,
                   fw_frame.y + fw_frame.h, false);

    // deny panel
    var deny_col = make_colour_rgb(140, 70, 70);
    draw_set_color(deny_col);
    draw_rectangle(fw_deny.x, fw_deny.y,
                   fw_deny.x + fw_deny.w,
                   fw_deny.y + fw_deny.h, false);

    // admit panel
    var admit_col = make_colour_rgb(70, 90, 140);
    draw_set_color(admit_col);
    draw_rectangle(fw_admit.x, fw_admit.y,
                   fw_admit.x + fw_admit.w,
                   fw_admit.y + fw_admit.h, false);

    // panel labels
    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    draw_text(fw_deny.x + fw_deny.w * 0.5, fw_deny.y + 8, "Deny");
    draw_text(fw_admit.x + fw_admit.w * 0.5, fw_admit.y + 8, "Admit");

    // tiles
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);

    for (var t = 0; t < array_length(fw_tiles); t++) {
        var tile = fw_tiles[t];

        var tx = tile.x;
        var ty = tile.y;
        var tw = tile.w;
        var th = tile.h;

        draw_set_color(c_white);
        draw_rectangle(tx, ty, tx + tw, ty + th, false);

        draw_set_color(c_black);
        draw_rectangle(tx, ty, tx + tw, ty + th, true);

        draw_set_color(c_black);
        var text_y = ty + (th - 14) * 0.5;
        draw_text(tx + 6, text_y, tile.text);
    }

    // confirm popup
    if (fw_confirm_open) {
        var mw  = 420;
        var mh  = 160;
        var mx2 = window_x + (window_w - mw) * 0.5;
        var my2 = window_y + (window_h - mh) * 0.5;

        draw_set_alpha(0.95);
        draw_set_color(c_black);
        draw_rectangle(mx2, my2, mx2 + mw, my2 + mh, false);

        draw_set_alpha(1);
        draw_set_color(c_white);
        draw_rectangle(mx2, my2, mx2 + mw, my2 + mh, true);

        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        draw_set_color(c_white);
        draw_text(mx2 + 20, my2 + 20, "Lock these answers?");

        var btn_w = 100;
        var btn_h = 30;
        var gap_x = 30;
        var btn_y = my2 + mh - 50;

        var cancel_x = mx2 + 40;
        var ok_x     = cancel_x + btn_w + gap_x;

        var bc = make_colour_rgb(200,200,200);

        // cancel
        draw_set_color(bc);
        draw_rectangle(cancel_x, btn_y, cancel_x + btn_w, btn_y + btn_h, false);
        draw_set_color(c_black);
        draw_rectangle(cancel_x, btn_y, cancel_x + btn_w, btn_y + btn_h, true);
        draw_set_color(c_black);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_text(cancel_x + btn_w * 0.5, btn_y + btn_h * 0.5, "Cancel");

        // OK
        draw_set_color(bc);
        draw_rectangle(ok_x, btn_y, ok_x + btn_w, btn_y + btn_h, false);
        draw_set_color(c_black);
        draw_rectangle(ok_x, btn_y, ok_x + btn_w, btn_y + btn_h, true);
        draw_set_color(c_black);
        draw_text(ok_x + btn_w * 0.5, btn_y + btn_h * 0.5, "OK");
    }

    draw_set_alpha(1);
    exit;
}

// -----------------------------------------------------------------------
//                         FIREWALL LOG / KEY VIEW
// -----------------------------------------------------------------------
if (view_mode == 2) {

    draw_set_color(c_black);
    draw_set_halign(fa_left);
    draw_text(window_x + 8, window_y + header_h + 4, "Home / Firewall.exe");

    // Back button
    var back_btn_x2 = window_x + window_w - 120;
    var back_btn_y2 = window_y + 60;
    var back_btn_w2 = 80;
    var back_btn_h2 = 24;

    var back_col2 = make_colour_rgb(230,230,230);
    draw_set_color(back_col2);
    draw_rectangle(back_btn_x2, back_btn_y2,
                   back_btn_x2 + back_btn_w2,
                   back_btn_y2 + back_btn_h2, false);
    draw_set_color(c_black);
    draw_rectangle(back_btn_x2, back_btn_y2,
                   back_btn_x2 + back_btn_w2,
                   back_btn_y2 + back_btn_h2, true);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(back_btn_x2 + back_btn_w2 * 0.5,
              back_btn_y2 + back_btn_h2 * 0.5, "< Back");

    // Log text
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_black);
    var tx = window_x + 8;
    var ty = window_y + header_h + 40;
    draw_text(tx, ty, "Preview");
    ty += 24;
    draw_text_ext(tx, ty, fw_log_text, 12, window_w - 40);

    // key sprite
    var line_prefix = "Click the gold key.";
    var line_w = string_width(line_prefix);

    var key_spr = fw_key_collected_local ? spr_golden_glow_key : spr_golden_key;

    if (key_spr != -1) {
        var raw_w = sprite_get_width(key_spr);
        var raw_h = sprite_get_height(key_spr);

        var desired_h = 64;
        var sc = (raw_h > 0) ? (desired_h / raw_h) : 1;

        var key_w = raw_w * sc;
        var key_h = raw_h * sc;

        var key_y = window_y + header_h + 40 + 24 + 7 * 16;
        var key_x = tx + line_w + 32;

        fw_key_rect[0] = key_x;
        fw_key_rect[1] = key_y;
        fw_key_rect[2] = key_w;
        fw_key_rect[3] = key_h;

        draw_sprite_ext(key_spr, 0, key_x, key_y, sc, sc, 0, c_white, 1);
    }

    draw_set_alpha(1);
    exit;
}

// -----------------------------------------------------------------------
//                 GENERIC FOLDER VIEW (OPEN ME / HR / Images)
// -----------------------------------------------------------------------
if (view_mode == 3) {

    draw_set_color(c_black);
    draw_set_halign(fa_left);
    draw_text(window_x + 8, window_y + header_h + 4,
              "Home / " + string(current_folder));

    // Back button
    var back_btn_x3 = window_x + window_w - 120;
    var back_btn_y3 = window_y + 60;
    var back_btn_w3 = 80;
    var back_btn_h3 = 24;

    var back_col3 = make_colour_rgb(230,230,230);
    draw_set_color(back_col3);
    draw_rectangle(back_btn_x3, back_btn_y3,
                   back_btn_x3 + back_btn_w3,
                   back_btn_y3 + back_btn_h3, false);
    draw_set_color(c_black);
    draw_rectangle(back_btn_x3, back_btn_y3,
                   back_btn_x3 + back_btn_w3,
                   back_btn_y3 + back_btn_h3, true);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(back_btn_x3 + back_btn_w3 * 0.5,
              back_btn_y3 + back_btn_h3 * 0.5, "< Back");

    if (current_folder == "OPEN ME") {

        if (open_me_stage == 0) {
            // inner folder icon + label
            var card_wi = 160;
            var card_hi = 140;
            var fx = window_x + (window_w - card_wi) * 0.5;
            var fy = window_y + header_h + 120;

            var spr_icon2 = spr_FilesIcon;

            if (spr_icon2 != -1) {
                var sw2 = sprite_get_width(spr_icon2);
                var sh2 = sprite_get_height(spr_icon2);

                var cx2 = fx + card_wi * 0.5;
                var cy2 = fy + card_hi * 0.5;

                var scale2 = 1;
                if (sw2 > 0 && sh2 > 0) {
                    var sx2 = (card_wi - 20) / sw2;
                    var sy2 = (card_hi - 20) / sh2;
                    scale2 = min(sx2, sy2);
                }

                draw_sprite_ext(spr_icon2, 0, cx2, cy2, scale2, scale2, 0, c_white, 1);
            } else {
                draw_set_color(c_black);
                draw_rectangle(fx, fy, fx + card_wi, fy + card_hi, true);
            }

            draw_set_halign(fa_center);
            draw_set_valign(fa_top);
            draw_set_color(c_black);
            draw_text(fx + card_wi * 0.5, fy + card_hi + 10,
                      "This is it - RealFileNotFound, Congrats!!!");

        } else {
            // stage 1: show video + banner text
            draw_set_halign(fa_center);
            draw_set_valign(fa_top);
            draw_set_color(c_black);
            draw_text(window_x + window_w * 0.5,
                      back_btn_y3 + 4,
                      "RickRolled You!!! HAHAHAHA");

            if (video_active) {
                var vd = video_draw();
                var status = vd[0];

                if (status == 0) {
                    var surf = vd[1];

                    if (surface_exists(surf)) {
                        var px = window_x + 40;
                        var py = window_y + header_h + 100;
                        var pw = window_w - 80;
                        var ph = window_h - header_h - 140;

                        draw_surface_stretched(surf, px, py, pw, ph);
                    }
                } else {
                    video_close();
                    video_active  = false;
                    open_me_stage = 0;
                }
            } else {
                draw_set_halign(fa_center);
                draw_set_valign(fa_top);
                draw_set_color(c_black);
                draw_text(window_x + window_w * 0.5,
                          window_y + header_h + 120,
                          "(Video not playing.)");
            }
        }

    } else {
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        draw_set_color(c_black);
        draw_text(window_x + 40, window_y + header_h + 80,
                  "(This folder is empty.)");
    }

    draw_set_alpha(1);
    exit;
}

// reset draw state
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_font(-1);
draw_set_color(c_white);
draw_set_alpha(1);
